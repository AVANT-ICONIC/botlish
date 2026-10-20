# cabi.tcl -- the C ABI type universe in the front end (C-ABI-TYPES.md):
# the target-resolved C integer scalars, std::ffi::c::Void, std::ffi::c::Ptr[T] and
# std::ffi::c::FnPtr[F].
#
#   std::ffi::c::Char ... ULongLong      C integer scalars: integer domains
#                                        (Int in exactly the target's range
#                                        of the C type) carrying C ABI
#                                        metadata (core::type's -c-abi)
#   std::ffi::c::Bool                    C _Bool: Botlish's own bool (the
#                                        same type, the C ABI's spelling of
#                                        it), carried as the one byte 0 or 1
#   std::ffi::c::Double                  C double: Botlish's own Float64 (the
#                                        same type, the C ABI's spelling of
#                                        it), carried as the target's IEEE
#                                        754 binary64 in its floating-point
#                                        register class. The two differ at
#                                        the boundary only: every Float64 is
#                                        a double, but a double C returns is
#                                        a Float64 only when it is finite
#                                        (NaN and the infinities are the
#                                        call's NonFiniteFloat, negative
#                                        zero is zero: FLOAT64-MILESTONE-1.md)
#   std::ffi::c::Void                    the C void: a permanently
#                                        incomplete pointee, never a type of
#                                        a value
#   std::ffi::c::Ptr[T]    {cptr T}      a C data pointer with pointee T
#   std::ffi::c::FnPtr[F]  {cfnptr F}    a C function pointer of signature
#                                        F, a Fn{args: [...], return: R}
#
# The scalars
# -----------
# They are ordinary source-defined integer domains of namespace std::ffi::c whose
# declarations no file spells: when a file imports std::ffi::c, the loader
# (surface/modules.tcl's LoadNamespace) adds NamespaceTypeDecls's
# declarations for the compilation's C target to the module's own, so they
# are registered, captured, activated, printed and read back exactly as
# every module's `type` is (hir/sourcetypes.tcl, hir/declarations.tcl): a
# HIR keeps the target's widths whatever is compiled after it, and HIR text
# and interchange carry them (`type std::ffi::c::Long parent Int domain interval
# LO HI cabi {long} TARGET`). Values are ordinary Ints: arithmetic on them
# is Botlish arithmetic, and a value is admitted into one only by a proof
# that it lies in the range (hir/range.tcl), as into any domain.
#
# Pointee identities
# ------------------
# A pointer's T is an identity, not the type of any value:
#
#   void                     std::ffi::c::Void
#   bool                     std::ffi::c::Bool, C _Bool
#   {refined int {NAME}}     a C integer scalar (NAME has -c-abi metadata)
#   {nstruct ID}             an *opaque* struct: a module-owned nominal
#                            identity (OPAQUE-STRUCTS.md), what a binding
#                            names an incomplete C tag (`SSL`) by; its
#                            Botlish fields are never the pointee's layout
#   {cptr P}, {cfnptr F}     another pointer: nesting is structural
#   {imprint T}              an imprint variable (hir/imprint.tcl), bound to
#                            a pointee at each call
#
# Everything else -- int, str, List[...], an ordinary struct, an enum,
# LayoutStruct[L], a non-C integer domain -- has no C representation contract
# and is rejected (PointeeProblem). A function pointer's argument types are
# C ABI value types (a scalar, a Ptr or a FnPtr) and its result is one of
# them or unit (C's void result); it declares no errors.

namespace eval hir::cabi {
    # The intrinsic type names of namespace std::ffi::c besides its scalars: the
    # incomplete pointee and the two pointer constructors.
    variable intrinsicTypes {Void Ptr FnPtr Bool Double}
}

# The C target a compilation uses: TARGET when given, else the host's. An
# unknown name is an error (main.tcl's -target, the front end's -target).
proc hir::cabi::ResolveTarget {target} {
    if {$target eq ""} {
        return [core::cabi::hostTarget]
    }
    if {![core::cabi::isTarget $target]} {
        error "unknown C ABI target \"$target\" (known: [join [core::cabi::targetNames] {, }])"
    }
    return $target
}

# 1 if namespace NS has target-dependent intrinsic type declarations
# (NamespaceTypeDecls): std::ffi::c, whose scalars are the target's.
proc hir::cabi::HasNamespaceTypes {ns} {
    return [expr {$ns eq $::core::cabi::namespace}]
}

# The target HIR was built for (surface/modules.tcl, "Target dependence"):
# the compilation target when the build read it (an architecture-specific
# module, a platform namespace, std::ffi::c's scalars), "" for a HIR that is
# every target's. A HIR from HIR text records the target its C integer
# scalars name (hir::read); one from core IR text none.
proc hir::cabi::targetOf {hir} {
    return [dict getdef $hir target ""]
}

# Why HIR cannot stand for a compilation for TARGET, or "" when it can: a HIR
# built for another target keeps that target's meaning (its C scalars'
# widths and signedness, its platform modules), which is never reinterpreted
# as TARGET's -- not even for a target of the same architecture and pointer
# width. A HIR that is every target's (targetOf "") stands for any; TARGET ""
# (a host that is no known target) accepts only such a HIR.
proc hir::cabi::TargetMismatch {hir target} {
    set built [targetOf $hir]
    if {$built eq "" || $built eq $target} {
        return ""
    }
    if {$target eq ""} {
        return "it was built for target $built, and this host ($::tcl_platform(os) $::tcl_platform(machine)) is none of the known targets: name the target with -target $built"
    }
    return "it was built for target $built, not $target: a HIR keeps the target it was built for (its C ABI facts and platform modules) and is never reinterpreted as another's; compile the program for $target"
}

# The intrinsic type declarations of namespace NS on C TARGET, located at
# SPAN (the module file's): the C integer scalars for std::ffi::c, nothing for any
# other namespace. Shaped like surface/lower.tcl's TypeDeclOf dicts plus
# their `cabi` metadata.
proc hir::cabi::NamespaceTypeDecls {ns target span} {
    if {$ns ne $::core::cabi::namespace} {
        return {}
    }
    set decls {}
    foreach name [core::cabi::scalarNames] {
        set info [core::cabi::scalarInfo $name $target]
        lassign [core::cabi::scalarDomain $info] _ lo hi
        lappend decls [dict create name $name nameSpan $span namespace $ns \
            parent Int parentSpan $span \
            domain [dict create kind interval lo $lo loSpan $span hi $hi hiSpan $span span $span] \
            domainSpan $span cabi $info]
    }
    return $decls
}

# The intrinsic non-scalar type names of namespace NS (Void, Ptr, FnPtr of
# std::ffi::c), which the loader authorizes like a module's own types.
proc hir::cabi::IntrinsicTypeNames {ns} {
    variable intrinsicTypes
    if {$ns eq $::core::cabi::namespace} {
        return $intrinsicTypes
    }
    return {}
}

# The C target of the compilation whose declarations are installed: the one
# its std::ffi::c scalars were declared for (NamespaceTypeDecls, re-derived by
# hir/read.tcl from HIR text), or "" when no file of it imports std::ffi::c.
proc hir::cabi::CompilationTarget {} {
    set info [core::type::cabiOf "$::core::cabi::namespace\::[lindex [core::cabi::scalarNames] 0]"]
    if {$info eq ""} {
        return ""
    }
    return [dict get $info target]
}

# The spellings of the intrinsic types, as a type expression writes them.
proc hir::cabi::VoidName {} { return "$::core::cabi::namespace\::Void" }
proc hir::cabi::BoolName {} { return "$::core::cabi::namespace\::Bool" }
proc hir::cabi::DoubleName {} { return "$::core::cabi::namespace\::Double" }
proc hir::cabi::PtrName {} { return "$::core::cabi::namespace\::Ptr" }
proc hir::cabi::FnPtrName {} { return "$::core::cabi::namespace\::FnPtr" }

# ---------------------------------------------------------------------------
# Pointers

# The message for std::ffi::c::Void written where a type of values is needed.
proc hir::cabi::VoidMessage {} {
    return "[VoidName] is C's void: an incomplete type with no values, written only as a pointee ([PtrName]\[[VoidName]\], C's void *); a C function returning void returns unit"
}

# The resolved type of std::ffi::c::Ptr[ARG] (ARG a surface::parser::TypeExpr) in
# the code of namespace NS; IMPRINTS as hir::resolve::ResolveTypeExpr's (an
# imprint variable may be the pointee). Raises a TYPE error for an invalid
# pointee (PointeeProblem).
proc hir::cabi::ResolvePtr {arg ns {imprints 0}} {
    if {$arg eq [VoidName]} {
        return [list cptr void]
    }
    set pointee [hir::resolve::ResolveTypeExpr $arg $ns $imprints]
    set problem [PointeeProblem $pointee]
    if {$problem ne ""} {
        return -code error -errorcode {BOTLISH TYPE} \
            "invalid pointee in [PtrName]\[[hir::resolve::ShowTypeExpr $arg]\]: $problem"
    }
    return [list cptr $pointee]
}

# The resolved type of std::ffi::c::FnPtr[ARG]: ARG must be a structural function
# type Fn{args: [...], return: R} whose arguments are C ABI value types and
# whose result is one or unit, declaring no errors (C reports none).
proc hir::cabi::ResolveFnPtr {arg ns {imprints 0}} {
    set spelled "[FnPtrName]\[[hir::resolve::ShowTypeExpr $arg]\]"
    if {[llength $arg] != 2 || [lindex $arg 0] ne "fn"
            || ([dict exists [lindex $arg 1] kind] && [dict get [lindex $arg 1] kind] eq "coroutine")} {
        return -code error -errorcode {BOTLISH TYPE} \
            "invalid signature in $spelled: a C function pointer's argument is its signature, Fn{args: \[...\], return: R}"
    }
    set fn [hir::resolve::ResolveTypeExpr $arg $ns $imprints]
    set problem [SignatureProblem $fn]
    if {$problem ne ""} {
        return -code error -errorcode {BOTLISH TYPE} "invalid signature in $spelled: $problem"
    }
    return [list cfnptr $fn]
}

# Why the canonical function type FN is not a C signature, or "".
proc hir::cabi::SignatureProblem {fn} {
    if {![hir::types::IsFn $fn]} {
        return "[hir::types::show $fn] is not a function signature"
    }
    if {[hir::types::FnErrors $fn] ne ""} {
        return "a C function declares no Botlish errors (errors: \[[join [hir::types::FnErrors $fn] {, }]\])"
    }
    set i 0
    foreach t [hir::types::FnArgs $fn] {
        incr i
        set problem [ValueTypeProblem $t]
        if {$problem ne ""} {
            return "argument $i: $problem"
        }
    }
    set result [hir::types::FnReturn $fn]
    if {$result ne "unit"} {
        set problem [ValueTypeProblem $result]
        if {$problem ne ""} {
            return "result: $problem (a void result is unit)"
        }
    }
    return ""
}

# 1 if TYPE is a C ABI value type: a C integer scalar, C _Bool (bool), C
# double (Float64), a C data or function pointer, or an imprint variable
# (bound at each call).
proc hir::cabi::IsValueType {type} {
    return [expr {[core::type::cabiScalar $type] ne "" || $type in {bool Float64} || [hir::types::IsCPtr $type]
        || [hir::types::IsCFnPtr $type] || [hir::types::IsImprint $type]}]
}

# Why TYPE is not a C ABI value type, or "".
proc hir::cabi::ValueTypeProblem {type} {
    if {[IsValueType $type]} {
        return ""
    }
    return "[hir::types::show $type] is not a C ABI value type (a C integer scalar such as [hir::cabi::ScalarExample], [BoolName], [DoubleName], [PtrName]\[...\] or [FnPtrName]\[...\])"
}

proc hir::cabi::ScalarExample {} {
    return "$::core::cabi::namespace\::Int"
}

# Why the resolved type POINTEE cannot be a C pointer's pointee identity, or
# "" if it can (this file's header, "Pointee identities").
proc hir::cabi::PointeeProblem {pointee} {
    if {$pointee eq "void" || $pointee eq "bool" || [hir::types::IsCPtr $pointee] || [hir::types::IsCFnPtr $pointee]
            || [hir::types::IsImprint $pointee] || [core::type::cabiScalar $pointee] ne ""} {
        return ""
    }
    set shown [hir::types::show $pointee]
    if {[hir::types::IsNamedStruct $pointee]} {
        set id [lindex $pointee 1]
        if {[string match {LayoutStruct\[*\]} $id]} {
            return "$shown is a Botlish struct value imprinted from bytes, not a pointee identity: a C struct's pointee identity is an opaque struct, and its layout a separate declaration (C-ABI-TYPES.md, \"Layouts and pointees\")"
        }
        if {[hir::structs::isOpaque $id]} {
            return ""
        }
        return "$shown is an ordinary struct, whose fields are a Botlish representation, not a C one: a C tag's identity is an opaque struct (`opaque struct Name:`), whose representation no other module sees"
    }
    if {[lindex $pointee 0] eq "refined" && [lindex $pointee 1] eq "int"} {
        return "$shown is an integer domain, not a C integer type: a C pointee scalar is one of namespace $::core::cabi::namespace's (e.g. [ScalarExample])"
    }
    return "$shown has no C representation: a pointee is [VoidName], a C integer scalar, [BoolName], an opaque struct or another pointer"
}

# The display of pointee identity POINTEE (show's std::ffi::c::Ptr[...] argument).
proc hir::cabi::ShowPointee {pointee} {
    if {$pointee eq "void"} {
        return [VoidName]
    }
    return [hir::types::show $pointee]
}

# The display of a C signature FN (show's std::ffi::c::FnPtr[...] argument): the
# source spelling, without the always-empty errors.
proc hir::cabi::ShowSignature {fn} {
    if {![hir::types::IsFn $fn]} {
        return [hir::types::show $fn]
    }
    return [format {Fn{args: [%s], return: %s}} \
        [join [lmap t [hir::types::FnArgs $fn] {hir::types::show $t}] {, }] \
        [hir::types::show [hir::types::FnReturn $fn]]]
}

# The pointee identity written TEXT on line NUMBER of HIR text
# (ShowPointee's inverse).
proc hir::cabi::ParsePointee {text number} {
    if {$text eq [VoidName]} {
        return void
    }
    return [hir::read::ParseType $text $number]
}

# ---------------------------------------------------------------------------
# Verification

# Diagnoses the uses of C addresses no operation has (C-ABI-TYPES.md, "A
# pointer is not an Int"): a data or function pointer given to a native whose
# parameter requires another kind -- `p + 1`, `p < q`, `bit_and(p, 1)`,
# `std::str::length(p)` -- is TYPE at compile time, not the run-time kind error
# such a call would otherwise reach. (`==` and `hash` of one are
# AFFINE-EQUALITY-UNSUPPORTED, hir/affine.tcl: a pointer is affine.)
proc hir::cabi::verify {hirVar} {
    upvar 1 $hirVar hir
    dict for {e node} [dict get $hir exprs] {
        if {[dict get $node kind] ne "call"} {
            continue
        }
        if {[dict exists $node reachable] && ![dict get $node reachable]} {
            continue
        }
        set calleeType [hir::typeOf $hir [dict get $node callee]]
        if {[hir::types::IsCAddress $calleeType]} {
            # A C function pointer (or any C address) is no Botlish callable:
            # calling C is the next milestone (C-ABI-TYPES.md).
            set callee [dict get $hir exprs [dict get $node callee]]
            if {[dict get $callee kind] eq "ref"} {
                set name [hir::semantic::RefName $hir [dict get $node callee]]
            } else {
                set name "this value"
            }
            hir::Diagnose hir TYPE [format \
                {%s is a C %s, %s: Botlish cannot call one yet (calling C is the next milestone)} \
                $name [expr {[hir::types::IsCFnPtr $calleeType] ? "function pointer" : "pointer"}] \
                [hir::types::show $calleeType]] $e
            continue
        }
        if {[lindex [dict get $node target] 0] ne "native"} {
            continue
        }
        set name [dict get [hir::symbol $hir [lindex [dict get $node target] 1]] name]
        set paramTypes [dict get [core::native::metadata $name] paramTypes]
        if {$paramTypes eq ""} {
            continue
        }
        set index 0
        foreach arg [dict get $node args] {
            set paramType [lindex $paramTypes [expr {min($index, [llength $paramTypes] - 1)}]]
            incr index
            set argType [hir::typeOf $hir $arg]
            if {[hir::types::IsNativeMemory $argType] && $paramType ni {"" any} && [hir::layouts::Role $name] eq ""
                    && [dict get [core::native::metadata $name] imprint] eq ""} {
                # (An imprinted native's signature rejects it itself: IMPRINT.)
                # A native view's word is its pointer's, but a view is no
                # pointer and no Int (NATIVE-LAYOUT-VIEWS.md): no pointer
                # operation (null?, clone, ...) and no other native takes one.
                if {[hir::types::IsNativeEdit $argType]} {
                    # (A native edit, NATIVE-LAYOUT-WRITES.md, likewise.)
                    set what "a native edit, where %s requires %s: a native edit is a window onto native memory, read by its fields (or std::binary::load) and written by std::binary::store, never a pointer, an Int or any other value"
                } else {
                    set what "a native view, where %s requires %s: a native view is a read-only window onto native memory, read by its fields (or std::binary::load), never a pointer, an Int or any other value"
                }
                hir::Diagnose hir TYPE [format "argument %d of %s is %s, $what" \
                    $index $name [hir::types::show $argType] $name [core::type::show $paramType]] $arg
                continue
            }
            if {![hir::types::IsCAddress $argType] || $paramType in {"" any}
                    || [core::type::base $paramType] eq "cptr"} {
                continue
            }
            hir::Diagnose hir TYPE [format \
                {argument %d of %s is %s, a C pointer, where %s requires %s: a pointer is an opaque address, not an Int or any other value (it has no arithmetic, ordering, bitwise operation or conversion)} \
                $index $name [hir::types::show $argType] $name [core::type::show $paramType]] $arg
        }
    }
}

# The type a call's explicit imprint TYPEEXPR denotes in the code of
# namespace NS (hir/imprint.tcl): an ordinary type, or the pointee identity
# std::ffi::c::Void (whether a variable may be bound to it is the callee's
# signature's business, hir::imprint::BindingProblem).
#
# VARIABLES are the imprint variables of the functions the call is written
# in (hir::imprint::EnclosingVariables): an imprint may forward one.
proc hir::cabi::ResolveImprint {typeExpr ns {variables {}}} {
    if {$typeExpr eq [VoidName]} {
        return void
    }
    return [hir::resolve::ResolveTypeExpr $typeExpr $ns [if {$variables eq ""} {string cat 0} else {set variables}]]
}

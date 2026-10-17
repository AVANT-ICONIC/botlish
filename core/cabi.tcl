# cabi.tcl -- the C ABI value universe of namespace ffi::c (C-ABI-TYPES.md):
# the targets' data models, the C integer scalar categories, and the raw C
# address values with their operations.
#
# Targets and data models
# -----------------------
# A C integer type is an identity whose width and signedness are the
# target's, never the name's: `long` is 64 bits on LP64 (Linux, macOS) and
# 32 on LLP64 (Windows); plain `char` is signed on x86-64 everywhere and on
# Apple and Windows AArch64, unsigned on Linux AArch64. This table is
# Botlish's own target knowledge: ordinary compilation never asks a C
# compiler (the C header archaeology's ABI probe confirmed the Linux x86-64
# row; C-HEADER-ARCHAEOLOGY.md, items 52-55).
#
#   targets   NAME -> {os OS arch ARCH model MODEL charSigned 0|1}
#   models    MODEL -> {char BITS short BITS int BITS long BITS longlong BITS
#             pointer BITS}
#   scalars   SOURCE-NAME -> {c C-SPELLING width WIDTH-KEY signed 0|1|char}
#             (signed `char`: plain char, the target's charSigned)
#
# A scalar's resolved metadata (scalarInfo) is the plain dict {c SPELLING
# target TARGET bits N signed 0|1}: what a later C call lowering reads (width
# and signedness), carried by the type's own registry entry, never recovered
# from its name. Floating categories, _Bool, size_t and the other typedefs
# are deliberately absent (C-ABI-TYPES.md, "What is not here").
#
# Values
# ------
#   {cptr ADDRESS}   a raw C address (a data pointer or a function pointer:
#                    the two are distinct static types of this one runtime
#                    kind), ADDRESS its bits as a canonical unsigned decimal;
#                    0 is null. Opaque: no arithmetic, ordering, equality,
#                    hash or Int conversion exists for it, and the pointee
#                    identity is static only (nothing in the value names
#                    it). The Tcl backends have no machine addresses: null
#                    and the test fixture's addresses are its only sources.
#
# Operations (natives; the explicit imprints are hir/imprint.tcl's)
# ----------
#   ffi::c::null[T]()     Ptr[T]         a null pointer (imprinting T)
#   ffi::c::null?(p)      bool           whether P is null (any C address)
#   ffi::c::clone(p)      P's own type   a second alias of the same address
#   ffi::c::erase(p)      Ptr[Void]      the same bits, as void * (moves P)
#   ffi::c::retype[T](p)  Ptr[T]         the same bits of a Ptr[Void] (moves P)
#
# None of them reads memory, calls foreign code, allocates or retains
# anything: clone copies the address, never the pointee, and none of them
# changes a reference count.

namespace eval core::cabi {
    variable models [dict create \
        LP64  {char 8 short 16 int 32 long 64 longlong 64 pointer 64} \
        LLP64 {char 8 short 16 int 32 long 32 longlong 64 pointer 64}]
    variable targets [dict create \
        linux-x86_64    {os linux arch x86_64 model LP64 charSigned 1} \
        linux-aarch64   {os linux arch aarch64 model LP64 charSigned 0} \
        macos-x86_64    {os macos arch x86_64 model LP64 charSigned 1} \
        macos-aarch64   {os macos arch aarch64 model LP64 charSigned 1} \
        windows-x86_64  {os windows arch x86_64 model LLP64 charSigned 1} \
        windows-aarch64 {os windows arch aarch64 model LLP64 charSigned 1}]
    # In declaration (and HIR text) order.
    variable scalars [dict create \
        Char      {c char width char signed char} \
        SChar     {c {signed char} width char signed 1} \
        UChar     {c {unsigned char} width char signed 0} \
        Short     {c short width short signed 1} \
        UShort    {c {unsigned short} width short signed 0} \
        Int       {c int width int signed 1} \
        UInt      {c {unsigned int} width int signed 0} \
        Long      {c long width long signed 1} \
        ULong     {c {unsigned long} width long signed 0} \
        LongLong  {c {long long} width longlong signed 1} \
        ULongLong {c {unsigned long long} width longlong signed 0}]
    # The namespace whose intrinsic types these are.
    variable namespace ffi::c
}

proc core::cabi::targetNames {} {
    variable targets
    return [lsort [dict keys $targets]]
}

# The architectures of the targets (their `arch`), sorted: what an
# architecture-specific module file may be specific to (surface/modules.tcl's
# ModuleFile: lib/P.ARCH.bot).
proc core::cabi::architectures {} {
    variable targets
    return [lsort -unique [lmap name [dict keys $targets] {dict get $targets $name arch}]]
}

proc core::cabi::isTarget {name} {
    variable targets
    return [dict exists $targets $name]
}

# The target metadata of NAME, with its data model's widths merged in.
proc core::cabi::target {name} {
    variable targets
    variable models
    if {![dict exists $targets $name]} {
        error "core::cabi: unknown C ABI target \"$name\" (known: [join [targetNames] {, }])"
    }
    set meta [dict get $targets $name]
    return [dict merge $meta [dict get $models [dict get $meta model]] [dict create name $name]]
}

# The target of the machine this process runs on, or "" if it is not one of
# the table's (the caller decides what that means: importing ffi::c then
# needs an explicit -target).
proc core::cabi::hostTarget {} {
    set os [string tolower $::tcl_platform(os)]
    set machine [string tolower $::tcl_platform(machine)]
    switch -glob -- $os {
        linux { set os linux }
        darwin { set os macos }
        windows* { set os windows }
        default { return "" }
    }
    switch -- $machine {
        x86_64 - amd64 { set arch x86_64 }
        aarch64 - arm64 { set arch aarch64 }
        default { return "" }
    }
    set name $os-$arch
    return [expr {[isTarget $name] ? $name : ""}]
}

# The C integer scalar names (ffi::c::NAME), in declaration order.
proc core::cabi::scalarNames {} {
    variable scalars
    return [dict keys $scalars]
}

# The resolved metadata of scalar NAME on TARGET: {c SPELLING target TARGET
# bits N signed 0|1}.
proc core::cabi::scalarInfo {name target} {
    variable scalars
    if {![dict exists $scalars $name]} {
        error "core::cabi: unknown C integer scalar \"$name\""
    }
    set meta [dict get $scalars $name]
    set t [core::cabi::target $target]
    set bits [dict get $t [dict get $meta width]]
    set signed [dict get $meta signed]
    if {$signed eq "char"} {
        set signed [dict get $t charSigned]
    }
    return [dict create c [dict get $meta c] target $target bits $bits signed $signed]
}

# The metadata of the scalar whose C spelling is SPELLING on TARGET (HIR
# text names a scalar so), or "" if there is none.
proc core::cabi::scalarInfoOf {spelling target} {
    variable scalars
    if {![isTarget $target]} {
        return ""
    }
    dict for {name meta} $scalars {
        if {[dict get $meta c] eq $spelling} {
            return [scalarInfo $name $target]
        }
    }
    return ""
}

# The exact mathematical value domain {interval LO HI} of a scalar with
# INFO (scalarInfo): two's complement for a signed one.
proc core::cabi::scalarDomain {info} {
    set bits [dict get $info bits]
    if {[dict get $info signed]} {
        return [list interval [expr {-(2 ** ($bits - 1))}] [expr {2 ** ($bits - 1) - 1}]]
    }
    return [list interval 0 [expr {2 ** $bits - 1}]]
}

# 1 if INFO is a well-formed scalar metadata dict (as a registry entry or HIR
# text carries it): a known target, and exactly the bits and signedness that
# target gives the C spelling. A registry entry read back from text is
# re-derived, never trusted.
proc core::cabi::validScalarInfo {info} {
    variable scalars
    if {[catch {dict size $info}] || [lsort [dict keys $info]] ne {bits c signed target}} {
        return 0
    }
    if {![isTarget [dict get $info target]]} {
        return 0
    }
    dict for {name meta} $scalars {
        if {[dict get $meta c] eq [dict get $info c]} {
            return [expr {[scalarInfo $name [dict get $info target]] eq $info}]
        }
    }
    return 0
}

# ---------------------------------------------------------------------------
# Values

proc core::cabi::address {address} {
    return [list cptr $address]
}

proc core::cabi::addressOf {v} {
    core::value::expect cptr $v "C pointer"
    return [lindex $v 1]
}

# The display text of a C address value (show.rs's must be the same).
proc core::cabi::show {v} {
    return [format {<C pointer 0x%llx>} [lindex $v 1]]
}

proc core::cabi::nullImpl {} {
    return [address 0]
}

proc core::cabi::isNullImpl {p} {
    return [core::value::bool [expr {[addressOf $p] == 0}]]
}

# clone, erase and retype: the same address, unchanged (the static type is
# all that differs).
proc core::cabi::sameImpl {p} {
    addressOf $p
    return $p
}

# The test fixture's address reader (installTestFixture): the address bits of
# the C address P, an Int. Only a test process can name it.
proc core::cabi::fixtureAddressOfImpl {p} {
    return [core::value::intFromNumber [addressOf $p]]
}

# The test fixture's address constructor (installTestFixture): the C address
# whose bits are the Int N, 0 <= N < 2^59 (the range every backend
# represents; the native word keeps 60 bits).
proc core::cabi::fixtureAddressImpl {n} {
    set n [core::value::intOf $n]
    if {$n < 0 || $n >= 2 ** 59} {
        core::semanticError RANGE "C pointer test fixture: address $n is outside 0..2^59-1"
    }
    return [address $n]
}

core::native::register ffi::c::null -arity 0 -impl core::cabi::nullImpl \
    -result-type cptr -imprint {vars {T} params {} result {cptr {imprint T}}}
core::native::register ffi::c::null? -arity 1 -impl core::cabi::isNullImpl \
    -param-types {cptr} -result-type bool -ownership {observe}
core::native::register ffi::c::clone -arity 1 -impl core::cabi::sameImpl \
    -param-types {cptr} -result-type cptr -result-shape {same 0} -ownership {observe}
core::native::register ffi::c::erase -arity 1 -impl core::cabi::sameImpl \
    -param-types {cptr} -result-type cptr -ownership {move} \
    -imprint {vars {T} params {{cptr {imprint T}}} result {cptr void}}
core::native::register ffi::c::retype -arity 1 -impl core::cabi::sameImpl \
    -param-types {cptr} -result-type cptr -ownership {move} \
    -imprint {vars {T} params {{cptr void}} result {cptr {imprint T}}}

# The private C pointer test fixture (C-ABI-TYPES.md, "Testing"). This
# milestone has no source of a non-null pointer: no C call, no exported
# function. Tests that must see one call this from Tcl, in their own process,
# before compiling; it registers the namespace `ffi_fixture` with
#
#   ffi_fixture::address[T](n)          Ptr[T], the address N
#   ffi_fixture::function_address[F](n) FnPtr[F], the address N
#   ffi_fixture::address_of(p)          the address bits of any C pointer P,
#                                       an Int (observes P)
#
# Nothing in the compiler, the libraries or main.tcl calls it, so no Botlish
# program outside a test process can name any of them: there is no public
# conversion between Ints and pointers. The native backend lowers them to the
# fixture-only NIR ops `cptrfixture` and `cptrfixtureaddress`
# (native/lower.tcl), which no other native lowers to.
proc core::cabi::installTestFixture {} {
    if {[core::native::isQualifiedNative ffi_fixture::address]} {
        return
    }
    core::native::register ffi_fixture::address -arity 1 -impl core::cabi::fixtureAddressImpl \
        -param-types {int} -result-type cptr -errors {} \
        -imprint {vars {T} params {int} result {cptr {imprint T}}}
    core::native::register ffi_fixture::function_address -arity 1 -impl core::cabi::fixtureAddressImpl \
        -param-types {int} -result-type cptr -errors {} \
        -imprint {vars {F} params {int} result {cfnptr {imprint F}}}
    core::native::register ffi_fixture::address_of -arity 1 -impl core::cabi::fixtureAddressOfImpl \
        -param-types {cptr} -result-type int -ownership {observe}
}

# ---------------------------------------------------------------------------
# Foreign call contracts and temporary byte exposure (C-POINTER-BORROWING.md)
#
# A foreign call contract (core/native.tcl's -foreign; a future `extern c
# fn` declaration carries the same facts) is a C signature with two facts
# per pointer parameter:
#
#   access   read | write | unknown
#            what C may do through the pointer during the call: read only
#            (C const), or read and modify; unknown when the binding says
#            nothing
#   escape   proven-noescape | declared-noescape | captures | unknown
#            whether C may retain pointer provenance after the call
#            returns: never (proven by a tool, or declared by the binding's
#            author -- the same fact, two kinds of evidence), it may
#            (stores it, hands it to another thread, returns it), or
#            nobody said (treated exactly like captures)
#
# The two are independent: a `const char *` (read) may still be stored, and
# a writable pointer may be perfectly safe to expose for one synchronous
# call. Nothing here or anywhere reads either fact from a C type, a `const`,
# a parameter name or a function name: the contract says it, or it is
# unknown.
#
# Temporary byte exposure. A pointer parameter whose contract is noescape
# and whose access is known, and whose pointee is a byte-sized C type (Char,
# SChar, UChar) or Void, admits existing Botlish byte storage for the one
# call (hir/borrow.tcl decides it statically, and records the transport on
# the call):
#
#   abi::bytes::Bytes          read access only: C sees the bytes, which it
#                              may not modify (an immutable value is never
#                              written, whatever its physical storage is)
#   abi::bytes::MutableBytes   read access: its current bytes, as they are
#                              (no copy); write access: a private copy of
#                              them (the detach linux::read takes), which C
#                              may read and modify, and which comes back as
#                              the call's updated value of that parameter
#                              (the call's result is then {result: R,
#                              NAME: abi::bytes::MutableBytes, ...})
#
# No pointer value exists for an exposure: nothing makes a ffi::c::Ptr of
# Botlish storage, and the address lives only as the call's argument. It
# ends when the call returns.
#
# On the Tcl backends there are no machine addresses: ForeignBoundary, the
# entry of every -foreign native's implementation, models an exposure as
# {exposure ID}, a handle into the call's own table of exposed bytes that the
# implementation reads (ExposedBytes) and, for a write exposure, writes
# (StoreExposed) -- and that is closed when the call returns, so a handle
# kept past the call can no longer reach anything. The native backend
# passes the storage's payload address (native/lower.tcl's BorrowCall).

namespace eval core::cabi {
    variable accesses {read write unknown}
    variable escapes {proven-noescape declared-noescape captures unknown}
    # The exposures of the calls in progress: ID -> {access A hex HEX}.
    variable exposures [dict create]
    variable exposureCounter 0
}

proc core::cabi::accesses {} {
    variable accesses
    return $accesses
}

proc core::cabi::escapes {} {
    variable escapes
    return $escapes
}

# 1 if ESCAPE says the pointer does not outlive the call (either evidence).
proc core::cabi::isNoescape {escape} {
    return [expr {$escape in {proven-noescape declared-noescape}}]
}

# The normalized foreign call contract CONTRACT of native NAME of ARITY
# (core/native.tcl's -foreign), or a Tcl error: {vars V params {P...} result
# R}, every P {name N type T} for a C value and {name N type T access A
# escape E} for a C pointer (a type {cptr ...} or {cfnptr ...}), an absent
# fact being `unknown`. Only a data pointer has an access; a write
# parameter's name is a field of the call's result, so it is never
# `result`.
proc core::cabi::NormalizeForeign {name contract arity} {
    variable accesses
    variable escapes
    if {[catch {dict size $contract}] || [lsort [dict keys $contract]] ni {{params result} {params result vars}}} {
        error "core::native::register: bad -foreign \"$contract\" for \"$name\" (expected {vars {...} params {...} result R})"
    }
    set vars [expr {[dict exists $contract vars] ? [dict get $contract vars] : {}}]
    set params [dict get $contract params]
    if {$arity eq "*" || [llength $params] != $arity} {
        error "core::native::register: -foreign of \"$name\" must describe its $arity parameter(s)"
    }
    set names {}
    set normalized {}
    foreach param $params {
        if {[catch {dict size $param}] || ![dict exists $param name] || ![dict exists $param type]} {
            error "core::native::register: bad -foreign parameter \"$param\" of \"$name\" (expected {name N type T ...})"
        }
        set pname [dict get $param name]
        set type [CanonicalTerm [dict get $param type]]
        if {![regexp {^[a-z_][a-z0-9_]*$} $pname] || $pname in $names} {
            error "core::native::register: -foreign parameter name \"$pname\" of \"$name\" is not a fresh lower-case name"
        }
        lappend names $pname
        set pointer [expr {[lindex $type 0] in {cptr cfnptr} && [llength $type] == 2}]
        foreach key [dict keys $param] {
            if {$key ni {name type access escape} || ($key in {access escape} && !$pointer)
                    || ($key eq "access" && [lindex $type 0] ne "cptr")} {
                error "core::native::register: -foreign parameter \"$pname\" of \"$name\" cannot have \"$key\" (access is a data pointer's fact, escape any pointer's)"
            }
        }
        set entry [dict create name $pname type $type]
        if {$pointer} {
            set access [expr {[dict exists $param access] ? [dict get $param access] : "unknown"}]
            set escape [expr {[dict exists $param escape] ? [dict get $param escape] : "unknown"}]
            if {$access ni $accesses || $escape ni $escapes} {
                error "core::native::register: -foreign parameter \"$pname\" of \"$name\": access must be one of $accesses and escape one of $escapes"
            }
            if {$access eq "write" && $pname eq "result"} {
                error "core::native::register: -foreign write parameter of \"$name\" cannot be named \"result\": its updated bytes are the call result's field of its name, beside `result`"
            }
            dict set entry access $access
            dict set entry escape $escape
        }
        lappend normalized $entry
    }
    return [dict create vars $vars params $normalized result [CanonicalTerm [dict get $contract result]]]
}

# The HIR type term TYPE in its canonical text (a list rebuilt at every
# level: {refined int {ffi::c::UChar}} is `refined int ffi::c::UChar`), the
# form types are compared in.
proc core::cabi::CanonicalTerm {type} {
    if {[llength $type] <= 1} {
        return [lindex $type 0]
    }
    return [lmap element $type {CanonicalTerm $element}]
}

# The pointer parameters of CONTRACT that may retain pointer authority past
# the call (escape captures or unknown), as {INDEX NAME ESCAPE}: the reasons
# a raw call of it is capability-escaping (the future `direct`, C-POINTER-
# BORROWING.md "direct"). A function pointer counts as any pointer does: a
# stored callback is retained authority.
proc core::cabi::RetainingParameters {contract} {
    set reasons {}
    set index 0
    foreach param [dict get $contract params] {
        if {[dict exists $param escape] && ![isNoescape [dict get $param escape]]} {
            lappend reasons [list $index [dict get $param name] [dict get $param escape]]
        }
        incr index
    }
    return $reasons
}

# The byte storage kind ("bytestore" or "mutbytes") a run-time value V owns
# when it is an abi::bytes::Bytes or abi::bytes::MutableBytes, else "".
proc core::cabi::OwnerKind {v} {
    if {[core::value::kind $v] ne "struct"} {
        return ""
    }
    set id [core::value::structId $v]
    if {$id eq [core::bytestore::bytesType] || $id eq [core::bytestore::mutableBytesType]} {
        set storage [core::value::structGet $v [core::bytestore::storageField]]
        return [core::value::kind $storage]
    }
    return ""
}

# The entry of the implementation IMPL of every -foreign native NAME on the
# Tcl backends (core/native.tcl wraps it): each argument that is byte
# storage at a pointer parameter is exposed for the call, as {exposure ID},
# and every exposure is closed when the call ends, normally or not. A write
# exposure's bytes after a normal return become the updated MutableBytes of
# its parameter, and the call's value {result: R, NAME: ...}. A failing call
# (a declared error, propagated) publishes nothing: the private copy C wrote
# is discarded, and the caller's own value never changed.
#
# What a static check proved is rechecked here only where a run-time value
# can show it (an unchecked, -strict 0 program): a byte owner at a parameter
# that may retain the pointer, whose access is unknown, or an immutable
# Bytes given write access, is refused (TYPE) before IMPL runs.
proc core::cabi::ForeignBoundary {name impl args} {
    variable exposures
    variable exposureCounter
    set contract [dict get [core::native::metadata $name] foreign]
    set callArgs {}
    set opened {}
    set writes {}
    foreach arg $args param [dict get $contract params] {
        set kind [expr {[dict exists $param access] ? [OwnerKind $arg] : ""}]
        if {$kind eq ""} {
            lappend callArgs $arg
            continue
        }
        set access [dict get $param access]
        set escape [dict get $param escape]
        if {![isNoescape $escape] || $access eq "unknown" || ($kind eq "bytestore" && $access eq "write")} {
            foreach id $opened {
                dict unset exposures $id
            }
            core::semanticError TYPE \
                "$name: byte storage cannot be exposed to parameter \"[dict get $param name]\" (access $access, escape $escape): only a noescape parameter of known access admits it, and an immutable Bytes only for reading"
        }
        set storage [core::value::structGet $arg [core::bytestore::storageField]]
        if {$kind eq "bytestore"} {
            set hex [core::value::bytestoreHex $storage]
        } else {
            set hex [core::value::mutbytesHex $storage]
        }
        set id [incr exposureCounter]
        dict set exposures $id [dict create access $access hex $hex]
        lappend opened $id
        if {$access eq "write"} {
            lappend writes [dict get $param name] $id
        }
        lappend callArgs [list exposure $id]
    }
    try {
        set result [{*}$impl {*}$callArgs]
        if {$writes eq ""} {
            return $result
        }
        set fields [dict create result $result]
        foreach {pname id} $writes {
            dict set fields $pname [core::value::structOf \
                [list [core::bytestore::mutableBytesType] [core::bytestore::storageField]] \
                [list [core::value::mutbytes [dict get $exposures $id hex]]]]
        }
        set names [lsort [dict keys $fields]]
        return [core::value::structOf [list {} {*}$names] [lmap n $names {dict get $fields $n}]]
    } finally {
        foreach id $opened {
            dict unset exposures $id
        }
    }
}

# The exposure ID of pointer argument P ({exposure ID}), or "" for a raw C
# address ({cptr ADDRESS}). CONTEXT names the operation for errors. An
# exposure that has ended (its call returned) is gone: using one is an
# internal error, never a read of stale bytes.
proc core::cabi::ExposureOf {p context} {
    variable exposures
    if {[lindex $p 0] eq "exposure" && [llength $p] == 2} {
        set id [lindex $p 1]
        if {![dict exists $exposures $id]} {
            error "$context: exposure $id has ended: an exposure lives only for the call it was made for"
        }
        return $id
    }
    addressOf $p
    return ""
}

# The COUNT bytes (a list of Ints) at OFFSET of pointer argument P, a read
# through the exposure. A raw C address on the Tcl backends reaches no
# memory: only a zero-byte access is possible.
proc core::cabi::ExposedBytes {p offset count context} {
    variable exposures
    set id [ExposureOf $p $context]
    if {$id eq ""} {
        if {$count != 0} {
            core::semanticError NATIVE-ONLY \
                "$context reads $count byte(s) through a raw C address, which only the native backend can do: the Tcl backends have no machine memory"
        }
        return {}
    }
    set hex [dict get $exposures $id hex]
    if {$offset < 0 || $offset + $count > [string length $hex] / 2} {
        error "$context: a read of $count byte(s) at $offset is outside the [expr {[string length $hex] / 2}] exposed bytes (a C operation's contract keeps it inside what its caller passes)"
    }
    if {$count == 0} {
        return {}
    }
    binary scan [binary decode hex [string range $hex [expr {2 * $offset}] [expr {2 * ($offset + $count) - 1}]]] cu* bytes
    return $bytes
}

# Writes BYTES (Ints in 0..255) at OFFSET through pointer argument P, a write
# exposure. A read exposure is never written: that would be C writing
# through a const pointer, which the contract rules out (an internal error
# here, where it can be seen; natively it would be undefined).
proc core::cabi::StoreExposed {p offset bytes context} {
    variable exposures
    set id [ExposureOf $p $context]
    if {$id eq ""} {
        if {[llength $bytes] != 0} {
            core::semanticError NATIVE-ONLY \
                "$context writes [llength $bytes] byte(s) through a raw C address, which only the native backend can do: the Tcl backends have no machine memory"
        }
        return
    }
    if {[dict get $exposures $id access] ne "write"} {
        error "$context: a write through read exposure $id: C may not modify what it was given to read"
    }
    set hex [dict get $exposures $id hex]
    set count [llength $bytes]
    if {$offset < 0 || $offset + $count > [string length $hex] / 2} {
        error "$context: a write of $count byte(s) at $offset is outside the [expr {[string length $hex] / 2}] exposed bytes"
    }
    if {$count == 0} {
        return
    }
    set new [binary encode hex [binary format cu* $bytes]]
    dict set exposures $id hex [string replace $hex [expr {2 * $offset}] [expr {2 * ($offset + $count) - 1}] $new]
}

# The replay of a byte exposure the static check refused, for an unchecked
# (-strict 0) program on the interpreter (hir/lower.tcl lowers such a call to
# a call of it, after the arguments; the Tcl compiler and native lowering
# emit the same error themselves): a run-time TYPE error with the
# refusal's message. Internal: `#` is no name source can spell.
proc core::cabi::refusedNative {} { return foreign#refused }

proc core::cabi::RefusedImpl {message args} {
    core::semanticError TYPE [core::value::strOf $message]
}

core::native::register [core::cabi::refusedNative] -arity * -impl core::cabi::RefusedImpl \
    -result-type any -result-shape never

# ---------------------------------------------------------------------------
# The private borrow test fixture (C-POINTER-BORROWING.md, "The fixture").
# There is no C call yet: tests that must see a foreign operation use these
# synthetic, synchronous ones, which read and write the bytes they are given
# through the pointer -- natively through the real payload address
# (native/src/runtime/ops.rs's rt_ffi_fixture_*), on the Tcl backends through
# the exposure. installBorrowFixture registers them in the calling (test)
# process only, like installTestFixture: nothing in the compiler, the
# libraries or main.tcl calls it, so no program outside a test can name
# them. Their contracts cover every access x escape combination a borrow
# decision reads:
#
#   read[T](data, count) -> List[int]           the COUNT bytes at DATA
#   read_reentrant[T](data, count) -> List[int] the same, after letting
#                                               Botlish collect and allocate
#                                               (a foreign operation that
#                                               runs Botlish code mid-call)
#   fill[T](out, count, seed) -> unit           writes byte i = (SEED + 37 i)
#                                               mod 256, i < COUNT
#   fill_checked(out, count, limit) -> unit errors UpperOverrun
#                                               writes min(COUNT, LIMIT)
#                                               bytes (91 + 37 i) mod 256,
#                                               then fails if COUNT > LIMIT
#   copy(dst, src, count) -> unit               DST[i] = SRC[i], i < COUNT
#   mixed(input, state, output, count) -> ULong OUTPUT[i] = INPUT[COUNT-1-i];
#                                               the sum of INPUT's bytes;
#                                               STATE is a userdata pointer
#                                               it may retain (it touches
#                                               nothing through it)
#
# with read_proven, read_retained (captures), read_unknown (escape unknown),
# read_unspecified (no facts) and read_unknown_access (noescape, access
# unknown) beside read, and fill_proven, fill_retained and fill_unknown
# beside fill.

namespace eval core::cabi {
    # NAME -> {BEHAVIOR VARS PARAMS RESULT ERRORS}; parameter facts as in a
    # -foreign contract. T is the pointee where a variable names it.
    variable borrowFixture {}
}

proc core::cabi::BorrowFixtureTable {} {
    set uchar {refined int {ffi::c::UChar}}
    set ulong {refined int {ffi::c::ULong}}
    set count [list name count type $ulong]
    set table {}
    foreach {suffix facts} {
        "" {access read escape declared-noescape}
        _proven {access read escape proven-noescape}
        _reentrant {access read escape declared-noescape}
        _retained {access read escape captures}
        _unknown {access read escape unknown}
        _unspecified {}
        _unknown_access {escape declared-noescape}
    } {
        set behavior [expr {$suffix eq "_reentrant" ? "read-reentrant" : "read"}]
        lappend table read$suffix [list $behavior {T} \
            [list [dict merge [list name data type {cptr {imprint T}}] $facts] $count] {list int} {}]
    }
    foreach {suffix escape} {"" declared-noescape _proven proven-noescape _retained captures _unknown unknown} {
        lappend table fill$suffix [list fill {T} \
            [list [list name out type {cptr {imprint T}} access write escape $escape] $count \
                [list name seed type $uchar]] unit {}]
    }
    lappend table fill_checked [list fill-checked {} \
        [list [list name out type [list cptr $uchar] access write escape declared-noescape] $count \
            [list name limit type $ulong]] unit {UpperOverrun}]
    lappend table copy [list copy {} \
        [list [list name dst type [list cptr $uchar] access write escape declared-noescape] \
            [list name src type [list cptr $uchar] access read escape declared-noescape] $count] unit {}]
    lappend table mixed [list mixed {} \
        [list [list name input type [list cptr $uchar] access read escape declared-noescape] \
            [list name state type {cptr void} escape captures] \
            [list name output type [list cptr $uchar] access write escape declared-noescape] $count] $ulong {}]
    return $table
}

# The fixture natives' names (ffi_fixture::NAME) and behaviors, in
# registration order: what native/lower.tcl maps to its fixture ops.
proc core::cabi::borrowFixture {} {
    set result {}
    foreach {name entry} [BorrowFixtureTable] {
        lappend result ffi_fixture::$name [lindex $entry 0]
    }
    return $result
}

proc core::cabi::installBorrowFixture {} {
    if {[core::native::isQualifiedNative ffi_fixture::read]} {
        return
    }
    foreach {name entry} [BorrowFixtureTable] {
        lassign $entry behavior vars params result errors
        set kinds [lmap p $params {expr {[lindex [dict get $p type] 0] in {cptr cfnptr} ? "any" : "int"}}]
        core::native::register ffi_fixture::$name -arity [llength $params] \
            -impl [list core::cabi::FixtureImpl $behavior ffi_fixture::$name] \
            -param-types $kinds -result-type any -errors $errors \
            -ownership [lrepeat [llength $params] observe] \
            -foreign [dict create vars $vars params $params result $result]
    }
}

# The Tcl model of fixture BEHAVIOR (core::cabi::BorrowFixtureTable), given
# the arguments as ForeignBoundary passes them (an exposure or a raw address
# for a pointer, an Int otherwise).
proc core::cabi::FixtureImpl {behavior name args} {
    set ints [lmap a $args {expr {[lindex $a 0] eq "int" ? [core::value::intOf $a] : ""}}]
    switch -- $behavior {
        read - read-reentrant {
            set bytes [ExposedBytes [lindex $args 0] 0 [lindex $ints 1] $name]
            return [core::value::listOf [lmap b $bytes {core::value::intFromNumber $b}]]
        }
        fill {
            lassign $ints - count seed
            set bytes {}
            for {set i 0} {$i < $count} {set i [expr {$i + 1}]} {
                lappend bytes [expr {($seed + 37 * $i) % 256}]
            }
            StoreExposed [lindex $args 0] 0 $bytes $name
            return [core::value::unit]
        }
        fill-checked {
            lassign $ints - count limit
            set n [expr {min($count, $limit)}]
            set bytes {}
            for {set i 0} {$i < $n} {set i [expr {$i + 1}]} {
                lappend bytes [expr {(91 + 37 * $i) % 256}]
            }
            StoreExposed [lindex $args 0] 0 $bytes $name
            if {$count > $limit} {
                core::native::failDeclared UpperOverrun "$name: $count byte(s) asked, $limit allowed"
            }
            return [core::value::unit]
        }
        copy {
            set count [lindex $ints 2]
            StoreExposed [lindex $args 0] 0 [ExposedBytes [lindex $args 1] 0 $count $name] $name
            return [core::value::unit]
        }
        mixed {
            set count [lindex $ints 3]
            ExposureOf [lindex $args 1] $name
            set input [ExposedBytes [lindex $args 0] 0 $count $name]
            StoreExposed [lindex $args 2] 0 [lreverse $input] $name
            return [core::value::intFromNumber [tcl::mathop::+ 0 {*}$input]]
        }
    }
    error "core::cabi::FixtureImpl: unknown behavior $behavior"
}

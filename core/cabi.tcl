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

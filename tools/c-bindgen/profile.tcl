# profile.tcl -- binding profiles (C-BINDGEN.md, "Profiles").
#
# A profile is a development-time description of one C library's binding:
# where its headers come from and how they are preprocessed (a header
# profile in the archaeology's format, C-HEADER-ARCHAEOLOGY.md "Profiles"),
# which Botlish targets it is generated for, the native linker's library
# names, the explicit API selection policy, the binding author's foreign
# contracts, the signatures of macro APIs that are to be thunked, and
# whether compiler evidence is gathered. tools/c-bindgen/profiles/NAME.tcl
# evaluates to the profile's dict; nothing here is read by the compiler.
#
#   name         the profile's name, also the binding's root namespace
#   description  one line
#   headers      the header profile: library, source ({url URL tag TAG
#                commit COMMIT}, or {local DIR} relative to the repository),
#                includeDirs, defines, undefines, flags, public, bundled,
#                entry; optional targetDefines {TARGET-GLOB {DEFINE ...}}
#   targets      the Botlish targets (core/cabi.tcl's names) it supports
#   modules      {stripPrefix PREFIX}: a header's module is its file stem
#                without PREFIX, lowercased
#   libraries    rules {headers GLOBS targets GLOBS names {LIB ...}}: each
#                module declares the names of every rule matching its
#                header and the target, in rule order (the linker's -lNAME)
#   exclude      explicit deny patterns (string match) of API names
#   contracts    {FUNCTION {PARAM FACTS ... result FACTS}}: the binding
#                author's foreign contracts (C-FFI.md, "Contracts")
#   groups       {{functions {F ...} facts {PARAM FACTS ...}} ...}: one
#                contract stated for an explicit list of functions
#   thunks       {NAME {C PROTOTYPE}}: the signature of a function-like
#                macro API the binding thunks (a macro has none)
#   stubs        thunk | unsupported: what a table-redirected API name
#                becomes (default thunk)
#   evidence     none | llvm: whether clang's optimized IR of the shim is
#                read for nocapture/readonly/writeonly/returned facts
#   output       where the generated bindings are committed, relative to
#                the repository: OUTPUT/TARGET/ (default generated/c/NAME)

namespace eval ::cbind::profile {
    variable dir [file join [file dirname [file normalize [info script]]] profiles]
    variable keys {name description headers targets modules libraries exclude contracts
        groups thunks stubs evidence output}
    variable headerKeys {library source includeDirs defines undefines flags public bundled
        internal entry description targetDefines}
}

# The names of the profiles (profiles/*.tcl), sorted.
proc ::cbind::profile::names {} {
    variable dir
    return [lsort [lmap p [glob -nocomplain -directory $dir *.tcl] {file rootname [file tail $p]}]]
}

# The validated profile NAME (or the profile file PATH when NAME names one).
proc ::cbind::profile::load {name} {
    variable dir
    set path [expr {[file exists $name] && [file isfile $name] ? $name : [file join $dir $name.tcl]}]
    if {![file exists $path]} {
        error "c-bindgen: no profile \"$name\" (known: [join [names] {, }])"
    }
    set profile [apply [list {} [list source $path]]]
    dict set profile path [file normalize $path]
    return [Validate $profile]
}

proc ::cbind::profile::Validate {p} {
    variable keys
    variable headerKeys
    foreach k [dict keys $p] {
        if {$k ni $keys && $k ne "path"} {
            error "c-bindgen: profile [dict get $p path]: unknown key \"$k\" (known: [join $keys {, }])"
        }
    }
    foreach k {name headers targets} {
        if {![dict exists $p $k]} {
            error "c-bindgen: profile [dict get $p path]: no \"$k\""
        }
    }
    set defaults [dict create description "" modules {stripPrefix ""} libraries {} exclude {} \
        contracts {} groups {} thunks {} stubs thunk evidence none]
    set p [dict merge $defaults $p]
    if {![dict exists $p output]} { dict set p output generated/c/[dict get $p name] }
    if {![regexp {^[a-z][a-z0-9_]*$} [dict get $p name]]} {
        error "c-bindgen: profile name \"[dict get $p name]\" is no Botlish namespace (lowercase letters, digits, _)"
    }
    set h [dict get $p headers]
    foreach k [dict keys $h] {
        if {$k ni $headerKeys} {
            error "c-bindgen: profile [dict get $p name]: unknown header key \"$k\""
        }
    }
    set h [dict merge [dict create includeDirs {} defines {} undefines {} flags {} bundled {} \
        targetDefines {}] $h]
    foreach k {library source public entry} {
        if {![dict exists $h $k]} {
            error "c-bindgen: profile [dict get $p name]: the header profile has no \"$k\""
        }
    }
    dict set p headers $h
    foreach t [dict get $p targets] {
        if {![core::cabi::isTarget $t]} {
            error "c-bindgen: profile [dict get $p name]: unknown target \"$t\" (known: [join [core::cabi::targetNames] {, }])"
        }
    }
    if {[dict get $p stubs] ni {thunk unsupported}} {
        error "c-bindgen: profile [dict get $p name]: stubs is thunk or unsupported, not \"[dict get $p stubs]\""
    }
    if {[dict get $p evidence] ni {none llvm}} {
        error "c-bindgen: profile [dict get $p name]: evidence is none or llvm, not \"[dict get $p evidence]\""
    }
    foreach rule [dict get $p libraries] {
        foreach k [dict keys $rule] {
            if {$k ni {headers targets names}} {
                error "c-bindgen: profile [dict get $p name]: a library rule has an unknown key \"$k\""
            }
        }
        foreach n [dict get $rule names] {
            if {![regexp {^[A-Za-z0-9_][A-Za-z0-9_+.-]*$} $n]} {
                error "c-bindgen: profile [dict get $p name]: \"$n\" is no linker library name"
            }
        }
    }
    foreach group [dict get $p groups] {
        foreach k [dict keys $group] {
            if {$k ni {name functions facts}} {
                error "c-bindgen: profile [dict get $p name]: a contract group has an unknown key \"$k\""
            }
        }
    }
    return $p
}

# The header profile of P for TARGET: its defines with the target's own.
proc ::cbind::profile::headersFor {p target} {
    set h [dict get $p headers]
    set defines [dict get $h defines]
    foreach {pattern extra} [dict get $h targetDefines] {
        if {[string match $pattern $target]} { lappend defines {*}$extra }
    }
    dict set h defines $defines
    if {![dict exists $h description]} { dict set h description [dict get $p description] }
    return [dict remove $h targetDefines]
}

# The library names of a module of HEADER (a source-relative path) on
# TARGET, in rule order, each once.
proc ::cbind::profile::librariesOf {p header target} {
    set names {}
    foreach rule [dict get $p libraries] {
        set headers [expr {[dict exists $rule headers] ? [dict get $rule headers] : "*"}]
        set targets [expr {[dict exists $rule targets] ? [dict get $rule targets] : "*"}]
        set hit 0
        foreach g $headers { if {[string match $g $header]} { set hit 1 } }
        if {!$hit} continue
        set hit 0
        foreach g $targets { if {[string match $g $target]} { set hit 1 } }
        if {!$hit} continue
        foreach n [dict get $rule names] {
            if {$n ni $names} { lappend names $n }
        }
    }
    return $names
}

# The name the command line gives P: its file's stem for a profile of the
# profiles directory (the fixture's file is fixture.tcl, its name bgf), else
# its file's path relative to the repository.
proc ::cbind::profile::cliName {p} {
    variable dir
    set path [dict get $p path]
    if {[file dirname $path] eq [file normalize $dir]} {
        return [file rootname [file tail $path]]
    }
    return [::chdr::relPath $::chdr::repoDir $path]
}

# 1 if API NAME is excluded by P's explicit deny patterns.
proc ::cbind::profile::excluded {p name} {
    foreach pattern [dict get $p exclude] {
        if {[string match $pattern $name]} { return 1 }
    }
    return 0
}

# Where P's bindings for TARGET are committed.
proc ::cbind::profile::outputDir {p target} {
    return [file join $::chdr::repoDir [dict get $p output] $target]
}

# The source root of P's headers: a fetched, pinned checkout or a local
# directory of the repository.
proc ::cbind::profile::sourceRoot {p {fetch 0}} {
    set h [dict get $p headers]
    set source [dict get $h source]
    if {[dict exists $source local]} {
        return [file normalize [file join $::chdr::repoDir [dict get $source local]]]
    }
    set dir [file join [::chdr::sourcesDir] [dict get $h library]]
    if {$fetch || ![file isdirectory $dir]} {
        if {!$fetch} {
            error "c-bindgen: no [dict get $h library] sources at $dir (run tools/c-bindgen.tcl fetch [dict get $p name])"
        }
        ::chdr::fetch [dict get $h library] $source
    }
    set revision [exec git -C $dir rev-parse HEAD]
    if {$revision ne [dict get $source commit]} {
        error "c-bindgen: $dir is at $revision, the profile pins [dict get $source commit]"
    }
    # Symbolic links resolved, so that preprocessor paths match.
    return [file dirname [file normalize [file join $dir .x]]]
}

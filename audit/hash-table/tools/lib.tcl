# lib.tcl -- shared machinery of the hash-table experiment's tools
# (HASH-TABLE-EXPERIMENT.md; ../SPEC.md): private application directories,
# compilation, and runs on the four backends with an injected argv.
#
# An experiment program is an application (IMPORTS.md, "Application
# modules"): a driver from drivers/ as main.bot, an implementation from
# impl/ beside it as table.bot, a key kind's module as keys.bot, and any
# other modules the driver imports. ht::app writes one into a private
# directory (AGENTS.md: never a fixed name), optionally with text edits
# applied to the implementation (a resize-policy variant, a mutant).

namespace eval ht {
    variable here [file dirname [file normalize [info script]]]
    variable base [file dirname $here]
    variable root [file dirname [file dirname $base]]
    variable work ""
    variable units [dict create]
}

# BOTLISH_HT_ROOT names another checkout whose compiler (and native
# backend) the tools load instead of this one's, so one harness -- these
# drivers, implementations and tools -- measures a prototype tree against
# the baseline.
if {[info exists ::env(BOTLISH_HT_ROOT)] && $::env(BOTLISH_HT_ROOT) ne ""} {
    set ht::root [file normalize $::env(BOTLISH_HT_ROOT)]
}

source [file join $ht::root core core.tcl]
source [file join $ht::root compiler compiler.tcl]
source [file join $ht::root surface surface.tcl]
source [file join $ht::root native native.tcl]

proc ht::readFile {path} {
    set f [open $path r]
    fconfigure $f -encoding utf-8 -translation lf
    set text [read $f]
    close $f
    return $text
}

proc ht::writeFile {path text} {
    set f [open $path w]
    fconfigure $f -encoding utf-8 -translation lf
    puts -nonewline $f $text
    close $f
}

# The scratch directory of this process (removed by ht::cleanup).
proc ht::workDir {} {
    variable work
    if {$work eq ""} {
        set work [file tempdir botlish-hash-table]
    }
    return $work
}

proc ht::cleanup {} {
    variable work
    if {$work ne "" && [file isdirectory $work]} {
        file delete -force $work
    }
    set work ""
}

# TEXT with each {OLD NEW} edit of EDITS applied; OLD must occur exactly once.
proc ht::applyEdits {text edits what} {
    foreach {old new} $edits {
        set at [string first $old $text]
        if {$at < 0 || [string first $old $text [expr {$at + 1}]] >= 0} {
            throw {HT EDIT} "$what: edit text does not occur exactly once: [string range $old 0 60]"
        }
        set text [string replace $text $at [expr {$at + [string length $old] - 1}] $new]
    }
    return $text
}

# DRIVER's text with its untyped key-List parameters (ks, qs, ms) typed
# List[TYPE], its value-List parameter (vs) List[int] and its table
# parameters (t) table::Table: the driver a typed implementation (header
# line "# key-type: TYPE") needs, since an untyped argument never satisfies
# a typed parameter (STRICT-TYPED-PARAMETERS.md).
proc ht::typedDriver {text type} {
    set out {}
    foreach line [split $text \n] {
        if {[regexp {^(nomethod )?fn } $line]} {
            foreach {name t} [list ks "List\[$type\]" qs "List\[$type\]" ms "List\[$type\]" vs "List\[int\]" t table::Table] {
                regsub -all "(\\(|, )${name}(,|\\))" $line "\\1${name}: ${t}\\2" line
            }
        }
        lappend out $line
    }
    return [join $out \n]
}

# The source file of implementation IMPL: impl/IMPL.bot for a bare module
# name, IMPL itself for a path (one with a directory part or a .bot
# extension). A bare name is never looked up in the working directory,
# whose files and directories may share an implementation's name.
proc ht::implPath {impl} {
    variable base
    if {[string match *.bot $impl] || [file tail $impl] ne $impl} {
        return $impl
    }
    return [file join $base impl $impl.bot]
}

# A private application directory NAME: DRIVER (a drivers/ file name, as
# main.bot), IMPL (an impl/ module name, or a path, as table.bot, with EDITS
# applied: ht::implPath), KEYS (int, str or point: drivers/keys_KEYS.bot as
# keys.bot) and EXTRA (more {FILE-NAME TEXT} pairs). Returns main.bot's path.
proc ht::app {name driver impl keys {edits {}} {extra {}}} {
    variable base
    set dir [file join [workDir] $name]
    file delete -force $dir
    file mkdir $dir
    set implPath [implPath $impl]
    set driverText [readFile [file join $base drivers $driver]]
    if {[regexp -line {^# key-type: (\S+)$} [readFile $implPath] -> keyType]} {
        set driverText [typedDriver $driverText $keyType]
    }
    writeFile [file join $dir main.bot] $driverText
    writeFile [file join $dir table.bot] [applyEdits [readFile $implPath] $edits $implPath]
    writeFile [file join $dir keys.bot] [readFile [file join $base drivers keys_$keys.bot]]
    foreach {file text} $extra {
        writeFile [file join $dir $file] $text
    }
    return [file join $dir main.bot]
}

# The program-mode HIR of the application whose entry file is PATH.
proc ht::compile {path} {
    return [surface::readProgramFile $path -warnings off]
}

# ARGS (Tcl strings) as a raw argv snapshot, with argument zero.
proc ht::argvOf {args} {
    return [lmap a [linsert $args 0 ht] {encoding convertto utf-8 $a}]
}

# The value of HIR run on BACKEND with argv ARGS (a Tcl list of strings),
# rendered as core::formatValue renders a value (the backends agree on the
# rendering when they agree on the value), or "error CODE MESSAGE".
proc ht::run {hir backend argList} {
    variable units
    set argv [argvOf {*}$argList]
    try {
        core::process::withArgv $argv {
            switch -- $backend {
                interp {
                    core::useProgramRecursionLimit
                    set value [core::evalProgram [hir::lower $hir]]
                }
                compile {
                    core::useProgramRecursionLimit
                    set key [list $hir]
                    if {![dict exists $units $key]} {
                        dict set units $key [core::compiler::compileHir $hir]
                    }
                    set value [core::compiler::evalUnit [dict get $units $key]]
                }
                cranelift {
                    set value [native::evalHir $hir]
                }
                cranelift-generic {
                    set value [native::evalHir $hir -specialize 0]
                }
                default {
                    error "unknown backend $backend"
                }
            }
        }
        return [core::formatValue $value]
    } on error {message options} {
        return [list error [dict get $options -errorcode] $message]
    }
}

# Like ht::run, for many argv lists of one native program: the NIR is
# lowered once (the expensive part), then the driver runs it per argv.
# Returns the rendered values in order.
proc ht::runNativeMany {hir backend argLists} {
    set options [expr {$backend eq "cranelift-generic" ? {-specialize 0} : {}}]
    set text [native::nir $hir {*}$options]
    set out {}
    foreach argList $argLists {
        try {
            core::process::withArgv [argvOf {*}$argList] {
                set value [native::Outcome [native::RunDriver discard run $text {}]]
            }
            lappend out [core::formatValue $value]
        } on error {message options} {
            lappend out [list error [dict get $options -errorcode] $message]
        }
    }
    return $out
}

# A native benchmark: the NIR of HIR lowered once (OPTIONS are native
# lowering's), then for each argv list in ARGLISTS one `bench` run of RUNS
# repetitions in one process. Returns a list of {BEST-US VALUE} pairs.
proc ht::benchNative {hir argLists runs {options {}}} {
    set text [native::nir $hir {*}$options]
    set out {}
    foreach argList $argLists {
        core::process::withArgv [argvOf {*}$argList] {
            set lines [native::Driver bench $text $runs]
        }
        set value [native::Outcome $lines]
        set times [lsearch -inline $lines {times *}]
        set best ""
        foreach n [lrange $times 1 end] {
            if {$best eq "" || $n < $best} { set best $n }
        }
        lappend out [list [expr {$best / 1000.0}] [core::formatValue $value]]
    }
    return $out
}

# The allocation report (summary) of one native run of HIR with ARGLIST.
proc ht::allocNative {hir argList {options {}}} {
    core::process::withArgv [argvOf {*}$argList] {
        set report [native::allocationReport $hir summary 1 {*}$options]
    }
    return $report
}

# python3 -I tools/model.py ARGS..., its standard output.
proc ht::model {args} {
    variable here
    return [exec python3 -I [file join $here model.py] {*}$args]
}

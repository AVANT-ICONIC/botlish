# probe-typing.tcl -- the typing/runtime probes the MutableArray
# construction/refinement milestone was developed against: static types of
# from_list / mutarray? programs and their outcome on every backend. Runs
# against the tree it is started in (pwd is the root).
#
#   tclsh9.0 audit/mutarray-construction/tools/probe-typing.tcl
set root [pwd]
source $root/compiler/compiler.tcl
source $root/surface/surface.tcl
source $root/native/native.tcl
interp recursionlimit {} 20000
proc compile {src} {
    set f [file join [file tempdir] probe-typing.bot]
    set c [open $f w]; puts $c "[surface::modules::ImportHeader $src]$src"; close $c
    try { return [surface::readProgramFile $f -strict 1] } finally { file delete $f }
}
proc last {src} {
    set hir [compile $src]
    set e [lindex [hir::roots $hir] end]
    hir::types::show [hir::typeOf $hir $e]
}
proc block {hir name} {
    dict for {b binding} [dict get $hir bindings] {
        if {[dict get $binding name] ne $name || [dict get $binding declaredBy] eq ""} continue
        set value [hir::get $hir [dict get $binding declaredBy] value]
        if {[hir::kind $hir $value] eq "block"} { return $value }
    }
}
proc sig {hir name} {
    set sig [hir::signatures::of $hir [block $hir $name]]
    lmap p [dict get $sig params] { format {%s: %s (%s)} [dict get $p name] [hir::types::show [hir::signatures::paramType $p]] [dict get $p source] }
}
proc fnType {src name} {
    set hir [compile $src]
    hir::types::show [hir::typeOf $hir [block $hir $name]]
}
proc run {backend src} {
    set hir [compile $src]
    if {$backend eq "compile"} {
        # The Tcl compiler compiles the HIR itself.
        return [outcomeOf {core::compiler::evalHir $hir}]
    }
    outcomeUnder $backend [hir::lower $hir]
}
proc outcomeOf {script} {
    if {[catch {uplevel 1 $script} result options]} {
        return [list error [dict get $options -errorcode] $result]
    }
    return [list value [core::value::show $result 1]]
}
proc outcomeUnder {backend exprs} {
    set saved [core::useBackend]
    core::useBackend $backend
    try {
        if {[catch {core::evalProgram $exprs} result options]} {
            return [list error [dict get $options -errorcode] $result]
        }
        return [list value [core::value::show $result 1]]
    } finally { core::useBackend $saved }
}
foreach {label src} {
 A "xs = \[1,2,3\]\nm = std::mutable_array::from_list(xs)\nn = m\nn"
 B "fn make():\n    std::mutable_array::from_list(\[1,2,3\])\nfn forward():\n    make()\nforward()"
 C "fn a():\n    std::mutable_array::from_list(\[1\])\nfn b():\n    std::mutable_array::from_list(\[2\])\nfn j(c):\n    if c:\n        a()\n    else:\n        b()\nj(true)"
 D "fn a():\n    std::mutable_array::from_list(\[1\])\nfn j(c):\n    if c:\n        a()\n    else:\n        \[\]\nj(true)"
 E "rows = \[std::mutable_array::from_list(\[1\]), std::mutable_array::from_list(\[2\])\]\nfn g(i):\n    std::list::at(rows, i)\ng(1)"
 F "import std::mutable_array\nstd::mutable_array::from_list(\[\"x\", 1, true\])"
 G "import std::mutable_array\nstd::mutable_array::from_list(123)"
 H "fn f(x):\n    std::mutable_array::from_list(x)\nf(1)"
} {
  puts "== $label"
  if {[catch {puts [last $src]} e]} { puts "REJECT: [string range $e 0 300]" }
}
puts "=========== runtime"
foreach {label src} {
 order "xs = \[10, 20, 30\]\nm = std::mutable_array::from_list(xs)\n\[std::mutable_array::capacity(m), std::mutable_array::at(m, 0), std::mutable_array::at(m, 1), std::mutable_array::at(m, 2)\]"
 mutate "fn f():\n    xs = \[1, 2, 3\]\n    m = std::mutable_array::from_list(xs)\n    std::mutable_array::set(m, 0, 99)\n    \[xs, std::mutable_array::at(m, 0)\]\nf()"
 empty "import std::mutable_array\nfn f():\n    m = std::mutable_array::from_list(\[\])\n    \[std::mutable_array::capacity(m), mutarray?(m)\]\nf()"
 hetero "fn f():\n    m = std::mutable_array::from_list(\[\"x\", 1, true\])\n    \[std::mutable_array::at(m, 0), std::mutable_array::at(m, 1), std::mutable_array::at(m, 2)\]\nf()"
 pred "\[mutarray?(std::mutable_array::allocate(1)), mutarray?(\[1\]), mutarray?(1), mutarray?(\"s\"), mutarray?(true), mutarray?(std::mutable_array::from_list(\[\]))\]"
} {
  puts "== $label"
  foreach b {interp compile cranelift-generic cranelift} {
     if {[catch {puts "$b: [run $b $src]"} e]} { puts "$b ERR: [string range $e 0 300]" }
  }
}
puts "=========== typing/inference"
proc show {label script} { puts "== $label"; if {[catch {uplevel #0 $script} r]} {puts "ERR: [string range $r 0 250]"} else {puts $r} }
show "maybe_capacity sig" {sig [compile "import std::mutable_array\nfn maybe_capacity(x):\n    if mutarray?(x):\n        std::mutable_array::capacity(x)\n    else:\n        0\nmaybe_capacity(1)"] maybe_capacity}
show "capacity sig" {sig [compile "import std::mutable_array\nfn capacity(x):\n    std::mutable_array::capacity(x)\ncapacity(std::mutable_array::allocate(1))"] capacity}
show "after-branch" {sig [compile "fn f(x):\n    if mutarray?(x):\n        0\n    std::mutable_array::capacity(x)\nf(std::mutable_array::allocate(1))"] f}
show "nested alias" {last "fn f(x):\n    if mutarray?(x):\n        y = x\n        std::mutable_array::capacity(y)\n    else:\n        0\nf(1)"}
show "mixed fnType" {fnType "fn f(x):\n    if mutarray?(x):\n        x\n    else:\n        0\nf(1)" f}
show "record ctrl" {fnType "fn mkpair():\n    \[std::mutable_array::from_list(\[1\]), 0\]\nfn first():\n    std::list::at(mkpair(), 0)\nfirst()" first}
show "record ctrl2" {last "fn mkpair():\n    \[std::mutable_array::from_list(\[1\]), 0\]\nfn first(p):\n    std::list::at(p, 0)\nfirst(mkpair())"}
show "local record" {last "p = \[std::mutable_array::from_list(\[1\]), 0\]\nstd::list::at(p, 0)"}
show "append" {last "import std::list\nimport std::mutable_array\nrows = std::list::append(\[std::mutable_array::from_list(\[1\])\], std::mutable_array::from_list(\[2\]))\nrows"}
show "pred type" {last "mutarray?"}
show "int pred type" {last "integer?"}
show "pred call" {fnType "fn p(x):\n    mutarray?(x)\np(1)" p}
show "unused pass" {last "fn apply(f, v):\n    f(v)\napply(mutarray?, 1)"}
puts "=========== callable"
show "list of preds" {last "\[integer?, list?, mutarray?\]"}
show "accept" {last "fn apply(p: Fn{args: \[any\], return: bool, errors: \[\]}, v) -> bool:\n    p(v)\napply(mutarray?, 1)"}
show "accept int" {last "fn apply(p: Fn{args: \[any\], return: bool, errors: \[\]}, v) -> bool:\n    p(v)\napply(integer?, 1)"}
show "used view" {
  set hir [compile "fn p(x):\n    mutarray?(x)\np(1)"]
  set spec [hir::specialize::analyze $hir]
  lmap id [dict get $spec used] {list [hir::specialize::label $spec $id] [hir::types::show [dict get $spec instances $id result]]}
}

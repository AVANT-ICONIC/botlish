# census.tcl -- the boilerplate census of the golden suites
# (GOLDEN-TEST-FRAMEWORK.md, "Recurring boilerplate"): counts, over
# tests/golden/*.bot, the constructs every port writes beside its code under
# test, mechanically, from the source text.
#
#   tclsh9.0 audit/golden/tools/census.tcl ?FILE.bot ...?
#
# A case is a registration call of the library (test::value, test::holds,
# test::rejects, test::rejects_at, test::rejects_any, test::case); ownhelper
# counts the calls of a suite's own registration helpers (its matchers over
# test::case, named PREFIX_rejects_..., and a registration function called
# with a test's name, register_..._test("name", ...)). A body is a function
# declaring `errors compiler::CompilerError` (toplevelbody: one declared at the
# suite's top level, outside any registration function); helpers are the
# suite's other top-level functions (its own matchers, shared code under
# test).

set root [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]]
set files $argv
if {$files eq ""} {
    set files [lsort [glob -directory [file join $root tests golden] *.bot]]
}

proc count {pattern text} {
    return [regexp -all -line -- $pattern $text]
}

set columns {
    cases       {^\s+test::(value|holds|rejects|rejects_at|rejects_any|rejects_message|rejects_containing|case)\(}
    value       {^\s+test::value\(}
    holds       {^\s+test::holds\(}
    rejects     {^\s+test::rejects\(}
    rejects_at  {^\s+test::rejects_at\(}
    rejects_any {^\s+test::rejects_any\(}
    rejects_msg {^\s+test::rejects_(message|containing)\(}
    custom      {^\s+test::case\(}
    ownhelper   {^\s+(?:[a-z]+_rejects_[a-z_]+|register_[a-z_]+)\("}
    bodies      {^\s*fn \S+\(\) errors compiler::CompilerError:}
    toplevelbody {^fn \S+\(\) errors compiler::CompilerError:}
    static      {^\s+static compile:}
    handlers    {^\s+on (?!compiler::CompilerError)\S+}
    registrars  {^fn register_\S+\(}
    toplevel    {^(struct|enum|error|type|refined type|trait|context struct|opaque struct|opaque context struct) }
    helpers     {^(nomethod )?fn (?!register_)[^(]+\((?!\) errors compiler::CompilerError:)}
}

set totals [dict create]
puts [format "%-24s %s" suite [join [lmap {c p} $columns {format %11s $c}] ""]]
foreach path $files {
    set f [open $path]
    fconfigure $f -encoding utf-8
    set text [read $f]
    close $f
    set row {}
    foreach {column pattern} $columns {
        set n [count $pattern $text]
        lappend row [format %11d $n]
        dict incr totals $column $n
    }
    dict incr totals lines [llength [split $text \n]]
    puts [format "%-24s %s" [file tail $path] [join $row ""]]
}
puts [format "%-24s %s" total [join [lmap {c p} $columns {format %11d [dict get $totals $c]}] ""]]
puts "\n[dict get $totals lines] lines in [llength $files] suites; [format %.1f [expr {[dict get $totals lines] / double(max(1, [dict get $totals cases]))}]] lines per case, declarations and comments included"

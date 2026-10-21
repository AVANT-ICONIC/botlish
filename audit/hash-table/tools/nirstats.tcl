# nirstats.tcl -- the hash-table experiment's generated-code census
# (HASH-TABLE-EXPERIMENT.md, "Generated code"; brief section 27): for each
# implementation, the specialized native lowering of drivers/bench.bot with
# that implementation, and per NIR function of the implementation (the
# functions whose names start "table::", plus nested ones they define): the
# ops that answer the brief's questions -- is the bounds path still there
# (mutarrayget/set vs their proven siblings), is mod a helper (imod), how
# many Botlish calls, which equality (ieq, streq, veq), guards, struct
# allocations, logical copies (mvshare) -- with the function's effects
# (native::roots: may_error, may_gc, safepoints) and machine-code bytes.
#
#   tclsh9.0 audit/hash-table/tools/nirstats.tcl ?-keys int|str|point? ?-functions PATTERN? IMPL...

source [file join [file dirname [file normalize [info script]]] lib.tcl]

set keys int
set pattern *
set impls {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    switch -- [lindex $argv $i] {
        -keys { set keys [lindex $argv [incr i]] }
        -functions { set pattern [lindex $argv [incr i]] }
        default { lappend impls [lindex $argv $i] }
    }
}

# Adds one to OPS's count of OP in function ID.
proc bump {opsVar id op} {
    upvar 1 $opsVar ops
    dict set ops $id $op [expr {[dict get $ops $id $op] + 1}]
}

set watched {
    mutarrayget mutarraygetproven mutarrayset mutarraysetproven mutarraycapacity mutarrayswap
    mvat mvpush mvlen listget listgetproven listlen listappend
    imod hash ieq streq veq enumeq structnew mvshare
}

try {
    foreach impl $impls {
        set hir [ht::compile [ht::app nir-$impl bench.bot $impl $keys]]
        set nir [native::nir $hir]
        lassign [native::codeSize $hir] total sizes
        set roots [native::roots $hir]
        # Effects per function from native::roots' report.
        set effects [dict create]
        set current ""
        foreach line [split $roots \n] {
            if {[regexp {^function (\d+)} $line -> id]} { set current $id }
            if {[regexp {effects: (.*)$} $line -> e]} { dict set effects $current [string trim $e] }
            if {[regexp {safepoints: (\d+)} $line -> s]} { dict set effects $current "[dict get $effects $current] safepoints=$s" }
        }
        puts "== $impl ($keys keys): $total bytes of machine code in all"
        set id ""
        set fns {}
        foreach line [split $nir \n] {
            if {[regexp {^func (\d+) "([^"]*)".*instance="([^"]*)"} $line -> id name instance]} {
                set counts [dict create]
                foreach op $watched { dict set counts $op 0 }
                dict set counts call 0
                dict set counts guard 0
                dict set fns $id [list $name $instance]
                dict set ops $id $counts
                continue
            }
            if {$id eq ""} continue
            if {[regexp {= op (\S+)} $line -> op] && [dict exists $ops $id $op]} { bump ops $id $op }
            if {[regexp {^\s+(%\d+ = )?(call|callmulti|tail|callvalue) } $line]} { bump ops $id call }
            if {[regexp {^\s+guard } $line]} { bump ops $id guard }
            if {[regexp {= structnew } $line]} { bump ops $id structnew }
        }
        dict for {id fn} $fns {
            lassign $fn name instance
            if {![string match table::* $name] && $name ni {walk fill}} continue
            if {![string match $pattern $name]} continue
            set nonzero {}
            dict for {op n} [dict get $ops $id] { if {$n} { lappend nonzero "$op=$n" } }
            set bytes [lindex $sizes $id]
            set e [expr {[dict exists $effects $id] ? [dict get $effects $id] : ""}]
            puts [format "  %-22s %-34s %5s B  %s  {%s}" $name "<$instance>" $bytes [join $nonzero " "] $e]
        }
    }
} finally {
    ht::cleanup
}

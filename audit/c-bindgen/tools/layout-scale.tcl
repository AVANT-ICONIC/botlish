# layout-scale.tcl -- the layout pass's scaling fixture (C-BINDGEN-LAYOUTS.md,
# "Performance"): synthetic headers of N records, generated for
# linux-x86_64 with the host's clang, each stage timed.
#
#   tclsh9.0 audit/c-bindgen/tools/layout-scale.tcl ?-shapes LIST? N ...
#
# Shapes (all of them by default):
#
#   mixed          every record holding the previous one by value, every
#                  fourth with a fixed array, every fourth an anonymous union
#                  instead: almost every record blocked, most transitively;
#   chain-blocked  one chain of N records by value whose first is blocked: the
#                  longest transitive chains there can be;
#   chain-emitted  one chain of N records by value, all emitted: N nested
#                  layouts, each one's verification naming the previous one;
#   flat           N independent records of scalars and pointers.
#
# The times must grow linearly in N (the pass is one dependency-ordered walk;
# a quadratic step shows as a ratio of about 4 between N and 2N). Scratch
# files are in a private temporary directory, removed afterwards.

source [file join [file dirname [file dirname [file dirname [file dirname [file normalize [info script]]]]]] tools c-bindgen lib.tcl]

set shapes {mixed chain-blocked chain-emitted flat}
set sizes {}
for {set i 0} {$i < [llength $argv]} {incr i} {
    set a [lindex $argv $i]
    if {$a eq "-shapes"} {
        set shapes [lindex $argv [incr i]]
    } else {
        lappend sizes $a
    }
}
if {![llength $sizes]} { set sizes {1000 2000 4000} }

proc header {shape n} {
    set h "#include <stdint.h>\n"
    for {set i 0} {$i < $n} {incr i} {
        set prev [expr {$i > 0 ? "struct s[expr {$i - 1}] prev;" : "int first;"}]
        switch -- $shape {
            mixed {
                switch -- [expr {$i % 4}] {
                    0 - 1 { append h "struct s$i { $prev uint32_t a$i; void *p$i; };\n" }
                    2 { append h "struct s$i { $prev char name$i\[8\]; struct s$i *self; };\n" }
                    3 { append h "struct s$i { int k; union { int x; long y; } u$i; };\n" }
                }
            }
            chain-blocked {
                if {$i == 0} {
                    append h "struct s0 { int first; char name\[8\]; };\n"
                } else {
                    append h "struct s$i { $prev uint32_t a$i; void *p$i; };\n"
                }
            }
            chain-emitted { append h "struct s$i { $prev uint32_t a$i; void *p$i; };\n" }
            flat { append h "struct s$i { int16_t k$i; uint64_t a$i; struct s$i *next; const char *name; };\n" }
        }
    }
    return $h
}

puts [format "%-14s %7s %8s %8s %8s %8s %8s %8s" shape records wall probe layouts verify emit emitted]
foreach shape $shapes {
    foreach n $sizes {
        set dir [file tempdir]
        file mkdir [file join $dir include sc]
        set f [open [file join $dir include sc sc.h] w]; puts $f [header $shape $n]; close $f
        set f [open [file join $dir profile] w]; puts $f "# layout-scale"; close $f
        set profile [::cbind::profile::Validate [dict create name sc path [file join $dir profile] \
            headers [dict create library sc source [list local $dir] includeDirs include \
                flags {-ffreestanding -nostdlibinc} public {include/sc/*} entry {sc/sc.h}] \
            targets {linux-x86_64} evidence none]]
        set t0 [clock milliseconds]
        set r [::cbind::generate::run $profile linux-x86_64]
        set wall [expr {([clock milliseconds] - $t0) / 1000.0}]
        set t [dict get $r timing]
        set c [::cbind::report::layoutCounts [dict get $r model]]
        puts [format "%-14s %7d %8.2f %8.2f %8.2f %8.2f %8.2f %8d" $shape $n $wall \
            [dict get $t probes] [dict get $t layouts] [dict get $t verification] [dict get $t emit] [dict get $c emitted]]
        file delete -force $dir
    }
}

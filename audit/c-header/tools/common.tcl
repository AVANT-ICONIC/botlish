# common.tcl -- shared helpers of the header experiment's tools
# (C-HEADER-ARCHAEOLOGY.md).
#
# The generally useful pieces -- the toolchain adapter, the declaration
# parser, the IR, the macro records and classifiers, the preprocessing
# pipeline -- are the C header library (tools/cheader/), which the binding
# generator shares (C-BINDGEN.md). This file loads its common helpers and
# adds what belongs to the experiment: where its profiles and results live.

namespace eval ::chdr {
    variable root [file dirname [file dirname [file normalize [info script]]]]
    variable repo [file dirname [file dirname $root]]
    variable lib [file join $repo tools cheader]
}
source [file join $::chdr::lib common.tcl]

# The profiles of LIBRARY (profiles/LIBRARY.tcl): a dict NAME -> profile.
proc ::chdr::loadProfiles {library} {
    variable root
    set path [file join $root profiles $library.tcl]
    if {![file exists $path]} { error "no profile file $path" }
    return [apply [list {} [list source $path]]]
}

# The profile NAME (LIBRARY-VARIANT).
proc ::chdr::profile {name} {
    set library [lindex [split $name -] 0]
    set profiles [loadProfiles $library]
    if {![dict exists $profiles $name]} {
        error "no profile $name (known: [dict keys $profiles])"
    }
    return [dict get $profiles $name]
}

# Sources a file of the C header library.
proc ::chdr::use {args} {
    variable lib
    foreach name $args {
        uplevel #0 [list source [file join $lib $name]]
    }
}

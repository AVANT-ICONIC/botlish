# macho-platform.tcl FILE.o ?PLATFORM MINOS? -- reports (and with PLATFORM
# and MINOS, rewrites) the LC_BUILD_VERSION of a 64-bit Mach-O object
# (REACT-NATIVE-TARGET-CENSUS.md, "iOS findings"). PLATFORM is a number of
# <mach-o/loader.h>'s PLATFORM_* (1 macOS, 2 iOS, 7 iOS simulator), MINOS a
# version X.Y.Z.
#
# Cranelift's object writer takes the platform from the ISA's triple, and
# Botlish's native backend builds its ISA for the host: an object made on a
# Mac says macOS. This tool is the census's way of asking Apple's linker
# whether that tag is the only thing between that object and an iOS app; a
# Botlish iOS target would build the ISA for the iOS triple instead.

lassign $argv path platform minos
set f [open $path rb]
set data [read $f]
close $f
binary scan $data iu1 magic
if {$magic != 0xfeedfacf} {
    error "$path: not a 64-bit little-endian Mach-O file"
}
binary scan $data @16iu1 ncmds
set offset 32
set found 0
for {set i 0} {$i < $ncmds} {incr i} {
    binary scan $data @${offset}iu1iu1 cmd size
    if {$cmd == 0x32} {
        binary scan $data @[expr {$offset + 8}]iu1iu1 old version
        puts "$path: LC_BUILD_VERSION platform $old minos [expr {$version >> 16}].[expr {($version >> 8) & 255}].[expr {$version & 255}]"
        if {$platform ne ""} {
            lassign [split $minos .] major minor patch
            set packed [expr {($major << 16) | ($minor << 8) | ($patch eq "" ? 0 : $patch)}]
            set data [string replace $data [expr {$offset + 8}] [expr {$offset + 15}] [binary format iu1iu1 $platform $packed]]
            puts "$path: rewritten to platform $platform minos $minos"
        }
        set found 1
    }
    incr offset $size
}
if {!$found} {
    puts "$path: no LC_BUILD_VERSION"
    exit 1
}
if {$platform ne ""} {
    set f [open $path wb]
    puts -nonewline $f $data
    close $f
}

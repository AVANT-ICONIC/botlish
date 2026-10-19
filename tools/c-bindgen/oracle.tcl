# oracle.tcl -- the runtime C oracle of generated layouts
# (C-BINDGEN-LAYOUTS.md, "Verification"). Test tooling: tests/c-bindgen.test
# and audit/c-bindgen/tools/fuzz.tcl source it; the generator never does.
#
#   ::cbind::oracle::build NS DIR LAYOUTS ?SEED?
#
# For layouts LAYOUTS of the generated binding NS in DIR (its NS/layouts.bot
# and layouts.tsv, as generation wrote them), the text of
#
#   oracle.c       C: for each layout's C record, functions that fill a
#                  record with 0xA5 and then write every leaf field with a
#                  value of its own C type at its own C address (init: a
#                  member C declares const is written so too), check every leaf and every padding
#                  byte of a record Botlish wrote in place (check_edit), check
#                  a byte image Botlish built in byte storage (check_bytes),
#                  hand out and compare pointer values (anchor, is), and
#                  answer sizeof and _Alignof;
#   orc.bot        the Botlish declarations of those functions (an ordinary
#                  module beside the program);
#   main.bot       a Botlish program that, for every layout, compares
#                  binary::layout_length and binary::layout_alignment with
#                  C's sizeof and _Alignof, reads every leaf of the record C
#                  initialized through binary::native::view, writes every
#                  leaf through binary::native::edit (binary::store) and has C
#                  check them and the padding, builds the record in
#                  abi::bytes::MutableBytes with binary::write and
#                  binary::write_foreign and has C check that image (and, for
#                  a layout without pointers, binary::parse reads it back);
#
# and the value the program must produce: a list per layout of zeros (each
# check returns 0 when C and Botlish agree, a nonzero code otherwise), with
# the label of every check for a failure's message. Every C access is a C
# member access of the record's C type with a C designator from the layout
# manifest; every number on the Botlish side is the generated layout's;
# the values are deterministic bit patterns per field (boundary values on
# every fourth), each phase its own.

namespace eval ::cbind::oracle {}

# The leaves of layout NAME of LAYOUTS (name -> {size align fields}) with
# MEMBERS ({layout field} -> C member): {{BOTPATH CPATH TYPE READ PARSE} ...},
# nested layouts flattened (a.b, a.b), fixed arrays element by element
# (FIXED-LAYOUT-ARRAYS.md): BOTPATH a static designator (a.items[2].x), CPATH
# the C designator, READ the Botlish expression reading the leaf through
# the view `v` (binary::element(v.a.items, 2).x) and PARSE the one reading
# it from the LayoutStruct `s` (list::at(s.a.items, 2).x). An array of more
# than four elements in a dimension is sampled there -- its first two, its
# middle and its last -- and every element left out is a byte no check
# covers: C checks it untouched.
proc ::cbind::oracle::Leaves {layouts members name {bot ""} {c ""} {read v} {parse s}} {
    set out {}
    foreach f [lindex [dict get $layouts $name] 2] {
        lassign $f fname type offset
        set cm [dict get $members [list $name $fname]]
        set bp [expr {$bot eq "" ? $fname : "$bot.$fname"}]
        set cp [expr {$c eq "" ? $cm : "$c.$cm"}]
        lappend out {*}[Elements $layouts $members $type $bp $cp "$read.$fname" "$parse.$fname"]
    }
    return $out
}

# The leaves of a field of type TYPE at BOT / C / READ / PARSE (Leaves').
proc ::cbind::oracle::Elements {layouts members type bot c read parse} {
    if {[regexp {^array ([0-9]+) of (.*)$} $type -> n element]} {
        set indices [expr {$n <= 4 ? [lsearch -all [lrepeat $n x] x] : [lsort -integer -unique [list 0 1 [expr {$n / 2}] [expr {$n - 1}]]]}]
        set out {}
        foreach i $indices {
            lappend out {*}[Elements $layouts $members $element "$bot\[$i\]" "$c\[$i\]" \
                "binary::element($read, $i)" "list::at($parse, $i)"]
        }
        return $out
    }
    if {[dict exists $layouts $type]} {
        return [Leaves $layouts $members $type $bot $c $read $parse]
    }
    return [list [list $bot $c $type $read $parse]]
}

# A deterministic value of an integer of BITS bits (SIGNED 0|1) for leaf I
# in PHASE (0 init, 1 edit, 2 bytes): {BITS-PATTERN VALUE}, every fourth
# leaf a boundary of its range.
proc ::cbind::oracle::Value {bits signed i phase seed} {
    set mod [expr {2 ** $bits}]
    switch -- [expr {($i + $phase) % 4}] {
        0 { set pattern [expr {$signed ? 2 ** ($bits - 1) : $mod - 1}] }
        1 { set pattern [expr {$signed ? 2 ** ($bits - 1) - 1 : 0}] }
        default {
            set pattern [expr {(($i + 1) * 0x9E3779B97F4A7C15 + ($phase + 1) * 0x632BE59BD9B4E019 + $seed * 0x2545F4914F6CDD1D) % $mod}]
        }
    }
    set value [expr {$signed && $pattern >= 2 ** ($bits - 1) ? $pattern - $mod : $pattern}]
    return [list $pattern $value]
}

proc ::cbind::oracle::Ident {s} { regsub -all {[^A-Za-z0-9_]} $s _ }

# The prelude of LAYOUTS-CHECK (layouts-check.c's text): its defines,
# includes and #undefs, before its own macros.
proc ::cbind::oracle::Prelude {check} {
    set at [string first "#define BOTLISH_M(" $check]
    return [string range $check 0 [expr {$at - 1}]]
}

proc ::cbind::oracle::build {ns dir names {seed 1} {target ""}} {
    if {$target eq ""} { set target [core::cabi::hostTarget] }
    set text [::chdr::readFile [file join $dir $ns layouts.bot]]
    set parsed [::cbind::verify::ParseLayouts $text]
    set layouts [dict create]
    foreach l $parsed { dict set layouts [lindex $l 0] [lrange $l 1 end] }
    lassign [::cbind::verify::CNames [::chdr::readFile [file join $dir layouts.tsv]]] records members
    if {$names eq "all"} { set names [dict keys $layouts] }
    set c [Prelude [::chdr::readFile [file join $dir layouts-check.c]]]
    append c "/* The runtime oracle of ${ns}::layouts (tools/c-bindgen/oracle.tcl): test tooling. */\n"
    append c "static char orc_anchor\[256\];\n"
    append c "#define ORC_ANCHOR(T, k) ((T)(__UINTPTR_TYPE__)&orc_anchor\[(k)\])\n"
    # (A binding whose layouts name no pointee identity has no ctypes module.)
    set ctypes [expr {[file exists [file join $dir $ns ctypes.bot]] ? "import ${ns}::ctypes\n" : ""}]
    set ext "# The C oracle's functions (tools/c-bindgen/oracle.tcl): test tooling.\nimport ffi::c\n$ctypes\nextern c library \"botlish_layout_oracle\"\n"
    set bot "direct module\n\nimport abi\nimport abi::bytes\nimport binary\nimport binary::native\nimport ffi::c\nimport list\nimport ${ns}::layouts\nimport orc\n"
    set calls {}
    set n 0
    foreach name $names {
        incr n
        set T [dict get $records $name]
        set L "${ns}::layouts::$name"
        set id [Ident $name]_$n
        set leaves [Leaves $layouts $members $name]
        set reads {}
        set parses {}
        set pointerFree 1
        foreach leaf $leaves { if {[regexp {^ffi::c::(Ptr|FnPtr)\[} [lindex $leaf 2]]} { set pointerFree 0 } }
        # C.
        append c "\n/* $name: $T */\n"
        append c "static union { $T value; unsigned char bytes\[sizeof($T)\]; } orc_rec_$id;\n"
        append c "unsigned long orc_${id}_size(void) { return sizeof($T); }\n"
        append c "unsigned long orc_${id}_align(void) { return _Alignof($T); }\n"
        append c "static int orc_${id}_covered(unsigned long i) {\n"
        append c "    static const unsigned long leaves\[\]\[2\] = {\n"
        foreach leaf $leaves {
            set cp [lindex $leaf 1]
            append c "        {__builtin_offsetof($T, $cp), sizeof(((($T *)0)->$cp))},\n"
        }
        append c "    };\n    for (unsigned long k = 0; k < sizeof leaves / sizeof leaves\[0\]; k++)\n"
        append c "        if (i >= leaves\[k\]\[0\] && i < leaves\[k\]\[0\] + leaves\[k\]\[1\]) return 1;\n    return 0;\n}\n"
        set init ""
        set checkEdit ""
        set checkBytes ""
        set botRead ""
        set botStore ""
        set botWrite ""
        set botParse ""
        set i 0
        foreach leaf $leaves {
            lassign $leaf bp cp type read parse
            set ct "__typeof__(((($T *)0)->$cp))"
            if {[regexp {^ffi::c::(Ptr|FnPtr)\[} $type]} {
                set ka [expr {($n * 7 + $i) % 200}]
                set kb [expr {$ka + 17}]
                set kc [expr {$ka + 33}]
                append c "$ct orc_${id}_anchor_$i\(int k) { return ORC_ANCHOR($ct, k); }\n"
                append c "int orc_${id}_is_$i\($ct q, int k) { return q == ORC_ANCHOR($ct, k) ? 0 : 1; }\n"
                append ext "extern c fn orc_${id}_anchor_$i\(k: ffi::c::Int) -> $type\n"
                append ext "extern c fn orc_${id}_is_$i\(q: $type, k: ffi::c::Int) -> ffi::c::Int\n"
                append init "    { $ct t = ORC_ANCHOR($ct, $ka); __builtin_memcpy((void *)&r->$cp, &t, sizeof t); }\n"
                append checkEdit "    if (r->$cp != ORC_ANCHOR($ct, $kb)) return [expr {$i + 1}];\n"
                append checkBytes "    if (r.$cp != ORC_ANCHOR($ct, $kc)) return [expr {$i + 1}];\n"
                append botRead "    q$i = $read\n    r$i = orc::orc_${id}_is_$i\(q$i, $ka)\n"
                lappend reads r$i
                append botStore "    a$i = orc::orc_${id}_anchor_$i\($kb)\n    binary::store(e, $L.$bp, a$i)\n"
                append botWrite "    b$i = orc::orc_${id}_anchor_$i\($kc)\n    d[expr {$i + 1}] = binary::write_foreign(d$i, $L.$bp, b$i)\n"
            } else {
                regexp {^ffi::c::([A-Za-z]+)$} $type -> scalar
                set info [core::cabi::scalarInfo $scalar $target]
                set bits [dict get $info bits]
                set signed [dict get $info signed]
                lassign [Value $bits $signed $i 0 $seed] pa va
                lassign [Value $bits $signed $i 1 $seed] pb vb
                lassign [Value $bits $signed $i 2 $seed] pc vc
                append init "    { $ct t = ($ct)${pa}ULL; __builtin_memcpy((void *)&r->$cp, &t, sizeof t); }\n"
                append checkEdit "    if (r->$cp != ($ct)${pb}ULL) return [expr {$i + 1}];\n"
                append checkBytes "    if (r.$cp != ($ct)${pc}ULL) return [expr {$i + 1}];\n"
                append botRead "    r$i = if $read == $va:\n        0\n    else:\n        1\n"
                lappend reads r$i
                append botStore "    binary::store(e, $L.$bp, $vb)\n"
                append botWrite "    d[expr {$i + 1}] = binary::write(d$i, $L.$bp, $vc)\n"
                if {$pointerFree} {
                    append botParse "    s$i = if $parse == $vc:\n        0\n    else:\n        1\n"
                    lappend parses s$i
                }
            }
            incr i
        }
        append c "void *orc_${id}_init(void) {\n    $T *r = &orc_rec_$id.value;\n    __builtin_memset(&orc_rec_$id, 0xA5, sizeof orc_rec_$id);\n$init    return r;\n}\n"
        append c "int orc_${id}_check_edit(const void *p) {\n    const $T *r = p;\n$checkEdit"
        append c "    for (unsigned long i = 0; i < sizeof($T); i++)\n        if (!orc_${id}_covered(i) && ((const unsigned char *)p)\[i\] != 0xA5) return 1000 + (int)i;\n    return 0;\n}\n"
        append c "int orc_${id}_check_bytes(const unsigned char *b, unsigned long n) {\n    $T r;\n    if (n != sizeof($T)) return -1;\n    __builtin_memcpy(&r, b, sizeof r);\n$checkBytes"
        append c "    for (unsigned long i = 0; i < sizeof($T); i++)\n        if (!orc_${id}_covered(i) && b\[i\] != 0) return 1000 + (int)i;\n    return 0;\n}\n"
        append ext "extern c fn orc_${id}_size() -> ffi::c::ULong\n"
        append ext "extern c fn orc_${id}_align() -> ffi::c::ULong\n"
        append ext "extern c fn orc_${id}_init() -> ffi::c::Ptr\[ffi::c::Void\]\n"
        append ext "extern c fn orc_${id}_check_edit(p: ffi::c::Ptr\[ffi::c::Void\]) -> ffi::c::Int\n"
        append ext "extern c fn orc_${id}_check_bytes(\n    b: ffi::c::Ptr\[ffi::c::UChar\] read noescape,\n    n: ffi::c::ULong\n) -> ffi::c::Int\n"
        # Botlish.
        set fn "\n# $name ($T)\nfn check_$id\() -> List\[int\] errors NativeViewNull, NativeEditNull, LayoutLengthMismatch, IndexNotFound:\n"
        append fn "    size = if orc::orc_${id}_size() == binary::layout_length($L):\n        0\n    else:\n        1\n"
        append fn "    align = if orc::orc_${id}_align() == binary::layout_alignment($L):\n        0\n    else:\n        1\n"
        append fn "    p = orc::orc_${id}_init()\n    v = binary::native::view($L, p)\n$botRead"
        append fn "    e = binary::native::edit($L, p)\n$botStore    edited = orc::orc_${id}_check_edit(p)\n"
        append fn "    d0 = abi::bytes::zeroed(abi::usize(binary::layout_length($L)))\n$botWrite"
        set dn d[llength $leaves]
        if {$pointerFree} {
            append fn "    s = binary::parse($L, abi::bytes::freeze($dn))\n$botParse"
        }
        append fn "    built = orc::orc_${id}_check_bytes($dn, [lindex [dict get $layouts $name] 0])\n"
        set all [concat size align $reads edited built $parses]
        append fn "    \[[join $all {, }]\]\n"
        append bot $fn
        lappend calls check_$id
        lappend expected [lrepeat [llength $all] 0]
        lappend checkLabels [concat [list "$name: layout_length == sizeof" "$name: layout_alignment == _Alignof"] \
            [lmap leaf $leaves {string cat $name "." [lindex $leaf 0] ": view read of C's store"}] \
            [list "$name: C reads every leaf Botlish stored through the edit, padding untouched" \
                "$name: C reads every leaf Botlish wrote in byte storage, padding zero"] \
            [expr {$pointerFree ? [lmap leaf $leaves {string cat $name "." [lindex $leaf 0] ": binary::parse of the bytes"}] : {}}]]
    }
    append bot "\nfn run() -> List\[any\] errors NativeViewNull, NativeEditNull, LayoutLengthMismatch, IndexNotFound:\n    \[[join [lmap k $calls {string cat $k "()"}] {, }]\]\n"
    append bot "\nr = run():\n    on NativeViewNull:\n        \[\"view of null\"\]\n    on NativeEditNull:\n        \[\"edit of null\"\]\n    on LayoutLengthMismatch:\n        \[\"length mismatch\"\]\n    on IndexNotFound:\n        \[\"index not found\"\]\nr\n"
    return [dict create c $c ext $ext bot $bot expected $expected labels $checkLabels names $names]
}

# The checks of RESULT (build's) a program VALUE fails (its shown value, a
# list of lists of Ints: [[0, 0], [0]]): their labels, with the code each
# returned.
proc ::cbind::oracle::failures {result value} {
    set out {}
    if {[regexp {^[][0-9, -]*$} $value]} { set value [lindex [string map {[ \{ ] \} , ""} $value] 0] }
    if {[llength $value] != [llength [dict get $result expected]]} {
        return [list "the program returned [string range $value 0 300]"]
    }
    foreach got $value want [dict get $result expected] labels [dict get $result labels] {
        foreach g $got w $want label $labels {
            if {$g ne $w} { lappend out "$label: code $g" }
        }
    }
    return $out
}

# Writes RESULT's files into APP (orc.bot, main.bot) and compiles its C
# oracle with CONFIG (a toolchain configuration) and the header profile
# TOOL into DIR's libbotlish_layout_oracle.a; returns DIR.
proc ::cbind::oracle::install {result app config tool dir} {
    ::chdr::writeFile [file join $app orc.bot] [dict get $result ext]
    ::chdr::writeFile [file join $app main.bot] [dict get $result bot]
    file mkdir $dir
    set src [file join $dir oracle.c]
    ::chdr::writeFile $src [dict get $result c]
    lassign [::chdr::toolchain::object $config $tool $src [file join $dir oracle.o] {-O1 -fPIC -w}] ok stderr
    if {!$ok} { error "the layout oracle does not compile:\n[string range $stderr 0 3000]" }
    lassign [::chdr::toolchain::archive $config [list [file join $dir oracle.o]] [file join $dir libbotlish_layout_oracle.a]] ok stderr
    if {!$ok} { error "the layout oracle's archive: $stderr" }
    return $dir
}

# membership.tcl -- the constant-membership experiment of the hash-table
# milestone (HASH-TABLE-EXPERIMENT.md, "Constant membership"; brief sections
# 15-19).
#
#   tclsh9.0 audit/hash-table/tools/membership.tcl ?-domains LIST?
#       ?-strategies LIST? ?-sizes LIST? ?-queries M? ?-runs R? ?-out FILE?
#       ?-backend B? ?-show DOMAIN/STRATEGY/K? ?-check 1? ?-data-limit N?
#       ?-max-chain N?
#
# -check 1 times nothing: it generates every program with every member as a
# hit query and every non-member as a miss query (programOf's FULL), runs
# both modes once through each list on interp, compile, cranelift and
# cranelift-generic, and requires K hits and 0 misses everywhere (a wrong
# representation fails here). A set with no non-members (the 64-case enum's
# K = 64) has no miss mode, timed or checked.
#
# For a constant set S of K values of a domain, each strategy below is a
# generated Botlish function `member?(x) -> bool` -- a representation a
# compiler could choose for membership in S while the semantics stay
# membership in S -- plus a driver that tests M queries, all present (hit)
# or all absent (miss), cycling through 64 query values. The generator does
# what a compiler would do at compile time (sorting, building bitsets,
# searching for a perfect hash) and reports its time.
#
# Domains:
#   int-dense   S a K-subset of 0..2K-1 (a bounded domain of 2K values)
#   int-sparse  S K values spread over 0..2^31
#   str         S K identifier-like Strings (keywords first, then generated)
#   enum        S K cases of a 64-case enum
#
# Strategies (not every one applies to every domain):
#   chain    x == c1 or x == c2 or ...                       (all)
#   list     a module-level List literal, a counted-loop scan (all)
#   iset     immutable_set::from_list of the literal, contains (all)
#   table    the experiment's lpa table built at start, has?   (all)
#   bsearch  a sorted List literal, binary search             (ints)
#   tree     a generated balanced comparison tree             (ints)
#   bits     32-bit words and a mask table, range check       (int-dense)
#   direct   a List of K Bools over the domain, range check   (int-dense)
#   pmod     the smallest M >= K with hash(x) mod M injective on S; a List
#            of M slots, every empty one filled with a member (int, str)
#   phash    hash-and-displace: B buckets by low hash bits, a displacement
#            per bucket XORed into high hash bits, M = 2^ceil(log2 K) slots
#            (int, str)
#   length   dispatch on str::length, then an equality chain  (str)
#   trie     dispatch on str::length, then on characters: at each node the
#            position that splits the remaining members most, a comparison
#            tree over its code points, one equality at a leaf (str)
#
# Per program and mode the native driver's best of R runs; a query costs
# (T[M] - T[0]) / M. Code size: native::codeSize of the strategy's own
# functions (member? and helpers whose names start "member"). Data: the
# constant elements the strategy's literals hold. Writes TSV rows:
#
#   domain strategy k mode queries best-us ns-per-query code-bytes data-elements
#   generate-ms frontend-ms lower-ms checksum

source [file join [file dirname [file normalize [info script]]] lib.tcl]

set options [dict create -domains {int-dense int-sparse str enum} \
    -strategies {chain list iset table bsearch tree bits direct pmod phash length trie} \
    -sizes {1 2 3 4 6 8 12 16 24 32 48 64 128 256 512 1024} -queries 1000000 -runs 5 \
    -out "" -backend cranelift -show "" -check 0 -data-limit 16384 -max-chain 512]
for {set i 0} {$i < [llength $argv]} {incr i} {
    set arg [lindex $argv $i]
    if {![dict exists $options $arg]} { error "unknown option $arg" }
    dict set options $arg [lindex $argv [incr i]]
}

# ---------------------------------------------------------------------------
# Constant sets

# A deterministic generator (an LCG) for the experiment's choices.
proc lcg {state} {
    return [expr {($state * 6364136223846793005 + 1442695040888963407) % (1 << 64)}]
}

# K distinct values of DOMAIN, and the values not among them that misses
# query: 64 (int-sparse, the Strings), int-dense's other K of 0..2K-1, or
# the enum's other 64 - K cases (none at K = 64).
proc constants {domain k} {
    set seed [expr {1000 + $k}]
    switch -- $domain {
        int-dense {
            # A K-subset of 0..2K-1 and the other K values of the domain.
            set all {}
            for {set i 0} {$i < 2 * $k} {incr i} { lappend all $i }
            set members {}
            set others {}
            foreach v $all {
                set seed [lcg $seed]
                if {[llength $members] < $k && (([llength $others] >= $k) || (($seed >> 33) % 2 == 0))} {
                    lappend members $v
                } else {
                    lappend others $v
                }
            }
            return [list $members $others]
        }
        int-sparse {
            set members {}
            set seen [dict create]
            while {[llength $members] < $k} {
                set seed [lcg $seed]
                set v [expr {($seed >> 20) % (1 << 31)}]
                if {![dict exists $seen $v]} { dict set seen $v 1; lappend members $v }
            }
            set others {}
            while {[llength $others] < 64} {
                set seed [lcg $seed]
                set v [expr {($seed >> 20) % (1 << 31)}]
                if {![dict exists $seen $v]} { dict set seen $v 1; lappend others $v }
            }
            return [list $members $others]
        }
        str {
            set words {
                if else elif for while in and or not return break continue def class
                import from as with try except finally raise pass yield lambda global
                nonlocal assert del is None True False async await match case type
                int char float double long short unsigned signed struct union enum
                static const volatile extern register sizeof typedef switch default goto
                do auto inline restrict bool void
            }
            set members [lrange $words 0 [expr {$k - 1}]]
            for {set i [llength $members]} {$i < $k} {incr i} {
                lappend members [format "ident_%x" [expr {$i * 2654435761 % (1 << 32)}]]
            }
            set others {}
            for {set i 0} {[llength $others] < 64} {incr i} {
                set w [format "other_%x" [expr {$i * 40503 + 7}]]
                lappend others $w
                # Near misses too: a member with one more character.
                if {$i < [llength $members]} { lappend others "[lindex $members $i]x" }
            }
            return [list $members [lrange $others 0 63]]
        }
        enum {
            set members {}
            set others {}
            for {set i 0} {$i < 64} {incr i} {
                if {$i < $k} { lappend members "Kw::C$i" } else { lappend others "Kw::C$i" }
            }
            return [list $members $others]
        }
    }
}

proc literal {domain v} {
    if {$domain eq "str"} { return "\"$v\"" }
    return $v
}

proc typeOf {domain} {
    return [dict get {int-dense int int-sparse int str str enum Kw} $domain]
}

# The Botlish hash of constant V (core/hashing.tcl, the reference the native
# runtime agrees with byte for byte).
proc hashOf {domain v} {
    set value [expr {$domain eq "str" ? [core::value::str $v] : [core::value::intFromNumber $v]}]
    return [core::value::intOf [core::hashing::hash $value]]
}

# ---------------------------------------------------------------------------
# Strategies: each returns {SOURCE DATA-ELEMENTS} (SOURCE defines member?
# and anything it needs, at module level), or "" when it does not apply.

proc chainOf {domain members} {
    set terms [lmap v $members {format "x == %s" [literal $domain $v]}]
    return [list "fn member?(x: [typeOf $domain]) -> bool:\n    [join $terms { or }]\n" 0]
}

proc listOf {domain members} {
    set items [join [lmap v $members {literal $domain $v}] ", "]
    return [list "member_items = \[$items\]\n\nfn member?(x: [typeOf $domain]) -> bool:\n    loop i from 0 to list::length(member_items):\n        if list::at(member_items, i) == x:\n            return true\n    false\n" [llength $members]]
}

proc isetOf {domain members} {
    set items [join [lmap v $members {literal $domain $v}] ", "]
    return [list "member_set = immutable_set::from_list(\[$items\])\n\nfn member?(x: [typeOf $domain]) -> bool:\n    immutable_set::contains(member_set, x)\n" [llength $members]]
}

proc tableOf {domain members} {
    # A table value is built in main (tables are threaded, not module
    # bindings); member? takes it as an argument (see programOf).
    return [list "fn member?(t: table::Table, x) -> bool errors IndexNotFound:\n    table::has?(t, x)\n" [llength $members]]
}

proc bsearchOf {domain members} {
    if {$domain ni {int-dense int-sparse}} { return "" }
    set sorted [lsort -integer $members]
    set items [join $sorted ", "]
    set n [llength $sorted]
    return [list "member_sorted = \[$items\]\n
# Whether X is in member_sorted's positions LO..HI-1.
fn member_search(x: int, lo: int, hi: int) -> bool errors IndexNotFound:
    if lo >= hi:
        return false
    mid = shift_right(lo + hi, 1)
    v = list::at(member_sorted, mid)
    if v == x:
        return true
    if v < x:
        return member_search(x, mid + 1, hi)
    member_search(x, lo, mid)

fn member?(x: int) -> bool errors IndexNotFound:
    member_search(x, 0, $n)
" $n]
}

proc treeNode {sorted lo hi indent} {
    set pad [string repeat "    " $indent]
    if {$hi - $lo <= 3} {
        set terms [lmap v [lrange $sorted $lo [expr {$hi - 1}]] {format "x == %s" $v}]
        if {$terms eq ""} { return "${pad}false\n" }
        return "${pad}[join $terms { or }]\n"
    }
    set mid [expr {($lo + $hi) / 2}]
    set pivot [lindex $sorted $mid]
    return "${pad}if x < $pivot:\n[treeNode $sorted $lo $mid [expr {$indent + 1}]]${pad}else:\n[treeNode $sorted $mid $hi [expr {$indent + 1}]]"
}

proc treeOf {domain members} {
    if {$domain ni {int-dense int-sparse}} { return "" }
    set sorted [lsort -integer $members]
    return [list "fn member?(x: int) -> bool:\n[treeNode $sorted 0 [llength $sorted] 1]" 0]
}

proc bitsOf {domain members} {
    if {$domain ne "int-dense"} { return "" }
    set u [expr {2 * [llength $members]}]
    set nwords [expr {($u + 31) / 32}]
    set words [lrepeat $nwords 0]
    foreach v $members {
        lset words [expr {$v >> 5}] [expr {[lindex $words [expr {$v >> 5}]] | (1 << ($v & 31))}]
    }
    set masks {}
    for {set b 0} {$b < 32} {incr b} { lappend masks [expr {1 << $b}] }
    return [list "member_words = \[[join $words {, }]\]
member_masks = \[[join $masks {, }]\]

fn member?(x: int) -> bool:
    if x < 0 or x >= $u:
        return false
    bit_and(list::at(member_words, shift_right(x, 5)), list::at(member_masks, bit_and(x, 31))) != 0
" [expr {$nwords + 32}]]
}

proc directOf {domain members} {
    if {$domain ne "int-dense"} { return "" }
    set u [expr {2 * [llength $members]}]
    set flags [lrepeat $u false]
    foreach v $members { lset flags $v true }
    return [list "member_flags = \[[join $flags {, }]\]

fn member?(x: int) -> bool:
    if x < 0 or x >= $u:
        return false
    list::at(member_flags, x)
" $u]
}

# The smallest M >= K for which hash mod M is injective on MEMBERS (give up
# past LIMIT), and the search's time.
proc pmodSearch {domain members limit} {
    set hashes [lmap v $members {hashOf $domain $v}]
    for {set m [llength $members]} {$m <= $limit} {incr m} {
        set seen [dict create]
        set ok 1
        foreach h $hashes {
            set s [expr {$h % $m}]
            if {[dict exists $seen $s]} { set ok 0; break }
            dict set seen $s 1
        }
        if {$ok} { return $m }
    }
    return ""
}

proc pmodOf {domain members} {
    if {$domain eq "enum"} { return "" }
    set k [llength $members]
    set m [pmodSearch $domain $members [expr {max(64, 64 * $k * $k)}]]
    if {$m eq ""} { return "" }
    set slots [lrepeat $m [lindex $members 0]]
    foreach v $members {
        lset slots [expr {[hashOf $domain $v] % $m}] $v
    }
    set items [join [lmap v $slots {literal $domain $v}] ", "]
    return [list "member_slots = \[$items\]

# Every slot holds a member (an empty one any member), so the slot of X's
# hash holds X exactly when X is a member.
fn member?(x: [typeOf $domain]) -> bool:
    list::at(member_slots, hash(x).mod($m)) == x
" $m]
}

# Hash and displace: bucket b = h mod B (B a power of two), slot =
# ((h >> SHIFT) xor d[b]) mod M (M a power of two, the next one at or above
# K, else twice that). Buckets are placed largest first, each with the
# smallest displacement whose slots are free and distinct; SHIFT and B are
# searched too. Returns {B M SHIFT DISPLACEMENTS SLOTS} or "".
proc phashSearch {domain members} {
    set k [llength $members]
    set m0 1
    while {$m0 < $k} { set m0 [expr {$m0 * 2}] }
    set hashes [lmap v $members {hashOf $domain $v}]
    # Fewest slots first (M = the next power of two, then twice that), then
    # fewest displacements (K/4 buckets, K/2, K).
    foreach m [list $m0 [expr {2 * $m0}]] {
      foreach bdiv {4 2 1} {
        set b 1
        while {$b * $bdiv < $k} { set b [expr {$b * 2}] }
        foreach shift {20 24 28 32 36 40} {
            set buckets [dict create]
            foreach v $members h $hashes {
                dict lappend buckets [expr {$h % $b}] [list $v [expr {($h >> $shift) % $m}]]
            }
            set order [lsort -integer -decreasing -index 1 [lmap {key entries} $buckets {list $key [llength $entries]}]]
            set free [lrepeat $m 1]
            set slots [lrepeat $m ""]
            set disp [lrepeat $b 0]
            set ok 1
            foreach pair $order {
                set key [lindex $pair 0]
                set entries [dict get $buckets $key]
                set placed 0
                for {set d 0} {$d < $m} {incr d} {
                    set targets {}
                    set good 1
                    foreach e $entries {
                        set s [expr {[lindex $e 1] ^ $d}]
                        if {![lindex $free $s] || $s in $targets} { set good 0; break }
                        lappend targets $s
                    }
                    if {$good} {
                        foreach e $entries s $targets {
                            lset free $s 0
                            lset slots $s [lindex $e 0]
                        }
                        lset disp $key $d
                        set placed 1
                        break
                    }
                }
                if {!$placed} { set ok 0; break }
            }
            if {$ok} {
                set slots [lmap s $slots {expr {$s eq "" ? [lindex $members 0] : $s}}]
                return [list $b $m $shift $disp $slots]
            }
        }
      }
    }
    return ""
}

proc phashOf {domain members} {
    if {$domain eq "enum"} { return "" }
    set found [phashSearch $domain $members]
    if {$found eq ""} { return "" }
    lassign $found b m shift disp slots
    set items [join [lmap v $slots {literal $domain $v}] ", "]
    return [list "member_disp = \[[join $disp {, }]\]
member_slots = \[$items\]

# Every slot holds a member (an empty one any member), so the slot X's hash
# displaces to holds X exactly when X is a member.
fn member?(x: [typeOf $domain]) -> bool:
    h = hash(x)
    d = list::at(member_disp, bit_and(h, [expr {$b - 1}]))
    list::at(member_slots, bit_and(bit_xor(shift_right(h, $shift), d), [expr {$m - 1}])) == x
" [expr {$b + $m}]]
}

proc lengthOf {domain members} {
    if {$domain ne "str"} { return "" }
    set groups [dict create]
    foreach v $members { dict lappend groups [string length $v] $v }
    set branches {}
    set first 1
    foreach len [lsort -integer [dict keys $groups]] {
        set terms [lmap v [dict get $groups $len] {format "x == \"%s\"" $v}]
        lappend branches "    [expr {$first ? "if" : "elif"}] n == $len:\n        [join $terms { or }]"
        set first 0
    }
    return [list "fn member?(x: str) -> bool:\n    n = str::length(x)\n[join $branches \n]\n    else:\n        false\n" 0]
}

# A trie node over GROUP, members of one length: one equality when two or
# fewer remain; otherwise the code point at the position that tells the
# most of them apart, bound once (NAME), and a comparison tree over its
# values whose leaves are the subgroups' nodes.
proc trieNode {group indent} {
    global trieNames
    set pad [string repeat "    " $indent]
    if {[llength $group] <= 2} {
        return "${pad}[join [lmap v $group {format "x == \"%s\"" $v}] { or }]\n"
    }
    set best 0
    set bestCount 0
    for {set d 0} {$d < [string length [lindex $group 0]]} {incr d} {
        set seen [lsort -unique [lmap v $group {string index $v $d}]]
        if {[llength $seen] > $bestCount} { set best $d; set bestCount [llength $seen] }
    }
    set parts [dict create]
    foreach v $group { dict lappend parts [scan [string index $v $best] %c] $v }
    set name c[incr trieNames]
    return "${pad}$name = char::scalar_value(str::char_at(x, $best))\n[trieSplit $name [lsort -integer [dict keys $parts]] $parts $indent]"
}

proc trieSplit {name points parts indent} {
    set pad [string repeat "    " $indent]
    if {[llength $points] == 1} {
        set p [lindex $points 0]
        return "${pad}if $name != $p:\n${pad}    return false\n[trieNode [dict get $parts $p] $indent]"
    }
    set mid [expr {[llength $points] / 2}]
    set pivot [lindex $points $mid]
    return "${pad}if $name < $pivot:\n[trieSplit $name [lrange $points 0 [expr {$mid - 1}]] $parts [expr {$indent + 1}]]${pad}else:\n[trieSplit $name [lrange $points $mid end] $parts [expr {$indent + 1}]]"
}

proc trieOf {domain members} {
    global trieNames
    if {$domain ne "str"} { return "" }
    set trieNames 0
    set groups [dict create]
    foreach v $members { dict lappend groups [string length $v] $v }
    set fns {}
    set branches {}
    set first 1
    foreach len [lsort -integer [dict keys $groups]] {
        lappend fns "fn member_len$len?(x: str) -> bool errors IndexNotFound:\n[trieNode [dict get $groups $len] 1]"
        lappend branches "    [expr {$first ? "if" : "elif"}] n == $len:\n        member_len$len?(x)"
        set first 0
    }
    return [list "[join $fns \n]\nfn member?(x: str) -> bool errors IndexNotFound:\n    n = str::length(x)\n[join $branches \n]\n    else:\n        false\n" 0]
}

# ---------------------------------------------------------------------------
# The program

# The program for DOMAIN/STRATEGY/K: {TEXT DATA GENERATE-MS MISSES}, MISSES
# the number of miss query values (0 when every value of the domain is a
# member). With FULL the queries are every member and every non-member,
# each once (-check); otherwise 64 of each, cycled (timing).
proc programOf {domain strategy k {full 0}} {
    lassign [constants $domain $k] members others
    set t0 [clock microseconds]
    set made [${strategy}Of $domain $members]
    set generateMs [expr {([clock microseconds] - $t0) / 1000.0}]
    if {$made eq ""} { return "" }
    lassign $made source data
    if {$full} {
        set hits $members
        set misses $others
        set index j
    } else {
        # 64 query values each: hits cycle through the members, misses are
        # absent values.
        set hits {}
        for {set i 0} {$i < 64} {incr i} { lappend hits [lindex $members [expr {$i % $k}]] }
        set misses {}
        if {[llength $others] > 0} {
            for {set i 0} {$i < 64} {incr i} { lappend misses [lindex $others [expr {$i % [llength $others]}]] }
        }
        set index "bit_and(j, 63)"
    }
    set type [typeOf $domain]
    set header "import list\nimport str\nimport char\n"
    if {$strategy eq "iset"} { append header "import immutable_set\n" }
    if {$strategy eq "table"} { append header "import table\n" }
    if {$domain eq "enum"} {
        set cases {}
        for {set i 0} {$i < 64} {incr i} { lappend cases "    C$i," }
        append header "\nenum Kw:\n[join $cases \n]\n"
    }
    set hitItems [join [lmap v $hits {literal $domain $v}] ", "]
    set missItems [join [lmap v $misses {literal $domain $v}] ", "]
    if {$strategy eq "table"} {
        set arg "t, "
        set param "t: table::Table, "
        set build "    t = table::from_lists(member_keys, member_vals)\n"
        set keysItems [join [lmap v $members {literal $domain $v}] ", "]
        set vals [join [lrepeat $k 1] ", "]
        append source "\nmember_keys = \[$keysItems\]\nmember_vals = \[$vals\]\n"
    } else {
        set arg ""
        set param ""
        set build ""
    }
    set text "${header}
query_hits = \[$hitItems\]
query_misses = \[$missItems\]

$source
fn bit(b: bool) -> int:
    if b:
        1
    else:
        0

fn int_of(text: str) -> int errors IndexNotFound:
    n = text.length()
    fn digits(i: int, acc: int) -> int errors IndexNotFound:
        if i >= n:
            return acc
        digits(i + 1, acc * 10 + char::scalar_value(text.char_at(i)) - 48)
    digits(0, 0)

fn run_hits(${param}j: int, m: int, acc: int) -> int errors IndexNotFound:
    if j >= m:
        return acc
    run_hits(${arg}j + 1, m, acc + bit(member?(${arg}list::at(query_hits, $index))))

fn run_misses(${param}j: int, m: int, acc: int) -> int errors IndexNotFound:
    if j >= m:
        return acc
    run_misses(${arg}j + 1, m, acc + bit(member?(${arg}list::at(query_misses, $index))))

fn main(args: List\[str\]) -> int errors IndexNotFound:
    mode = list::get(args, 1, \"none\")
    m = int_of(list::get(args, 2, \"0\"))
$build    if mode == \"hit\":
        return run_hits(${arg}0, m, 0)
    if mode == \"miss\":
        return run_misses(${arg}0, m, 0)
    0

args = argv():
    on InvalidArgumentEncoding:
        \[\]
result = main(args):
    on IndexNotFound:
        -1
result
"
    return [list $text $data $generateMs [llength $misses]]
}

# ---------------------------------------------------------------------------

proc strategyBytes {hir} {
    lassign [native::codeSize $hir] total sizes
    set names {}
    foreach line [split [native::nir $hir] \n] {
        if {[regexp {^func (\d+) "([^"]*)"} $line -> id name]} { dict set names $id $name }
    }
    set bytes 0
    foreach size $sizes id [dict keys $names] {
        if {[string match member* [dict get $names $id]]} { incr bytes $size }
    }
    return $bytes
}

if {[dict get $options -show] ne ""} {
    lassign [split [dict get $options -show] /] domain strategy k
    puts [lindex [programOf $domain $strategy $k] 0]
    exit 0
}

set outChannel ""
if {[dict get $options -out] ne ""} { set outChannel [open [dict get $options -out] a] }
set m [dict get $options -queries]
set failed 0
try {
    foreach domain [dict get $options -domains] {
        foreach strategy [dict get $options -strategies] {
            foreach k [dict get $options -sizes] {
                if {$domain eq "enum" && $k > 64} continue
                # An equality chain (chain, and length's per-length chains)
                # of more than MAX-CHAIN terms is not measured: the front end
                # gives up on 1024 (CO-8), and length's 1024 Strings ran a
                # tclsh out of 15 GB of memory.
                if {$strategy in {chain length} && $k > [dict get $options -max-chain]} {
                    puts "SKIP $domain $strategy $k: an equality chain of more than -max-chain [dict get $options -max-chain] terms"
                    continue
                }
                set made [programOf $domain $strategy $k [dict get $options -check]]
                if {$made eq ""} continue
                lassign $made text data generateMs misses
                # A constant table of more than DATA-LIMIT elements is not
                # measured: native lowering of a List literal grows faster
                # than its length (15531 elements took 173 s, 62949 ran out
                # of 15 GB of memory: HASH-TABLE-COMPILER-PRESSURE.md, CO-7).
                if {$data > [dict get $options -data-limit]} {
                    puts "SKIP $domain $strategy $k: $data data elements (over -data-limit [dict get $options -data-limit])"
                    continue
                }
                set dir [file join [ht::workDir] m-$domain-$strategy-$k]
                file mkdir $dir
                ht::writeFile [file join $dir main.bot] $text
                if {$strategy eq "table"} {
                    ht::writeFile [file join $dir table.bot] [ht::readFile [file join $ht::base impl lpa.bot]]
                }
                set t0 [clock microseconds]
                if {[catch {ht::compile [file join $dir main.bot]} hir]} {
                    puts "SKIP $domain $strategy $k: [string range $hir 0 300]"
                    continue
                }
                set frontendMs [expr {([clock microseconds] - $t0) / 1000.0}]
                if {[dict get $options -check]} {
                    set verdict ok
                    foreach backend {interp compile cranelift cranelift-generic} {
                        set hit [ht::run $hir $backend [list hit $k]]
                        set miss [ht::run $hir $backend [list miss $misses]]
                        if {$hit ne $k || $miss ne "0"} {
                            set verdict "FAIL $backend hit=$hit/$k miss=$miss/$misses"
                            set ::failed 1
                        }
                    }
                    puts "check $domain $strategy $k: $verdict ($k members, $misses non-members)"
                    continue
                }
                set t0 [clock microseconds]
                set bytes [strategyBytes $hir]
                set lowerMs [expr {([clock microseconds] - $t0) / 1000.0}]
                # With no non-member there is no miss mode to time.
                set modes [expr {$misses > 0 ? {hit miss} : {hit}}]
                set results [ht::benchNative $hir [list {none 0} {*}[lmap mode $modes {list $mode $m}]] [dict get $options -runs]]
                lassign [lindex $results 0] base
                foreach mode $modes result [lrange $results 1 end] {
                    lassign $result us sum
                    set row [list $domain $strategy $k $mode $m $us [format %.2f [expr {($us - $base) * 1000.0 / $m}]] \
                        $bytes $data [format %.1f $generateMs] [format %.0f $frontendMs] [format %.0f $lowerMs] $sum]
                    puts [join $row \t]
                    if {$outChannel ne ""} { puts $outChannel [join $row \t]; flush $outChannel }
                }
            }
        }
    }
} finally {
    if {$outChannel ne ""} { close $outChannel }
    ht::cleanup
}
exit $failed

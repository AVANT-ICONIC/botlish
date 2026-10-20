# attribution.tcl -- which value-semantics deficiency costs the natural `lp`
# its copies (HASH-TABLE-COMPILER-PRESSURE.md, VS-1, VS-3, VS-7): `lp` as
# written, then with each trigger's source workaround applied (SPEC.md
# section 7) and both, each built from 1,024 Int keys and then 2,000
# replacements, with the native allocation counters' MutableArray shares,
# detaches and elements copied. Run it once per compiler tree
# (BOTLISH_HT_ROOT, tools/lib.tcl): the baseline shows what the workarounds
# remove, a tree with per-path last uses what is left for the compiler.
#
#   tclsh9.0 audit/hash-table/tools/attribution.tcl
#
# Variants:
#   as-written   impl/lp.bot
#   no-VS-3      the reading argument bound first: `j = find_empty(dest.hashes, h)`
#                before `store(dest, j, ...)` (twice)
#   no-VS-7      the lookup and empty-slot walks top-level functions taking
#                the table, instead of nested functions capturing its arrays
#   no-VS-3+7    both

source [file join [file dirname [file normalize [info script]]] lib.tcl]

set vs3 {
    {    placed = store(dest, find_empty(dest.hashes, h), h, std::mutable_array::at(keys, i), std::mutable_array::at(vals, i))}
    {    j = find_empty(dest.hashes, h)
    placed = store(dest, j, h, std::mutable_array::at(keys, i), std::mutable_array::at(vals, i))}
    {        return with_count(store(g, find_empty(g.hashes, h), h, key, value), t.count + 1)}
    {        j = find_empty(g.hashes, h)
        return with_count(store(g, j, h, key, value), t.count + 1)}
}
set vs7 {
    {fn find(t: Table, h: int, key) -> int errors IndexNotFound:
    hashes = t.hashes
    keys = t.keys
    cap = hashes.capacity()
    fn walk(i: int) -> int errors IndexNotFound:
        s = hashes.at(i)
        if s < 0 or s == h and std::mutable_array::at(keys, i) == key:
            return i
        walk(next_slot(i, cap))
    walk(home(h, cap))}
    {fn walk(t: Table, h: int, key, i: int) -> int errors IndexNotFound:
    s = t.hashes.at(i)
    if s < 0 or s == h and t.keys.at(i) == key:
        return i
    walk(t, h, key, next_slot(i, t.hashes.capacity()))

fn find(t: Table, h: int, key) -> int errors IndexNotFound:
    walk(t, h, key, home(h, t.hashes.capacity()))}
    {fn find_empty(hashes: MutableArray[int], h: int) -> int errors IndexNotFound:
    cap = hashes.capacity()
    fn walk(i: int) -> int errors IndexNotFound:
        if hashes.at(i) < 0:
            return i
        walk(next_slot(i, cap))
    walk(home(h, cap))}
    {fn empty_walk(hashes: MutableArray[int], i: int) -> int errors IndexNotFound:
    if hashes.at(i) < 0:
        return i
    empty_walk(hashes, next_slot(i, hashes.capacity()))

fn find_empty(hashes: MutableArray[int], h: int) -> int errors IndexNotFound:
    empty_walk(hashes, home(h, hashes.capacity()))}
}

puts "compiler: $ht::root"
puts [format "%-11s %-8s %8s %9s %12s" variant mode shares detaches elements]
try {
    foreach {name edits} [list as-written {} no-VS-3 $vs3 no-VS-7 $vs7 no-VS-3+7 [concat $vs3 $vs7]] {
        set hir [ht::compile [ht::app attribution-$name bench.bot lp int $edits]]
        foreach mode {build replace} {
            set r [dict get [ht::allocNative $hir [list $mode 0 1024 2000 1]] mutableArray]
            puts [format "%-11s %-8s %8d %9d %12d" $name $mode \
                [dict get $r shares] [dict get $r detaches] [dict get $r detachElements]]
        }
    }
} finally {
    ht::cleanup
}

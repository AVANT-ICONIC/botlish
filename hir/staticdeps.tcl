# staticdeps.tcl -- which static sites each site's decision depends on
# (STATIC-COMPILE.md, "Decision economics"; hir/static.tcl's batched
# scheduler).
#
#   hir::staticdeps::Deps HIR SITES DECISIONS   => dict
#       sites     key -> the keys of the sites (present as bodies under
#                 DECISIONS) whose form the site's own diagnostics may
#                 depend on, never the site itself
#       channels  the program-wide channels of the build, for the trace
#   hir::staticdeps::Explain DEPS Y Z            why site Y depends on site
#                                                Z: a path, as text
#
# The question
# ------------
# A build of the program (hir::BuildFull) is a pure function of the forms of
# its static sites. hir/static.tcl runs the sequential decision order on one
# build for as long as the build answers it: having rejected site Z without
# building again, it must know which other sites' diagnostics may now
# differ. Those are the sites that *depend* on Z: whose own analysis may
# read a fact Z's form can change. Everything else keeps its diagnostics,
# because nothing it reads changed. This file computes that relation for one
# build, conservatively: a dependency it misses would make the batched
# scheduler commit a decision the sequential order would not; a dependency it
# adds only costs a build. It never decides anything itself.
#
# The graph
# ---------
# Nodes are *regions* (R: a function literal, or the program's top-level
# code), *bindings* (B: the facts of one binding as its readers see them),
# *sites* (Z: a static site present as a body) and *channels* (C: a
# program-wide fact). An edge u -> v says u's facts may depend on v's. A
# site Y depends on Z when Z's node is reachable from Y's.
#
#   Z:site    -> R of the region the site's body stands in (its position: the
#                code before and after it in the same function, which its
#                rejection can make unreachable -- completion and ownership
#                diagnostics are not reported in unreachable code), the site
#                whose body holds it (nested static compile), and its own
#                contract-boundary checks (below).
#   R:region  -> everything its own code mentions (its own code: the region's
#                expressions, not those of the functions defined in it):
#                every binding referenced (B), every function literal in it
#                (R: its summary -- result, errors, contexts, completion
#                facts), every exact call target (R), every candidate of a
#                method-style call (B: the trial builds try each one), every
#                site whose body is in it (Z); its parameters and captures
#                (B); the control operands enclosing its literal in the
#                enclosing functions (conditions, loop operands, handled
#                calls); and, for each captured binding, the narrowing
#                mentions of it in the functions between its definition and
#                this one (a capture is seen with the facts its binding has
#                where the function is defined: an `if integer?(v):` or a
#                `v + 1` before the definition narrows it). A function is
#                *not* made to depend on the rest of its enclosing function:
#                a function's body is analyzed from its own entry, whatever
#                the reachability of the point that defines it, and what it
#                sees of the enclosing code is exactly its captures
#                (tests/static-economics.test pins both).
#   B:binding -> its definition (the bound value's subtree; a loop
#                variable's loop operands; a handler payload's handled call),
#                and the narrowing mentions of it in its own region: a
#                mention's enclosing call (a native's parameter types, a
#                validator's proof narrow it), or the whole statement when the
#                mention is inside a branch, loop or handler (the narrowing
#                after a join depends on every branch's completion).
#
# Backward and program-wide channels -- facts of a function its *callers* or
# the whole program determine:
#
#   untyped parameter   its contract is inferred from every reachable use,
#                       in the function and every function nested in it
#                       (hir/signatures.tcl): B:p -> R of each.
#   shared binding      an affine or mutable value: a use anywhere (a move,
#                       a capture, a mutation through a place) changes what
#                       the others see: B -> R of every region mentioning it.
#   yield type          an unconstrained function's yields are typed by the
#                       coroutines that reach it -- `any` once a
#                       struct-protocol one does (hir/coroutines.tcl): R ->
#                       every construction whose root has a struct protocol
#                       and reaches it over the exact call edges.
#   C:erased            the erased-callable contract (hir::completions::
#                       erasedErrorsOf): what every callable passed into an
#                       untyped parameter can raise. Its *contributors*:
#                       C:erased -> each semantic instance's request whose
#                       arguments at its parameters with no declared or
#                       trusted contract could carry errors (CanCarry: a
#                       callable, or a value holding one -- a rejection only
#                       ever turns a type into `never` or adds errors to a
#                       callable's, so nothing else ever carries any), by
#                       those arguments and the call's own place, up the
#                       chain of requests when the request is itself inside
#                       an instance; each position where a callable with an
#                       uncontracted parameter acquires a structural type
#                       whose argument could carry errors (Contravariant);
#                       and each request the budget declined. Its
#                       *consumers*: R -> C:erased for a region with a call
#                       through an uncontracted value (a callee of type any
#                       or a bare kind, a native calling such an argument),
#                       which has lost both identity precision and contract
#                       precision: the uncontracted erased-callable channel
#                       (VERIFIED-CALLABLE-CONTRACT-BOUNDARY.md). A call
#                       through a verified structural Fn or Coroutine
#                       contract is no consumer (VERIFIED-CALLABLE-CONTRACT-
#                       BOUNDARY.md: the contract bounds it whatever it
#                       holds).
#   C:budget:B          the semantic-instance budget of block B
#                       (hir/semantic.tcl): which call gets one of B's
#                       instances depends on every other call requesting one.
#                       Open only under pressure -- a request declined, or B
#                       holding half its per-block budget -- and then every
#                       call of B is both.
#
# And one channel that is the site's own, never a summary another region
# reads: the contract-boundary checks at the site's positions
# (hir::completions::Subsume) run only in the diagnosing walk of a body and
# only while the program erases something, analyzing a callable there with
# each uncontracted input standing for what it can hold (Possible). So
# Z:site -> C:erased and -> P:input for the inputs of the callables at its
# positions (and the outward finals of a yield in it: every construction
# reaching it); P:input -> what its calls pass in its position (a parameter
# of a function only ever called), its value (a local), or C:erased.
#
# What is not a channel, and why: a demoted trusted contract (hir::check
# keeps the diagnostics of the check before the demotion, so a demotion
# changes no diagnostic); the trait monomorphization (it runs only on a
# program with no diagnostic, and its own diagnostics are internal, never a
# site's); resolution (lexical: a site's own bindings are scoped to it, and
# hir/static.tcl decides every resolution-stage rejection in one build).

namespace eval hir::staticdeps {}

# The dependency analysis of HIR, one build of a program whose static sites
# are SITES (hir::static::Sites, post-order) under DECISIONS (header).
proc hir::staticdeps::Deps {hir sites decisions {methods 0}} {
    set state [Prepare $hir $sites $decisions]
    # With METHODS, the region of every method-style call with several
    # candidates is a root too, and marks what reaches it (M:region).
    set mregions [dict create]
    set mcalls [dict create]
    if {$methods && [dict exists $hir methodCalls]} {
        dict for {key info} [dict get $hir methodCalls] {
            set e [dict get $info expr]
            if {![dict exists $state regionOf $e]} continue
            set q [dict get $state regionOf $e]
            dict set mcalls $key $q
            dict lappend mregions $q $key
        }
    }
    set G [dict create]
    set labels [dict create]
    # Tarjan's strongly connected components over the nodes reachable from
    # the sites, iteratively; the site sets are summed over the condensation
    # in the order the components complete (every successor's first).
    set index [dict create]
    set low [dict create]
    set onStack [dict create]
    set stack {}
    set counter 0
    set sccOf [dict create]
    set sccSites [dict create]
    set sccCount 0
    set roots {}
    foreach key [dict get $state presentKeys] {
        if {[dict exists $state siteHome $key]} {
            lappend roots Z:$key
        }
    }
    foreach q [dict keys $mregions] {
        lappend roots R:$q
    }
    foreach root $roots {
        if {[dict exists $index $root]} continue
        set work [list [list $root 0]]
        while {$work ne {}} {
            lassign [lindex $work end] v i
            if {$i == 0} {
                dict set index $v $counter
                dict set low $v $counter
                incr counter
                lappend stack $v
                dict set onStack $v 1
                if {![dict exists $G $v]} {
                    set succ [Successors $hir state $v]
                    dict set G $v [dict keys $succ]
                    dict set labels $v $succ
                }
            }
            set succs [dict get $G $v]
            set descended 0
            while {$i < [llength $succs]} {
                set w [lindex $succs $i]
                incr i
                if {![dict exists $index $w]} {
                    lset work end [list $v $i]
                    lappend work [list $w 0]
                    set descended 1
                    break
                } elseif {[dict exists $onStack $w]} {
                    if {[dict get $index $w] < [dict get $low $v]} {
                        dict set low $v [dict get $index $w]
                    }
                }
            }
            if {$descended} continue
            # Every successor of V is done.
            lpop work
            if {[dict get $low $v] == [dict get $index $v]} {
                set id $sccCount
                incr sccCount
                set members {}
                while 1 {
                    set w [lpop stack]
                    dict unset onStack $w
                    dict set sccOf $w $id
                    lappend members $w
                    if {$w eq $v} break
                }
                set found [dict create]
                foreach w $members {
                    if {[string match Z:* $w]} {
                        dict set found [string range $w 2 end] 1
                    } elseif {[string match R:* $w] && [dict exists $mregions [string range $w 2 end]]} {
                        dict set found M:[string range $w 2 end] 1
                    }
                    foreach x [dict get $G $w] {
                        set sx [dict get $sccOf $x]
                        if {$sx != $id} {
                            foreach k [dict get $sccSites $sx] {
                                dict set found $k 1
                            }
                        }
                    }
                }
                dict set sccSites $id [dict keys $found]
            }
            if {$work ne {}} {
                set parent [lindex [lindex $work end] 0]
                if {[dict get $low $v] < [dict get $low $parent]} {
                    dict set low $parent [dict get $low $v]
                }
            }
        }
    }
    set result [dict create]
    foreach key [dict get $state presentKeys] {
        if {![dict exists $sccOf Z:$key]} {
            dict set result $key {}
            continue
        }
        dict set result $key [lsearch -all -inline -not -glob \
            [lsearch -all -inline -not -exact [dict get $sccSites [dict get $sccOf Z:$key]] $key] M:*]
    }
    # Per method-style call: the sites and the method-call regions its own
    # region reaches (hir/static.tcl's MethodSeeds).
    set methodCones [dict create]
    dict for {key q} $mcalls {
        set markers [dict get $sccSites [dict get $sccOf R:$q]]
        set calls {}
        foreach m [lsearch -all -inline -glob $markers M:*] {
            lappend calls {*}[dict get $mregions [string range $m 2 end]]
        }
        dict set methodCones $key [dict create sites [lsearch -all -inline -not -glob $markers M:*] \
            calls [lsort -unique $calls]]
    }
    # Per site, the smallest expression number in its span: every expression
    # numbered below it is numbered the same whatever the site's form (ids
    # are allocated in one walk of the program, hir::NewId).
    set firstIds [dict create]
    dict for {site exprs} [expr {[dict exists $state siteExprs] ? [dict get $state siteExprs] : {}}] {
        set min ""
        foreach e $exprs {
            set n [string range $e 1 end]
            if {$min eq "" || $n < $min} {
                set min $n
            }
        }
        dict set firstIds $site $min
    }
    return [dict create sites $result channels [dict get $state channels] \
        labels $labels names [dict get $state names] nodes [dict size $G] methods $methodCones \
        firstIds $firstIds]
}

# A path of DEPS's graph from site Y's node to site Z's, as text: each step's
# edge label and the node it reaches (Deps' header names the labels).
proc hir::staticdeps::Explain {deps y z} {
    set labels [dict get $deps labels]
    set from [dict create Z:$y ""]
    set queue [list Z:$y]
    set target Z:$z
    while {$queue ne {}} {
        set v [lindex $queue 0]
        set queue [lrange $queue 1 end]
        if {$v eq $target} break
        if {![dict exists $labels $v]} continue
        dict for {w label} [dict get $labels $v] {
            if {![dict exists $from $w]} {
                dict set from $w [list $v $label]
                lappend queue $w
            }
        }
    }
    if {![dict exists $from $target]} {
        return "no path"
    }
    set steps {}
    set v $target
    while {[dict get $from $v] ne ""} {
        lassign [dict get $from $v] u label
        set steps [linsert $steps 0 "$label [Name $deps $v]"]
        set v $u
    }
    return [join $steps " -> "]
}

proc hir::staticdeps::Name {deps node} {
    if {[dict exists $deps names $node]} {
        return [dict get $deps names $node]
    }
    return $node
}

# ---------------------------------------------------------------------------
# The walk: what the successors are computed from

# The facts of HIR the graph is built from, as a dict (one walk of the
# program and of every function body).
proc hir::staticdeps::Prepare {hir sites decisions} {
    set present {}
    foreach site $sites {
        set key [dict get $site key]
        if {[dict exists $decisions $key] && [lindex [dict get $decisions $key] 0] eq "rejected"} continue
        lappend present $site
    }
    # Site spans by file, sorted by start; the enclosing present site of each.
    set byFile [dict create]
    foreach site $present {
        set origin [dict get $site origin]
        dict lappend byFile [dict get $origin file] \
            [list [dict get $origin start] [dict get $origin end] [dict get $site key]]
    }
    set spanParent [dict create]
    dict for {file spans} $byFile {
        set spans [lsort -command hir::staticdeps::SpanOrder $spans]
        dict set byFile $file $spans
        set open {}
        foreach span $spans {
            lassign $span start end key
            while {$open ne {} && [lindex $open end 1] < $start} {
                set open [lrange $open 0 end-1]
            }
            dict set spanParent $key [expr {$open eq {} ? "" : [lindex $open end 2]}]
            lappend open $span
        }
    }
    set state [dict create byFile $byFile spanParent $spanParent \
        presentKeys [lmap site $present {dict get $site key}] \
        regionOf {} parentOf {} litRegion {} ownRefs {} ownLits {} ownTargets {} \
        ownSites {} ownCalls {} siteHome {} siteDepth {} depth {program 0} mentions {} \
        subtree {} names {} paramOwner {} children {} channels {}]
    # The walk: every expression's region and parent; per region the
    # bindings, literals, call targets and sites its own code mentions.
    set regionOf [dict create]
    set parentOf [dict create]
    set litRegion [dict create]
    set depth [dict create program 0]
    set siteOf [dict create]
    set stack {}
    foreach r [lreverse [dict get $hir roots]] {
        lappend stack [list $r program ""]
    }
    set exprs [dict get $hir exprs]
    while {$stack ne {}} {
        lassign [lpop stack] e region parent
        if {[dict exists $regionOf $e] || ![dict exists $exprs $e]} continue
        dict set regionOf $e $region
        dict set parentOf $e $parent
        set node [dict get $exprs $e]
        set site [SiteAt $byFile $spanParent [dict get $node origin]]
        if {$site ne ""} {
            dict set siteOf $e $site
            dict lappend state siteExprs $site $e
            dict set state ownSites $region $site 1
            set d [dict get $depth $region]
            if {![dict exists $state siteDepth $site] || $d < [dict get $state siteDepth $site]} {
                dict set state siteDepth $site $d
                dict set state siteHome $site $region
            }
        }
        switch -- [dict get $node kind] {
            block {
                dict set litRegion $e $region
                dict set state ownLits $region $e 1
                dict set depth $e [expr {[dict get $depth $region] + 1}]
                dict lappend state children $region $e
                set i 0
                foreach p [dict get $node params] {
                    dict set state paramOwner $p [list block $e $i]
                    incr i
                }
                foreach b [lreverse [dict get $node body]] {
                    lappend stack [list $b $e ""]
                }
                continue
            }
            ref {
                set b [dict get $node binding]
                if {$b ne "" && [dict get $hir bindings $b kind] ne "root"} {
                    dict set state ownRefs $region $b 1
                    dict lappend state mentions $b $e
                }
            }
            call {
                lassign [dict get $node target] tk tb
                if {$tk eq "block"} {
                    dict set state ownTargets $region $tb 1
                }
                dict lappend state ownCalls $region $e
            }
            listloop {
                dict set state paramOwner [dict get $node elementBinding] [list loop $e]
            }
            countloop {
                dict set state paramOwner [dict get $node countBinding] [list loop $e]
            }
            lockloop {
                foreach domain [dict get $node domains] {
                    foreach field {binding elementBinding countBinding} {
                        if {[dict exists $domain $field] && [dict get $domain $field] ne ""} {
                            dict set state paramOwner [dict get $domain $field] [list loop $e]
                        }
                    }
                }
            }
            handle {
                foreach payload [dict get $node handlerPayloads] {
                    foreach b $payload {
                        if {$b ne "" && [dict exists $hir bindings $b]} {
                            dict set state paramOwner $b [list handle $e]
                        }
                    }
                }
            }
        }
        foreach c [lreverse [hir::children $hir $e]] {
            lappend stack [list $c $region $e]
        }
    }
    dict set state regionOf $regionOf
    dict set state parentOf $parentOf
    dict set state litRegion $litRegion
    dict set state depth $depth
    dict set state siteOf $siteOf
    # The region of each scope: where the bindings it holds live.
    set scopeRegion [dict create]
    dict for {e region} $regionOf {
        set s [dict get $exprs $e scope]
        if {![dict exists $scopeRegion $s]} {
            dict set scopeRegion $s $region
        }
        if {[dict get $exprs $e kind] eq "block"} {
            dict set scopeRegion [dict get $exprs $e bodyScope] $e
        }
    }
    dict set state scopeRegion $scopeRegion
    # Method-style calls: every candidate of a call with several (the trial
    # builds resolve the call to each in turn).
    set candidates [dict create]
    if {[dict exists $hir methodCalls]} {
        dict for {key info} [dict get $hir methodCalls] {
            set e [dict get $info expr]
            if {![dict exists $regionOf $e]} continue
            foreach display [dict get $info candidates] {
                set b [CandidateBinding $hir $e $display]
                if {$b ne ""} {
                    dict set candidates $e $b 1
                }
            }
        }
    }
    dict set state candidates $candidates
    # Functions used as values (some reference is not a callee): their
    # uncontracted parameters are checked against the erased-callable
    # contract, never against their calls' arguments (hir::completions::
    # PossibleOf).
    set definedBy [dict create]
    set callees [dict create]
    set callsOf [dict create]
    set creates {}
    set yielding [dict create]
    set callEdges [dict create]
    dict for {e region} $regionOf {
        set node [dict get $exprs $e]
        switch -- [dict get $node kind] {
            bind {
                set v [dict get $node value]
                if {$v ne "" && [dict exists $exprs $v] && [dict get $exprs $v kind] eq "block"} {
                    dict set definedBy $v [dict get $node binding]
                }
            }
            call {
                dict set callees [dict get $node callee] 1
                lassign [dict get $node target] tk tb
                if {$tk eq "block"} {
                    dict lappend callsOf $tb $e
                    dict set callEdges $region $tb 1
                }
                switch -- [hir::coroutines::NativeOf $hir $e] {
                    coroutine#create { lappend creates $e }
                    coroutine#yield { dict set yielding $region 1 }
                }
            }
        }
    }
    set escaping [dict create]
    dict for {e region} $regionOf {
        set node [dict get $exprs $e]
        if {[dict get $node kind] eq "ref" && ![dict exists $callees $e] && [dict get $node binding] ne ""} {
            dict set escaping [dict get $node binding] 1
        }
    }
    dict set state definedBy $definedBy
    dict set state escaping $escaping
    dict set state callsOf $callsOf
    # Yields: the coroutine constructions whose root reaches each yielding
    # function over the exact call edges (yieldAll: the outward types a
    # yield's value lands in, hir::completions::YieldFinalsOf), and among
    # them those whose root has a struct protocol, which alone decide the
    # type of an unconstrained function's yields (yieldStruct: `any` once
    # one reaches it, else `unit`; hir/coroutines.tcl's analyze).
    set table [expr {[dict exists $hir coroutines blocks] ? [dict get $hir coroutines blocks] : {}}]
    set yieldAll [dict create]
    set yieldStruct [dict create]
    foreach c $creates {
        set root [CreateRoot $hir $c]
        set struct 1
        if {$root ne "" && [dict exists $table $root]} {
            set struct [hir::coroutines::IsStructProtocol \
                [hir::coroutines::Resolved [dict get $table $root protocol]]]
        }
        if {$root eq ""} {
            # A construction whose root is unknown: every yield may be
            # reached by it.
            set reached [dict keys $yielding]
        } else {
            set reached {}
            set seen [dict create]
            set work [list $root]
            while {$work ne {}} {
                set b [lpop work]
                if {[dict exists $seen $b]} continue
                dict set seen $b 1
                if {[dict exists $yielding $b]} {
                    lappend reached $b
                }
                if {[dict exists $callEdges $b]} {
                    lappend work {*}[dict keys [dict get $callEdges $b]]
                }
            }
        }
        foreach q $reached {
            dict lappend yieldAll $q $c
            if {$struct && (![dict exists $table $q] || [dict get $table $q protocol] eq "none")} {
                dict lappend yieldStruct $q $c
            }
        }
    }
    dict set state yieldAll $yieldAll
    dict set state yieldStruct $yieldStruct
    # The erased-callable contract (hir::completions::erasedErrorsOf): what
    # the program's erasures carry, and the regions that consume it.
    set points {}
    set consumers [dict create]
    dict for {e region} $regionOf {
        set node [dict get $exprs $e]
        if {[dict get $node kind] ne "call"} continue
        lassign [dict get $node target] tk tb
        set args [dict get $node args]
        if {$tk eq "native"} {
            set from [dict get [core::native::metadata [dict get $hir symbols $tb name]] errorsFrom]
            if {$from ne "" && $from < [llength $args]
                    && [hir::completions::Uncontracted [hir::typeOf $hir [lindex $args $from]]]} {
                dict set consumers $region 1
            }
        }
        if {[hir::completions::Uncontracted [hir::typeOf $hir [dict get $node callee]]]} {
            dict set consumers $region 1
        }
    }
    # Its contributors. A semantic instance erases what its arguments at
    # untyped parameters carry: an instance one of whose arguments there could
    # carry errors (a callable, or a value holding one: CanCarry -- a value of
    # any other type never carries any, whatever the sites become) depends on
    # the calls that requested it, and on theirs when the requesting call is
    # itself inside an instance.
    if {[dict exists $hir semantic instances]} {
        set requests [dict create]
        dict for {callKey id} [dict get $hir semantic calls] {
            dict lappend requests $id $callKey
        }
        dict for {id inst} [dict get $hir semantic instances] {
            set block [dict get $inst block]
            if {![dict exists $exprs $block]} continue
            set carries 0
            foreach entry [hir::signatures::entryTypes $hir $block] type [dict get $inst args] {
                if {$entry eq "" && [CanCarry $hir $type]} {
                    set carries 1
                }
            }
            if {!$carries} continue
            set work [list $id]
            set seen [dict create]
            while {$work ne {}} {
                set i [lpop work]
                if {[dict exists $seen $i] || ![dict exists $requests $i]} continue
                dict set seen $i 1
                foreach callKey [dict get $requests $i] {
                    lassign $callKey caller call
                    if {[dict exists $regionOf $call]} {
                        # The call's key is its arguments at the parameters
                        # with no declared or trusted contract; the call
                        # itself exists where it is written.
                        lappend points [list key $call]
                    }
                    if {$caller ne "generic"} {
                        lappend work $caller
                    }
                }
            }
        }
        # A request the budget declined may be granted once a site is
        # rejected: one that could carry errors is a potential contributor.
        dict for {callKey reason} [dict get $hir semantic declined] {
            set call [lindex $callKey 1]
            if {![dict exists $regionOf $call]} continue
            foreach arg [dict get $exprs $call args] {
                if {[CanCarry $hir [hir::typeOf $hir $arg]]} {
                    lappend points [list key $call]
                    break
                }
            }
        }
    }
    # Contravariant erasure: a callable with an uncontracted parameter whose
    # value acquires a structural Fn type there erases what that type's
    # argument carries (hir::completions::Contravariant), at the positions
    # hir::completions::Positions names and at a function's trailing value.
    if {[hir::completions::HasFnTypes $hir]} {
        set finals [hir::completions::YieldFinalsOf $hir]
        dict for {e region} $regionOf {
            set pairs [hir::completions::Positions $hir $e $finals]
            set node [dict get $exprs $e]
            if {[dict get $node kind] eq "block" && [dict get $node body] ne {}} {
                lappend pairs [list [lindex [dict get $node body] end] [hir::completions::ResultFinal $hir $e]]
            }
            foreach pair $pairs {
                lassign $pair value final
                if {$value eq "" || $final eq "" || ![dict exists $exprs $value]} continue
                foreach triple [hir::completions::Align [hir::typeOf $hir $value] $final] {
                    lassign $triple source target
                    set i 0
                    foreach arg [hir::types::FnArgs $target] {
                        if {[hir::completions::ParamUncontracted $hir $source $i] && [CanCarry $hir $arg]} {
                            lappend points [list all $value] [list all $e]
                            break
                        }
                        incr i
                    }
                }
            }
        }
    }
    dict set state erasurePoints $points
    dict set state erasedConsumers $consumers
    # The semantic-instance budget: the blocks under pressure.
    set pressured [dict create]
    set global 0
    if {[dict exists $hir semantic byBlock]} {
        set half [expr {$::hir::semantic::maxPerBlock / 2}]
        set total 0
        dict for {b n} [dict get $hir semantic byBlock] {
            incr total $n
            if {$n >= $half} {
                dict set pressured $b 1
            }
        }
        if {$total >= $::hir::semantic::maxInstances / 2} {
            set global 1
        }
        dict for {callKey reason} [dict get $hir semantic declined] {
            if {$reason in {budget-total nesting}} {
                set global 1
            } elseif {$reason eq "budget-block"} {
                set e [lindex $callKey 1]
                if {[dict exists $exprs $e target] && [lindex [dict get $exprs $e target] 0] eq "block"} {
                    dict set pressured [lindex [dict get $exprs $e target] 1] 1
                } else {
                    set global 1
                }
            }
        }
    }
    if {$global} {
        dict for {b _} $callsOf {
            dict set pressured $b 1
        }
    }
    set budgetOf [dict create]
    dict for {b _} $pressured {
        if {![dict exists $callsOf $b]} continue
        foreach call [dict get $callsOf $b] {
            dict set budgetOf [dict get $regionOf $call] $b 1
        }
    }
    dict set state pressured $pressured
    dict set state budgetOf $budgetOf
    dict set state channels [dict create erasurePoints [llength $points] \
        erasedConsumers [dict size $consumers] budgetPressure [dict size $pressured] \
        yieldingFunctions [dict size $yielding] constructions [llength $creates]]
    return $state
}

# lsort comparison of two spans {START END KEY}: by start, the enclosing one
# (the longer) first.
proc hir::staticdeps::SpanOrder {a b} {
    set d [expr {[lindex $a 0] - [lindex $b 0]}]
    if {$d != 0} {
        return [expr {$d < 0 ? -1 : 1}]
    }
    return [expr {[lindex $b 1] - [lindex $a 1] < 0 ? -1 : ([lindex $b 1] == [lindex $a 1] ? 0 : 1)}]
}

# The key of the innermost present site (BYFILE, SPANPARENT: Prepare) whose
# span holds the start of source ORIGIN, or "".
proc hir::staticdeps::SiteAt {byFile spanParent origin} {
    if {[lindex $origin 0] ne "file"} {
        return ""
    }
    set file [dict get $origin file]
    if {![dict exists $byFile $file]} {
        return ""
    }
    set at [dict get $origin start]
    set spans [dict get $byFile $file]
    # The last span starting at or before AT.
    set lo 0
    set hi [expr {[llength $spans] - 1}]
    set found -1
    while {$lo <= $hi} {
        set mid [expr {($lo + $hi) / 2}]
        if {[lindex $spans $mid 0] <= $at} {
            set found $mid
            set lo [expr {$mid + 1}]
        } else {
            set hi [expr {$mid - 1}]
        }
    }
    if {$found < 0} {
        return ""
    }
    set key [lindex $spans $found 2]
    set end [lindex $spans $found 1]
    while {$key ne ""} {
        if {$at <= $end} {
            return $key
        }
        set key [dict get $spanParent $key]
        if {$key ne ""} {
            set end [lindex [lsearch -inline -index 2 -exact $spans $key] 1]
        }
    }
    return ""
}

# The binding a method-style call E's candidate DISPLAY denotes: a module
# member (NS::NAME) or the lexical binding of NAME visible at E; "" for a
# native.
proc hir::staticdeps::CandidateBinding {hir e display} {
    set idx [string last :: $display]
    if {$idx > 0} {
        set ns [string range $display 0 [expr {$idx - 1}]]
        set name [string range $display [expr {$idx + 2}] end]
        if {[dict exists $hir modules $ns]} {
            set scope [dict get $hir modules $ns]
            if {[dict exists $hir scopes $scope names $name]} {
                set b [dict get $hir scopes $scope names $name]
                return [expr {[dict get $hir bindings $b kind] eq "root" ? "" : $b}]
            }
        }
        return ""
    }
    set s [dict get $hir exprs $e scope]
    while {$s ne "" && [dict exists $hir scopes $s]} {
        if {[dict exists $hir scopes $s names $display]} {
            set b [dict get $hir scopes $s names $display]
            return [expr {[dict get $hir bindings $b kind] eq "root" ? "" : $b}]
        }
        set s [dict get $hir scopes $s parent]
    }
    return ""
}

# The root function of the coroutine construction CREATE (a call of
# coroutine#create whose argument is the thunk): the exact target of the
# thunk's call, or "".
proc hir::staticdeps::CreateRoot {hir create} {
    set thunk [lindex [dict get $hir exprs $create args] 0]
    if {$thunk eq "" || [dict get $hir exprs $thunk kind] ne "block"} {
        return ""
    }
    foreach e [dict get $hir exprs $thunk body] {
        set stack [list $e]
        while {$stack ne {}} {
            set x [lpop stack]
            set node [dict get $hir exprs $x]
            if {[dict get $node kind] eq "call" && [lindex [dict get $node target] 0] eq "block"} {
                return [lindex [dict get $node target] 1]
            }
            if {[dict get $node kind] ne "block"} {
                lappend stack {*}[hir::children $hir $x]
            }
        }
    }
    return ""
}

# ---------------------------------------------------------------------------
# Successors

# The successors of node V (header): a dict successor -> edge label.
proc hir::staticdeps::Successors {hir stateVar v} {
    upvar 1 $stateVar state
    set succ [dict create]
    switch -glob -- $v {
        Z:* {
            set key [string range $v 2 end]
            dict set state names $v "site [SiteName $hir $key]"
            if {[dict exists $state siteHome $key]} {
                dict set succ R:[dict get $state siteHome $key] position
            }
            set outer [dict get $state spanParent $key]
            if {$outer ne ""} {
                dict set succ Z:$outer nested
            }
            SubsumeSuccessors $hir state $key succ
        }
        P:* {
            PossibleSuccessors $hir state [string range $v 2 end] succ
        }
        R:* {
            RegionSuccessors $hir state [string range $v 2 end] succ
        }
        B:* {
            BindingSuccessors $hir state [string range $v 2 end] succ
        }
        C:erased {
            dict set state names $v "the erased-callable contract"
            foreach point [lsort -unique [dict get $state erasurePoints]] {
                lassign $point how e
                if {$how eq "all"} {
                    AddSubtree $hir state $e succ erasure
                    continue
                }
                # A semantic instance's request: the arguments its key is
                # made of, and the sites the call is written in.
                if {[dict exists $state siteOf $e]} {
                    dict set succ Z:[dict get $state siteOf $e] erasure
                }
                lassign [dict get $hir exprs $e target] tk tb
                set args [dict get $hir exprs $e args]
                if {$tk ne "block" || ![dict exists $hir exprs $tb]} {
                    foreach arg $args {
                        AddSubtree $hir state $arg succ erasure
                    }
                    continue
                }
                dict set succ R:$tb erasure
                foreach entry [hir::signatures::entryTypes $hir $tb] arg $args {
                    if {$entry eq "" && $arg ne ""} {
                        AddSubtree $hir state $arg succ erasure
                    }
                }
            }
        }
        C:budget:* {
            set b [string range $v 9 end]
            dict set state names $v "the semantic-instance budget of [BlockName $hir $b]"
            foreach call [dict get $state callsOf $b] {
                AddSubtree $hir state $call succ budget
            }
        }
    }
    dict unset succ $v
    return $succ
}

# The contract-boundary checks of site KEY's own code (hir::completions::
# Subsume): at every position where a callable value acquires a structural
# type, its body is analyzed with each uncontracted input standing for what
# it can hold (Possible) -- only while the program's erased-callable
# contract is not empty, and only in the walk that reports the site's own
# diagnostics (never a summary another region reads). So the site depends
# on that contract and on the Possible of those inputs (P:).
proc hir::staticdeps::SubsumeSuccessors {hir stateVar key succVar} {
    upvar 1 $stateVar state $succVar succ
    set exprs {}
    foreach site [concat [list $key] [NestedSites $state $key]] {
        if {[dict exists $state siteExprs $site]} {
            lappend exprs {*}[dict get $state siteExprs $site]
        }
    }
    if {![dict exists $state finals]} {
        dict set state finals [expr {[hir::completions::HasFnTypes $hir] ? [hir::completions::YieldFinalsOf $hir] : {}}]
    }
    set finals [dict get $state finals]
    foreach e $exprs {
        set node [dict get $hir exprs $e]
        if {[dict exists $finals $e]} {
            # A yield: the outward type its value lands in is every reaching
            # coroutine's.
            set q [dict get $state regionOf $e]
            if {[dict exists $state yieldAll $q]} {
                foreach c [dict get $state yieldAll $q] {
                    AddSubtree $hir state $c succ yield-final
                }
            }
        }
        set pairs [hir::completions::Positions $hir $e $finals]
        if {[dict get $node kind] eq "block" && [dict get $node body] ne {}} {
            lappend pairs [list [lindex [dict get $node body] end] [hir::completions::ResultFinal $hir $e]]
        }
        foreach pair $pairs {
            set value [lindex $pair 0]
            if {$value eq "" || ![dict exists $hir exprs $value]} continue
            set type [hir::typeOf $hir $value]
            if {[hir::types::IsCoroutine $type]} {
                dict set succ C:erased subsume
                set thunk [hir::coroutines::thunkOfHandle $hir $value]
                if {$thunk ne ""} {
                    foreach c [dict get $hir exprs $thunk captures] {
                        dict set succ P:$c subsume
                    }
                }
                continue
            }
            if {[lindex $pair 1] eq ""} continue
            foreach triple [hir::completions::Align $type [lindex $pair 1]] {
                set source [lindex $triple 0]
                dict set succ C:erased subsume
                if {[hir::types::IsExactBlock $source] && [dict exists $hir exprs [lindex $source 1]]} {
                    set block [dict get $hir exprs [lindex $source 1]]
                    foreach b [concat [dict get $block params] [dict get $block captures]] {
                        dict set succ P:$b subsume
                    }
                }
            }
        }
    }
}

# The sites nested, at any depth, in site KEY's body (present ones).
proc hir::staticdeps::NestedSites {state key} {
    set result {}
    dict for {site parent} [dict get $state spanParent] {
        set p $parent
        while {$p ne ""} {
            if {$p eq $key} {
                lappend result $site
                break
            }
            set p [dict get $state spanParent $p]
        }
    }
    return $result
}

# What an uncontracted input B may hold at the contract boundary
# (hir::completions::PossibleOf): a parameter of a function only ever called,
# what its calls pass in its position; a local, what it is bound to; anything
# else (a parameter of a function used as a value, a loop or handler
# binding), the erased-callable contract. Only a value that may carry errors
# matters (CanCarry); one that is itself an uncontracted input holds that
# input's Possible.
proc hir::staticdeps::PossibleSuccessors {hir stateVar b succVar} {
    upvar 1 $stateVar state $succVar succ
    dict set state names P:$b "what [dict get $hir bindings $b name] may hold"
    if {![hir::completions::CleanInput $hir $b]} {
        return
    }
    set binding [dict get $hir bindings $b]
    set by [dict get $binding declaredBy]
    set owner [expr {[dict exists $state paramOwner $b] ? [dict get $state paramOwner $b] : ""}]
    set values {}
    if {[lindex $owner 0] eq "block"} {
        lassign $owner _ block i
        set definer [expr {[dict exists $state definedBy $block] ? [dict get $state definedBy $block] : ""}]
        if {$definer eq "" || [dict exists $state escaping $definer]} {
            dict set succ C:erased possible
            return
        }
        if {[dict exists $state callsOf $block]} {
            foreach call [dict get $state callsOf $block] {
                set arg [lindex [dict get $hir exprs $call args] $i]
                if {$arg ne ""} {
                    lappend values $arg
                }
            }
        }
    } elseif {$by ne "" && [dict exists $hir exprs $by] && [dict get $hir exprs $by kind] eq "bind"
            && [dict get $hir exprs $by value] ne ""} {
        lappend values [dict get $hir exprs $by value]
    } else {
        dict set succ C:erased possible
        return
    }
    foreach value $values {
        set type [hir::typeOf $hir $value]
        if {[CanCarry $hir $type]} {
            AddSubtree $hir state $value succ possible
            if {[hir::types::IsExactBlock $type] && [dict exists $hir exprs [lindex $type 1]]} {
                foreach c [dict get $hir exprs [lindex $type 1] captures] {
                    dict set succ P:$c possible
                }
            }
        } elseif {[hir::completions::Uncontracted $type]} {
            # An uncontracted value: the input a reference reads, else the
            # erased-callable contract.
            set node [dict get $hir exprs $value]
            if {[dict get $node kind] eq "ref" && [dict get $node binding] ne ""
                    && [dict get $hir bindings [dict get $node binding] kind] ne "root"} {
                dict set succ P:[dict get $node binding] possible
            } else {
                dict set succ C:erased possible
            }
        }
    }
}

proc hir::staticdeps::RegionSuccessors {hir stateVar q succVar} {
    upvar 1 $stateVar state $succVar succ
    dict set state names R:$q [expr {$q eq "program" ? "the top-level code" : "function [BlockName $hir $q]"}]
    foreach {field label prefix} {ownRefs mentions B: ownLits defines R: ownTargets calls R: ownSites holds Z:} {
        if {[dict exists $state $field $q]} {
            foreach x [dict keys [dict get $state $field $q]] {
                if {![dict exists $succ $prefix$x]} {
                    dict set succ $prefix$x $label
                }
            }
        }
    }
    if {[dict exists $state ownCalls $q]} {
        foreach call [dict get $state ownCalls $q] {
            if {[dict exists $state candidates $call]} {
                foreach b [dict keys [dict get $state candidates $call]] {
                    if {![dict exists $succ B:$b]} {
                        dict set succ B:$b method-candidate
                    }
                }
            }
        }
    }
    if {[dict exists $state erasedConsumers $q]} {
        dict set succ C:erased erased-consumer
    }
    if {[dict exists $state budgetOf $q]} {
        foreach b [dict keys [dict get $state budgetOf $q]] {
            dict set succ C:budget:$b budget
        }
    }
    if {$q eq "program"} {
        return
    }
    set node [dict get $hir exprs $q]
    foreach p [dict get $node params] {
        dict set succ B:$p parameter
    }
    foreach c [dict get $node captures] {
        if {![dict exists $succ B:$c]} {
            dict set succ B:$c capture
        }
    }
    # Where it is defined: the control operands around its literal, in every
    # enclosing function up to the program.
    set literal $q
    while {[dict exists $state litRegion $literal]} {
        set region [dict get $state litRegion $literal]
        set x $literal
        while {[set parent [dict get $state parentOf $x]] ne ""} {
            foreach operand [ControlOperands $hir $parent $x] {
                AddSubtree $hir state $operand succ context
            }
            set x $parent
        }
        if {$region eq "program"} break
        set literal $region
    }
    # The narrowing mentions of each capture in the functions between its
    # binding's region and this one.
    foreach c [dict get $node captures] {
        set home [BindingRegion $hir state $c]
        set region [dict get $state litRegion $q]
        while {$region ne $home && $region ne "program" && $region ne ""} {
            if {[dict exists $state mentions $c]} {
                foreach r [dict get $state mentions $c] {
                    if {[dict get $state regionOf $r] eq $region} {
                        AddNarrowing $hir state $r succ capture-narrowing
                    }
                }
            }
            set region [expr {[dict exists $state litRegion $region] ? [dict get $state litRegion $region] : ""}]
        }
    }
    if {[dict exists $state yieldStruct $q]} {
        foreach c [dict get $state yieldStruct $q] {
            AddSubtree $hir state $c succ yield-type
        }
    }
}

proc hir::staticdeps::BindingSuccessors {hir stateVar b succVar} {
    upvar 1 $stateVar state $succVar succ
    set binding [dict get $hir bindings $b]
    dict set state names B:$b "binding [dict get $binding name]"
    set region [BindingRegion $hir state $b]
    set by [dict get $binding declaredBy]
    set owner [expr {[dict exists $state paramOwner $b] ? [dict get $state paramOwner $b] : ""}]
    if {$by ne "" && [dict exists $hir exprs $by]} {
        set node [dict get $hir exprs $by]
        if {[dict get $node kind] eq "bind" && [dict get $node value] ne ""} {
            set value [dict get $node value]
            AddSubtree $hir state $value succ definition
            if {[dict exists $hir exprs $value] && [dict get $hir exprs $value kind] eq "ref"
                    && [dict get $hir exprs $value binding] ne ""} {
                # An alias: a use of either is a use of the one value.
                set c [dict get $hir exprs $value binding]
                if {[dict get $hir bindings $c kind] ne "root"} {
                    dict set succ B:$c alias
                    dict set state aliasOf $c $b 1
                }
            }
        } else {
            AddSubtree $hir state $by succ definition
        }
    } elseif {[lindex $owner 0] eq "block"} {
        lassign $owner _ block i
        if {[lindex [dict get $hir exprs $block declaredParamTypes] $i] eq ""} {
            # An untyped parameter: its contract is inferred from every
            # reachable use, in the function and the functions in it.
            foreach r [Descendants $state $block] {
                dict set succ R:$r untyped-parameter
            }
        }
    } elseif {[lindex $owner 0] eq "loop"} {
        foreach operand [hir::children $hir [lindex $owner 1]] {
            if {[dict get $hir exprs $operand kind] eq "block"} continue
            if {$operand in [LoopBody $hir [lindex $owner 1]]} continue
            AddSubtree $hir state $operand succ definition
        }
    } elseif {[lindex $owner 0] eq "handle"} {
        AddSubtree $hir state [dict get $hir exprs [lindex $owner 1] call] succ definition
    } elseif {$region ne ""} {
        dict set succ R:$region binding
    }
    if {[dict exists $state aliasOf $b]} {
        foreach a [dict keys [dict get $state aliasOf $b]] {
            dict set succ B:$a alias
        }
    }
    if {![dict exists $state mentions $b]} {
        return
    }
    set type [hir::bindingType $hir $b]
    set shared [expr {[hir::types::IsAffine $type] || [MentionsMutable $type]}]
    foreach r [dict get $state mentions $b] {
        set at [dict get $state regionOf $r]
        if {$at eq $region} {
            AddNarrowing $hir state $r succ narrowing
        } elseif {$shared} {
            dict set succ R:$at shared
        }
    }
}

# The region (Prepare) binding B lives in: the region of its declaration, of
# the function whose parameter it is, of the loop or handler that binds it,
# else of its scope; "" if none is known.
proc hir::staticdeps::BindingRegion {hir stateVar b} {
    upvar 1 $stateVar state
    if {[dict exists $state bindingRegion $b]} {
        return [dict get $state bindingRegion $b]
    }
    set binding [dict get $hir bindings $b]
    set by [dict get $binding declaredBy]
    set region ""
    if {$by ne "" && [dict exists $state regionOf $by]} {
        set region [dict get $state regionOf $by]
    } elseif {[dict exists $state paramOwner $b]} {
        set owner [dict get $state paramOwner $b]
        if {[lindex $owner 0] eq "block"} {
            set region [lindex $owner 1]
        } elseif {[dict exists $state regionOf [lindex $owner 1]]} {
            set region [dict get $state regionOf [lindex $owner 1]]
        }
    } elseif {[dict exists $state scopeRegion [dict get $binding scope]]} {
        set region [dict get $state scopeRegion [dict get $binding scope]]
    }
    dict set state bindingRegion $b $region
    return $region
}

# Region Q and every function literal nested in it, at any depth.
proc hir::staticdeps::Descendants {state q} {
    set result {}
    set work [list $q]
    while {$work ne {}} {
        set r [lpop work]
        lappend result $r
        if {[dict exists $state children $r]} {
            lappend work {*}[dict get $state children $r]
        }
    }
    return $result
}

# The body expressions of loop expression E.
proc hir::staticdeps::LoopBody {hir e} {
    return [dict get $hir exprs $e body]
}

# The operands of control expression PARENT that decide whether, or how
# often, its child CHILD runs, when CHILD is in one of its branches or
# bodies: an `if`'s condition, a loop's operands, a handled call.
proc hir::staticdeps::ControlOperands {hir parent child} {
    set node [dict get $hir exprs $parent]
    switch -- [dict get $node kind] {
        if {
            set condition [dict get $node condition]
            return [expr {$child eq $condition ? {} : [list $condition]}]
        }
        listloop {
            set iterable [dict get $node iterable]
            return [expr {$child eq $iterable ? {} : [list $iterable]}]
        }
        countloop {
            if {$child in [list [dict get $node start] [dict get $node end]]} {
                return {}
            }
            return [list [dict get $node start] [dict get $node end]]
        }
        lockloop {
            set operands [hir::loopOperands $node]
            return [expr {$child in $operands ? {} : $operands}]
        }
        handle {
            set call [dict get $node call]
            return [expr {$child eq $call ? {} : [list $call]}]
        }
    }
    return {}
}

# Adds to the caller's SUCCVAR what a mention R of a binding narrows it by
# (header, B:binding): its enclosing call or projection, or, when the mention
# is inside a branch, loop or handler of its function, the whole statement.
proc hir::staticdeps::AddNarrowing {hir stateVar r succVar label} {
    upvar 1 $stateVar state $succVar succ
    set parentOf [dict get $state parentOf]
    set x $r
    set controlled 0
    while {[set parent [dict get $parentOf $x]] ne ""} {
        if {[dict get $hir exprs $parent kind] in {if loop listloop countloop lockloop handle}} {
            set controlled 1
        }
        set x $parent
    }
    if {$controlled} {
        AddSubtree $hir state $x succ $label
        return
    }
    set parent [dict get $parentOf $r]
    if {$parent eq "" || [dict get $hir exprs $parent kind] eq "bind"} {
        # A statement of its own, or an alias's value (the alias edge).
        if {[dict exists $state siteOf $r]} {
            dict set succ Z:[dict get $state siteOf $r] $label
        }
        return
    }
    AddSubtree $hir state $parent succ $label
}

# Adds to the caller's SUCCVAR every node expression E's subtree depends on
# (not entering the bodies of the functions it defines: their literals are
# their summaries): the bindings it references, its function literals, its
# exact call targets, the candidates of its method-style calls, the sites
# its expressions belong to.
proc hir::staticdeps::AddSubtree {hir stateVar e succVar label} {
    upvar 1 $stateVar state $succVar succ
    if {![dict exists $state subtree $e]} {
        set nodes [dict create]
        set stack [list $e]
        while {$stack ne {}} {
            set x [lpop stack]
            if {![dict exists $hir exprs $x]} continue
            set node [dict get $hir exprs $x]
            if {[dict exists $state siteOf $x]} {
                dict set nodes Z:[dict get $state siteOf $x] 1
            }
            switch -- [dict get $node kind] {
                block {
                    dict set nodes R:$x 1
                    continue
                }
                ref {
                    set b [dict get $node binding]
                    if {$b ne "" && [dict get $hir bindings $b kind] ne "root"} {
                        dict set nodes B:$b 1
                    }
                }
                call {
                    lassign [dict get $node target] tk tb
                    if {$tk eq "block"} {
                        dict set nodes R:$tb 1
                    }
                    if {[dict exists $state candidates $x]} {
                        foreach b [dict keys [dict get $state candidates $x]] {
                            dict set nodes B:$b 1
                        }
                    }
                }
            }
            lappend stack {*}[hir::children $hir $x]
        }
        dict set state subtree $e [dict keys $nodes]
    }
    foreach n [dict get $state subtree $e] {
        if {![dict exists $succ $n]} {
            dict set succ $n $label
        }
    }
}

# 1 if a value of static TYPE could carry declared errors to where it is
# erased (hir::callables::CarriedErrors), for this type or the type it has
# once some site is rejected (a rejected body only ever turns a type into
# `never` or adds errors to a callable's): a callable, or a List, set,
# vector, array or struct that may hold one.
proc hir::staticdeps::CanCarry {hir type {seen {}}} {
    if {[hir::types::IsExactBlock $type] || [hir::types::IsExactNative $type]
            || [hir::types::IsFn $type] || [hir::types::IsCoroutine $type]} {
        return 1
    }
    if {[hir::types::IsMutArray $type] || [hir::types::IsSet $type] || [hir::types::IsMutVec $type]} {
        return [CanCarry $hir [lindex $type 1] $seen]
    }
    if {[hir::types::IsList $type]} {
        foreach t [concat [list [lindex $type 1]] [hir::types::shapeOf $type]] {
            if {[CanCarry $hir $t $seen]} {
                return 1
            }
        }
        return 0
    }
    if {[hir::types::IsStruct $type]} {
        foreach {name t} [lindex $type 1] {
            if {[CanCarry $hir $t $seen]} {
                return 1
            }
        }
        return 0
    }
    if {[hir::types::IsNamedStruct $type]} {
        set id [lindex $type 1]
        if {$id in $seen} {
            return 0
        }
        lappend seen $id
        foreach {name t} [hir::structs::fieldTypes $id] {
            if {[CanCarry $hir $t $seen]} {
                return 1
            }
        }
    }
    return 0
}

# 1 if static TYPE mentions a mutable value (a MutableVector or a
# MutableArray, at any depth): a value whose places another use can change.
proc hir::staticdeps::MentionsMutable {type} {
    if {$type in {mutvec mutarray}} {
        return 1
    }
    if {[llength $type] < 2} {
        return 0
    }
    if {[lindex $type 0] in {mutvec mutarray}} {
        return 1
    }
    foreach part [lrange $type 1 end] {
        if {[MentionsMutable $part]} {
            return 1
        }
    }
    return 0
}

proc hir::staticdeps::BlockName {hir b} {
    if {[catch {hir::contexts::BlockName $hir $b} name]} {
        return $b
    }
    return $name
}

proc hir::staticdeps::SiteName {hir key} {
    return $key
}
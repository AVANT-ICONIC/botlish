# fixture.tcl -- the binding generator's synthetic fixture profile
# (C-BINDGEN.md, "The synthetic fixture"): include/bgf/bgf.h of
# tools/c-bindgen/fixture, freestanding (clang's own headers only, never a
# host's: -nostdlibinc), for three targets. Its generated
# output is pinned in tools/c-bindgen/fixture/expected/TARGET and checked by
# tools/c-bindgen/tests/bindgen.test.
dict create \
    name bgf \
    description "the synthetic fixture: every shape the generator decides about, in one small header" \
    headers {
        library bgf
        source {local tools/c-bindgen/fixture}
        includeDirs {include}
        flags {-ffreestanding -nostdlibinc}
        public {include/bgf/*}
        entry {bgf/bgf.h}
    } \
    targets {linux-x86_64 linux-aarch64 macos-aarch64} \
    modules {stripPrefix bgf_} \
    libraries {
        {headers * targets * names {bgf}}
    } \
    contracts {
        bgf_length {text {read noescape}}
        bgf_open {name {read noescape} result independent}
        bgf_digest {data {read noescape} out {write noescape} result {alias out}}
        bgf_fill {out {write noescape}}
    } \
    groups {
        {name handles functions {bgf_close bgf_window_of bgf_walk} facts {handle noescape}}
    } \
    thunks {
        BGF_TWICE {int BGF_TWICE(int x)}
    } \
    evidence llvm \
    output tools/c-bindgen/fixture/expected

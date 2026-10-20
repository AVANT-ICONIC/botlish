# stdlib/io.bot (S16, 2048-ENGINE-WORKLOAD.md): print_line and write_error_line
# append the newline as a character, text.append_char('\n'), instead of
# concatenating the one-character String "\n". Probed through a substitute
# std::io::IO context declared by the driver (an entry-program context struct
# holding only an Int: a native context slot holds no String), whose
# write_text and write_error_text succeed exactly when they receive one
# expected text and fail with std::io::WriteFailed otherwise: each probe is
# "written" or "not written". Every text is probed against TEXT followed by
# one newline on its own stream (written) and against TEXT alone (not
# written): the empty text, ASCII, a two-byte and a four-byte scalar, and
# texts that already hold or end with a newline.
program stdlib/io.bot

# The driver calling CALL under a context whose standard output accepts
# exactly OUT and whose error output exactly ERR (Botlish String literals).
proc ioProbeDriver {call out err} {
    return [string map [list @CALL@ $call @OUT@ $out @ERR@ $err] {import std::str
type ProbeTag = Int in 0..0
context struct Expect:
    tag: ProbeTag
fn write_text(text: str, context c: Expect) -> unit errors std::io::WriteFailed:
    if text == @OUT@:
        return unit
    fail std::io::WriteFailed
fn write_error_text(text: str, context c: Expect) -> unit errors std::io::WriteFailed:
    if text == @ERR@:
        return unit
    fail std::io::WriteFailed
fn run() -> str errors std::io::WriteFailed:
    @CALL@
    "written"
with context Expect {tag: 0}
r = run():
    on std::io::WriteFailed:
        "not written"
r}]
}

set ioProbeTexts {{""} {"hi"} {"é"} {"😀"} {"a\nb"} {"x\n"}}

foreach {id op stream} {print-line print_line out write-error-line write_error_line err} {
    set drivers {}
    foreach text $ioProbeTexts {
        set line "[string range $text 0 end-1]\\n\""
        foreach expected [list $line $text] {
            set out [expr {$stream eq "out" ? $expected : {""}}]
            set err [expr {$stream eq "err" ? $expected : {""}}]
            lappend drivers [ioProbeDriver "std::io::$op\($text\)" $out $err]
        }
    }
    each $id $drivers
}

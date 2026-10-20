# stdlib/linux/path.bot (P3): concat's "does PATH already end with a slash"
# test reads the last character (the one-character slice's character)
# instead of comparing the slice with a one-character String. Probed with
# paths ending and not ending in "/", the root, non-ASCII and every
# rejected component.
program stdlib/linux/path.bot

probe concat {import std::io::path
fn j(a: str, b: str) -> str errors std::io::path::NotAPath:
    std::linux::path::validate(a)
    std::linux::path::concat(a, b)
[j("/tmp/", "x"), j("/tmp", "x/y"), j("/", "etc"), j("a", "b"), j("a/", "b/"), j("é/", "ü"), j("/x//", "y")]}
probe concat-rejects {import std::io::path
fn j(a: str, b: str) -> str errors std::io::path::NotAPath:
    std::linux::path::validate(a)
    std::linux::path::concat(a, b)
r1 = j("/tmp", "/x"):
    on std::io::path::NotAPath:
        "NotAPath"
r2 = j("/tmp", ""):
    on std::io::path::NotAPath:
        "NotAPath"
r3 = j("", "x"):
    on std::io::path::NotAPath:
        "NotAPath"
[r1, r2, r3]}

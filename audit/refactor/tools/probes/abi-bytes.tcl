# stdlib/abi/bytes.bot (P4): replace's two IndexNotFound guards are one
# condition, an index outside 0..count-1 (milestone 4's merge check, whose
# probe this is). Probed at every boundary: below, first, last, one past,
# far past, the empty value, and a replacement that changes nothing.
program stdlib/abi/bytes.bot

probe replace {fn mb(s: str):
    std::abi::bytes::from_bytes(std::abi::bytes::from_list(std::str::encode_utf8(s)))
fn tryset(m: std::abi::bytes::MutableBytes, i: int) -> List[any] errors IndexNotFound:
    r = std::abi::bytes::replace(m, i, std::byte::from_int(88))
    [std::abi::bytes::mutable_length(r).value, std::abi::bytes::freeze(r) == std::abi::bytes::freeze(m)]
fn at(m: std::abi::bytes::MutableBytes, i: int):
    tryset(m, i):
        on IndexNotFound:
            []
m = mb("abc")
[at(m, 0 - 1), at(m, 0), at(m, 2), at(m, 3), at(m, 1000), at(std::abi::bytes::zeroed(std::abi::usize(0)), 0), at(mb("XYZ"), 0)]}

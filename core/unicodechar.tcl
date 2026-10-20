# unicodechar.tcl -- the UnicodeChar scalar type's one native primitive.
#
# UnicodeChar is a builtin semantic scalar (core/value.tcl, core/type.tcl),
# distinct from Int and String; see UNICODE-CHAR-LITERALS.md. The only
# operation that observes a UnicodeChar's numeric scalar value is total,
# never fails, and returns a plain Int in the Unicode scalar range
# 0..0x10FFFF (its -result-range, which the range and completion analyses
# read): std::char::scalar_value, a root native
# registered under its qualified `char` name (core::native::isQualifiedNative;
# STDLIB-NAMESPACES.md -- before that milestone the root name
# `char_codepoint`, wrapped by a stdlib/char.bot `std::char::codepoint`; the one
# canonical name is now std::char::scalar_value, which says exactly what it
# returns -- a Unicode scalar value, never a byte or a Latin-1 code). Like
# every native's, its UnicodeChar parameter is checked when the call runs;
# an untyped Botlish parameter forwarded to it is inferred UnicodeChar and
# checked statically at its own call sites
# (INTRINSIC-FUNCTION-CONTRACT-INFERENCE.md).
#
# This file, like scalarbits.tcl, is sourced unconditionally by core.tcl:
# the native is a core language primitive.

namespace eval core::unicodechar {}

proc core::unicodechar::scalar_value {c} {
    set c [core::value::expect UnicodeChar $c std::char::scalar_value]
    return [core::value::int [core::value::charOf $c]]
}

core::native::register std::char::scalar_value -arity 1 -impl core::unicodechar::scalar_value \
    -param-types {UnicodeChar} -result-type int -result-range {interval 0 0x10FFFF} -context-free 1

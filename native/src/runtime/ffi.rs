//! The runtime side of C calls (C-FFI.md): the few conversions a
//! `foreigncall` (nir.rs) cannot do inline, and its two failures.
//!
//! A C call itself is no helper: codegen::clif converts the operands to
//! their C ABI classes, calls the linked symbol directly with the platform C
//! calling convention, and converts the result back. Only these slow paths
//! leave generated code:
//!
//! * a 64-bit C integer argument held as a BigInt (`rt_ffi_int_word`: its
//!   two's-complement word; the static check proved it fits the C type);
//! * a 64-bit C integer result outside the small-Int range
//!   (`rt_ffi_box_i64`, `rt_ffi_box_u64`: a BigInt);
//! * a returned address the C address word cannot hold
//!   (`rt_ffi_bad_address`): a NATIVE ADDRESS failure, never a masked or
//!   truncated pointer -- every canonical x86-64 address and every untagged
//!   AArch64 one fits; an AArch64 top-byte-tagged one does not;
//! * a pointer result whose contract says it is exactly a pointer argument
//!   (`alias`) but is not (`rt_ffi_contract_violation`): the development
//!   assertion of the binding's contract, a CONTRACT-VIOLATION failure.
//!
//! None of them names a symbol, opens a library or looks anything up: link
//! symbols are resolved when the program is linked.
use super::error::RtError;
use super::value::*;
use super::vm::Vm;
use num_bigint::BigInt;
use num_traits::ToPrimitive;

fn vm<'a>(p: *mut Vm) -> &'a mut Vm {
    // SAFETY: generated code passes the Vm pointer it was entered with.
    unsafe { &mut *p }
}

/// The two's-complement 64-bit word of the Int V: a C `long`, `long long`
/// or their unsigned forms (the caller's static proof keeps V inside the
/// C type's range, so one of the two conversions holds). Never fails and
/// never allocates.
#[unsafe(no_mangle)]
pub extern "C" fn rt_ffi_int_word(_p: *mut Vm, v: Value) -> u64 {
    let n: BigInt = int_to_big(v);
    match n.to_i64() {
        Some(i) => i as u64,
        None => n.to_u64().unwrap_or(0),
    }
}

/// The Int of the signed 64-bit C result N (a BigInt when it is outside the
/// small range).
#[unsafe(no_mangle)]
pub extern "C" fn rt_ffi_box_i64(p: *mut Vm, n: i64) -> Value {
    vm(p).new_int(n)
}

/// The Int of the unsigned 64-bit C result N.
#[unsafe(no_mangle)]
pub extern "C" fn rt_ffi_box_u64(p: *mut Vm, n: u64) -> Value {
    vm(p).new_big(BigInt::from(n))
}

/// The failure of a C function NAME (a String constant) that returned the
/// address ADDRESS, which no C address word can hold (value.rs: the payload
/// is a sign-extended 60-bit number). Records it and returns NO_VALUE.
#[unsafe(no_mangle)]
pub extern "C" fn rt_ffi_bad_address(p: *mut Vm, name: Value, address: u64) -> Value {
    let name = super::show::show(name);
    vm(p).fail(RtError::ForeignAddress(format!(
        "the C function {name} returned the address 0x{address:x}, which a Botlish C pointer cannot hold (its word keeps a sign-extended 60-bit address: a top-byte-tagged pointer is not one); the pointer is never truncated or masked"
    )))
}

/// The failure of a C function NAME whose contract declares its result
/// exactly its pointer argument (`alias`), at the address EXPECTED, but that
/// returned RETURNED. Records it and returns NO_VALUE: a false contract is
/// the binding's error, reported where it is seen.
#[unsafe(no_mangle)]
pub extern "C" fn rt_ffi_contract_violation(p: *mut Vm, name: Value, expected: u64, returned: u64) -> Value {
    let name = super::show::show(name);
    vm(p).fail(RtError::ContractViolation(format!(
        "the C function {name} returned 0x{returned:x}, but its extern c fn declaration says its result is exactly its pointer argument (alias), 0x{expected:x}: the binding's contract is false"
    )))
}

/// The address a C function's symbol has in code the JIT compiles only to
/// inspect (codegen/mod.rs): a program that calls C runs as a linked
/// executable, so this is never reached; if it were, it stops the process
/// rather than call anything.
#[unsafe(no_mangle)]
pub extern "C" fn rt_ffi_unlinked() -> u64 {
    eprintln!("a C function was called from JIT code compiled for inspection only (C-FFI.md): a program that calls C runs as a linked executable (NATIVE BUG)");
    std::process::abort();
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn ffi_int_word_small_and_big() {
        assert_eq!(rt_ffi_int_word(std::ptr::null_mut(), make_small(-5)), (-5i64) as u64);
        assert_eq!(rt_ffi_int_word(std::ptr::null_mut(), make_small(42)), 42);
    }
}

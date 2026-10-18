//! Read-only native layout views (NATIVE-LAYOUT-VIEWS.md): the loads a
//! `NativeView[L]` field read lowers to, and the test fixture's native
//! memory.
//!
//! A native view is a C address word (value.rs: `(address << 4) | 0b1110`)
//! whose static type names a layout; nothing at run time knows the layout.
//! native/lower.tcl lowers each field read of one statically known layout to
//! one op with constant operands:
//!
//! * `nativeload %v %o %c` -- the Int encoded at address V + O by the scalar
//!   encoding C (the `binload` encoding word, ops.rs's `bin_encoding`), read
//!   with one unaligned load;
//! * `nativeloadptr %v %o %w` -- the C address word of the W-byte address
//!   stored at V + O (a pointer field: `ffi::c::Ptr[T]` or `FnPtr`), exactly
//!   the materialization of a C call's pointer result (codegen/clif.rs's
//!   `foreign_call`): an address the word cannot hold is a `NATIVE ADDRESS`
//!   failure, never truncated;
//! * `cptroffset %v %o` -- the address word V + O (a nested layout's view).
//!
//! The offsets are the layout's (hir/layouts.tcl validated every field inside
//! the layout's size), and a view is never null (the view constructor fails
//! with NativeViewNull first). Nothing here can know that the address is a
//! live allocation of the layout's size: that is the foreign interface's
//! contract, and a wrong address faults like the C code it stands for. These
//! helpers still refuse what they can see -- an operand that is no C address
//! word, the null address, a malformed encoding -- because no checked program
//! reaches them with one.
//!
//! `cptrfixturememory %b` is the test fixture's (core/cabi.tcl's
//! installTestFixture, `ffi_fixture::memory`): a fresh, never-freed native
//! copy of the bytes of the abi::bytes::Bytes B (a one-field struct over its
//! storage), 64-byte aligned, and its
//! address. Only that fixture native lowers to it.

use super::error::RtError;
use super::value::*;
use super::vm::Vm;

#[inline]
fn vm<'a>(p: *mut Vm) -> &'a mut Vm {
    unsafe { &mut *p }
}

fn fail(p: *mut Vm, kind: &'static str, message: String) -> Value {
    vm(p).fail(RtError::Semantic { kind, message })
}

/// The non-null machine address the view operand V holds, plus the constant
/// offset O; CONTEXT names the operation in a failure.
fn view_address(p: *mut Vm, v: Value, offset: Value, context: &str) -> Result<usize, Value> {
    if !is_cptr(v) {
        let message = format!("{context}: expected a native view (a C address), got {}", super::show::show(v));
        return Err(fail(p, "TYPE", message));
    }
    if v == CPTR_NULL {
        return Err(fail(p, "RANGE", format!("{context}: a native view of the null address")));
    }
    let Some(o) = int_small(offset).filter(|o| *o >= 0) else {
        let message = format!("{context}: malformed field offset {}", super::show::int_text(offset));
        return Err(fail(p, "RANGE", message));
    };
    let base = cptr_address(v) as usize;
    match base.checked_add(o as usize) {
        Some(address) => Ok(address),
        None => Err(fail(p, "RANGE", format!("{context}: address 0x{base:x} + {o} overflows"))),
    }
}

/// `nativeload %v %o %c`: the Int at address V + O in encoding C.
#[unsafe(no_mangle)]
pub extern "C" fn rt_native_load(p: *mut Vm, view: Value, offset: Value, code: Value) -> Value {
    let address = match view_address(p, view, offset, "native view") {
        Ok(address) => address,
        Err(failed) => return failed,
    };
    let Some((width, signed, big)) = super::ops::bin_encoding(code) else {
        let message = format!("native view: malformed scalar encoding {}", super::show::int_text(code));
        return fail(p, "RANGE", message);
    };
    let mut bytes = [0u8; 8];
    // SAFETY: the view's contract (NATIVE-LAYOUT-VIEWS.md, "Bounds and
    // lifetime"): the foreign interface that produced the address promises
    // live memory of the layout's size there, and the layout's validation put
    // this field inside that size. Unaligned: a layout may place a field at
    // any offset (a packed record).
    unsafe { std::ptr::copy_nonoverlapping(address as *const u8, bytes.as_mut_ptr(), width) };
    super::ops::bin_decode(p, &bytes[..width], signed, big)
}

/// `nativeloadptr %v %o %w`: the C address word of the W-byte address stored
/// at V + O, or NATIVE ADDRESS when no C address word can hold it.
#[unsafe(no_mangle)]
pub extern "C" fn rt_native_load_ptr(p: *mut Vm, view: Value, offset: Value, width: Value) -> Value {
    let address = match view_address(p, view, offset, "native view") {
        Ok(address) => address,
        Err(failed) => return failed,
    };
    let width = match int_small(width) {
        Some(w @ (4 | 8)) => w as usize,
        _ => {
            let message = format!("native view: malformed pointer width {}", super::show::int_text(width));
            return fail(p, "RANGE", message);
        }
    };
    let mut bytes = [0u8; 8];
    // SAFETY: as rt_native_load's.
    unsafe { std::ptr::copy_nonoverlapping(address as *const u8, bytes.as_mut_ptr(), width) };
    // A pointer is the target's own word: zero-extended from a narrower
    // width (a 32-bit target's address), the full word otherwise.
    let stored = u64::from_le_bytes(bytes) as i64;
    if !cptr_fits(stored) {
        return vm(p).fail(RtError::ForeignAddress(format!(
            "the native view's pointer field at address 0x{address:x} holds 0x{stored:x}, which a Botlish C pointer cannot hold (its word keeps a sign-extended 60-bit address: a top-byte-tagged pointer is not one); the pointer is never truncated or masked"
        )));
    }
    make_cptr(stored)
}

/// `cptroffset %v %o`: the address word V + O (a nested layout's view).
#[unsafe(no_mangle)]
pub extern "C" fn rt_cptr_offset(p: *mut Vm, view: Value, offset: Value) -> Value {
    let address = match view_address(p, view, offset, "native view") {
        Ok(address) => address as i64,
        Err(failed) => return failed,
    };
    if !cptr_fits(address) {
        return vm(p).fail(RtError::ForeignAddress(format!(
            "the nested native view at 0x{address:x} lies outside the addresses a Botlish C pointer holds"
        )));
    }
    make_cptr(address)
}

/// `cptrfixturememory %b` (the test fixture's `ffi_fixture::memory`): the
/// address of a fresh, 64-byte aligned native copy of the bytes of B, which
/// is never freed (a test process makes a few).
#[unsafe(no_mangle)]
pub extern "C" fn rt_cptr_fixture_memory(p: *mut Vm, bytes: Value) -> Value {
    // The abi::bytes::Bytes value itself: a one-field struct over its storage.
    let bytes = if heap_kind(bytes) == KIND_STRUCT && struct_of(bytes).fields().len() == 1 {
        struct_of(bytes).fields()[0]
    } else {
        bytes
    };
    if heap_kind(bytes) != KIND_BYTES {
        let message = format!("native memory test fixture: expected byte storage, got {}", super::show::show(bytes));
        return fail(p, "TYPE", message);
    }
    let data = bytes_of(bytes);
    let layout = std::alloc::Layout::from_size_align(data.len().max(1), 64).expect("fixture layout");
    // SAFETY: a non-zero size; the allocation is leaked on purpose.
    let block = unsafe { std::alloc::alloc_zeroed(layout) };
    if block.is_null() {
        std::alloc::handle_alloc_error(layout);
    }
    unsafe { std::ptr::copy_nonoverlapping(data.as_ptr(), block, data.len()) };
    let address = block as i64;
    if !cptr_fits(address) {
        return vm(p).fail(RtError::ForeignAddress(format!("native memory test fixture: address 0x{address:x} does not fit a C address word")));
    }
    make_cptr(address)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::runtime::metrics::AllocMode;
    use crate::runtime::vm::ProgramInfo;

    fn with_vm<R>(f: impl FnOnce(*mut Vm) -> R) -> R {
        let mut vm = Vm::new(std::rc::Rc::new(ProgramInfo { functions: Vec::new(), natives: Vec::new(), shapes: Vec::new(), enums: Vec::new() }), AllocMode::Off);
        f(&mut *vm as *mut Vm)
    }

    fn word(bytes: &[u8]) -> (Value, Vec<u8>) {
        let mut storage = bytes.to_vec();
        storage.resize(storage.len() + 16, 0xEE);
        let address = storage.as_ptr() as i64;
        (make_cptr(address), storage)
    }

    #[test]
    fn nview_scalar_loads_every_encoding() {
        with_vm(|p| {
            let (v, _keep) = word(&[0xff, 0x7f, 0x00, 0x80, 0x01, 0x02, 0x03, 0x04, 0xfe, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]);
            // u8, i8 at 0
            assert_eq!(int_small(rt_native_load(p, v, make_small(0), make_small(1))), Some(255));
            assert_eq!(int_small(rt_native_load(p, v, make_small(0), make_small(17))), Some(-1));
            // u16 at 1 (unaligned): 0x007f
            assert_eq!(int_small(rt_native_load(p, v, make_small(1), make_small(2))), Some(0x7f));
            // i16 at 2: 0x8000
            assert_eq!(int_small(rt_native_load(p, v, make_small(2), make_small(18))), Some(-32768));
            // u32 at 4
            assert_eq!(int_small(rt_native_load(p, v, make_small(4), make_small(4))), Some(0x04030201));
            // i64 at 8: -2
            assert_eq!(int_small(rt_native_load(p, v, make_small(8), make_small(24))), Some(-2));
        });
    }

    #[test]
    fn nview_u64_above_small_range_is_a_bigint() {
        with_vm(|p| {
            let (v, _keep) = word(&[0xff; 8]);
            let n = rt_native_load(p, v, make_small(0), make_small(8));
            assert_ne!(n, NO_VALUE);
            assert_eq!(super::super::show::int_text(n), "18446744073709551615");
        });
    }

    #[test]
    fn nview_pointer_field_round_trips_and_refuses_tagged() {
        with_vm(|p| {
            let target = 0x1234_5678_9a00u64;
            let (v, _keep) = word(&target.to_le_bytes());
            let q = rt_native_load_ptr(p, v, make_small(0), make_small(8));
            assert!(is_cptr(q));
            assert_eq!(cptr_address(q), target as i64);
            let (z, _keep2) = word(&[0; 8]);
            assert_eq!(rt_native_load_ptr(p, z, make_small(0), make_small(8)), CPTR_NULL);
            let (t, _keep3) = word(&0xf000_0000_0000_0010u64.to_le_bytes());
            assert_eq!(rt_native_load_ptr(p, t, make_small(0), make_small(8)), NO_VALUE);
        });
    }

    #[test]
    fn nview_refuses_null_and_non_addresses() {
        with_vm(|p| {
            assert_eq!(rt_native_load(p, CPTR_NULL, make_small(0), make_small(1)), NO_VALUE);
        });
        with_vm(|p| {
            assert_eq!(rt_native_load(p, make_small(8), make_small(0), make_small(1)), NO_VALUE);
        });
        with_vm(|p| {
            let (v, _keep) = word(&[0; 8]);
            assert_eq!(rt_native_load(p, v, make_small(0), make_small(3)), NO_VALUE);
        });
    }

    #[test]
    fn nview_offset_moves_the_address() {
        with_vm(|p| {
            let (v, _keep) = word(&[0; 8]);
            let w = rt_cptr_offset(p, v, make_small(6));
            assert_eq!(cptr_address(w), cptr_address(v) + 6);
        });
    }
}

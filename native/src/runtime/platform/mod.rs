//! The native stack's platform layer (MACOS-AARCH64-MILESTONE-4.md): how each
//! host finds the bounds and the guard of the current thread's stack
//! (`linux`, `macos`), and the stack-overflow guard every one of them shares
//! (`guard`). runtime::native_stack is the one stack representation they
//! fill; everything above this module is host-independent.
#[cfg(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")))]
pub mod linux;
#[cfg(all(target_os = "macos", target_arch = "aarch64"))]
pub mod macos;
mod guard;

pub use guard::{published_stack, set_active_stack, set_result_fd, OverflowGuard};
#[cfg(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")))]
pub use linux::{current_stack, thread_token};
#[cfg(all(target_os = "macos", target_arch = "aarch64"))]
pub use macos::{current_stack, thread_token};

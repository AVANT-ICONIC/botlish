//! The compilation target as the native backend sees it.
//!
//! A program's target is the front end's (core/cabi.tcl): an operating
//! system *and* an architecture, named to the driver by its target triple
//! (NIR's `target "NAME" triple="TRIPLE"` line, present when the program's
//! HIR depends on its target). Two targets of one architecture are still two
//! targets: linux-aarch64 and macos-aarch64 share an instruction set, not an
//! operating system, a C ABI or an object format.
//!
//! Botlish owns the triple. Cranelift owns what it means for the machine
//! ABI: the C calling convention (`c_call_conv`), register assignment, stack
//! argument placement and the extension of narrow arguments. Nothing here
//! spells a register or a stack slot.
//!
//! Three kinds of call, three conventions:
//!
//!   * Botlish-to-Botlish calls (`clif::signature_n`): the ISA's default
//!     convention, `module.make_signature()`. Internal to one compilation;
//!     the platform C ABI does not bind them, and a foreign target never
//!     changes them.
//!   * runtime helper calls (`rt_*`, `clif::declare`): the ISA's default
//!     convention, which is the host's C convention -- the helpers are Rust
//!     `extern "C"` functions compiled for this host.
//!   * foreign C calls (`clif::c_signature`): the C convention of the target
//!     triple, `c_call_conv` -- AppleAarch64 for aarch64-apple-darwin,
//!     SystemV for Linux, WindowsFastcall for Windows. Machine code is only
//!     made for the host's own target (`check_host`), so this is the host's
//!     platform C convention, stated where foreign signatures are built
//!     instead of left implicit.

use cranelift_codegen::isa::CallConv;
use std::str::FromStr;
use target_lexicon::{OperatingSystem, Triple};

/// The C calling convention of a foreign C function on the platform of
/// TRIPLE: Cranelift's platform default for it (`CallConv::triple_default`),
/// AppleAarch64 on Apple AArch64, never the generic AArch64 SystemV one.
pub fn c_call_conv(triple: &Triple) -> CallConv {
    CallConv::triple_default(triple)
}

/// The operating system family of OS, as targets distinguish them.
fn os_family(os: OperatingSystem) -> String {
    if os.is_like_darwin() {
        return "darwin".to_string();
    }
    match os {
        OperatingSystem::Linux => "linux".to_string(),
        OperatingSystem::Windows => "windows".to_string(),
        other => other.to_string(),
    }
}

/// Whether machine code for TARGET runs on HOST: the same architecture *and*
/// the same operating system. A matching architecture (or pointer width) is
/// not a matching target.
pub fn same_target(target: &Triple, host: &Triple) -> bool {
    target.architecture == host.architecture
        && os_family(target.operating_system) == os_family(host.operating_system)
}

/// TEXT as a target triple, or why it is not one.
pub fn parse_triple(text: &str) -> Result<Triple, String> {
    Triple::from_str(text).map_err(|e| format!("invalid target triple \"{text}\": {e}"))
}

/// Ok if PROGRAM was built for this host (or for no target in particular),
/// else the NATIVE TARGET refusal's message: the driver runs and emits
/// machine code for its own host only, and never treats a program built for
/// another target as the host's.
pub fn check_host(program: &crate::nir::Program) -> Result<(), String> {
    let Some(target) = &program.target else { return Ok(()) };
    let triple = parse_triple(&target.triple)?;
    let host = Triple::host();
    if same_target(&triple, &host) {
        return Ok(());
    }
    let shared = if triple.architecture == host.architecture {
        format!(" Both are {}, but a matching architecture is not a matching target.", host.architecture)
    } else {
        String::new()
    };
    Err(format!(
        "this program was built for target {} ({}), and native code runs only on its own target's host: \
         this host is {host}.{shared} Compile the program for this host (main.tcl -target, or the host's \
         default), or run it on a Tcl backend",
        target.name, target.triple
    ))
}

/// The driver's `target TRIPLE` report, a Tcl list: TRIPLE's architecture,
/// operating system, pointer width, object format and C calling convention
/// as Cranelift and target-lexicon read them, the host's triple, and whether
/// machine code for TRIPLE runs here.
pub fn describe(text: &str) -> Result<Vec<String>, String> {
    let triple = parse_triple(text)?;
    let host = Triple::host();
    let pointer = triple.pointer_width().map(|w| w.bits().to_string()).unwrap_or_else(|_| "unknown".into());
    Ok(vec![
        "target".into(),
        text.to_string(),
        "arch".into(),
        triple.architecture.to_string(),
        "os".into(),
        os_family(triple.operating_system),
        "pointer".into(),
        pointer,
        "format".into(),
        triple.binary_format.to_string(),
        "c-call-conv".into(),
        c_call_conv(&triple).to_string(),
        "host".into(),
        host.to_string(),
        "runs".into(),
        if same_target(&triple, &host) { "1" } else { "0" }.into(),
    ])
}

#[cfg(test)]
mod tests {
    use super::*;

    fn conv(text: &str) -> CallConv {
        c_call_conv(&parse_triple(text).unwrap())
    }

    // The triples of core/cabi.tcl's six targets (tests/target-model.test
    // checks the table's triples against this driver's `target` report).
    #[test]
    fn c_call_conv_is_the_platform_c_convention_of_each_target() {
        assert_eq!(conv("aarch64-apple-darwin"), CallConv::AppleAarch64);
        assert_eq!(conv("aarch64-unknown-linux-gnu"), CallConv::SystemV);
        assert_eq!(conv("x86_64-unknown-linux-gnu"), CallConv::SystemV);
        assert_eq!(conv("x86_64-apple-darwin"), CallConv::SystemV);
        assert_eq!(conv("x86_64-pc-windows-msvc"), CallConv::WindowsFastcall);
        assert_eq!(conv("aarch64-pc-windows-msvc"), CallConv::WindowsFastcall);
    }

    #[test]
    fn apple_aarch64_is_not_the_linux_aarch64_convention() {
        assert_ne!(conv("aarch64-apple-darwin"), conv("aarch64-unknown-linux-gnu"));
    }

    #[test]
    fn same_architecture_is_not_same_target() {
        let linux = parse_triple("aarch64-unknown-linux-gnu").unwrap();
        let macos = parse_triple("aarch64-apple-darwin").unwrap();
        let x86 = parse_triple("x86_64-unknown-linux-gnu").unwrap();
        assert!(!same_target(&macos, &linux));
        assert!(!same_target(&linux, &macos));
        assert!(!same_target(&x86, &linux));
        assert!(same_target(&linux, &linux));
        assert!(same_target(&macos, &parse_triple("arm64-apple-darwin").unwrap()));
    }

    #[test]
    fn describe_reports_the_targets_facts() {
        let d = describe("aarch64-apple-darwin").unwrap();
        let get = |k: &str| d[d.iter().position(|x| x == k).unwrap() + 1].clone();
        assert_eq!(get("arch"), "aarch64");
        assert_eq!(get("os"), "darwin");
        assert_eq!(get("pointer"), "64");
        assert_eq!(get("format"), "macho");
        assert_eq!(get("c-call-conv"), "apple_aarch64");
        assert!(describe("not a triple at all").is_err());
    }
}

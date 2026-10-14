//! botlish-aot-stub: the runtime half of an executable the `stub` linker
//! links (codegen/aot.rs, SINGLE-EXECUTABLE.md). The linker appends a program
//! image to a copy of this executable; at startup `aotimage::main` reads the
//! image back from the running file, maps and relocates its machine code
//! next to this runtime, and runs it with the process's own arguments. Run
//! bare (no image), it reports that and exits 1.

#[cfg(all(target_arch = "x86_64", target_os = "linux"))]
fn main() {
    std::process::exit(botlish_native::runtime::aotimage::main());
}

#[cfg(not(all(target_arch = "x86_64", target_os = "linux")))]
fn main() {
    eprintln!("botlish-aot-stub runs on x86-64 Linux only (NATIVE STARTUP)");
    std::process::exit(1);
}

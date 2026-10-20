//! Standalone executable linking: Linux glibc on x86-64 (both linkers) and
//! AArch64 (the `rustc` linker), ELF; macOS on AArch64 (the `rustc` linker),
//! Mach-O (MACOS-AARCH64-MILESTONE-5.md). Cranelift emits the program object
//! in the host triple's format; a linker turns it and the runtime into an
//! executable. The executable needs neither Tcl, rustc, the source nor this
//! checkout: only the system's own libraries.
//!
//! Two linkers, chosen by `BOTLISH_NATIVE_LINKER` (SINGLE-EXECUTABLE.md):
//!
//!   * `rustc` (the default): rustc compiles a small data initializer and
//!     statically links our runtime (`libbotlish_native.rlib` beside the
//!     driver), through the system linker.
//!   * `stub`: no toolchain at all. The prebuilt `botlish-aot-stub` (this
//!     runtime and a loader, beside the driver or `BOTLISH_NATIVE_AOT_STUB`)
//!     is copied and the program's image appended to it: the object's
//!     sections laid out and relocated here, by `image` below, into a
//!     `runtime::aotimage::Image` the stub maps at startup. This is how the
//!     single-file compiler (single/) emits executables.
//!
//! Both link the same machine code (`emit_object`) and start it the same way
//! (`runtime::aot::run`); `tests/aot-stub-linker.test` runs programs linked
//! both ways side by side.
//!
//! A program that calls C (C-FFI.md: `foreign` functions, `link` libraries)
//! needs the system linker to resolve its foreign symbols: the `rustc`
//! linker passes the program's link plan to it -- `-lNAME` for every
//! library, inside one `--start-group`/`--end-group`, so the order of the
//! declarations never decides a static link, and `-LDIR` for every
//! `--link-dir` search directory -- after the program object. The `stub`
//! linker links no native library and refuses such a program, and so does
//! macOS for now (`C_CALLS`). An ordinary program's link is unchanged.
//!
//! On macOS nothing in the link is Mach-O-specific code of ours: rustc drives
//! the platform linker (the C compiler driver, Apple's ld) with the same
//! arguments, the object's symbols carry Mach-O's `_` prefix because the
//! object crate writes it, and the linker signs the executable ad hoc, as it
//! signs every arm64 executable it links.
use super::{Const, ObjectProgram, emit_object};
use crate::nir::Program;
use botlish_native::runtime::aotimage::{self, Fixup, FunctionCode, Image, Target};
use std::collections::HashMap;
use std::fmt::Write;
use std::path::{Path, PathBuf};
use std::process::Command;

struct WorkDir(PathBuf);

impl WorkDir {
    /// A fresh directory beside DESTINATION (so the finished executable is
    /// published by a rename on the same filesystem).
    fn beside(destination: &Path) -> Result<WorkDir, String> {
        let parent = destination.parent().ok_or("output has no parent directory")?;
        let nonce = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .map_err(|e| e.to_string())?
            .as_nanos();
        let work = parent.join(format!(".botlish-aot-{}-{nonce}", std::process::id()));
        std::fs::create_dir(&work).map_err(|e| format!("{}: {e}", work.display()))?;
        Ok(WorkDir(work))
    }
}

impl Drop for WorkDir {
    fn drop(&mut self) {
        // This directory was exclusively created by this invocation beside
        // the destination; it never contains user-owned files.
        let _ = std::fs::remove_dir_all(&self.0);
    }
}

fn startup(program: &Program, object: &ObjectProgram) -> String {
    let mut s = String::from(
        "#![allow(unused_imports)]\n\
         use botlish_native::{nir::OpCode, runtime::{aot, constants::{self, Const},\n\
         framemap::{FunctionMap, ProgramMap}, metrics::AllocMode, value::{Kind, Value},\n\
         vm::{EnumInfo, FunctionInfo, NativeInfo, ProgramInfo, ShapeInfo, Vm}}};\n\
         use std::rc::Rc;\n\
         unsafe extern \"C\" {\n",
    );
    for f in &program.functions {
        writeln!(s, "fn botlish_fn_{}(); fn botlish_entry_{}();", f.id, f.id).unwrap();
    }
    s.push_str(
        "}\nextern \"C\" fn entry(vm: *mut Vm) -> Value {\n\
        let f: aot::ProgramEntry = unsafe { std::mem::transmute(botlish_fn_0 as *const ()) };\n\
        f(vm)\n}\nfn main() {\n\
        use std::os::unix::ffi::OsStringExt;\n\
        let argv: Vec<Vec<u8>> = std::env::args_os().map(|a| a.into_vec()).collect();\n\
        std::process::exit(aot::run(argv, || {\n\
        let info = ProgramInfo { functions: vec![\n",
    );
    for f in &program.functions {
        writeln!(
            s,
            "FunctionInfo {{ arity: {}, pnames: {:?}.into() }},",
            f.params, f.pnames
        )
        .unwrap();
    }
    s.push_str("], natives: vec![\n");
    for n in &program.natives {
        let params: Vec<String> = n
            .params
            .iter()
            .map(|kind| match kind {
                Some(k) => format!("Some(Kind::{k:?})"),
                None => "None".to_string(),
            })
            .collect();
        writeln!(
            s,
            "NativeInfo {{ name: {:?}.into(), arity: {:?}, params: vec![{}], op: OpCode::{:?} }},",
            n.name,
            n.arity,
            params.join(","),
            n.op
        )
        .unwrap();
    }
    s.push_str("], shapes: vec![\n");
    for shape in &program.shapes {
        let name = match &shape.name {
            Some(n) => format!("Some({n:?}.to_string())"),
            None => "None".to_string(),
        };
        writeln!(
            s,
            "ShapeInfo {{ name: {name}, fields: <Vec<&str>>::into_iter(vec!{:?}).map(String::from).collect(), opaque: {} }},",
            shape.fields, shape.opaque
        )
        .unwrap();
    }
    s.push_str("], enums: vec![\n");
    for e in &program.enums {
        writeln!(
            s,
            "EnumInfo {{ name: {:?}.to_string(), cases: vec!{:?}.into_iter().map(String::from).collect() }},",
            e.name, e.cases
        )
        .unwrap();
    }
    s.push_str("] };\nlet mut vm = Vm::new(Rc::new(info), AllocMode::Off);\nlet entries = vec![\n");
    for f in &program.functions {
        writeln!(s, "botlish_entry_{} as *const () as usize,", f.id).unwrap();
    }
    s.push_str("];\nconstants::install(&mut vm, &[\n");
    for c in &object.pool.entries {
        match c {
            Const::Str(text) => writeln!(s, "Const::Str({text:?}.into()),"),
            Const::Bytes(bytes) => {
                // A byte-string literal of \xNN escapes: compact however large
                // the static storage is, and exact for every byte (NUL, 0xff).
                let literal: String = bytes.iter().map(|b| format!("\\x{b:02x}")).collect();
                writeln!(s, "Const::Bytes(b\"{literal}\".to_vec()),")
            }
            Const::BigInt(text) => writeln!(s, "Const::BigInt({text:?}.into()),"),
            Const::Native(id) => writeln!(s, "Const::Native({id}),"),
            Const::FnValue(id) => writeln!(s, "Const::FnValue({id}),"),
        }
        .unwrap();
    }
    writeln!(
        s,
        "], &entries, {});\nlet mut map = ProgramMap::new();",
        program.statics
    )
    .unwrap();
    for (id, f) in object.functions.iter().enumerate() {
        let points: Vec<String> = f
            .safepoints
            .iter()
            .map(|(pc, roots)| format!("({pc}, vec!{roots:?})"))
            .collect();
        writeln!(
            s,
            "let start = botlish_fn_{id} as *const () as usize;\n\
            map.push(FunctionMap {{ code_start: start, code_end: start + {}, safepoints: vec![{}] }});\n\
            let start = entries[{id}];\n\
            map.push(FunctionMap {{ code_start: start, code_end: start + {}, safepoints: vec![] }});",
            f.direct_size,
            points.join(","),
            f.entry_size
        )
        .unwrap();
    }
    s.push_str("map.finish();\nvm.set_framemap(Rc::new(map));\n(vm, entry as aot::ProgramEntry)\n})); }\n");
    s
}

/// Whether PROGRAM calls C or names a native library (C-FFI.md): it is then
/// linked by the system linker, and run as an executable.
pub fn calls_c(program: &Program) -> bool {
    !program.foreigns.is_empty() || !program.links.is_empty()
}

/// Whether this host links executables: Linux glibc on x86-64 and AArch64
/// (ELF), macOS on AArch64 (Mach-O, MACOS-AARCH64-MILESTONE-5.md). On every
/// one the program object is Cranelift's, in the host triple's object
/// format, and the rustc linker links it through the platform's own linker.
const EXECUTABLES: bool = cfg!(any(
    all(target_os = "linux", target_env = "gnu", any(target_arch = "x86_64", target_arch = "aarch64")),
    all(target_os = "macos", target_arch = "aarch64")
));

/// Whether this host links a program that calls C (C-FFI.md): Linux glibc
/// only. macOS links ordinary programs, whose only native libraries are the
/// ones rustc links for the runtime; a C call there -- the Apple C ABI
/// against real callees, a link plan for Apple's ld -- is not validated yet
/// (the C FFI milestone of MACOS-AARCH64-PORT-AUDIT.md's roadmap), so its
/// link is refused before the linker runs, as it was before macOS linked
/// anything.
const C_CALLS: bool = cfg!(target_os = "linux");

pub fn emit_executable(program: &Program, destination: &Path, link_dirs: &[String]) -> Result<(), String> {
    if !EXECUTABLES {
        return Err("executable emission requires Linux glibc on x86_64 or aarch64, or macOS on aarch64".into());
    }
    if calls_c(program) && !C_CALLS {
        return Err(format!(
            "native link failed: this program calls C or declares a C library ({}), and C calls are linked on Linux glibc only: on this host executables of programs that call no C are supported, C calls not yet (MACOS-AARCH64-PORT-AUDIT.md, C FFI)",
            describe_link_plan(program)
        ));
    }
    let destination = std::path::absolute(destination).map_err(|e| e.to_string())?;
    match std::env::var("BOTLISH_NATIVE_LINKER").as_deref() {
        Err(std::env::VarError::NotPresent) | Ok("" | "rustc") => link_rustc(program, &destination, link_dirs),
        Ok("stub") if calls_c(program) => Err(format!(
            "native link failed: this program calls C or declares a C library ({}), which only the system linker resolves, and the stub linker (BOTLISH_NATIVE_LINKER=stub, the single executable's) links no native library: link it with the rustc linker of a Botlish checkout whose native backend is built (BOTLISH_NATIVE_LINKER=rustc; C-FFI.md)",
            describe_link_plan(program)
        )),
        Ok("stub") => link_stub(program, &destination),
        Ok(other) => Err(format!("unknown BOTLISH_NATIVE_LINKER {other:?} (known: rustc stub)")),
        Err(e) => Err(format!("BOTLISH_NATIVE_LINKER: {e}")),
    }
}

/// The `rustc` linker: a generated startup crate, compiled and linked
/// against this build's runtime library.
/// The C functions and libraries PROGRAM names, for messages.
fn describe_link_plan(program: &Program) -> String {
    let mut parts = Vec::new();
    if !program.foreigns.is_empty() {
        let names: Vec<&str> = program.foreigns.iter().map(|f| f.symbol.as_str()).collect();
        parts.push(format!("symbols {}", names.join(", ")));
    }
    if !program.links.is_empty() {
        let libraries: Vec<String> = program.links.iter().map(|l| format!("-l{l}")).collect();
        parts.push(format!("libraries {}", libraries.join(" ")));
    }
    parts.join("; ")
}

/// The linker's own account of a failed link of a program that calls C:
/// the lines of rustc's STDERR the system linker wrote (its diagnostics,
/// never rustc's echo of the whole command line), else all of it.
fn linker_diagnostics(stderr: &str) -> String {
    let lines: Vec<&str> = stderr
        .lines()
        .map(str::trim)
        .filter(|line| {
            line.contains("undefined reference")
                || line.contains("cannot find")
                || line.contains("ld:")
                || line.contains("ld.lld:")
                || line.starts_with("collect2")
                || line.contains("error: linking with")
        })
        .filter(|line| !line.starts_with("= note: \"") && line.len() < 2000)
        .collect();
    if lines.is_empty() { stderr.to_string() } else { lines.join("\n") }
}

fn link_rustc(program: &Program, destination: &Path, link_dirs: &[String]) -> Result<(), String> {
    let driver = std::env::current_exe().map_err(|e| e.to_string())?;
    let release = driver.parent().ok_or("cannot locate native runtime")?;
    let library = release.join("libbotlish_native.rlib");
    if !library.is_file() {
        return Err(format!(
            "runtime library missing: {}; run cargo build --release --manifest-path native/Cargo.toml",
            library.display()
        ));
    }
    let work = WorkDir::beside(destination)?;
    let object = emit_object(program).map_err(|e| e.message().to_string())?;
    let object_path = work.0.join("program.o");
    let source_path = work.0.join("startup.rs");
    let executable = work.0.join("executable");
    std::fs::write(&object_path, &object.bytes).map_err(|e| e.to_string())?;
    std::fs::write(&source_path, startup(program, &object)).map_err(|e| e.to_string())?;
    let output = Command::new(std::env::var_os("RUSTC").unwrap_or_else(|| "rustc".into()))
        .arg("--edition=2024")
        .arg("--crate-name=botlish_program")
        .args([
            "-C",
            "opt-level=2",
            "-C",
            "force-frame-pointers=yes",
            "-C",
            "relocation-model=pic",
        ])
        .arg("--extern")
        .arg(format!("botlish_native={}", library.display()))
        .arg("-L")
        .arg(format!("dependency={}", release.join("deps").display()))
        .arg("-C")
        .arg(format!("link-arg={}", object_path.display()))
        .args(link_plan_args(program, link_dirs))
        .arg(&source_path)
        .arg("-o")
        .arg(&executable)
        .output()
        .map_err(|e| format!("cannot launch rustc to link executable: {e}"))?;
    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        if calls_c(program) {
            return Err(format!(
                "native link failed: the system linker could not link this program with the C functions and libraries it declares ({}):\n{}",
                describe_link_plan(program),
                linker_diagnostics(&stderr)
            ));
        }
        return Err(format!("executable link failed ({}):\n{}", output.status, stderr));
    }
    // Publish only a successfully linked file, on the same filesystem. A
    // failed build leaves any previous executable intact.
    std::fs::rename(&executable, &destination).map_err(|e| format!("{}: {e}", destination.display()))?;
    Ok(())
}

/// rustc's arguments passing PROGRAM's link plan to the system linker: the
/// search directories LINK_DIRS (`-LDIR`), then every library `-lNAME`, in
/// the plan's order, inside one linker group. Nothing for a program that
/// names none.
///
/// A program that calls C is also linked with the C compiler driver's
/// default libraries (`-C default-linker-libraries=yes`: rustc passes no
/// `-nodefaultlibs`), which the driver appends after every argument, so the
/// libraries are followed by libc, its as-needed dynamic loader and libgcc
/// exactly as in a C program's link. rustc's own system libraries come before
/// its link arguments, and GNU ld drops an as-needed library nothing has
/// referenced yet: a static archive needing a symbol only the loader defines
/// (AArch64 glibc's `__stack_chk_guard`, which BoringSSL's stack protector
/// reads) or a libgcc helper would otherwise fail to link.
fn link_plan_args(program: &Program, link_dirs: &[String]) -> Vec<String> {
    let mut args = Vec::new();
    if !calls_c(program) {
        return args;
    }
    args.extend(["-C".to_string(), "default-linker-libraries=yes".to_string()]);
    for dir in link_dirs {
        args.extend(["-C".to_string(), format!("link-arg=-L{dir}")]);
    }
    if !program.links.is_empty() {
        args.extend(["-C".to_string(), "link-arg=-Wl,--start-group".to_string()]);
        for library in &program.links {
            args.extend(["-C".to_string(), format!("link-arg=-l{library}")]);
        }
        args.extend(["-C".to_string(), "link-arg=-Wl,--end-group".to_string()]);
    }
    args
}

/// The `stub` linker: the prebuilt `botlish-aot-stub` with the program's
/// image appended (runtime/aotimage.rs).
fn link_stub(program: &Program, destination: &Path) -> Result<(), String> {
    // `image` lays out and relocates an ELF x86-64 object (its relocation
    // types and call trampolines are x86-64's), and the stub's loader is
    // built for x86-64 Linux only (runtime/aotimage.rs). No Mach-O stub:
    // macOS executables are the system linker's.
    if !cfg!(all(target_os = "linux", target_arch = "x86_64")) {
        return Err("the stub linker supports x86_64 Linux only: use BOTLISH_NATIVE_LINKER=rustc".into());
    }
    let stub = match std::env::var_os("BOTLISH_NATIVE_AOT_STUB") {
        Some(path) => PathBuf::from(path),
        None => {
            let driver = std::env::current_exe().map_err(|e| e.to_string())?;
            driver.parent().ok_or("cannot locate native runtime")?.join("botlish-aot-stub")
        }
    };
    let mut bytes = std::fs::read(&stub).map_err(|e| {
        format!(
            "runtime stub missing: {}: {e}; run cargo build --release --manifest-path native/Cargo.toml",
            stub.display()
        )
    })?;
    if bytes.ends_with(aotimage::MAGIC) {
        return Err(format!("{} already carries a program image: not a botlish-aot-stub", stub.display()));
    }
    let object = emit_object(program).map_err(|e| e.message().to_string())?;
    let payload = image(program, &object)?.encode();
    bytes.extend_from_slice(&payload);
    bytes.extend_from_slice(&aotimage::trailer(payload.len()));
    let work = WorkDir::beside(destination)?;
    let executable = work.0.join("executable");
    std::fs::write(&executable, &bytes).map_err(|e| e.to_string())?;
    {
        use std::os::unix::fs::PermissionsExt;
        std::fs::set_permissions(&executable, std::fs::Permissions::from_mode(0o755)).map_err(|e| e.to_string())?;
    }
    // Publish only a complete file, on the same filesystem, as link_rustc.
    std::fs::rename(&executable, destination).map_err(|e| format!("{}: {e}", destination.display()))?;
    Ok(())
}

// The ELF64 x86-64 relocatable object `emit_object` writes: just what `image`
// reads of it.
const SHT_RELA: u32 = 4;
const SHT_NOBITS: u32 = 8;
const SHT_SYMTAB: u32 = 2;
const SHF_ALLOC: u64 = 2;
const SHF_EXECINSTR: u64 = 4;
const SHN_UNDEF: u16 = 0;
const SHN_LORESERVE: u16 = 0xff00;
const R_X86_64_64: u32 = 1;
const R_X86_64_PC32: u32 = 2;
const R_X86_64_PLT32: u32 = 4;
const R_X86_64_GOTPCREL: u32 = 9;
const R_X86_64_GOTPCRELX: u32 = 41;
const R_X86_64_REX_GOTPCRELX: u32 = 42;

struct Section {
    kind: u32,
    flags: u64,
    offset: usize,
    size: usize,
    link: usize,
    info: usize,
    align: u64,
    entsize: usize,
}

struct Symbol {
    name: String,
    section: u16,
    value: u64,
}

struct Rela {
    section: usize,
    offset: u64,
    kind: u32,
    symbol: usize,
    addend: i64,
}

fn read_object(bytes: &[u8]) -> Result<(Vec<Section>, Vec<Symbol>, Vec<Rela>), String> {
    let bad = || "malformed program object".to_string();
    let get = |at: usize, n: usize| bytes.get(at..at + n).ok_or_else(bad);
    let u16_at = |at: usize| get(at, 2).map(|b| u16::from_le_bytes(b.try_into().unwrap()));
    let u32_at = |at: usize| get(at, 4).map(|b| u32::from_le_bytes(b.try_into().unwrap()));
    let u64_at = |at: usize| get(at, 8).map(|b| u64::from_le_bytes(b.try_into().unwrap()));
    if bytes.len() < 64 || &bytes[0..4] != b"\x7fELF" || bytes[4] != 2 || bytes[5] != 1 || u16_at(0x12)? != 62 {
        return Err("program object is not an ELF64 x86-64 object".to_string());
    }
    let shoff = u64_at(0x28)? as usize;
    let shentsize = u16_at(0x3a)? as usize;
    let mut sections = Vec::new();
    for i in 0..u16_at(0x3c)? as usize {
        let h = shoff + i * shentsize;
        sections.push(Section {
            kind: u32_at(h + 4)?,
            flags: u64_at(h + 8)?,
            offset: u64_at(h + 0x18)? as usize,
            size: u64_at(h + 0x20)? as usize,
            link: u32_at(h + 0x28)? as usize,
            info: u32_at(h + 0x2c)? as usize,
            align: u64_at(h + 0x30)?.max(1),
            entsize: u64_at(h + 0x38)? as usize,
        });
    }
    let mut symbols = Vec::new();
    let symtab = sections.iter().find(|s| s.kind == SHT_SYMTAB && s.entsize > 0).ok_or_else(bad)?;
    let strtab = sections.get(symtab.link).ok_or_else(bad)?;
    for index in 0..symtab.size / symtab.entsize {
        let e = symtab.offset + index * symtab.entsize;
        let start = strtab.offset + u32_at(e)? as usize;
        let tail = bytes.get(start..strtab.offset + strtab.size).ok_or_else(bad)?;
        let end = tail.iter().position(|&c| c == 0).ok_or_else(bad)?;
        symbols.push(Symbol {
            name: String::from_utf8_lossy(&tail[..end]).into_owned(),
            section: u16_at(e + 6)?,
            value: u64_at(e + 8)?,
        });
    }
    let mut relas = Vec::new();
    for s in sections.iter().filter(|s| s.kind == SHT_RELA && s.entsize > 0) {
        for index in 0..s.size / s.entsize {
            let e = s.offset + index * s.entsize;
            let info = u64_at(e + 8)?;
            relas.push(Rela {
                section: s.info,
                offset: u64_at(e)?,
                kind: info as u32,
                symbol: (info >> 32) as usize,
                addend: u64_at(e + 16)? as i64,
            });
        }
    }
    Ok((sections, symbols, relas))
}

/// Lays out OBJECT's allocated sections as one image and relocates it, the
/// way a static linker relocates the same object into an executable:
///
/// ```text
///   [machine code][trampolines]  page-aligned: executable
///   [GOT][data][.bss]            writable
/// ```
///
/// A reference inside the image is resolved here, a PC-relative call to a
/// runtime helper becomes a `Call32` fixup (a direct call at load time, or
/// one through the helper's trampoline if the helper is out of rel32 reach),
/// and an absolute address (a data word, a GOT slot) an `Abs64` fixup.
/// GOT-relative loads of an image symbol are relaxed to `lea` when the
/// relocation allows it (`R_X86_64_[REX_]GOTPCRELX` on a `mov`, as GNU ld
/// and lld relax them: the context area's accesses, mod.rs's
/// `relax_context_got`); every other GOT-relative load gets a GOT slot.
fn image(program: &Program, object: &ObjectProgram) -> Result<Image, String> {
    let bytes = &object.bytes;
    let (sections, symbols, relas) = read_object(bytes)?;
    let unsupported = |r: &Rela| format!("unsupported relocation type {} against {}", r.kind, symbols[r.symbol].name);
    let allocated = |s: &Section| s.flags & SHF_ALLOC != 0;

    // Imports, in first-use order, and what each relocation needs.
    let mut imports: Vec<String> = Vec::new();
    let mut import_index: HashMap<String, u32> = HashMap::new();
    let mut calls: Vec<u32> = Vec::new();
    let mut got: Vec<Target> = Vec::new();
    let mut got_index: HashMap<Target, usize> = HashMap::new();
    let relaxable = |r: &Rela| -> bool {
        // `mov disp32(%rip), %reg` (opcode 0x8b, ModRM mod=00 rm=101) is
        // the instruction both GOTPCRELX relocations may rewrite to `lea`.
        let s = &sections[r.section];
        let at = s.offset + r.offset as usize;
        matches!(r.kind, R_X86_64_GOTPCRELX | R_X86_64_REX_GOTPCRELX)
            && symbols[r.symbol].section != SHN_UNDEF
            && r.offset >= 2
            && bytes.get(at - 2) == Some(&0x8b)
            && bytes.get(at - 1).is_some_and(|m| m & 0xc7 == 0x05)
    };
    // Symbols resolve to Local targets once laid out: until then, GOT keys
    // for image symbols are (section, value) pairs, packed into Local.
    let mut pre_target = |symbol: &Symbol, imports: &mut Vec<String>| -> Result<Target, String> {
        if symbol.section == SHN_UNDEF {
            let next = imports.len() as u32;
            let index = *import_index.entry(symbol.name.clone()).or_insert_with(|| {
                imports.push(symbol.name.clone());
                next
            });
            Ok(Target::Import(index))
        } else if symbol.section < SHN_LORESERVE && sections.get(symbol.section as usize).is_some_and(allocated) {
            Ok(Target::Local(((symbol.section as u64) << 48) | symbol.value))
        } else {
            Err(format!("program object symbol {} is not in an allocated section", symbol.name))
        }
    };
    let mut targets = Vec::with_capacity(relas.len());
    for r in &relas {
        if !sections.get(r.section).is_some_and(allocated) {
            continue;
        }
        let symbol = symbols.get(r.symbol).ok_or("malformed program object relocation")?;
        let target = pre_target(symbol, &mut imports)?;
        match (r.kind, target) {
            (R_X86_64_PLT32, Target::Import(i)) if !calls.contains(&i) => calls.push(i),
            (R_X86_64_GOTPCREL | R_X86_64_GOTPCRELX | R_X86_64_REX_GOTPCRELX, _) if !relaxable(r) => {
                got_index.entry(target).or_insert_with(|| {
                    got.push(target);
                    got.len() - 1
                });
            }
            _ => {}
        }
        targets.push(target);
    }
    // Every helper reached by a call has a trampoline, and so a GOT slot.
    for &i in &calls {
        got_index.entry(Target::Import(i)).or_insert_with(|| {
            got.push(Target::Import(i));
            got.len() - 1
        });
    }

    // Layout.
    let mut place: Vec<Option<u64>> = vec![None; sections.len()];
    let mut cursor = 0u64;
    let mut lay = |i: usize, s: &Section, cursor: &mut u64| {
        *cursor = cursor.next_multiple_of(s.align);
        place[i] = Some(*cursor);
        *cursor += s.size as u64;
    };
    for (i, s) in sections.iter().enumerate() {
        if allocated(s) && s.flags & SHF_EXECINSTR != 0 {
            lay(i, s, &mut cursor);
        }
    }
    cursor = cursor.next_multiple_of(16);
    let trampolines = cursor;
    cursor += 8 * calls.len() as u64;
    let executable = cursor.next_multiple_of(4096);
    let got_base = executable;
    cursor = got_base + 8 * got.len() as u64;
    for (i, s) in sections.iter().enumerate() {
        if allocated(s) && s.flags & SHF_EXECINSTR == 0 && s.kind != SHT_NOBITS {
            lay(i, s, &mut cursor);
        }
    }
    let initialized = cursor;
    for (i, s) in sections.iter().enumerate() {
        if allocated(s) && s.flags & SHF_EXECINSTR == 0 && s.kind == SHT_NOBITS {
            lay(i, s, &mut cursor);
        }
    }
    let size = cursor;

    let mut code = vec![0u8; initialized as usize];
    for (i, s) in sections.iter().enumerate() {
        if let (Some(at), true) = (place[i], s.kind != SHT_NOBITS) {
            let data = bytes.get(s.offset..s.offset + s.size).ok_or("malformed program object section")?;
            code[at as usize..at as usize + s.size].copy_from_slice(data);
        }
    }
    let local = |t: Target| -> Target {
        match t {
            Target::Local(packed) => {
                Target::Local(place[(packed >> 48) as usize].expect("allocated section") + (packed & 0xffff_ffff_ffff))
            }
            import => import,
        }
    };
    let rel32 = |code: &mut [u8], at: u64, value: i128| -> Result<(), String> {
        let value = i32::try_from(value).map_err(|_| "program image relocation out of rel32 range".to_string())?;
        code[at as usize..at as usize + 4].copy_from_slice(&value.to_le_bytes());
        Ok(())
    };
    let mut fixups = Vec::new();
    for (slot, &target) in got.iter().enumerate() {
        fixups.push(Fixup::Abs64 { at: got_base + 8 * slot as u64, target: local(target), addend: 0 });
    }
    let mut trampoline_of = HashMap::new();
    for (n, &i) in calls.iter().enumerate() {
        // jmp *GOT(%rip); int3; int3
        let at = trampolines + 8 * n as u64;
        let slot = got_base + 8 * got_index[&Target::Import(i)] as u64;
        code[at as usize..at as usize + 2].copy_from_slice(&[0xff, 0x25]);
        rel32(&mut code, at + 2, i128::from(slot) - i128::from(at + 6))?;
        code[at as usize + 6..at as usize + 8].copy_from_slice(&[0xcc, 0xcc]);
        trampoline_of.insert(i, at);
    }
    let applied = relas.iter().filter(|r| sections.get(r.section).is_some_and(allocated));
    for (r, &target) in applied.zip(&targets) {
        let at = place[r.section].expect("allocated section") + r.offset;
        let a = i128::from(r.addend);
        match (r.kind, local(target)) {
            (R_X86_64_64, resolved) => fixups.push(Fixup::Abs64 { at, target: resolved, addend: r.addend }),
            (R_X86_64_PC32 | R_X86_64_PLT32, Target::Local(s)) => rel32(&mut code, at, i128::from(s) + a - i128::from(at))?,
            (R_X86_64_PLT32, Target::Import(i)) => {
                fixups.push(Fixup::Call32 { at, import: i, addend: r.addend, trampoline: trampoline_of[&i] })
            }
            (R_X86_64_GOTPCREL | R_X86_64_GOTPCRELX | R_X86_64_REX_GOTPCRELX, resolved) => {
                if let (true, Target::Local(s)) = (relaxable(r), resolved) {
                    code[at as usize - 2] = 0x8d;
                    rel32(&mut code, at, i128::from(s) + a - i128::from(at))?;
                } else {
                    let slot = got_base + 8 * got_index[&target] as u64;
                    rel32(&mut code, at, i128::from(slot) + a - i128::from(at))?;
                }
            }
            _ => return Err(unsupported(r)),
        }
    }

    let defined: HashMap<&str, u64> = symbols
        .iter()
        .filter(|s| s.section != SHN_UNDEF && s.section < SHN_LORESERVE)
        .filter_map(|s| Some((s.name.as_str(), place.get(s.section as usize).copied().flatten()? + s.value)))
        .collect();
    let mut functions = Vec::with_capacity(program.functions.len());
    for (f, compiled) in program.functions.iter().zip(&object.functions) {
        let find = |name: String| defined.get(name.as_str()).copied().ok_or(format!("program object lacks {name}"));
        functions.push(FunctionCode {
            direct: find(format!("botlish_fn_{}", f.id))?,
            direct_size: compiled.direct_size,
            entry: find(format!("botlish_entry_{}", f.id))?,
            entry_size: compiled.entry_size,
            safepoints: compiled.safepoints.clone(),
        });
    }
    Ok(Image {
        info: crate::program_info(program),
        constants: object.pool.entries.clone(),
        statics: program.statics,
        imports,
        code,
        size,
        executable,
        fixups,
        functions,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    /// A program that calls one C function and declares two libraries.
    const FFI_PROGRAM: &str = concat!(
        "nir 1 call-effects=1 statics=0\n",
        "link \"first\"\n",
        "link \"second\"\n",
        "foreign 0 \"c_add\" params=\"i32 i32\" result=i32 name=\"m::add\"\n\n",
        "func 0 \"<program>\" params=0 env=0 regs=3 pnames=\"\" captures=0\n",
        "    %0 = int 40\n    %1 = int 2\n    %2 = foreigncall 0 %0 %1\n    ret %2\nend\n",
    );

    /// The link plan reaches the system linker as one group, in the plan's
    /// order, after the search directories: GNU ld and gold resolve a static
    /// archive only against what precedes it, so without the group an
    /// archive declared before the archive that needs it would leave its
    /// symbols undefined (lld, rustc's own x86-64 linker, does not care:
    /// tests/c-ffi.test's cf-link-order shows the group's effect where the
    /// linker is GNU ld).
    #[test]
    fn ffi_link_plan_is_one_linker_group() {
        let program = crate::nir::parse(FFI_PROGRAM).unwrap_or_else(|e| panic!("{}", e.message));
        assert!(calls_c(&program));
        let args = link_plan_args(&program, &["/opt/lib".to_string()]);
        let links: Vec<&str> = args.iter().filter(|a| *a != "-C").map(String::as_str).collect();
        assert_eq!(
            links,
            vec![
                "default-linker-libraries=yes",
                "link-arg=-L/opt/lib",
                "link-arg=-Wl,--start-group",
                "link-arg=-lfirst",
                "link-arg=-lsecond",
                "link-arg=-Wl,--end-group"
            ]
        );
        assert_eq!(describe_link_plan(&program), "symbols c_add; libraries -lfirst -lsecond");
    }

    /// An ordinary program passes the linker nothing.
    #[test]
    fn ffi_link_plan_is_empty_without_c() {
        let text = FFI_PROGRAM.replace("link \"first\"\n", "").replace("link \"second\"\n", "")
            .replace("foreign 0 \"c_add\" params=\"i32 i32\" result=i32 name=\"m::add\"\n", "")
            .replace("%2 = foreigncall 0 %0 %1", "%2 = int 42");
        let program = crate::nir::parse(&text).unwrap_or_else(|e| panic!("{}", e.message));
        assert!(!calls_c(&program));
        assert!(link_plan_args(&program, &["/opt/lib".to_string()]).is_empty());
    }
}

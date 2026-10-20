# make-patch.py -- the edits behind audit/windows-toolchain/probe.patch
# (WINDOWS-TOOLCHAIN-CENSUS.md).
#
#   python3 make-patch.py COPY
#
# Applies the Windows probe's edits in place to COPY/native/, a scratch copy
# of a checkout's native/ (never the checkout itself); `diff -ruN` against an
# unedited copy gives probe.patch. Each edit names the exact text it
# replaces, so a change to the code it touches fails loudly here rather than
# producing a patch that no longer means the same thing.
import os
import sys

root = sys.argv[1]
if os.path.isdir(os.path.join(root, ".git")):
    sys.exit("make-patch.py: refusing to edit a git checkout; give it a scratch copy")
def sub(path, old, new):
    path = f"{root}/{path}"
    s = open(path).read()
    assert s.count(old) == 1, (path, old[:70])
    open(path, "w").write(s.replace(old, new))

sub("native/src/main.rs", """    use std::os::unix::ffi::OsStrExt;
    use std::os::unix::process::CommandExt;
    let result = work.join("result");
    let mut child = std::process::Command::new(&executable);
    child
        .arg0(std::ffi::OsStr::from_bytes(first))
        .args(rest.iter().map(|a| std::ffi::OsStr::from_bytes(a)))
""", """    let result = work.join("result");
    let mut child = std::process::Command::new(&executable);
    #[cfg(unix)]
    {
        use std::os::unix::ffi::OsStrExt;
        use std::os::unix::process::CommandExt;
        child.arg0(std::ffi::OsStr::from_bytes(first)).args(rest.iter().map(|a| std::ffi::OsStr::from_bytes(a)));
    }
    // WINDOWS PROBE: Windows has no separate argv[0], and its arguments are
    // UTF-16: the bytes are passed as text (ARGV.md's byte snapshot has no
    // Windows form yet).
    #[cfg(windows)]
    {
        let _ = first;
        child.args(rest.iter().map(|a| String::from_utf8_lossy(a).into_owned()));
    }
    child
""")
sub("native/src/codegen/aot.rs", """    {
        use std::os::unix::fs::PermissionsExt;""", """    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;""")
for name in ("EXECUTABLES", "C_CALLS"):
    sub("native/src/codegen/aot.rs", f"""const {name}: bool = cfg!(any(
    all(target_os = "linux", target_env = "gnu", any(target_arch = "x86_64", target_arch = "aarch64")),""", f"""const {name}: bool = cfg!(any(
    all(target_os = "windows", target_arch = "x86_64"), // WINDOWS PROBE
    all(target_os = "linux", target_env = "gnu", any(target_arch = "x86_64", target_arch = "aarch64")),""")
sub("native/src/codegen/aot.rs", """        use std::os::unix::ffi::OsStringExt;\\n\\
        let argv: Vec<Vec<u8>> = std::env::args_os().map(|a| a.into_vec()).collect();\\n\\""",
"""        let argv: Vec<Vec<u8>> = std::env::args_os().map(|a| a.into_encoded_bytes()).collect();\\n\\""")
sub("native/src/codegen/aot.rs", """    /// Apple's ld through Apple clang: macOS.
    Apple,
}""", """    /// Apple's ld through Apple clang: macOS.
    Apple,
    /// WINDOWS PROBE: link.exe (or lld-link) through rustc's msvc targets.
    Msvc,
}""")
sub("native/src/codegen/aot.rs", """const LINKER: LinkerFlavor = if cfg!(target_vendor = "apple") { LinkerFlavor::Apple } else { LinkerFlavor::Gnu };""",
"""const LINKER: LinkerFlavor = if cfg!(target_vendor = "apple") {
    LinkerFlavor::Apple
} else if cfg!(target_env = "msvc") {
    LinkerFlavor::Msvc
} else {
    LinkerFlavor::Gnu
};""")
sub("native/src/codegen/aot.rs", """    args.extend(["-C".to_string(), "default-linker-libraries=yes".to_string()]);
    for dir in link_dirs {""", """    args.extend(["-C".to_string(), "default-linker-libraries=yes".to_string()]);
    // WINDOWS PROBE: link.exe's spelling of the same plan; it resolves
    // libraries in any order, so there is no group.
    if flavor == LinkerFlavor::Msvc {
        for dir in link_dirs {
            args.extend(["-C".to_string(), format!("link-arg=/LIBPATH:{dir}")]);
        }
        for library in &program.links {
            args.extend(["-C".to_string(), format!("link-arg={library}.lib")]);
        }
        return args;
    }
    for dir in link_dirs {""")
sub("native/src/codegen/mod.rs", """    if crate::runtime::native_stack::native_stack_overflow_supported() {
        set(&mut flags, "enable_probestack", "true")?;""", """    // WINDOWS PROBE: Windows commits a thread's stack one guard page at a
    // time, so a frame larger than a page must probe on Windows whether or
    // not an overflow guard exists.
    if crate::runtime::native_stack::native_stack_overflow_supported() || cfg!(windows) {
        set(&mut flags, "enable_probestack", "true")?;""")
sub("native/src/codegen/clif.rs", """        let stack_maps = matches!(module.isa().name(), "x64" | "aarch64");""",
"""        // WINDOWS PROBE: BOTLISH_PROBE_SHADOW=1 keeps every function with a
        // Botlish call on the shadow stack (the fallback root plan), to tell
        // the native-frame walk's failure from the fallback's.
        let stack_maps = matches!(module.isa().name(), "x64" | "aarch64")
            && !(cfg!(windows) && std::env::var_os("BOTLISH_PROBE_SHADOW").is_some());""")
# The linker's own output names on Windows: MinGW's gcc appends .exe to an
# output without an extension (link.exe does not), so the work files carry it.
sub("native/src/codegen/aot.rs", """    let executable = work.0.join("executable");
    std::fs::write(&object_path""", """    // WINDOWS PROBE: gcc (MinGW) appends .exe to an output without one.
    let executable = work.0.join(if cfg!(windows) { "executable.exe" } else { "executable" });
    std::fs::write(&object_path""")
sub("native/src/main.rs", """    let executable = work.join("program");""", """    let executable = work.join(if cfg!(windows) { "program.exe" } else { "program" }); // WINDOWS PROBE""")
# BOTLISH_PROBE_ALL_SHADOW=1: every root on the shadow stack (leaf functions
# too) and no frame walk -- fix (a) of WINDOWS-TOOLCHAIN-CENSUS.md's B2.
sub("native/src/codegen/roots.rs", """    let storage = if native_frame_supported || !has_call {""", """    // WINDOWS PROBE: BOTLISH_PROBE_ALL_SHADOW=1 puts every root on the
    // shadow stack, leaf functions' too, so no root is found by a frame walk.
    let all_shadow = cfg!(windows) && std::env::var_os("BOTLISH_PROBE_ALL_SHADOW").is_some();
    let storage = if (native_frame_supported || !has_call) && !all_shadow {""")
sub("native/src/codegen/clif.rs", """            && !(cfg!(windows) && std::env::var_os("BOTLISH_PROBE_SHADOW").is_some());""",
"""            && !(cfg!(windows)
                && (std::env::var_os("BOTLISH_PROBE_SHADOW").is_some() || std::env::var_os("BOTLISH_PROBE_ALL_SHADOW").is_some()));""")
sub("native/src/runtime/framewalk.rs", """pub fn walk_from(map: &ProgramMap, start: usize, stack: Option<&NativeStack>, mut visit: impl FnMut(*mut Value)) {
    let mut record = start;""", """pub fn walk_from(map: &ProgramMap, start: usize, stack: Option<&NativeStack>, mut visit: impl FnMut(*mut Value)) {
    // WINDOWS PROBE: no frame walk under BOTLISH_PROBE_ALL_SHADOW=1.
    if cfg!(windows) && std::env::var_os("BOTLISH_PROBE_ALL_SHADOW").is_some() {
        return;
    }
    let mut record = start;""")
# BOTLISH_PROBE_CRT_STATIC=1: the startup crate links the C runtime statically.
sub("native/src/codegen/aot.rs", """        .args(link_plan_args(program, link_dirs))
        .arg(&source_path)""", """        .args(link_plan_args(program, link_dirs))
        // WINDOWS PROBE: BOTLISH_PROBE_CRT_STATIC=1 links the C runtime statically.
        .args(if std::env::var_os("BOTLISH_PROBE_CRT_STATIC").is_some() {
            vec!["-C", "target-feature=+crt-static"]
        } else {
            vec![]
        })
        .arg(&source_path)""")
# BOTLISH_PROBE_NO_WALK=1 (with BOTLISH_PROBE_SHADOW=1): the fallback plan
# with no frame walk -- fix (a) of B2 exactly.
sub("native/src/runtime/framewalk.rs", """    if cfg!(windows) && std::env::var_os("BOTLISH_PROBE_ALL_SHADOW").is_some() {""",
"""    if cfg!(windows)
        && (std::env::var_os("BOTLISH_PROBE_ALL_SHADOW").is_some() || std::env::var_os("BOTLISH_PROBE_NO_WALK").is_some())
    {""")
sub("native/src/runtime/framewalk.rs", """    // WINDOWS PROBE: no frame walk under BOTLISH_PROBE_ALL_SHADOW=1.""", """    // WINDOWS PROBE: no frame walk under BOTLISH_PROBE_ALL_SHADOW=1 or
    // BOTLISH_PROBE_NO_WALK=1.""")
# BOTLISH_PROBE_KEEP_LINK=DIR: copy the link inputs (program object, startup
# crate, link plan) to DIR and stop before rustc -- for a Windows driver run
# under Wine, which cannot wait for the Linux rustc it would start.
sub("native/src/codegen/aot.rs", """    std::fs::write(&source_path, startup(program, &object)).map_err(|e| e.to_string())?;
""", """    std::fs::write(&source_path, startup(program, &object)).map_err(|e| e.to_string())?;
    // WINDOWS PROBE: BOTLISH_PROBE_KEEP_LINK=DIR keeps the link inputs in DIR
    // and stops before rustc (Wine cannot wait for a Linux rustc).
    if let Some(keep) = std::env::var_os("BOTLISH_PROBE_KEEP_LINK") {
        let keep = PathBuf::from(keep);
        std::fs::copy(&object_path, keep.join("program.obj")).map_err(|e| e.to_string())?;
        std::fs::copy(&source_path, keep.join("startup.rs")).map_err(|e| e.to_string())?;
        std::fs::write(keep.join("link-plan.txt"), link_plan_args(program, link_dirs).join("\\n"))
            .map_err(|e| e.to_string())?;
        return Ok(());
    }
""")
print("probe edits applied to", os.path.join(root, "native"))

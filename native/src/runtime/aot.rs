//! Standalone executable startup. The initializer contains only constants,
//! function metadata and relocated stack maps; program instructions are
//! already machine code in the linked object.
//!
//! Process arguments (ARGV.md): the generated `main` collects the real
//! argument vector -- the `argc`/`argv` the C runtime hands the process
//! (glibc's on Linux, libSystem's on macOS), which Rust's runtime keeps and
//! `std::env::args_os` returns as raw `OsString`s, i.e. the exact bytes,
//! never decoded -- into one owned `Vec<Vec<u8>>` copy (it does not borrow
//! the C startup array) and passes
//! it to `run`, which installs it in the Vm as the run's argument snapshot
//! before the program's entry function executes. Nothing is validated here:
//! UTF-8 validation belongs to the `argv()` operation (`ops.rs`'s
//! `rt_argv`), so malformed arguments cannot fail a program that never
//! asks for them. `argc == 0` yields an empty snapshot, and `argv()` an
//! empty List.
//!
//! The driver protocol (C-FFI.md, "Running a program that calls C"). The
//! driver runs a program that calls C by linking it as an executable -- the
//! one way its foreign symbols are resolved, by the system linker -- and
//! running that, with `BOTLISH_NATIVE_RESULT` naming a file: the executable
//! then reports exactly as `botlish-native run` does (result lines `value
//! V` / `error CODE MESSAGE` in the host value format, the overflow guard's
//! report among them) to that file instead of printing its value, and
//! leaves its standard output and error to the program. With
//! `BOTLISH_NATIVE_RUNS=N` it runs the program N times, as `bench` does,
//! reporting `times` and `timing` lines (`BOTLISH_NATIVE_COMPILE_US`, the
//! driver's compile and link time, is the timing line's first field). An
//! ordinary run of the executable, with neither variable, is unchanged.
use super::error::RtError;
use super::metrics::AllocMode;
use super::show::{show, tcl_list, tcl_value};
use super::value::{NO_VALUE, Value};
use super::vm::Vm;
use std::io::Write;

pub type ProgramEntry = extern "C" fn(*mut Vm) -> Value;

pub fn run(argv: Vec<Vec<u8>>, init: impl FnOnce() -> (Box<Vm>, ProgramEntry) + Send + 'static) -> i32 {
    let stack_size = std::env::var("BOTLISH_NATIVE_STACK_BYTES")
        .ok()
        .and_then(|text| text.parse::<usize>().ok())
        .filter(|&size| size >= 1 << 20)
        .unwrap_or(1 << 30);
    let protocol = std::env::var_os("BOTLISH_NATIVE_RESULT").filter(|p| !p.is_empty());
    let worker = std::thread::Builder::new().stack_size(stack_size).spawn(move || {
        let (mut vm, entry) = init();
        vm.set_argv(argv);
        debug_assert!(matches!(vm.metrics.mode, AllocMode::Off));
        if let Some(path) = protocol {
            return driver_protocol(std::path::Path::new(&path), &mut vm, entry);
        }
        #[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64")))]
        let _guard = {
            let stack = super::native_stack::NativeStack::current().expect("pthread stack bounds");
            super::platform::OverflowGuard::install_executable(&stack).expect("pthread stack guard")
        };
        let result = entry(&mut *vm);
        if result == NO_VALUE {
            let error = vm
                .error
                .take()
                .unwrap_or_else(|| RtError::Bug("native code failed without recording an error".to_string()));
            eprintln!("{} ({})", vm.describe_error(&error), error.error_code().join(" "));
            return 1;
        }
        match writeln!(std::io::stdout().lock(), "{}", show(result)) {
            Ok(()) => 0,
            Err(error) => {
                eprintln!("{error} (NATIVE IO)");
                1
            }
        }
    });
    match worker {
        Ok(worker) => match worker.join() {
            Ok(status) => status,
            Err(_) => {
                eprintln!("native executable panicked (NATIVE BUG)");
                1
            }
        },
        Err(error) => {
            eprintln!("{error} (NATIVE STARTUP)");
            1
        }
    }
}

/// Runs the program as `botlish-native run` (or `bench`) would and writes its
/// result lines to PATH (the header's "driver protocol"). Returns the exit
/// status: 0 whenever the result lines were written, a program error
/// included.
fn driver_protocol(path: &std::path::Path, vm: &mut Vm, entry: ProgramEntry) -> i32 {
    let mut file = match std::fs::File::create(path) {
        Ok(file) => file,
        Err(error) => {
            eprintln!("{}: {error} (NATIVE IO)", path.display());
            return 2;
        }
    };
    #[cfg(any(all(target_os = "linux", any(target_arch = "x86_64", target_arch = "aarch64")), all(target_os = "macos", target_arch = "aarch64")))]
    let _guard = {
        super::platform::set_result_fd(std::os::unix::io::AsRawFd::as_raw_fd(&file));
        let stack = super::native_stack::NativeStack::current().expect("pthread stack bounds");
        super::platform::OverflowGuard::install(&stack).expect("pthread stack guard")
    };
    let runs = std::env::var("BOTLISH_NATIVE_RUNS").ok().and_then(|n| n.parse::<usize>().ok()).filter(|n| *n > 0);
    let mut lines = Vec::new();
    let mut result = NO_VALUE;
    let mut nanos = Vec::new();
    let mut best = u128::MAX;
    for run in 0..runs.unwrap_or(1) {
        if run > 0 {
            vm.reset();
        }
        let started = std::time::Instant::now();
        result = entry(&mut *vm);
        let elapsed = started.elapsed();
        nanos.push(elapsed.as_nanos().to_string());
        best = best.min(elapsed.as_micros());
        if result == NO_VALUE {
            break;
        }
    }
    if let Some(runs) = runs {
        let compile = std::env::var("BOTLISH_NATIVE_COMPILE_US").unwrap_or_else(|_| "0".to_string());
        lines.push(format!("times {}", nanos.join(" ")));
        lines.push(format!("timing {compile} {best} {runs} {}", vm.heap.collections));
    }
    if result == NO_VALUE {
        let error = vm
            .error
            .take()
            .unwrap_or_else(|| RtError::Bug("native code failed without recording an error".to_string()));
        let code: Vec<String> = error.error_code().iter().map(|w| w.to_string()).collect();
        lines.push(tcl_list(&["error".to_string(), tcl_list(&code), vm.describe_error(&error)]));
    } else {
        match tcl_value(result) {
            Ok(value) => lines.push(tcl_list(&["value".to_string(), value])),
            Err(error) => {
                let code: Vec<String> = error.error_code().iter().map(|w| w.to_string()).collect();
                lines.push(tcl_list(&["error".to_string(), tcl_list(&code), error.message()]));
            }
        }
    }
    for line in lines {
        if writeln!(file, "{line}").is_err() {
            return 2;
        }
    }
    0
}

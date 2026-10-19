//! Native stack bounds and guards, as the host's thread library and kernel
//! report and enforce them (MACOS-AARCH64-MILESTONE-4.md).
//!
//! Not a libtest harness (`harness = false` in Cargo.toml): `main` runs on
//! the process's own main thread, which libtest never runs a test on, so the
//! main thread's facts are observed here as they are. Every check that
//! faults on purpose runs in a child process -- this same executable, re-run
//! with `BOTLISH_STACK_TEST_CHILD` naming the scenario -- and the parent
//! reads its exit status, its terminating signal and its output: nothing
//! faults in the parent.
//!
//! Prints one line per check (and the raw facts each one saw, for the CI
//! log) and exits 1 if any check failed.
use std::process::{Command, ExitStatus};

// ---------------------------------------------------------------------------
// Raw facts, straight from the thread library (not the runtime's reading)

#[derive(Clone, Copy, Debug)]
struct Raw {
    /// The lowest usable address of the stack.
    low: usize,
    /// One past its highest address.
    high: usize,
    /// The guard size the thread library reports, where it reports one.
    reported_guard: Option<usize>,
}

#[cfg(target_os = "macos")]
fn raw_stack() -> Raw {
    // SAFETY: both read the current thread's own descriptor.
    unsafe {
        let thread = libc::pthread_self();
        let high = libc::pthread_get_stackaddr_np(thread) as usize;
        let size = libc::pthread_get_stacksize_np(thread);
        Raw { low: high - size, high, reported_guard: None }
    }
}

#[cfg(target_os = "linux")]
fn raw_stack() -> Raw {
    // SAFETY: the attribute object is initialized by pthread_getattr_np and
    // destroyed once read.
    unsafe {
        let mut attr = std::mem::MaybeUninit::<libc::pthread_attr_t>::uninit();
        assert_eq!(libc::pthread_getattr_np(libc::pthread_self(), attr.as_mut_ptr()), 0);
        let mut attr = attr.assume_init();
        let mut base: *mut libc::c_void = std::ptr::null_mut();
        let mut size = 0usize;
        let mut guard = 0usize;
        assert_eq!(libc::pthread_attr_getstack(&attr, &mut base, &mut size), 0);
        assert_eq!(libc::pthread_attr_getguardsize(&attr, &mut guard), 0);
        libc::pthread_attr_destroy(&mut attr);
        Raw { low: base as usize, high: base as usize + size, reported_guard: Some(guard) }
    }
}

fn page_size() -> usize {
    // SAFETY: no preconditions.
    unsafe { libc::sysconf(libc::_SC_PAGESIZE) as usize }
}

#[inline(always)]
fn current_sp() -> usize {
    let sp: usize;
    // SAFETY: reads a register.
    unsafe {
        #[cfg(target_arch = "x86_64")]
        std::arch::asm!("mov {}, rsp", out(reg) sp, options(nomem, nostack, preserves_flags));
        #[cfg(target_arch = "aarch64")]
        std::arch::asm!("mov {}, sp", out(reg) sp, options(nomem, nostack, preserves_flags));
    }
    sp
}

/// The mapping containing ADDRESS: its start, its end and its protection
/// (`rwx` letters, `---` for none), or None when nothing is mapped there.
#[cfg(target_os = "macos")]
fn region(address: usize) -> Option<(usize, usize, String)> {
    #[repr(C, packed(4))]
    #[derive(Default)]
    struct BasicInfo64 {
        protection: i32,
        max_protection: i32,
        inheritance: u32,
        shared: u32,
        reserved: u32,
        offset: u64,
        behavior: i32,
        user_wired_count: u16,
    }
    const VM_REGION_BASIC_INFO_64: i32 = 9;
    unsafe extern "C" {
        static mach_task_self_: libc::mach_port_t;
        fn mach_vm_region(task: libc::mach_port_t, address: *mut u64, size: *mut u64, flavor: i32,
            info: *mut i32, count: *mut u32, object_name: *mut libc::mach_port_t) -> libc::kern_return_t;
    }
    let mut start = address as u64;
    let mut size = 0u64;
    let mut info = BasicInfo64::default();
    let mut count = (std::mem::size_of::<BasicInfo64>() / 4) as u32;
    let mut object = 0;
    // SAFETY: every out-parameter points at storage of the size COUNT says.
    let kr = unsafe {
        mach_vm_region(mach_task_self_, &mut start, &mut size, VM_REGION_BASIC_INFO_64,
            (&mut info as *mut BasicInfo64).cast(), &mut count, &mut object)
    };
    if kr != 0 || start as usize > address {
        return None;
    }
    let p = info.protection;
    let text = format!("{}{}{}", if p & 1 != 0 { "r" } else { "-" }, if p & 2 != 0 { "w" } else { "-" },
        if p & 4 != 0 { "x" } else { "-" });
    Some((start as usize, (start + size) as usize, text))
}

#[cfg(target_os = "linux")]
fn region(address: usize) -> Option<(usize, usize, String)> {
    let maps = std::fs::read_to_string("/proc/self/maps").ok()?;
    for line in maps.lines() {
        let mut fields = line.split_whitespace();
        let range = fields.next()?;
        let perms = fields.next()?;
        let (a, b) = range.split_once('-')?;
        let (a, b) = (usize::from_str_radix(a, 16).ok()?, usize::from_str_radix(b, 16).ok()?);
        if a <= address && address < b {
            return Some((a, b, perms[..3].to_string()));
        }
    }
    None
}

fn describe_region(address: usize) -> String {
    match region(address) {
        Some((start, end, prot)) => format!("{prot} [{start:#x}, {end:#x}) ({} KiB)", (end - start) / 1024),
        None => "unmapped".to_string(),
    }
}

// ---------------------------------------------------------------------------
// Threads

/// Runs F on a thread the thread library creates with STACK bytes (None: its
/// default) and GUARD bytes of guard (None: its default), as a raw pthread so
/// that the guard size can be chosen.
fn on_pthread<T: Send + 'static>(stack: Option<usize>, guard: Option<usize>, f: impl FnOnce() -> T + Send + 'static) -> T {
    extern "C" fn start(arg: *mut libc::c_void) -> *mut libc::c_void {
        // SAFETY: ARG is the Box<Box<dyn FnOnce()>> made below, used once.
        let f = unsafe { Box::from_raw(arg as *mut Box<dyn FnOnce()>) };
        f();
        std::ptr::null_mut()
    }
    let result = std::sync::Arc::new(std::sync::Mutex::new(None));
    let out = result.clone();
    let job: Box<dyn FnOnce()> = Box::new(move || {
        *out.lock().unwrap() = Some(f());
    });
    let arg = Box::into_raw(Box::new(job));
    // SAFETY: the attribute object lives until pthread_create returns; the
    // thread is joined before RESULT is read.
    unsafe {
        let mut attr = std::mem::MaybeUninit::<libc::pthread_attr_t>::uninit();
        assert_eq!(libc::pthread_attr_init(attr.as_mut_ptr()), 0);
        let mut attr = attr.assume_init();
        if let Some(stack) = stack {
            assert_eq!(libc::pthread_attr_setstacksize(&mut attr, stack), 0);
        }
        if let Some(guard) = guard {
            unsafe extern "C" {
                // POSIX; the libc crate declares it for neither host.
                fn pthread_attr_setguardsize(attr: *mut libc::pthread_attr_t, guard: libc::size_t) -> libc::c_int;
            }
            assert_eq!(pthread_attr_setguardsize(&mut attr, guard), 0);
        }
        let mut thread = std::mem::MaybeUninit::<libc::pthread_t>::uninit();
        assert_eq!(libc::pthread_create(thread.as_mut_ptr(), &attr, start, arg.cast()), 0);
        libc::pthread_attr_destroy(&mut attr);
        assert_eq!(libc::pthread_join(thread.assume_init(), std::ptr::null_mut()), 0);
    }
    result.lock().unwrap().take().expect("the thread ran")
}

/// The threads every fact is gathered on, by name: the process's main
/// thread, std's default thread, a 1 MiB and a 1 GiB std thread (the
/// driver's and a standalone executable's worker, main.rs and runtime/aot.rs),
/// and raw pthreads with a four-page guard and with none.
const THREADS: &[&str] = &["main", "std-default", "std-1MiB", "std-1GiB", "pthread-guard-4-pages", "pthread-no-guard"];

fn on_thread<T: Send + 'static>(name: &str, f: impl FnOnce() -> T + Send + 'static) -> T {
    match name {
        "main" => f(),
        "std-default" => std::thread::spawn(f).join().unwrap(),
        "std-1MiB" => std::thread::Builder::new().stack_size(1 << 20).spawn(f).unwrap().join().unwrap(),
        "std-1GiB" => std::thread::Builder::new().stack_size(1 << 30).spawn(f).unwrap().join().unwrap(),
        "pthread-guard-4-pages" => on_pthread(Some(1 << 20), Some(4 * page_size()), f),
        "pthread-no-guard" => on_pthread(Some(1 << 20), Some(0), f),
        other => panic!("no thread {other}"),
    }
}

// ---------------------------------------------------------------------------
// Child scenarios (each runs alone, in its own process)

/// `touch:THREAD:WHERE`: reads one byte, on THREAD, at WHERE relative to the
/// thread library's stack: `below` (the byte below the lowest usable one),
/// `page-below` (one page below it) or `low` (the lowest usable byte). Prints
/// `survived` when the read returned.
fn child(scenario: &str) -> ! {
    let parts: Vec<&str> = scenario.split(':').collect();
    match parts.as_slice() {
        ["touch", thread, place] => {
            let place = place.to_string();
            // The kernel's own signal, not Rust's report of it: std's
            // handler would turn a fault in what it takes for the guard into
            // its stack-overflow abort.
            // SAFETY: restores the default disposition before anything faults.
            unsafe {
                libc::signal(libc::SIGSEGV, libc::SIG_DFL);
                libc::signal(libc::SIGBUS, libc::SIG_DFL);
            }
            on_thread(thread, move || {
                let raw = raw_stack();
                let address = match place.as_str() {
                    "below" => raw.low - 1,
                    "page-below" => raw.low - page_size(),
                    "low" => raw.low,
                    other => panic!("no place {other}"),
                };
                // SAFETY: deliberately not: the read may fault, which is what
                // the parent observes.
                let byte = unsafe { std::ptr::read_volatile(address as *const u8) };
                std::hint::black_box(byte);
                println!("survived");
            });
            std::process::exit(0)
        }
        _ => {
            eprintln!("no child scenario {scenario}");
            std::process::exit(2)
        }
    }
}

struct Outcome {
    status: ExitStatus,
    stdout: String,
    stderr: String,
}

impl Outcome {
    fn signal(&self) -> Option<i32> {
        std::os::unix::process::ExitStatusExt::signal(&self.status)
    }

    fn brief(&self) -> String {
        match self.signal() {
            Some(signal) => format!("killed by signal {signal} ({})", signal_name(signal)),
            None => format!("exit {} stdout {:?}", self.status.code().unwrap_or(-1), self.stdout.trim()),
        }
    }
}

fn signal_name(signal: i32) -> &'static str {
    match signal {
        libc::SIGSEGV => "SIGSEGV",
        libc::SIGBUS => "SIGBUS",
        libc::SIGABRT => "SIGABRT",
        libc::SIGILL => "SIGILL",
        libc::SIGTRAP => "SIGTRAP",
        _ => "other",
    }
}

fn run_child(scenario: &str) -> Outcome {
    let output = Command::new(std::env::current_exe().expect("the test executable"))
        .env("BOTLISH_STACK_TEST_CHILD", scenario)
        .output()
        .expect("the child ran");
    Outcome {
        status: output.status,
        stdout: String::from_utf8_lossy(&output.stdout).into_owned(),
        stderr: String::from_utf8_lossy(&output.stderr).into_owned(),
    }
}

// ---------------------------------------------------------------------------
// Checks

struct Report {
    failures: usize,
}

impl Report {
    fn check(&mut self, name: &str, ok: bool, detail: impl AsRef<str>) {
        println!("{} {name}: {}", if ok { "ok  " } else { "FAIL" }, detail.as_ref());
        if !ok {
            self.failures += 1;
        }
    }

    fn note(&self, text: impl AsRef<str>) {
        println!("     {}", text.as_ref());
    }
}

/// The thread library's facts on every thread of THREADS: the current stack
/// pointer lies inside the reported stack, the stack is page-aligned, nested
/// calls stay inside it, and what is mapped around it.
fn facts(report: &mut Report) {
    let page = page_size();
    report.note(format!("page size {page} bytes ({} KiB)", page / 1024));
    for &thread in THREADS {
        let (raw, sp, nested_ok, below, below_page, at_low, at_top) = on_thread(thread, move || {
            let raw = raw_stack();
            let sp = current_sp();
            // Nested ordinary calls: each one's stack pointer is inside the
            // stack and below its caller's.
            fn nest(depth: usize, raw: Raw, outer: usize) -> bool {
                let sp = current_sp();
                let ok = sp < outer && sp >= raw.low && sp < raw.high;
                std::hint::black_box([0u8; 64]);
                if depth == 0 { ok } else { ok && nest(depth - 1, raw, sp) }
            }
            let nested_ok = nest(200, raw, sp);
            (raw, sp, nested_ok, describe_region(raw.low - 1), describe_region(raw.low - page),
                describe_region(raw.low), describe_region(raw.high - 1))
        });
        let size = raw.high - raw.low;
        let inside = sp >= raw.low && sp < raw.high;
        let aligned = raw.low % page == 0 && raw.high % page == 0;
        report.check(&format!("facts {thread}"), inside && raw.low < raw.high && nested_ok,
            format!("stack [{:#x}, {:#x}) {} KiB, sp {sp:#x} ({} KiB below the top), page-aligned {aligned}, nested calls inside {nested_ok}{}",
                raw.low, raw.high, size / 1024, (raw.high - sp) / 1024,
                raw.reported_guard.map(|g| format!(", reported guard {g} bytes")).unwrap_or_default()));
        report.note(format!("the byte below: {below}"));
        report.note(format!("a page below:  {below_page}"));
        report.note(format!("lowest usable: {at_low}"));
        report.note(format!("highest:       {at_top}"));
    }
}

/// Whether the byte below each thread's stack, and the page below it, is
/// inaccessible (a read kills the process with SIGSEGV or SIGBUS) and the
/// lowest usable byte readable: observed, in child processes.
fn guard_probes(report: &mut Report) {
    for &thread in THREADS {
        for place in ["below", "page-below", "low"] {
            let outcome = run_child(&format!("touch:{thread}:{place}"));
            let faulted = matches!(outcome.signal(), Some(libc::SIGSEGV | libc::SIGBUS));
            let survived = outcome.status.success() && outcome.stdout.trim() == "survived";
            let expected = match (thread, place) {
                (_, "low") => survived,
                ("pthread-no-guard", _) => true,
                _ => faulted,
            };
            report.check(&format!("touch {thread} {place}"), expected, outcome.brief());
            if !outcome.stderr.trim().is_empty() {
                report.note(format!("stderr: {}", outcome.stderr.trim().lines().next().unwrap_or("")));
            }
        }
    }
}

fn main() {
    if let Ok(scenario) = std::env::var("BOTLISH_STACK_TEST_CHILD") {
        child(&scenario);
    }
    let mut report = Report { failures: 0 };
    facts(&mut report);
    guard_probes(&mut report);
    if report.failures > 0 {
        println!("{} native stack checks failed", report.failures);
        std::process::exit(1);
    }
    println!("every native stack check passed");
}

//! Execution tests: every `tests/run/NAME.pas` is transpiled, compiled and
//! run, and its standard output is compared with `tests/run/NAME.out`.
//!
//! Optional files next to the program:
//! - `NAME.in`: fed to the program as standard input
//! - `NAME.exitcode`: the expected exit code (default 0)
//!
//! Compiling each program as its own Cargo project would rebuild the runtime
//! every time, so all programs become binaries (`src/bin/NAME.rs`) of one
//! scratch package and a single `cargo build` compiles them all.

use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};

fn repo_root() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join("../..").canonicalize().unwrap()
}

#[test]
fn run_tests() {
    let dir = repo_root().join("tests/run");
    let mut programs: Vec<PathBuf> = std::fs::read_dir(&dir)
        .unwrap()
        .map(|entry| entry.unwrap().path())
        .filter(|p| p.extension().is_some_and(|e| e == "pas"))
        .collect();
    programs.sort();
    // `RUSCAL_TEST=name` runs just one test, which is handy while debugging.
    if let Ok(only) = std::env::var("RUSCAL_TEST") {
        programs.retain(|p| p.file_stem().unwrap().to_string_lossy() == only);
    }

    // `CARGO_TARGET_TMPDIR` is a scratch directory Cargo provides to
    // integration tests.
    let scratch = Path::new(env!("CARGO_TARGET_TMPDIR")).join("run-tests");
    let bin_dir = scratch.join("src/bin");
    std::fs::create_dir_all(&bin_dir).unwrap();

    let mut failures = Vec::new();
    let mut built = Vec::new();
    let mut features = vec!["crt".to_string(), "dos".to_string()];
    // Transpiling is independent for each program, so it's done in
    // parallel; the results come back in order.
    let transpiled = parallel_map(&programs, |path| ruscal::driver::transpile_file(path));
    for (path, result) in programs.iter().zip(transpiled) {
        match result {
            Ok(generated) => {
                // Each program is a binary in its own directory, so its unit
                // modules can sit next to its `main.rs`.
                let dir = bin_dir.join(&generated.name);
                std::fs::create_dir_all(&dir).unwrap();
                for (name, code) in &generated.files {
                    write_if_changed(&dir.join(name), code.as_bytes());
                }
                // A unit's module the program no longer has.
                for entry in std::fs::read_dir(&dir).unwrap() {
                    let file = entry.unwrap().path();
                    let name = file.file_name().unwrap().to_string_lossy().to_string();
                    if !generated.files.iter().any(|(n, _)| *n == name) {
                        std::fs::remove_file(file).unwrap();
                    }
                }
                features.extend(generated.features);
                built.push((path.clone(), generated.name));
            }
            // Units are compiled as part of the programs that use them.
            Err(message) if message.contains("is a unit") => {}
            Err(message) => failures.push(format!("{}: transpile failed:\n{message}", path.display())),
        }
    }
    // A program that's gone (or was only run on its own, `RUSCAL_TEST`)
    // isn't built: its directory goes. The rest keep their files, and
    // their modification times, so Cargo rebuilds only what changed.
    for entry in std::fs::read_dir(&bin_dir).unwrap() {
        let dir = entry.unwrap().path();
        let name = dir.file_name().unwrap().to_string_lossy().to_string();
        if !built.iter().any(|(_, built_name)| *built_name == name) {
            std::fs::remove_dir_all(dir).unwrap();
        }
    }
    features.sort();
    features.dedup();
    let mut toml = ruscal::driver::cargo_toml("ruscal_run_tests", &features);
    // `cargo_toml` writes a binary package; we only need its dependency and
    // profile sections, with autodiscovered `src/bin/*.rs` binaries.
    toml = toml.replace("[workspace]", "[workspace]\n\n[lib]\npath = \"src/lib.rs\"");
    write_if_changed(&scratch.join("Cargo.toml"), toml.as_bytes());
    write_if_changed(&scratch.join("src/lib.rs"), b"");

    // Generated code must compile without warnings, so any warning fails the
    // tests: `-D warnings` turns warnings into errors. (Cargo caps lints for
    // dependencies from crates.io, so only our code is affected.)
    let build = Command::new("cargo")
        .args(["build", "--quiet"])
        .env("RUSTFLAGS", "-D warnings")
        .current_dir(&scratch)
        .output()
        .unwrap();
    if !build.status.success() {
        panic!("generated code failed to compile:\n{}", String::from_utf8_lossy(&build.stderr));
    }

    // Each program runs in its own directory, so they can run in parallel.
    // That matters on macOS, which checks each binary it hasn't run for a
    // while before running it (a third of a second each, for 200 of them).
    let results = parallel_map(&built, |(path, name)| run_one(&scratch, path, name));
    failures.extend(results.into_iter().flatten());
    if !failures.is_empty() {
        panic!("{} run test failure(s):\n\n{}", failures.len(), failures.join("\n\n"));
    }
}

/// Write `contents` to `path` unless it holds them already: rewriting a
/// file Cargo builds would make it rebuild it (and all 200 programs, each
/// run, took two minutes).
fn write_if_changed(path: &Path, contents: &[u8]) {
    if std::fs::read(path).ok().as_deref() != Some(contents) {
        std::fs::write(path, contents).unwrap();
    }
}

/// Run one built test program and compare what it prints, and its exit
/// code, with what it should: the failures, if any.
fn run_one(scratch: &Path, path: &Path, name: &str) -> Vec<String> {
    let mut failures = Vec::new();
    let exe = scratch.join("target/debug").join(name);
    let input = std::fs::read(path.with_extension("in")).unwrap_or_default();
    // Run in an empty scratch directory, so files the program creates
    // don't land in the repository.
    let cwd = scratch.join("cwd").join(name);
    let _ = std::fs::remove_dir_all(&cwd);
    std::fs::create_dir_all(&cwd).unwrap();
    let mut child = Command::new(&exe)
        .current_dir(&cwd)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .env("RUSCAL_FAST", "1")
        .env("RUSCAL_GRAPH", "headless")
        // Drives C: and A: are the scratch directory, so tests that use
        // drive letters and `GetDir` give the same answers anywhere.
        .env("RUSCAL_DRIVE_C", ".")
        .env("RUSCAL_DRIVE_A", ".")
        .spawn()
        .unwrap();
    child.stdin.take().unwrap().write_all(&input).unwrap();
    let output = child.wait_with_output().unwrap();
    // Every test must say what it should print, and print something:
    // otherwise a program that silently does nothing (or can't write
    // at all) would pass.
    let Ok(expected) = std::fs::read(path.with_extension("out")) else {
        failures.push(format!("{}: has no .out file with the output it should print", path.display()));
        return failures;
    };
    if expected.is_empty() {
        failures.push(format!("{}: its .out file is empty; a test must print something to check", path.display()));
        return failures;
    }
    if output.stdout != expected {
        failures.push(format!(
            "{}: output differs\n--- expected\n{}\n--- actual\n{}\n--- stderr\n{}",
            path.display(),
            String::from_utf8_lossy(&expected),
            String::from_utf8_lossy(&output.stdout),
            String::from_utf8_lossy(&output.stderr),
        ));
    }
    let expected_code: i32 =
        std::fs::read_to_string(path.with_extension("exitcode")).map(|s| s.trim().parse().unwrap()).unwrap_or(0);
    if output.status.code() != Some(expected_code) {
        failures.push(format!(
            "{}: exit code {:?}, expected {expected_code}\n{}",
            path.display(),
            output.status.code(),
            String::from_utf8_lossy(&output.stderr)
        ));
    }
    failures
}

/// `f` applied to each item, on as many threads as the machine has cores,
/// in the items' order.
fn parallel_map<T: Sync, R: Send>(items: &[T], f: impl Fn(&T) -> R + Sync) -> Vec<R> {
    use std::sync::Mutex;
    use std::sync::atomic::{AtomicUsize, Ordering};
    let next = AtomicUsize::new(0);
    let results: Mutex<Vec<Option<R>>> = Mutex::new((0..items.len()).map(|_| None).collect());
    let threads = std::thread::available_parallelism().map_or(4, |n| n.get());
    std::thread::scope(|scope| {
        for _ in 0..threads {
            scope.spawn(|| {
                loop {
                    let i = next.fetch_add(1, Ordering::Relaxed);
                    let Some(item) = items.get(i) else { break };
                    let result = f(item);
                    results.lock().unwrap()[i] = Some(result);
                }
            });
        }
    });
    results.into_inner().unwrap().into_iter().map(|r| r.expect("every item was mapped")).collect()
}

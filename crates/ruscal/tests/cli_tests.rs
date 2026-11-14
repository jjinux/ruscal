//! The command-line tools' own behaviour: what they print, not what the
//! programs they build do.

use std::process::Command;

/// `ruscal build` says where the executable went (cargo's `--quiet` says
/// nothing), named after the program even when `-o` picks the directory.
#[test]
fn build_says_where_the_executable_is() {
    let tmp = std::path::Path::new(env!("CARGO_TARGET_TMPDIR")).join("cli_build");
    std::fs::create_dir_all(&tmp).unwrap();
    let source = tmp.join("greet.pas");
    std::fs::write(&source, "program Greet;\nbegin\n   WriteLn('hi');\nend.\n").unwrap();
    let dir = tmp.join("elsewhere");
    let output =
        Command::new(env!("CARGO_BIN_EXE_ruscal")).arg("build").arg(&source).arg("-o").arg(&dir).output().unwrap();
    assert!(output.status.success(), "{}", String::from_utf8_lossy(&output.stderr));
    let exe = dir.join("target/debug").join(format!("greet{}", std::env::consts::EXE_SUFFIX));
    let stdout = String::from_utf8_lossy(&output.stdout);
    assert_eq!(stdout.trim(), format!("built the executable: {}", exe.display()));
    assert!(exe.exists());
}

/// `tpc --help` (and `-h`, `-H`) prints the usage, as no arguments does, rather
/// than calling it an invalid option.
#[test]
fn tpc_help() {
    for flag in ["--help", "-h", "-H"] {
        let output = Command::new(env!("CARGO_BIN_EXE_tpc")).arg(flag).output().unwrap();
        assert!(output.status.success(), "{flag}: {}", String::from_utf8_lossy(&output.stderr));
        assert!(String::from_utf8_lossy(&output.stdout).contains("Syntax: tpc"));
    }
}

/// Each command's `--help` says what its file argument is.
#[test]
fn file_argument_help() {
    for cmd in ["emit", "build", "run"] {
        let output = Command::new(env!("CARGO_BIN_EXE_ruscal")).args([cmd, "--help"]).output().unwrap();
        assert!(String::from_utf8_lossy(&output.stdout).contains("The Pascal program"), "{cmd}");
    }
}

/// Run `ruscal run` on a small program, with `RUSCAL_RUNTIME` set to
/// `runtime`; its output.
fn run_with_runtime(dir: &str, runtime: &std::ffi::OsStr) -> std::process::Output {
    let tmp = std::path::Path::new(env!("CARGO_TARGET_TMPDIR")).join(dir);
    std::fs::create_dir_all(&tmp).unwrap();
    let source = tmp.join("greet.pas");
    std::fs::write(&source, "program Greet;\nbegin\n   WriteLn('hi');\nend.\n").unwrap();
    Command::new(env!("CARGO_BIN_EXE_ruscal"))
        .arg("run")
        .arg(&source)
        .arg("-o")
        .arg(tmp.join("out"))
        .env("RUSCAL_RUNTIME", runtime)
        .output()
        .unwrap()
}

/// A `RUSCAL_RUNTIME` with no runtime there gets a message saying so,
/// instead of Cargo's "failed to read .../Cargo.toml". (A path gone for
/// other reasons, a moved clone or a cleaned Cargo cache, gets advice on
/// building Ruscal again.)
#[test]
fn a_missing_runtime_says_what_to_do() {
    let gone = std::path::Path::new(env!("CARGO_TARGET_TMPDIR")).join("gone/crates/ruscal_runtime");
    let output = run_with_runtime("cli_no_runtime", gone.as_os_str());
    assert!(!output.status.success());
    let stderr = String::from_utf8_lossy(&output.stderr);
    assert!(stderr.contains("RUSCAL_RUNTIME is") && stderr.contains("which has no Cargo.toml"), "{stderr}");
}

/// An empty `RUSCAL_RUNTIME` counts as unset.
#[test]
fn an_empty_runtime_variable_is_ignored() {
    let output = run_with_runtime("cli_empty_runtime", std::ffi::OsStr::new(""));
    assert!(output.status.success(), "{}", String::from_utf8_lossy(&output.stderr));
    assert_eq!(String::from_utf8_lossy(&output.stdout).trim(), "hi");
}

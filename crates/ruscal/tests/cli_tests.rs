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

/// When the runtime has gone (Cargo cleaned up the copy a `cargo install
/// --git` left in its cache), `ruscal run` says so and what to do, instead
/// of Cargo's "failed to read .../Cargo.toml".
#[test]
fn a_missing_runtime_says_what_to_do() {
    let tmp = std::path::Path::new(env!("CARGO_TARGET_TMPDIR")).join("cli_no_runtime");
    std::fs::create_dir_all(&tmp).unwrap();
    let source = tmp.join("greet.pas");
    std::fs::write(&source, "program Greet;\nbegin\n   WriteLn('hi');\nend.\n").unwrap();
    let output = Command::new(env!("CARGO_BIN_EXE_ruscal"))
        .arg("run")
        .arg(&source)
        .arg("-o")
        .arg(tmp.join("out"))
        .env("RUSCAL_RUNTIME", tmp.join("gone/crates/ruscal_runtime"))
        .output()
        .unwrap();
    assert!(!output.status.success());
    let stderr = String::from_utf8_lossy(&output.stderr);
    assert!(stderr.contains("Ruscal's runtime isn't at") && stderr.contains("install Ruscal again"), "{stderr}");
}

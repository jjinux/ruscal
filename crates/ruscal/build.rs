//! Decide, when Ruscal itself is built, where the programs it translates
//! will get the runtime.
//!
//! Built from a checkout of Ruscal (`cargo run -p ruscal`, our tests,
//! `cargo install --path crates/ruscal`), they use the checkout's
//! `crates/ruscal_runtime` by path, so a change to the runtime is seen at
//! once. Installed from crates.io, they depend on `ruscal_runtime` from
//! crates.io, the same version as this translator (`driver::runtime_source`).
//!
//! This is decided here, once, rather than each time `ruscal` runs: if the
//! checkout later moved, a run-time test would quietly switch to an older
//! runtime from crates.io, and generated code wouldn't compile against it.

use std::path::Path;

fn main() {
    println!("cargo:rerun-if-changed=build.rs");
    let dir = std::env::var("CARGO_MANIFEST_DIR").unwrap();
    let dir = Path::new(&dir);
    let runtime = dir.join("../ruscal_runtime");
    // `cargo package` adds `Cargo.toml.orig` to a published crate, so a
    // crate from crates.io (or vendored from it, where the runtime may sit
    // beside it as `ruscal_runtime/`) isn't taken for a checkout.
    let checkout = runtime.join("Cargo.toml").is_file() && !dir.join("Cargo.toml.orig").exists();
    if checkout {
        let runtime = runtime.canonicalize().unwrap_or(runtime);
        // `cargo:rustc-env` sets an environment variable for compiling the
        // crate, which `option_env!` reads.
        println!("cargo:rustc-env=RUSCAL_CHECKOUT_RUNTIME={}", runtime.display());
    }
}

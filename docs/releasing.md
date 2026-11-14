# Releasing Ruscal

Ruscal is on crates.io as two crates: `ruscal` (the translator and its
tools) and `ruscal_runtime` (the library generated programs use). A
`ruscal` installed from crates.io writes projects that depend on
`ruscal_runtime` at exactly its own version, so the two are always
released together, with the same version.

## When to release

- When generated code needs something new or changed in the runtime: a
  `ruscal` from `main` and the runtime on crates.io don't fit until both
  are released. (Users of a clone don't notice; crates.io users do.)
- When a fix or a feature in the translator is worth having.
- Not for docs, tests or examples alone.

Never yank a release: every installed `ruscal` of that version, and every
project it generated (they have no `Cargo.lock` of their own until built),
asks for exactly that runtime version.

## How

1. Pick the version. Before 1.0, a change that breaks a Rust program
   using Ruscal (`ruscal::build`, the runtime's API) bumps the minor
   version (0.7 → 0.8); anything else the patch (0.7.0 → 0.7.1).
2. Change it everywhere:
   - `version` in the workspace `Cargo.toml`;
   - the `=X.Y.Z` of `ruscal_runtime` in `crates/ruscal/Cargo.toml` (Cargo
     refuses to build if it doesn't match);
   - the `=X.Y.Z` in `docs/embedding.md`, `README.md` and the comment in
     `examples/ruscal/rust_calls_pascal/Cargo.toml` (`docs_tests` checks
     these match the workspace version), and "Ruscal is version X.Y" in
     the README.
3. Run everything: `cargo test --workspace`, `cargo fmt --all --check`,
   `cargo clippy --workspace --all-targets -- -D warnings`.
4. Check the packages: `cargo publish --workspace --dry-run`. It builds
   `ruscal` against the packaged runtime, nothing is uploaded.
5. Commit ("Version X.Y.Z"), push, and wait for CI.
6. Publish: `cargo publish --workspace` (the runtime first, then `ruscal`;
   Cargo does the order). This can't be undone.
7. Tag it: `git tag vX.Y.Z && git push origin vX.Y.Z`.
8. Check it as a user would, in an empty directory outside any clone:
   `cargo install ruscal --force`, then `ruscal run` a program that uses
   `Crt`, and `tpc` one.

## The first time

- An account on crates.io (log in with GitHub), with a verified email.
- An API token (Account Settings → API Tokens), and `cargo login` with it,
  which saves it in `~/.cargo/credentials.toml`.

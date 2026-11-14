# Publishing Ruscal on crates.io

The user, 2026-11-13: a Pascal program, or a Rust program, should get
Ruscal from Cargo, not from a clone. Ruscal's own tests and examples keep
using the checkout by path. Publish a new version whenever something
needs it (above all a runtime change a translator needs).

## Today

- A generated project (`ruscal run`/`build`, `tpc`, `ruscal build --lib`)
  says `ruscal_runtime = { path = "<checkout>/crates/ruscal_runtime" }`:
  `driver::runtime_path` is `env!("CARGO_MANIFEST_DIR")/../ruscal_runtime`
  (or `RUSCAL_RUNTIME`). So the installed `ruscal` needs its clone, and
  after `cargo install --git` it points into Cargo's git cache, which Cargo
  deletes about a month later (`check_runtime` now says so).
- A Rust program with a `build.rs` depends on `ruscal` and
  `ruscal_runtime` by `git` (docs/embedding.md, the example's comment).

## Plan

1. **Where a generated project gets the runtime** (`driver.rs`):
   - `RUSCAL_RUNTIME` set: that path, as today.
   - Otherwise, if `ruscal` was built from a checkout (the sibling
     `CARGO_MANIFEST_DIR/../ruscal_runtime/Cargo.toml` exists): that path,
     as today. This covers `cargo run -p ruscal`, our tests, the examples,
     `cargo install --path crates/ruscal`, and `--git` installs (which stay
     on the path, so a translator from `main` never meets an older runtime
     from crates.io).
   - Otherwise (installed from crates.io: the registry unpacks
     `ruscal-0.7.0/` and `ruscal_runtime-0.7.0/` side by side, so there's no
     `ruscal_runtime` sibling): `ruscal_runtime = { version = "=0.7.0",
     features = [...] }`, the translator's own `CARGO_PKG_VERSION`. Exact
     (`=`), since generated code calls the runtime of the same version.
   - A small enum, `RuntimeSource::{Path(PathBuf), Version(&str)}`, chosen
     by `runtime_source()`; `cargo_toml_with` takes it, so a unit test can
     check the `version` form without a crates.io install.
   - `check_runtime` only checks a `Path` source.
   - The generated `Cargo.toml` says in a comment which it is ("the
     runtime of the Ruscal that translated this program").
2. **Packaging** (`Cargo.toml`s):
   - `ruscal`'s dependency: `ruscal_runtime = { path = "../ruscal_runtime",
     version = "=0.7.0", optional = true }` (Cargo uses the path here and
     the version on crates.io).
   - Both crates: `repository`, `keywords`, `categories`, and `readme`
     (`ruscal` the workspace README; the runtime a short line in its
     description is enough). `license` (MIT) and `description` are there.
   - `exclude` what a user doesn't need from `crates/ruscal` (its `tests/`
     with the snapshots; they reach outside the crate anyway). The
     runtime's one test that `include_bytes!`s `examples/database/mark.dat`
     only builds under `cargo test`, which the packaged crate isn't for.
   - `cargo publish --dry-run -p ruscal_runtime` must pass. For `ruscal`,
     a dry run can't resolve `ruscal_runtime =0.7.0` until it's published,
     so `cargo package -p ruscal --list` checks the file list, and the real
     check is after the runtime is published.
3. **Rust programs** (docs/embedding.md, the example's `Cargo.toml`
   comment): `ruscal_runtime = "=0.7.0"` and `ruscal = { version =
   "=0.7.0", default-features = false }` (the same version for both).
   The git form stays as a note, for a fix not yet released.
4. **README**: `cargo install ruscal` to use it; a clone (`cargo install
   --path crates/ruscal`, or `cargo run -p ruscal`) to work on it or run
   the examples. Drop the `--git` install and its cache caveat. The
   "start your own project" list keeps saying copy out of a clone.
5. **Releasing** (`docs/releasing.md`, linked from CLAUDE.md, and in
   TODO): when to release (a runtime change that generated code needs, a
   translator change worth having, a fix), and how: bump
   `workspace.package.version` and `ruscal`'s `=` runtime version, update
   the docs' version numbers (a test checks they match the workspace
   version), run the suite, `cargo publish -p ruscal_runtime`, then
   `cargo publish -p ruscal`, tag `vX.Y.Z` and push the tag.
6. **Tests**:
   - A unit test: `cargo_toml_with(.., RuntimeSource::Version("0.7.0"))`
     has `ruscal_runtime = { version = "=0.7.0", features = ["crt"] }`.
   - A test that the docs' version numbers (README, embedding.md, the
     example's comment) are the workspace version, so a release can't
     forget them.
   - The rest of the suite keeps running on the path source.

## Not doing

- A git dependency at the translator's commit (needs the commit at build
  time; superseded by crates.io).
- Publishing: that's the user's, with their crates.io account (walked
  through after the merge-ready branch).

## Fable's review of the plan, and what changed

- Deciding "built from a checkout" at run time would switch a `ruscal`
  whose clone moved (or whose `--git` cache was cleaned) to an older
  crates.io runtime: now `crates/ruscal/build.rs` decides when Ruscal is
  built, and `check_runtime` still reports a path that's gone.
- `cargo vendor` puts the runtime beside `ruscal` as `ruscal_runtime/`:
  a published crate has `Cargo.toml.orig` (added by `cargo package`), so
  that's not taken for a checkout.
- `cargo package --workspace` builds `ruscal` against the packaged
  runtime through a temporary local registry, so both can be checked
  before publishing (`cargo publish --workspace --dry-run`), and CI runs
  it.
- Each crate has its own short README (the repository's has relative
  links that crates.io would break) and a link to the LICENSE.
- Releasing: never yank (installed `ruscal`s and their projects pin
  `=X.Y.Z`), a smoke test after publishing; docs/releasing.md.
- Checked end to end with the packaged crates, the runtime stood in by a
  `[patch.crates-io]`: the packaged `ruscal` writes
  `ruscal_runtime = { version = "=0.7.0", ... }` and the program runs.

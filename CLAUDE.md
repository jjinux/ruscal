# Ruscal

A Turbo Pascal → Rust transpiler, written in Rust. It's a learning project:
the user is an intermediate Rust programmer who's fascinated by language
implementation. The opening prompt is in `README.md` before it was removed
(`git show 726b781:README.md`).

## Where things are decided

- `TODO.md`: the phased plan. Check items off as they land, and add new ones.
- `docs/architecture.md`: core design decisions and their rationale. If you
  deviate from it, update it in the same commit (and say why).
- `docs/language_spec.md`: which Pascal constructs are supported, by topic (and what isn't yet).
- `notes/`: research (p2c, Free Pascal) and answered questions for the user.
- `README.md`: what a user needs: what Ruscal is, how to run it (`ruscal`,
  `tpc`, `fmt`), the environment variables, what's supported, the examples.
- `docs/releasing.md`: publishing `ruscal` and `ruscal_runtime` on
  crates.io (the user does the publishing). Remind the user a release is
  due when generated code needs something new in the runtime, or after a
  major change.
- `docs/`: longer user documentation the README links to (printing, timer
  interrupts), so the README stays short. `docs/rust_limits.md` explains
  each error caused by a limit of Rust, with a worked rewrite; such an
  error links to its section (`sema::rewrite_link`, checked by
  `tests/docs_tests.rs`). A new error of that kind gets a section too.

Keep these up to date as you go: whenever a change adds or changes a
feature, a command, an option or a limitation, update `README.md`,
`docs/language_spec.md` and `docs/architecture.md` (and check off
`TODO.md`) in the same commit, not later. They drift quickly otherwise.

## Layout

- `crates/ruscal`: the transpiler (lexer → parser → sema → codegen → driver), bin + lib.
  `fmt/` is `ruscal fmt`, a source formatter that reuses the lexer.
- `crates/ruscal_runtime`: the library every generated program depends on
  (Pascal strings, I/O, `run()`, later `Crt`/`Dos`/`Graph` behind features).
- `tests/run/*.pas`: execution tests (`.out` expected stdout, optional `.in`, `.exitcode`).
- `tests/translate/*.pas`: snapshot tests of the generated Rust.
- `tests/errors/*.pas`: programs that must be rejected; snapshots of the messages.
- `examples/`: the user's own Turbo Pascal programs from the 90s, the acceptance test.
  `examples/ruscal/` holds Ruscal's own examples (formatted on their own).

## Commands

```sh
cargo test                                   # everything
cargo test -p ruscal --test run_tests      # execution tests only
RUSCAL_TEST=hello cargo test --test run_tests   # one execution test
INSTA_UPDATE=always cargo test --test translate_tests   # accept new snapshots, then review the git diff
cargo run -p ruscal -- emit file.pas       # print generated Rust
cargo run -p ruscal -- run file.pas        # transpile, build and run (project goes in out/)
cargo run -p ruscal -- fmt $(find examples -name '*.pas' -not -path '*/ruscal/*')   # the user's examples, together (checked by fmt_tests)
cargo run -p ruscal -- fmt tests/run/foo.pas  # format each new test program on its own (checked by fmt_tests)
cargo run -p ruscal -- fmt --crlf c/RUSCAL/FOO.PAS  # a Turbo Pascal 7 check program, keeping DOS line endings
tests/gen_expected.sh tests/run/foo.pas      # expected output from Free Pascal (fpc -Mtp)
cargo fmt --all && cargo clippy --workspace --all-targets -- -D warnings
```

## Licensing

Ruscal is MIT. Important: don't copy code or tests from Free Pascal,
Turbo Pascal, p2c, GNU Pascal or any other Pascal implementation: read
them for ideas only. (Turbo Pascal's own runtime source is in
`c/TP/SOURCE`; it's Borland's, not ours.) You may run them on your own
programs to see how they behave:

- `fpc -Mtp` gives most tests' expected output (`tests/gen_expected.sh`).
- Turbo Pascal 7 runs in DOSBox (`brew install --cask dosbox`), whose
  C: drive is `c/`, to settle what TP really did where Free Pascal
  differs. TP goes in `c/TP` (git-ignored), unzipped from
  https://archive.org/download/tp_20240418/TP.zip. Our programs that
  check it, and their output, are in `c/RUSCAL` (its `README.md`).

## Who it's for

Ruscal balances six uses; a change for one shouldn't cost another without
a good reason (docs/architecture.md, "Who Ruscal is for"):

1. Running an old Turbo Pascal program on a modern computer, not caring
   about the Rust in between.
2. Translating a program to Rust once, and working on the Rust from then on.
3. A Pascal program calling Rust code.
4. A Rust program calling Pascal code.
5. Reading and writing data that Turbo Pascal programs made long ago
   (`to-json`, `from-json`).
6. Improving the Pascal code itself (`ruscal fmt`).

So the generated Rust must stay readable by a human (use 2). Calling
helper functions in `ruscal_runtime` is fine when a Pascal construct
needs support code; what matters is that a reader can follow the
translated program, and can go on editing it: a named Pascal constant
stays a name, not a number worked out ahead of time.

## Style rules

- Write Rust the way an intermediate Rust programmer would: clear over clever.
- When you use an interesting Rust construct (lifetimes, `RefCell`, trait
  tricks, const generics, `macro_rules!`, let-else, ...), leave a short
  comment explaining it. Same for interesting Pascal semantics.
- Generated code must also read like hand-written Rust: no redundant
  parentheses, casts or `mut`, and teaching comments where a Pascal construct
  needed an unusual translation.
- Generated code must compile without warnings.
- Every new Pascal construct needs a translate test *and* a run test.
- Write Pascal test programs the way `ruscal fmt` formats them:
  3 spaces a level, as in the user's examples. Run `ruscal fmt` on each
  new test program.
- Commit as you go, with focused commits.

## Pull requests and reviews

Every change goes through a pull request on GitHub (the user, 2026-11-13);
nothing is committed straight to `main`.

1. Branch from `main` (`git worktree add ../ruscal-<name> -b <name>`
   keeps the main checkout free), commit as you go, and push the branch.
   (A new worktree has no `c/TP`, which is git-ignored: for Turbo Pascal
   checks in DOSBox, link it with `ln -s ../../ruscal/c/TP c/TP`.)
2. For a non-trivial feature, write a plan first (`notes/<name>.md`) and
   have Fable check it before building.
3. Open the PR with `gh pr create`: what it does and why, how it was
   tested, and anything the user should decide.
4. Have Claude Fable review the PR, the way you'd review any PR: a Fable
   subagent (the Agent tool with `model: "fable"`) gets the PR's diff
   (`gh pr diff`, or the exact commits), with the project's goals, and
   reproduces each finding about translation or behaviour with a small
   Pascal program (compared with `fpc -Mtp` where FPC matches TP). Its
   scratch files go in `out/review/`, and it must not read or search
   anything outside the PR's worktree.
5. Fix the straightforward findings on the branch (each with a test that
   fails without the fix), and ask the user about the rest (or put them
   in `TODO.md`). Have Fable review the fix commits too, until a review
   is clean. Post a short summary of the reviews and the fixes as a PR
   comment.
6. Merge when the reviews' fixes are in and CI is green, from the main
   checkout (`main` is checked out there, so not from the worktree):

   ```sh
   gh pr checks <n> --watch
   gh pr merge <n> --merge        # keeps the branch's commits
   git pull
   git worktree remove ../ruscal-<name>
   git branch -d <name>
   git push origin --delete <name>
   ```

   If `git worktree remove` refuses, look at what's left before using
   `--force`. For stacked PRs, merge the bottom one first, then retarget
   the next (`gh pr edit <next> --base main`) before deleting the merged
   branch. Don't rewrite a pushed branch (rebase,
   force-push): add commits, or merge `main` into it. A change that needs
   the user (publishing, a decision) waits for them.

Every commit on `main` must be covered by a Fable review. (Before the
switch, reviews went by commit range: see the "Fable code reviews" item
in `TODO.md`, now frozen.)

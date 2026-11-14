# Ruscal TODO

Plan written by Fable (the architect pass). Opus takes over from here. The
core decisions live in `docs/architecture.md`; what the language supports in
`docs/language_spec.md`; prior-art research in `notes/p2c.md`; questions for the
user in `notes/open_questions.md`. Check items off as they land. Every phase
ends with something runnable, and the examples in `examples/` are the
acceptance test for the whole project.

An item marked "PUNT:" won't be done in the short term (the user, 2026-11-06):
it's kept for the record and checked off, so the open boxes count only what's
planned. The goal is to get to done.

## For the user (things Claude can't do)

Claude can't watch a window, press keys in a real terminal, or run the real
Turbo Pascal. These need you; tell Claude what you find, and it fixes it.

- [x] Play each interactive example by hand with `cargo run -p ruscal -- run <file>` and note anything that looks or behaves differently from how you remember it:
  - [x] Text mode (Crt). Done: `database/filesys.pas` (the user, 2026-11-06: "working"), `airport/airport4.pas` (the user, 2026-11-06: "works fine"), `blkjack.pas` (the user, 2026-11-05: "It's great!"), `life.pas` ("Life works"), `gmscode.pas` ("works"), `paper.pas` ("works :)"), `magic_square.pas` (works), `menu.pas` ("menu works", with its games built into `A:\SHANNON` as the README's Examples section shows).
  - [x] Graphics (a window opens). Done: `clock/` (the user, 2026-11-06: "works"), a whole game of `tictac/` against the computer ("tictac works").
  - [x] Ruscal's own examples in `examples/ruscal/`. Done: `rust_calls_pascal/` (the user, 2026-11-06: works, but what it does wasn't clear; the README says now), `calls_rust.pas` (the user, 2026-11-06: "works"), `turtles.pas` (the user, 2026-11-06: "works. Nice job!").
- [x] Read README.md and docs/ as a newcomer would, and say what's confusing or missing. Done on the `docs-newcomer` branch (2026-11-10), from a fresh agent's read: README (quick start, requirements, where output goes, RUSCAL_RUNTIME, what's supported moved up, status/bugs/license), the spec's opening and `{$N+}` line, embedding's `rev`, RscTurtle; `asm`/`inline`/`Mem[Seg:Ofs]`/`Port` say they need a real DOS PC; `tpc --help`; `ruscal build` says where the executable is.
- [x] Starting your own project from an example (the user, 2026-11-13: a fresh agent copied `turtles.pas`, `calls_rust.pas` and `rust_calls_pascal` out of a clone and got each running). Done: `rust_calls_pascal` has its own copy of `bstunit.pas` (`pascal/`, kept equal to the original by `build_rs_tests`), and its `Cargo.toml` and docs/embedding.md show `git = ..., branch = "main"` (the user: no tag needed; `rev` to pin); the README says what to copy for each, that `Rsc` units are built in, `out/` in `.gitignore`, and how to run turtles headless.
- [x] Findings of the review of the `docs-newcomer` branch: Rust 1.88, not 1.85 (`let` chains; `rust-version` set); `RUSCAL_RUNTIME` needs the runtime inside a whole checkout; the README's `fmt --check` line leaves out `examples/ruscal`; `assembler;` routines, an `asm` body and the `inline(...)` directive say they need DOS too; `A[1:2]` is an ordinary syntax error, not the `Mem` one; `emit`/`build --help` describe the file; `tpc -H`.
- [x] `ruscal fmt` doesn't know `asm ... end` is a block: the `end` goes to column 1 and what follows is indented one level too far (from the `docs-newcomer` review; `tests/errors/dos_asm.pas` is formatted that way). Done (2026-11-11): an `asm` statement or an `assembler` routine's body is a block, its instructions one level in.
- [x] `Registers` has only its `Word` fields, so interrupt code setting `AH` gets "`Registers` has no field `AH`" before the helpful error about `Intr` (from the `docs-newcomer` review). Add the byte halves (`AL`, `AH`, ...)? Done (2026-11-11), differently: `Regs.AH` (and `AH` in a `with Regs`) says the byte halves are only for `Intr` and `MsDos`, which need real DOS. (The runtime's `Registers` is a plain struct, and nothing but `Intr`/`MsDos` reads it.)
  - [x] For the user: restructure docs/language_spec.md by topic (Types, Statements, Units, Crt, Dos, Graph, Not supported) instead of the tiers and "Decision" log, folding in the "(Done, now in tier 2)" items, and gloss its jargon on first use (typed constant, open array, VMT, `PString`, procedural value). Done (2026-11-11): by topic, with a contents list; the done "later" items folded in, the remaining ones renumbered under "Not supported yet" (with `Single`/`Double`/`Extended`/`Comp` added, and comment preservation and the `Overlay` unit dropped as done); duplicates merged.
- [x] `SizeOf` names where its number comes from (the user, 2026-11-07: "do the SizeOf work", on a branch, reviewed by Fable before merging). A type's size in TP's layout isn't its size in Rust's memory, so it's the *serialized* size (the user's name): sema's `tp_size` and the runtime's `record_size()` became `serialized_size` (an untyped file's `record_size`, set by `Reset(f, n)`, keeps TP's name). `SizeOf(Rec)` is `Rec::SERIALIZED_SIZE`, an inherent constant built from the fields (`2 + serialized_string_size(10) + 3 * Point::SERIALIZED_SIZE`), cast where an integer type is wanted and kept through constants (`const K: i16 = Rec::SERIALIZED_SIZE as i16 * 2`). See docs/architecture.md.
  - [ ] `SizeOf` in an array bound (`array[1..SizeOf(Point)]`) is still a number: sema writes bounds' Rust (`bounds_rust`) before codegen knows which types get a constant.
  - [ ] `serialized_string_size(10)` for a `string[NameLen]` could be `serialized_string_size(NAME_LEN as usize)`; the type keeps only the number (as `file_record!`'s `string 10` does).
- [x] An object with a constructor, destructor or virtual method takes 2 more bytes, TP's VMT field (you decided, 2026-11-07: be as accurate to TP's file format as possible). The TP 7 Language Guide and Free Pascal agree: the field follows the fields of the first type in the line with a constructor, destructor or virtual method, and descendants' fields come after it. `SizeOf` and `file of` count it (Ruscal writes zeros there and reads past it); `to-json` now reads such objects, and `from-json` refuses them, since it can't know the address TP stored. The database example's files hold only records, so they were never affected.

- [x] Rename the project "Ruscal" per Julie's suggestion (done 2026-11-07: the repository, crates, command, environment variables (`RUSCAL_*`) and docs). Julie's artwork for it, at the top of the README: https://chatgpt.com/s/m_6aeea40a95dc8191bdc0e0822d186814
- [x] Ruscal's own units' names start with `Rsc`, not `PR` (the user, 2026-11-07; `PR` was left over from the old project name): `PRTurtle` is `RscTurtle` and `PRJson` is `RscJson`, with their docs (`docs/rsc_turtle.md`, `docs/rsc_json.md`) and tests renamed to match. Older items below keep the old names.
- [x] Add DOSBox and the Turbo Pascal 7 copy the user runs in it (https://archive.org/details/tp_20240418) to the README's Acknowledgements (the user, 2026-11-07: "at some point").
- [ ] Announce Ruscal to the Pascal community (the user, 2026-11-06: theirs to do): find which Pascal compiler projects are still alive (Free Pascal, Lazarus, and others), their mailing lists or forums and what each allows for announcements, and send a short announcement to each (what Ruscal is, that it's MIT, a link to the repository). Claude can help draft them if asked.
  Plan (researched by a subagent, 2026-11-12; links checked then, some places couldn't be read by a bot):
  - [ ] Before posting: tag a release (v0.7.0 on crates.io; see docs/releasing.md). Say plainly that Claude wrote the code (the README does): Hacker News asks for human-written posts ("Don't post generated text"), and users.rust-lang.org is tired of low-quality LLM crates, so write each post in your own words. Tell the story: your own 1996-97 programs are the acceptance test, `fpc -Mtp` gives expected output, TP 7 in DOSBox settles disagreements; say what's missing (macOS/Linux only). Expect comparisons with Ferropascal (another Pascal → Rust transpiler) and Ben Hoyt's pas2go (TP → Go, https://benhoyt.com/writings/zzt-in-go/); unverified.
  - [ ] Smaller, friendlier places first, to catch problems: the Lazarus/FPC forum's "Third party announcements" board (https://forum.lazarus.freepascal.org/, account needed), then the fpc-pascal mailing list (https://www.freepascal.org/maillist.html; third-party release notes appear there, e.g. https://lists.freepascal.org/fpc-pascal/2026-February/063108.html). Credit FPC as the source of expected output.
  - [ ] Get Ruscal listed by Free Pascal. The FPC site's Links page (https://www.freepascal.org/links.html) lists related tools (Lazarus, PasDoc): probably from the GitLab repo freepascal.org/fpc/website, so a merge request, or ask on fpc-pascal; not confirmed. The FPC wiki was "temporarily offline", so the related-tools page you remember (if it's there) wasn't found: look again (pages like "Code Conversion Guide"); editing needs a wiki account. Also "Contributed Units" (https://www.freepascal.org/contrib/contribs.html, add with a community account; mostly dormant, cheap). Draft entry: Ruscal, Miscellaneous, macOS/Linux, https://github.com/jjinux/ruscal, "an MIT-licensed Turbo Pascal 7 to Rust transpiler, written in Rust: it turns a TP program (Crt, Dos, Graph, typed files) into a small Cargo project you can build and run natively, reads old TP data files (to and from JSON), and has a source formatter. Its expected test output comes from FPC's -Mtp mode."
  - [ ] Delphi-PRAXiS, "I made this" board (https://en.delphipraxis.net/). Retro/DOS: BTTR forum's Announce category (https://bttr-software.de/forum/), VOGONS (https://www.vogons.org/); lead with "run your 90s TP programs natively".
  - [ ] Reddit: r/pascal, r/retrocomputing, r/rust, r/delphi (read each sidebar's self-promotion rules first; stay to answer comments). users.rust-lang.org "announcements" (https://users.rust-lang.org/c/announcements, now muted by default).
  - [ ] Show HN (https://news.ycombinator.com/showhn.html): "Show HN: Ruscal – Turbo Pascal 7 to Rust transpiler, tested on my 90s programs". No hype, no asking for upvotes; a first comment of your own on how and why; a weekday US morning; be around to answer.
  - [ ] Mastodon, Bluesky, X: #TurboPascal #Pascal #FreePascal #RustLang #retrocomputing, with a GIF of a Graph or Crt program running.
  - [ ] Maybe: a blog post of your own ("What I learned translating TP to Rust"), which This Week in Rust takes by PR (https://github.com/rust-lang/this-week-in-rust; no project updates, no LLM-written articles). Skip Lobsters unless you're a member (invite only, no self-promotion for 70 days).
  - Alive in 2026: Free Pascal (3.2.4 at RC), Lazarus (4.8, June 2026), Delphi (RAD Studio 13.2), Oxygene/Elements (talk.remobjects.com), DWScript. PascalABC.NET's last release found was Sept 2025. GNU Pascal is dead (2007).

## Check with a real Turbo Pascal

Free Pascal (`fpc -Mtp`) gives most expected outputs, but it works in 32 or
64 bits, pads records, and differs from TP 7 in some corners. If you still
have Turbo Pascal 7 (in DOSBox, say), these settle what it can't. Tell
Claude what TP does, and it makes Ruscal match.

- [x] `w + 1` with `w: Word = 65535`: 0 (Ruscal) or 65536? TP 7 (DOSBox, 2026-11-07): 0, also `L := w + 1`; but `L := w + i` (`i` an Integer) is 65536. Ruscal does the same.
- [x] With `{$Q+}`, is `Inc(b)` at 255 for a Byte (or `w + 1` at 65535 for a Word) error 215, as Ruscal says, or 0? TP 7 (in DOSBox, 2026-11-07): `Inc` and `Dec` are never checked, for any type (`Inc(i)` at 32767 is -32768, `Inc(b)` at 255 is 0); `w := w + 1` at 65535 and `i := i + 1` at 32767 are error 215; `b := b + 1` at 255 is 0 (worked out in Integer); `Succ`, `Pred`, `Abs`, `Sqr`, negation and LongInt `*` are checked. Ruscal checked `Inc`/`Dec`; fixed.
- [x] `s := s + Bump` where the function `Bump` changes `s`: which runs first? TP 7: `s` is read first (`'ab'` gives `'abX'`; `Bump + s` gives `'Xabc'`). Ruscal does the same.
- [x] `type Small = 0..10; const X = Small(300);`: an error, or 44 (Ruscal)? TP 7: 44, as Ruscal.
- [x] Graph: does `SetBkColor` use the current `SetPalette` entry? Do XOR-mode rectangles lose their corners? TP 7: yes, a copy of the entry as it is at the call (a later `SetPalette` doesn't change it), and `SetBkColor(0)` brings back black; Ruscal used the default palette's entry: fixed (and `EGALightRed` & co. were missing: added). XOR rectangles lose their corners, in TP and Ruscal alike.
- [x] `SizeOf` of a subrange of an enum of more than 256 values (`V10..V20`): TP 7 (DOSBox, 2026-11-07) says 1, as Free Pascal does (the bounds fit a byte), and a record of one such field is 1 byte too; `V250..V260` is 2. Ruscal said 2 (the host enum's): fixed; the subrange's `EnumType` is marked `in_one_byte`, and `file_record!` says `enum 1`.
- [x] `const W = Word(-1)`, then `i := W` (an Integer) is a compile error, "the constant 65535 is out of range for Integer" (also `i := K - W`). Free Pascal accepts it (-1). What did TP 7 do? A compile error too ("Error 76: Constant out of range"), as Ruscal.
- [x] An object with a constructor but no virtual methods: does TP 7 give it the 2-byte VMT field? TP 7: yes, `SizeOf` 6 (and 6 with only a destructor), as Ruscal.

## Original TODOs

- [x] Figure out a name:
  - [x] PascRust (renamed Ruscal, 2026-11-07, as Julie suggested)
- [x] Write a TODO.md file.
- [x] Have Fable fill out the TODO.md with the plan and make the core architectural decisions.
- [x] Opus can then read the plan and fill in the details.
- [x] Write a CLAUDE.md.
- [x] Use an MIT license.
- [x] Figure out if I should aim to translate Pascal or Turbo Pascal:
  - [x] Is there an official spec and/or open source implementation for Turbo Pascal? (No formal spec; the TP 7.0 Language Guide is the spec, Free Pascal `-Mtp` is the open-source implementation. See `notes/p2c.md` §4.)
  - [x] Wasn't there some famous Pascal to C compiler? If so, carefully study how it's implemented. Take notes and save them into a file. (p2c; see `notes/p2c.md`.)
  - [x] Write a file called language_spec.md (now in docs/) with a plan of what language constructs we want to support. (Decision: Turbo Pascal; tiers in `docs/language_spec.md`.)
- [x] Make the core architectural decisions:
  - [x] Figure out what lexer and parser I should use. (Handwritten recursive descent; `docs/architecture.md` §4.)
  - [x] Maybe we should have a "virtual heap" that represents the Pascal heap in a somewhat safe way. (Passing around a heap object, embedding a Pascal engine in Rust, maybe a memory-mapped file; errors raise to the Rust container.) (Decided: handles (`Ptr<T>` over `Rc<RefCell>`), not a heap object; panics caught by `run()`; `docs/architecture.md` §5, §12, §17.)
  - [x] How should we represent arrays and strings in Pascal in Rust? (`PArray<T, LO, N>` and `PString`; §8, §10.)
  - [x] How should we represent pointers and the heap? (`Ptr<T>`; §12.)
  - [x] How should we represent records? (structs, variant records flattened; §11.)
  - [x] How do we build a FFI to Rust? (§22.)
  - [x] How do we build a FFI to C? (§22, tier 3.)
  - [x] Is it even possible to have a FFI to Pascal that's already been compiled? (Low priority; save ideas for later.) (Not directly; ideas in §22.)
  - [x] Can we skip implementing threads? Do Pascal / Turbo Pascal even have those built in? (Yes, skip; TP has none; §23.)
  - [x] Write all of the core architectural decisions to a file named docs/architecture.md.
- [x] Start building a battery of tests to verify we're compiling it correctly:
  - [x] Are there existing tests in other open source projects that we can use for inspiration? (Free Pascal `tests/`, p2c `examples/`, Pascal Validation Suite; `notes/p2c.md` §3-4.)
  - [x] There should be tests that test what Pascal constructs translate into what Rust constructs. (`tests/translate`, snapshotted.)
- [x] How do we build at least a small standard library, including things like printing to stdout? (`crates/ruscal_runtime`.)
  - [x] There should be tests that compile Pascal to Rust and then run the Rust to generate expected output. (`tests/run`, expected output from `fpc -Mtp`.)
- [x] Is there an official standard library for Pascal or Turbo Pascal that has an interface that we can match? (The TP `System` unit plus `Crt`/`Dos`/`Graph`; list in `notes/p2c.md` §5.)
- [x] If possible, copy all the code in ~/Dropbox/programming/turbo_pascal to an examples directory and get them working.
  - [x] Copy the code into `examples/`.
  - [x] Get them working. (All ten programs transpile, build without warnings and run; see Phases 4 and 5.)

## Phase 0: Scaffolding (half a day)

- [x] Review `notes/open_questions.md` with the user; record answers at the top of that file.
- [x] Create the Cargo workspace: `crates/ruscal` (bin + lib) and `crates/ruscal_runtime` (lib with features `crt`, `dos`, `graph`). Edition 2024.
- [x] Write `CLAUDE.md`: project goals, the "intermediate Rust with teaching comments" style rule, where decisions live, how to run tests, the rule that every new Pascal construct needs a translate test and a run test.
- [x] Add `.gitignore` entries for `out/` and `target/`; add `rustfmt.toml`; add a GitHub Actions workflow (fmt, clippy, test).
- [x] Add `tests/README.md` describing the three test layers from `docs/architecture.md` §21.
- [x] `ruscal --help` prints usage; `ruscal emit`, `build`, `run` subcommands stubbed with `clap`.

## Phase 1: Hello world end to end (first thing that runs)

Goal: `ruscal run tests/run/hello.pas` prints `Hello, world!` by going
lexer → parser → AST → sema → codegen → Cargo project → `cargo run`.

- [x] `token.rs`: token enum (keywords, identifiers, integer/real/string/char literals, operators, punctuation) with `Span`.
- [x] `lexer.rs`: handwritten lexer; case-insensitive keywords; `{ }`, `(* *)` and `//` comments; `{$...}` directives kept as a `Directive` token; `1..5` vs `1.5`; `'it''s'`, `#13`, `^M`; hex `$FF`.
  - [x] Unit tests for every token class and the tricky cases.
- [x] `ast.rs`: `Program`, `Block`, `Decl` (const/type/var/proc), `TypeExpr`, `Stmt`, `Expr`, all with spans. Keep it a plain tree of enums and structs; comment what each node corresponds to in Pascal.
- [x] `parser/`: recursive descent for `program`, `const`/`var` sections, `begin ... end`, procedure calls with arguments, string and integer literals, `writeln`. Error type with Pascal file:line:col.
  - [x] `insta` snapshot tests of the AST for hello world and a few malformed inputs (error messages).
- [x] `sema/` skeleton: symbol table with case-insensitive lookup, builtin `writeln`, types `Integer`/`String`; annotates the AST with types.
- [x] `codegen/`: indenting writer; emits `use ruscal_runtime::prelude::*;`, `fn pascal_main()`, `fn main() { ruscal_runtime::run(pascal_main) }`, `pwriteln!(...)`.
- [x] `ruscal_runtime`: `prelude`, `run()` (plain version: call the closure, map panics to exit code 1 for now), `pwrite!`/`pwriteln!` macros over a `PasWrite` trait implemented for `&str`, integers, `f64`, `bool`, `u8`.
- [x] `driver.rs`: writes `out/<name>/Cargo.toml` (path dependency on the runtime, `overflow-checks = false`) and `src/main.rs`; runs `rustfmt` if present; `build`/`run` shell out to `cargo`.
- [x] Test harness v1: `tests/run_tests.rs` finds `tests/run/*.pas`, transpiles each, builds, runs with `*.in` as stdin, diffs against `*.out`. Build all test programs into one scratch workspace so a single `cargo build` covers them.
- [x] Translate test harness v1: `tests/translate_tests.rs` snapshots the generated Rust for `tests/translate/*.pas` with `insta`.
- [x] `hello.pas` passes both harnesses. Commit.

## Phase 2: Core language (tier 1 of `docs/language_spec.md`)

Each bullet: parser + sema + codegen + a translate test + a run test. Order
chosen so each step is testable with the previous ones.

- [x] Integer, real, boolean, char expressions with TP precedence and promotion rules; `div`/`mod`/`/`; `as` casts inserted by sema's type info. Decide and document `i16` wrapping (`docs/architecture.md` §7).
- [x] `var` declarations with `Default` initialization; assignment; `if`/`else` (dangling else); `while`; `repeat`; `for to/downto` over integers.
- [x] `writeln`/`write` formatting: `:w`, `:w:d`, TP default real format, booleans. Run tests compare byte for byte.
- [x] `readln`/`read` from stdin for integers, reals, chars, strings (TP's lenient parsing). `.in` files in run tests.
- [x] Procedures and functions: value params, `var` params as `&mut`, function result variable, `Exit`, recursion, `forward`. Call-site `.clone()` insertion for non-Copy value args.
- [x] Nested procedures: lifting analysis in sema (free variables, transitive through calls, including recursion), codegen of lifted `fn outer_inner(captured..., params...)`. Tests: recursive nested proc, nested proc modifying an outer local, two levels of nesting, nested proc capturing an outer `var` parameter.
- [x] Globals lifted into `pascal_main` and threaded to procedures (same analysis). Test: a procedure that reads a global and is called from another procedure.
- [x] Alias detection in sema: same lvalue root passed twice (`Swap(x, x)`, `F(a, a[1])`, global passed by `var` to a procedure that uses it); report a transpile error with the Pascal position. Tests for each.
  - [x] Alias *unification*: when every call passes the same outer variable for a `var` parameter that the callee also captures (`life.pas`'s `Pause`), use the parameter for both instead of rejecting the program.
  - [x] PUNT: Copy-in/copy-out for `Swap(a[i], a[j])` on arrays of `Copy` elements (currently rejected because both roots are `a`).
- [x] `PString`: runtime type (`[u8; 255]` + `len` + `cap`), `Index<i32>`, concatenation, comparison, `assign` with truncation, `pstr!` literal macro; string vs char coercions in sema. `Length`, `Copy`, `Pos`, `Delete`, `Insert`, `Concat`, `UpCase`, `Str`, `Val`.
- [x] Enumerated types and `Ordinal` trait (generated impl per enum; runtime impls for integers, `u8`, `bool`); `Ord`, `Chr`, `Succ`, `Pred`, `Inc`, `Dec`, `Low`, `High`; `for` over enums and chars.
  - [x] `Inc`/`Dec` on an enum variable: `Inc(c)` came out as `c += 1`, which doesn't compile (found 2026-10-31); now `c.inc()`, `c.dec_by(n)`.
- [x] Subranges as host types.
  - [x] PUNT: `--range-checks` flag.
- [x] `case` → `match` with lists, ranges, `else`, and no-match-is-no-op.
- [x] `PArray<T, LO, N>`: runtime type, `Index`/`IndexMut<i32>`, `Default` via `array::from_fn`, `Copy` when `T: Copy`; multi-dimensional sugar; char/enum indexes. Range-check panic message in TP style.
- [x] Records: struct generation, `Clone`/`Default`/`Copy` decisions, field access, record assignment, records in arrays, arrays in records, anonymous record types in `var`.
- [x] `const` section with constant folding; typed constants (array and scalar) as initialized variables.
- [x] Math and misc builtins: `Abs Sqr Sqrt Sin Cos ArcTan Ln Exp Trunc Round Int Frac Pi Odd Random Randomize Hi Lo Swap MaxInt`.
- [x] `Halt`, `Halt(n)`, exit codes; runtime `run()` with `catch_unwind`, TP-style "Runtime error NNN" messages and codes (200, 201, 204, ...), big-stack worker thread.
- [x] Naming: case-insensitive canonicalization, `snake_case`/`CamelCase` conversion, Rust keyword escaping, user declarations shadowing builtins (`procedure Exit`, `type ShortString`). Test with the examples' names.
- [x] `///` comments with the original Pascal declaration on every generated item; teaching comments at first use of `Ptr`, const generics, lifting, `catch_unwind`.
- [x] Milestone: `magic_square.pas` (minus `Crt`) and the tier-1 subset of `paper.pas` run.

## Phase 3: Files, units, objects, pointers (tier 2 language)

- [x] `Text` files: `PText` runtime type; `Assign`/`Reset`/`Rewrite`/`Append`/`Close`/`Eof`/`Eoln`/`Erase`/`Rename`/`Flush`; `read`/`write` variants taking a file. `SeekEof`/`SeekEoln`; `{$I-}`/`IOResult`. Run tests that write then read a temp file.
- [x] Typed files: `PFile<T>` with a generated `PascalRecord` (serialize/deserialize) impl per record type; `Seek`/`FilePos`/`FileSize`/`Truncate`. Test with a `file of record` round trip and `Seek` to the middle.
- [x] Units: driver locates `uses` targets (same directory, then `-I` paths), parses interface/implementation, emits one module per unit with `pub` visibility, `init()` for initialization sections called in `uses` order; name resolution across units with TP's later-unit-wins rule. Test: a program using two units with a name clash.
- [x] Objects: `struct` + `impl`, `&self`/`&mut self` selection, implicit `Self` field access, nested procedures inside methods (`this: &mut T` lifting), inheritance by composition (`base` field, path rewriting, upcasting to `&mut child.base`), `private` ignored. Tests from `bstunit.pas` and `clock/menu.pas` patterns.
- [x] Pointers: `Ptr<T>` runtime type (`nil`, `new_`, `dispose` with use-after-dispose detection, `get`/`get_mut`, `ptr_eq`), temporaries hoisted for `p := p^.next` and for call arguments containing derefs, `var` args of heap fields as `&mut p.get_mut().field`. Tests: linked list push/pop, BST insert/delete (the `bstunit.pas` algorithm verbatim), `Root^ := TempPtr^`.
- [x] `RefCell` double-borrow panics mapped to a clear "pointer aliasing" runtime error message with the Pascal procedure name.
- [x] `with` statements by path rewriting (sema rewrites the body; `with p^` copies the pointer when the body could change it; changing an index that chooses the record is an error).
- [x] `{$I-}` and a real `IOResult`: I/O calls in a `{$I-}` region are wrapped in `io_unchecked`, which keeps the error code for `IOResult`.
- [x] Hoist pointer dereferences out of call arguments too, so `f(p^.x)` never holds a `RefCell` guard across the call.
- [x] PUNT: Methods that don't modify `Self` could take `&self` instead of `&mut self`.
- [x] `Break`/`Continue`; `FillChar`/`Move` on arrays of scalars; `ParamCount`/`ParamStr`; `SizeOf` for sized types; `{$N+}` float types (`Single`, `Double`, `Extended`).
  - [x] PUNT: `Comp`, the 8087's 64-bit integer type: `unknown type`.
- [x] Milestone: `examples/database/` (bstunit, founit, filesys) transpiles and the non-interactive paths run (with `Crt` stubbed to plain mode).

## Phase 4: Crt, then the text-mode examples

- [x] `crt` feature: `crossterm`-backed terminal with TP state (`TextAttr`, `WindMin`/`WindMax`), `ClrScr`, `ClrEol`, `GotoXY`, `WhereX`/`WhereY`, `TextColor`/`TextBackground`/`HighVideo`/`LowVideo`/`NormVideo`, `Window`, `InsLine`/`DelLine`, `TextMode`, `Delay`, `Sound`/`NoSound`, `KeyPressed`, `ReadKey` (with `#0` + scan codes for arrows/function keys), colour constants, `Blink`.
- [x] Route all `write` output through the runtime (raw-mode `\r\n`, CP437).
  - [x] PUNT: `Window` clipping and scrolling of output (currently `Window` only affects `ClrScr`/`GotoXY`/`WhereX`).
- [x] CP437 → Unicode output mapping; reverse mapping on input.
- [x] Plain mode when stdout is not a TTY or `RUSCAL_TERM=plain`: cursor ops are no-ops, `ReadKey` reads stdin bytes, `Delay` honours `RUSCAL_FAST`.
- [x] Scripted-input run tests: in plain mode `ReadKey` reads the test's `.in` file; compare stdout (`tests/run/crt_plain.pas`).
- [x] Get working, one at a time, fixing transpiler bugs as found: `gmscode.pas`, `paper.pas`, `magic_square.pas`, `life.pas`, `blkjack.pas`, `menu.pas` (needs `Dos.Exec`, which may fail gracefully), `airport/` (four units). All transpile and build warning-free; `magic_square`, `paper`, `airport4` and `database/filesys` verified with scripted sessions.
  - [x] PUNT: Turn those scripted sessions into run tests (`examples/` acceptance tests in CI).
  - [x] `examples/database/founit.pas` empties the master file on delete: `Fcopy` stops at `eof` because nothing seeks back to the start. Confirmed as a bug in the original program and fixed there (plus `BST.ShiftLocations`, since later records move up a position).
  - [x] `bstunit.pas`: deleting a node with two children copied the successor's links (`Root^ := TempPtr^`). Fixed in the example.
- [x] PUNT: CI builds every example; runs the non-interactive ones. Done: CI builds every example warning-free (`examples_tests.rs`). Not yet: running any of them.

## Requests from the user, 2026-10-27

- [x] Fix the two bugs found in the user's examples (`bstunit`, `founit`). Fixing them exposed a transpiler bug: call arguments that read through a pointer kept the record borrowed during the call; now they're copied into a `let` first (`tests/run/ptr_args.pas`).
- [x] README: usage instructions.
- [x] README: an "Inspiration" section.
- [x] BGI graphics (Phase 5 below). `clock/` and `tictac/` run. The clock's hands go round anticlockwise on purpose: it's a playful backwards clock.
- [x] Consistent identifier casing in the examples.
- [x] Consistent spacing in the examples: `ruscal fmt` (`crates/ruscal/src/fmt/`), a re-indenter that reuses the lexer; the examples are kept formatted by `tests/fmt_tests.rs`. Prototyped in Python, then ported.
- [x] DOS and UNIX line endings both work: source, standard input and text files (`tests/run/crlf.pas`, stored with CRLF; see `.gitattributes`), and `fmt`.
- [x] Code review by Fable (two reviewers: transpiler; runtime and `fmt`). Fixed: `Continue` in `repeat` skipped the `until` test; hoisted temporaries could collide or shadow variables; scoped `for` loops with literal bounds became `i32`; `-b` on `Byte`/`Word`; big subranges; `Ord`/`Abs` in constants; `Write` of an enum; `Boolean(n)`; `^Name` resolved too early; `shr` was arithmetic; `Read` into `string[n]`; directives silently ignored (now warnings, includes an error); pointer comparisons cloned; `get_mut` on every `^` in a path; `if` temporaries in a block; Crt left the terminal raw after a normal end or runtime error; `Val` crashed on non-ASCII; reals rounded ties to even and `Inf` crashed; Graph-only programs built with warnings; `fmt` and numeric labels; `Eof` at an unterminated last line; doc drift. Still open from the review:
  - [x] `var p: ^T;` with a one-letter type name lexed as the control character `^T`. Now, as in Free Pascal, `^` is the pointer symbol wherever a type can appear (`type` and `var` sections, a typed constant's type); the lexer tracks which section it is in. Like FPC, `set of ^A..^Z` in a `type` section is then a pointer, not characters.
  - [x] Two disjoint fields of one record as two `var` arguments (`Init(p.x, p.y)`) were rejected. Sema now compares field paths; two fields of one heap record (`q^.x, q^.y`) borrow it once with `Ptr::with_mut`. Still rejected: two elements of one array (`a[1], a[2]`).
  - [x] A local that clashed with a captured global renamed the global everywhere (`global_count`); now only inside the procedure with the clash (`Analysis::capture_names`).
  - [x] Hoisting a deref argument evaluated it before earlier arguments with side effects (`ShowV(Bump, head^.value)`); earlier arguments with calls go into temporaries first now.
  - [x] `x shl n` with `n` at least the type's width didn't compile (constant) or panicked (variable); TP gives 0. Now `checked_shl(n).unwrap_or(0)` unless the count is a literal below the width. A shift also has the type of its left operand now, as in TP.
  - [x] `p^.x := p^.x + 1` hoisted a temporary; it's `p.get_mut().x += 1` now, when the added part reads no pointer. (Places are compared in the Pascal, not in the rendered Rust.)
  - [x] `Random(n)`: checked against a disassembly of TP's System unit (github.com/daelsepara/turbo-pascal-assembly): it uses the full 32-bit seed, `(seed * n) shr 32`, as we do. `n` is now truncated to a `Word`, as TP's parameter is. Not done: `RandSeed` as an assignable variable.
  - [x] `{$I-}` and a real `IOResult`.
  - [x] `SeekEof`/`SeekEoln`.
  - [x] `LastMode` (done with the Crt variables).
  - [x] `Val` corner cases: a number that doesn't fit wraps with code 0, as in Free Pascal (TP left it undefined); a minus sign is an error for a Byte or Word; after an error the variable is 0.
  - [x] PUNT: Graph: should `SetBkColor` use the current `SetPalette` entry? Do XOR-mode rectangles lose their corners in the real BGI? `FExpand` ignores `ChDir`.
  - [x] `i16::MIN div -1` panicked (runtime error 255). TP doesn't wrap: its 16-bit divide traps, which it reported as runtime error 200, and so does Ruscal now.
  - Not changed: `Round(2.5)` is 3. The reviewer suggested ties-to-even to match Free Pascal, but Turbo Pascal's documentation says halves round away from zero. `Eof` on a text file being written stays runtime error 104, as in Free Pascal (the reviewer thought TP returns True).

## Requests from the user, 2026-10-28

- [x] PUNT: Evaluation order where a function has side effects (the user: follow Free Pascal). Done: `Write(F, G)` writes F before running G; `n := n + Bump` reads `n` first. Not yet, and worth asking whether to chase: on aarch64 Free Pascal calls the function first for reals, strings and sets (`t := t + Ext` where `Ext` changes `t` gives `ayz`, Ruscal `az`), and works out an assignment's target index before the right side (now done: such an index goes into a `let` first). These are Free Pascal code-generator details, and may differ on x86.
- [x] Rename the project to "PascRust" wherever a friendly name fits: the README, the other docs, `Cargo.toml` descriptions, the GitHub repo description, CLI help text and messages, comments and generated-code headers. The directory, the crates, the binary (`pascrust`), the repo name and other identifiers stay `pascrust`. (Later renamed Ruscal, 2026-11-07.)

## Requests from the user, 2026-11-03

- [x] A Rust project that embeds Pascal code: how does its `cargo build` know to run Ruscal on the Pascal? Done: `ruscal::build::library` in its `build.rs` and `ruscal_runtime::include_library!` (`examples/ruscal/rust_calls_pascal`, docs/embedding.md). (The user's question.) Likely answer: a `build.rs` build script, with Ruscal as a build dependency, that translates the unit into Cargo's `OUT_DIR` (`cargo:rerun-if-changed=unit.pas` so a change in the Pascal is noticed) and an `include!` of it; a helper such as `ruscal::build::library("unit.pas")` would make that `build.rs` two lines. Document it in docs/embedding.md, and test it with the BSTUnit host.

- [x] Overflow (decided with the user, 2026-11-04): integer arithmetic keeps wrapping, as TP's default `{$Q-}` did; forbidding it would break correct programs (hashes, checksums, random number generators, `Byte` sums TP cut to fit). A library gets wrap-around only if the Rust program turns overflow checks off, so the docs give the `Cargo.toml` line and the runtime warns once when checks are on (part of the `build.rs` plan, `notes/build_rs.md`).
- [x] `{$Q+}` turns integer overflow into runtime error 215, as in TP: checked arithmetic in the regions it covers (the user, 2026-11-05: "if it isn't too hard").

## Requests from the user, 2026-11-02

In this order, after fixing `Inc`/`Dec` on enums and the Fable review of `076ffea..HEAD`:

- [x] PUNT: Ruscal's own units, named with a `PR` prefix (`PRJson`, `PRTurtle`), as Turbo Pascal's types start with `T`. The user's choice (2026-11-02): the units are `PR...`, and their types follow TP's own convention inside them (`TJsonValue`, `PJsonValue = ^TJsonValue`), as `Dos`'s `SearchRec` does.
  - [x] `PRJson`: read and write JSON from Turbo Pascal (written in Pascal, the user's choice; JSON strings up to 255 characters).
  - [x] `PRTurtle`: turtle graphics on top of `Graph`, with Graph3's own routine names (the user's choice: `Forwd`, `Back`, `TurnLeft`, `TurnRight`, `SetHeading`, `Heading`, `SetPosition`, `Xcor`, `Ycor`, `Home`, `PenUp`, `PenDown`, `ShowTurtle`, `HideTurtle`, `Wrap`, `NoWrap`, `SetPenColor`), so a Graph3 turtle program ports by changing its `uses` line and its graphics setup.
    - [x] An example of an interesting turtle graphics program in `examples/` (`examples/ruscal/turtles.pas`: a Koch snowflake, a tree, a spiral) (the user's request, 2026-11-02): something that's fun to watch draw, such as a recursive tree or a Koch snowflake.
- [x] Document how Turbo Pascal code can call existing Rust code (and make it work: see the "FFI to Rust" item in Phase 8). (`docs/calling_rust.md`.)

## Requests from the user, 2026-10-29

- [x] PUNT: `Single`/`Double`/`Extended`/`Comp` on disk in their TP sizes (4/8/10/8 bytes; today all are 6-byte `Real`), in translated programs and `to-json` (the user, 2026-11-05: later; `to-json` refuses them meanwhile). See notes/file_json.md.
- [x] An enum of more than 256 values: `tp_size` says 2 bytes (as TP), the runtime writes 1. (Now 2 bytes in files too: `tests/run/big_enum.pas`.)
- [x] (Prioritized by the user, 2026-11-05; plan in notes/file_json.md: done as `ruscal to-json` and `from-json`, docs/data_files.md.) A command like `fmt` that turns a binary file written by a Turbo Pascal program (`file of T`) into JSON: an input file and an output file. A binary file doesn't say what its records look like, so it also needs the record type: probably the Pascal source that declares it and the type's name (`ruscal json founit.pas People mark.dat mark.json`), or the only `file of` type the program uses. It can reuse the runtime's TP-exact layout (`FileRecord`), decoding through the type's fields; one JSON object per record, in an array.

## Phase 5: Dos and Graph, then the graphics examples

- [x] `dos` feature (the parts the examples use; the rest is in Phase 7): `GetDate`/`GetTime` (`chrono`), `FExpand`/`FSearch`/`FSplit` with the drive-letter mapping and `\`→`/` translation, `Exec`/`DosExitCode` via `std::process::Command`, `ChDir`/`MkDir`/`RmDir`/`GetDir`, `GetEnv`, `DosVersion`, `FindFirst`/`FindNext`, `DiskFree`/`DiskSize` best effort; `PathStr` and friends as `PString` aliases.
- [x] `graph` feature, headless core first: 640x480 framebuffer of colour numbers, EGA palette (`SetBkColor`, `SetPalette`), `PutPixel`/`GetPixel`, Bresenham `Line`/`LineTo`/`LineRel`, `Rectangle`, `Bar`/`Bar3D` with 8x8 fill patterns (`SetFillStyle`/`SetFillPattern`/`GetFillPattern`), `Circle`/`Arc`/`Ellipse`/`FillEllipse`/`PieSlice`/`Sector`, `FloodFill`, line styles and `ThickWidth`, viewports (`SetViewPort`/`ClearViewPort`/`ClearDevice`), `SetWriteMode`.
  - [x] The rest of Graph: see Phase 7.
- [x] Bitmap text: the public-domain 8x8 VGA font (ASCII); `OutText`/`OutTextXY`/`SetTextJustify`/`SetTextStyle` (default font, integer scale; stroked fonts approximated with it)/`TextWidth`/`TextHeight`.
  - [x] PUNT: CP437 characters 128-255 in the font (box drawing, accented letters).
- [x] `InitGraph`/`Detect`/`DetectGraph`/`CloseGraph`/`GraphResult`/`GraphErrorMsg`/`SetGraphMode`/`GetGraphMode`/`RestoreCrtMode`/`GetMaxX`/`GetMaxY`/`GetMaxColor`/`GetAspectRatio`.
- [x] Tests: `RUSCAL_GRAPH=headless` draws without a window; `tests/run/graph_basics.pas` checks drawings with `GetPixel` (instead of golden images; see docs/architecture.md §19). `RUSCAL_GRAPH_SAVE=file.bmp` saves the screen for a look by eye.
- [x] `minifb` window backend: present the framebuffer, forward key events to `ReadKey`/`KeyPressed` while graphics mode is active, window serviced by the main thread (macOS needs that) while the program runs on its worker thread.
- [x] Get working: `clock/` (menu unit, clock unit, tester), `tictac/` (five units, `Ollie`, `CompUnit` AI). Checked headless with scripted keys and saved screenshots; the window opens on macOS.
  - [x] Transpiler fixes they needed: method call arguments that use the receiver (`obj.Prompt(obj.WhoseTurn)`) are computed first (`tests/run/method_args.pas`); two anonymous record types for same-named variables are `EndPoint` and `EndPoint2`, not `EndPoint_2` (`tests/run/anon_records.pas`).
  - [x] DOS drives: C: is the file system's root and other drives exist only when `RUSCAL_DRIVE_x` maps them (7d058ff; before, an unmapped drive was the directory the program started in) (`tictac` does `ChDir('a:\TicTac')` before every game), and names match files on disk case-insensitively.
  - [x] Play a whole game against the computer in the window, by hand (the user, 2026-11-06).
- [x] Milestone: every program in `examples/` transpiles, builds without warnings, and runs. Mark the original "Get them working" TODO done.

## Phase 6: Polish and readability

- [x] Have Claude Fable review every commit since its last code review (`git log 38138d3..HEAD`): three reviewers (language features, the rest of the transpiler, the runtime), every finding reproduced. Fixed:
  - Wrong output: virtual dispatch for `p^` passed to a `var` parameter of an ancestor type; `Random(n)` returned negative values for ranges over 32767 (it's a `Word`); `High`/`Low` of a subrange-typed variable; `FileMode := $40` opened files read-write; `GetDir` above drive C:'s root; printer output lost on Ctrl-C or a signal.
  - Didn't compile or panicked: `Output`/`Input`/`Lst` passed as `var Text`; a static method calling virtual ones, declared below the root, through a pointer; two `var` arguments in one heap record through an index (`arr[i]^.x, arr[i]^.y`; runtime error 204); a pointer and a field behind it as two `var` arguments; sets in `file of` records; `FillChar(b, SizeOf(b), True)`; `Swap($ABCD)`.
  - Missing checks: `New`/`Dispose` with a method that isn't a constructor/destructor; a `with` field as a `for` variable; descendant objects by value (now allowed, copying the ancestor part); `ruscal emit game.pas` without a directory; `SetTextBuf` made its file `mut` (a warning).
  - Tests: run tests and a new examples test now build generated code with `-D warnings`, so warnings fail the suite.
  - Decided with the user: a value outside a set's range is never in it, `300 in s` is False for a constant and a variable alike (FPC truncates the variable).
  - Open: `SizeOf` of a subrange variable (2 here, 1 in TP), of a small set (32 here), and of an object with virtual methods (TP adds 2); a `{$I-}` error still waiting isn't raised by later `{$I+}` I/O (documented in docs/architecture.md); `x shl 32` is 0 where TP masks the count to 5 bits.
- [x] PUNT: Open from the Fable reviews of the fix commits (2026-10-28). Done: a call in an index (`arr[Pick] := ...` where `Pick` reads `arr`, `items[Count]` in a method) is worked out into a `let` first, so it borrow-checks, and the target's index comes before the value, as in Free Pascal; `a[F] := a[F] + 1` runs F twice, as in TP. Still open: And: in `s := s + Bump` where `Bump` changes `s`, FPC calls `Bump` first and Ruscal reads `s` first (TP's order unverified); `i in [-3..-1]` (set elements outside 0..255) depends on whether the ends are literals or named constants; `b in [True]` is `matches!(b, true)`, which clippy flags. Cosmetic: an enum value named like a runtime type gets a needless `_` (`Kind::Ptr_`); a long record's `/// Pascal:` line quotes the Rust name (`FileRecord_ = record ... end`). Two Pascal names that become the same Rust name in different scopes (a variable `enum_range` and a function `EnumRange`) clash.
- [x] Add an "Acknowledgements" section to the README thanking the projects we learned from and compared against. Our code is our own, but being able to run their tools and compare output helped a great deal: Free Pascal (`fpc -Mtp` produces most of our expected test output), daelsepara's turbo-pascal-assembly (the System unit disassembly behind `Random`), J R Stockton's Pascal pages, Borland's Turbo Pascal manuals, p2c (design ideas), and the Rust crates we build on (`clap`, `crossterm`, `minifb`, `insta`, ...). Also Claude Fable, for the code and design reviews.
- [x] `tpc`: a command-line compiler with Turbo Pascal's `TPC.EXE` options (`-$`, `-E`, `-U`, `-Q`; the rest accepted and ignored). Not an `fpc` look-alike, which would hide the real one.
- [x] PUNT: Under `{$I-}`, run each `Write`/`Writeln` argument as its own unchecked call, as TP does: in `WriteLn('x', IOResult)` with an error waiting, TP skips the `'x'` but prints the result (FPC prints `2`; we print nothing).
- [x] PUNT (the user, 2026-11-07): `and`/`or`/`xor` of two Byte values compared with a constant that fits: `s.Attr and Directory = Directory` comes out as `i16::from(s.attr) & i16::from(DIRECTORY) == i16::from(DIRECTORY)`; `s.attr & DIRECTORY == DIRECTORY` computes the same (found by the Fable review of FindFirst).
- [x] Read through the generated Rust for `life.pas` and `bstunit.pas` as if reviewing a colleague's code; fix anything an intermediate Rust programmer would not write (unneeded clones, casts, parentheses, `mut`). Done (2026-11-07, low-hanging fruit): `WriteLn('')` is `pwriteln!()`; one-statement `case` arms are `pattern => stmt,`; a comment in an empty `then` stays there; the alias doc comment reads right when the parameter has the outer name.
- [x] Readability: a function that sets its result only in its last statement (`result = read_key(); result`, `let mut result = false; result = self.root.is_nil(); result`) could end with the expression itself. Needs to know the result isn't read, set elsewhere or used by `Exit`. Done (2026-11-11): the body ends with the value (`n * 2`); 96 functions in the snapshots lost their `result`.
- [x] PUNT: Commit showcase generated output for `hello.pas` and `life.pas` (per open question 7) with a refresh script.
- [x] Make transpiler diagnostics show the source line with a caret; add `--explain` text for the alias-detection error. (Instead of `--explain`, errors caused by a limit of Rust link to a worked rewrite in `docs/rust_limits.md`.)
- [x] PUNT: Write `docs/translating.md`: a user guide with the Pascal→Rust mapping table and the known limitations, generated partly from the translate-test snapshots.
- [x] PUNT: Measure and trim compile time of generated crates (feature flags, no unused dependencies).

## Phase 7: The rest of Turbo Pascal 7's standard units

Borland's *Turbo Pascal 7.0 Programmer's Reference* lists every routine,
variable and constant of the standard units, so "done" is well defined. The
order below puts first what old programs use most. Where the real thing
makes no sense on a modern machine, we **fake it**: accept the call and do
something harmless and plausible, so the program runs, and list the fake in
`docs/language_spec.md`. Each item gets translate and run tests, checked against
`fpc -Mtp` where FPC matches TP.

Next up (moved here from Phase 6 at the user's request)
- [x] Carry Pascal comments into the Rust output at statement boundaries: anchored to statements, declarations, record fields, procedures and block ends (`codegen/comments.rs`, docs/architecture.md §20).

System, the small routines
- [x] `SizeOf` with TP's sizes (`Integer` 2, `LongInt` 4, `Real` 6, `Char` and `Boolean` 1, `string[n]` n+1, records unpadded, arrays), so `FillChar(a, SizeOf(a), 0)` and record-size arithmetic work.
- [x] `High`/`Low` (of arrays, strings, ordinal types and variables), `Swap`, `Assigned`, `RunError(n)`. `SizeOf`, `High` and `Low` are folded into constants, as in TP, so they work in `const` declarations and array bounds. (`Double`, `Single` and `Extended` are all `Real` here, so `SizeOf` gives them 6.)
- [x] `FillChar` and `Move` for the common cases: filling a whole array, record or string with one byte value (zeroing is by far the most common), and copying between variables of the same type. Other uses (partial byte ranges, mismatched types) are a clear error.
- [x] `GetDir(drive, s)`: the current directory as a DOS path, through the drive mapping.
- [x] System variables: `ExitCode` (read/write; `Halt` without an argument uses it), `RandSeed` (read/write, so `RandSeed := 42` gives a repeatable sequence), `FileMode` (0 opens typed files read-only), and `Input`/`Output` as `Text` variables (`Writeln(Output, ...)`). Done as runtime variables (`SymKind::RuntimeVar`: a getter and a setter, `set_rand_seed(42)`), which Crt's `TextAttr` and `LastMode` can reuse; `Input`/`Output` are always the console (reopening them is an error).
- [x] Fake: `MemAvail`/`MaxAvail` return a typical DOS figure (about 500 KB), so "is there enough memory?" checks pass; `Mark`/`Release` do nothing (records are freed when nothing points to them); `SetTextBuf` does nothing (our files are buffered anyway); `Test8087` is 3 (an 80387 is present).

Crt, the variables
- [x] `TextAttr` as an assignable variable (now a read-only function), `LastMode` (the mode from `TextMode`), `AssignCrt(f)` (a `Text` file that writes through Crt, honouring the window and colours).
- [x] Fake: `DirectVideo`, `CheckSnow` and `CheckEOF` are accepted and ignored; `CheckBreak` decides whether Ctrl-Break ends the program (as now, by default).

Printer and Overlay
- [x] Fake `Printer`: `Lst` is a `Text` file appended to `printer.txt` (or the file named by `RUSCAL_PRINTER`), so printed reports can be read. `RUSCAL_PRINTER='|lp'` pipes it to a command instead, for a real printer.
- [x] Fake `Overlay`: `OvrInit`, `OvrInitEMS`, `OvrSetBuf`, `OvrGetBuf`, `OvrClearBuf` do nothing and `OvrResult` is 0 (`ovrOk`); `{$O+}` and `{$F+}` are ignored silently. Overlays only existed to fit in 640 KB.

Sets (a language feature, but `Include`/`Exclude` and `in` are everywhere in old code)
- [x] `set of T` as a runtime `PSet` (a 256-bit set, as in TP), set literals with ranges, `in` (a `matches!` for a list of constants), `+ - *` as `| & -`, `= <> <= >=`, `Include`/`Exclude`, set constants (`PSet::of`/`from_ranges`, `const fn`s), sets in typed constants, records and parameters.

Dos, the rest
- [x] `FindFirst`/`FindNext`/`SearchRec` with DOS wildcards (`*.PAS`, `?`), the attribute filter (`Directory`, `AnyFile`, ...), names shown as on disk.
- [x] `FSplit`, `EnvCount`/`EnvStr`, `DosVersion` (fake: DOS 6.22, `$1606`). `DosError` is now a variable.
- [x] `GetFTime`/`SetFTime` with `PackTime`/`UnpackTime` and the `DateTime` record; `GetFAttr`/`SetFAttr` (read-only from the file's permissions, directory from its type; hidden/system/archive faked from the name and kept in memory).
- [x] `DiskFree`/`DiskSize`, faked (as the user suggested): real disks overflow a `LongInt`, so every drive is a 1 GB disk with 512 MB free; past Z: is -1.
- [x] Fake: `SetDate`/`SetTime` don't change the machine's clock; `GetCBreak`/`SetCBreak` and `GetVerify`/`SetVerify` remember a flag; `SwapVectors` does nothing.
- [x] Never: `Intr`, `MsDos`, `Keep` are a clear "needs real DOS" error (`UnitRoutine::refused`).
- [x] `GetIntVec`/`SetIntVec` faked: vectors are kept and given back, handlers (`interrupt` procedures, `@Handler`) never run, and installing one gives a warning (the user's call).

Graph, the rest
- [x] `DrawPoly`/`FillPoly` (arrays of `PointType`), `GetArcCoords`, and the `Get*Settings` records (`GetLineSettings`, `GetFillSettings`, `GetTextSettings`, `GetViewSettings`).
- [x] `GetImage`/`PutImage`/`ImageSize` with the `PutImage` modes, in TP's own buffer layout (step 4 of `notes/untyped_memory.md`).
- [x] Palettes: `GetPalette`, `GetDefaultPalette`, `SetAllPalette`, `SetRGBPalette`, `GetPaletteSize`; `GraphDefaults`; `SetAspectRatio`; `SetUserCharSize`; `GetDriverName`/`GetModeName`/`GetMaxMode`/`GetModeRange`.
- [x] `SetActivePage`/`SetVisualPage` (two framebuffers, for flicker-free animation).
- [x] Fake: `InstallUserFont` and `SetGraphBufSize` succeed and change nothing (there are no `.CHR` files to load). `RegisterBGIdriver`, `RegisterBGIfont` and `InstallUserDriver` are refused instead, with the reason: they take `@DriverProc` (code linked in from an `.OBJ` file) or a driver file, and the call can simply go.

Last: raw bytes and C strings
- [x] PUNT: From the Fable review of 8172e5e..afba062, left for later: a pointer chain that comes back to the same record (`p^.next^.next^.x := ... * 2` with a cycle) panics with error 204 on the write (the place keeps every pointer on the path borrowed; clone the last handle first, as `with p^` does). (Not worth chasing, the user says: `Val`'s error positions differ from Free Pascal's by one for a too-long number into a Byte or Word and for `'1e'`.) TP 7 may have wrapped `MinLongInt div -1` (its LongInt division is a software routine) where Ruscal gives error 200.
- [ ] Killing `ruscal run` (a timeout's SIGALRM, `kill`) leaves the program it started running, orphaned, with its window open (the second newcomer test, 2026-11-13). Ctrl-C works, since it signals the whole process group. On Unix, `ruscal run` could `exec` the program (`CommandExt::exec`) instead of waiting for it, or forward the signals.
- [ ] A `Graph` window waiting in `ReadKey` uses about 24% of a CPU (seen with `turtles.pas`): the main loop redraws the screen every frame even when nothing changed.
- [x] Findings of review batch AM (docs, 2288903..419d969): after `cargo install --git`, Cargo deletes its checkout (with the runtime generated projects use by path) about a month later, however often `ruscal` runs: now `ruscal`/`tpc` check the runtime is there and say what to do (`check_runtime`); a git install updates without `--force`; copying an example needs a clone, and `rust_calls_pascal` doesn't need `ruscal` installed; its Cargo.toml says the `[workspace]` table can go in a copy; the drift test says how to fix it.
- [x] Findings of review batch AM (code, 64563eb and e70c807): `with Rec(Data) do` read the view once for the whole body, which broke a read-only body (didn't compile), two views or nested ones (all named `rsc_view`), a statement's own view or `Data` used directly or passed on in the body, `with TOuter(Data).Inner do`, and `Break`/`Continue`/`Exit` out of the body: now each statement reads and writes back itself, and a temporary lasts one statement (the rewritten body shares the record's expression, so a later statement found the earlier one's `let`). `temp_name` and a `for` loop's copy step around every Pascal name (`Rsc_Index`, `Rsc_I`). A constant value (`'q'`, `nil`, `[]`, a routine) isn't put in a `let` before a hoisted index, and a value through a pointer gets one `let`, not two.
- [ ] `TRec(P^).A := 3` with `P: Pointer` panics in codegen (`untyped_name`; review batch AM, there before it). `PRec(P)^.A` works; support the cast through `P^`'s bytes, or refuse it with that advice.
- [x] Ask the user: a `ruscal` installed with `cargo install --git` could make generated projects depend on the runtime the same way (`git = ..., rev = <its commit>`) instead of by path into Cargo's cache, so nothing breaks a month later. Superseded (the user, 2026-11-13): Ruscal goes on crates.io.
- [ ] Ruscal on crates.io (the user, 2026-11-13: "can we just use the version that comes from Cargo?"; on the `crates-io` branch, plan `notes/crates_io.md` checked by Fable). Done on the branch: a `ruscal` built from a checkout keeps using its runtime by path, one installed from crates.io writes `ruscal_runtime = "=X.Y.Z"` (decided in `crates/ruscal/build.rs`); both crates have crates.io metadata, a README and the LICENSE; `cargo package --workspace` in CI; docs/releasing.md, and `docs_tests` checks the docs' versions. Left: the user publishes 0.7.0 (walked through), then merge.
- [x] Findings of the review of the `crates-io` branch (c42ca35): the release checklist's dry run came before the commit (Cargo wants a clean tree) and forgot the `Cargo.lock`s; a checkout moved with its `target/` kept the old runtime path (`build.rs` now reruns when the runtime's `Cargo.toml` is gone); nothing tested the packaged crate's choice (`tests/packaged_install.sh`, in CI, with the runtime laid out as `cargo vendor` does); a wrong or empty `RUSCAL_RUNTIME` got the "clone has moved" message; README wording; the checklist says how to recover from a half-done `cargo publish --workspace`.
- [x] Findings of the review of PR #1's fixes (df57b97): the moved-clone message had no test (now a unit test of `runtime_problem`); `tests/packaged_install.sh` checks for any `path =`, runs from anywhere and follows `CARGO_TARGET_DIR`, and CI no longer packages twice; docs/architecture.md and the README say an empty `RUSCAL_RUNTIME` counts as unset. Left, documented: a checkout *copied* with its `target/` (the original still there) keeps the original's runtime path until `cargo clean -p ruscal` (no cheap way for `build.rs` to notice).
- [x] Findings of the last batch review (f5595c8, 7576f1f, a53694b; on the `with-calls` PR): a `with` record chosen by a function call (`with A[Slot] do`, `with Pick^ do`, `with Items[Next] do`) called it at every statement of the body (a53694b made the writing case worse; a read-only body was wrong before); now sema puts the index or pointer in a variable first. `fixed_value` took a procedural variable for a routine, so `Funcs[Bump(I)] := FV` no longer worked `FV` out first (TP 7 does: `c/RUSCAL/IDXPROC.PAS`).
- [x] Findings of the review of the `with-calls` PR (#4): a copy made in a unit's initialization part was never declared (pointer copies too, before); `with Pick^.Arr[Slot] do` ran `Slot` before `Pick` (now left to right); a parameterless procedural variable or field (`A[FV]`) and a parameterless standard function (`A[IOResult - 1]`, `T[ReadKey]`) weren't taken for calls.
- [ ] From the PR #4 review, for later: `with PF^ do` (a procedural variable returning a pointer) doesn't compile, nor does `P := PF`; a pointer copy from a function is `t_rec = pick(..).clone()`, a needless `clone`; the with copies are declared at the top of the routine (`let mut rsc_index_7: i16 = 0;`), where a `let` at the `with` would read better; `with L.Items[L.Next] do` says "the `with` body changes `L`", which misleads; `K := Add(Slot)` where both change a global is rustc E0499; a name qualified by a user unit (`WithUnit.Calls`) is unknown.
- [ ] `for J := P^.N + F to P^.N + F + 1 do` reads both bounds' `P^.N` before either `F` runs (`for_loop`'s bounds are generated before `bound_before_loop` flushes); FPC gives `12 13 14`, Ruscal `12 13`. There before (last batch review).
- [ ] Readability, from the last batch review: a `with Rec(Data)` body that changes the view is three lines a statement (read, change, write back), and the view's teaching comment comes only at the program's first; a `for` copy beside a Pascal `Rsc_I` is `rsc_i_arg` (`rsc_i_2` would read better).
- [ ] If Ruscal ever supports Windows: a runtime path in a generated `Cargo.toml` is a TOML basic string, so its backslashes (and `canonicalize`'s `\\?\` prefix) break it; write it as a literal string or with `/`.
- [ ] Maybe: `ruscal::build::library` could check, when the program compiles, that `ruscal` and `ruscal_runtime` are the same version (a mismatch now shows as errors in the generated code). Fable's idea, from the crates.io plan review.
- [ ] Fable code reviews: resumed (the user, 2026-10-30). Reviewed: up to f75a57b (batches A-AG). Also the `fn-result` branch and its fixes, the batch AG fixes (batch AH: clean), the `float-types` branch (0d8bfe7) and its fixes (d6dd606: batch AI), and the `sizeof-names` and `n-plus-units` branches (plans and code). Also e531d02..dbd9010 (batch AJ) and 2186066 (batch AK). Also the `constant-ranges` branch (a4c5f0c). Also 587b9d9..a467c7d (batch AL) and 9bdc92a..419d969 (batch AM: the batch AL fixes, the rsc_ temporaries, the example and README work). Not yet reviewed: f5595c8, 7576f1f and a53694b (the batch AM code fixes): one last batch. Frozen (2026-11-13): from now on every change is a PR, reviewed before it's merged (CLAUDE.md).
- [x] Findings of review batch AD (8a264c8..2d57c1a): `Abs(-(1.5 + 0.0))` didn't compile (a negated literal-only real); an infinite real constant (`1E300 * 1E300`) was written as `inf` (now an overflow error); `R := -0` was `f64::from(0)` (now `0.0`, and `-4` as a real is `-4.0`); the `Color(5)` message also inside another call (`Ord(Color(4))`), in a typed constant, as a `case` or variant label, and naming the enum behind a subrange; the directives sentence mentions `calls_rust.pas`. Left: `Word(SizeOf(LongInt))` stays `4 as u16` (SizeOf isn't folded as a constant there; not a regression).
- [x] Findings of review batch AE (6c8e8b8): an out-of-range enum typecast in a typed set constant (`[Color(5)]`) got past the check and stopped at run time; `1.0 / 0.0`, `0.0 / 0.0` and `1 / Z` said "too big for a Real": now "division by zero", as TP 7 refuses a constant `/` by 0 ("Invalid floating point operation", `c/RUSCAL/REALDIV0.PAS`; `x / 0` of a variable stays a run-time error); `I: Integer = Integer(1.5)` gave two errors; an overflowing real constant gave its error again at each use; the `Sub(6)` message names the cast; the spec says a too-big real constant is an error. Left: `R := +5` and `-(2 - 7)` as reals stay `f64::from(...)`.
- [x] Findings of review batch AF (0be2d77, f42a979): clean but for `'a' / 0` (and `'a' div 0`) saying "division by zero" where it's a type error; now only a number divided by a constant 0 is.
- [x] Findings of review batch AG (33344d0, 8542921, f75a57b): a field given twice in a record or object constant gave Rust that didn't compile (now an error, as in TP 7); `1.5 div 0` said "division by zero"; a program's own `Registers` record got the Dos message (now told apart by identity); `AH` in a `with` on `Registers` bound an outer `AH`, where TP binds the field; a program that only calls its units had an unused-import warning.
- [x] An untyped `var` parameter seen as a type and passed on to a `var` parameter (`Add1(Integer(X))` in `function Bump(var X)`) loses the change: `I` stays 258 where TP and FPC give 259, and `let mut x = Bytes::of(x)` warns (from the `fn-result` review; on main before it too). The cast isn't taken as a variable for a `var` argument, so nothing writes back. Fixed: the bytes are read into a variable for the call and written back after it, as for a field of one.
- [x] `Single`, `Double` and `Extended` as types of their own (the user, 2026-11-11: try it on a branch). Done: `Single` is an `f32` (arithmetic in `f64`, as the 8087's extended precision), `Double`/`Extended` `f64`s; `SizeOf` and typed files 4/8/10 bytes (`Extended` in the 8087's format), `to-json`/`from-json` too; under `{$N+}` reals print with 15 digits and a 4-digit exponent, as TP 7 did. Checked in DOSBox, byte for byte (`c/RUSCAL/FLOATTYP.PAS`). `Comp` won't be supported (the user, 2026-11-12): its error says to use `LongInt` or `Double`.
- [x] Findings of the review of the `float-types` branch: a `Double` or `Extended` in a variant part without a tag kept a 6-byte `Real`'s bytes (now 8 and 10, as TP); `S := 2 + 3` gave `f32::from(2 + 3)`, which didn't compile; a real constant too big for a `Single` (and an integer one too big for a typed constant, `const B: Byte = 300`) is an error; `Write` to a typed file takes a variable of exactly the file's type, as in TP 7 (checked in DOSBox: a value is "Variable identifier expected", a `Single` for a `file of Real` "Type mismatch"; before, a mismatch gave Rust that didn't compile).
- [x] PUNT (the user, 2026-11-12: "for now"): readability: one operation on `Single`s (`s := s + 1`, `s = s2`) could be written in `f32` (`s += 1.0`), as rounding the `f64` result to `f32` gives the same bits; only chains need the `f64` steps (from the `float-types` review).
- [x] The `{$N+}` print format is a setting for the whole run, from the program file; TP chose per `Write` call, so a unit with another setting prints as the program does. A library (`--lib`) has no `main` to set it. Done (the user, 2026-11-12: on a branch, plan checked by Fable): a unit compiled otherwise wraps the reals it writes (`coprocessor_format(x)`, `software_format(x)`); checked in DOSBox (`c/RUSCAL/NPMIX.PAS`, `NPMIX2.PAS`).
- [x] `ruscal fmt` can't format an `asm` block using `$` as the location counter (`jmp $+2`): the lexer wants hex digits after `$` (from review batch AG). Done: a lone `$` is a token of its own (`Dollar`), which the parser refuses.
- [x] Findings of review batch AC (481168b, 81a0969, d1979e3): a real function of literals only (`Round(2.5 + 0.0)`, `Sqrt(2.0 + 2.0)`) was `(2.5 + 0.0).round()`, which doesn't compile; it's the value now (`2.5_f64.round()`); a typecast folds standard routines on literals again (`Byte(Ord('A'))` is `65_u8`), keeping the program's names; `-$0` is `0` everywhere; the two-var message mentions two fields of one element; the variable-typecast message says TP allows it for the same size, with the type in backticks.
- [x] `{$N+}` (a global switch) after the declaration part: TP 7 says "Invalid compiler directive"; Ruscal accepts it and switches from there (from review batch AC). An error, or a warning? Done (2026-11-11): an error, as in TP 7, which takes `$N` only before the `uses` clause and the declarations (after `interface` in a unit), checked in DOSBox (`c/RUSCAL/NLATE.PAS`).
- [x] Findings of review batch AB (0736325, 3a75410, f38eca2, 389fdec): a Dos or Graph routine with several `var` parameters (`GetDate(D[1], D[2], ...)`, `FSplit`) gets the two-var-arguments check too (it gave Rust that didn't compile); a typecast of a constant expression folds only literals and operators, so `Byte(Ord(Blue))` keeps its names; `RUSCAL_TEST=name` leaves the other programs' builds alone and fails on a name with no test; a negative constant shift count uses its low 5 bits, as in TP 7, and a constant that can't be worked out is still declared (no cascade of "unknown identifier"); `-$10` is `-0x10` in a `case` label and a `Dec` step, `-$0` is `0`; rust_limits says standard routines get the check.
- [x] `Round` under `{$N+}`: TP 7 rounds half to even at run time with the 8087 (`Round(2.5)` is 2), but half away from zero under `{$N-}` and in constants (3); Ruscal always rounds half away from zero (from review batch AB, checked in DOSBox). Follow `{$N+}`? Done (2026-11-10): under `{$N+}`, `round_ties_even()` at run time (checked in TP 7 for every real type, `Real` too); the default (`{$N-}`) and constants stay half away from zero, as TP.
- [x] `Val(S, Word(I), N)`: a variable typecast as a `var` argument of a standard routine is refused ("only an untyped parameter can be typecast and assigned to"); TP allows a same-size typecast there (from review batch AB). The user (2026-11-10): keep refusing it (treating a variable's bytes as another type); the message now says so and what to do instead.
- [x] Findings of review batch AA (fdd5c94, 4296600, d7de6a9): collapsing two casts widened `ShortInt(B)` into a Word wrongly (255, not 65535; only narrowing collapses now); constant `shr` is a LongInt's logical shift and a constant shift count is taken mod 32, as in TP 7; a procedure nested in a virtual method passing `Self` to a `var` parameter of a type with virtual methods is an error (it dispatched to the ancestor); hex stays hex in `case` labels, `Inc`/`Dec` steps and typecasts (`Word($FFFF)` is `0xFFFF_u16`); a procedure nested in one renamed for a Rust keyword is `use_inner`, not `use__inner`. `-$10` is `-0x10` now too.
- [x] Findings of review batch Z (the review fixes b660468, 42804a6, 36f7728, 4b0dd87, 89508e7): constant `shl` and `div` wrap in 32 bits and `Abs`/`Succ`/`Pred` overflow is an error, as in TP 7 (and one error, not two, for `I := MaxLongInt + 1`); a `const` parameter passed by `var` in a call inside a method receiver (`GetP(N)^.Bump`) is caught; a file parameter in a procedural type must be `var`; `ruscal fmt` indents what follows `array[...] of record ... end` right (two test programs were checked in misformatted); `Self` given to a `var` parameter in a virtual method's default body compiles (`self.as_t_shape_dyn()`).
- [x] Findings of review batch W (354baf7..main), for the user: a method that changes a `const` object parameter of more than 4 bytes changes the caller's object in TP 7 and Free Pascal (they pass it by reference), but not in Ruscal (a copy); a 2-byte one is a copy in all three. Pass such a parameter as `&mut` when a method is called on it, or document the difference? (The rest are fixed: constant overflow is an error, a `const` parameter passed by `var` in a method receiver's index is caught, a comment after an empty `then`'s `else` stays with the else branch, a record inside a named type is `Anonymous<Type>`, file parameters must be `var`, and two doc comments moved back.) The user (2026-11-07): match TP fully. Done on the `const-ref` branch: `const` parameters TP passes by reference are `&T`/`&mut T` (plan in `notes/const_ref.md`).
- [x] Readability (from Fable's review of the const-ref branch): a `const string[10]` parameter reads `(*s).length()` (redundant parentheses from `coerce`), `Move(S, ...)` gives `string_view_bytes(&*s, 255)`, and `w(*s, 12)`, `pos("l", *s)`, `*s == "hello"` copy the string where the reference would do (as `var` ones do, `*log + s`). Done (2026-11-10): `pwriteln!(s)`, `w(s, 12)`, `pos("l", s)`, `s == "hello"`, `string_view_bytes(s, 255)` for a `const` string (the runtime takes `&PString` there); `(*s).length()` only for a `string[n]` parameter, which TP refuses anyway.
- [x] A typed constant of an object type (`KCounter: TCounter = (Count: 10; Step: 1)`) is refused ("this initializer doesn't fit type TCounter"); TP 7 allows it for an object without virtual methods. Done (2026-11-11): TP 7 allows it with virtual methods too (checked in DOSBox, `c/RUSCAL/OBJCONST.PAS`); a struct literal with the parent's part in `base`.
- [x] `Val(S, I, I)` (one variable as two `var` arguments of a standard routine) gives Rust that doesn't compile (E0499) instead of the two-var-arguments error; user routines get the error. Done (2026-11-10): the two-var-arguments error, as for a user routine (`ReadLn(X, X)` stays fine).
- [x] Ruscal accepts a function returning an object (`function Make: TObj`); TP 7 refuses it ("Error 34: Invalid function result type", found writing the const-ref test). Done (2026-11-10): an error, as in TP 7, which also refuses a record, array, set or file result (checked in DOSBox); three test programs returned one and now use a `var` parameter.
- [x] Findings of review batch V (c39f2bf..354baf7: header, `{$Q+}` Inc/Dec, SetBkColor, `fmt --crlf`, the TP check programs, byte-sized enum subranges):
  - [x] A byte-sized enum subrange in a variant part without a tag panicked (placed by its 1 byte, read as the enum's 2); `VariantPart` reads and writes it with a one-byte hint now. The translate test covers the tagged variant and `file of array of TPart` too, and the first `enum 1` gets a teaching comment.
  - [x] `SetBkColor(c)` with c past 15 changes nothing in TP 7; Ruscal took `c and 15`. And (checked while at it) `SetColor(17)` draws in colour 1 but `GetColor` says 17 (44 after `SetColor(300)`); Ruscal said 1.
  - [x] PUNT: to-json's messages show an enum subrange as its host type (`array[1..3] of TBig`, not `TPart`).
- [ ] From review batch AL (587b9d9..a467c7d), for later (fixed: a view's index reading the same view, the value before a hoisted index as in TP 7, needless hoists of `St.Items[St.Top]`, `Succ(Low(A))`, `case 'a' of`, `with Rec(Data) do` losing later statements' writes, `Word(Data) := Word(Data) + Next(Word(Data))`):
  - [ ] A `var` argument's index is worked out before the statement's earlier calls: `Write(Bump(A[1]), ' ', Bump(A[A[1]]))` gives `2 3` where TP 7 and FPC give `2 4`. (Indexes with calls have always gone first.)
  - [ ] TP 7 runs the calls in an expression before its other operands (`A[A[1]] + Pick(A)`, `R.A[R.N] + SetN(R)`): Ruscal goes left to right (the known difference in docs/architecture.md, "Evaluation order").
  - [ ] A view of an untyped parameter passed `var` on the right of `and`/`or` doesn't compile (its `let` goes in the block, its write-back outside).
  - [ ] Two elements of one view as `var` arguments (`Swap2(TWords(Data)[0], TWords(Data)[1])`) is a rustc error (E0499), not Ruscal's "passed by `var` more than once".
  - [ ] An untyped `var` argument whose index reads the array (`Zap(B[B[3]], 2)`) doesn't compile: that path doesn't hoist.
  - [x] The temp `index` can shadow a Pascal function named `Index` (`temp_name` avoids variables only). Done: every temporary starts with `rsc_` (the user's idea, 2026-11-12).
  - [ ] `High(TWords(Data))` is refused; FPC takes it.
  - [ ] `case SizeOf(Rec) of` is `match 2`, losing the name; `case 3000000000 of` passes sema and fails in rustc.
  - [x] `with Rec(Data) do` writes the view back after the body: an `Exit` or `goto` out of the body skips it. Done (batch AM): each statement of the body reads and writes back the bytes itself.
- [ ] From review batch AK (2186066), for later (fixed: two views of one untyped parameter as one type in a statement undoing each other, a read after a call changed it in the same statement, the size rule refusing `Word(Data)` and `Byte(S[1])`, `Chr(- -1)`):
  - [ ] Views of one untyped parameter as two different types in one statement (`ReadLn(T, Word(Data), Rec(Data).b)`): each reads its own copy, and the second's write-back undoes the first's change. Rare; refuse it, or write back in order with only the changed bytes.
  - [ ] A string view's write-back (`TName(Data) := '7'`, `Str(n, TName(Data))`) writes the whole `string[5]`, zeroing bytes past the length, where TP copied length + 1 bytes: matters only when the string overlays other data.
  - [ ] Nits: `Str(n, TName(Data))` reads the view it then overwrites (`let mut view = data.read_string..; view = ..`); `Write(F, Word(Integer(W)))` gives `w_ as u16` for a `u16`.
- [ ] From review batch AJ (e531d02..dbd9010), for later (fixed: two typecast arguments sharing a temp, a typecast untyped parameter as `Val`/`Str`/`ReadLn`'s `var` argument, `Chr(300)`, `Write(F, Word(B))` of another size, `Comp` in an expression or `SizeOf`):
  - [ ] `Read(F, Word(I))` from a typed file is refused (a typecast isn't a place in Ruscal); TP 7 took it (out/review/aj/tp/RDCAST). Could read into a temp and assign back.
  - [x] Standard routines' own Byte/Word parameters get no constant range check: `GotoXY(300, 1)` compiles; TP 7 says "Constant out of range". (`Inc(B, 300)` wraps, as in TP.) Done for `Crt`'s (`GotoXY`, `TextColor`, `TextBackground`, `Window`, `Delay`, `Sound`: `Param::Byte`/`Param::Word`); the other units' routines take any integer, as their TP types weren't all checked.
  - [ ] A subrange parameter takes an out-of-range constant (`PS(11)` for `1..10`); TP 7: Error 76. Subranges are their host type in Ruscal. Left (2026-11-12): a subrange type keeps only its host type, so its bounds are gone by the time a call, an assignment (`D := 11`), a field or an array element is checked; doing it means carrying the bounds in `Type`, a bigger change.
  - [x] An open array of Byte given a single constant (`PA(300)`) isn't range-checked; TP 7 refuses any single value there (Error 122). Done: checked against the element type (Ruscal still takes a single value, which TP refused).
  - [ ] Two rules for an integer literal into a `Single`: `S := 16777217` is the literal `16777217.0` (rustc rounds it, as the 8087 did), a named constant past 2^24 `BIG as f32`. Harmless.
- [ ] From the review of the `sizeof-names` branch (pre-existing, not SizeOf's):
  - [x] `A[High(A)] := 1` doesn't compile: `a[a.high()] = 1` borrows `a` mutably and immutably at once (E0502); also `A[High(A) - 1] := 2`. Reading `a[a.high()]` works. Hoist such an index into a `let` before the assignment. Done: an index that reads the variable being changed is worked out first (`let index = a.high(); a[index] = 1;`), as is `S[Length(S)] := 'z'`.
  - [x] A constant `case` selector (`case 2 of`, `case SizeOf(Rec) of`) is refused with "expected a Integer label, found Integer"; FPC accepts it. Done: the selector is typed as its integer type.
  - [ ] A negative constant count (`BlockWrite(F, P, -6)`) is accepted and writes nothing; `SizeOf(Point) - 10` becomes 65530 and runtime error 201. TP likely refuses the constant (check in DOSBox).
- [x] Findings of review batch U (f29ca45..c39f2bf, the SizeOf work), for the user to decide (the three compile errors, the variant-part comment and notes/ are fixed in fff7a13): `SizeOf` stays a number in some places where its type is known, so it could be a name: `{$Q+}` arithmetic (`13_i16.checked_mul(i)`), a Real context (`f64::from(17)`, could be `Rec::SERIALIZED_SIZE as f64`), `WriteLn(-SizeOf(Rec))`, the runtime calls a reader most wants it in (`Seek`, `BlockRead`, `GetMem`, `Move`: `Rec::SERIALIZED_SIZE as i32` would do for `impl Into<i32>`), an index `a[SizeOf(Point) + 1]` (`a[4 + 1]`), `SizeOf(Rec) in s`; and two casts in a row (`Word(SizeOf(Rec))` is `Rec::SERIALIZED_SIZE as i16 as u16`). Either name them or make the docs say "in most places". Done (the user, 2026-11-12: on a branch, plan checked by Fable, `notes/sizeof_names.md`): named in all of them but a sum with `High(a)` and an array bound; a `case` label stays a guard; the two casts no longer happen.
- [x] Findings of review batch T (d0b1780..f29ca45):
  - [x] An object's field as an untyped argument (`Move(C.R, W, 2)`, `BlockWrite(f, C.R, 2)`) started at the object's first byte: only records' field offsets were counted. Objects have `ObjectType::field_offset` now (the parent's part, with its VMT field, first).
  - [x] `for i := 1 to p^.Count` (a bound read through a pointer) with a body that changes `p^` was runtime error 204: Rust keeps the range's `p.get()` borrowed for the whole loop. Batch S's `Low(p^.Items)..High(p^.Items)` bounds hit it too. Such a bound goes into a `let` before the loop now (TP works out the bounds once anyway).
  - [x] `const TopLet = High(Letter)` (a Char subrange) and `High(Char)` were Integer constants (`WriteLn` printed 122, `c := TopLet` was an error); they're Chars (`b'z'`, `u8::MAX`). `const TopW = High(Word)` is a Word (`u16::MAX`), not `i32 = 65535`, likewise `High(Byte)`, `Low(ShortInt)`.
  - [x] `array[-K..-1]` read `(-1 + K + 1)`; it's `K` (and `array[K..10]` is `11 - K`).
  - [x] A method called on a typecast untyped parameter (`TCounter(Data).Bump`) ran on a copy, so its changes were lost (and `let mut data` drew an `unused_mut` warning); it runs on a view written back after the call.
  - [x] `notes/file_json.md` still said `to-json` refuses objects with virtual methods.
  - [x] PUNT: `High(a)`/`Low(a)` of `a: array[Boolean] of Integer` print `1`/`0` (TP: TRUE/FALSE), and `for b := False to True` (or `Low(a) to High(a)`) doesn't compile (`false..=true` isn't a Rust iterator). Rare in real programs: fix, or document? The user (2026-11-07): punt; no fix or docs needed.
- [x] Findings of review batch S (721ee55..d0b1780):
  - [x] A `for` loop over `Low(a)..High(a)` (or a subrange's, or `Low(Integer)`) whose variable is used only in the loop didn't compile: the type suffix went on `a.low() as i16` (`i16_i16`). It goes only on a bare number now.
  - [x] A constant expression that doesn't fit its operands' type (`C + 1`, `C = 32767`) was cut back to an Integer (-32768); TP types it by its value, a LongInt, and so the arithmetic around it: `i * (C + 1)` is 98304 for `i = 3`.
  - [x] `High`/`Low` of a field (`High(r.Items)`, `High(Items)` in a method or a `with`) stayed a number; it's `r.items.high()`. `High(Letter)` for a Char or enum subrange gave the whole type's bound (chr 255); it's the subrange's.
  - [x] `const Top = High(Integer)` and a `case` label `High(Integer)` are `i16::MAX`; `array[-K..K]` reads `K + K + 1`, not `K - -K + 1`; `{ N as usize }`, not `{ N as i16 as usize }`; the sets section of the architecture contradicted the named-constants rule.
  - [x] PUNT: `Cnt = Ord(Last) - Ord(Mon) + 1` (enum constants) gets no `// Pascal` comment, where other worked-out constants do; constant `x / Z` with `Z = 0` is runtime error 200 (TP may have refused it when compiling). (Settled 2026-11-11: TP 7 refuses it, and so does Ruscal now; batch AE.)
- [x] Findings of review batch R (b89b0fe..721ee55):
  - [x] `Inc(i, 32768)` on an Integer (`Inc(s, 128)` on a ShortInt) was an out-of-range literal that rustc refused; it wraps to -32768 now, as in TP.
  - [x] Division by a constant 0 in a subrange, array bound, string length, variant or case label gave a second, generic error (and a type declaration both twice); the docs didn't say it's a compile error, nor that a parameter's type must be a type's name.
  - [x] Real division by zero (`x / 0`) printed `+Inf`; TP stops with runtime error 200. The user (2026-11-06): stop with runtime error 200, as TP did.
  - [x] PUNT: `from-json` takes `[1e-400]` as 0 without an error (serde_json reads it as 0.0), where `[1e-320]` is refused as too small. The user (2026-11-06): leave it.
  - [x] Codegen's `constant_int` was a second constant evaluator next to sema's `eval_const`, and knew less (`Inc(b, Ord('A'))` under `{$Q+}` took the long form). Fable's advice (the user: "Try asking Fable"): sema records each constant expression's value (`Analysis::consts`) and codegen reads it; a named constant stays a name (`b += K as u8`), as a reader wants to see where 5 comes from.
  - [x] Also from that advice: `Ord` of a Char or char literal into an 8-bit type is written as the character (`b.checked_add(b'A')`, `b = c`), not `i16::from(b'A') as u8`; a set range of constants (`i in [K + 1..K * 2]`) becomes a `matches!` pattern; `case_labels` can be read from `consts`.
  - [x] PUNT: `Inc(c, s)` on a Char isn't checked under `{$Q+}`; a literal above MaxLongInt (`2147483648`) is accepted and rustc refuses it.
- [x] Findings of review batch Q (70d5d51..b89b0fe):
  - [x] `Dec(b, -K)` (a constant step) was error 215 under `{$Q+}`, where `Dec(b, -5)` turns round; a checked index was written twice in the read-then-write block (now only for a place through a pointer); `Inc(a^[i], a^[i])` shadowed `value` with `value`.
  - [x] Division by a constant 0 went to rustc, which refused it; it's TP's compile error now. `p: ^Node` as a parameter's type said "unknown type `Node`"; now it says to name the pointer type. `from-json` printed a Real out of range with hundreds of digits.
  - [x] Under `{$Q+}`, `Inc(b, s)` or `Dec(b, s)` on a Byte or Word with a negative variable `s` was error 215 (`b.checked_sub(s as u8)`). The user (2026-11-06): add in a wider signed type and check the result, as a negative constant step does.
- [x] Findings of review batch P (44cbc65..70d5d51):
  - [x] `Exec('true.exe')` ran `/usr/bin/true`: a bare name was looked up on `PATH`; now it runs from the current directory only, as in DOS.
  - [x] `{$Q+}` `Inc(r^.q^.N, 40)` (two pointers) didn't compile; `from-json` refused `to-json`'s output for a Boolean variant before a Byte one; the Real range in `from-json` was approximate (2.92e-39 stored as 0, the largest Real refused).
  - [x] `tpc -E` didn't make the directory, so the README's recipe for menu.pas's games failed; Crt didn't put its colours back after `Exec`.
  - [x] Under `{$Q+}`, `i * (2 + 3)` checked the constant `2 + 3`, and `w * (2 + 3)` (a Word), `l - (2 + 3)`, `Dec(b, 2 + 3)` didn't compile. The user: simplify, as Fable advised: a constant expression is never checked (TP works it out when it compiles), so it's written as under `{$Q-}`: `i.checked_mul(2 + 3)`.
  - [x] From Fable's advice on that: a kept constant expression is computed in the context's type, where TP used 32 bits: `i * (30000 + 30000 - 40000)` fails with rustc's `overflowing_literals`, and `const C = 32767; i * (C + 1)` with `arithmetic_overflow` (both modes). Fold such an expression to its value when an intermediate doesn't fit. (Done: `Inc(b, 2 + 300)` wraps as `Inc(b, 302)` does, and `Dec(b, -K)` turns round as `Dec(b, -5)` does.)
  - [x] An anonymous pointer type as a record field (`q: ^Inner;` inside a record) panicked codegen ("only named pointer types are emitted"). The user: support it. It's `Ptr<Inner>`, as for a variable.
- [x] Findings of review batch O (f4219c0..44cbc65):
  - [x] `{$Q+}`: `(2 + 3) * i` didn't compile (a suffix on a folded expression); `Inc(p^.N)` was runtime error 204 (two borrows of the heap record).
  - [x] `to-json` read a Boolean nested tag as its byte, not as TP's any-nonzero-is-True, so `from-json` refused `to-json`'s own output.
  - [x] `to-json` on a source with `{$I file.inc}` gave a confusing error; `from-json` wrote 0 for a Real too small; `owners` moved into `Out` (no more `too_many_arguments`); README names `{$Q+}`.
  - [x] Tests: nested variant parts, a tagless record over a Boolean, an object with a parent, sets of 10..20 and of Byte, files of strings and integers, a unit as the source (tests/json/more.pas).
- [x] Findings of review batch N (c537266..f4219c0):
  - [x] `Halt` inside `call` with `panic = "abort"` aborted with "Halt(0)" instead of exiting with its code.
  - [x] The abort note's wording assumed `call`; `cast` lost its doc comment to `is_unsigned`; the test matched "Runtime error 2" in "201".
  - [x] `Byte(i shr 1)` and `Word(Integer(i shr 1))` kept a needless `as i16`. (Still open, cosmetic: `Word((i shr 1) shr 1)` has `as i16 as u16` on the inner shift.)
  - [x] A typecast of a real, a string or an enum value out of range in a constant says "expected a constant expression" (and then "unknown identifier"); a specific message would be better (fpc: "Illegal type conversion"). A Real or a string: "invalid type cast", as TP 7 says ("Invalid type cast").
  - [x] An enum typecast out of range in a constant (`Color(5)`) still says "expected a constant expression". TP 7 accepts it (checked in DOSBox), but a Rust enum can't hold the value, so it's a limit of Rust: a specific message needs a `docs/rust_limits.md` section with a rewrite (an integer instead of the enum). Done (2026-11-10): "Color has no value 5 (its values are 0 to 2)...", linking to a new rust_limits section.
  - [x] PUNT: `const X = Small(300)` for `type Small = 0..10` gives 44, unchecked; fpc reports a range error. TP 7 unverified (for the user, above).
- [x] Findings of review batch M (a7c84bf..c537266):
  - [x] With `panic = "abort"`, an error inside `call` or an I/O error under `{$I-}` ended the program with nothing on stderr.
  - [x] `Word(+5)` wasn't folded (`5 as u16`); `Word(Integer(-1) shr 1)` cast to `i16` and back.
  - [x] Tests: out-of-range and nested conversions, a folded negative literal as a method's receiver, `not Odd` of expressions (tests/run/casts_folded.pas).
  - [x] Typecasts in constant expressions (`const W = Word(-1)`, `case` labels, array bounds): TP 7 allows them (the user: now). `IntKind::wrap` is shared with `value_cast`.
  - [x] `Odd`/`not Odd` of a Byte/Word as `b.is_multiple_of(2)`, as clippy's default `manual_is_multiple_of` wants (the user's choice).
  - [x] A bit operator's operands get parentheses unless simple: `(i << 1) & 3`, `(a & b) | c` (the user: parentheses make it easier to understand).
- [x] Findings of review batch L (6b96dc9..a7c84bf), fixed (the user's choices: `super::` in linked Rust, no overflow probe under `panic = "abort"`, Boolean `Succ`/`Pred` as for an enum, clippy-clean where a person would write it so):
  - [x] A linked `.rs` that names the unit's types `crate::X` (as docs/calling_rust.md and calls_rust.rs say) doesn't compile under `include_library!`; `super::X` works everywhere.
  - [x] The overflow probe aborts the program under `panic = "abort"` (`catch_unwind` can't catch).
  - [x] A user cast of a negative literal (`Word(-1) div 2`) doesn't compile.
  - [x] `Succ`/`Pred` of a Boolean doesn't compile (`ok + 1`).
  - [x] The `FEATURE_CRT` check's message comes after the missing-name errors, not first (docs wording).
  - [x] `single_file` keeps the comment explaining the `#![allow]` it strips.
  - [x] Readability: `not Odd(a)` as `!(a % 2 != 0)`; a shift mixed with arithmetic without parentheses (clippy's `precedence`); `Char(66)` as `(66 as u8)`.
  - [x] docs/embedding.md doesn't mention `library_with`/`unit_dirs`, or that a linked `.rs` uses `super::`.
  - [x] `tpc_tests` need the `cli` feature (`required-features`).
  - [x] Low: `calls_rust.pas`'s sort has no run test of its own (left: `rust_callback` covers Rust calling back into Pascal, and the examples test builds it).
- [x] Findings of review batch K (1fc2d9b..6b96dc9), fixed:
  - [x] A function ending in `repeat ... until False` doesn't compile (`if false { break; }` makes the loop `()`); `repeat ... until False` should just be `loop`.
  - [x] A `goto` counts as leaving a `while True` loop, so the Rust after it is unreachable (warnings): only a `Break` leaves it.
  - [x] A labeled `Break` (`L: Break`) isn't seen: the loop is taken as endless and what follows is commented out (wrong output).
  - [x] `{$I-}` I/O in Pascal code called outside `call` prints "Runtime error 2" although the Pascal handles it.
  - [x] The `with` comment still appears when the rewrite only copies the pointer (`with p^ do p := q`); that copy deserves its own comment.
  - [x] A declared label no `goto` targets, after an endless loop, makes the next statement live (a warning). The user (2026-11-04): accept it, it's rare.
  - Decided (the user): a runtime error in Pascal code called outside `call` stays a Rust panic (exit 101); `call` gives TP's code.
  - [x] A program whose only runtime uses are dead gets an unused-import warning for the prelude.
  - [x] docs/architecture.md doesn't mention endless loops in the dead-code rules.
- [x] Findings of review batch J (bc55d07..1fc2d9b), fixed (the user's decisions: always a context; code after an endless loop is dead; the innermost `call` gets a `Halt`; `tpc` keeps the file-name check):
  - [x] `--lib`: an interface routine that assigns to a value parameter (`mut n`) makes a `lib.rs` that doesn't compile.
  - [x] `Halt` inside a `{$I-}` I/O statement inside `call` is taken for an I/O error (`IOResult = n`), and the Pascal code goes on.
  - [x] A runtime error outside `call` is reported only if a `call` or `run` came first (the hook is installed there).
  - [x] `--lib`: a unit with no variables never runs its initialization parts (no context, no `new()`).
  - [x] `while True do` with no way out but `Exit`: the trailing `result` and the statements after it are unreachable (warnings).
  - [x] A `repeat` body ending in dead code after a `Break`/`Exit` still gets the unreachable `until` test.
  - [x] Small: `library_method`'s unused `captures`; docs/embedding.md on errors outside `call` and on `Halt` in nested `call`s.
- [x] Findings of review batch I (a132173..bc55d07), fixed:
  - [x] A `goto` out of a goto loop nested in another goto loop (`Main:` ... `Inner:` ... `goto Finish` ... `goto Main`; `Finish:`) loops forever: the block isn't widened past the outer loop.
  - [x] `--lib` on a unit that uses Graph hangs in `InitGraph` (the window needs `run`'s main thread). The user's decision (2026-11-03): refuse it; a program that uses Graph should be a Pascal program that calls out to Rust.
  - [x] `--lib`: `use counter::*` in the host is ambiguous (the crate and its module have one name); the unit's own module should be private, re-exported.
  - [x] `--lib`: no public way to shut the runtime down (Crt's raw terminal, a `|command` printer).
  - [x] Two units linking the same Rust file is an error since bc55d07; only different files with one module name should be.
  - [x] A runtime error outside `call`, after a `call`, kills the host without a message (the hook stays installed).
  - [x] `Halt` inside `call` exits the host. Decided: `call` returns it as an `Err` instead.
  - [x] `Exit` or `Break` as the last statement of a `repeat` body: the `if cond { break; }` after it is unreachable (a warning).
  - [x] A labeled final `Exit` (`Fin: Exit;`) still warns; a dropped final `Exit` loses its comment.
  - [x] `--lib` with a file not named after its unit: the error quotes the made-up program's `uses` line.
  - [x] `--lib`: an interface `external` isn't re-exported; a unit's variables are parameters the host must own. The user's decision (2026-11-03): bundle a unit's variables into one generated record for `--lib` now.
  - [x] PRTurtle: `Wrap` in a zero-size `TurtleWindow` hangs.
  - [x] `while True do` gives rustc's `while_true` warning: it should be `loop`.
  - [x] `tpc unit.pas`: decided, check the unit compiles and say how units are used (the program that uses it, or `ruscal build --lib`), naming `tpc`.
  - [x] Small: `with r do goto L` emits the `with` comment for nothing.
- [x] Findings of review batch H (86ec036..a132173), fixed:
  - [x] A labeled main loop with a forward `goto` out of it (`Main: begin ... goto Finish ... goto Main end; Finish:`) loops forever: the loop is put outside the block.
  - [x] `Inc(i, -32768)` on an Integer (a negative step at the type's minimum) gives a literal out of range.
  - [x] Constant arithmetic that wraps (`b := 250; Inc(b, 10)`) is rustc's deny-by-default `arithmetic_overflow` error.
  - [x] PRJson: a `\u` escape above 32767 overflows an Integer and gives a garbage byte.
  - [x] PRJson: a string whose escaped form is over 255 characters is written without its closing quote.
  - [x] PRJson: `1e400` reads as infinity and is written as `+Inf`.
  - [x] Dead code after `if ... then goto A else goto B`, or after a `begin ... goto L end`, still warns.
  - [x] A routine whose last statement is `Exit` warns (unreachable `result`).
  - [x] Commented-out dead code loses its indentation.
  - [x] PRTurtle: `Wrap` with the turtle already outside the window draws a stray line; `Forwd(0)` there runs away.
  - [x] The `r#` branch in `link_externals` is dead (`snake_case` already escapes keywords); `{$L sub\type.rs}` with a backslash isn't found.
  - [x] Small: `goto::dead`'s doc comment; `Inc(b, 256)` emits `b += 0`; the comment names `sound_rs.rs` for a renamed module; two `{$L}` files with one name; PRTurtle leaves Graph's colour and write mode changed; PRJson's tiny numbers and `JsonSet`/`JsonAdd` on the wrong kind.
  - Kept as is (decided, open to the user): `Round` rounds half away from zero, as TP documented (FPC rounds half to even); `JsonToString` cuts at 255 characters (documented).
- [x] Findings of review batch G (076ffea..86ec036), fixed:
  - [x] A labeled `begin ... goto Main end` (a main loop) gets an unreachable `break 'main` after the `continue` (a warning).
  - [x] Two labels on one statement (`L1: L2: x`): a `goto L2` is refused as a jump into a statement.
  - [x] `Inc(p^.v, p^.n)` (a step read from the heap record being changed): runtime error 204.
  - [x] `Inc`/`Dec` on a Boolean doesn't compile.
  - [x] In a method, a bare procedural field called with arguments (`Show(n)`) is refused.
  - [x] `Dec(c, 2)` on a Char gives `c -= 2 as u8` (a needless cast).
  - [x] Document that `Inc`/`Dec`/`Succ`/`Pred` past the ends of an enum are a range error (a Rust enum can't hold an ordinal outside it; TP with `{$R-}` stored it).
  - [x] Dead code after an unconditional `goto` or `Exit` gave an `unreachable_code` warning. The user's choice: the Rust keeps it, commented out.
  - [x] Label a loop that holds a goto block, so `Break`/`Continue` inside the block work (the user: now).
- [x] Findings of review batch F (3ab3ee4..076ffea), fixed:
  - [x] A parameterless procedure field or element called as a statement (`H.S;`, `with H do S;`) is called twice: `.get()(..).get()(..)`.
  - [x] Every unary builtin (`Odd(F)`, `Abs(R.Next)`) refuses a parameterless function value; only `Assigned` should look at the value.
  - [x] In a method, a bare object field holding a parameterless function (`N := Next`) isn't called.
  - [x] `Val(S, p^.v, p^.code)`: two targets in one heap record are runtime error 204.
  - [x] `Insert`, `Delete`, `FillChar`, `Move` writing a heap field while reading the same record: runtime error 204.
  - [x] A call statement through an element or a dereference (`Arr[1];`, `PS^;`) is refused.
- [x] Findings of review batch E (d1097cb..3ab3ee4), fixed:
  - [x] Answered (a newtype, the user): a routine kept in a procedural type whose globals include a variable of that type (a state machine's `Current := Second`) makes a recursive type alias (rustc E0391). A newtype `struct State(ProcVar<...>)`, or a documented refusal?
  - [x] A parameterless function *variable* is called where TP uses its value: `G := F`, `Run(F)`, `Assigned(F)`, `@F`, `@F = nil`.
  - [x] The converse: a parameterless function in a field or element (`R.Next`, `Fs[1]`) isn't called in an expression; the `F = G` message is misleading there.
  - [x] A unit's procedural type whose routines use a program-declared type: the unit's module spells `Stats` without `crate::`.
  - [x] Two untyped `var` arguments from one heap record (`Both(pp^.y, pp^.x, 2)`) are runtime error 204.
  - [x] The typed-constant tag check doesn't reach nested variant parts.
  - [x] `Str(p^.v:2, p^.name)` and `Val` into a heap record's field from the same record: runtime error 204 (the value needs a `let`).
  - [x] Answered (216, the user): a nil procedural call is runtime error 210 (TP: "Object not initialized"); FPC and the design note say 216.
  - [x] TODO's "Procedural types and procedure parameters" item; a procedural type alias's doc comment shows the signature, not the declaration (kept: a record's shows its type alone too).
- [x] Findings of review batch D (697e1d1..d1097cb), fixed:
  - [x] A routine that changes a lent Char array through a `var` argument or as a method isn't run first (check_lends looks at captures only; use the call site's var_args too).
  - [x] A record or enum field in a tagless variant part doesn't compile (its type needs a FileRecord: register it); then a nested setter that reads its own record needs the value in a `let` first.
  - [x] Insert/Delete/FillChar on a `string[n]` field of a tagless part, and `Delete(p^, ...)`: `place()`'s leading `*` before a method; and `S4(data) := t + 'z'` needs parentheses in `write_string(&(...), n)`.
  - [x] An index inside a byte-field place is evaluated as a mutable place (`p.B[p.B[0]] := 9` borrows `p` twice).
  - [x] Sets of a subrange take 32 bytes in SizeOf, byte views and files; TP sizes them by range (`(Max div 8) - (Min div 8) + 1`).
  - [x] Move between two fields of one heap record of different types is still runtime error 204.
  - [x] A cast on the left of `<` doesn't compile (`i shr 1 < 50`, `Word(i) < w`).
  - [x] A `string[n]` field of a tagless part writes cap+1 bytes and clamps the length; TP touches Length+1 bytes (the `S[0] := #3` overlay idiom).
  - [x] Untyped var arguments skip the aliasing check (a rustc error instead of Ruscal's message).
  - [x] Smaller: `Str(1234:5, s)` into a `string[3]` isn't cut; `New(PNode(q))` through a Pointer; a typed constant whose tag selects another variant than its fields; the accessor comment's "bytes 0 to 4".
- [x] Untyped memory, as planned in `notes/untyped_memory.md` (agreed with Fable's review; the user said go ahead). Done: step 0 (TP-exact typed files), step 1 (untyped `var` parameters, byte views, `Move`/`FillChar` between types), step 2 (untyped files, `BlockRead`/`BlockWrite`), step 3 (the untyped `Pointer`, `GetMem`/`FreeMem`), step 4 (`GetImage`/`PutImage` in TP's layout), step 5 (`PChar` and `Strings`, with `Char` arrays lent a copy for one statement).
- [x] Question for the user (from a Fable review): is the directory the program starts in a drive's root? Answered by 7d058ff: no, C: is the file system's root, so the start directory is just the current directory, and `FindFirst` lists `.`/`..` there.
- [x] Untyped files (`file` without `of`) with `BlockRead`/`BlockWrite`, and untyped `var` parameters, as byte views of records and arrays (with `SizeOf`).
- [x] `PChar` and the `Strings` unit, as a byte buffer plus an offset; a `Char` array used as a `PChar` is lent a copy for the statement, and keeping a `PChar` into one is a compile error (the user chose this over shared arrays, 2026-10-29).
- [x] `WinDos`: the `Dos` routines, and wrappers with `PChar` strings.
- [x] `Write`/`Read`/`Str`/`Val`/`Assign`/`Rename` on `Char` arrays and `PChar`s (TP 7's extended syntax).
- [x] Packed strings: a string constant assigned to a `Char` array, and one used as a string (assigned, compared, joined, passed).
- [x] Skipped, on purpose: `Graph3` and `Turbo3`, TP 7's units for running Turbo Pascal 3.0 programs (TP 3's turtle and point graphics, and its `Kbd` file, integer `MemAvail` and the like). The examples are TP 5.5/6.0 code; `uses Graph3` or `Turbo3` says it's a TP 3.0 compatibility unit Ruscal doesn't provide. Graph3 on top of our Graph was estimated (2026-10-31: CGA modes and palettes, `Write` on the graphics screen, turtle graphics, no FPC to compare with) and punted by the user until a program needs it.

## Phase 8: Tier 3 and FFI (as interest dictates)

- [x] Variant records and procedural types, as in `notes/variant_records_and_procedural_types.md`: step 1 (tagged variant parts, flattened, with TP's layout in files), step 2 (tagless parts as TP's bytes, behind accessors), step 3 (nested parts), steps 4-6 (procedural types: values, calls, globals through them, as bytes).
- [x] PUNT: Left for later, if a program needs it: `Func(P)`, a `Pointer` turned back into a routine.
- [x] PUNT: Argument order in `Inc(a[Pick], Bump)`: Ruscal runs `Pick` before `Bump`, Free Pascal `Bump` first (from the Fable review of 99e4f09). TP doesn't document it; obscure.
- [x] Hex constants as TP reads them: a 32-bit `$AABBCCDD` is a `LongInt` bit pattern (`$FFFFFFFF` is -1); Ruscal says it's out of range. Fixed (checked in TP 7: `$100000000` is "Error in integer constant").
- [x] Readability: a hex constant becomes decimal in the Rust (`$FF00` is `65280`); `0xFF00` would keep what the programmer wrote. Done: a hex literal stays hex (`0xFF00`), unless it's a negative LongInt (`$FFFFFFFF` is `-1`).
- [x] Change the generated files' first line from ``//! Generated by Ruscal from `foo.pas`. Do not edit by hand.`` to `//! Generated by the Ruscal Turbo Pascal to Rust transpiler` (the user, 2026-11-07): "Do not edit by hand" contradicts translating once and editing the Rust from then on. The translate snapshots change with it. Done 2026-11-07, then (the user) a third line, ``//! File: `foo.pas` ``, after the `//! Pascal:` line; the same for a library's `lib.rs`, and the generated `Cargo.toml` says `# Generated by the Ruscal Turbo Pascal to Rust transpiler`.
- [x] Assigning to a `const` parameter (`procedure P(const n: Integer); begin n := 2 end`) is accepted; TP rejects it. Found while rewriting the README's "What's supported", 2026-11-07. Fixed: rejected as in TP 7 (checked in DOSBox), but a method call on one and `p^ :=` through one are allowed, as there.
- [x] Open array parameters (`a: array of Integer`, TP 7) are a parse error; the README lists them as not supported yet. Done on the `open-arrays` branch (plan in `notes/open_arrays.md`, reviewed by Fable): `&OpenArray<T>` / `&mut OpenArray<T>`.
- [x] Readability: `for b: Byte := 0 to High(a)` with an open array `a` is `0..=a.high() as i16 as u8` (a double cast); `a.high() as u8` would do. Done: narrowing twice is one cast.
- [x] An anonymous record type is named `Record` in Rust (`fn pair(&self) -> Record`); naming it after its field (`Pair`) would read better. Done, as the user suggested (2026-11-07): `AnonymousPair`, after its field or variable (an anonymous enum too), which can't be taken for a type the program named.
- [x] Field names needn't avoid the runtime's function names (done: `names::field_name` escapes only Rust keywords): a field `W` becomes `w_` because `w` is the runtime's width helper, but a struct field can't clash with a function.
- [x] Virtual methods, constructors, destructors: a trait per object in the hierarchy for dispatch, an enum per hierarchy for pointers (`notes/virtual_methods.md`, docs/architecture.md §16), and `TypeOf`.
- [x] Procedural types and procedure parameters (steps 4-6 of the variant records and procedural types item).
- [x] Structured `goto`, the user's idea (2026-10-30): a jump forward is a labeled block (`'done: { ... break 'done; }`), a jump back a labeled loop (`continue 'again`), in `sema/goto.rs`. Jumps into a statement, and crossing ones, are refused with a rust_limits link.
- [x] `Break`/`Continue` inside the statements a `goto` skips or repeats, for a loop around them: label that loop (`break 'while_loop`) instead of refusing.
- [x] TP-exact binary file layout including 6-byte `Real`, so `examples/database/mark.dat` can be read (step 0 of `notes/untyped_memory.md`).
- [x] PUNT: The per-procedure "place" option for `var` parameters that hit `RefCell` aliasing.
- [x] PUNT: Bundled-globals option (`struct Globals` per unit) for programs with very many globals. (By hand, a unit can do it already: `PRTurtle` keeps its state in one record, `TTurtleContext`.)
- [x] FFI to Rust: `external` routines in a Rust file named by `{$L file.rs}` (the user's choice, as TP linked `.OBJ` files), with crates from `//! cargo:` lines; `tests/run/rust_externals.pas` is the worked example.
- [x] Embedding: `ruscal build --lib unit.pas` and `ruscal_runtime::call(...) -> Result`, with a host example that calls `BSTUnit` from Rust (`tests/embed/bst_host.rs`, docs/embedding.md). Rust calling back into a Pascal program through a procedural value works too (`tests/run/rust_callback.pas`).
- [x] PUNT: FFI to C: `external 'C'` → `extern "C"` block with `#[repr(C)]` records, `build.rs` with `cc`.
- [x] PUNT: Ideas only, for already-compiled Pascal: Free Pascal `{$mode tp}` C-ABI library, or DOSBox bridge. Not scheduled.
- [x] PUNT: `--integer-width 32` flag if the user wants it.

## Testing track (runs alongside every phase)

- [x] PUNT: One translate snapshot and one run test per construct in `docs/language_spec.md` tier 1 and 2; keep a checklist table in `tests/README.md`.
- [x] If FPC is installed (open question 2): script `tests/gen_expected.sh` that compiles each `tests/run/*.pas` with `fpc -Mtp` and records its stdout as `*.out`; commit the outputs.
- [x] Write our own self-checking run tests (exit code 0 when every check passes) for the System, Crt, Dos and Graph routines (`system_*`, `crt_vars`, `dos_misc`, `graph_*` and others; see `tests/README.md`), covering the kinds of cases Free Pascal's test suite covers. Don't copy FPC's or p2c's tests: both are GPL and this project is MIT. Running `fpc -Mtp` as an external program to produce expected output (`tests/gen_expected.sh`) is fine.
- [x] Negative tests: malformed programs produce the expected diagnostic text (snapshot). (`tests/errors`.)
- [x] Alias-detection tests (should fail to transpile) and `RefCell` aliasing tests (should fail at run time with the clear message). (`tests/errors/alias_*` and others; at run time, the runtime's `record_used_through_two_references_is_an_error` test.)
- [x] `cargo clippy -- -D warnings` on the transpiler and the runtime; `#![deny(warnings)]` is not applied to generated code, but generated code must build warning-free for every example. (CI and `out/gate.sh`; the run and examples tests build with `-D warnings`.)

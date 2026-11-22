# Free Pascal's units: Objects and Free Vision (plan)

The user, 2026-11-19 to 21: someone who saw the announcement asked whether
Ruscal can run "the old Turbo Vision demo". This note collects what we
found and a plan for a flag that lets programs use Free Pascal's
`Objects` and Free Vision (its Turbo Vision) units. Nothing here is built
yet, and step 1 decides whether the rest is worth doing.

## The question

Turbo Vision is Borland's text-mode windowing library (menus, dialogs,
windows, a desktop), shipped with TP 6 and 7. TP 7's demo is in
`c/TP/EXAMPLES/TVDEMO` (15 files, about 5,200 lines). Programs built on
Turbo Vision were common, so running them fits Ruscal's first use
(running an old Turbo Pascal program on a modern computer).

## What we found (2026-11-19/21, all experiments in `out/`, git-ignored)

- **Borland's source can't be used.** TP 7 has source only for `App`,
  `ColorSel`, `Editors`, `MsgBox`, `Outline`, `StdDlg` and `Validate`
  (`c/TP/SOURCE`; only the file names were looked at). The core units
  (`Objects`, `Drivers`, `Views`, `Menus`, `Dialogs`, `Memory`,
  `HistList`) are compiled `.TPU`s only; their source was Borland's
  separate Runtime Library Source product. `App` alone stops at an
  `assembler` function (8086 code, never supported). And it's Borland's.
- **Free Vision is the only route.** Free Pascal 3.2.2's Free Vision
  (`packages/fv/src`, about 31,000 lines) plus its `Objects` unit
  (`packages/rtl-extra/src/inc/objects.pp`, about 3,000 lines) were
  downloaded from Free Pascal's GitLab into `out/fvsrc` (copied to `out/fv/` in this branch's worktree). Homebrew's
  `fpc` installs only compiled units, not source.
- **First wall: the dialect.** Ruscal stops at `{$ifdef}` (it has no
  conditional compilation or include files). A throwaway script
  (`out/fv/pp.py` in the worktree, not committed: resolves `{$ifdef}`/`{$if}`/`{$define}` for
  Darwin/aarch64, inlines `{$i}`, drops FPC's `inline` modifier) gets
  `tvdemo.pas` through parsing `Objects`, to `Drivers`, which needs
  Free Pascal's `Video` unit (and `Keyboard`, `Mouse`), part of Free
  Pascal's runtime library, not Free Vision.
- **`Objects` alone** (a program that only declares a `TCollection`)
  gives 100 errors:
  1. Free Pascal's dialect, about 40: `Cardinal`, `CodePointer`,
     `PtrUInt`, `SizeInt`, `PByte`, `THandle`, `System.` prefixes.
  2. Raw pointer tricks, about 35: `@` on variables and methods (23),
     `Ofs`, pointer arithmetic, `get_caller_frame`, constructors called
     through code pointers (`CallPointerConstructor`).
  3. Ruscal's own gaps, about 25: a nested procedure calling a virtual
     method of its object, a method hiding one that calls virtual
     methods, `SizeOf` of some expressions.
- **The pointer code is a few repeated patterns**, not arbitrary
  arithmetic (counts over Free Vision + `Objects` + the demo, 44,000
  lines; rough greps):

  | Pattern | Lines | Recognizable? |
  |---|---|---|
  | Stream registration: `TStreamRec` constants with `VmtLink: Ofs(TypeOf(T)^)`, `Load: @T.Load`, `Store: @T.Store`, then `RegisterType` | ~53 | Yes, very regular; user programs write these too (TVDEMO's `PUZZLE.PAS`, `CALC.PAS`, ...) |
  | `ForEach`/`FirstThat`/`LastThat(@LocalProc)`, which FPC runs with `CallPointerLocal` and `get_caller_frame` | ~47 calls, 31 `Call*` helpers, 7 frame reads | Yes: a nested procedure as a callback becomes a closure |
  | Events carrying untyped pointers: `Event.InfoPtr := @Self`, `Message(Owner, ..., @Self)`, integers in `PtrInt(Event.InfoPtr)` | ~65 `@Self`, plus receivers | Hard: the receiver decides the type |
  | Dialog data transfer: `GetData`/`SetData` with `Move` between a control and a record | some of ~78 `Move`s | Partly: depends on layout, which Ruscal knows for typed files |
  | Buffers: `GetMem`/`FreeMem`, `FillChar`, `^[...]` | ~56, ~30, ~142 | Mostly supported already |
  | Real pointer arithmetic: `PtrInt`/`PtrUInt` | ~12 | Few: rewrite case by case |

## Licensing

Summary of the texts, not legal advice.

- `COPYING.FPC` (fetched from `rtl/COPYING.FPC`, 3.2.2) covers Free
  Pascal's runtime library and packages: the LGPL (v2, "Library GNU
  General Public License") with a linking exception. Linking the
  library into a program lets you distribute the program "under terms of
  your choice". A *modified* library stays LGPL, and the modifier chooses
  whether to keep the exception.
- Free Vision's file headers are mixed: some LGPL (`tabs.pas`,
  `colorsel.pas`, `sysmsg.pas`, `timeddlg.pas`), core ones "THIS CODE IS
  FREEWARE ... You may redistribute it and/or modify" (`views.pas`), and
  several say "Interface Copyright (c) 1992 Borland International": Free
  Vision copies Turbo Vision's interface.
- So: a translated Free Vision is a modified version of it, stays under
  its license, and can never go in Ruscal's repository (CLAUDE.md's
  licensing rule). Ruscal's own code, including special cases that
  recognize Free Vision's patterns, is ours (MIT) as long as it holds
  none of their code.

## The idea (the user's)

A flag that turns on compatibility with Free Pascal's units: Ruscal takes
Free Pascal's source, translates it, and writes it to the build
directory with its original license (`COPYING.FPC` and the LGPL), so
programs can use those units. Special cases are fine where needed.

- **Where the source comes from:** the user downloads it and gives its
  path (`--fpc-source DIR`, or an environment variable like
  `RUSCAL_RUNTIME`). Ruscal doesn't download it itself (the user's
  supply-chain concerns). Ruscal checks it's 3.2.2 (special cases are
  tied to one version) and refuses others with a clear message.
- **The output** is a crate (or modules) in `out/`, marked with Free
  Pascal's license, beside the program's own crate. Keeping the linking
  exception means the user's program keeps its own license.
- **Tests:** no Free Pascal code in `tests/`. Each special case gets a
  small program of our own that uses the same pattern (a translate test
  and a run test, as CLAUDE.md asks). A full Free Vision run is an
  optional check that downloads the source in CI.

## What it would take (easiest first)

1. **Getting the source** (above).
2. **The dialect.** `{$ifdef}`/`{$ifndef}`/`{$else}`/`{$endif}`,
   `{$define}`, and include files `{$I name}`: TP 7 has all of these, so
   plain TP programs gain too. Free Pascal's `{$if expr}`, `{$mode}`,
   `inline`, its types (`Cardinal`, `CodePointer`, `PtrUInt`, ...), and
   `System.` names, only in Free Pascal mode.
3. **`Video`, `Keyboard`, `Mouse`.** Written in Rust in
   `ruscal_runtime`, like `Crt` and `Graph`, from Free Pascal's
   documented interface, not translated: their source is Unix system
   calls and terminal handling, and Rust has good crates for that. These
   are ours (MIT).
4. **Pattern special cases:**
   - Stream registration becomes a registry of loader functions (a
     `HashMap<u16, fn(&mut Stream) -> Box<dyn Object>>`, filled by a
     generic `register::<T>()`). The Rust shape was tried in the
     scratchpad (`out/fv/reg.rs`, not committed; compiles and runs).
   - `ForEach(@Local)` and friends become closures.
   - `GetData`/`SetData` through TP's byte layout, if `Move` of records
     isn't enough.
5. **`@Self` and untyped event pointers: the deciding question.**
   - Finding the object: a method gets `&mut self`, which can't be
     stored. Handles (an ID per object, looked up in a table; the user's
     suggestion of a string key works the same, a number is cheaper) or,
     simpler since a Pascal pointer is already a `Ptr<T>`
     (`Rc<RefCell<...>>`), a hidden weak pointer to itself in each heap
     object, set by `New` (`Rc::new_cyclic`), so `@Self` is
     `self.rsc_self.upgrade()`. A stale pointer then fails cleanly.
     Objects not made by `New` (a global `MyApp: TMyApp`, whose `Init`
     does `Application := PApplication(@Self)`) would need to live in a
     `Ptr` too.
   - Re-entrancy, the hard half: while a method runs, its object's
     `RefCell` is borrowed mutably. Turbo Vision calls back into the
     running object all the time (a button's `HandleEvent` sends
     `Message(Owner, ..., @Self)`, the owner reads the sender through
     `InfoPtr`, and the `RefCell` panics). No way of finding the object
     fixes that. Options:
     - methods take the shared pointer and borrow per field access
       (`this.borrow_mut().state = ...`): safe, but changes how every
       method is translated and is noisier;
     - fields in `Cell`/`RefCell` each: the same cost, moved into the types;
     - only for the types that need it (use `@Self`, or reachable from an
       event pointer), today's translation for the rest: fits Ruscal's
       "plain unless needed", but the most complex inside Ruscal.

## Steps

1. **Measure (cheap, `out/` and scratchpad only).** Extend the throwaway
   preprocessor to handle the whole dialect (types, `System.`), rerun on
   the demo, and list what's left by kind. Write a small program of our
   own (a few objects messaging each other with `@Self`, Turbo Vision
   style), translate it by hand both ways (per-field borrows; `Cell`
   fields), and see which Rust is acceptable to read. Report to the user;
   decide whether to go on.
2. **Plan for real.** Update this note with step 1's results; Fable
   checks it before building (CLAUDE.md).
3. **Build in stages, each useful by itself:**
   1. `{$ifdef}` and include files (helps TP programs too).
   2. `--fpc-source` and Free Pascal mode, with `Objects` alone: its
      collections and streams are useful without the rest.
   3. `Drivers` with `Video`/`Keyboard`/`Mouse` in the runtime.
   4. `Views` and the rest of Free Vision; then TVDEMO.
4. Each stage: docs (README, `docs/language_spec.md`,
   `docs/architecture.md`), TODO, a runtime release when the runtime
   changes.

## Open questions for the user

- Is Turbo Vision worth a change to how objects are translated (step 1
  decides how big)?
- `--fpc-source` flag, environment variable, or both?
- A separate LGPL project for anything that has to be a modified Free
  Vision (if special cases inside Ruscal aren't enough)?

# Free Pascal's units: Objects and Free Vision (plan)

The user, 2026-11-19 to 21: someone who saw the announcement asked whether
Ruscal can run "the old Turbo Vision demo". This note collects what we
found and a plan for a flag that lets programs use Free Pascal's
`Objects` and Free Vision (its Turbo Vision) units. Nothing here is built
yet, and step 1 decides whether the rest is worth doing. Fable reviewed
the plan on 2026-11-21; its changes are listed at the end.

In short:

- Turbo Vision needs a different translation of objects, whichever way
  the library is obtained: its objects call back into each other while
  their methods run, and today that is a runtime error at the first
  `Draw`. Step 1 tests that with a small program of our own, before any
  Free Pascal work.
- TP 7's TVDEMO can't run on Free Vision as it is, even with Free Pascal
  itself. Free Vision's own demo is the first target.
- `{$ifdef}`, include files and a few gaps this turned up are worth
  doing whatever is decided.

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
- **Free Vision is the only existing source.** Free Pascal 3.2.2's Free
  Vision (`packages/fv/src`, 31,000 lines) plus its `Objects` unit
  (`packages/rtl-extra/src/inc/objects.pp`, 3,000 lines) were downloaded
  from Free Pascal's GitLab into `out/fv/fvsrc` in this branch's
  worktree. Homebrew's `fpc` installs only compiled units, not source.
- **TP 7's TVDEMO doesn't build on Free Vision, even with Free Pascal**
  (`fpc -Mtp` 3.2.2 on the demo's files, `out/review/fpcdemo`):
  - `HELPFILE.PAS`, part of the demo, has two 8086 `assembler` routines
    (`Scan`, `TextToLine`).
  - The demo uses `ColorSel`. Free Vision's `colorsel.pas` calls itself a
    "(Still unused) skeleton": Free Pascal doesn't build it, and it
    doesn't compile.
  - With those two stubbed, `TVDEMO.PAS` itself has 10 errors
    (`MaxHeapSize`, `cmFind`/`cmReplace`/`cmSearchAgain`,
    `LoadIndexes`/`StoreIndexes`, one in the menu bar's `New`). `Puzzle`,
    `Calc`, `Calendar` and `MouseDlg` compile.

  So "the old Turbo Vision demo" on Free Vision means an edited demo
  (Borland's files, which we can't ship edited), whatever Ruscal does.
  Free Vision has its own demo, `packages/fv/examples/testapp.pas` (462
  lines: menus, dialogs, windows, editor windows), which Free Pascal compiles.
  That is the first target; TVDEMO comes after, with instructions for the
  user's own edits.
- **First wall: the dialect.** Ruscal stops at `{$ifdef}` (it has no
  conditional compilation or include files). A throwaway script
  (`out/fv/pp.py`, not committed: resolves `{$ifdef}`/`{$if}`/`{$define}`
  for Darwin/aarch64, inlines `{$i}`, drops FPC's `inline` modifier) gets
  `tvdemo.pas` through parsing `Objects`, to `Drivers`, which stops at
  `Video.TVideoMode`. `Drivers` needs Free Pascal's `Video`, `Keyboard`
  and `Mouse` units, and, as preprocessed for Darwin, `BaseUnix`, `Unix`
  and `UnixType` (`SysMsg` needs `BaseUnix` and `termio`): Free Pascal's
  runtime library, not Free Vision.
- **Nothing past `Objects` has been through Ruscal.** The units TVDEMO
  uses come to 35,200 lines after preprocessing; `Views` (5,000),
  `Dialogs` (4,500), `Editors` (4,100) and the rest haven't reached the
  parser. The numbers below are a floor.
- **`Objects` alone** (a program that only declares a `TCollection`,
  `out/fv/tvpp/useobj.pas`) gives 100 errors, from sema's first pass only
  (the later checks and codegen never ran):
  1. Free Pascal's dialect, about 45: unknown types and names
     (`Cardinal`, `CodePointer`, `PtrUInt`, `SizeInt`, `PByte`,
     `THandle`, `System.` prefixes).
  2. Raw pointer tricks, about 40: `@` on variables and methods (23),
     `Ofs`, pointer arithmetic, `get_caller_frame`, constructors called
     through code pointers (`CallPointerConstructor`), `absolute`.
  3. Ruscal's own gaps, about 15: a nested procedure calling a virtual
     method of its object (2), a method hiding one that calls virtual
     methods (3: `Load` constructors; in Turbo Vision every `Init` and
     `Load` hides its ancestor's), `SizeOf` of some expressions (8).
- **Gaps the error list doesn't show** (found with small programs of our
  own in `out/review/`):
  - `Fail` in a constructor is an unknown identifier (`failc.pas`). Free
    Vision and `Objects` use it about 50 times.
  - `TEvent` is a variant record with untagged variant parts inside an
    untagged one, one of them laying `InfoPtr: Pointer` over `InfoLong`,
    `InfoWord`, ... (`ev.pas`: "a variant part without a tag field inside
    a variant ... isn't supported yet"). Every `HandleEvent` takes one.
  - `TCollection` keeps its items in `GetMem`'d memory seen through a
    pointer to a huge array (`TItemList`, 4 million pointers). Ruscal's
    rule for that idiom allocates the whole array type (`big.pas`: a
    stack overflow).
  - An object's methods called through a pointer borrow the whole
    object: see "The deciding question".
- **The pointer code is a few repeated patterns**, not arbitrary
  arithmetic (counts over all of Free Vision + `Objects` + the demo,
  44,000 lines; rough greps):

  | Pattern | Count | Recognizable? |
  |---|---|---|
  | Stream registration: `TStreamRec` constants with `VmtLink: Ofs(TypeOf(T)^)`, `Load: @T.Load`, `Store: @T.Store`, then `RegisterType` | 85 constants, 79 `RegisterType` calls | Yes, very regular; user programs write these too (TVDEMO's `PUZZLE.PAS`, `CALC.PAS`, ...) |
  | `ForEach`/`FirstThat`/`LastThat(@LocalProc)`, which FPC runs with `CallPointerLocal` and `get_caller_frame` | 47 calls, 31 `Call*` helpers, 7 frame reads | Yes: a nested procedure as a callback becomes a closure. User programs write the calls too |
  | Back pointers: `Owner^.` (63), `Application^.`/`Desktop^.`/... (73), the `Next` ring | everywhere in `Views` | Not a pattern to recognize: a property of the object model (below) |
  | Events carrying untyped pointers: `Event.InfoPtr := @Self`, `Message(Owner, ..., @Self)`, integers in `PtrInt(Event.InfoPtr)` | 65 `@Self` (37 in `Views`), 58 `InfoPtr` | `@Self` is easy once methods have a pointer to their object (below); the receiver's cast is a checked downcast (`AnyPtr::cast`, error 204) |
  | Dialog data transfer: `GetData`/`SetData` with `Move` between a control and a record | 49 methods, some of 54 `Move` calls | Partly: depends on layout, which Ruscal knows for typed files |
  | Buffers: `GetMem`/`FreeMem`, `FillChar`, `^[...]` | 56, 30, 142 | Mostly supported already, except the huge-array idiom above |
  | Real pointer arithmetic: `PtrInt`/`PtrUInt` | 12 | Few: rewrite case by case |

## The deciding question: objects that call back into each other

The first plan called `@Self` and untyped event pointers the deciding
question. `@Self` is the easy half. The hard half, which the first plan
described for events, is much wider than events, and it doesn't need
`@Self` or Free Pascal to show up.

**What Ruscal does today** (docs/architecture.md §12 and §16): a method
takes `&mut self`, and a call through a pointer, `P^.Draw`, is
`p.get_mut().draw()`: the object's `RefCell` stays mutably borrowed
until `Draw` returns. Most of what Turbo Vision needs is there: virtual
methods through pointers, descendants in other units (checked:
`out/review/xu`), `Owner`/`Next` links as `Ptr`s, `TypeOf`, an untyped
`Pointer` holding a typed one. But any use of an object whose method is
still running, through any pointer, is runtime error 204.

**Turbo Vision is built on exactly that.** A group's `Draw` calls each
subview's `Draw`, which reads `Owner^.Size` and `Owner^.Clip` and writes
into the owner's buffer. A group's `HandleEvent` passes the event to a
subview, whose `HandleEvent` calls `Owner^.SelectNext` or
`Message(Owner, evBroadcast, ...)`, which runs the owner's `HandleEvent`
again, which calls every subview, the sender included.
`Application^.Run` is running for the whole program, and every menu
command calls `Desktop^.Insert` or `Application^.ExecuteDialog` beneath
it. `TObject.Free` disposes the object whose method it is.

Checked with 80 lines of plain TP (`out/review/owner.pas`: a group, a
view, a button whose `Draw` reads `Owner^.Offset`; no `@Self`, no Free
Pascal): Ruscal translates it, and it stops at the first button with
runtime error 204 ("a heap record is used through two references at
once").

So this decides everything, and it's independent of where the library
comes from: a hand-written Rust Turbo Vision would call the user's
`HandleEvent`, which calls `Owner^.` and `Desktop^.` in the same way.

**What would fix it: a method that holds a pointer, not a borrow.** For
the hierarchies that need it, a method gets its object as the shared
pointer and borrows for one field access at a time. The user's handle
suggestion comes to the same thing (the method holds a key, and looks
the object up each time it touches it); since a Pascal pointer is
already a `Ptr` (`Rc<RefCell<...>>`), the pointer can be the handle, with
no table. A sketch, not yet compiled:

```rust
// procedure TButton.Draw; begin WriteLn('button ', X + Owner^.Offset) end;
fn t_button_draw(this: &PView) {
    let owner = this.get().as_t_view().owner.clone();
    pwriteln!("button ", this.get().as_t_view().x + owner.get().as_t_group().offset);
}
```

- Inside such a method, a field is translated as `Self^.Field` would be
  for a pointer `Self`. Ruscal already has those rules (§12: borrow per
  statement, hoist a dereference into a `let` before a call), so this
  reuses the pointer translation; that's why it's the first to try.
- A virtual call reads which object it is (the enum's variant), lets go
  of the borrow, then calls that object's version with the pointer.
- `@Self` is `this.clone()`. No weak self-pointer and no ID table.
- An object in a plain variable (`var MyApp: TMyApp`, a local
  `TBufStream`) lives in a `Ptr` allocated where it's declared.
- It would also close Ruscal's two object gaps (a static method hidden
  by a descendant, a nested procedure calling a virtual method): both
  exist because `&mut self` of the ancestor part can't get back to the
  whole object, and a pointer can.
- What it costs: methods read worse (`this.get_mut().t_view().size.x =
  3` for `Size.X := 3`), which matters for use 2; a second way of
  translating methods to maintain; a borrow and a `match` per field
  access.
- Which hierarchies: one where some method uses `@Self` is the natural
  rule (that's how an object hands out a pointer to itself; `Owner` is
  set from `@Self` in `TGroup.Insert`). With Turbo Vision that's
  everything descended from `TObject`, since `TObject.Free` uses it;
  other programs keep today's translation.
- What's still open: a `var` argument that is a field of a heap object
  (`GetExtent(Bounds)`, `S.Read(Field, ...)`) keeps the object borrowed
  for the call (§15's known hazard). In this mode it may have to be
  copied in and out. `with P^ do` blocks. And how big one enum of some
  90 object types with about 500 `virtual` declarations gets (today's
  translation of `owner.pas` is 300 lines of Rust for 3 types).

The other two options from the first plan stay as fallbacks: each field
in a `Cell`/`RefCell` (methods take `&self`; but a field can't be passed
as `&mut`, and `Size.X := 3` needs a read, a change and a write back, so
every use of a field needs new rules rather than the pointer ones), and
a weak self-pointer set by `New` (`Rc::new_cyclic`; it finds the object
but doesn't fix the borrow).

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
  FREEWARE ... You may redistribute it and/or modify" (`views.pas`,
  `dialogs.pas`, `app.pas`, `drivers.pas`, `menus.pas`), and those also
  say "Interface Copyright (c) 1992 Borland International": Free Vision
  copies Turbo Vision's interface.
- So: a translated Free Vision is a modified version of it, stays under
  its license, and can never go in Ruscal's repository (CLAUDE.md's
  licensing rule). Ruscal's own code, including special cases that
  recognize Free Vision's patterns, is ours (MIT) as long as it holds
  none of their code.
- The translated units can't be a crate of their own: a hierarchy's enum
  lists every object in it, the program's included (the unit's module
  gets `Circle(crate::TCircle)`, `out/review/xu`), so they're modules of
  the program's crate, translated again for each program. Each generated
  file carries its license. A user who goes on working on the Rust (use
  2) has a crate that is partly a modified Free Vision.
- A Turbo Vision written by us from Borland's documented interface would
  be in the same position as our `Crt`, `Dos` and `Graph`.

## Three ways to get the library

Whichever is chosen, the object model above comes first.

1. **Translate Free Pascal's source (the user's idea).** A flag turns on
   compatibility with Free Pascal's units: Ruscal takes Free Pascal's
   source, translates it, and writes it to the build directory with its
   original license (`COPYING.FPC` and the LGPL), so programs can use
   those units. Special cases are fine where needed.
   - **Where the source comes from:** the user downloads it and gives its
     path (`--fpc-source DIR`, or an environment variable like
     `RUSCAL_RUNTIME`). Ruscal doesn't download it itself (the user's
     supply-chain concerns). Ruscal checks it's 3.2.2 (special cases are
     tied to one version) by the files' SHA-256 hashes, which aren't
     their code, and refuses others with a clear message.
   - **The output** is modules in the program's project in `out/`, marked
     with Free Pascal's license (see Licensing).
   - **Tests:** no Free Pascal code in `tests/`. Each special case gets a
     small program of our own that uses the same pattern (a translate
     test and a run test, as CLAUDE.md asks). A full Free Vision run is
     an optional check that downloads the source in CI.
   - For: 31,000 lines we don't write, and Free Vision's behaviour is the
     one people know. Against: the dialect, a dozen special cases tied to
     one version, nothing testable in the repository, and a build that
     only works after a download.
2. **Write Turbo Vision by hand in Rust, in `ruscal_runtime`** (as `Crt`
   and `Graph` are). No dialect, no license question, tests in the
   repository. But:
   - A user's object descends from `TView` and overrides its virtual
     methods, reads its fields (`Size`, `Owner`, `State`), and calls
     `inherited`. So the runtime's objects would have to have exactly
     the shape Ruscal generates (struct, methods trait, accessors), and
     the hierarchy's enum, which lists the program's own objects, can't
     live in the runtime: pointers into such a hierarchy would need a
     second representation (`dyn` with downcasts) or generics all through
     the library. That's new machinery for use 3 that nothing else needs.
   - The simpler form of the same idea is to write it by hand in
     *Pascal*, as a unit that Ruscal translates with the program:
     descendants in the program already work that way.
   - Either way it's a clean-room library the size of Free Vision, whose
     programs depend on its details (palettes, draw buffers, stream
     formats, resource files). Months, not days. Not recommended for
     Turbo Vision as a whole.
3. **A mix.** Write the small, documented, widely used bottom layer
   ourselves, and translate the rest:
   - `Objects` (`TObject`, `TCollection` and its descendants, the
     streams, `TRect`, `TPoint`, `NewStr`): our own unit, in Pascal that
     Ruscal already supports, from TP 7's documented interface. Programs
     used collections and streams without Turbo Vision, it could be
     committed and tested like `RscJson`, and it avoids most of the 100
     errors above (they're Free Pascal's implementation tricks, not the
     interface). Free Vision's units would then use ours, which must
     also offer the few extras they expect (`Sw_Integer`, ...).
   - `Drivers` (events, keyboard, mouse, screen, `MoveBuf`/`MoveStr`,
     `FormatStr`; no objects): in Rust in the runtime, with `TEvent` as a
     type of the runtime's. That replaces `Video`, `Keyboard`, `Mouse`,
     `BaseUnix`, `Unix` and `SysMsg` in one go, and the `TEvent` gap.
   - `Views`, `Menus`, `Dialogs`, `App`, `Editors`, `StdDlg`, ...:
     translated from Free Pascal's source, by the user's flag.

Before choosing, look for an existing Rust Turbo Vision crate (and the
C++ ports): unlikely to fit, since Pascal objects must descend from its
views, but ten minutes settles it.

## What it would take (easiest first)

1. **Useful whatever is decided:** `{$ifdef}`/`{$ifndef}`/`{$else}`/
   `{$endif}`, `{$define}`, and include files `{$I name}` (TP 7 has all
   of these); `Fail`; nested untagged variant parts; a `GetMem`'d part
   of a huge array.
2. **The object model** (above).
3. **Getting the source**, for routes 1 and 3.
4. **Free Pascal's dialect**, only in Free Pascal mode: `{$if expr}`,
   `{$mode}`, `inline`, its types (`Cardinal`, `CodePointer`, `PtrUInt`,
   ...), `System.` and other unit-qualified names (`Video.TVideoMode`).
5. **The screen.** Route 1: `Video`, `Keyboard`, `Mouse` written in Rust
   in `ruscal_runtime`, like `Crt` and `Graph`, from Free Pascal's
   documented interface, not translated (their source is Unix system
   calls and terminal handling, and Rust has good crates for that), plus
   whatever `Drivers` and `SysMsg` take from `BaseUnix`. Route 3:
   `Drivers` itself. Ours (MIT) either way.
6. **Pattern special cases:**
   - Stream registration becomes a registry of loader functions, filled
     by a generic `register::<T>()`. The Rust shape was tried in the
     scratchpad (`out/fv/reg.rs`, not committed; compiles and runs) with
     `Box<dyn Object>`; in Ruscal the loader returns the hierarchy's
     pointer (`fn(&mut Stream) -> PObject`).
   - `ForEach(@Local)` and friends become closures (or lifted functions
     with their captures, as nested procedures are today).
   - `GetData`/`SetData` through TP's byte layout, if `Move` of records
     isn't enough.
   - `TCollection`'s item list, if the huge-array rule doesn't cover it.

## Steps

1. **Decide (cheap, `out/` only, nothing committed but this note).**
   1. *The object model (a day at most; no Free Pascal needed).* Write
      `minitv.pas`, about 200 lines of plain TP of our own, in Turbo
      Vision's style: a group with a ring of subviews (`Owner`, `Next`,
      `Insert` setting `Owner := @Self`); `Draw` reading the owner and
      writing its buffer; `HandleEvent` passing an event down, a subview
      answering with `Message(Owner, ..., @Self)` that runs the owner's
      `HandleEvent` again and reaches the sender; a view that removes
      and frees itself in its own method; a modal `Execute` loop inside
      a method; a `var` argument that is a field; `ForEach` with a
      nested procedure; a descendant in the program overriding a virtual
      method and calling `inherited`; an object in a global variable.
      Its expected output comes from `fpc -Mtp`. Translate it to Rust by
      hand with pointer methods (and one object with `Cell` fields, to
      compare).
      **Go** if the Rust compiles without warnings or `unsafe`, prints
      what Free Pascal prints, each construct follows a rule that can be
      written down, and the user finds the Rust acceptable to read.
      **No-go** otherwise: Turbo Vision stops there, by any route; what's
      left is item 1 of "What it would take" and perhaps `Objects`.
   2. *The size (only after a go).* Extend the throwaway preprocessor to
      the whole dialect, stub `Video`/`Keyboard`/`Mouse`, and get every
      unit `testapp.pas` uses through the parser and sema; list what's
      left by kind, with counts, and which special case covers each.
      Generate a Pascal program with 90 objects and 500 virtual methods
      and see how long its Rust is and how long it takes to build.
   3. *Report to the user*, with a route (1, 2 or 3) and a rough size
      for each stage.
2. **Plan for real.** Update this note with step 1's results; Fable
   checks it before building (CLAUDE.md).
3. **Build in stages, each useful by itself:**
   1. `{$ifdef}` and include files, `Fail`, the other small gaps (help
      TP programs too).
   2. Pointer methods for hierarchies that use `@Self`, with tests of
      our own (`minitv.pas` becomes a run test).
   3. `Objects` alone (ours, or Free Pascal's through `--fpc-source`):
      collections and streams are useful without the rest.
   4. `Drivers`, or `Video`/`Keyboard`/`Mouse`, in the runtime.
   5. `Views` and the rest of Free Vision; `testapp.pas`; then TVDEMO,
      with the edits it needs written up for the user.
4. Each stage: docs (README, `docs/language_spec.md`,
   `docs/architecture.md`), TODO, a runtime release when the runtime
   changes.

## Open questions for the user

- Is Turbo Vision worth a second way of translating objects' methods
  (step 1.1 shows what it looks like)? It would be used only by programs
  whose objects use `@Self`.
- Is Free Vision's own demo enough as the goal, with TVDEMO needing the
  user's edits (its help unit's assembler, `ColorSel`, 10 errors)?
- `Objects` and `Drivers`: ours (route 3) or Free Pascal's (route 1)?
- `--fpc-source` flag, environment variable, or both?
- A separate LGPL project for anything that has to be a modified Free
  Vision (if special cases inside Ruscal aren't enough)?

## Fable's changes (2026-11-21)

Checked against the sources in `out/fv/`, Ruscal's code and docs, and
small programs in `out/review/` (not committed).

- **The deciding question is wider than `@Self`.** The first plan put the
  re-entrancy problem under events and `InfoPtr`, and suggested limiting
  the change to types "reachable from an event pointer". It's every
  `Owner^.`, `Desktop^.` and `Application^.` during a `Draw` or a
  `HandleEvent`: plain TP with no `@Self` fails today (`owner.pas`). It
  now has its own section, placed before the routes because it doesn't
  depend on them.
- **The handle idea is kept, in its cheapest form.** The user's handle
  (a key looked up at each use) is what fixes the borrow, not only what
  finds the object; the note says so, and uses the `Ptr` the object
  already lives in as the handle. The weak self-pointer I'd call a
  fallback: it finds the object and leaves the borrow.
- **Pointer methods first, `Cell` fields second**, because the first
  reuses the rules Ruscal has for `P^.Field`. Also noted: it would close
  the two object gaps in `docs/language_spec.md`.
- **TVDEMO can't be the first target.** Free Pascal itself can't build
  TP 7's TVDEMO on Free Vision (assembler in `HELPFILE.PAS`, no working
  `ColorSel`, 10 errors in `TVDEMO.PAS`). Free Vision's `testapp.pas`
  is, and the open questions ask whether that's enough.
- **Numbers corrected:** 85 `TStreamRec` constants and 79 `RegisterType`
  calls (was "~53 lines"); 54 `Move` calls (was ~78); the error split is
  about 45/40/15 (was 40/35/25); the units TVDEMO uses are 35,200 lines,
  none past `Objects` parsed. The others match.
- **Gaps added:** `Fail`, `TEvent`'s nested untagged variants, the
  huge-array `GetMem` idiom behind `TCollection`, `Drivers`' and
  `SysMsg`'s Unix units, unit-qualified type names.
- **The output can't be a separate crate** (a hierarchy's enum names the
  program's objects), so "a crate (or modules)" became modules of the
  program's crate; the registry sketch's `Box<dyn Object>` became the
  hierarchy's pointer; the version check is by file hashes.
- **Routes compared.** The user's flag is kept as route 1. A hand-written
  Rust Turbo Vision (route 2) doesn't avoid the object-model change and
  needs more machinery for descendants, so it isn't recommended; writing
  only `Objects` (in Pascal) and `Drivers` (in Rust) ourselves is offered
  as route 3.
- **Step 1 is split** into a go/no-go on the object model, with a named
  test program and stated criteria, and a sizing step that only runs
  after a go. The stages gained the object model, and put the gaps that
  help plain TP programs first.

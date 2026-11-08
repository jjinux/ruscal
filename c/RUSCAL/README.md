# Turbo Pascal 7 checks

Small programs that settle what Turbo Pascal 7 really did, where Free
Pascal (`fpc -Mtp`) differs or the docs don't say. They're Ruscal's own
(MIT), written to ask TP a question; the answers are recorded in
`TODO.md`, and the ones that changed Ruscal became tests in `tests/run`.

DOSBox's C: drive is the repo's `c/`; TP itself goes in `c/TP` (see
`CLAUDE.md`, Licensing), which git ignores. To run them all:

```sh
/Applications/dosbox.app/Contents/MacOS/DOSBox \
  -c "mount c $PWD/c" -c "c:" -c "cd \ruscal" -c "runall" -c "exit"
```

`RUNALL.BAT` compiles and runs each `NAME.PAS`: `NAME.CMP` is TPC's
output, `NAME.OUT` the program's, and `DONE.TXT` appears at the end.
DOS wants 8.3 names and CRLF line endings, and nothing may wait for a
key. A new program needs its two lines in `RUNALL.BAT`.

Format a program with `ruscal fmt`, then put back the CRLF line endings
it turns into UNIX ones:

```sh
ruscal fmt c/RUSCAL/NAME.PAS && perl -pi -e 's/\r?\n/\r\n/' c/RUSCAL/NAME.PAS
```

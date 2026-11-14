# Ruscal

A Turbo Pascal to Rust transpiler, so you can run your old Turbo Pascal
programs on a modern computer: it turns a program (and its units) into a
small Cargo project, with `Crt`, `Dos` and `Graph` provided by its runtime,
[`ruscal_runtime`](https://crates.io/crates/ruscal_runtime).

```sh
cargo install ruscal
ruscal run life.pas        # translate, build and run
ruscal emit life.pas       # print the generated Rust
```

A Rust program can use a Turbo Pascal unit too: `ruscal` as a build
dependency (with `default-features = false`) translates it in `build.rs`.

The documentation, the examples and the source are on GitHub:
<https://github.com/jjinux/ruscal>.

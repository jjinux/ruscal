//! Translate the Pascal unit into Rust as part of `cargo build`.

fn main() {
    ruscal::build::library("pascal/bstunit.pas").unwrap();
}

#!/bin/sh
# Install `ruscal` as crates.io would give it, and check the projects it
# writes get the runtime from crates.io, at its own version, not by path.
# The runtime isn't fetched from crates.io: a `[patch.crates-io]` puts the
# packaged one in its place. Run by CI; it packages the workspace itself
# (see docs/releasing.md).
#
# Usage: tests/packaged_install.sh   (from anywhere)
set -eu
cd "$(dirname "$0")/.."
version=$(cargo pkgid -p ruscal | sed 's/.*[#@]//')
cargo package --workspace --allow-dirty --quiet
packages=${CARGO_TARGET_DIR:-target}/package
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
# Laid out as `cargo vendor` does, the runtime as `ruscal_runtime/` beside
# `ruscal/`, so `build.rs` must tell a published crate from a checkout by
# its `Cargo.toml.orig`, not by the missing sibling.
cp -R "$packages/ruscal-$version" "$scratch/ruscal"
cp -R "$packages/ruscal_runtime-$version" "$scratch/ruscal_runtime"
mkdir "$scratch/.cargo" "$scratch/prog"
cat > "$scratch/.cargo/config.toml" <<CONFIG
[patch.crates-io]
ruscal_runtime = { path = "$scratch/ruscal_runtime" }
CONFIG
cd "$scratch"
cargo install --quiet --root "$scratch/bin" --path ruscal
cd prog
printf "program Greet;\nuses Crt;\nbegin\n   WriteLn('hi');\nend.\n" > greet.pas
output=$("$scratch/bin/bin/ruscal" run greet.pas)
[ "$output" = hi ] || { echo "ruscal run printed: $output" >&2; exit 1; }
grep -q "^ruscal_runtime = { version = \"=$version\", features = \[\"crt\"\] }$" out/greet/Cargo.toml || {
    echo "the generated Cargo.toml doesn't take the runtime from crates.io:" >&2
    cat out/greet/Cargo.toml >&2
    exit 1
}
if grep -q "path =" out/greet/Cargo.toml; then
    echo "the generated Cargo.toml takes something by path" >&2
    exit 1
fi
echo "packaged ruscal $version writes ruscal_runtime = \"=$version\": ok"

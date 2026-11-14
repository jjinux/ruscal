//! Every error that links to `docs/rust_limits.md` links to a section that
//! exists there, so the advice it promises is really on the page; and the
//! version numbers in the docs are Ruscal's own, so a release can't leave
//! them behind (docs/releasing.md).

use std::path::Path;

#[test]
fn rewrite_links_have_sections() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR"));
    let page = std::fs::read_to_string(root.join("../../docs/rust_limits.md")).unwrap();
    let mut anchors = Vec::new();
    for dir in ["src/sema", "src/codegen", "src"] {
        for entry in std::fs::read_dir(root.join(dir)).unwrap().flatten() {
            let Ok(source) = std::fs::read_to_string(entry.path()) else { continue };
            // `rewrite_link("two-var-arguments")`, ignoring its definition.
            for piece in source.split("rewrite_link(\"").skip(1) {
                anchors.push(piece.split('"').next().unwrap().to_string());
            }
        }
    }
    assert!(!anchors.is_empty(), "no rewrite_link calls found");
    for anchor in anchors {
        assert!(page.contains(&format!("<a id=\"{anchor}\"></a>")), "docs/rust_limits.md has no section `{anchor}`");
    }
}

/// Every `=X.Y.Z` in the docs that tell a Rust program which Ruscal to
/// depend on is this version (`CARGO_PKG_VERSION`, the workspace's), and so
/// is `ruscal`'s own dependency on the runtime.
#[test]
fn docs_name_this_version() {
    let root = Path::new(env!("CARGO_MANIFEST_DIR")).join("../..");
    let version = env!("CARGO_PKG_VERSION");
    let files =
        ["README.md", "docs/embedding.md", "examples/ruscal/rust_calls_pascal/Cargo.toml", "crates/ruscal/Cargo.toml"];
    for file in files {
        let text = std::fs::read_to_string(root.join(file)).unwrap();
        let pinned: Vec<&str> = text.split("\"=").skip(1).map(|rest| rest.split('"').next().unwrap()).collect();
        assert!(!pinned.is_empty(), "{file} names no `=X.Y.Z` version");
        for found in pinned {
            assert_eq!(found, version, "{file} says ={found}; Ruscal is {version} (see docs/releasing.md)");
        }
    }
    let readme = std::fs::read_to_string(root.join("README.md")).unwrap();
    let short = version.rsplit_once('.').unwrap().0;
    assert!(readme.contains(&format!("Ruscal is version {short}:")), "README's status doesn't say version {short}");
}

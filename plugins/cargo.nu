# description: cargo shortcuts, plus dependency and installed-binary tables
# requires: cargo

export alias cb = cargo build
export alias cbr = cargo build --release
export alias cr = cargo run
export alias crr = cargo run --release
export alias cex = cargo run --example
export alias ct = cargo test
export alias cch = cargo check --all-targets
export alias ccl = cargo clippy --all-targets
export alias cf = cargo fmt
export alias cfc = cargo fmt --check
export alias cdo = cargo doc --open
export alias cbe = cargo bench
export alias ca = cargo add
export alias crm = cargo remove
export alias cu = cargo update
export alias cn = cargo new
export alias ci = cargo install --path .
export alias cin = cargo install

# Dependencies of the current workspace as a table
export def cdeps [] {
    ^cargo metadata --format-version 1
    | from json
    | get packages
    | where source != null
    | select name version
    | sort-by name
}

# Binaries installed with `cargo install`
export def cbins [] {
    ^cargo install --list
    | lines
    | parse --regex '^(?<crate>\S+) v(?<version>[^\s:]+)(?: \((?<source>.+)\))?:$'
}

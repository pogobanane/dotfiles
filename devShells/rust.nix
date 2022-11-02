{pkgs, fenixPkgs, toolchain ? fenixPkgs.stable, ...}:
let
  rustToolchain = with fenixPkgs; combine [
    toolchain.cargo
    toolchain.rustc
    toolchain.rust-src
    toolchain.rust-std
    toolchain.clippy
    toolchain.rustfmt
    #targets.x86_64-unknown-linux-musl.stable.rust-std
    # fenix.packages.x86_64-linux.targets.aarch64-unknown-linux-gnu.latest.rust-std
  ];

  rustPlatform = (pkgs.makeRustPlatform {
    cargo = rustToolchain;
    rustc = rustToolchain;
  });
in
pkgs.mkShell {
  RUST_SRC_PATH = "${rustToolchain}/lib/rustlib/src/rust/library";
  buildInputs = with pkgs; [
    rustToolchain
    fenixPkgs.rust-analyzer
  ];
}

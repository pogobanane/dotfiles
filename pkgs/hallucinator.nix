{
  hallucinator-src,
  lib,
  rustPlatform,
  pkg-config,
  fontconfig,
}:

rustPlatform.buildRustPackage {
  pname = "hallucinator";
  version = "0.2.1";

  src = hallucinator-src;
  sourceRoot = "source/hallucinator-rs";

  # no vendor hash to maintain: crate hashes come from the lock file
  cargoLock.lockFile = "${hallucinator-src}/hallucinator-rs/Cargo.lock";

  nativeBuildInputs = [
    rustPlatform.bindgenHook # mupdf-sys generates bindings from vendored mupdf
    pkg-config
  ];

  buildInputs = [
    fontconfig # yeslogic-fontconfig-sys links the system library
  ];

  # tests query online academic databases (CrossRef, arXiv, DBLP, ...)
  doCheck = false;

  meta = with lib; {
    description = "Detect hallucinated references in academic papers";
    homepage = "https://github.com/gianlucasb/hallucinator";
    license = licenses.agpl3Plus;
    mainProgram = "hallucinator-tui";
    platforms = platforms.unix;
  };
}

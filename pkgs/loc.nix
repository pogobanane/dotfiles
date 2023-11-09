{ loc-src, lib, rustPlatform }:

with rustPlatform;

buildRustPackage rec {
  version = "0.4.1";
  pname = "loc";

  src = loc-src;

  cargoSha256 = "sha256-9JXOEBEgHjom1VPPKLjsumlxLwBDq090EvPMFePVzB4=";

  meta = with lib; {
    homepage = "https://github.com/cgag/loc";
    description = "Count lines of code quickly";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    platforms = platforms.unix;
  };
}


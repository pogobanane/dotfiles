{pkgs, ...}:
pkgs.rustPlatform.buildRustPackage {
    pname = "bender";
    version = "v0.28.2";

    src = pkgs.fetchFromGitHub {
      owner = "pulp-platform";
      repo = "bender";
      rev = "v0.28.2"; # tag or commit hash
      sha256 = "sha256-OJWYhs5QmfUC1I5OkEJAeLTpklEQyQ6024wmhv1sSnA=";
    };

    cargoHash = "sha256-Y9naWhhGgGMC8aCgCvvBMOtxci2NMfKMB2ETz7PDfSc=";

}

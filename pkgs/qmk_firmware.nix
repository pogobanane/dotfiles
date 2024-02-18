{pkgs ? <nixpkgs>} :

pkgs.stdenv.mkDerivation {
  name = "qmk_firmware";
  src = pkgs.fetchgit {
    url = "https://github.com/pogobanane/qmk_firmware.git";
    fetchSubmodules = true;
    rev = "9b85de87aa81931606d5a758863c8a2f9af092c1"; # branch k3_dev 18.02.2024
    sha256 = "sha256-lMBalwDTkSGrlYRsNbHxuKBp37TXiPt0GZNtrOz/Ia4=";
  };

  buildInputs = with pkgs; [
    qmk
    (writeShellScriptBin "git" ''
      echo called git $@
    '')
  ];

  buildPhase = ''
    qmk compile --keyboard keychron/k3/rgb/optical_ansi --keymap via
  '';

  installPhase = ''
    mkdir -p $out
    install ./keychron_k3_rgb_optical_ansi_via.bin $out/
  '';

  meta = with pkgs.lib; {
    description = "A QMK keyboard firmware fork for Keychron K3";
    homepage = "https://github.com/pogobanane/qmk_firmware";
    license = licenses.gpl3;
    maintainers = with maintainers; [ pogobanane ];
    platforms = platforms.unix;
  };
}


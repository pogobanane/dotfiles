
{pkgs ? <nixpkgs>} :

pkgs.stdenv.mkDerivation {
  name = "sonixflasherc";
  src = pkgs.fetchFromGitHub {
    owner = "SonixQMK";
    repo = "SonixFlasherC";
    rev = "548174b98e1c5d69a524829f79db5ca1b002fa99"; # main 20.02.2024
    sha256 = "sha256-XikZ086kCAEzuA9jnfW8OhC+hcT6/HBVavQuCLEw50w=";
  };
  buildInputs = with pkgs; [
    hidapi
    pkg-config
    # usbutils
  ];

  installPhase = ''
    mkdir -p $out/bin
    install ./sonixflasher $out/bin/sonixflasherc
  '';

  meta = with pkgs.lib; {
    description = "A CLI-based Flasher for Sonix 24x/26x MCUs (keyboards).";
    homepage = "https://github.com/SonixQMK/SonixFlasherC";
    license = licenses.gpl3;
    maintainers = with maintainers; [ pogobanane ];
    platforms = platforms.unix;
  };
}


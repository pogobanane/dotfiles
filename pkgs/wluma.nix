{ pkgs, rustPlatform }: 
#rustPlatform.buildRustPackage rec {
#  pname = "wluma";
#  version = "4.2.0";
#
#  src = fetchFromGitHub {
#    owner = "maximbaz";
#    repo = pname;
#    rev = version;
#    sha256 = "";
#  };
#
#  cargoSha256 = "";
#
#  meta = with lib; {
#    description = "Automatic brightness adjustment based on screen contents and ALS";
#    homepage = "https://github.com/BurntSushi/ripgrep";
#    license = licenses.unlicense;
#    maintainers = [ maintainers.tailhook ];
#  };
#}
(pkgs.wluma.overrideAttrs (_finalAttrs: _previousAttrs: {
  #src = ../wluma-git;
  #unpackPhase = ''
    #cp -r ${finalAttrs.src} $sourceRoot/
  #'';
  #dontUnpack = true;
  #src = ../wluma-git;
  #cargoSha256 = "";
}))

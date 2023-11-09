{ pkgs, ... }: let 
  node2nix = import ./apple-music { inherit pkgs; };
in node2nix.package
# stdenv.mkDerivation rec {
#   pname = "apple-music";
#   version = "0.7.0";
#   src = fetchFromGitHub {
#       owner = "cross-platform";
#       repo = "apple-music-for-linux";
#       rev = "${version}";
#       sha256 = "sha256-K2PbTIteg5Ae2xTyHHgdGyljl32d6H21aiGR5nmd+Us=";
#   };
#
#   buildPhase = ''
#     npm install
#     npm run build
#   '';
#
#   meta = with lib; {
#     description = "Apple Music for Linux (electron)";
#     homepage = "https://github.com/cross-platform/apple-music-for-linux";
#   };
# }

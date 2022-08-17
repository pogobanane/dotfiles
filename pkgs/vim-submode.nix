{ pkgs }:
pkgs.vimUtils.buildVimPlugin {
  name = "vim-submode";
  src = pkgs.fetchFromGitHub {
    owner = "thinca";
    repo = "vim-submode";
    rev = "be74a7aabe44492432a86f4c954ba3b14a757b10";
    sha256 = "sha256-/S7/og501eyk/xn1eR/WEGtROo5/wz/kZteObDhzXL8=";
  };
}

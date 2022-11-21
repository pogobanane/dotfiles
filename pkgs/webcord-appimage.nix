{ lib, appimageTools, fetchurl }:
appimageTools.wrapType2 {
  name = "webcord";
  src = fetchurl {
    url = "https://github.com/SpacingBat3/WebCord/releases/download/v3.9.3/WebCord-3.9.3-x64.AppImage";
    sha256 = "sha256-CwA5DMECQS3se+xf3wbbS8wLN1ABgrIDan65TocLt4A=";
  };
  extraPkgs = pkgs: with pkgs; [ ];

  meta = with lib; {
    description = "A new look into listening and enjoying Apple Music in style and performance.";
    homepage = "https://github.com/ciderapp/Cider";
    license = licenses.agpl3;
    maintainers = [ maintainers.cigrainger ];
    platforms = [ "x86_64-linux" ];
  };
}

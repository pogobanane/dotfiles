{ lib, appimageTools, fetchurl, makeWrapper }:
appimageTools.wrapType2 rec {
  pname = "webcord";
  version = "3.9.3";

  src = fetchurl {
    url = "https://github.com/SpacingBat3/WebCord/releases/download/v3.9.3/WebCord-3.9.3-x64.AppImage";
    sha256 = "sha256-CwA5DMECQS3se+xf3wbbS8wLN1ABgrIDan65TocLt4A=";
  };
  extraPkgs = pkgs: with pkgs; [ makeWrapper ];
  #nativeBuildInputs = [ makeWrapper ];

  extraInstallCommands =
    let contents = appimageTools.extract { inherit pname version src; };
    #wrapped = writeScript "${pname}" ''
        #exec $out/bin/${pname}-${version} $\{NIXOS_OZONE_WL:+$\{WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}} $@
    #'';
    in ''
      #cp $\{wrapped} $out/bin/${pname}
      mv $out/bin/${pname}-${version} $out/bin/${pname}
      #wrapProgram $out/bin/${pname} \
      #makeWrapper $out/bin/${pname}-${version} $out/bin/${pname}
        #--add-flags $\{NIXOS_OZONE_WL:+$\{WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}

      install -m 444 -D ${contents}/WebCord.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/WebCord.desktop \
        --replace 'Exec=webcord' 'Exec=${pname} --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations'
      substituteInPlace $out/share/applications/WebCord.desktop \
        --replace 'Icon=webcord' "Icon=$out/share/icons/hicolor/512x512/webcord.png"
      cp -r ${contents}/usr/share/icons $out/share
    '';

  meta = with lib; {
    description = "A Discord and Fosscord client made with the Electron API.";
    homepage = "A Discord and Fosscord client made with the Electron API.";
    license = licenses.mit;
    maintainers = [ maintainers.pogobanane ];
    platforms = [ "x86_64-linux" ];
  };
}

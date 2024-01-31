{ pkgs, lib, wondershaper-src }: pkgs.stdenv.mkDerivation {
  name = "wondershaper";

  src = wondershaper-src;

  installPhase = ''
    mkdir -p $out/bin
    install ./wondershaper $out/bin/wondershaper
  '';

  meta = with lib; {
    homepage = "https://github.com/magnific0/wondershaper";
    description = "Command-line utility for limiting an adapter's bandwidth";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ pogobanane ];
    platforms = platforms.unix;
  };
}

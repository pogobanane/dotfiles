{...}: {
  # printing:
  services.printing.enable = true;
  services.printing.drivers = [
    pkgs.gutenprint # often replaces hplip

    # TUM-FMI Xerox "followme" PPD (CIT/ITO guide): https://my.ito.cit.tum.de/printing/
    # https://wiki.ito.cit.tum.de/bin/view/CIT/ITO/Docs/Guides/XeroxDrucker/
    (pkgs.runCommand "xerox-c8030-ppd" { } ''
      install -Dm644 ${pkgs.fetchurl {
        url = "https://wiki.ito.cit.tum.de/bin/download/CIT/ITO/Docs/Guides/XeroxDrucker/WebHome/x2UNIV-C8030.ppd?rev=1.2";
        hash = "sha256-If8PWiGxn7r9MIG/hJzTjmcBBwRApuseN7FT7+Eybl0=";
      }} $out/share/cups/model/x2UNIV-C8030.ppd
    '')
  ];
  hardware.printers.ensurePrinters = [{
    name = "followme";
    location = "TUM-FMI";
    description = "Xerox-Followme";
    deviceUri = "ipps://print.in.tum.de/printers/followme";
    model = "x2UNIV-C8030.ppd";
  }];
}

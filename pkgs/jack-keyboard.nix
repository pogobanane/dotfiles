{pkgs ? <nixpkgs>} :

pkgs.stdenv.mkDerivation {
  name = "jack-keyboard";

  src = fetchTarball {
    url = "https://deac-riga.dl.sourceforge.net/project/jack-keyboard/jack-keyboard/2.7.2/jack-keyboard-2.7.2.tar.gz";
    sha256 = "sha256:06xkzr7ajxfrj9j58knnpk492pnf0w3zpa70lysdq12sbahx20zm";
  };

  patchPhase = ''
    # require newer cmake version
    # could also be done via cmakeFlags: "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
    substituteInPlace ./CMakeLists.txt --replace "cmake_minimum_required(VERSION 2.8)" "cmake_minimum_required(VERSION 3.5)"
  '';

  nativeBuildInputs = with pkgs; [ cmake pkg-config ];

  buildInputs = with pkgs; [ gtk2 glib jack2 lash ];

  cmakeFlags = with pkgs;
    [ "-DGTK2_GLIBCONFIG_INCLUDE_DIR=${glib.out}/lib/glib-2.0/include"
      "-DGTK2_GDKCONFIG_INCLUDE_DIR=${gtk2.out}/lib/gtk-2.0/include"
      "-DLASH_INCLUDE_DIR=${lash.out}/include/lash-1.0"
    ];
}


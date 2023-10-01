{ lib, pkgs, python3Packages }:
with python3Packages;
buildPythonApplication {
  pname = "kobo-book-downloader";
  version = "2022-11-23";

  propagatedBuildInputs = [ 
    colorama
    pycryptodome
    requests
  ];

  postPatch = ''
    echo "
    #!/usr/bin/env python

    from setuptools import setup, find_packages

    setup(name='kobo-book-downloader',
          version='0.0.1',
          # Modules to import from other scripts:
          # packages=find_packages(where='kobo-book-downloader'),
          # Executables
          scripts=['kobo-book-downloader/__main__.py'],
         )
    " > setup.py

    sed -i "1i #!/usr/bin/env python3" kobo-book-downloader/__main__.py
  '';

  postInstall = ''
    # setuptools fails to find any files imported by the script. Place them manually.
    pushd $out/lib/python*/site-packages
    cp $src/kobo-book-downloader/* .
    popd

    # rename binary
    mv $out/bin/__main__.py $out/bin/kobo-book-downloader
  '';

  src = pkgs.fetchFromGitHub {
    owner = "TnS-hun";
    repo = "kobo-book-downloader";
    rev = "3f365f8d3c51fd2c458b496a4c8d0783767a2ab1";
    sha256 = "sha256-7dwHVeHeVUNp2Ka/ruvlhqlMwEKVcq7pd9lS5MpBWzk=";
  };
}

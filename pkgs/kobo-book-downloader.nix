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

    setup(name='demo-flask-vuejs-rest',
          version='0.0.1',
          # Modules to import from other scripts:
          packages=find_packages(where='kobo-book-downloader'),
          # packages=find_packages(),
          # provides=find_packages(),
          # Executables
          # scripts=['kobo-book-downloader/__main__.py'],
          # package_dir={''': 'kobo-book-downloader'}
          # packages=['kobo-book-downloader']
         )
    " > setup.py
    sed -i "1i #!/usr/bin/env python3" kobo-book-downloader/__main__.py
    sed -i "2i breakpoint()" kobo-book-downloader/__main__.py
    mv kobo-book-downloader/__main__.py kobo-book-downloader/__init__.py
    exit 1
  '';

  # doCheck = false;
  # doInstallCheck = false;

  src = pkgs.fetchFromGitHub {
    owner = "TnS-hun";
    repo = "kobo-book-downloader";
    rev = "3f365f8d3c51fd2c458b496a4c8d0783767a2ab1";
    sha256 = "sha256-7dwHVeHeVUNp2Ka/ruvlhqlMwEKVcq7pd9lS5MpBWzk=";
  };
}

{rustPlatform, fetchFromGitHub, lib, writers, python3Packages}:
rustPlatform.buildRustPackage rec {
  pname = "core-to-core-latency";
  version = "2023-01-18";

  src = fetchFromGitHub {
    owner = "nviennot";
    repo = pname;
    rev = "96a943ac384b78bf54252068f25e2f891bfadc60";
    sha256 = "sha256-Vbswp+E1Kbd8GHDg8J/MmfVYoKwraXgCIYk8D3MOlGw=";
  };

  cargoHash = "sha256-pUVfAbhed1TTsuz5k3XeCezxsYFMcx9p+NPST/Ux9cw=";

  # add my plotting script
  postInstall = let
    plotting-script = (
      writers.writePython3
      "core-to-core-latency-plot"
      {
        doCheck = false;
        libraries = with python3Packages; [
          pandas
          matplotlib
          numpy
        ];
      }
      ./core-latency.py
    );
  in ''
    mkdir -p $out/bin
    ln -s ${plotting-script} $out/bin/core-to-core-latency-plot
  '';

  meta = with lib; {
    description = "Measures the latency between CPU cores";
    homepage = "https://github.com/nviennot/core-to-core-latency";
    license = licenses.mit;
    maintainers = [ maintainers.pogobanene ];
  };
}

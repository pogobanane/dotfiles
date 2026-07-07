{
  lib,
  python3,
  claude-monitor-src,
}:

python3.pkgs.buildPythonPackage {
  pname = "claude-monitor";
  version = "4.0.0";
  pyproject = true;

  src = claude-monitor-src;

  build-system = with python3.pkgs; [ setuptools wheel ];

  dependencies = with python3.pkgs; [
    numpy
    pydantic
    pydantic-settings
    pyyaml
    pytz
    rich
    tomli
    wcwidth
  ];

  meta = {
    description = "Privacy-first Claude Code usage monitor with official limits, state exports, forecasting, and local history";
    license = lib.licenses.mit;
    mainProgram = "claude-monitor";
  };
}

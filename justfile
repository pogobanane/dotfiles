
nixos-build HOST="aenderpad":
  nix build .#nixosConfigurations.{{HOST}}.config.system.build.toplevel --log-format internal-json -v |& nom --json

nixos-repl HOST="aenderpad":
  nix repl ./repl.nix --argstr hostname {{HOST}}

# install/update home-manager config on doctor cluster
doctor-home:
  # only for use on the doctor cluster
  nix-shell '<home-manager>' -A install
  home-manager switch


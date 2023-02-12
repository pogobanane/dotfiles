hostname := `hostname`
proot := `pwd`

nixos-build HOST=`hostname`:
  nix build .#nixosConfigurations.{{HOST}}.config.system.build.toplevel --log-format internal-json -v |& nom --json

nixos-switch HOST=`hostname`:
  sudo nixos-rebuild switch --flake .#{{HOST}}

# repl into current system
nixos-repl:
  # use `:lf .` to load the underlying flake
  cd /run/current-system-flake && nix repl ./repl.nix --argstr hostname {{hostname}}

# repl into systems defined in this git
nixos-repl-git HOST=`hostname`:
  nix repl ./repl.nix --argstr hostname {{HOST}}

# install/update home-manager config on doctor cluster
doctor-home:
  # only for use on the doctor cluster
  # without flake: nix-shell '<home-manager>' -A install
  nix run {{proot}}#homeConfigurations.peter-doctor-cluster.activationPackage


hostname := `hostname`
proot := `pwd`

nixos-build HOST=`hostname`:
  nix build .#nixosConfigurations.{{HOST}}.config.system.build.toplevel --log-format internal-json -v --builders "" |& nom --json

nixos-switch HOST=`hostname`:
  sudo nixos-rebuild switch --flake .#{{HOST}}

# repl into current system
nixos-repl:
  # use `:lf .` to load the underlying flake
  cd /run/current-system-flake && nix repl ./repl.nix --argstr hostname {{hostname}}

nixos-nix SELECTOR WHAT="shell":
  nix {{WHAT}} $(realpath /etc/nixos)#nixosConfigurations.{{hostname}}.{{SELECTOR}}

# diff nixos config sources
nixos-diff-src:
  # requires nixos module modules/self.nix
  diff -r --color=always -x .direnv -x .envrc -x .git -x result -x archlinux -x async-term-askpass {{proot}} /etc/nixos \
  && echo "The running nixos system configuration matches the one defined here." \
  || echo "The running nixos system DOES NOT match the one configured here."
  diff {{proot}} /etc/tinc/retiolum/*.priv
  diff {{proot}} /etc/tinc/retiolum/*.pub
  diff {{proot}} /etc/ssh
  diff {{proot}} /etc/NetworkManager

# diff packages. Baseline: current system. Compare to: .#nixosConfigurations.{{HOST}}.
nixos-diff-closures:
  #!/bin/sh
  baseline="/nix/var/nix/profiles/system"
  compare=$(nix build .#nixosConfigurations.{{hostname}}.config.system.build.toplevel --print-out-paths)
  nix store diff-closures $baseline $compare

# diff evaluated nixos config
nixos-diff-config:
  echo wip
  # https://discourse.nixos.org/t/print-flake-system-configuration-as-json/14199/4
  # lib.mapAttrsRecursive (path: value: let result = builtins.tryEval value; in (if result.success then result.value else "error")) nixosConfigurations.aendernix.config
  nix eval --json .\#nixosConfigurations.aendernix.config.console

libvirt-diff:
  diff <(sudo virsh dumpxml win11) {{proot}}/libvirt/win11.libvirt.xml

# repl into systems defined in this git
nixos-repl-git HOST=`hostname`:
  nix repl ./repl.nix --argstr hostname {{HOST}}

# install/update home-manager config on doctor cluster
doctor-home:
  # only for use on the doctor cluster
  # without flake: nix-shell '<home-manager>' -A install
  nix run {{proot}}#homeConfigurations.peter-doctor-cluster.activationPackage

# same as doctor-home, but runs it remotely on all hosts
all-doctor-homes:
  ssh astrid.dse.in.tum.de     -- nix run ./dotfiles#homeConfigurations.peter-doctor-cluster.activationPackage
  ssh dan.dse.in.tum.de        -- nix run ./dotfiles#homeConfigurations.peter-doctor-cluster.activationPackage
  ssh mickey.dse.in.tum.de     -- nix run ./dotfiles#homeConfigurations.peter-doctor-cluster.activationPackage
  # ssh bill.dse.in.tum.de       -- nix run ./dotfiles#homeConfigurations.peter-doctor-cluster.activationPackage
  # ssh nardole.dse.in.tum.de    -- nix run ./dotfiles#homeConfigurations.peter-doctor-cluster.activationPackage
  # ssh yasmin.dse.in.tum.de     -- nix run ./dotfiles#homeConfigurations.peter-doctor-cluster.activationPackage
  ssh graham.dse.in.tum.de     -- nix run ./dotfiles#homeConfigurations.peter-doctor-cluster.activationPackage
  # ssh ryan.dse.in.tum.de       -- nix run ./dotfiles#homeConfigurations.peter-doctor-cluster.activationPackage
  ssh christina.dse.in.tum.de  -- nix run ./dotfiles#homeConfigurations.peter-doctor-cluster.activationPackage
  ssh jackson.dse.in.tum.de    -- nix run ./dotfiles#homeConfigurations.peter-doctor-cluster.activationPackage
  ssh adelaide.dse.in.tum.de   -- nix run ./dotfiles#homeConfigurations.peter-doctor-cluster.activationPackage
  ssh wilfred.dse.in.tum.de    -- nix run ./dotfiles#homeConfigurations.peter-doctor-cluster.activationPackage
  ssh river.dse.in.tum.de      -- nix run ./dotfiles#homeConfigurations.peter-doctor-cluster.activationPackage
  ssh jack.dse.in.tum.de       -- nix run ./dotfiles#homeConfigurations.peter-doctor-cluster.activationPackage
  ssh clara.dse.in.tum.de      -- nix run ./dotfiles#homeConfigurations.peter-doctor-cluster.activationPackage
  ssh amy.dse.in.tum.de        -- nix run ./dotfiles#homeConfigurations.peter-doctor-cluster.activationPackage
  ssh rose.dse.in.tum.de       -- nix run ./dotfiles#homeConfigurations.peter-doctor-cluster.activationPackage

backup-zed-config:
    ls ~/.local/share/zed/extensions/installed > ./homeManager/zed-extensions.txt
    cp ~/.config/zed/settings.json homeManager/zed-settings.json
    cp ~/.config/zed/keymap.json homeManager/zed-keymap.json

# ~/.config/nixpgs/home.nix
# install home manager via: `nix-shell '<home-manager>' -A install`
{ config
, nixpkgs
, pkgs
, sops-nix
, nix-index-database
, nur
, username
, homeDirectory
, my-gui
, inputs
, ...
}:
let

  sendtelegram = pkgs.writeScriptBin "sendtelegram" ''
    set -e
    echo "Sending \$1 as message to me: $1"

    TOKEN=$(cat $XDG_RUNTIME_DIR/telegram_bot_token)
    CHAT_ID="272730663"
    URL="https://api.telegram.org/bot$TOKEN/sendMessage"
    MESSAGE="$1"

    [[ $(curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE" | ${pkgs.jq}/bin/jq .ok) = "true" ]]
  '';

  nixos-generations = pkgs.callPackage ../pkgs/nixos-generations.nix { };

  sopspw = pkgs.writeShellApplication {
    name = "sopspw";
    runtimeInputs = [ pkgs.sops pkgs.age ];
    text = "SOPS_AGE_KEY=$(${pkgs.age}/bin/age -d ~/.config/sops/age/keys.age) ${pkgs.sops}/bin/sops \"$@\"";
  };

  nscan = pkgs.writeShellApplication {
    name = "nscan";
    runtimeInputs = [ pkgs.nmap ];
    text = "${pkgs.nmap}/bin/nmap -sP \"$@\"";
  };
in
{
  imports = [
    "${sops-nix}/modules/home-manager/sops.nix"
    ./gui.nix
    #./editors.nix
    ./neovim # reset by deleting ~/.local/share/nvim/
    nix-index-database.hmModules.nix-index
  ];

  my-gui.enable = my-gui;
  programs.nix-index-database.comma.enable = true;

  # Configuration of secrets
  sops = {
    #age.sshKeyPaths = [ "/home/peter/.ssh/aenderpad_home_manager" ]; # must have no password!
    defaultSopsFile = ./secrets.yaml;
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/aenderpad_home_manager.txt";
    secrets.telegram_bot_token = {
      path = "%r/telegram_bot_token"; # %r gets replaced with your $XDG_RUNTIME_DIR
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch"; # experimental way to automatically restart systemd.user services

  #programs.doom-emacs = {
  #enable = true;
  #doomPrivateDir = builtins.path {
  #name = "doom";
  #path = kjk
  #};

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = username;
  home.homeDirectory = homeDirectory;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.03";

  home.file.".config/nixpkgs/config.nix".text = ''
    {
      # pin nixpkgs to same version as for NixOS
      pkgs ? import (${nixpkgs}){}
    }: {
        packageOverrides = pkgs: {
          # pin nur to same version as for NixOS
          nur = import (${nur}) { inherit pkgs; };
      };
    }
  '';

  #systemd.user.services.ls1vpn = {
  #  Unit = {
  #    Description = "foobar desc";
  #  };
  #  Service = {
  #    ExecStart = "${ls1vpn}/bin/ls1vpn";
  #  };
  #};

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.tmux = {
    enable = true;
    extraConfig = builtins.readFile ./tmux.conf;
    plugins = with pkgs; [
      tmuxPlugins.resurrect # save/restore sessions leader+S (save) and +R (restore)
      tmuxPlugins.nord # powerline-ish theme
      tmuxPlugins.pain-control # sane pane contol bindings
      tmuxPlugins.sensible # general sanity
    ];
  };

  # config.programs.ssh.startAgent = true;

  home.file.".gitconfig".source = ./gitconfig;
  home.file.".gitignore".source = ./gitignore;

  home.file.".wezterm.lua".source = ./wezterm.lua;

  home.file.".emacs.d/init.el".text = ''
    (load "default.el")
  '';

  home.file.".zshrc_actual".source = ./zshrc;
  home.file.".zshrc".text = ''
    # zsh caches compiled code in *.zwc. But its updating is broken because it
    # follows symlinks and our link target is nix store seconds since epoch 0.
    # Thus we have to force an update manually here. Note that simple
    # comparison with -nt does not work as it will always dereference the
    # symlink as well. Funnily this works of course only once the .zwc has been
    # removed manually once to bootstrap this line in. Also that file is write
    # protected (-> -f).
    [[ $(stat ~/.zshrc -c '%021Y') < $(stat ~/.zshrc.zwc -c '%021Y') ]] || rm -f ~/.zshrc.zwc

    source ${pkgs.antigen}/share/antigen/antigen.zsh
    source ~/.zshrc_actual

    # add justfile autocompletion for zsh
    export FPATH=$FPATH:${pkgs.just}/share/zsh/site-functions
  '';

  home.file.".tmate.conf".source = ./tmate.conf;
  home.file.".config/lazygit/config.yml".source = ./lazygit.yml;

  home.packages = with pkgs; [
    antigen
    zoxide
    fzf
    tree
    git
    git-absorb
    tmux
    psmisc
    # libguestfs-with-appliance
    lazygit
    ack
    ripgrep
    bottom # btm
    #doom-emacs
    sendtelegram
    #nix-index # nix-locate
    #comma # package containing command and run it
    sops
    sopspw
    age
    nscan
    nixos-generations
    nix-output-monitor # nom
    # rustup
    ranger # command line file manager
    man-pages
    inputs.hosthog.packages.${system}.default
  ];
}

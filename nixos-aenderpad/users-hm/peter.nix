# ~/.config/nixpgs/home.nix
# install home manager via: `nix-shell '<home-manager>' -A install`
{ config, lib, pkgs, modulesPath, ... }:
let 
  doom-emacs = pkgs.callPackage (builtins.fetchTarball {
    url = https://github.com/vlaci/nix-doom-emacs/archive/master.tar.gz;
    sha256 = "sha256:1jz8mxh143a4470mq303ng6dh3bxi6mcppqli4z0m13qhqssh4fx";
  }) {
    doomPrivateDir = ./doom.d;
  };

  sendtelegram = pkgs.writeScriptBin "sendtelegram" ''
    set -e
    echo "Sending \$1 as message to me: $1"

    TOKEN=$(cat /home/peter/.ssh/telegram_bot_token)
    CHAT_ID="272730663"
    URL="https://api.telegram.org/bot$TOKEN/sendMessage"
    MESSAGE="$1"

    [[ $(curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE" | ${pkgs.jq}/bin/jq .ok) = "true" ]]
  '';

  nixos-generations = pkgs.writeScriptBin "nixos-generations" ./nixos-generations;

  ls1vpn = pkgs.writeShellApplication {
    name = "ls1vpn";
    runtimeInputs = [ pkgs.libsecret pkgs.openvpn pkgs.gnome.seahorse ];
    # text = "secret-tool store --label='foobar' setting-name foo";
    text = "${pkgs.gnome.seahorse}libexec/seahorse/ssh-askpass";
  };

  sopspw = pkgs.writeShellApplication {
    name = "sopspw";
    runtimeInputs = [ pkgs.sops pkgs.age ];
    text = "SOPS_AGE_KEY=$(${pkgs.age}/bin/age -d ~/.config/sops/age/keys.age) ${pkgs.sops}/bin/sops \"$@\"";
  };

  sops-nix = pkgs.fetchFromGitHub {
    owner = "Mic02";
    repo = "sops-nix";
    rev = "feat/home-manager";
    ref = "c4d7f1cbd0f971e1dd625988556dd83539ee422f";
    sha256 = "";
  };

  nscan = pkgs.writeShellApplication {
    name = "nscan";
    runtimeInputs = [ pkgs.nmap ];
    text = "${pkgs.nmap}/bin/nmap -sP \"$@\"";
  };

  my-vim-paste-easy = pkgs.vimUtils.buildVimPlugin {
    name = "vim-paste-easy";
    src = pkgs.fetchFromGitHub {
      owner = "roxma";
      repo = "vim-paste-easy";
      rev = "c28c2e4fc7b2d57efb54787bc6d67120b523d42c";
      sha256 = "sha256-DbVyfr9uH3o1GSvWv06/5HO2S5JXVYZvudPN2RemOY0=";
    };
  };
in
{
  imports = [ 
    ./gui.nix
    ./sops.nix
  ];

  #home-manager.sharedModules = [
    #./sops.nix
  #];

  # Configuration of secrets
  # TODO: see comment in sops.nix
  # sops = {
  #   #age.sshKeyPaths = [ "/home/peter/.ssh/aenderpad_home_manager" ]; # must have no password!
  #   age.keyFile = "/home/peter/.config/sops/age/aenderpad_home_manager.txt";
  #   secrets.example_key = {
  #     sopsFile = ./secrets.yaml;
  #     path = "/run/user/1000/example_key.txt"; # %r gets replaced with your $XDG_RUNTIME_DIR
  #   };
  # };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  #programs.doom-emacs = {
    #enable = true;
    #doomPrivateDir = builtins.path {
      #name = "doom";
      #path = kjk
  #};

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "peter";
  home.homeDirectory = "/home/peter";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.03";

  # home.environment.variables = { EDITOR = "rvim"; };
  xdg.configFile."nvim/init.vim".source = ./nvimrc;

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
      tmuxPlugins.resurrect # save/restore sessions
      tmuxPlugins.nord # powerline-ish theme
      tmuxPlugins.pain-control # sane pane contol bindings
      tmuxPlugins.sensible # general sanity
    ];
  };
  
  # config.programs.ssh.startAgent = true;

  home.file.".gitconfig".source = ./gitconfig;
  home.file.".gitignore".text = ''
    .direnv/
    result/
    *.swp
  '';

  home.file.".emacs.d/init.el".text = ''
    (load "default.el")
  '';

  home.file.".zshrc_actual".source = ./zshrc;
  home.file.".zshrc".text = ''
    source ${pkgs.antigen}/share/antigen/antigen.zsh
    source ~/.zshrc_actual
  '';

  home.file.".tmate.conf".source = ./tmate.conf;
  home.file.".config/lazygit/config.yml".source = ./lazygit.yml;

  home.file.".config/nixpkgs/config.nix".text = let 
    #flake-inputs2 = (builtins.getFlake (toString ./.)).inputs;
    flake-inputs = (import ../flake.nix).inputs;
    assertion = if (flake-inputs.nur.url == "github:nix-community/NUR") then throw "unexpected NUR url" else "";
  in ''
    #${flake-inputs.nur.url}
    {
        packageOverrides = pkgs: {

          #nur = import ({flake-inputs2.nur}) { inherit pkgs; };
          nur = import (
            # boring and gives nix-shell other nur version than nixos:
            builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz"

            #builtins.fetchGit {
            #  url = "https://github.com/nix-community/NUR.git";
            #  rev = "{flake-inputs.nur.rev}";
            #}

            #builtins.fetchTarball {
            #  # Get the revision by choosing a version from https://github.com/nix-community/NUR/commits/master
            #  url = "https://github.com/nix-community/NUR/archive/3a6a6f4da737da41e27922ce2cfacf68a109ebce.tar.gz";
            #  # Get the hash by running `nix-prefetch-url --unpack <url>` on the above url
            #  sha256 = "04387gzgl8y555b3lkz9aiw9xsldfg4zmzp930m62qw8zbrvrshd";
            #}

            ) {
          inherit pkgs;
            };
      };
    }
  '';
    #{
      #nixpkgs.config.packageOverrides = pkgs: {
        #nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
          #inherit pkgs;
        #};
      #};
    #}

  home.packages = with pkgs; [
    antigen
    zoxide
    fzf
    tree
    git
    tmux
    psmisc
    # libguestfs-with-appliance
    lazygit
    ack
    ripgrep
    bottom # btm
    #doom-emacs
    sendtelegram
    nix-index
    sops
    sopspw
    age
    nscan
    nixos-generations
    (
      vim_configurable.customize {
        name = "vim";
        vimrcConfig.customRC = builtins.readFile ./vimrc;
        vimrcConfig.packages.nixbundle.start = with pkgs.vimPlugins; [ 
          my-vim-paste-easy
          vim-sensible 
          # detenctindent
          nerdcommenter
          ale
          molokai
          nerdtree
          rainbow_parentheses-vim
          fzf-vim
          gitgutter
          vim-airline
          vim-airline-themes
          indentLine
          zoomwintab-vim
          vim-tmux-navigator
          vim-bufkill
          ack-vim
          vim-osc52
          tabular
          vim-LanguageTool
        ];
#          tpope/vim-sensible
#          roryokane/detectindent
#          ddollar/nerdcommenter
#          dense-analysis/ale
#          tomasr/molokai
#          scrooloose/nerdtree
#          junegunn/rainbow_parentheses.vim
#          junegunn/fzf
#          ctrlpvim/ctrlp.vim # vimscript only fuzzy search
#          airblade/vim-gitgutter
#          vim-airline/vim-airline
#          vim-airline/vim-airline-themes
#
#          Yggdroot/indentLine # mark levels of line indentation |
#          troydm/zoomwintab.vim
#          christoomey/vim-tmux-navigator
#          qpkorr/vim-bufkill # :BD is :bdelete without closing windows
#        ];
      }
    )
    # rustup
  ];
}

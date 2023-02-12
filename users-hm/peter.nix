# ~/.config/nixpgs/home.nix
# install home manager via: `nix-shell '<home-manager>' -A install`
{ 
  config, 
  lib, 
  nixpkgs, 
  pkgs, 
  sops-nix, 
  nur, 
  username, 
  homeDirectory, 
  my-gui,
  ... 
}: let 
  doom-emacs = pkgs.callPackage (builtins.fetchTarball {
    url = https://github.com/vlaci/nix-doom-emacs/archive/master.tar.gz;
    sha256 = "sha256:1jz8mxh143a4470mq303ng6dh3bxi6mcppqli4z0m13qhqssh4fx";
  }) {
    doomPrivateDir = ./doom.d;
  };

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
  
  vim-submode = pkgs.callPackage ../pkgs/vim-submode.nix { };

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

  p4-syntax-highlighter-collection = pkgs.vimUtils.buildVimPlugin {
    name = "p4-syntax-highlighter-collection";
    src = pkgs.fetchFromGitHub {
      owner = "c3m3gyanesh";
      repo = "p4-syntax-highlighter-collection";
      rev = "e6525b5ea5eb31148dcc7957cb49985de6e582c3";
      sha256 = "sha256-exZ89Q30OwpIl00SG8KhRxA8vbnRNdJhZVGNZMDYLVQ=";
    };
  };
in
{
  imports = [ 
    "${sops-nix}/modules/home-manager/sops.nix"
    ./gui.nix
  ];

  my-gui.enable = my-gui;

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
    source ${pkgs.antigen}/share/antigen/antigen.zsh
    source ~/.zshrc_actual
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
    nix-index # nix-locate
    sops
    sopspw
    age
    nscan
    nixos-generations
    nix-output-monitor # nom
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
          zoomwintab-vim # <C-w>o to zoom a buffer to whole screen size
          vim-tmux-navigator
          vim-bufkill
          ack-vim
          #vim-osc52
          vim-oscyank
          tabular
          vim-LanguageTool
          vim-obsession # start recording vim sessions for a directory with :Obsess and restore it with vim -S
          vim-submode
          vim-cpp-enhanced-highlight
          p4-syntax-highlighter-collection
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

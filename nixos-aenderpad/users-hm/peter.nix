# ~/.config/nixpgs/home.nix
# install home manager via: `nix-shell '<home-manager>' -A install`
{ config, lib, pkgs, ... }:

let 
  doom-emacs = pkgs.callPackage (builtins.fetchTarball {
    url = https://github.com/vlaci/nix-doom-emacs/archive/master.tar.gz;
    sha256 = "sha256:1jz8mxh143a4470mq303ng6dh3bxi6mcppqli4z0m13qhqssh4fx";
  }) {
    doomPrivateDir = ./doom.d;
  };
  sendtelegram = pkgs.writeScriptBin "sendtelegram" ''
    echo "Sending \$1 as message to me: $1"

    TOKEN="1312459906:AAHWAsfnr3SuZJYyP8scl8fJ_kiW-jQWArA"
    CHAT_ID="272730663"
    URL="https://api.telegram.org/bot$TOKEN/sendMessage"
    MESSAGE="$1"

    curl -s -X POST $URL -d chat_id=$CHAT_ID -d text="$MESSAGE" &> /dev/null
  '';
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

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  # programs.direnv.nix-direnv.enableFlakes = true;

  programs.git = {
    enable = true;
    userName  = "Pogobanane";
    userEmail = "aenderboy@gmx.de";
  };
  
  # config.programs.ssh.startAgent = true;

  home.file.".emacs.d/init.el".text = ''
    (load "default.el")
  '';

  home.file.".zshrc_actual".source = ./zshrc;
  home.file.".zshrc".text = ''
    source ${pkgs.antigen}/share/antigen/antigen.zsh
    source ~/.zshrc_actual
  '';

  home.file.".tmux.conf".source = ./tmux.conf;
  home.file.".tmate.conf".source = ./tmate.conf;
  home.file.".imapfilter/config.lua".source = ./imapfilter.lua;

  home.packages = with pkgs; [
    antigen
    fzf
    tree
    git
    tmux
    psmisc
    libguestfs-with-appliance
    lazygit
    ack
    ripgrep
    bottom # btm
    #doom-emacs
    sendtelegram
    imapfilter
    languagetool
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

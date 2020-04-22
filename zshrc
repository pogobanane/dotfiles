###############################################################
#                 user config                                 #
###############################################################

#[ -z "$SSH_CONNECTION" ] && ZSH_TMUX_AUTOSTART="true"
# [ -z $TMUX ] && ZSH_TMUX_AUTOSTART="true"
# vim starts terminals as xterm even if running in tmux
[[ ! $TERM = *screen* ]] && [ ! $TERM = 'xterm' ] && tmux new -t default

path+=$HOME/bin
typeset -U path

export SSH_ASKPASS=/usr/bin/ksshaskpass
export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket
export EDITOR=vim

alias sve="sudo EDITOR=$EDITOR virsh edit"

set ttymouse=xterm2
set mouse=a

#function subl () {
#	/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=sublime --file-forwarding com.sublimetext.three $@ &>/dev/null &
#}

###############################################################
#                 antigen packages                            #
###############################################################

# requires the antigen-git package
source /usr/share/zsh/share/antigen.zsh

# Load the oh-my-zsh's library.
# This is a minimalistic baseline configuration. 
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
#antigen bundle heroku
#antigen bundle pip
#antigen bundle lein
antigen bundle command-not-found
antigen bundle colored-man-pages
antigen bundle extract
#antigen bundle tmux
antigen bundle ansible
antigen bundle systemd


# Bundles from the zsh-users repo (fish like zsh stuff)

antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-completions

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#686868"
ZSH_AUTOSUGGEST_USE_ASYNC="true"
antigen bundle zsh-users/zsh-autosuggestions

# my stuff
antigen bundle zpm-zsh/ssh
antigen bundle HeroCC/LS_COLORS

# Load the theme.
#antigen theme fishy

# Tell Antigen that you're done.
antigen apply


###############################################################
#                 my promt theme                              #
###############################################################

# ZSH Theme emulating something similar to the Fish shell's default prompt.

_fishy_collapsed_wd() {
  echo $(pwd | perl -pe '
   BEGIN {
      binmode STDIN,  ":encoding(UTF-8)";
      binmode STDOUT, ":encoding(UTF-8)";
   }; s|^$ENV{HOME}|~|g; s|/([^/.]{'3'})[^/]*(?=/)|/$1|g; s|/\.([^/]{'3'})[^/]*(?=/)|/.$1|g
')
}

user_color='green'; [ $UID -eq 0 ] && user_color='red'
return_status="%{$fg_bold[red]%}%(?.. %?)%{$reset_color%}"
PROMPT='%n@%m${return_status}%{$fg[$user_color]%}%(!.#.>)%{$reset_color%} '
PROMPT2='%{$fg[red]%}\ %{$reset_color%}'

date_time_string="+%a %T"
RPROMPT="${RPROMPT}"'%{$FG[240]%}$(date $date_time_string)%{$reset_color%}$(git_prompt_info)$(git_prompt_status)%{$reset_color%} %{$fg[$user_color]%}$(_fishy_collapsed_wd)%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX=" "
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""

ZSH_THEME_GIT_PROMPT_ADDED="%{$fg_bold[green]%}+"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg_bold[blue]%}!"
ZSH_THEME_GIT_PROMPT_DELETED="%{$fg_bold[red]%}-"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$fg_bold[magenta]%}>"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$fg_bold[yellow]%}#"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[cyan]%}?"

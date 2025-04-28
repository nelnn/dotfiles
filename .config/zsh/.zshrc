export EDITOR=nvim
# ls enable directory color:
export CLICOLOR=1
export LSCOLORS=gxfxcxdxbxegedabagacad
setopt auto_cd

# Enable man syntax highlighting
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# Enable colors and change prompt:
autoload -U colors && colors

# Git Status Prompt
# Using single quotes around the PROMPT is very important, otherwise
# the git branch will always be empty. Using single quotes delays the
# evaluation of the prompt. Also PROMPT is an alias to PS1.
git_prompt() {
    local branch="$(git symbolic-ref HEAD 2> /dev/null | cut -d'/' -f3-)"
    local branch_truncated="${branch##*[/|--]}"
    if (( ${#branch} > 20 )); then
        branch="...${branch_truncated}"
    fi

    [ -n "${branch}" ] && echo " (${branch})"
}

# Prompt Config
setopt PROMPT_SUBST
PROMPT=$'%B%{$fg[red]%}[%{$fg[blue]%}%(6~|.../%1~|%~)%{$fg[red]%}]%{$fg[green]%}$(git_prompt)%{$reset_color%}%{$fg[yellow]%}%{$fg[magenta]%}%(?.$.)%b '
# Show Datetime on the right side.
RPROMPT='%{$fg[cyan]%}[%D{%f/%m/%y} | %D{%L:%M:%S}]'

# History in cache directory:
HISTFILE=$HOME/.cache/.zsh_history
HISTSIZE=2000
SAVEHIST=1000
setopt appendhistory

# Basic auto/tab complete:
autoload -U compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zmodload zsh/complist
# compinit
_comp_options+=(globdots)		# Include hidden files.


#############################
######### VIM MODE ##########
#############################

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Load aliases and shortcuts if existent.
[ -f "$HOME/.config/zsh/shortcutrc" ] && source "$HOME/.config/zsh/shortcutrc"
[ -f "$HOME/.config/zsh/aliasrc" ] && source "$HOME/.config/zsh/aliasrc"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/nsc/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/nsc/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/nsc/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/nsc/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# zsh-autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^@' autosuggest-accept # Ctrl + Space to accept

# Bind Tab to menu-complete (Which is the default)
# bindkey '^L' menu-complete

# Load zsh-syntax-highlighting; should be last.
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Load zoxide (cd replacement)
eval "$(zoxide init zsh)"

# Start Tmux
# Attach only if there's no session
if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
  if ! tmux has-session 2>/dev/null; then
    tmux new-session -s default
  fi
fi

setopt auto_cd

# Enable colors and change prompt:
autoload -U colors && colors

# Use two lines in Git repositories, one line elsewhere.
autoload -Uz add-zsh-hook
update_prompt_layout() {
    local branch
    typeset -g prompt_git_text='' prompt_newline='' prompt_right_up='' prompt_right_down=''
    if branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null) ||
       branch=$(git rev-parse --short HEAD 2>/dev/null); then
        # Escape percent signs so branch names aren't interpreted as prompt codes.
        prompt_git_text=" (${branch//\%/%%})"
        prompt_newline=$'\n'
        prompt_right_up=$'\e[1A'
        prompt_right_down=$'\e[1B'
    fi
}
add-zsh-hook precmd update_prompt_layout

# Keep substitutions deferred until the prompt is rendered.
setopt PROMPT_SUBST
PROMPT='%B%{$fg[red]%}[%{$fg[blue]%}%(6~|.../%1~|%~)%{$fg[red]%}]%{$fg[green]%}${prompt_git_text}%{$reset_color%}${prompt_newline}%{$fg[yellow]%}%{$fg[magenta]%}%(?.$.)%b '
# Keep the date on the first line; cursor movements are zero-width to ZLE.
RPROMPT='%{${prompt_right_up}%}%{$fg[cyan]%}[%D{%a}·%D{%f%b}·%D{%L:%M}]%{$reset_color%}%{${prompt_right_down}%}'

# Persistent history in the XDG state directory:
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history
[[ -d ${HISTFILE:h} ]] || mkdir -p -m 700 -- "${HISTFILE:h}"
setopt appendhistory

# Basic auto/tab complete:
autoload -U compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zmodload zsh/complist
compinit
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
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutenvrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutenvrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/workaliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/workaliasrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc"

# zsh-autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^@' autosuggest-accept # Ctrl + Space to accept

# Bind Tab to menu-complete (Which is the default)
# bindkey '^L' menu-complete

# Load zsh-syntax-highlighting; should be last.
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# Keep dependency and internal directories out of zoxide (including Yazi's picker).
export _ZO_EXCLUDE_DIRS="$HOME:*/.venv:*/.venv/*:*/venv:*/venv/*:*/node_modules:*/node_modules/*:*/.git:*/.git/*:*/.jj:*/.jj/*:*/__pycache__:*/__pycache__/*"
eval "$(zoxide init zsh)" # Load zoxide (cd replacement)
eval "$(fnm env --use-on-cd --shell zsh)" # fnm for node.js version manager
# Load nvm (Node Version Manager)
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

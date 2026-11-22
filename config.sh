#!/bin/bash

# Real configuration lives in dotfiles; ~/.config contains links to it.
SOURCE_DIR="$HOME/.dotfiles/.config"
DEST_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config-backups/$(date +%Y%m%d-%H%M%S)-$$"

# Link directories containing only configuration. For applications that mix
# configuration with state, link individual files and leave runtime data local.
directories=(
    aerospace alacritty btop ghostty git karabiner lazydocker lazygit
    mpv neofetch npm nvim python shell sioyek skhd sniffnet terraform
    tmux tor vim wget yazi zathura zsh
)
files=(
    cheat/conf.yml cliamp/config.toml jj/config.toml mcp.json
)

link_config() {
    local relative="$1"
    local source="$SOURCE_DIR/$relative"
    local destination="$DEST_DIR/$relative"

    if [ ! -e "$source" ]; then
        printf 'Missing source: %s\n' "$source" >&2
        return 1
    fi
    if [ -L "$destination" ] && [ "$(readlink "$destination")" = "$source" ]; then
        return 0
    fi
    mkdir -p "$(dirname "$destination")" || return 1
    if [ -e "$destination" ] || [ -L "$destination" ]; then
        mkdir -p "$(dirname "$BACKUP_DIR/$relative")" || return 1
        mv "$destination" "$BACKUP_DIR/$relative" || return 1
        printf 'Backed up %s to %s\n' "$destination" "$BACKUP_DIR/$relative"
    fi
    ln -s "$source" "$destination" || return 1
    printf '%s -> %s\n' "$destination" "$source"
}

for relative in "${directories[@]}" "${files[@]}"; do
    link_config "$relative" || return 1 2>/dev/null || exit 1
done

#!/bin/bash

# Source and destination directories
SOURCE_DIR="$HOME/.dotfiles/.config"

# list of directories to symlink in ${homedir}
directories=(karabiner lf nvim python tmux zk yazi zsh)

# create symlinks (will overwrite old dotfiles)
# for directory in "$SOURCE_DIR"/*; do  # use this to apply for all files/directories
for directory in "${directories[@]}"; do
    echo "Running ln -sf ${SOURCE_DIR}/${directory} ${HOME}/.config/"
    ln -sf "${SOURCE_DIR}/${directory}" "${HOME}/.config"
done

#!/bin/bash

# Source and destination directories
SOURCE_DIR="$HOME/.dotfiles/.local/bin"

# List of directories to symlink in ${HOME}
directories=(musictag musicsort)

# Create symlinks (will overwrite old dotfiles)
for directory in "${directories[@]}"; do
    echo "Creating symlink for ${directory} in ${HOME}/.local/bin"
    ln -sf "${SOURCE_DIR}/${directory}" "${HOME}/.local/bin/${directory}"
    chmod +x "${HOME}/.local/bin/${directory}"
done

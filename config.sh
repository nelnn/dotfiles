#!/bin/bash

# TODO: This is created by Claude. May need an update.

# Source and destination directories
SOURCE_DIR="$HOME/.dotfiles/.config"
DEST_DIR="$HOME/.config"

# Create the destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Loop through each directory in the source
for dir in "$SOURCE_DIR"/*; do
    if [ -d "$dir" ]; then
        # Get the base name of the directory
        base_name=$(basename "$dir")
        
        # Full path of the destination link
        dest_link="$DEST_DIR/$base_name"
        
        # Check if a link already exists
        if [ -L "$dest_link" ]; then
            echo "Updating existing link for $base_name"
            ln -sf "$dir" "$dest_link"
        elif [ -e "$dest_link" ]; then
            echo "Warning: $dest_link already exists and is not a symlink. Skipping."
        else
            echo "Creating new link for $base_name"
            ln -s "$dir" "$dest_link"
        fi
    fi
done

echo "Linking complete!"

# Nelson's dotfiles
These are my dotfiles.

- Opperating System: macOS
- Settings for:
    - vim/nvim (text editor)
    - zsh (shell)
    - lf (file manager)
    - other default programs like homebrew, golang, rust, etc.


# Get Started
```bash
cd ~
git clone https://github.com/nelnn/dotfiles.git
ln -sf ~/.dotfiles/.config/zsh/.zshenv ~/.zshenv
source brew.sh
source config.sh
```

This installs the mac package manager [homebrew](https://brew.sh/) and installs all the necessary packages for the dotfiles.
It then creates a symbolic link for `.zshenv` since we want the `.zshrc` to be in the zsh folder instead of the home directory:
`config.sh` is a handy script for creating all the symlinks in the `~/.config/` directory.

Remove any default files in the home directory like `.zshrc` or other file you see in the `~/.dotfiles/.config/` directory
(except the symlink `~/.zshenv` we just created of course.). 
Retart your terminal and you should be good to go.


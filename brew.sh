#!/usr/bin/env zsh

# Install Homebrew if it isn't already installed
if ! command -v brew &>/dev/null; then
    echo "Homebrew not installed. Installing Homebrew."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Attempt to set up Homebrew PATH automatically for this session
    if [ -x "/opt/homebrew/bin/brew" ]; then
        # For Apple Silicon Macs
        echo "Configuring Homebrew in PATH for Apple Silicon Mac..."
        export PATH="/opt/homebrew/bin:$PATH"
    fi
else
    echo "Homebrew is already installed."
fi

# Verify brew is now accessible
if ! command -v brew &>/dev/null; then
    echo "Failed to configure Homebrew in PATH. Please add Homebrew to your PATH manually."
    exit 1
fi

# Update Homebrew and Upgrade any already-installed formulae
brew update
brew upgrade
brew upgrade --cask
brew cleanup

# Define an array of packages to install using Homebrew.
packages=(
    # Shell
    "bash"
    "zsh"
    # CLI
    "zsh-syntax-highlighting"
    "zsh-autosuggestions"
    "zoxide" # replacement for cd
    "bat" # Cat with syntax highlighting
    "tree"
    "yazi"
    "poppler" # Preview PDF
    # Python
    "python"
    "pylint"
    "black"
    # Git
    "git"
    "jesseduffield/lazygit/lazygit"
    # neovim
    "neovim"
    "ripgrep"
    # LaTex
    "pandoc"
    "tectonic" # Lightweigh LaTex Compiler
    # Email
    "neomutt"
    "isync"  # Downloads emails
    "msmtp"  # Send mail
    "pass"  # Securely stores user passwords encrypted with their GPG key
    "lynx"  # Format HTML emails in neomutt
    "notmuch"  # Index all mail making it searchable
    "urlview"  # Allows one to follow urls
    # Other Stuff
    "node"
    "go"
    "hugo" # static site generator
)

# Loop over the array to install each application.
for package in "${packages[@]}"; do
    if brew list --formula | grep -q "^$package\$"; then
        echo "$package is already installed. Skipping..."
    else
        echo "Installing $package..."
        brew install "$package"
    fi
done

# Add the Homebrew zsh to allowed shells
echo "Changing default shell to Homebrew zsh"
echo "$(brew --prefix)/bin/zsh" | sudo tee -a /etc/shells >/dev/null
# Set the Homebrew zsh as default shell
chsh -s "$(brew --prefix)/bin/zsh"

# Git config name
echo "Please enter your FULL NAME for Git configuration:"
read git_user_name

# Git config email
echo "Please enter your EMAIL for Git configuration:"
read git_user_email

# Set my git credentials
$(brew --prefix)/bin/git config --global user.name "$git_user_name"
$(brew --prefix)/bin/git config --global user.email "$git_user_email"

# Define an array of applications to install using Homebrew Cask.
apps=(
    "firefox"
    "brave-browser"
    "virtualbox"
    "spotify"
    "google-drive"
    "gimp"
    "vlc"
    "anki"
    "ngrok"
    "whatsapp"
    "singal"
    "alt-tab"
    "alfred"
    "raycast"
    "karabiner-elements"
    "github"
)

# Loop over the array to install each application.
for app in "${apps[@]}"; do
    if brew list --cask | grep -q "^$app\$"; then
        echo "$app is already installed. Skipping..."
    else
        echo "Installing $app..."
        brew install --cask "$app"
    fi
done

# Update and clean up again for safe measure
brew update
brew upgrade
brew upgrade --cask
brew cleanup

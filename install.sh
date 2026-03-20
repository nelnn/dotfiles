#!/usr/bin/env zsh

# ── Homebrew ──────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
    echo "Homebrew not installed. Installing Homebrew."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [ -x "/opt/homebrew/bin/brew" ]; then
        echo "Configuring Homebrew in PATH for Apple Silicon Mac..."
        export PATH="/opt/homebrew/bin:$PATH"
    fi
else
    echo "Homebrew is already installed."
fi

if ! command -v brew &>/dev/null; then
    echo "Failed to configure Homebrew in PATH. Please add Homebrew to your PATH manually."
    exit 1
fi

brew update
brew upgrade
brew upgrade --cask
brew cleanup

# ── Taps ──────────────────────────────────────────────────────────────────────
brew tap smudge/smudge
brew tap jesseduffield/lazygit
brew tap jesseduffield/lazydocker
brew tap koekeishiya/formulae
brew tap zegervdv/zathura
brew tap hashicorp/tap

# ── Formulae ──────────────────────────────────────────────────────────────────
packages=(
    # Shell
    "zsh"
    "zsh-syntax-highlighting"
    "zsh-autosuggestions"
    # CLI Tools
    "zoxide"           # replacement for cd
    "bat"              # cat with syntax highlighting
    "bat-extras"       # bat-based utilities (batdiff, batgrep, etc.)
    "eza"              # modern ls replacement
    "tree"
    "yazi"             # terminal file manager
    "fzf"              # fuzzy finder
    "fd"               # modern find
    "jq"               # JSON processor
    "ripgrep"          # fast grep
    "wget"
    "rlwrap"           # readline wrapper
    "btop"             # resource monitor
    "neofetch"         # system info
    "tealdeer"         # tldr for man pages
    "pastel"           # terminal color tool
    "visidata"         # terminal spreadsheet/data explorer
    "astroterm"        # planetarium in terminal
    "sevenzip"         # archive tool
    "exiftool"         # metadata reader/writer
    "screenresolution" # set screen resolution from CLI
    "sniffnet"         # network monitor
    "poppler"          # PDF rendering (yazi preview)
    "smudge/smudge/nightlight" # Night Shift CLI
    # Git
    "git"
    "jesseduffield/lazygit/lazygit"
    "jesseduffield/lazydocker/lazydocker"
    "jj"               # jujutsu - modern VCS
    # Neovim
    "neovim"
    "marksman"         # markdown LSP
    # Terminal / Window Management
    "tmux"
    "koekeishiya/formulae/skhd" # hotkey daemon
    # Media
    "ffmpeg"
    "imagemagick"
    "handbrake"        # video transcoder (CLI)
    "yt-dlp"           # YouTube/video downloader
    # Music
    # "mpd"            # music player daemon
    # "ncmpcpp"        # mpd TUI client
    # Documents / Publishing
    "pandoc"
    "typst"
    # "tectonic"       # lightweight LaTeX compiler
    # Email
    # "neomutt"
    # "isync"          # downloads emails (mbsync)
    # "msmtp"          # send mail
    # "pass"           # password manager (GPG-encrypted)
    # "lynx"           # format HTML emails in neomutt
    # "notmuch"        # mail indexer
    # "urlview"        # follow URLs in neomutt
    # Languages & Runtimes
    "go"
    "rust"
    "node"
    "deno"
    "uv"               # Python version & package manager
    "dotnet@9"
    # "r"
    "cmake"
    # AI / ML
    "ollama"
    "llama.cpp"
    "opencode"         # AI coding agent for terminal
    "mlx"              # Apple ML framework
    # Database & Infrastructure
    "postgresql@15"
    "awscli"
    "kubernetes-cli"
    "minikube"
    "hashicorp/tap/terraform"
    # Network & Security
    "gnupg"
    "tor"
    "transmission-cli"
    "mole"             # SSH tunnel manager
    # PDF / Document Viewers
    "zegervdv/zathura/zathura"
    "zegervdv/zathura/zathura-pdf-mupdf"
    # Misc
    # "hugo"           # static site generator
)

for package in "${packages[@]}"; do
    local_name="${package##*/}"
    if brew list --formula | grep -q "^${local_name}\$"; then
        echo "$package is already installed. Skipping..."
    else
        echo "Installing $package..."
        brew install "$package"
    fi
done

# ── Shell setup ───────────────────────────────────────────────────────────────
echo "Changing default shell to Homebrew zsh"
echo "$(brew --prefix)/bin/zsh" | sudo tee -a /etc/shells >/dev/null
chsh -s "$(brew --prefix)/bin/zsh"

# ── Git config ────────────────────────────────────────────────────────────────
echo "Please enter your FULL NAME for Git configuration:"
read git_user_name
echo "Please enter your EMAIL for Git configuration:"
read git_user_email
$(brew --prefix)/bin/git config --global user.name "$git_user_name"
$(brew --prefix)/bin/git config --global user.email "$git_user_email"

# ── Casks ─────────────────────────────────────────────────────────────────────
casks=(
    # Browsers
    "brave-browser"
    "librewolf"
    "tor-browser"
    "mullvad-vpn"
    # Terminal
    "ghostty"
    "alacritty"        # GPU-accelerated terminal emulator
    # Productivity / Launcher
    "raycast"
    "alt-tab"          # better cmd-tab switcher
    # "keepingyouawake" # prevent sleep
    # Input & Window Management
    "karabiner-elements"  # keyboard customizer
    "scroll-reverser"
    # Communication
    "signal"
    "whatsapp"
    "legcord"          # Discord client
    # Media
    "vlc"
    "spotify"
    "freetube"         # privacy-focused YouTube client
    "obs"              # streaming & recording
    "steam"
    # Notes / Reference
    "anki"
    "zotero"
    "calibre"          # ebook manager
    # Office
    "libreoffice"
    # Development
    "orbstack"         # Docker & Linux VMs
    "visual-studio-code"
    "pycharm-ce"       # JetBrains Python IDE
    "hoppscotch"       # API client
    "quarto"           # publishing system
    # AI / ML
    "lm-studio"        # local LLM GUI
    # VPN / Network
    "protonvpn"
    "tailscale-app"
    # PDF Viewers
    "sioyek"
    "pdf-expert"
    # Fonts
    "font-hack-nerd-font"
    "font-jetbrains-mono"
    "font-symbols-only-nerd-font"
    # Utilities
    "keycastr"         # key visualizer
    "openmtp"          # Android file transfer
    "musicbrainz-picard" # music tagger
    "rustdesk"         # remote desktop
    "syncthing-app"    # continuous file sync
    # "alfred"         # launcher
)

for app in "${casks[@]}"; do
    if brew list --cask | grep -q "^$app\$"; then
        echo "$app is already installed. Skipping..."
    else
        echo "Installing $app..."
        brew install --cask "$app"
    fi
done

# ── Mac App Store (requires being signed in) ──────────────────────────────────
brew install mas

mas_apps=(
    "1352778147"  # Bitwarden
    "425264550"   # Blackmagic Disk Speed Test
    "682658836"   # GarageBand
    "1444383602"  # Goodnotes
    "408981434"   # iMovie
    "409183694"   # Keynote
    "360593530"   # Notability
    "409203825"   # Numbers
    "1451685025"  # WireGuard
)

for app in "${mas_apps[@]}"; do
    mas install "$app"
done

# ── Manual Installs ───────────────────────────────────────────────────────────
# The following must be downloaded and installed manually:
#
#   Mathematica   https://www.wolfram.com/mathematica/  (requires license)
#   Xcode         xcode-select --install
#                 OR https://developer.apple.com/xcode/
#   World Monitor https://worldmonitor.app/

# ── Final cleanup ─────────────────────────────────────────────────────────────
brew update
brew upgrade
brew upgrade --cask
brew cleanup

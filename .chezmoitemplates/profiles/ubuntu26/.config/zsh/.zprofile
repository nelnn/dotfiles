[[ ! -f "$HOME/.local/bin/env" ]] || source "$HOME/.local/bin/env"
# Shared XDG roots and application paths (npm, Nimble, Pulumi, etc.).
source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/profile"

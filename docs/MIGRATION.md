# Branch consolidation

## Inputs

Compared fetched `origin/main`, `origin/ubuntu26`, and `origin/x220` without
switching the active `~/.dotfiles` checkout. Exact commit IDs and target membership
are recorded in `profile-manifest.json`. Previously imported live Mac Borders,
Rift, SketchyBar, and Vicinae files take precedence over branch snapshots.

## Decisions

- Preserve branch behavior and presence/absence rather than overwrite every
  machine with the Mac version. Identical files/bodies are shared. Larger
  differences select raw profile bodies, especially shell, tmux and Yazi.
- Mac Neovim now follows Ubuntu's newer configuration, excluding ClickHouse code
  and tests. X220 and Ubuntu output remain unchanged. Shared Ubuntu/Mac bodies
  are stored once; Mac-specific bodies adapt terminal integration and paths.
  Mac uses native vim-tmux-navigator Ctrl-h/j/k/l instead of an external Herdr
  script. Space-gg/y/jj launch lazygit/yazi/lazyjj in tmux windows, or Neovim
  terminal tabs outside tmux. Arguments use argv lists, not shell concatenation.
  Lazy bootstrap uses `<stdpath(data)>/lazy/lazy.nvim`; debugpy uses
  `<stdpath(data)>/mason/packages/debugpy/venv/bin/python`. Python provider prefers
  the existing data-home venv, falling back to python3 on PATH.
  Space-cv toggles CSV view without overriding Space-gf formatting; Space-dd uses
  DAP continue (run/select a config), not the argument-requiring `dap.run`.
  Removed the duplicate visit-label deletion mapping. Mac retains the Ubuntu
  completion, picker, CSV, snippets and preview behavior otherwise.
  `python3 docs/test-mac-nvim.py` checks Lua compilation and exercises these paths
  and bindings in isolated headless Neovim with plugin services mocked; it does
  not install plugins or claim full third-party plugin runtime coverage.
- macOS: Karabiner, Borders, Rift, SketchyBar and Homebrew/OrbStack integration
  stay in the Mac profile. Vicinae has separate Mac and Ubuntu configurations.
- Ubuntu: preserve Herdr, o-tiling, Wofi, direnv and desktop helpers, along with
  newer Neovim custom ClickHouse plugins/tests. Do not deploy these to X220.
- X220: preserve X11 startup, Dunst/Picom, Newsboat, xclip tmux behavior and
  statusbar scripts (some are Arch-specific). Do not deploy these to Ubuntu.
- Helpers are executable even where the old Git mode omitted the executable bit.
- Do not import runtime state, Karabiner backups, downloaded binaries, `.gitignore`
  files, or local chezmoi config/database files.
- Correct stale tmux reload and shell alias paths to use `~/.config`, and Herdr's
  helper path to use `~/.local/bin`, without relying on the old checkout.
- Render absolute `/Users/nsc`, `/home/nsc`, and `/home/n` prefixes using the
  destination home, including Sioyek database and wget history paths.
- Fix Linux Yazi's Excel opener to use `xdg-open` instead of macOS `open -a`.
- Correct PYTHONSTARTUP to the imported `.config/python/.pythonstartup` file.
- Keep missing optional Linux `~/.local/bin/env` from breaking zsh startup.
- Add minimal shell bootstrap shims: zsh must discover ZDOTDIR before it can read
  `~/.config/zsh`; X220's old root `.xprofile`/`.zprofile` were literal stale paths,
  not usable shell sources.

## Deliberately not automated

- `~/.config/keyd/default.conf` is a reference config only. keyd normally reads
  `/etc/keyd/default.conf`; review and install it there manually with privileges.
- Ubuntu's user camera service references `~/.local/bin/laptop-camera-bridge`,
  which is not tracked in any input branch. The unit is preserved but not enabled
  or started. Install its helper before enabling it.
- Package managers, TPM and Neovim plugin installation are not run. Existing
  branch configs still assume their programs/fonts/plugins are installed.
- The X220 profile preserves its existing startx-on-tty1 behavior and `.env`
  loading. Review these before applying on a different Linux machine.
- Optional work aliases/secrets remain local. No credentials or home directories
  were recursively imported. Tracked personal/work URLs are still present; review
  before publishing to a public remote.

## Cutover

Nothing has been applied to the live Mac. Back up selected symlinks first, then
apply a non-shell config and check the app before migrating shell startup.
`chezmoi apply` will replace managed directory symlinks with real directories;
`~/.dotfiles` is retained. An ignored file is unmanaged, not automatically removed:
when changing profiles on an existing machine, review any obsolete files manually.

Run `python3 docs/test-profiles.py` from the source repository to validate rendered
profiles. OS data overrides exercise Linux selection/rendering on this Mac; they
are not a substitute for application tests on the Linux machines.

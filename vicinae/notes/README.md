# Local Notes for Vicinae (macOS)

A native replacement for the Linux `dmenu-notes` workflow. Search Markdown
filenames/folders, open notes in Neovim/Ghostty, or create a note using a directory
picker and filename field. Notes are listed by modification time, newest first.
Cmd+N creates a note; Cmd+R refreshes the list. Hidden folders/files and symlinks
are skipped. Creation never overwrites an existing file. Blank names default to
`YYYY-MM-DD-wWW` (local date, ISO week), matching the original shell script.

## Install / update

Requires Vicinae 0.30.1, Node.js 22.18+ with npm, Ghostty, and Neovim installed at
`/opt/homebrew/bin/nvim` (Apple Silicon Homebrew).

```sh
cd ~/.local/share/chezmoi/vicinae/notes
npm ci
npm test
npm run test:bundle
npm run typecheck
npm run build
```

Keep the extension manifest CommonJS-compatible (do not add `"type": "module"`):
Vicinae emits CommonJS bundles. `test:bundle` checks the actual built command with
Node's module loader, stubbing only Vicinae-provided APIs; it does not test UI rendering.

The build installs into `~/.local/share/vicinae/extensions/local-notes`.
Restart Vicinae after the first build if Notes does not appear.

Search for **Notes** in Vicinae. Set **Local Notes → Notes Directory** in
Vicinae's extension settings to your Markdown folder. The default is
`~/work/notes`, like the Linux script; a missing folder is only created when you
save your first note. Do not point at a folder unless you want to create notes
there. Optionally assign the Notes command a global shortcut in Vicinae settings.

The source lives in the repository-only `vicinae/` directory (already excluded
from `chezmoi apply`). Installation is an explicit build, not a chezmoi hook.
No Linux script or existing Vicinae settings are modified.

Ghostty is launched with an argument array (not a shell command), so note paths
with spaces and quotes are safe. Note scanning does not search file contents.

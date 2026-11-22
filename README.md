# Dotfiles — one repository, three profiles

Active source: `~/.local/share/chezmoi`. No branch switching is required.

| Profile | OS | Baseline and desktop |
| --- | --- | --- |
| `mac` | macOS | `main`; Karabiner, Rift, Borders, SketchyBar, macOS Ghostty bindings |
| `ubuntu26` | Linux | `ubuntu26`; Herdr, o-tiling, Wofi, direnv, Ubuntu zsh plugin paths |
| `x220` | Linux | `x220`; X11, Dunst, Picom, Newsboat, statusbar scripts, Arch zsh plugin paths |

Profiles preserve the original branch's file set. A config absent from that branch
is not silently inherited from another machine. Identical content is stored once;
files that differ use small `.tmpl` selectors and raw bodies in
`.chezmoitemplates/profiles/`. Shared Mac/Ubuntu bodies live in `profiles/core/`
(previously `mac-ubuntu26/`); btop, cliamp, Neovim bootstrap and visit helpers use
shared `.tmpl` bodies with small profile-specific sections. These are evaluated
with `includeTemplate`; other bodies remain literal includes. Mac Neovim follows Ubuntu (without ClickHouse),
with Mac-specific tmux bindings and corrected paths; X220's tree remains separate.
`.chezmoiignore` gates both OS and profile, including files unique to one Neovim tree.

## Initialize / review / apply

```sh
chezmoi init --promptString 'Machine profile (mac, x220, ubuntu26, or another name)=ubuntu26'
chezmoi diff
chezmoi apply --dry-run --verbose
# Back up existing symlinks before the actual cutover:
chezmoi apply
```

Alternatively, set `[data].profile` in the local chezmoi config. `mac` only deploys
on Darwin; `ubuntu26` and `x220` only deploy on Linux. Choose the matching profile.
Initialization does not apply files unless explicitly requested.

All application configs target `~/.config`. Executable helper scripts target
`~/.local/bin`. The only home-level configs are minimal `.zshenv` / `.zprofile`
startup shims and the X220 `.xprofile` shim: shells/session managers look for these
at fixed home paths. Their actual configuration remains under `~/.config`.

## Editing

```sh
chezmoi source-path ~/.config/ghostty/config
chezmoi edit ~/.config/ghostty/config
chezmoi diff
```

For a profile selector, edit the corresponding raw body under
`.chezmoitemplates/profiles/`, not the selector. Bodies are included literally (not
re-evaluated as Go templates, except shared `.tmpl` bodies in `core/`); old absolute home prefixes are replaced at render
time with the destination user's home. Run `chezmoi re-add` cautiously: it can
replace a profile selector with this machine's contents.

## Validation

```sh
python3 ~/.local/share/chezmoi/docs/test-profiles.py
python3 ~/.local/share/chezmoi/docs/test-mac-nvim.py
```

This renders all three OS/profile combinations without applying, verifies exact
file sets against `docs/profile-manifest.json`, checks shell syntax and script
permissions, and catches old home/repository paths and macOS Ghostty/Yazi commands
in Linux output. It requires `chezmoi`, Python 3.9+, and `zsh`.
These are rendering tests, not application runtime tests on Linux.

See [docs/MIGRATION.md](docs/MIGRATION.md) for comparison decisions and caveats.
Legacy `.config`, `.local`, root app folders, and bootstrap scripts are retained
as migration references; only the encoded `dot_config` / `dot_local` source is
used for deployment. Do not run the old symlink scripts after cutover.

No commits, pushes, package installation, or live application cutover have been
performed. The current remote is still the original dotfiles repository; review
all content before publishing.

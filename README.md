# Machine configurations — chezmoi

A new, single-branch home for migrating `~/.dotfiles`. Source state lives in
`~/.local/share/chezmoi`; the existing repository and live symlinks remain intact.
No configuration files have been imported or applied yet.

## Machine profiles

`chezmoi init` prompts for a profile and saves it in the local chezmoi config.
Use `mac` or `x220` for the existing machine configurations. A future `ubuntu26`
profile can be added once its configuration is available. The profile is
local data, not a Git branch. macOS defaults to `mac`; other systems default to
their hostname. Review the profile-to-application rules in `.chezmoiignore`.

```sh
chezmoi data
chezmoi execute-template '{{ .profile }}'
```

To change the profile, edit `[data].profile` in `chezmoi.toml` under
`chezmoi dump-config`'s configuration location (normally `~/.config/chezmoi/`).
Use `.chezmoi.os` for OS-specific settings and `.profile` for machine differences:

```gotemplate
{{ if eq .chezmoi.os "darwin" }}
# macOS settings
{{ end }}
{{ if eq .profile "x220" }}
# X220 settings
{{ end }}
```

## Migration

Follow [docs/MIGRATION.md](docs/MIGRATION.md). Use the active working files on the
Mac, not just the old `main` commit: the old repository has uncommitted changes
and new active configurations. Compare the Linux branches without checking them
out in the active repository.

## Daily use, after migration

```sh
chezmoi edit ~/.config/ghostty/config
chezmoi diff
chezmoi apply
# Capture changes made directly by an application:
chezmoi re-add ~/.config/ghostty/config
```

Review and commit source changes from `chezmoi cd`. Do not run the old
`~/.dotfiles/config.sh` after switching a config to chezmoi.

## Remote repository

This is currently a local Git repository on `main`, without a remote or commits.
Once reviewed, create a separate remote (for example `chezmoi`), preferably private,
and commit/push explicitly. Do not reuse the old `dotfiles` remote accidentally.
On another machine:

```sh
chezmoi init <new-repository-url>
chezmoi diff
chezmoi apply --dry-run --verbose
# Apply only after reviewing the proposed changes.
```

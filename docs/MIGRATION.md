# Migration checklist

## Safety boundaries

- Keep `~/.dotfiles` and its existing branches unchanged during migration.
- Import selected files, never all of `$HOME`, `~/.config`, or `~/.local/bin`.
- Leave self-managed directories such as `~/.config/pi` outside this repository.
- Do not import `.ssh`, `.gnupg`, credentials, tokens, application auth files,
  sessions, caches, logs, dependency directories, or downloaded binaries.
- `.chezmoiignore` controls deployment, not secrecy: ignored content can still
  be present in source state/Git. Inspect imports before publishing.
- Keep the new remote private initially. Review URLs, usernames, hostnames, and
  commands as well as obvious secret fields.
- Do not run `chezmoi apply` during preparation. It can replace existing symlinks
  with regular files. Back up those links before the actual cutover.

## 1. Import a small active configuration

The Mac's active configuration is the baseline. `--follow` imports a symlink's
contents rather than preserving a link into the old repository.

```sh
chezmoi add --follow ~/.config/ghostty/config
chezmoi managed
chezmoi status
chezmoi diff
chezmoi apply --dry-run --verbose
```

Then import other selected files incrementally. Inspect directories before
importing them recursively: zsh contains generated completion data; tmux can
contain plugins; Karabiner contains automatic backups. Import only source config.
Do not import unused configurations just because they exist in the old repo.

## 2. Compare the machine branches without switching the live checkout

The remote currently has only `main` and `x220`. The `arch` branch was deleted
remotely; local `arch` and `origin/arch` refs may still exist but are historical,
not migration targets. No `ubuntu26` branch is currently published. Confirm refs
are current before migration with `git -C ~/.dotfiles ls-remote --heads origin`.

```sh
git -C ~/.dotfiles diff main origin/x220 -- .config/shell .config/zsh .config/tmux
git -C ~/.dotfiles show origin/x220:.config/x11/xinitrc
```

Do not check out another branch inside `~/.dotfiles`: the live symlinks point
there. Use `git show` or a separate worktree to inspect another branch.

Known differences to review:

| Area | Migration strategy |
| --- | --- |
| Shell, zsh, tmux, yazi, terminals | Shared baseline with small OS/profile templates |
| Neovim | Substantial structural divergence; choose/consolidate deliberately |
| Aerospace, Karabiner | macOS only |
| Dunst, Picom, X11 | `x220` profile |
| keyd, systemd | Linux only; review system-level destinations separately |
| Scripts in `.local/bin` | Import reviewed source scripts, not downloaded executables |

The historical Arch branch contains `uv`/`uvx` binaries: do not import these if
consulting it for reference. Reinstall tools with a package manager. `keyd` normally needs
system configuration under `/etc`; chezmoi's default home destination does not
install system files automatically.

## 3. Introduce templates only for real differences

```sh
chezmoi chattr +template ~/.config/ghostty/config
chezmoi edit ~/.config/ghostty/config
```

Keep ordinary shared files untemplated. Use `.chezmoi.os` and `.profile` in
`.tmpl` files. For completely different implementations, keep separate bodies
under `.chezmoitemplates` and select the appropriate one from a target template.
Do not try to force the divergent Neovim trees into a single giant conditional.

## 4. Validate profiles without changing this machine

```sh
chezmoi --override-data '{"profile":"mac"}' managed
chezmoi --override-data '{"profile":"x220"}' managed
```

These commands test profile selection on the current OS, not another OS.
Validate Linux-specific output on Linux or in an isolated Linux environment.
Run `chezmoi diff` and `chezmoi apply --dry-run --verbose` before each cutover.

## 5. Cut over deliberately

1. Back up each selected live config/symlink and preserve the old Git worktree.
2. Apply only reviewed targets, starting with a non-shell config.
3. Check that the application still works before migrating shell startup files.
4. Review source state for secrets, then commit and push to the new remote.
5. Migrate the other machines and review their profile-specific diffs.
6. Remove old symlink-management scripts/repository only after every machine works.

# Dotfiles

Personal Arch / Omarchy setup, managed entirely with [mise](https://mise.jdx.dev):
dotfiles, system packages, CLI tools, repos and services all come from
`mise/config.toml`.

## Bootstrap a fresh machine

Omarchy ships mise, yay, git and tmux, so nothing needs installing first.
(On plain Arch: `sudo pacman -S mise git base-devel`, plus yay from the AUR.)

1. Restore the SSH key to `~/.ssh/`. The vault repo is private and cloned
   over SSH. No key yet? Add `--skip repos` to the command below and rerun
   `mise bootstrap` once the key is in place.

2. Run:

   ```sh
   mise bootstrap --from https://github.com/mrlorentx/dotfiles.git \
     --from-dir ~/dotfiles --config-dir mise
   ```

   This clones the repo to `~/dotfiles`, links `~/.config/mise` to
   `~/dotfiles/mise`, and then applies everything: packages, repos,
   dotfiles, tools, the vault backup timer.

3. Open 1Password, sign in, and enable
   Settings → Developer → Integrate with 1Password CLI. The next new shell
   then materializes the secrets.

4. Run `gh auth login`, then `mise bootstrap` again to install the gh
   extensions.

5. To push changes from the new machine, switch the clone to SSH:
   `git -C ~/dotfiles remote set-url origin git@github.com:mrlorentx/dotfiles.git`

## Layout

```
home/                 mirrors $HOME; every file is symlinked into place
  .bashrc  .aliases.sh
  .claude/skills/     Claude Code skills
  .config/            hypr, nvim, tmux, alacritty, foot, omarchy, zsh
  .local/bin/         personal scripts
mise/config.toml      the global mise config (~/.config/mise links here)
keymaps/              Iris keyboard firmware keymap (stored, not deployed)
```

## What mise manages

All of it is declared in `mise/config.toml`:

- `[dotfile_groups.home]` symlinks each file under `home/` into `$HOME`.
  `mode = "absent"` entries remove leftovers from older setups.
- `[bootstrap.packages]` installs `pacman:` and `aur:` packages on top of
  the Omarchy baseline.
- `[bootstrap.repos]` clones the vault and the tmux plugin manager.
- `[bootstrap.linux.systemd.units]` defines the vault backup service and
  its 3-minute timer.
- `[bootstrap.hooks]` installs tmux plugins and gh extensions, and enables
  linger. Hooks run on every bootstrap.
- `[tools]` lists CLI tools and language runtimes.

## Everyday use

```sh
mise bootstrap status      # what differs from the config
mise bootstrap             # apply everything (safe to rerun)
mise bootstrap --dry-run   # preview

mise dot status            # dotfiles only
mise dot apply             # link new files added under home/
```

- **Edit a dotfile:** edit it in place. It is a symlink into this repo, so
  the change shows up in `git status` here. Commit and push.
- **Add a dotfile:** `mise dot add --group home ~/.config/foo/bar.toml`,
  or create it under `home/` and run `mise dot apply`.
- **Add a tool:** `mise use -g <tool>`, or edit `[tools]` and run
  `mise install`.
- **Add a system package:** add a `"pacman:<name>"` or `"aur:<name>"` line
  under `[bootstrap.packages]` and run `mise bootstrap packages apply`.
  Deleting an `aur:` line does not uninstall the package.
- **Update another machine:** `git -C ~/dotfiles pull && mise bootstrap`.

System upgrades stay with Omarchy (`pacman -Syu`); mise does not do them.

## Secrets

The schema lives in git at `home/.config/zsh/secrets-in.zsh` as
`op://vault/item/field` references. On the first shell of a new machine,
`secrets-sourcer.zsh` runs `op inject` once to materialize the values into
`~/.cache/zsh/secrets.zsh`. Later shells just source the cached file.

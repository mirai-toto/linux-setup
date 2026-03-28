# linux-setup

Linux system provisioner — sets up a fresh machine and bootstraps [dotfiles](https://github.com/mirai-toto/dotfiles).

This repo handles everything that requires distro-level knowledge, leaving the dotfiles repo focused purely on configuration.

This repo sets up:

- 🐧 **Distro dependencies** — build tools and locale per distro
- 🍺 **Homebrew + dotfiles** — delegates to `dotfiles/install.sh`
- 🦀 **Rust** — toolchain via rustup
- 📦 **npm globals** — commitlint
- 🪟 **Windows Terminal** — auto-configured when running under WSL

---

## 🚀 Usage

### First install

```bash
git clone https://github.com/mirai-toto/linux-setup.git ~/linux-setup
cd ~/linux-setup
./install.sh
```

`install.sh` does the following:

1. Detects the distro and installs build dependencies
2. Configures locale (`en_US.UTF-8`)
3. Clones [dotfiles](https://github.com/mirai-toto/dotfiles) to `~/dotfiles` and runs its `install.sh`
4. Installs Rust toolchain via rustup
5. Installs npm global packages
6. **(WSL only)** Installs and configures Windows Terminal via [wt-settings](https://github.com/mirai-toto/wt-settings)

After install, restart your terminal or run `exec zsh`.

---

## 🐧 Supported distros

| Distro | Script |
| ------ | ------ |
| Debian / Ubuntu | `distro/debian/setup.sh` |
| Fedora / RHEL | `distro/fedora/setup.sh` |

Distro detection reads `/etc/os-release`. If your distro is not recognized, distro-specific steps are skipped with a warning and the rest of the install continues.

---

## 🐳 Test in a container

Each distro has its own Dockerfile for isolated testing:

```bash
./test-install.sh          # defaults to debian
./test-install.sh debian
./test-install.sh fedora
```

This builds the image for the target distro and drops you into an interactive shell after `install.sh` completes.

---

## 🪟 Windows Terminal

Auto-configured during install when running under WSL, via [wt-settings](https://github.com/mirai-toto/wt-settings). Color scheme files live in `themes/`.

---

## ⚠️ After install checklist

These files are created by `dotfiles/install.sh` with empty values — don't forget to fill them in:

| File | What to fill in |
| ---- | --------------- |
| `~/.gitconfig.local` | `name` and `email` for git commits |
| `~/.secrets` | API keys and other secrets |

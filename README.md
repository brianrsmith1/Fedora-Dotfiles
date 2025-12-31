# Brian Smith's Fedora 43 personal Developer Setup

![Fedora Logo](https://upload.wikimedia.org/wikipedia/commons/3/3f/Fedora_logo.svg)

 Overview

This repository is my personal Fedora setup. It’s designed for speed, productivity, and terminal efficiency — a quick way to get a developer-ready system.

# Fedora Dotfiles & Dev Installer

A focused collection of dotfiles and an opinionated installer script to provision a Fedora (or RHEL-family) development workstation. This repository automates common developer tooling, shell configuration, and multimedia/productivity apps so you can get a reproducible environment quickly.

This project is maintained by Brian R. Smith.

---

## Table of Contents

- [Highlights](#highlights)
- [Supported Platform](#supported-platform)
- [What the Installer Does](#what-the-installer-does)
- [Quickstart — Run the Installer](#quickstart---run-the-installer)
- [Install Options (what you can choose)](#install-options-what-you-can-choose)
- [Configuration & Dotfiles](#configuration--dotfiles)
- [Security & Safety Notes](#security--safety-notes)
- [Testing Recommendations](#testing-recommendations)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgements](#acknowledgements)
- [Contact](#contact)

---

## Highlights

- Single interactive Bash installer: `install.sh`
- Installs core development tools (git, neovim, gcc, rustup, nodejs, go, java, podman, etc.)
- Shell setup (zsh + Oh My Zsh + Powerlevel10k) with recommended plugins:
  - zsh-autosuggestions
  - zsh-syntax-highlighting
- Installs popular productivity & creative apps (VS Code, Kdenlive, OBS Studio, Blender, GIMP, Inkscape, Krita)
- Supports installations via DNF and Flatpak (Flathub), enables RPM Fusion where appropriate
- Opinionated, reproducible, non-destructive: attempts to be safe and idempotent when possible

---

## Supported Platform

This repository and its installer target Fedora and RHEL-family distributions where `dnf` is available.

Minimum requirements
- Fedora / RHEL-based Linux (dnf present)
- A user with sudo privileges
- Network connectivity to download packages

---

## What the Installer Does

The installer provides modular tasks that you can run individually or all at once. Major categories include:

- Core developer packages: git, curl, wget, neovim, tmux, compilers, language toolchains, container tooling, AWS CLI, GitHub CLI, etc.
- Shell and dotfiles: zsh, Oh My Zsh, powerlevel10k theme, zsh-autosuggestions, zsh-syntax-highlighting
- Multimedia & creative apps: kdenlive, obs-studio, blender, gimp, krita, inkscape (via DNF and/or Flatpak)
- IDE/editor: Visual Studio Code (DNF repo or Flatpak fallback)
- Flatpak/Flathub setup and installs
- Container & Kubernetes tooling: podman, buildah, skopeo, kubectl, minikube, helm
- Misc productivity tools: VLC, HandBrake, KeepassXC, Signal, neofetch, imagemagick, etc.

The script attempts to avoid unsafe changes (for example, it does not automatically change your login shell) and will copy local dotfile templates where present in the repository.

---

## Quickstart — Run the Installer

Important: Review the script before running it. It's recommended to test in a VM or disposable environment first.

1. Download or clone the repository

   - Clone (recommended if you plan to edit/commit):
     ```
     git clone https://github.com/brianrsmith1/Fedora-Dotfiles.git
     cd Fedora-Dotfiles
     ```

   - Download a single file:
     ```
     curl -Lo install.sh https://raw.githubusercontent.com/brianrsmith1/Fedora-Dotfiles/39a37ddb2d9abcd0026fe59c47fb26dace523b56/install.sh
     ```

2. Make the installer executable and run it:
   ```
   chmod +x install.sh
   ./install.sh
   ```

3. Follow the interactive menu to select what you want installed (or choose "Install Everything").

---

## Install Options (what you can choose)

When you run the installer you'll see a menu with options such as:

- Essential Packages (core dev tools)
- Zsh + Powerlevel10k (includes zsh-autosuggestions & zsh-syntax-highlighting)
- Neovim (and copy repo config if present)
- Tmux (and copy repo config if present)
- Flatpak Apps (Flathub + VS Code)
- Multimedia & Creative Apps (Kdenlive, OBS, Blender, GIMP, Inkscape, Krita)
- Container & K8s Tools (podman, kubectl, minikube, helm)
- Productivity & Design Tools
- Install Everything (runs all the above)

---

## Configuration & Dotfiles

- Shell config (Oh My Zsh) is installed to `~/.oh-my-zsh` and the script will write/modify `~/.zshrc` to:
  - Use `powerlevel10k` theme
  - Add `git`, `zsh-autosuggestions`, and `zsh-syntax-highlighting` plugins
  - Source `zsh-syntax-highlighting` last to avoid plugin ordering issues

- Neovim configuration: if `nvim/init.vim` exists in repository it will be copied to `~/.config/nvim/init.vim`.

- Tmux configuration: if `tmux/.tmux.conf` exists in repository it will be copied to `~/.tmux.conf`.

Feel free to customize these files in the repo and re-run parts of the installer or copy the files manually.

---

## Security & Safety Notes

- The script runs package managers with `sudo`. Always inspect scripts you run with elevated privileges.
- The installer may add third-party repositories (e.g., Microsoft VS Code repo) and enable RPM Fusion. Only proceed if you accept those sources.
- Flatpak apps are installed from Flathub by default — verify the applications you install via Flatpak if you have special security requirements.
- The script is idempotent where possible but may alter configuration files (e.g., append plugin entries to `~/.zshrc`). Back up your existing configuration before running.

---

## Testing Recommendations

- Use a disposable Fedora VM or container (e.g., a Fedora cloud image, Podman/VirtualBox/Libvirt) to validate the installer and its side effects before running on a production workstation.
- Run selective options first (e.g., "Zsh + Powerlevel10k") to confirm shell behavior before "Install Everything".

---

## Troubleshooting

- If `dnf` reports dependency or repository errors, ensure you have correct Fedora version metadata and network connectivity.
- If a Flatpak fails, run the installation command manually to view detailed output:
  ```
  sudo flatpak install -y flathub org.blender.Blender
  ```
- If zsh plugins do not activate:
  - Ensure `~/.oh-my-zsh/custom/plugins/<plugin>` exists.
  - Ensure `plugins=(... zsh-syntax-highlighting)` is present in `~/.zshrc`.
  - Confirm the sourcing block for zsh-syntax-highlighting exists and is the last thing that sources plugins.

---

## Acknowledgements

- Oh My Zsh — https://github.com/ohmyzsh/ohmyzsh
- Powerlevel10k — https://github.com/romkatv/powerlevel10k
- zsh-autosuggestions — https://github.com/zsh-users/zsh-autosuggestions
- zsh-syntax-highlighting — https://github.com/zsh-users/zsh-syntax-highlighting
- Fedora, RPM Fusion, Flathub and many upstream package maintainers

---

## Contact

For questions, suggestions, or issues, please open an issue in this repository or contact brianrsmith1 on GitHub.

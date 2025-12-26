# Brian Smith's Fedora 43 personal Developer Setup

![Fedora Logo](https://upload.wikimedia.org/wikipedia/commons/3/3f/Fedora_logo.svg)

 Overview

This repository is my personal Fedora setup. It’s designed for speed, productivity, and terminal efficiency — a quick way to get a developer-ready system.

 Key Features

| Category | Description | Config / Install Location |
|-----------|--------------|----------------------------|
| **Essential Packages** | Core CLI tools (`git`, `zsh`, `curl`, `vim`, etc.) | Installed system-wide via `dnf` |
| **Flatpak Apps** | Sandbox-isolated desktop apps | `/var/lib/flatpak` (system) / `$HOME/.local/share/flatpak` (user) |
| **Zsh + Powerlevel10k** | Modern shell with rich prompt and customization | `$HOME/.zshrc`, `$HOME/.p10k.zsh` |
| **Neovim Config** | Developer-optimized configuration for Neovim | `$HOME/.config/nvim/init.vim` |
| **Tmux Config** | Pre-configured terminal multiplexer | `$HOME/.tmux.conf` |
| **Extras & CLI Tools** | `fzf`, `ripgrep`, `bat`, `htop`, `fd-find` | Installed system-wide via `dnf` |


##  File Structure & Config Paths

| File / Directory | Purpose |
|------------------|----------|
| `install.sh` | Main interactive installer script |
| `README.md` | Documentation and setup guide |
| `$HOME/.zshrc` | Zsh configuration |
| `$HOME/.p10k.zsh` | Powerlevel10k theme configuration |
| `$HOME/.config/nvim/` | Neovim configuration directory |
| `$HOME/.tmux.conf` | Tmux configuration file |

##  Notes & Recommendations

- You can rerun the installer anytime to add or update components.  
- The "Install Everything" option installs all available components and then exits.  
- Designed for Fedora 43.
- After the installation is complete you may be required to manually paste the .zshrc code into the config structure due to p10k do so by using the directory cd ~/.zshrc and pasting the code accordingly.
- If fastfetch does not pop up automatically on a new terminal startup try these fixes | source ~/.zshrc | chsh -s $(which zsh) | chsh -s /usr/bin/zsh | echo $SHELL | This should output /usr/bin/zsh or /bin/zsh.
    
## ⚙️ Installation & Setup Guidechsh 

Follow these steps to install and configure your Fedora 43 development environment.

 Step 1: Clone the Repository

```bash
git clone https://github.com/brianrsmith1/Fedora-Dotfiles.git
cd Fedora-Dotfiles
```

 Step 2: Make the Installer Executable

```bash
chmod +x install.sh
```

 Step 3: Run the Installer

```bash
./install.sh
```

After launching, the interactive setup menu presents six options:

=======================================
 Brian Smith's Dev Installer
=======================================
Select what to install:
  1) Essential Packages
  2) Zsh + Powerlevel10k
  3) Neovim Config
  4) Tmux Config
  5) Flatpak Apps
  6) Install Everything
=======================================

Choose the number for the component you want to install. To exit the installer at any time, press Ctrl+C.


 After-Installation Configuration

Powerlevel10k Setup

After installation, start a new terminal and launch Zsh:

```bash
zsh
p10k configure
```

This opens the Powerlevel10k configuration wizard so you can personalize the prompt.

 After Installation

Once setup completes, your Fedora system will include:

- A Zsh shell with Powerlevel10k and autosuggestions
- A Neovim configuration optimized for coding productivity
- A pre-configured Tmux setup
- Selected Flatpak desktop apps

License: MIT

#!/usr/bin/env bash
set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# Resolve script dir for copying local dotfiles/configs
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${MAGENTA}${BOLD}
 ____  _       _               ____  _ _       _
| __ )| | ___ | |_ ___  ___   / ___|| (_) __ _| | ___
|  _ \| |/ _ \| __/ _ \/ __|  \___ \| | |/ _\` | |/ _ \
| |_) | | (_) | ||  __/\__ \   ___) | | | (_| | |  __/
|____/|_|\___/ \__\___||___/  |____/|_|_|\__, |_|\___|
                                         |___/
${NC}"

echo -e "${CYAN}${BOLD}Brian Smith's Fedora Dev Installer (Updated)${NC}\n"

# Basic environment checks
if ! command -v dnf &>/dev/null; then
    echo -e "${YELLOW}dnf not found. This installer targets Fedora / RHEL-based systems.${NC}"
    exit 1
fi

if ! command -v sudo &>/dev/null; then
    echo -e "${YELLOW}sudo not found. Install sudo or run as root.${NC}"
    exit 1
fi

DNF_INSTALL="sudo dnf install -y --setopt=install_weak_deps=False"

# Install a package if its command is missing or if package name differs from command
install_if_missing() {
    local cmd="$1"
    local pkg="${2:-$1}"

    if command -v "$cmd" &>/dev/null; then
        echo -e "${CYAN}$cmd already installed.${NC}"
        return 0
    fi

    echo -e "${CYAN}Installing $pkg...${NC}"
    if $DNF_INSTALL "$pkg"; then
        echo -e "${GREEN}$pkg installed.${NC}"
        return 0
    else
        echo -e "${YELLOW}Failed to install $pkg via dnf. Continuing...${NC}"
        return 1
    fi
}

install_packages() {
    local -n pkgs=$1
    for p in "${pkgs[@]}"; do
        # If package has ":" we treat as "cmd:pkg"
        if [[ "$p" == *:* ]]; then
            cmd="${p%%:*}"
            pkg="${p#*:}"
        else
            cmd="$p"
            pkg="$p"
        fi
        install_if_missing "$cmd" "$pkg" || true
    done
}

enable_rpmfusion() {
    echo -e "${GREEN}${BOLD}Enabling RPM Fusion (free + nonfree)...${NC}"
    # Use rpm -E %fedora to get fedora version
    sudo dnf install -y "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
        "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" || true
}

install_vscode_repo() {
    echo -e "${GREEN}${BOLD}Adding Microsoft VS Code repo (optional)${NC}"
    # Add repo and import key, then install code if possible. If this fails we fallback to flatpak.
    if [ ! -f /etc/yum.repos.d/vscode.repo ]; then
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc || true
        sudo tee /etc/yum.repos.d/vscode.repo > /dev/null <<'EOF'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
    fi

    # Try to install code
    $DNF_INSTALL code || echo -e "${YELLOW}Could not install 'code' via dnf. You can still install VS Code via Flatpak.${NC}"
}

install_essentials() {
    echo -e "${GREEN}${BOLD}Installing core developer essentials...${NC}"

    local core_packages=(
        git
        curl
        wget
        vim
        neovim
        tmux
        zsh
        htop
        ripgrep
        fd-find
        fzf
        bat
        fastfetch
        gcc
        gcc-c++
        make
        unzip
        tar
        jq
        which
        openssh-clients
        openssh-server
        rsync
        xz
        file
        lsof
        libffi-devel
        bzip2
        bzip2-devel
        python3
        python3-pip
        python3-virtualenv
        python3-venv
        nodejs
        npm
        golang
        java-17-openjdk-devel
        podman
        buildah
        skopeo
        podman-docker
        awscli
        gh
    )

    install_packages core_packages

    # Rust via rustup (recommended)
    if ! command -v rustc &>/dev/null; then
        echo -e "${CYAN}Installing Rust (rustup)...${NC}"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || true
        export PATH="$HOME/.cargo/bin:$PATH"
    fi

    # Python pipx (for user-level CLI tools)
    if ! command -v pipx &>/dev/null; then
        echo -e "${CYAN}Installing pipx...${NC}"
        python3 -m pip install --user pipx || true
        python3 -m pipx ensurepath || true
        export PATH="$HOME/.local/bin:$PATH"
    fi

    # Lazygit install via dnf if available, otherwise try pipx or skip
    install_if_missing lazygit lazygit || (pipx install lazygit && true) || true

    # Configure git safe defaults if not set (non-interactive)
    if ! git config --global user.name &>/dev/null; then
        git config --global init.defaultBranch main || true
    fi

    echo -e "${GREEN}Core packages installed.${NC}"
}

install_zsh() {
    echo -e "${GREEN}${BOLD}Installing Zsh + Oh My Zsh + Powerlevel10k + plugins...${NC}"

    install_if_missing zsh zsh

    # Install oh-my-zsh unattended
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        export RUNZSH=no CHSH=no KEEP_ZSHRC=yes
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true
    fi

    mkdir -p "$HOME/.oh-my-zsh/custom/plugins"
    mkdir -p "$HOME/.oh-my-zsh/custom/themes"

    # zsh-autosuggestions
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" || true
    fi

    # zsh-syntax-highlighting (added)
    if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
            "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" || true
    fi

    # powerlevel10k theme
    if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
            "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" || true
    fi

    if [ ! -f "$HOME/.zshrc" ]; then
        cat > "$HOME/.zshrc" <<'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# Ensure zsh-syntax-highlighting is sourced last if plugin loading doesn't work
if [ -f "${ZSH}/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "${ZSH}/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
EOF
    else
        # Set theme if possible
        if grep -q "^ZSH_THEME=" "$HOME/.zshrc"; then
            sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME/.zshrc" || true
        else
            echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$HOME/.zshrc"
        fi

        # Ensure plugins line exists and includes autosuggestions and syntax-highlighting
        if grep -q "^plugins=" "$HOME/.zshrc"; then
            # add zsh-autosuggestions if missing
            if ! grep -q "zsh-autosuggestions" "$HOME/.zshrc"; then
                sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions)/' "$HOME/.zshrc" || true
            fi
            # add zsh-syntax-highlighting if missing
            if ! grep -q "zsh-syntax-highlighting" "$HOME/.zshrc"; then
                sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-syntax-highlighting)/' "$HOME/.zshrc" || true
            fi
        else
            echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' >> "$HOME/.zshrc"
        fi

        # Ensure zsh-syntax-highlighting is sourced at the end (recommended)
        if ! grep -q "zsh-syntax-highlighting.zsh" "$HOME/.zshrc"; then
            cat >> "$HOME/.zshrc" <<'EOF'

# Source zsh-syntax-highlighting last to ensure it works reliably
if [ -f "${ZSH}/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "${ZSH}/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
EOF
        fi
    fi
}

install_neovim_config() {
    echo -e "${GREEN}${BOLD}Installing Neovim and copying config if present...${NC}"
    install_if_missing nvim neovim
    mkdir -p "$HOME/.config/nvim"
    if [ -f "$SCRIPT_DIR/nvim/init.vim" ]; then
        cp "$SCRIPT_DIR/nvim/init.vim" "$HOME/.config/nvim/init.vim"
    fi
}

install_tmux_config() {
    echo -e "${GREEN}${BOLD}Installing Tmux and copying config if present...${NC}"
    install_if_missing tmux tmux
    if [ -f "$SCRIPT_DIR/tmux/.tmux.conf" ]; then
        cp "$SCRIPT_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
    fi
}

install_multimedia_apps() {
    echo -e "${GREEN}${BOLD}Installing multimedia / creative apps (kdenlive, obs, blender, gimp, inkscape, krita)...${NC}"

    # Enable RPM Fusion for obs/dx support
    enable_rpmfusion

    # Try to install obs-studio and kdenlive via dnf first (better integration)
    if ! install_if_missing obs-studio obs-studio; then
        echo -e "${YELLOW}obs-studio not available or failed via dnf; will attempt Flatpak as fallback.${NC}"
    fi

    install_if_missing kdenlive kdenlive || true
    install_if_missing blender blender || true
    install_if_missing gimp gimp || true
    install_if_missing inkscape inkscape || true
    install_if_missing krita krita || true

    # Flatpaks for apps where newer versions are preferred
    if command -v flatpak &>/dev/null; then
        local flatpaks=(
            com.visualstudio.code
            org.kde.kdenlive
            com.obsproject.Studio
            org.blender.Blender
            org.gimp.GIMP
            org.inkscape.Inkscape
            org.kde.krita
            com.spotify.Client
        )

        for app in "${flatpaks[@]}"; do
            echo -e "${CYAN}Installing Flatpak: $app${NC}"
            sudo flatpak install -y flathub "$app" || true
        done
    else
        echo -e "${YELLOW}flatpak not installed; skipping Flatpak installs.${NC}"
    fi
}

install_flatpaks() {
    echo -e "${GREEN}${BOLD}Installing Flatpaks (Flathub content)...${NC}"

    install_if_missing flatpak flatpak

    sudo flatpak remote-add --if-not-exists flathub \
        https://flathub.org/repo/flathub.flatpakrepo || true

    local flatpaks=(
        com.visualstudio.code
        com.spotify.Client
        org.kde.kdenlive
        com.obsproject.Studio
        org.blender.Blender
        org.gimp.GIMP
        org.inkscape.Inkscape
        org.kde.krita
    )

    for app in "${flatpaks[@]}"; do
        sudo flatpak install -y flathub "$app" || true
    done
}

install_container_tools() {
    echo -e "${GREEN}${BOLD}Installing container & kubernetes tooling (podman, kubectl, minikube, helm)...${NC}"
    install_if_missing podman podman
    install_if_missing buildah buildah
    install_if_missing skopeo skopeo
    install_if_missing kubectl kubectl || install_if_missing kubectl kubernetes-client || true
    install_if_missing helm helm || true

    # minikube might not be in dnf; try to install via curl if missing
    if ! command -v minikube &>/dev/null; then
        echo -e "${CYAN}Installing minikube...${NC}"
        curl -Lo /tmp/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 || true
        sudo install /tmp/minikube /usr/local/bin/minikube || true
        rm -f /tmp/minikube
    fi
}

install_productivity_tools() {
    echo -e "${GREEN}${BOLD}Installing productivity / design / misc tools...${NC}"
    local misc=(
        vlc
        handbrake
        flatpak # ensure flatpak present for these
        neofetch
        exa
        sxiv
        imagemagick
        keepassxc
        torbrowser-launcher
        signal-desktop
    )
    install_packages misc || true
}

install_vscode_flatpak_or_repo() {
    # Try to add repo and install code via dnf for best integration; fallback to flatpak if that fails.
    install_vscode_repo
    if ! command -v code &>/dev/null; then
        echo -e "${CYAN}Attempting to install VS Code via dnf...${NC}"
        if $DNF_INSTALL code; then
            echo -e "${GREEN}VS Code installed via dnf.${NC}"
            return 0
        fi
    fi

    echo -e "${YELLOW}Falling back to Flatpak install for VS Code.${NC}"
    sudo flatpak install -y flathub com.visualstudio.code || true
}

# Options menu
options=(
    "Essential Packages (core dev tools)"
    "Zsh + Powerlevel10k"
    "Neovim (and copy config)"
    "Tmux (and copy config)"
    "Flatpak Apps (Flathub + VS Code)"
    "Multimedia & Creative Apps (kdenlive, obs, blender, gimp, inkscape, krita)"
    "Container & K8s Tools (podman, kubectl, minikube, helm)"
    "Productivity & Design Tools"
    "Install Everything (recommended)"
    "Quit"
)

while true; do
    echo -e "${BOLD}${CYAN}Choose an option:${NC}\n"
    select opt in "${options[@]}"; do
        case $REPLY in
            1)
                install_essentials
                break
                ;;
            2)
                install_zsh
                break
                ;;
            3)
                install_neovim_config
                break
                ;;
            4)
                install_tmux_config
                break
                ;;
            5)
                install_flatpaks
                install_vscode_flatpak_or_repo
                break
                ;;
            6)
                install_multimedia_apps
                break
                ;;
            7)
                install_container_tools
                break
                ;;
            8)
                install_productivity_tools
                break
                ;;
            9)
                install_essentials
                install_zsh
                install_neovim_config
                install_tmux_config
                install_flatpaks
                install_multimedia_apps
                install_container_tools
                install_productivity_tools
                echo -e "${GREEN}${BOLD}✔ Setup complete${NC}"
                exit 0
                ;;
            10)
                exit 0
                ;;
            *)
                echo -e "${YELLOW}Invalid option${NC}"
                break
                ;;
        esac
    done
done

#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${MAGENTA}${BOLD}
 ____  _       _               ____  _ _       _
| __ )| | ___ | |_ ___  ___   / ___|| (_) __ _| | ___
|  _ \| |/ _ \| __/ _ \/ __|  \___ \| | |/ _\` | |/ _ \
| |_) | | (_) | ||  __/\__ \   ___) | | | (_| | |  __/
|____/|_|\___/ \__\___||___/  |____/|_|_|\__, |_|\___|
                                         |___/
${NC}"

echo -e "${CYAN}${BOLD}Brian Smith's Fedora Dev Installer (stable)${NC}\n"

# Fedora check
if ! command -v dnf &>/dev/null; then
    echo -e "${YELLOW}dnf not found. Fedora/RHEL-based system required.${NC}"
    exit 1
fi

if ! command -v sudo &>/dev/null; then
    echo -e "${YELLOW}sudo not found. Install sudo or run as root.${NC}"
    exit 1
fi

DNF_INSTALL="sudo dnf install -y --setopt=install_weak_deps=False"

install_if_missing() {
    local cmd="$1"
    local pkg="$2"

    if command -v "$cmd" &>/dev/null; then
        echo -e "${CYAN}$cmd already installed.${NC}"
        return
    fi

    echo -e "${CYAN}Installing $pkg...${NC}"
    $DNF_INSTALL "$pkg" || echo -e "${YELLOW}Failed to install $pkg${NC}"
}

install_essentials() {
    echo -e "${GREEN}${BOLD}Installing essentials...${NC}"

    install_if_missing git git
    install_if_missing curl curl
    install_if_missing wget wget
    install_if_missing vim vim
    install_if_missing tmux tmux
    install_if_missing zsh zsh
    install_if_missing htop htop
    install_if_missing rg ripgrep
    install_if_missing fd fd-find
    install_if_missing fzf fzf
    install_if_missing bat bat
    install_if_missing fastfetch fastfetch

    # build / archive essentials
    $DNF_INSTALL gcc gcc-c++ make unzip tar || true
}

install_zsh() {
    echo -e "${GREEN}${BOLD}Installing Zsh + Oh My Zsh + Powerlevel10k...${NC}"

    install_if_missing zsh zsh

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        export RUNZSH=no CHSH=no KEEP_ZSHRC=yes
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true
    fi

    mkdir -p "$HOME/.oh-my-zsh/custom/plugins"
    mkdir -p "$HOME/.oh-my-zsh/custom/themes"

    [ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ] || \
        git clone https://github.com/zsh-users/zsh-autosuggestions \
        "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"

    [ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ] || \
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
        "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"

    if [ ! -f "$HOME/.zshrc" ]; then
        cat > "$HOME/.zshrc" <<'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions)
source $ZSH/oh-my-zsh.sh
EOF
    else
        sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME/.zshrc" || true
    fi
}

install_nvim() {
    echo -e "${GREEN}${BOLD}Installing Neovim...${NC}"
    install_if_missing nvim neovim
    mkdir -p "$HOME/.config/nvim"
    [ -f ./nvim/init.vim ] && cp ./nvim/init.vim "$HOME/.config/nvim/init.vim"
}

install_tmux() {
    echo -e "${GREEN}${BOLD}Installing Tmux config...${NC}"
    install_if_missing tmux tmux
    [ -f ./tmux/.tmux.conf ] && cp ./tmux/.tmux.conf "$HOME/.tmux.conf"
}

install_flatpaks() {
    echo -e "${GREEN}${BOLD}Installing Flatpaks...${NC}"

    install_if_missing flatpak flatpak

    sudo flatpak remote-add --if-not-exists flathub \
        https://flathub.org/repo/flathub.flatpakrepo

    sudo flatpak install -y flathub \
        com.visualstudio.code \
        com.spotify.Client || true
}

options=(
    "Essential Packages (incl. fastfetch)"
    "Zsh + Powerlevel10k"
    "Neovim"
    "Tmux"
    "Flatpak Apps"
    "Install Everything"
    "Quit"
)

while true; do
    echo -e "${BOLD}${CYAN}Choose an option:${NC}\n"
    select opt in "${options[@]}"; do
        case $REPLY in
            1) install_essentials; break ;;
            2) install_zsh; break ;;
            3) install_nvim; break ;;
            4) install_tmux; break ;;
            5) install_flatpaks; break ;;
            6)
                install_essentials
                install_zsh
                install_nvim
                install_tmux
                install_flatpaks
                echo -e "${GREEN}${BOLD}✔ Setup complete${NC}"
                exit 0
                ;;
            7) exit 0 ;;
            *) echo -e "${YELLOW}Invalid option${NC}"; break ;;
        esac
    done
done
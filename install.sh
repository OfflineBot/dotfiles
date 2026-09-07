#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

packages=(
    hyprland hyprlock niri quickshell awww xwayland-satellite
    kitty fish tmux neovim micro btop fastfetch zathura
    mako nwg-look grim slurp wl-clipboard wl-clip-persist cliphist
    fzf fd ripgrep bat eza zoxide jq playerctl cowsay libnotify
    wireguard-tools ttf-firacode-nerd firefox nautilus pavucontrol
    flatpak spotify-launcher vesktop-bin spicetify-cli
    catppuccin-gtk-theme-mocha catppuccin-cursors-mocha
)

ask() {
    local reply
    read -rp "$1 [y/N] " reply
    [[ ${reply,,} == y* ]]
}

if ! command -v pacman >/dev/null; then
    echo "no pacman found, this is for arch" >&2
    exit 1
fi

if ! command -v stow >/dev/null; then
    if ask "stow is missing, install it?"; then
        sudo pacman -S --needed stow
    else
        echo "nothing works without stow, bye"
        exit 1
    fi
fi

if ask "link configs into \$HOME with stow?"; then
    stow -t "$HOME" .
    echo "linked"
fi

repo_pkgs=()
aur_pkgs=()
for pkg in "${packages[@]}"; do
    if pacman -Si "$pkg" >/dev/null 2>&1; then
        repo_pkgs+=("$pkg")
    else
        aur_pkgs+=("$pkg")
    fi
done

if ask "install ${#repo_pkgs[@]} packages with pacman?"; then
    sudo pacman -S --needed "${repo_pkgs[@]}" || true
fi

if ((${#aur_pkgs[@]})); then
    if command -v paru >/dev/null; then
        if ask "install from aur with paru: ${aur_pkgs[*]}?"; then
            paru -S --needed "${aur_pkgs[@]}" || true
        fi
    else
        echo "no paru, skipping aur packages: ${aur_pkgs[*]}"
    fi
fi

if ask "install easyeffects via flatpak?"; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
    flatpak install -y flathub com.github.wwmm.easyeffects || true
fi

if ask "build hyprglass plugin? (needs hyprland headers)"; then
    src="$HOME/.local/src/hyprglass"
    if [ ! -d "$src" ]; then
        git clone https://github.com/hyprnux/hyprglass "$src" || true
    fi
    if [ -d "$src" ]; then
        make -C "$src" || echo "hyprglass build failed"
    fi
fi

missing=()
for pkg in "${packages[@]}"; do
    pacman -Qq "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
done
flatpak info com.github.wwmm.easyeffects >/dev/null 2>&1 || missing+=("easyeffects (flatpak)")

echo
if ((${#missing[@]})); then
    echo "not installed:"
    printf '  %s\n' "${missing[@]}"
else
    echo "everything installed"
fi

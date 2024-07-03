# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc


# bash completion
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi


# custom env Paths
export PATH=$PATH:$HOME/Apps/Scripts
export PATH=$PATH:$HOME/.platformio/penv/bin

# dark theme
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# theme
MY_PATH="\[\033[0;34m\]"
MY_ARG="\[\033[0;37m\]"
PS1="${MY_PATH}\w> ${MY_ARG}"

# idk tbh
. "$HOME/.cargo/env"


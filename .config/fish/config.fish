



# --- tty colors ---------------------------------------------
eval (dircolors -c ~/.dircolors | string replace 'LS_COLORS=' 'set -x LS_COLORS ' | string replace ';$' '' )

set -Ux TERMINAL alacritty
set -gx EDITOR nvim
set -gx VISUAL nvim
set -x GOPROXY direct
set -x XCOMPOSEFILE $HOME/.XCompose
set fish_greeting ""

fish_add_path $HOME/.local/bin


function fish_command_not_found
    cowsay "Command not found: $argv[1]"
end


function home-server 
    ssh offlinebot@100.67.28.61
end

function cff
    clear
    fastfetch
end

# Prompt liegt jetzt in functions/fish_prompt.fish (+ fish_right_prompt.fish)

fish_add_path /home/offlinebot/.spicetify
fish_add_path /home/offlinebot/.modular/bin

zoxide init --cmd cd fish | source

# fzf-Bindings: Ctrl+R fuzzy History, Ctrl+T Dateien, Alt+C Verzeichnisse
if status is-interactive; and command -q fzf
    fzf --fish | source
    set -gx FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border=rounded \
        --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
        --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
        --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
        --color=selected-bg:#45475a,border:#585b70,label:#cdd6f4"
end


# --- wayland env for ssh/tmux shells ------------------------
if not set -q WAYLAND_DISPLAY
    set -l _rt /run/user/(id -u)
    if test -d $_rt
        set -l _wl (command ls $_rt 2>/dev/null | string match -r '^wayland-[0-9]+$' | head -n1)
        if test -n "$_wl"
            set -gx XDG_RUNTIME_DIR $_rt
            set -gx WAYLAND_DISPLAY $_wl
            set -l _sock (command ls $_rt 2>/dev/null | string match -r '^niri\..*\.sock$' | head -n1)
            if test -n "$_sock"
                set -gx NIRI_SOCKET $_rt/$_sock
            end
        end
    end
end





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

function prompt_pwd
	echo (string replace --regex "^$HOME" "~" (pwd))
end

function fish_prompt
	set -l last_status $status

	set -l stat
	if test $last_status -ne 0
		set stat (set_color red)"[$last_status]" (set_color normal)
	end
    string join '' -- (set_color --bold green) (prompt_pwd) $stat ' > ' (set_color normal)
end

fish_add_path /home/offlinebot/.spicetify
fish_add_path /home/offlinebot/.modular/bin

zoxide init --cmd cd fish | source


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

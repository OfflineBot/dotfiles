#source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end



# TTY Colors
eval (dircolors -c ~/.dircolors | string replace 'LS_COLORS=' 'set -x LS_COLORS ' | string replace ';$' '' )

set -eU PATH
set -Ux TERMINAL alacritty
set -x GOPROXY direct
set -x XCOMPOSEFILE $HOME/.XCompose
set -Ux PATH $HOME/Coding/nim/bin $PATH
set -x PATH $HOME/Documents/path $PATH
set fish_greeting ""
export PATH="$HOME/.local/bin:$PATH"


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


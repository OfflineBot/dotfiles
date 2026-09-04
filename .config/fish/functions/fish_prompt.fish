# Catppuccin-Mocha-Prompt — mauve/maroon, passend zu Hyprland-Bordern,
# zellij und kitty. Glyphs brauchen eine Nerd Font (kitty: FiraCode NF).
#
#   ╭─  ~/.dotfiles on  main !1 ⇡2
#   ╰─❯
#
# Bei Fehlern wird der Pfeil rot und zeigt den Exit-Code:  ╰─✘ 127 ❯

# fish_git_prompt-Verhalten (läuft einmal beim Autoload)
set -g __fish_git_prompt_showdirtystate 1
set -g __fish_git_prompt_showuntrackedfiles 1
set -g __fish_git_prompt_showstashstate 1
set -g __fish_git_prompt_showupstream auto
set -g __fish_git_prompt_showcolorhints 1
set -g __fish_git_prompt_char_dirtystate ' !'
set -g __fish_git_prompt_char_stagedstate ' +'
set -g __fish_git_prompt_char_untrackedfiles ' ?'
set -g __fish_git_prompt_char_stashstate ' *'
set -g __fish_git_prompt_char_upstream_ahead ' ⇡'
set -g __fish_git_prompt_char_upstream_behind ' ⇣'
set -g __fish_git_prompt_color_branch eba0ac --bold
set -g __fish_git_prompt_color_dirtystate f9e2af
set -g __fish_git_prompt_color_stagedstate a6e3a1
set -g __fish_git_prompt_color_untrackedfiles 6c7086
set -g __fish_git_prompt_color_stashstate 94e2d5
set -g __fish_git_prompt_color_upstream f5c2e7

function fish_prompt
    set -l last_status $status

    # Pfad: Eltern gedimmt, letztes Segment fett in Mauve
    set -l path (string replace -r "^$HOME" '~' -- $PWD)
    set -l parent (string replace -r '[^/]*$' '' -- $path)
    set -l leaf (string replace -r '^.*/' '' -- $path)
    if test -z "$leaf" # Sonderfall "/"
        set leaf $path
        set parent ''
    end

    echo -n -s (set_color eba0ac) '╭─ ' (set_color cba6f7) ' ' \
        (set_color 9399b2) $parent (set_color --bold cba6f7) $leaf (set_color normal)

    set -l git (fish_git_prompt '%s')
    if test -n "$git"
        echo -n -s (set_color 6c7086) ' on ' (set_color eba0ac) ' ' $git (set_color normal)
    end

    echo

    if test $last_status -ne 0
        echo -n -s (set_color eba0ac) '╰─' (set_color --bold f38ba8) '✘ ' $last_status ' ❯ ' (set_color normal)
    else
        echo -n -s (set_color eba0ac) '╰─' (set_color --bold cba6f7) '❯ ' (set_color normal)
    end
end

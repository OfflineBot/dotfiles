# Catppuccin-Mocha-Prompt — mauve/maroon, passend zu Hyprland-Bordern,
# zellij und kitty. Glyphs brauchen eine Nerd Font (kitty: FiraCode NF).
#
#    ~/.dotfiles  main ! ❯
#
# Git: nur der Branch-Name, plus genau ein Marker —
#   !  es gibt uncommittete Änderungen ODER ungepushte Commits
#   (nichts)  alles committet und gepusht
# Bei Fehlern wird der Pfeil rot und zeigt den Exit-Code:  ✘ 127 ❯

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

    echo -n -s (set_color cba6f7) ' ' \
        (set_color 9399b2) $parent (set_color --bold cba6f7) $leaf (set_color normal)

    # Git: Branch + evtl. "!"
    set -l branch (git symbolic-ref --short HEAD 2>/dev/null;
        or git rev-parse --short HEAD 2>/dev/null)
    if test -n "$branch"
        echo -n -s (set_color eba0ac) '  ' (set_color --bold eba0ac) $branch (set_color normal)

        # uncommittet? (geänderte/gestagte getrackte Dateien)
        set -l dirty (git status --porcelain --untracked-files=no 2>/dev/null | count)
        # ungepusht? (Commits vor dem Upstream; ohne Upstream: 0)
        set -l ahead (git rev-list --count '@{upstream}..HEAD' 2>/dev/null; or echo 0)
        if test $dirty -gt 0; or test $ahead -gt 0
            echo -n -s (set_color --bold f9e2af) ' !' (set_color normal)
        end
    end

    if test $last_status -ne 0
        echo -n -s (set_color --bold f38ba8) ' ✘ ' $last_status ' ❯ ' (set_color normal)
    else
        echo -n -s (set_color --bold eba0ac) ' ❯ ' (set_color normal)
    end
end

# Rechte Seite: Dauer des letzten Befehls (ab 1s), dezent gedimmt.
function fish_right_prompt
    if set -q CMD_DURATION; and test $CMD_DURATION -gt 1000
        set -l total_s (math -s0 $CMD_DURATION / 1000)
        set -l out
        if test $total_s -ge 60
            set out (math -s0 $total_s / 60)'m '(math $total_s % 60)'s'
        else
            set out (math -s1 $CMD_DURATION / 1000)'s'
        end
        echo -n -s (set_color 6c7086) '󱎫 ' $out (set_color normal)
    end
end

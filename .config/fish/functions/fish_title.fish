# Eigener Fenster-/Tab-Titel (überschreibt den vom fish-pure-prompt-Paket
# mitgelieferten): "verzeichnis" bzw. "befehl · verzeichnis".
function fish_title
    set -l dir (string replace -r "^$HOME" '~' -- $PWD | string split '/')[-1]
    if test -n "$argv[1]"
        echo -- (string split ' ' -- $argv[1])[1]" · $dir"
    else
        echo -- $dir
    end
end

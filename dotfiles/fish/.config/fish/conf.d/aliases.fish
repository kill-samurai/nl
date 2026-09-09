function python
    command python3 $argv
end

function pip
    command pip3 $argv
end

function caribe --description 'Refresh Caribe data and restore the original Tailscale state'
    if not command -q python3
        echo 'Python 3 is required to refresh Caribe data.' >&2
        return 1
    end
    python3 "$HOME/Documents/caribe/refresh_data.py" $argv
end

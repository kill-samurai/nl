function claude --description "Launches Claude Code with Inner Monologue and SWARM side panes"
    if not set -q WEZTERM_PANE
        echo "Error: This automation requires running inside WezTerm."
        command claude $argv
        return
    end

    set -l monologue_pane_id (wezterm cli split-pane --right --percent 30 -- fish -c "
        echo '=== Claude Inner Monologue Ready ==='
        while true; sleep 1; end
    ")
    if test -z "$monologue_pane_id"
        echo "Warning: could not create the Inner Monologue pane; running Claude alone."
        command claude $argv
        return
    end

    set -l swarm_pane_id (wezterm cli split-pane --pane-id $monologue_pane_id --bottom --percent 50 -- fish -c "
        echo '=== SWARM Monitor Ready ==='
        while true; sleep 1; end
    ")

    command claude $argv

    wezterm cli kill-pane --pane-id $monologue_pane_id >/dev/null 2>&1
    if test -n "$swarm_pane_id"
        wezterm cli kill-pane --pane-id $swarm_pane_id >/dev/null 2>&1
    end
end

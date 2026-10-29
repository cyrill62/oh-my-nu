# description: rmux / tmux session shortcuts (Oh My Zsh's tmux plugin); rmux first, else tmux
# requires: rmux|tmux

# rmux when installed, else tmux ($env.OMN_MUX overrides)
def mux [] { $env.OMN_MUX? | default (if (which rmux | is-not-empty) { "rmux" } else { "tmux" }) }

# Attach to a session: ta NAME
export def --wrapped ta [...args] { run-external (mux) attach-session '-t' ...$args }

# Attach to a session, detaching its other clients: tad NAME
export def --wrapped tad [...args] { run-external (mux) attach-session '-d' '-t' ...$args }

# New session: ts NAME
export def --wrapped ts [...args] { run-external (mux) new-session '-s' ...$args }

# List sessions
export def --wrapped tl [...args] { run-external (mux) list-sessions ...$args }

# List windows
export def --wrapped tlw [...args] { run-external (mux) list-windows ...$args }

# Kill the server
export def --wrapped tksv [...args] { run-external (mux) kill-server ...$args }

# Kill a session: tkss NAME
export def --wrapped tkss [...args] { run-external (mux) kill-session '-t' ...$args }

# Attach to a session, creating it if needed (default: current directory name)
export def tat [name?: string] {
    let name = $name | default (pwd | path basename | str replace --all '.' '_')
    run-external (mux) new-session '-A' '-s' $name
}

# Sessions as a table
export def tst [] {
    run-external (mux) list-sessions '-F' "#{session_name}\t#{session_windows}\t#{session_attached}\t#{session_created}"
    | lines
    | split column "\t" name windows attached created
    | update windows { into int }
    | update attached { $in != "0" }
    | update created { into datetime --format '%s' }
}

# Windows of the current (or given) session as a table
export def twt [session?: string] {
    let target = if $session == null { [] } else { ['-t' $session] }
    run-external (mux) list-windows ...$target '-F' "#{window_index}\t#{window_name}\t#{window_panes}\t#{window_active}"
    | lines
    | split column "\t" index name panes active
    | update index { into int }
    | update panes { into int }
    | update active { $in == "1" }
}

def config-file [] {
    let name = mux
    [$"~/.config/($name)/($name).conf" $"~/.($name).conf"]
    | path expand
    | where { path exists }
    | append ($"~/.($name).conf" | path expand)
    | first
}

# Reload the config
export def trl [] { run-external (mux) source-file (config-file) }

# Edit the config
export def trc [] { run-external ($env.EDITOR? | default vi) (config-file) }

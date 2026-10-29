# description: Start ssh-agent once and share it between shells (Oh My Zsh's ssh-agent)
# requires: ssh-agent
#
# Settings (set them in env.nu):
#   $env.OMN_SSH_AGENT_IDENTITIES = [id_ed25519 work_key]   keys to add (default: the usual id_* files)
#   $env.OMN_SSH_AGENT_LAZY = true      don't add keys at startup (run `ssh-agent-add`)
#   $env.OMN_SSH_AGENT_LIFETIME = "4h"  ssh-agent -t
#   $env.OMN_SSH_AGENT_QUIET = true
#   $env.OMN_SSH_AGENT_ARGS = [-T]      extra ssh-agent arguments (-T: socket in /tmp)

def cache-file [] {
    let host = (sys host | get hostname | split row '.' | first)
    $"~/.ssh/environment-($host)" | path expand
}

def agent-alive [socket: any] {
    ($socket | is-not-empty) and (($socket | path type) == "socket")
}

def read-cache [] {
    if not (cache-file | path exists) { return {} }
    open --raw (cache-file)
    | parse --regex '(?<key>SSH_AUTH_SOCK|SSH_AGENT_PID)=(?<value>[^;]+);'
    | reduce --fold {} {|row, acc| $acc | upsert $row.key $row.value }
}

# Keys to add: $env.OMN_SSH_AGENT_IDENTITIES, else the default id_* files
def identities [] {
    let wanted = $env.OMN_SSH_AGENT_IDENTITIES? | default [id_rsa id_dsa id_ecdsa id_ed25519 id_ed25519_sk identity]
    $wanted
    | each {|id| if ($id | str starts-with '/') { $id } else { "~/.ssh" | path expand | path join $id } }
    | where { path exists }
}

# Add the configured keys that the agent does not hold yet
export def ssh-agent-add [] {
    let held = do { ^ssh-add -l } | complete | get stdout | lines | each { split row ' ' | get --optional 1 }
    let missing = identities | where {|file|
        let sig = do { ^ssh-keygen -lf $file } | complete | get stdout | split row ' ' | get --optional 1
        $sig not-in $held
    }
    if ($missing | is-not-empty) { ^ssh-add ...$missing }
}

export-env {
    if not (agent-alive ($env.SSH_AUTH_SOCK? | default "")) {
        let cached = read-cache
        if (agent-alive ($cached.SSH_AUTH_SOCK? | default "")) {
            load-env $cached
        } else if ("~/.ssh" | path expand | path exists) {
            if ($env.OMN_SSH_AGENT_QUIET? != true) { print --stderr "Starting ssh-agent ..." }
            let lifetime = $env.OMN_SSH_AGENT_LIFETIME? | default ""
            let args = [-s] ++ (if ($lifetime | is-empty) { [] } else { [-t $lifetime] }) ++ ($env.OMN_SSH_AGENT_ARGS? | default [])
            let result = do { ^ssh-agent ...$args } | complete
            if $result.exit_code != 0 {
                # Never break shell startup: say why and carry on without an agent.
                print --stderr $"ssh-agent failed: ($result.stderr | lines | where { is-not-empty } | last | default '')"
                return
            }
            $result.stdout | lines | where { not ($in starts-with 'echo') } | str join "\n" | save --force (cache-file)
            ^chmod 600 (cache-file)
            load-env (read-cache)
        }
    }
    # Like Oh My Zsh, load the keys now unless lazy (ssh-add asks for passphrases).
    if ($env.OMN_SSH_AGENT_LAZY? != true) and (agent-alive ($env.SSH_AUTH_SOCK? | default "")) {
        try { ssh-agent-add }
    }
}

export def --env ssh-agent-env [] { load-env (read-cache) }

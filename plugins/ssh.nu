# description: ssh helpers (Oh My Zsh's ssh): ssh_rmhkey, ssh_load_key, ssh_unload_key, plus a hosts table
# requires: ssh

def config-hosts [] {
    let config = "~/.ssh/config" | path expand
    if not ($config | path exists) { return [] }
    open --raw $config | lines | parse --regex '^\s*Host\s+(?<names>.+)$' | get names
    | each { split row ' ' } | flatten | where {|h| ($h | is-not-empty) and not ($h | str contains '*') } | uniq | sort
}

# Hosts of ~/.ssh/config as a table: host, hostname, user, port
export def ssh-hosts [] {
    let config = "~/.ssh/config" | path expand
    if not ($config | path exists) { return [] }
    open --raw $config
    | split row --regex '(?m)^\s*Host\s+'
    | skip 1
    | each {|block|
        let lines = $block | lines
        let get = {|key| $lines | parse --regex ('(?i)^\s*' + $key + '\s+(?<v>\S+)') | get --optional v.0 }
        {host: ($lines | first | str trim), hostname: (do $get HostName), user: (do $get User), port: (do $get Port)}
    }
    | where { not ($in.host | str contains '*') }
}

# Remove the known_hosts key of a ~/.ssh/config host (by its HostName)
export def ssh_rmhkey [host: string@config-hosts] {
    let hostname = ssh-hosts | where host == $host | get --optional 0.hostname
    ^ssh-keygen -R ($hostname | default $host)
}

def keysig [key: string] { ^ssh-keygen -l -f ($"~/.ssh/($key)" | path expand) | split row ' ' | get 1 }

def loaded [] { do { ^ssh-add -l } | complete | get stdout }

# Add ~/.ssh/KEY to the agent unless it is already loaded
export def ssh_load_key [key: string] {
    if not (loaded | str contains (keysig $key)) { ^ssh-add ($"~/.ssh/($key)" | path expand) }
}

# Remove ~/.ssh/KEY from the agent if it is loaded
export def ssh_unload_key [key: string] {
    if (loaded | str contains (keysig $key)) { ^ssh-add -d ($"~/.ssh/($key)" | path expand) }
}

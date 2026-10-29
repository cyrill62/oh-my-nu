# description: OpenRC service shortcuts (rc-service, rc-update, rc-status)
# requires: rc-service

use ../lib/root.nu [as-root]

# Status of a service
export def rcst [service: string] { ^rc-service $service status }

# Start a service
export def rcstart [service: string] { as-root rc-service $service start }

# Stop a service
export def rcstop [service: string] { as-root rc-service $service stop }

# Restart a service
export def rcrestart [service: string] { as-root rc-service $service restart }

# Add a service to a runlevel (default: default)
export def rcadd [service: string, runlevel: string = "default"] { as-root rc-update add $service $runlevel }

# Remove a service from a runlevel (default: default)
export def rcdel [service: string, runlevel: string = "default"] { as-root rc-update del $service $runlevel }

export alias rcs = rc-service
export alias rcu = rc-update
export alias rcls = rc-status --all

# Services of all runlevels as a table: service, runlevel
export def rct [] {
    ^rc-update show --verbose
    | lines
    | parse --regex '^\s*(?<service>\S+)\s*\|\s*(?<runlevels>.*)$'
    | update runlevels { split row ' ' | where { is-not-empty } | str join ' ' }
}

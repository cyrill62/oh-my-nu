# description: firewall-cmd shortcuts (Oh My Zsh's firewalld names)
# requires: firewall-cmd

use ../lib/root.nu [as-root]

# firewall-cmd
export def --wrapped fw [...args] { as-root firewall-cmd ...$args }

# firewall-cmd --permanent
export def --wrapped fwp [...args] { as-root firewall-cmd --permanent ...$args }

# Reload the rules
export def --wrapped fwr [...args] { as-root firewall-cmd --reload ...$args }

# Make the runtime rules permanent
export def --wrapped fwrp [...args] { as-root firewall-cmd --runtime-to-permanent ...$args }

# Active zones with their interfaces, services and ports, as a table
export def fwl [] {
    let zones = as-root firewall-cmd --get-active-zones | lines | where { not ($in starts-with ' ') and ($in | is-not-empty) }
    $zones | each {|zone|
        let info = as-root firewall-cmd --zone $zone --list-all | lines | parse --regex '^\s+(?<key>[a-z-]+):\s*(?<value>.*)$' | transpose --header-row --as-record
        {zone: $zone, interfaces: ($info.interfaces? | default ""), services: ($info.services? | default ""), ports: ($info.ports? | default "")}
    }
}

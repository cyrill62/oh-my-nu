# description: dnf / yum shortcuts (Oh My Zsh's yum plugin), plus an updates table
# requires: dnf|yum

use ../lib/root.nu [as-root c-locale]

# dnf when installed, else yum ($env.OMN_YUM overrides)
def pm [] { $env.OMN_YUM? | default (if (which dnf | is-not-empty) { "dnf" } else { "yum" }) }

# Search packages
export def --wrapped ys [...args] { run-external (pm) search ...$args }

# Show package information
export def --wrapped yp [...args] { run-external (pm) info ...$args }

# List packages
export def --wrapped yl [...args] { run-external (pm) list ...$args }

# List installed packages
export def --wrapped yli [...args] { run-external (pm) list '--installed' ...$args }

# List package groups
export def --wrapped ygl [...args] { run-external (pm) group list ...$args }

# Transaction history
export def --wrapped yh [...args] { run-external (pm) history ...$args }

# Install packages
export def --wrapped yi [...args] { as-root (pm) install ...$args }

# Remove packages
export def --wrapped yr [...args] { as-root (pm) remove ...$args }

# Remove packages with the dependencies nothing else needs
export def --wrapped yrl [...args] { as-root (pm) remove --remove-leaves ...$args }

# Upgrade packages
export def --wrapped yu [...args] { as-root (pm) upgrade ...$args }

# Remove packages that nothing needs any more
export def --wrapped yar [...args] { as-root (pm) autoremove ...$args }

# Refresh the metadata cache
export def --wrapped ymc [...args] { as-root (pm) makecache ...$args }

# Clean all caches
export def --wrapped yc [...args] { as-root (pm) clean all ...$args }

# Install a package group
export def --wrapped ygi [...args] { as-root (pm) group install ...$args }

# Remove a package group
export def --wrapped ygr [...args] { as-root (pm) group remove ...$args }

# Available updates as a table
export def ycu [] {
    c-locale (pm) check-update --quiet
    | lines
    | parse --regex '^(?<package>\S+)\.(?<arch>[^.\s]+)\s+(?<version>\S+)\s+(?<repo>\S+)$'
}

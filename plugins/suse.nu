# description: zypper shortcuts (openSUSE, SLES; Oh My Zsh's suse names)
# requires: zypper

use ../lib/root.nu [as-root c-locale]

export alias zh = zypper help
export alias zinfo = zypper info
export alias zlp = zypper list-patches
export alias zlu = zypper list-updates
export alias zpch = zypper patch-check
export alias zps = zypper ps
export alias zse = zypper search
export alias zlr = zypper repos
export alias zwp = zypper what-provides

# Install packages
export def --wrapped zin [...args] { as-root zypper install ...$args }

# Install new recommended packages
export def --wrapped zinr [...args] { as-root zypper install-new-recommends ...$args }

# Remove packages
export def --wrapped zrm [...args] { as-root zypper remove ...$args }

# Update packages
export def --wrapped zup [...args] { as-root zypper update ...$args }

# Distribution upgrade
export def --wrapped zdup [...args] { as-root zypper dist-upgrade ...$args }

# Install patches
export def --wrapped zpatch [...args] { as-root zypper patch ...$args }

# Refresh repositories
export def --wrapped zref [...args] { as-root zypper refresh ...$args }

# Clean caches
export def --wrapped zcl [...args] { as-root zypper clean ...$args }

# Add a repository
export def --wrapped zar [...args] { as-root zypper addrepo ...$args }

# Remove a repository
export def --wrapped zrr [...args] { as-root zypper removerepo ...$args }

# Modify a repository
export def --wrapped zmr [...args] { as-root zypper modifyrepo ...$args }

# Install a source package
export def --wrapped zsi [...args] { as-root zypper source-install ...$args }

# Available updates as a table
export def zlut [] {
    c-locale zypper --quiet --xmlout list-updates
    | from xml
    | get --optional content.content.0.content
    | default []
    | where tag == update
    | each { get attributes | select --optional name edition arch }
}

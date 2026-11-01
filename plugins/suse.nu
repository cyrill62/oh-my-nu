# description: zypper shortcuts (openSUSE, SLES; Oh My Zsh's suse names)
# requires: zypper

use ../lib/root.nu [as-root c-locale]

export alias zh = zypper help
export alias zhse = zypper help search
export alias zlicenses = zypper licenses
export alias ztos = zypper tos
export alias zvcmp = zypper vcmp
export alias zlp = zypper list-patches
export alias zlu = zypper list-updates
export alias zpch = zypper --no-refresh patch-check
export alias zif = zypper --no-refresh info
export alias zpa = zypper --no-refresh packages
export alias zpatch-info = zypper --no-refresh patch-info
export alias zpattern-info = zypper --no-refresh pattern-info
export alias zproduct-info = zypper --no-refresh product-info
export alias zpd = zypper --no-refresh products
export alias zpt = zypper --no-refresh patterns
export alias zse = zypper --no-refresh search
export alias zwp = zypper --no-refresh what-provides
export alias zlr = zypper repos
export alias zls = zypper services
export alias zll = zypper locks

# zypper as root
export def --wrapped z [...args] { as-root zypper ...$args }

# Processes using deleted files
export def --wrapped zps [...args] { as-root zypper ps ...$args }

# zypper's shell
export def --wrapped zshell [...args] { as-root zypper shell ...$args }

# Download source packages
export def --wrapped zsource-download [...args] { as-root zypper source-download ...$args }

# Verify dependencies
export def --wrapped zve [...args] { as-root zypper verify ...$args }

# Check patches
export def --wrapped zpchk [...args] { as-root zypper patch-check ...$args }

# Rename a repository
export def --wrapped znr [...args] { as-root zypper namerepo ...$args }

# Add a service
export def --wrapped zas [...args] { as-root zypper addservice ...$args }

# Modify a service
export def --wrapped zms [...args] { as-root zypper modifyservice ...$args }

# Refresh services
export def --wrapped zrefs [...args] { as-root zypper refresh-services ...$args }

# Remove a service
export def --wrapped zrs [...args] { as-root zypper removeservice ...$args }

# Lock packages
export def --wrapped zal [...args] { as-root zypper addlock ...$args }

# Unlock packages
export def --wrapped zrl [...args] { as-root zypper removelock ...$args }

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

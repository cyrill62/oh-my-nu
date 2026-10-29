# description: Oh My Zsh's dnf aliases (Fedora, RHEL...)
# requires: dnf

use ../lib/root.nu [as-root]

export alias dnfl = dnf list
export alias dnfli = dnf list --installed
export alias dnfgl = dnf group list
export alias dnfp = dnf info
export alias dnfs = dnf search
export alias dnfh = dnf history

# Refresh the metadata cache
export def --wrapped dnfmc [...args] { as-root dnf makecache ...$args }

# Upgrade packages
export def --wrapped dnfu [...args] { as-root dnf upgrade ...$args }

# Install packages
export def --wrapped dnfi [...args] { as-root dnf install ...$args }

# Install a package group
export def --wrapped dnfgi [...args] { as-root dnf group install ...$args }

# Remove packages
export def --wrapped dnfr [...args] { as-root dnf remove ...$args }

# Remove a package group
export def --wrapped dnfgr [...args] { as-root dnf group remove ...$args }

# Remove packages nothing needs
export def --wrapped dnfar [...args] { as-root dnf autoremove ...$args }

# Clean all caches
export def --wrapped dnfc [...args] { as-root dnf clean all ...$args }

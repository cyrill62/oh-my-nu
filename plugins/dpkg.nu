# description: dpkg shortcuts, plus installed-package tables
# requires: dpkg

use ../lib/root.nu [as-root c-locale]

# Install .deb files
export def --wrapped dpi [...args] { as-root dpkg --install ...$args }

# Reconfigure a package
export def --wrapped dprec [...args] { as-root dpkg-reconfigure ...$args }

export alias dpf = dpkg --listfiles
export alias dpown = dpkg --search
export alias dpinfo = dpkg --info
export alias dpc = dpkg --contents
export alias dpv = dpkg --verify

# Installed packages as a table (optionally matching glob patterns)
export def dpls [...patterns: string] {
    c-locale dpkg-query --show '--showformat=${db:Status-Abbrev}\t${Package}\t${Version}\t${Architecture}\t${Installed-Size}\n' ...$patterns
    | lines
    | split column "\t" status package version arch size
    | where status starts-with 'ii'
    | reject status
    | update size { into int | $in * 1kib }
}

# Biggest installed packages, biggest first
export def dpsz [count: int = 20] { dpls | sort-by size --reverse | first $count }

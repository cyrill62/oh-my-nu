# description: apt shortcuts (Debian, Ubuntu...), plus upgradable/history tables
# requires: apt

use ../lib/root.nu [as-root c-locale]

# Install packages
export def --wrapped apti [...args] { as-root apt install ...$args }

# Remove packages
export def --wrapped aptr [...args] { as-root apt remove ...$args }

# Remove packages and their configuration
export def --wrapped aptp [...args] { as-root apt purge ...$args }

# Refresh the package lists
export def --wrapped aptu [...args] { as-root apt update ...$args }

# Upgrade installed packages
export def --wrapped aptug [...args] { as-root apt upgrade ...$args }

# Upgrade, adding/removing packages if needed
export def --wrapped aptfu [...args] { as-root apt full-upgrade ...$args }

# Refresh the package lists, then upgrade
export def --wrapped aptuu [...args] {
    as-root apt update
    as-root apt upgrade ...$args
}

# Remove packages that nothing needs any more
export def --wrapped aptar [...args] { as-root apt autoremove ...$args }

# Delete downloaded packages that can no longer be downloaded
export def --wrapped aptc [...args] { as-root apt autoclean ...$args }

export alias apts = apt search
export alias aptsh = apt show
export alias aptl = apt list --installed
export alias aptpol = apt policy
export alias aptdep = apt-cache depends
export alias aptrdep = apt-cache rdepends
export alias aptmark = apt-mark

# Upgradable packages as a table
export def aptup [] {
    c-locale apt list --upgradable
    | lines
    | parse --regex '^(?<package>[^/\s]+)/(?<suite>\S+) (?<version>\S+) (?<arch>\S+) \[upgradable from: (?<current>[^\]]+)\]'
}

# Manually installed packages
export def aptman [] { c-locale apt-mark showmanual | lines }

# apt history (install/remove/upgrade runs) as a table, most recent last
export def apth [count: int = 20, --file: path = /var/log/apt/history.log] {
    open --raw $file
    | split row "\n\n"
    | where { str trim | is-not-empty }
    | each {|block|
        $block | lines | parse '{key}: {value}' | transpose --header-row --as-record
    }
    | select --optional Start-Date Commandline Requested-By
    | rename date command by
    | update date { into datetime --format '%Y-%m-%d  %H:%M:%S' }
    | last $count
}

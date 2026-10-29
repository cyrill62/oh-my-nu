# description: pacman shortcuts (Arch, Manjaro...; Oh My Zsh's archlinux names), plus tables
# requires: pacman

use ../lib/root.nu [as-root c-locale]

# Sync and upgrade everything
export def --wrapped pacupg [...args] { as-root pacman -Syu ...$args }

# Install packages from the repositories
export def --wrapped pacin [...args] { as-root pacman -S ...$args }

# Install local package files
export def --wrapped pacins [...args] { as-root pacman -U ...$args }

# Install packages as dependencies
export def --wrapped pacinsd [...args] { as-root pacman -S --asdeps ...$args }

# Remove packages with their unneeded dependencies and config files
export def --wrapped pacrem [...args] { as-root pacman -Rns ...$args }

# Clean the package cache of uninstalled packages
export def --wrapped paclean [...args] { as-root pacman -Sc ...$args }

# Force a refresh of the package databases
export def --wrapped pacmir [...args] { as-root pacman -Syy ...$args }

# Refresh the file databases (for pacfiles)
export def --wrapped pacfileupg [...args] { as-root pacman -Fy ...$args }

export alias pacrep = pacman -Si
export alias pacreps = pacman -Ss
export alias pacloc = pacman -Qi
export alias paclocs = pacman -Qs
export alias pacls = pacman -Ql
export alias pacown = pacman -Qo
export alias pacfiles = pacman -F
export alias paclsorphans = pacman -Qdt

# Remove orphaned packages (asks first)
export def pacrmorphans [] {
    let orphans = c-locale pacman -Qdtq | lines | where { is-not-empty }
    if ($orphans | is-empty) {
        print "no orphans"
    } else {
        as-root pacman -Rns ...$orphans
    }
}

# Explicitly installed packages as a table
export def pacexp [] { c-locale pacman -Qe | lines | parse '{package} {version}' }

# Available updates as a table (from the local databases: run pacmir first)
export def pacout [] { c-locale pacman -Qu | lines | parse --regex '^(?<package>\S+) (?<current>\S+) -> (?<version>\S+)' }

# Biggest installed packages, biggest first
export def pacsz [count: int = 20] {
    c-locale pacman -Qi
    | split row "\n\n"
    | where { str trim | is-not-empty }
    | each {|block|
        let fields = $block | lines | parse --regex '^(?<key>[^:]+?)\s*:\s(?<value>.*)$' | transpose --header-row --as-record
        {package: $fields.Name, size: ($fields."Installed Size" | str replace --all ' ' '' | into filesize)}
    }
    | sort-by size --reverse
    | first $count
}

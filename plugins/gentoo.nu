# description: Portage shortcuts (emerge, equery, eselect) and an emerge history table
# requires: emerge

use ../lib/root.nu [as-root]

# Install packages (asks first)
export def --wrapped emi [...args] { as-root emerge --ask --verbose ...$args }

# Update @world (deep, new USE flags, build deps)
export def --wrapped emup [...args] { as-root emerge --ask --verbose --update --deep --newuse --with-bdeps=y @world ...$args }

# Sync the repositories
export def --wrapped ems [...args] { as-root emaint --auto sync ...$args }

# Remove packages that nothing needs (asks first)
export def --wrapped emc [...args] { as-root emerge --ask --depclean ...$args }

# Remove a package from @world and depclean it (asks first)
export def --wrapped emr [...args] { as-root emerge --ask --verbose --deselect ...$args; as-root emerge --ask --depclean ...$args }

# Rebuild packages using old libraries
export def --wrapped emrb [...args] { as-root emerge --ask --verbose @preserved-rebuild ...$args }

# Resume the last interrupted emerge
export def --wrapped emres [...args] { as-root emerge --ask --resume ...$args }

# Show what would be installed (no root needed)
export alias emp = emerge --pretend --verbose
export alias emsearch = emerge --search

export alias eqf = equery files
export alias eqb = equery belongs
export alias eqd = equery depends
export alias equ = equery uses
export alias eql = equery list
export alias eqs = equery size
export alias eqh = equery hasuse
export alias eqw = equery which

export alias es = eselect
export alias esk = eselect kernel list
export alias esn = eselect news read new

# Recently merged packages, from /var/log/emerge.log
export def emlog [count: int = 20] {
    let log = "/var/log/emerge.log"
    let text = try { open --raw $log } catch {
        error make --unspanned {msg: $"cannot read ($log): add yourself to the portage group \(usermod -aG portage ($env.USER? | default $env.LOGNAME?)) or use sudo"}
    }
    $text
    | lines
    | parse --regex '^(?<time>\d+):\s+::: completed emerge \(\d+ of \d+\) (?<package>\S+) to'
    | last $count
    | update time { into datetime --format '%s' }
}

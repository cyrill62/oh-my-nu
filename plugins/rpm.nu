# description: rpm queries (Fedora, RHEL, openSUSE...), plus installed-package tables
# requires: rpm

use ../lib/root.nu [as-root c-locale]

export alias rpmq = rpm --query
export alias rpmqa = rpm --query --all
export alias rpmqi = rpm --query --info
export alias rpmql = rpm --query --list
export alias rpmqf = rpm --query --file
export alias rpmreq = rpm --query --requires
export alias rpmprov = rpm --query --provides
export alias rpmqp = rpm --query --info --package
export alias rpmqlp = rpm --query --list --package
export alias rpmchg = rpm --query --changelog
export alias rpmv = rpm --verify

# Install or upgrade .rpm files
export def --wrapped rpmi [...args] { as-root rpm --upgrade --verbose --hash ...$args }

# Installed packages as a table (optionally matching a regex)
export def rpmls [pattern: string = ""] {
    c-locale rpm --query --all '--queryformat=%{NAME}\t%{VERSION}-%{RELEASE}\t%{ARCH}\t%{SIZE}\t%{INSTALLTIME}\n'
    | lines
    | split column "\t" package version arch size installed
    | where package =~ $pattern
    | update size { into int | into filesize }
    | update installed { into datetime --format '%s' }
}

# Most recently installed packages, most recent last
export def rpmlast [count: int = 20] { rpmls | sort-by installed | last $count }

# Biggest installed packages, biggest first
export def rpmsz [count: int = 20] { rpmls | sort-by size --reverse | first $count }

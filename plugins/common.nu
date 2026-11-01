# description: Everyday shortcuts: listings, directories, history, processes
# requires:

export alias l = ls --all --long
export alias ll = ls --long
export alias la = ls --all
export alias md = mkdir
export alias h = history
export alias c = clear
export alias reload = exec nu

# Oh My Zsh's common-aliases (external tools)
export alias lr = ^ls -tRFh
export alias ldot = ^ls -ld .*
export alias lS = ^ls -1FSsh
export alias lart = ^ls -1Fcart
export alias lrt = ^ls -1Fcrt
export alias lsr = ^ls -lARFh
export alias lsn = ^ls -1
export alias grep = ^grep --color=auto
export alias t = tail -f
export alias dud = du --max-depth 1
export alias p = ^ps -f
export alias sortnr = ^sort -n -r
export alias unexport = hide-env
export alias ping = ^ping -c 5
export alias ping6 = ^ping6 -c 5

# List a directory sorted by modification time, newest last
export def lt [pattern: glob = "."] { ls $pattern | sort-by modified }

# List a directory sorted by size, biggest last
export def lsz [pattern: glob = "."] { ls $pattern | sort-by size }

# Size of each entry of the current directory, biggest last
export def dus [] { du ...(glob *) | sort-by apparent }

# Create a directory (with parents) and enter it
export def --env mkcd [dir: path] {
    mkdir $dir
    cd $dir
}

# Search the history for a pattern (regex), most recent last
export def hs [pattern: string, --limit (-n): int = 25] {
    history | where command =~ $pattern | last $limit | select command
}

# Search the history for a pattern, ignoring case
export def hsi [pattern: string, --limit (-n): int = 25] {
    history | where command =~ $"\(?i\)($pattern)" | last $limit | select command
}

# Search the whole history for a pattern (regex), with dates
export def hgrep [pattern: string] {
    history | enumerate | flatten | where command =~ $pattern | select index start_timestamp? command
}

# The history in a pager
export def hl [] { history | get command | to text | ^less }

# The ten most used commands
export def hist10 [] {
    history | get command | each { split row ' ' | first } | uniq --count | sort-by count --reverse | first 10
}

# grep recursively with line numbers and context, skipping VCS directories
export def --wrapped sgrep [...rest] { ^grep -R -n -H -C 5 --exclude-dir=.git --exclude-dir=.svn --exclude-dir=CVS ...$rest }

# Files below the current directory matching a glob pattern
export def ff [pattern: string] { glob $"**/($pattern)" | where { ($in | path type) == file } | path relative-to $env.PWD }

# Clear the screen and say who and where you are
export def clr [] {
    clear
    print $"Currently logged in on (do { ^tty } | complete | get stdout | str trim), as (whoami) in directory ($env.PWD)."
}

# Processes using the most memory first
export def psmem [] { ps --long | sort-by mem --reverse | select pid name mem command }

# The ten processes using the most memory
export def psmem10 [] { psmem | first 10 }

# Processes using the most CPU first
export def pscpu [] { ps --long | sort-by cpu --reverse | select pid name cpu status command }

# The ten processes using the most CPU
export def pscpu10 [] { pscpu | first 10 }

# Zombie processes
export def pszombie [] { ps --long | where status == Zombie | select pid ppid name status }

# Processes whose name matches a pattern (regex)
export def psg [pattern: string] {
    ps --long | where name =~ $pattern | select pid ppid name cpu mem command
}

# Prepend a directory to PATH for this shell
export def --env path-add [dir: path] {
    $env.PATH = ($env.PATH | prepend ($dir | path expand) | uniq)
}

# Copy a file to FILE.bak (or FILE.bak.N if it exists)
export def bak [file: path] {
    mut target = $"($file).bak"
    mut n = 1
    while ($target | path exists) {
        $target = $"($file).bak.($n)"
        $n += 1
    }
    cp --recursive $file $target
    $target
}

# Public IP address
export def myip [] { http get --max-time 5sec https://ifconfig.me/ip | str trim }

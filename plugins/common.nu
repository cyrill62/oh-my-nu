# description: Everyday shortcuts: listings, directories, history, processes
# requires:

export alias l = ls --all --long
export alias ll = ls --long
export alias la = ls --all
export alias md = mkdir
export alias h = history
export alias c = clear
export alias reload = exec nu

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

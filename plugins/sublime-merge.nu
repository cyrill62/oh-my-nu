# description: Oh My Zsh's sublime-merge aliases: Sublime Merge, found where it is installed
# requires:

use ../lib/root.nu [as-root]

# smerge on PATH, or the first Sublime Merge install found
def find-smerge [] {
    let found = which --all smerge | where type == external | get --optional 0.path
    if $found != null { return $found }
    let candidates = [
        ("~/bin/sublime_merge" | path expand)
        /opt/sublime_merge/sublime_merge
        /usr/bin/sublime_merge
        /usr/local/bin/sublime_merge
        "/Applications/Sublime Merge.app/Contents/SharedSupport/bin/smerge"
        ("~/Applications/Sublime Merge.app/Contents/SharedSupport/bin/smerge" | path expand)
    ]
    let path = $candidates | where { path exists } | get --optional 0
    if $path == null {
        error make --unspanned {msg: "Sublime Merge not found: put smerge on PATH"}
    }
    $path
}

# Sublime Merge, from PATH or its install directory
export def --wrapped smerge [...rest] { run-external (find-smerge) ...$rest }
# Sublime Merge, quietly (it returns at once and keeps running)
export def --wrapped sm [...rest] { run-external (find-smerge) ...$rest out+err> /dev/null }
# Sublime Merge on the current directory
export def --wrapped smt [...rest] { run-external (find-smerge) . ...$rest out+err> /dev/null }
# Sublime Merge as root
export def --wrapped ssm [...rest] { as-root (find-smerge) ...$rest out+err> /dev/null }

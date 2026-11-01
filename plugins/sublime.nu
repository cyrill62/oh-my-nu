# description: Oh My Zsh's sublime aliases: Sublime Text, found where it is installed, and its projects
# requires:

use ../lib/root.nu [as-root]

# subl on PATH, or the first Sublime Text install found
def find-subl [] {
    let found = which --all subl | where type == external | get --optional 0.path
    if $found != null { return $found }
    let candidates = [
        ("~/bin/sublime_text" | path expand)
        /opt/sublime_text/sublime_text
        /opt/sublime_text_3/sublime_text
        /usr/bin/sublime_text
        /usr/local/bin/sublime_text
        /usr/bin/subl3
        /snap/bin/subl
        /snap/bin/sublime-text.subl
        "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl"
        ("~/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" | path expand)
    ]
    let path = $candidates | where { path exists } | get --optional 0
    if $path == null {
        error make --unspanned {msg: "Sublime Text not found: put subl on PATH"}
    }
    $path
}

# Sublime Text, from PATH or its install directory
export def --wrapped subl [...rest] { run-external (find-subl) ...$rest }
# Same as subl
export def --wrapped st [...rest] { run-external (find-subl) ...$rest }
# Open the current directory in Sublime Text
export def --wrapped stt [...rest] { run-external (find-subl) . ...$rest }
# Sublime Text as root
export def --wrapped sst [...rest] { as-root (find-subl) ...$rest }

# Open the project of the current git repository: its NAME.sublime-project
# when there is one, else the repository's directory
export def stp [] {
    mut dir = $env.PWD
    while $dir != "/" and not ($dir | path join .git | path exists) {
        $dir = $dir | path dirname
    }
    if $dir == "/" {
        run-external (find-subl) .
        return
    }
    let name = $dir | path basename
    mut search = $dir
    while $search != "/" and not ($search | path join $"($name).sublime-project" | path exists) {
        $search = $search | path dirname
    }
    run-external (find-subl) (if $search == "/" { $dir } else { $search | path join $"($name).sublime-project" })
}

# Create DIR/DIR.sublime-project (default: the current directory)
export def stn [dir?: path] {
    let dir = $dir | default $env.PWD | path expand
    if not ($dir | path exists) or ($dir | path type) != dir {
        error make --unspanned {msg: $"($dir) is not a valid directory"}
    }
    let file = $dir | path join $"($dir | path basename).sublime-project"
    if not ($file | path exists) {
        {folders: [{path: ".", file_exclude_patterns: []}]} | to json --indent 4 | save $file
        print $"New Sublime Text project created:\n\t($file)"
    }
}

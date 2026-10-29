# description: Directory bookmarks: mark, jump, marks, unmark (Oh My Zsh's jump / wd)
# requires:

def marks-file [] {
    $env.OMN_CONFIG_DIR? | default (
        $env.XDG_CONFIG_HOME? | default ($env.HOME | path join .config) | path join oh-my-nu
    ) | path join marks.nuon
}

def load-marks [] { if (marks-file | path exists) { open (marks-file) } else { {} } }

def save-marks [marks: record] {
    mkdir (marks-file | path dirname)
    $marks | save --force (marks-file)
}

def complete-marks [] { load-marks | columns }

# Bookmark the current directory (default name: its basename)
export def mark [name?: string] {
    let name = $name | default (pwd | path basename)
    save-marks (load-marks | upsert $name (pwd))
    print $"($name) -> (pwd)"
}

# Remove a bookmark
export def unmark [name: string@complete-marks] {
    let marks = load-marks
    if $name not-in ($marks | columns) {
        error make --unspanned {msg: $"no mark named ($name)"}
    }
    save-marks ($marks | reject $name)
}

# Go to a bookmarked directory
export def --env main [name: string@complete-marks] {
    let target = load-marks | get --optional $name
    if $target == null {
        error make --unspanned {msg: $"no mark named ($name) \(see `marks`)"}
    }
    cd $target
}

# Bookmarks as a table
export def marks [] {
    load-marks | transpose name path | insert exists {|m| $m.path | path exists }
}

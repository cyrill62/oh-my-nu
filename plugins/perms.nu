# description: Reset permissions (Oh My Zsh's perms): directories 755, files 644
# requires: find

# chmod 755 every directory below DIR (default: current)
export def set755 [dir: path = "."] { ^find $dir -type d -exec chmod 755 '{}' '+' }

# chmod 644 every file below DIR (default: current)
export def set644 [dir: path = "."] { ^find $dir -type f -exec chmod 644 '{}' '+' }

# Directories 755 and files 644 below DIR; asks first
export def fixperms [dir: path = "."] {
    let full = $dir | path expand
    let answer = input $"reset permissions under ($full)? [y/N] "
    if ($answer | str lowercase) in [y yes] {
        set755 $full
        set644 $full
    }
}

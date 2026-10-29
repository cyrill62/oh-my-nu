# description: Copy to the clipboard: copypath, copyfile, copyout (Oh My Zsh's copypath / copyfile)
# requires: wl-copy|xclip|xsel|pbcopy

use ../lib/root.nu [clipcopy]

# Copy the absolute path of a file or directory (default: the current directory)
export def main [path: path = "."] {
    let full = $path | path expand
    clipcopy $full
    print $"copied ($full)"
}

# Copy a file's contents
export def copyfile [file: path] {
    clipcopy (open --raw $file | decode)
    print $"copied ($file) contents"
}

# Copy the input (text, or a table as text): `ls | copyout`
export def copyout [] {
    let input = $in
    let text = if ($input | describe) == string { $input } else { $input | table --expand | ansi strip }
    clipcopy $text
}

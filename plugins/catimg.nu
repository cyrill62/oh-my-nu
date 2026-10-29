# description: Show images in the terminal with Oh My Zsh's catimg.sh (Oh My Zsh's catimg)
# requires: magick|convert

use ../lib/root.nu [omz-plugin-dir]

# Display an image: catimg [-w WIDTH] [-c CHAR] FILE
export def --wrapped main [...args] {
    let script = omz-plugin-dir catimg | path join catimg.sh
    if not ($script | path exists) { error make --unspanned {msg: $"($script) not found (catimg.sh comes with Oh My Zsh)"} }
    let convert = if (which magick | is-not-empty) { "magick" } else { "convert" }
    with-env {CONVERT_CMD: $convert} { ^zsh $script ...$args }
}

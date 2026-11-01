# description: Oh My Zsh's emacs aliases: emacsclient, reusing a frame or opening one
# requires: emacs

# Oh My Zsh's emacsclient.sh: open in an existing frame of the right kind
# (graphical, or tty with -t/-nw), or create one. `-` reads the pipeline input.
def --wrapped launch [...args] {
    let input = $in
    let tty = $args | any {|arg| $arg in [-t --tty -nw] }
    # A tty frame needs the client to stay attached
    let args = if $tty { $args | where $it != --no-wait } else { $args }
    let args = if "-" in $args {
        let file = mktemp --tmpdir emacs-stdin-XXXXXXX
        $input | save --force $file
        $args | each {|arg| if $arg == "-" { $file } else { $arg } }
    } else { $args }
    let check = if $tty { "(memq 't (mapcar 'framep (frame-list)))" } else { "(delete 't (mapcar 'framep (frame-list)))" }
    let frames = do { ^emacsclient -a "" -n -e $check } | complete | get stdout | str replace --regex '.*\x07' '' | str trim
    if $frames in ["" nil] or ($args | is-empty) or $args == [--no-wait] {
        ^emacsclient --alternate-editor="" --create-frame ...$args
    } else {
        ^emacsclient --alternate-editor="" ...$args
    }
}

# Open files in emacs without waiting (`open notes.txt | emacs -` for text)
export def --wrapped main [...rest] { $in | launch --no-wait ...$rest }
# Same as emacs
export def --wrapped e [...rest] { $in | launch --no-wait ...$rest }
# Open files in a terminal frame
export def --wrapped te [...rest] { $in | launch -nw ...$rest }
# Evaluate Emacs Lisp in the running emacs
export def --wrapped eeval [...rest] { launch --eval ...$rest }
export alias eframe = emacsclient --alternate-editor= --create-frame

# The file in emacs' current buffer
export def efile [] {
    let file = launch --eval "(buffer-file-name (window-buffer))" | str trim | str replace --all '"' ''
    if ($file | is-empty) or $file == nil {
        error make --unspanned {msg: "Can't deduce current buffer filename."}
    }
    $file
}

# The directory of the file in emacs' current buffer
export def ecd [] { efile | path dirname }

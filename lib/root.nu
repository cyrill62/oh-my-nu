# Helpers shared by plugins (not a plugin itself).

# Run a command as root: directly when already root, else with
# $env.OMN_SUDO, sudo or doas
export def --wrapped as-root [...cmd] {
    if (is-admin) {
        run-external ...$cmd
    } else {
        let sudo = $env.OMN_SUDO? | default (if (which sudo | is-not-empty) { "sudo" } else { "doas" })
        run-external $sudo ...$cmd
    }
}

# Run a command with the C locale and return its stdout, whatever its exit
# status: table helpers parse English output, and some tools (dnf
# check-update) exit non-zero on success
export def --wrapped c-locale [...cmd] {
    with-env {LC_ALL: C, LANG: C} { run-external ...$cmd | complete } | get stdout
}

# Open a URL or file with the desktop's handler (xdg-open, open, wslview)
export def open-url [url: string] {
    let opener = [xdg-open open wslview] | where {|bin| which $bin | is-not-empty } | get --optional 0
    if $opener == null {
        print $url
    } else {
        run-external $opener $url out+err> /dev/null
    }
}

# A random entry of a fortune file (entries separated by lines holding `%`)
export def random-fortune [file: path] {
    if not ($file | path exists) {
        error make --unspanned {msg: $"($file) not found: these quotes come with Oh My Zsh \(set $env.ZSH to its directory)"}
    }
    let entries = open --raw $file | split row --regex '(?m)^%\n' | str trim | where { is-not-empty }
    $entries | get (random int 0..(($entries | length) - 1))
}

# Directory of an Oh My Zsh plugin ($env.ZSH, default ~/.oh-my-zsh)
export def omz-plugin-dir [plugin: string] {
    $env.ZSH? | default ("~/.oh-my-zsh" | path expand) | path join plugins $plugin
}

# Copy text to the clipboard with wl-copy, xclip, xsel or pbcopy
export def clipcopy [text: string] {
    let tools = [
        [bin, args];
        [wl-copy, []]
        [xclip, [-selection clipboard]]
        [xsel, [--clipboard --input]]
        [pbcopy, []]
    ]
    let tool = $tools | where {|t| which $t.bin | is-not-empty } | get --optional 0
    if $tool == null { error make --unspanned {msg: "no clipboard tool (wl-copy, xclip, xsel or pbcopy)"} }
    $text | run-external $tool.bin ...$tool.args
}

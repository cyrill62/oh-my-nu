# description: VS Code shortcuts for code, code-insiders, codium or cursor (Oh My Zsh's vscode)
# requires: code|code-insiders|codium|cursor

# $env.VSCODE, else the first installed flavour
def editor [] {
    $env.VSCODE? | default ([code code-insiders codium cursor] | where {|bin| which $bin | is-not-empty } | get --optional 0 | default code)
}

# Open files, or the current directory
export def --wrapped vsc [...args] {
    if ($args | is-empty) { run-external (editor) . } else { run-external (editor) ...$args }
}

export def --wrapped vsca [...args] { run-external (editor) '--add' ...$args }
export def --wrapped vscd [...args] { run-external (editor) '--diff' ...$args }
export def --wrapped vscg [...args] { run-external (editor) '--goto' ...$args }
export def --wrapped vscn [...args] { run-external (editor) '--new-window' ...$args }
export def --wrapped vscr [...args] { run-external (editor) '--reuse-window' ...$args }
export def --wrapped vscw [...args] { run-external (editor) '--wait' ...$args }
export def --wrapped vscu [...args] { run-external (editor) '--user-data-dir' ...$args }
export def --wrapped vscp [...args] { run-external (editor) '--profile' ...$args }
export def --wrapped vsced [...args] { run-external (editor) '--extensions-dir' ...$args }
export def --wrapped vscie [...args] { run-external (editor) '--install-extension' ...$args }
export def --wrapped vscue [...args] { run-external (editor) '--uninstall-extension' ...$args }
export def --wrapped vscv [...args] { run-external (editor) '--verbose' ...$args }
export def --wrapped vscl [...args] { run-external (editor) '--log' ...$args }
export def --wrapped vscde [...args] { run-external (editor) '--disable-extensions' ...$args }

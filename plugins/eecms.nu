# description: Oh My Zsh's eecms aliases: ExpressionEngine's eecms console, found in the project
# requires: php

# Run the project's eecms console (searched up to 3 levels down)
export def --wrapped main [...rest] {
    let console = glob --depth 3 **/eecms | where { ($in | path type) == file } | get --optional 0
    if $console == null { error make --unspanned {msg: "no eecms console below the current directory"} }
    ^php $console ...$rest
}

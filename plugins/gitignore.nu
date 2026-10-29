# description: Fetch .gitignore templates from gitignore.io (Oh My Zsh's gitignore): gi rust,python
# requires:

# Print a .gitignore for the given templates: `gi rust python | save .gitignore`
export def gi [...templates: string] {
    if ($templates | is-empty) {
        error make --unspanned {msg: "usage: gi TEMPLATE... (see gi-list)"}
    }
    http get --max-time 10sec $"https://www.toptal.com/developers/gitignore/api/($templates | str join ',' | url encode)"
}

# Template names available on gitignore.io
export def gi-list [] {
    http get --max-time 10sec https://www.toptal.com/developers/gitignore/api/list | str replace --all "\n" ',' | split row ',' | where { is-not-empty }
}

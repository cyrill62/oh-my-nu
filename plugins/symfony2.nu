# description: Symfony console shortcuts (Oh My Zsh's symfony2): sf finds bin/console or app/console
# requires: php

# The project's console script, searched two levels deep like Oh My Zsh
def console [] {
    let found = glob --depth 2 **/console | where { path type | $in == file } | sort-by { str length } | get --optional 0
    if $found == null { error make --unspanned {msg: "no Symfony console script found here"} }
    $found
}

# Run the Symfony console
export def --wrapped sf [...args] { ^php (console) ...$args }

export def --wrapped sfcl [...args] { sf cache:clear ...$args }
export def --wrapped sfsr [...args] { sf server:run -vvv ...$args }
export def --wrapped sfcw [...args] { sf cache:warmup ...$args }
export def --wrapped sfroute [...args] { sf debug:router ...$args }
export def --wrapped sfcontainer [...args] { sf debug:container ...$args }
export def --wrapped sfgb [...args] { sf generate:bundle ...$args }
export def --wrapped sfgc [...args] { sf generate:controller ...$args }
export def --wrapped sfgcom [...args] { sf generate:command ...$args }
export def --wrapped sfge [...args] { sf doctrine:generate:entity ...$args }
export def --wrapped sfsu [...args] { sf doctrine:schema:update ...$args }
export def --wrapped sfdc [...args] { sf doctrine:database:create ...$args }
export def --wrapped sfdev [...args] { sf --env=dev ...$args }
export def --wrapped sfprod [...args] { sf --env=prod ...$args }

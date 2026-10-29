# description: Activate a Poetry project's virtualenv when you cd into it, deactivate when you leave (Oh My Zsh's poetry-env)
# requires: poetry

export-env {
    let hook = {|before, after|
        let root = $env.OMN_POETRY_ENV_ROOT? | default ""
        if ($root | is-not-empty) and not (($after == $root) or ($after | str starts-with $"($root)/")) {
            $env.PATH = ($env.PATH | where {|p| $p != ($env.VIRTUAL_ENV? | default "" | path join bin) })
            hide-env --ignore-errors VIRTUAL_ENV OMN_POETRY_ENV_ROOT
        }
        if ($env.OMN_POETRY_ENV_ROOT? | is-empty) and ($after | path join pyproject.toml | path exists) and ($after | path join poetry.lock | path exists) {
            let venv = do { cd $after; ^poetry env info --path } | complete | get stdout | str trim
            if ($venv | is-not-empty) and ($venv | path join bin | path exists) {
                $env.VIRTUAL_ENV = $venv
                $env.OMN_POETRY_ENV_ROOT = $after
                $env.PATH = ($env.PATH | prepend ($venv | path join bin) | uniq)
            }
        }
    }
    $env.config = ($env.config | upsert hooks.env_change.PWD ($env.config.hooks?.env_change?.PWD? | default [] | append $hook))
}

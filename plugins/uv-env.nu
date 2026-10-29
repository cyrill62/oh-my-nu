# description: Activate a uv project's .venv when you cd into it, deactivate when you leave (Oh My Zsh's uv-env)
# requires: uv

export-env {
    let hook = {|before, after|
        let root = $env.OMN_UV_ENV_ROOT? | default ""
        # Left the project: deactivate.
        if ($root | is-not-empty) and not (($after == $root) or ($after | str starts-with $"($root)/")) {
            $env.PATH = ($env.PATH | where {|p| $p != ($env.VIRTUAL_ENV? | default "" | path join bin) })
            hide-env --ignore-errors VIRTUAL_ENV OMN_UV_ENV_ROOT
        }
        # Entered a uv project: activate its environment.
        if ($env.OMN_UV_ENV_ROOT? | is-empty) and ($after | path join pyproject.toml | path exists) and ($after | path join uv.lock | path exists) {
            let venv = $env.UV_PROJECT_ENVIRONMENT? | default ".venv" | do {|v| if ($v | str starts-with '/') { $v } else { $after | path join $v } } $in
            if ($venv | path join bin/activate | path exists) {
                $env.VIRTUAL_ENV = $venv
                $env.OMN_UV_ENV_ROOT = $after
                $env.PATH = ($env.PATH | prepend ($venv | path join bin) | uniq)
            }
        }
    }
    $env.config = ($env.config | upsert hooks.env_change.PWD ($env.config.hooks?.env_change?.PWD? | default [] | append $hook))
}

# description: python, pip and uv shortcuts (Oh My Zsh's python, pip and uv names)
# requires: python3

export alias py = python3
export alias pyserver = python3 -m http.server
export alias pip = pip3
export alias pipi = python3 -m pip install
export alias pipu = python3 -m pip install --upgrade
export alias pipir = python3 -m pip install --requirement requirements.txt
export alias pipun = python3 -m pip uninstall
export alias pipf = python3 -m pip freeze
export alias piplo = python3 -m pip list --outdated

export alias uvi = uv init
export alias uvinw = uv init --no-workspace
export alias uva = uv add
export alias uvrm = uv remove
export alias uvr = uv run
export alias uvs = uv sync
export alias uvsr = uv sync --refresh
export alias uvsu = uv sync --upgrade
export alias uvl = uv lock
export alias uvlr = uv lock --refresh
export alias uvlu = uv lock --upgrade
export alias uvexp = uv export --format requirements-txt --no-hashes --output-file requirements.txt --quiet
export alias uvp = uv pip
export alias uvpy = uv python
export alias uvpi = uv python install
export alias uvpl = uv python list
export alias uvpu = uv python uninstall
export alias uvpp = uv python pin
export alias uvtr = uv tree
export alias uvup = uv self update
export alias uvv = uv venv

# Installed packages matching a grep pattern
export def --wrapped pipgi [...rest] { ^python3 -m pip freeze | ^grep ...$rest }

# Write the installed packages to requirements.txt
export def pipreq [] { ^python3 -m pip freeze | save --force requirements.txt }

# Python files below the current directory
export def pyfind [] { glob **/*.py | path relative-to $env.PWD }

# grep Python files below the current directory
export def --wrapped pygrep [...rest] { ^grep -nr --include=*.py ...$rest }

# Create a virtualenv (default .venv); activate it with `overlay use .venv/bin/activate.nu`
export def mkv [dir: path = ".venv"] {
    ^python3 -m venv $dir
    print $"activate with: overlay use ($dir)/bin/activate.nu"
}

# Delete __pycache__ directories and .pyc files below the current directory
export def pyclean [] {
    let found = (glob **/__pycache__) ++ (glob **/*.py[co])
    $found | each {|p| if ($p | path exists) { rm --recursive $p } } | ignore
    print $"removed ($found | length) entries"
}

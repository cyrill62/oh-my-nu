# description: python, pip and uv shortcuts
# requires: python3

export alias py = python3
export alias pyserve = python3 -m http.server
export alias pipi = python3 -m pip install
export alias pipu = python3 -m pip install --upgrade
export alias pipr = python3 -m pip install --requirement requirements.txt
export alias pipun = python3 -m pip uninstall
export alias pipf = python3 -m pip freeze
export alias uvr = uv run
export alias uva = uv add
export alias uvs = uv sync
export alias uvl = uv lock
export alias uvp = uv pip

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

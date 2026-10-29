# description: pre-commit shortcuts, using prek when installed (Oh My Zsh's pre-commit)
# requires: prek|pre-commit

def tool [] { if (which prek | is-not-empty) { "prek" } else { "pre-commit" } }

export def --wrapped prc [...args] { run-external (tool) ...$args }

# Update hook versions
export def --wrapped prcau [...args] { run-external (tool) (if (tool) == prek { "auto-update" } else { "autoupdate" }) ...$args }

# Run the hooks on staged files
export def --wrapped prcr [...args] { run-external (tool) run ...$args }

# Run the hooks on all files
export def --wrapped prcra [...args] { run-external (tool) run '--all-files' ...$args }

# Run the hooks on some files
export def --wrapped prcrf [...args] { run-external (tool) run '--files' ...$args }

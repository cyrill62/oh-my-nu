# description: Oh My Zsh's kamal aliases, through the project's bin/kamal when there is one
# requires: kamal|ruby

# ./bin/kamal when the project has one, else the installed kamal
def --wrapped kamal-command [...rest] {
    if ("bin/kamal" | path exists) { ^./bin/kamal ...$rest } else { ^kamal ...$rest }
}

# kamal, through the project's bin/kamal when there is one
export def --wrapped main [...rest] { kamal-command ...$rest }

# Which kamal runs here
export def which-kamal [] {
    if ("bin/kamal" | path exists) { "Using local ./bin/kamal" } else { $"Using global (which --all kamal | where type == external | get --optional 0.path)" }
}

export alias kad = kamal-command deploy

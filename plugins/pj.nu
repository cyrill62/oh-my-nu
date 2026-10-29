# description: Jump to projects under $env.PROJECT_PATHS: pj NAME, pjo NAME opens it in $EDITOR (Oh My Zsh's pj)
# requires:

def roots [] {
    $env.PROJECT_PATHS? | default [~/Projects ~/projects ~/src ~/code]
    | if ($in | describe | str starts-with string) { split row (char esep) } else { $in }
    | path expand
    | where { path exists }
}

def projects [] { roots | each {|root| ls --short-names $root | where type == dir | get name } | flatten | uniq }

def find-project [name: string] {
    let hit = roots | each { path join $name } | where { path exists } | get --optional 0
    if $hit == null { error make --unspanned {msg: $"No such project '($name)'."} }
    $hit
}

# Go to a project
export def --env main [project: string@projects] { cd (find-project $project) }

# Open a project in $EDITOR
export def pjo [project: string@projects] { run-external ($env.EDITOR? | default vi) (find-project $project) }

# description: Oh My Zsh's git-flow aliases for git-flow (AVH edition), plus bugfix/support and a flow-branches table
# requires: git-flow

# A git-flow setting, e.g. branch.develop or prefix.feature
def flow-config [key: string, fallback: string] {
    let value = do { ^git config $"gitflow.($key)" } | complete | get stdout | str trim
    if ($value | is-empty) { $fallback } else { $value }
}

# Name of the current branch without its git-flow prefix (e.g. feature/x -> x)
def current-name [kind: string] {
    let prefix = flow-config $"prefix.($kind)" $"($kind)/"
    let branch = ^git branch --show-current | str trim
    if not ($branch starts-with $prefix) {
        error make --unspanned {msg: $"not on a ($kind) branch \(($branch) does not start with ($prefix))"}
    }
    $branch | str substring ($prefix | str length)..
}

# Switch to the only local branch with a git-flow prefix
def checkout-kind [kind: string] {
    let prefix = flow-config $"prefix.($kind)" $"($kind)/"
    let branches = ^git branch '--format=%(refname:short)' | lines | where { str starts-with $prefix }
    match ($branches | length) {
        0 => { error make --unspanned {msg: $"no ($prefix)* branch"} }
        1 => { ^git checkout ($branches | first) }
        _ => { error make --unspanned {msg: $"several ($prefix)* branches: ($branches | str join ', ')"} }
    }
}

export alias gfl = git flow
export alias gfli = git flow init

# Check out the develop branch (gitflow.branch.develop)
export def gcd [] { ^git checkout (flow-config branch.develop develop) }

# Check out the hotfix branch in progress
export def gch [] { checkout-kind hotfix }

# Check out the release branch in progress
export def gcr [] { checkout-kind release }

export alias gflf = git flow feature
export alias gflfs = git flow feature start
export alias gflff = git flow feature finish
export alias gflfp = git flow feature publish
export alias gflfpll = git flow feature pull
export alias gflfr = git flow feature rebase
export alias gflfd = git flow feature delete

export alias gflb = git flow bugfix
export alias gflbs = git flow bugfix start
export alias gflbf = git flow bugfix finish
export alias gflbp = git flow bugfix publish

export alias gflr = git flow release
export alias gflrs = git flow release start
export alias gflrf = git flow release finish
export alias gflrp = git flow release publish

export alias gflh = git flow hotfix
export alias gflhs = git flow hotfix start
export alias gflhf = git flow hotfix finish
export alias gflhp = git flow hotfix publish

export alias gfls = git flow support
export alias gflss = git flow support start

# Finish the feature branch you are on
export def --wrapped gflffc [...args] { ^git flow feature finish ...$args (current-name feature) }

# Publish the feature branch you are on
export def --wrapped gflfpc [...args] { ^git flow feature publish ...$args (current-name feature) }

# Finish the bugfix branch you are on
export def --wrapped gflbfc [...args] { ^git flow bugfix finish ...$args (current-name bugfix) }

# Finish the release branch you are on
export def --wrapped gflrfc [...args] { ^git flow release finish ...$args (current-name release) }

# Publish the release branch you are on
export def --wrapped gflrpc [...args] { ^git flow release publish ...$args (current-name release) }

# Finish the hotfix branch you are on
export def --wrapped gflhfc [...args] { ^git flow hotfix finish ...$args (current-name hotfix) }

# Publish the hotfix branch you are on
export def --wrapped gflhpc [...args] { ^git flow hotfix publish ...$args (current-name hotfix) }

# git-flow branches in progress as a table: kind, name, branch, current
export def gflt [] {
    let current = ^git branch --show-current | str trim
    let kinds = [feature bugfix release hotfix support] | each {|kind| {kind: $kind, prefix: (flow-config $"prefix.($kind)" $"($kind)/")} }
    ^git branch '--format=%(refname:short)'
    | lines
    | each {|branch|
        let kind = $kinds | where {|k| $branch starts-with $k.prefix } | get --optional 0
        if $kind != null {
            {kind: $kind.kind, name: ($branch | str substring ($kind.prefix | str length)..), branch: $branch, current: ($branch == $current)}
        }
    }
    | compact
}

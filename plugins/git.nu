# description: Oh My Zsh's git aliases, plus helpers returning nushell tables
# requires: git

export alias g = git
export alias ga = git add
export alias gaa = git add --all
export alias gapa = git add --patch
export alias gau = git add --update

export alias gb = git branch
export alias gba = git branch --all
export alias gbd = git branch --delete
export alias gbD = git branch --delete --force
export alias gbl = git blame -w
export alias gbs = git bisect
export alias gbsb = git bisect bad
export alias gbsg = git bisect good
export alias gbsr = git bisect reset
export alias gbss = git bisect start

export alias gc = git commit --verbose
export alias 'gc!' = git commit --verbose --amend
export alias 'gcn!' = git commit --verbose --no-edit --amend
export alias gca = git commit --verbose --all
export alias 'gca!' = git commit --verbose --all --amend
export alias gcam = git commit --all --message
export alias gcmsg = git commit --message
export alias gcsm = git commit --signoff --message

export alias gco = git checkout
export alias gcb = git checkout -b
export alias gcor = git checkout --recurse-submodules
export alias gcf = git config --list
export alias gcl = git clone --recurse-submodules
export alias gclean = git clean --interactive -d
export alias gcount = git shortlog --summary --numbered
export alias gcp = git cherry-pick
export alias gcpa = git cherry-pick --abort
export alias gcpc = git cherry-pick --continue

export alias gd = git diff
export alias gdca = git diff --cached
export alias gds = git diff --staged
export alias gdw = git diff --word-diff

export alias gf = git fetch
export alias gfa = git fetch --all --prune
export alias gfo = git fetch origin

export alias gl = git pull
export alias gpr = git pull --rebase
export alias gp = git push
export alias gpd = git push --dry-run
export alias gpf = git push --force-with-lease --force-if-includes
export alias 'gpf!' = git push --force
export alias gpv = git push --verbose

export alias glg = git log --stat
export alias glgp = git log --stat --patch
export alias glgg = git log --graph
export alias glgga = git log --graph --decorate --all
export alias glo = git log --oneline --decorate
export alias glog = git log --oneline --decorate --graph
export alias gloga = git log --oneline --decorate --graph --all
export alias glol = git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'

export alias gm = git merge
export alias gma = git merge --abort
export alias gms = git merge --squash

export alias gr = git remote
export alias grv = git remote --verbose
export alias gra = git remote add
export alias grmv = git remote rename
export alias grrm = git remote remove
export alias grset = git remote set-url
export alias grup = git remote update

export alias grb = git rebase
export alias grba = git rebase --abort
export alias grbc = git rebase --continue
export alias grbi = git rebase --interactive
export alias grbo = git rebase --onto
export alias grbs = git rebase --skip

export alias grh = git reset
export alias grhh = git reset --hard
export alias grhk = git reset --keep
export alias grhs = git reset --soft
export alias grs = git restore
export alias grss = git restore --source
export alias grst = git restore --staged
export alias grm = git rm
export alias grmc = git rm --cached
export alias grev = git revert

export alias gsh = git show
export alias gst = git status
export alias gss = git status --short
export alias gsb = git status --short --branch

export alias gsta = git stash push
export alias gstaa = git stash apply
export alias gstall = git stash --all
export alias gstc = git stash clear
export alias gstd = git stash drop
export alias gstl = git stash list
export alias gstp = git stash pop
export alias gsts = git stash show --patch

export alias gsw = git switch
export alias gswc = git switch --create
export alias gsi = git submodule init
export alias gsu = git submodule update

export alias gta = git tag --annotate
export alias gts = git tag --sign
export alias gtv = git tag --sort=version:refname

export alias gwt = git worktree
export alias gwta = git worktree add
export alias gwtls = git worktree list
export alias gwtmv = git worktree move
export alias gwtrm = git worktree remove

export alias gignore = git update-index --assume-unchanged
export alias gunignore = git update-index --no-assume-unchanged

# Name of the current branch
export def git-current-branch [] { ^git branch --show-current | str trim }

# Name of the main branch (main, trunk, mainline, default, stable or master)
export def git-main-branch [] {
    for branch in [main trunk mainline default stable master] {
        for ref in [$"refs/heads/($branch)" $"refs/remotes/origin/($branch)" $"refs/remotes/upstream/($branch)"] {
            if (do { ^git show-ref --quiet --verify $ref } | complete).exit_code == 0 {
                return $branch
            }
        }
    }
    "master"
}

# Check out the main branch
export def --wrapped gcm [...rest] { ^git checkout (git-main-branch) ...$rest }

# Rebase onto the main branch
export def --wrapped grbm [...rest] { ^git rebase (git-main-branch) ...$rest }

# Merge the main branch
export def --wrapped gmom [...rest] { ^git merge $"origin/(git-main-branch)" ...$rest }

# Push the current branch and set its upstream to origin
export def --wrapped gpsup [...rest] { ^git push --set-upstream origin (git-current-branch) ...$rest }

# Pull the current branch from origin
export def --wrapped ggl [...rest] { ^git pull origin (git-current-branch) ...$rest }

# Push the current branch to origin
export def --wrapped ggp [...rest] { ^git push origin (git-current-branch) ...$rest }

# Go to the root of the repository
export def --env grt [] { cd (^git rev-parse --show-toplevel | str trim) }

# Commit everything as a "--wip--" commit
export def gwip [] {
    ^git add --all
    ^git commit --no-verify --no-gpg-sign --message "--wip-- [skip ci]"
}

# Undo the last commit if it is a "--wip--" commit, keeping the changes
export def gunwip [] {
    if (^git log -1 --format=%s | str contains "--wip--") {
        ^git reset HEAD~1
    } else {
        print "the last commit is not a --wip-- commit"
    }
}

# Delete local branches merged into the current one (keeps the main branch)
export def gbda [] {
    let keep = [main master develop dev (git-main-branch)]
    ^git branch --merged
    | lines
    | where {|line| not ($line starts-with '*') and not ($line starts-with '+') }
    | str trim
    | where {|branch| $branch not-in $keep }
    | each {|branch| ^git branch --delete $branch | str trim }
}

# Commits as a table: hash, author, date, subject
export def glt [count: int = 20] {
    ^git log $"--max-count=($count)" "--pretty=format:%h%x1f%an%x1f%aI%x1f%s"
    | lines
    | split column "\u{1f}" hash author date subject
    | update date { into datetime }
}

# `git status` as a table: index state, worktree state, file
export def gstt [] {
    ^git status --porcelain=v1
    | lines
    | parse --regex '^(?<index>.)(?<worktree>.) (?<file>.+)$'
}

# Local branches as a table, most recently committed first
export def gbt [] {
    ^git for-each-ref --sort=-committerdate "--format=%(HEAD)%1f%(refname:short)%1f%(upstream:short)%1f%(committerdate:iso-strict)%1f%(contents:subject)" refs/heads
    | lines
    | split column "\u{1f}" current branch upstream date subject
    | update current { $in == '*' }
    | update date { into datetime }
}

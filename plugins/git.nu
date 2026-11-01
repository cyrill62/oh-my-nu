# description: Oh My Zsh's git aliases, plus helpers returning nushell tables
# requires: git

export alias g = git
export alias ga = git add
export alias gaa = git add --all
export alias gapa = git add --patch
export alias gau = git add --update
export alias gav = git add --verbose
export alias gam = git am
export alias gama = git am --abort
export alias gamc = git am --continue
export alias gamscp = git am --show-current-patch
export alias gams = git am --skip
export alias gap = git apply
export alias gapt = git apply --3way

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
export alias gbsn = git bisect new
export alias gbso = git bisect old
export alias gbm = git branch --move
export alias gbnm = git branch --no-merged
export alias gbr = git branch --remotes

export alias gc = git commit --verbose
export alias 'gc!' = git commit --verbose --amend
export alias 'gcn!' = git commit --verbose --no-edit --amend
export alias gca = git commit --verbose --all
export alias 'gca!' = git commit --verbose --all --amend
export alias gcam = git commit --all --message
export alias gcmsg = git commit --message
export alias gcsm = git commit --signoff --message
export alias gcn = git commit --verbose --no-edit
export alias 'gcan!' = git commit --verbose --all --no-edit --amend
export alias 'gcans!' = git commit --verbose --all --signoff --no-edit --amend
export alias 'gcann!' = git commit --verbose --all --date=now --no-edit --amend
export alias gcas = git commit --all --signoff
export alias gcasm = git commit --all --signoff --message
export alias gcs = git commit --gpg-sign
export alias gcss = git commit --gpg-sign --signoff
export alias gcssm = git commit --gpg-sign --signoff --message
export alias gcfu = git commit --fixup

export alias gco = git checkout
export alias gcb = git checkout -b
export alias gcB = git checkout -B
export alias gcor = git checkout --recurse-submodules
export alias gcf = git config --list
export alias gcl = git clone --recurse-submodules
export alias gclf = git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules
export alias gclean = git clean --interactive -d
export alias gcount = git shortlog --summary --numbered
export alias gcp = git cherry-pick
export alias gcpa = git cherry-pick --abort
export alias gcpc = git cherry-pick --continue

export alias gd = git diff
export alias gdca = git diff --cached
export alias gds = git diff --staged
export alias gdw = git diff --word-diff
export alias gdcw = git diff --cached --word-diff
export alias gdup = git diff '@{upstream}'
export alias gdt = git diff-tree --no-commit-id --name-only -r

export alias gf = git fetch
export alias gfa = git fetch --all --prune
export alias gfo = git fetch origin

export alias gg = git gui citool
export alias gga = git gui citool --amend
export alias ghh = git help

export alias gl = git pull
export alias gpr = git pull --rebase
export alias gprv = git pull --rebase --verbose
export alias gpra = git pull --rebase --autostash
export alias gprav = git pull --rebase --autostash --verbose
export alias gp = git push
export alias gpd = git push --dry-run
export alias gpf = git push --force-with-lease --force-if-includes
export alias 'gpf!' = git push --force
export alias gpv = git push --verbose
export alias gpod = git push origin --delete
export alias gpu = git push upstream

export alias glg = git log --stat
export alias glgp = git log --stat --patch
export alias glgg = git log --graph
export alias glgga = git log --graph --decorate --all
export alias glo = git log --oneline --decorate
export alias glog = git log --oneline --decorate --graph
export alias gloga = git log --oneline --decorate --graph --all
export alias glol = git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'
export alias glola = git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --all
export alias glols = git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --stat
export alias glod = git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'
export alias glods = git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short
export alias glgm = git log --graph --max-count=10
export alias gwch = git log --patch --abbrev-commit --pretty=medium --raw

export alias gm = git merge
export alias gma = git merge --abort
export alias gms = git merge --squash
export alias gmc = git merge --continue
export alias gmff = git merge --ff-only
export alias gmtl = git mergetool --no-prompt
export alias gmtlvim = git mergetool --no-prompt --tool=vimdiff

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
export alias grf = git reflog

export alias grh = git reset
export alias grhh = git reset --hard
export alias grhk = git reset --keep
export alias grhs = git reset --soft
export alias gru = git reset --
export alias grs = git restore
export alias grss = git restore --source
export alias grst = git restore --staged
export alias grm = git rm
export alias grmc = git rm --cached
export alias grev = git revert
export alias greva = git revert --abort
export alias grevc = git revert --continue

export alias gsh = git show
export alias gshs = git show --stat
export alias gsps = git show --pretty=short --show-signature
export alias gst = git status
export alias gss = git status --short
export alias gsb = git status --short --branch
export alias gsnut = git status --untracked-files=no

export alias gsta = git stash push
export alias gstu = git stash push --include-untracked
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
export alias gsuri = git submodule update --recursive --init
export alias gsd = git svn dcommit
export alias gsr = git svn rebase

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

# Name of the develop branch (dev, devel, develop or development)
export def git-develop-branch [] {
    for branch in [dev devel develop development] {
        if (do { ^git show-ref --quiet --verify $"refs/heads/($branch)" } | complete).exit_code == 0 {
            return $branch
        }
    }
    "develop"
}

# Check out the main branch
export def --wrapped gcm [...rest] { ^git checkout (git-main-branch) ...$rest }

# Check out the develop branch
export def --wrapped gcd [...rest] { ^git checkout (git-develop-branch) ...$rest }

# Switch to the main branch
export def --wrapped gswm [...rest] { ^git switch (git-main-branch) ...$rest }

# Switch to the develop branch
export def --wrapped gswd [...rest] { ^git switch (git-develop-branch) ...$rest }

# Rebase onto the main branch
export def --wrapped grbm [...rest] { ^git rebase (git-main-branch) ...$rest }

# Rebase onto the main branch, interactively
export def --wrapped grbmi [...rest] { ^git rebase (git-main-branch) --interactive ...$rest }

# Rebase onto the main branch, interactively, with --autosquash
export def --wrapped grbmia [...rest] { ^git rebase (git-main-branch) --interactive --autosquash ...$rest }

# Rebase onto the develop branch
export def --wrapped grbd [...rest] { ^git rebase (git-develop-branch) ...$rest }

# Rebase onto origin's main branch
export def --wrapped grbom [...rest] { ^git rebase $"origin/(git-main-branch)" ...$rest }

# Rebase onto upstream's main branch
export def --wrapped grbum [...rest] { ^git rebase $"upstream/(git-main-branch)" ...$rest }

# Merge the main branch
export def --wrapped gmom [...rest] { ^git merge $"origin/(git-main-branch)" ...$rest }

# Merge upstream's main branch
export def --wrapped gmum [...rest] { ^git merge $"upstream/(git-main-branch)" ...$rest }

# Pull origin's main branch, rebasing
export def --wrapped gprom [...rest] { ^git pull --rebase origin (git-main-branch) ...$rest }

# Pull origin's main branch, rebasing interactively
export def --wrapped gpromi [...rest] { ^git pull --rebase=interactive origin (git-main-branch) ...$rest }

# Pull upstream's main branch, rebasing
export def --wrapped gprum [...rest] { ^git pull --rebase upstream (git-main-branch) ...$rest }

# Pull upstream's main branch, rebasing interactively
export def --wrapped gprumi [...rest] { ^git pull --rebase=interactive upstream (git-main-branch) ...$rest }

# Pull upstream's main branch
export def --wrapped glum [...rest] { ^git pull upstream (git-main-branch) ...$rest }

# Pull the current branch from upstream
export def --wrapped gluc [...rest] { ^git pull upstream (git-current-branch) ...$rest }

# Log of the main branch, as glol
export def --wrapped glolm [...rest] { ^git log (git-main-branch) --graph "--pretty=%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset" ...$rest }

# Commits since the main branch
export def --wrapped glom [...rest] { ^git log --oneline --decorate --color $"(git-main-branch).." ...$rest }

# Push the current branch and set its upstream to origin
export def --wrapped gpsup [...rest] { ^git push --set-upstream origin (git-current-branch) ...$rest }

# Set the current branch's upstream to origin
export def --wrapped ggsup [...rest] { ^git branch $"--set-upstream-to=origin/(git-current-branch)" ...$rest }

# Pull the current branch from origin
export def --wrapped ggl [...rest] { ^git pull origin (git-current-branch) ...$rest }

# Push the current branch to origin
export def --wrapped ggp [...rest] { ^git push origin (git-current-branch) ...$rest }

# Same as ggl
export def --wrapped ggpull [...rest] { ^git pull origin (git-current-branch) ...$rest }

# Same as ggp
export def --wrapped ggpush [...rest] { ^git push origin (git-current-branch) ...$rest }

# Pull a branch from origin, rebasing (default: the current one)
export def ggu [branch?: string] { ^git pull --rebase origin ($branch | default (git-current-branch)) }

# Same as ggu
export def ggpur [branch?: string] { ggu $branch }

# Push every branch and tag to origin
export def gpoat [] {
    ^git push origin --all
    ^git push origin --tags
}

# Reset the current branch to origin's, discarding local changes
export def groh [] { ^git reset $"origin/(git-current-branch)" --hard }

# Discard all changes and remove untracked and ignored files
export def gpristine [] {
    ^git reset --hard
    ^git clean --force -dfx
}

# Discard all changes and remove untracked files
export def gwipe [] {
    ^git reset --hard
    ^git clean --force -df
}

# Describe the latest tag
export def gdct [] { ^git describe --tags (^git rev-list --tags --max-count=1 | str trim) }

# Log with a --pretty format (oneline, short, full...)
export def glp [format: string] { ^git log $"--pretty=($format)" }

# Tags starting with a prefix, newest version first, with their messages
export def gtl [prefix: string = ""] { ^git tag --sort=-v:refname -n --list $"($prefix)*" }

# Tracked files matching a grep pattern
export def --wrapped gfg [...rest] { ^git ls-files | ^grep ...$rest }

# Files marked --assume-unchanged (gignore)
export def gignored [] { ^git ls-files -v | lines | where $it =~ '^[a-z]' }

# Local branches whose upstream is gone
def gone-branches [] {
    with-env {LC_ALL: C, LANG: C} { ^git branch --no-color -vv } | lines | where $it =~ ': gone\]'
}

# Local branches whose upstream is gone (git branch -vv lines)
export def gbg [] { gone-branches }

# Delete the local branches whose upstream is gone
export def gbgd [] {
    for branch in (gone-branches | each { str substring 2.. | split row ' ' | first }) { ^git branch --delete $branch }
}

# Force-delete the local branches whose upstream is gone
export def gbgD [] {
    for branch in (gone-branches | each { str substring 2.. | split row ' ' | first }) { ^git branch --delete --force $branch }
}

# git svn dcommit, then push the main branch to github's svntrunk
export def git-svn-dcommit-push [] {
    ^git svn dcommit
    ^git push github $"(git-main-branch):svntrunk"
}

# gitk on all branches, in the background
export def --wrapped gk [...rest] { ^sh -c 'gitk --all --branches "$@" >/dev/null 2>&1 &' gk ...$rest }

# gitk on all branches and reflog commits, in the background
export def --wrapped gke [...rest] {
    let reflog = ^git log --walk-reflogs --pretty=%h | lines
    ^sh -c 'gitk --all "$@" >/dev/null 2>&1 &' gke ...$reflog ...$rest
}

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

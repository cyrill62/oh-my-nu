# description: Conventional commits: gcfeat MSG, gcfix -s SCOPE MSG, -a for a breaking change (Oh My Zsh's git-commit)
# requires: git
#
# Oh My Zsh adds these as global git aliases (`git feat ...`) by editing
# ~/.gitconfig; here they are plain commands and your git config is left alone.

def commit [type: string, scope: any, attention: bool, words: list<string>] {
    let scope_part = if ($scope | is-empty) { "" } else { $"\(($scope))" }
    let bang = if $attention { "!" } else { "" }
    ^git commit -m $"($type)($scope_part)($bang): ($words | str join ' ')"
}

# feat: commit
export def gcfeat [--scope (-s): string, --attention (-a), ...message: string] { commit feat $scope $attention $message }
# fix: commit
export def gcfix [--scope (-s): string, --attention (-a), ...message: string] { commit fix $scope $attention $message }
# build: commit
export def gcbuild [--scope (-s): string, --attention (-a), ...message: string] { commit build $scope $attention $message }
# chore: commit
export def gcchore [--scope (-s): string, --attention (-a), ...message: string] { commit chore $scope $attention $message }
# ci: commit
export def gcci [--scope (-s): string, --attention (-a), ...message: string] { commit ci $scope $attention $message }
# docs: commit
export def gcdocs [--scope (-s): string, --attention (-a), ...message: string] { commit docs $scope $attention $message }
# perf: commit
export def gcperf [--scope (-s): string, --attention (-a), ...message: string] { commit perf $scope $attention $message }
# refactor: commit
export def gcrefactor [--scope (-s): string, --attention (-a), ...message: string] { commit refactor $scope $attention $message }
# revert: commit
export def gcrev [--scope (-s): string, --attention (-a), ...message: string] { commit revert $scope $attention $message }
# style: commit
export def gcstyle [--scope (-s): string, --attention (-a), ...message: string] { commit style $scope $attention $message }
# test: commit
export def gctest [--scope (-s): string, --attention (-a), ...message: string] { commit test $scope $attention $message }
# wip: commit
export def gcwip [--scope (-s): string, --attention (-a), ...message: string] { commit wip $scope $attention $message }

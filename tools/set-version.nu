#!/usr/bin/env nu
# Copies the VERSION file into oh-my-nu.nu (shown by `omn --version`).
#
#   tools/set-version.nu            sync oh-my-nu.nu with VERSION
#   tools/set-version.nu 0.2.0      write VERSION, then sync
#   tools/set-version.nu minor      bump major, minor or patch, then sync
#   tools/set-version.nu --check    fail if oh-my-nu.nu and VERSION differ

const ROOT = path self | path dirname | path dirname
const VERSION_FILE = $ROOT | path join VERSION
const MANAGER = $ROOT | path join oh-my-nu.nu
const LINE = '(?m)^const VERSION = "([^"]*)"$'
const SEMVER = '^\d+\.\d+\.\d+(-[0-9A-Za-z.-]+)?$'

def fail [msg: string] {
    print --stderr $"set-version: ($msg)"
    exit 1
}

def read-version [] {
    let version = open --raw $VERSION_FILE | str trim
    if $version !~ $SEMVER { fail $"VERSION holds '($version)', not MAJOR.MINOR.PATCH" }
    $version
}

def bump [version: string, part: string] {
    let n = $version | str replace --regex '-.*' '' | split row '.' | into int
    match $part {
        major => [($n.0 + 1) 0 0]
        minor => [$n.0 ($n.1 + 1) 0]
        patch => [$n.0 $n.1 ($n.2 + 1)]
    } | str join '.'
}

def main [
    version?: string  # new version (MAJOR.MINOR.PATCH[-PRE]) or major, minor, patch
    --check           # only check that oh-my-nu.nu matches VERSION
] {
    let source = open --raw $MANAGER
    let current = $source | parse --regex $LINE | get 0?.capture0
    if $current == null { fail $"no `const VERSION = \"...\"` line in ($MANAGER)" }

    if $check {
        let wanted = read-version
        if $current != $wanted { fail $"oh-my-nu.nu has ($current), VERSION has ($wanted): run tools/set-version.nu" }
        print $"oh-my-nu.nu and VERSION agree: ($wanted)"
        return
    }

    if $version != null {
        let new = if $version in [major minor patch] { bump (read-version) $version } else { $version }
        if $new !~ $SEMVER { fail $"'($version)' is not MAJOR.MINOR.PATCH[-PRE] or major, minor, patch" }
        $"($new)\n" | save --force $VERSION_FILE
    }

    let wanted = read-version
    if $current == $wanted {
        print $"already ($wanted)"
        return
    }
    $source | str replace --regex $LINE $'const VERSION = "($wanted)"' | save --force $MANAGER
    print $"($current) -> ($wanted)"
}

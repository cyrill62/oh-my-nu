# Installs or updates oh-my-nu from its latest GitHub release, then enables plugins.
#
#   nu -c (http get https://cyrill62.github.io/oh-my-nu/install.nu)
#
# It installs into $OMN_HOME (default ~/.local/share/oh-my-nu) and runs its
# install.nu, which enables a default set or the plugins given. Run it again to
# update: the enabled plugins are kept, and `omn sync` reloads them.
# OMN_VERSION picks a release (0.1.0); OMN_RELEASE_DIR takes the files from a
# local directory instead of GitHub (used by the tests).

const REPO = "cyrill62/oh-my-nu"

def fetch [name: string, tag: string, dest: path] {
    let local = $env.OMN_RELEASE_DIR? | default ""
    if $local != "" {
        cp ($local | path join $name) $dest
    } else {
        http get --raw $"https://github.com/($REPO)/releases/download/($tag)/($name)" | save --raw --force $dest
    }
}

def main [...plugins: string] {
    let data = $env.XDG_DATA_HOME? | default ($nu.home-dir | path join .local share)
    let home = $env.OMN_HOME? | default ($data | path join oh-my-nu) | path expand
    let version = $env.OMN_VERSION? | default {
        try {
            http get $"https://api.github.com/repos/($REPO)/releases/latest" | get tag_name
        } catch {|err|
            error make --unspanned {msg: $"can't find the latest release of ($REPO) \(none published yet?\): ($err.msg)"}
        }
    } | str replace --regex '^v' ''
    let tag = $"v($version)"
    let name = $"oh-my-nu-($version)"

    let updating = $home | path exists
    if $updating {
        if ($home | path join .git | path exists) {
            error make --unspanned {msg: $"($home) is a git clone: update it with git pull"}
        }
        if not ($home | path join oh-my-nu.nu | path exists) {
            error make --unspanned {msg: $"($home) exists and is not oh-my-nu: set OMN_HOME to install elsewhere"}
        }
    }

    let tmp = mktemp --directory --tmpdir oh-my-nu.XXXXXX
    try {
        print $"downloading oh-my-nu ($version)..."
        let archive = $tmp | path join $"($name).tar.gz"
        fetch $"($name).tar.gz" $tag $archive
        fetch SHA256SUMS $tag ($tmp | path join SHA256SUMS)
        let expected = open --raw ($tmp | path join SHA256SUMS)
            | parse --regex '(?m)^(?<sum>[0-9a-f]{64}) [ *](?<file>\S+)$'
            | where file == $"($name).tar.gz" | get sum.0? | default ""
        let actual = open --raw $archive | hash sha256
        if $expected != $actual {
            error make --unspanned {msg: $"($name).tar.gz: checksum mismatch \(expected '($expected)', got ($actual)\)"}
        }
        ^tar -xzf $archive -C $tmp

        # Swap the directories, so a failure above leaves the old install alone.
        mkdir ($home | path dirname)
        if $updating { mv $home ($tmp | path join old) }
        mv ($tmp | path join $name) $home
    } catch {|err|
        rm --recursive --force $tmp
        error make --unspanned {msg: $err.msg}
    }
    rm --recursive --force $tmp

    if $updating and ($plugins | is-empty) {
        ^$nu.current-exe --no-config-file --commands $"use ($home | path join oh-my-nu.nu | to nuon) *; omn sync"
    } else {
        ^$nu.current-exe --no-config-file ($home | path join install.nu) ...$plugins
    }
    print $"oh-my-nu ($version) is in ($home): open a new shell, then try omn help"
}

# Test suite: `nu tests/run.nu` (set OMN_TEST_DIR to choose the scratch dir).
use std/assert

const ROOT = path self | path dirname | path dirname

def nu-run [code: string] {
    # A scratch HOME: plugins with startup code (ssh-agent...) never touch the real one.
    let home = $env.OMN_TEST_HOME
    let result = with-env {HOME: $home, ZSH: "", TZ: "UTC"} { ^$nu.current-exe --no-config-file --commands $code | complete }
    if $result.exit_code != 0 {
        error make --unspanned {msg: $"nu failed: ($code)\n($result.stderr)"}
    }
    $result
}

def plugin-files [] { glob ($ROOT | path join plugins/*.nu) | sort }

# Every plugin parses on its own, without warnings.
def test-parse [] {
    for file in (plugin-files) {
        let result = nu-run $"use ($file | to nuon) *"
        assert equal $result.stderr "" $"($file) printed: ($result.stderr)"
    }
}

# No plugin replaces a nushell command, and no name is defined twice.
def test-names [] {
    let builtins = nu-run "scope commands | where type != custom | get name | to nuon" | get stdout | from nuon
    let exports = plugin-files | each {|file|
        let stem = $file | path parse | get stem
        let code = $"use ($file | to nuon); scope modules | where name == ($stem | to nuon) | first | [...\($in.commands.name) ...\($in.aliases.name)] | to nuon"
        nu-run $code | get stdout | from nuon | each {|name|
            {plugin: $stem, name: (if $name == main { $stem } else { $name })}
        }
    } | flatten
    let shadowing = $exports | where name in $builtins
    assert ($shadowing | is-empty) $"shadow nushell commands: ($shadowing | to nuon)"
    # Plugins may share names (as in Oh My Zsh), but not within the default set.
    let defaults = open --raw ($ROOT | path join install.nu) | parse --regex 'let defaults = \[(?<names>[^\]]+)\]' | get 0.names | split row ' '
    let dupes = $exports | where plugin in $defaults | group-by name | items {|name, rows| {name: $name, plugins: ($rows.plugin)} } | where { ($in.plugins | length) > 1 }
    assert ($dupes | is-empty) $"defined twice in the default set: ($dupes | to nuon)"
    print $"  ($exports | length) aliases and commands"
}

# enable / disable / sync / custom plugins, in a sandboxed config.
def test-manager [dir: path] {
    let cfg = $dir | path join cfg
    let autoload = $dir | path join autoload/oh-my-nu.nu
    mkdir ($cfg | path join custom)
    "# description: needs a missing tool\n# requires: no-such-tool-xyz\nexport alias zz = echo" | save ($cfg | path join custom/needs.nu)
    "# description: my git\n# requires:\nexport alias gmine = echo mine" | save ($cfg | path join custom/git.nu)
    let env_code = $"$env.OMN_CONFIG_DIR = ($cfg | to nuon); $env.OMN_AUTOLOAD_FILE = ($autoload | to nuon); use ($ROOT | path join oh-my-nu.nu | to nuon) *"

    let out = nu-run $"($env_code); omn enable common needs git cargo" | get stdout
    assert str contains $out "3 plugins"
    assert str contains $out "skipped needs: no-such-tool-xyz not found"
    let text = open --raw $autoload
    assert str contains $text "custom/git.nu"
    assert not ($text | str contains "needs.nu")

    let loaded = nu-run $"$env.OMN_CONFIG_DIR = ($cfg | to nuon); source ($autoload | to nuon); [\(scope aliases | where name in [ll gmine cb gst] | get name | sort) \(omn list | where enabled | get name)] | to nuon" | get stdout | from nuon
    assert equal $loaded.0 [cb gmine ll]
    assert equal $loaded.1 [cargo common git needs]
    let only = nu-run $"($env_code); [\(omn list --enabled | get name) \(omn list -e | where status == loaded | get name)] | to nuon" | get stdout | from nuon
    assert equal $only.0 [cargo common git needs]
    assert equal $only.1 [cargo common git]

    # --loaded / --failed, including a plugin that does not parse
    "# description: broken\n# requires:\nexport def oops [] { (\n" | save ($cfg | path join custom/broken.nu)
    let sync_out = nu-run $"($env_code); omn enable broken" | get stdout
    assert str contains $sync_out "error in broken, not loaded: Unclosed delimiter"
    assert not (open --raw $autoload | str contains "broken.nu")
    let states = nu-run $"($env_code); {loaded: \(omn list --loaded | get name), failed: \(omn list --failed | select name status)} | to nuon" | get stdout | from nuon
    assert equal $states.loaded [cargo common git]
    assert equal ($states.failed | get name) [broken needs]
    assert (($states.failed | where name == broken | get 0.status) | str starts-with "error: Unclosed delimiter (line 3)")
    assert equal ($states.failed | where name == needs | get 0.status) "skipped: needs no-such-tool-xyz"
    nu-run $"($env_code); omn disable broken" | ignore
    rm ($cfg | path join custom/broken.nu)

    # help: every command with its options, and one command in detail
    let overview = nu-run $"($env_code); omn help" | get stdout
    assert str contains $overview "omn list [--enabled (-e)]"
    assert str contains $overview "--enabled, -e"
    assert str contains $overview "e.g. omn list --enabled"
    assert str contains (nu-run $"($env_code); omn help list" | get stdout) "only the enabled plugins"
    assert str contains (nu-run $"($env_code); omn --help" | get stdout) "omn list --enabled"

    # version: the manager's constant follows the VERSION file
    let version = open --raw ($ROOT | path join VERSION) | str trim
    assert equal (nu-run $"($env_code); omn --version" | get stdout | str trim) $"oh-my-nu ($version)"
    assert equal (nu-run $"($env_code); omn -v" | get stdout | str trim) $"oh-my-nu ($version)"
    assert str contains $overview $"oh-my-nu ($version):"
    assert str contains $overview "omn [--version (-v)]"
    nu-run $"^($nu.current-exe) -n ($ROOT | path join tools/set-version.nu | to nuon) --check" | ignore

    nu-run $"($env_code); omn disable cargo needs" | ignore
    assert equal (open ($cfg | path join plugins.nuon)) [common git]
    assert not (open --raw $autoload | str contains "cargo.nu")

    "# description: one\n# requires:\nexport alias zzdup = echo one" | save ($cfg | path join custom/clash1.nu)
    "# description: two\n# requires:\nexport alias zzdup = echo two" | save ($cfg | path join custom/clash2.nu)
    let clash = nu-run $"($env_code); omn enable clash1 clash2" | get stdout
    assert str contains $clash "zzdup: clash1, clash2"
    let clashes = nu-run $"($env_code); omn clashes | to nuon" | get stdout | from nuon
    assert equal $clashes [{name: zzdup, plugins: [clash1 clash2], wins: clash2}]
    nu-run $"($env_code); omn disable clash1 clash2" | ignore

    let bad = ^$nu.current-exe --no-config-file --commands $"($env_code); omn enable nope" | complete
    assert not equal $bad.exit_code 0
    assert str contains $bad.stderr "unknown plugin: nope"

    let aliases = nu-run $"($env_code); omn aliases extract | to nuon" | get stdout | from nuon
    assert equal ($aliases | get name) [extract]
}

# extract handles each archive type and --remove.
def test-extract [dir: path] {
    let work = $dir | path join extract
    mkdir $work
    cd $work
    "hello" | save data.txt
    ^tar czf a.tar.gz data.txt
    ^tar --zstd -cf a.tar.zst data.txt
    ^tar cJf a.tar.xz data.txt
    ^python3 -m zipfile -c a.zip data.txt
    ^7z a -bso0 a.7z data.txt
    ^gzip --keep --stdout data.txt | save b.txt.gz
    for archive in [a.tar.gz a.tar.zst a.tar.xz a.zip a.7z] {
        let out = $dir | path join $"out-($archive)"
        mkdir $out
        cd $out
        nu-run $"use ($ROOT | path join plugins/extract.nu | to nuon) *; extract ($work | path join $archive | to nuon) out+err> /dev/null" | ignore
        assert equal (open data.txt) "hello" $archive
        cd $work
    }
    nu-run $"use ($ROOT | path join plugins/extract.nu | to nuon) *; extract --remove b.txt.gz" | ignore
    assert equal (open b.txt) "hello"
    assert not ("b.txt.gz" | path exists)
    "x" | save c.unknown
    let bad = ^$nu.current-exe --no-config-file --commands $"use ($ROOT | path join plugins/extract.nu | to nuon) *; extract c.unknown" | complete
    assert str contains $bad.stderr "unknown archive type"
}

# git helpers return tables in a real repository.
def test-git [dir: path] {
    let repo = $dir | path join repo
    mkdir $repo
    cd $repo
    ^git init --quiet --initial-branch=main | ignore
    ^git config user.email t@example.invalid
    ^git config user.name tester
    "a" | save a.txt
    ^git add a.txt
    ^git commit --quiet -m "first"
    ^git branch merged-feature
    "b" | save b.txt
    let plugin = $ROOT | path join plugins/git.nu | to nuon
    let result = nu-run $"use ($plugin) *; {
        main: \(git-main-branch), current: \(git-current-branch),
        log: \(glt | get subject), status: \(gstt), branches: \(gbt | select current branch)
    } | to nuon" | get stdout | from nuon
    assert equal $result.main main
    assert equal $result.current main
    assert equal $result.log [first]
    assert equal $result.status [{index: "?", worktree: "?", file: "b.txt"}]
    assert equal ($result.branches | where current | get branch) [main]

    nu-run $"use ($plugin) *; gwip out+err> /dev/null" | ignore
    assert equal (^git log -1 --format=%s | str trim) "--wip-- [skip ci]"
    nu-run $"use ($plugin) *; gunwip out+err> /dev/null" | ignore
    assert equal (^git log -1 --format=%s | str trim) "first"

    nu-run $"use ($plugin) *; gbda out+err> /dev/null" | ignore
    assert equal (^git branch '--format=%(refname:short)' | lines) [main]
}

# rmux helpers against a throwaway server (an `rmux` wrapper on PATH).
def test-rmux [dir: path] {
    if (which rmux | is-empty) { print "  (rmux not installed, skipped)"; return }
    let bin = $dir | path join bin
    mkdir $bin
    let real = which rmux | get 0.path
    $"#!/bin/sh\nexec ($real) -L omn-test-($nu.pid) \"$@\"\n" | save ($bin | path join rmux)
    chmod +x ($bin | path join rmux)
    let code = $"$env.PATH = \($env.PATH | prepend ($bin | to nuon)); use ($ROOT | path join plugins/rmux.nu | to nuon) *"
    nu-run $"($code); ts omntest -d; ^rmux new-window -t omntest" | ignore
    let result = nu-run $"($code); {sessions: \(tst | select name windows attached), windows: \(twt omntest | get index)} | to nuon" | get stdout | from nuon
    nu-run $"($code); tksv" | ignore
    assert equal $result.sessions [{name: omntest, windows: 2, attached: false}]
    assert equal $result.windows [0 1]
}

# Distro plugins against fake package managers that print canned output.
def test-distro [dir: path] {
    let bin = $dir | path join bin
    mkdir $bin
    let fake = '#!/bin/sh
name=$(basename "$0")
case "$name $*" in
  "apt list --upgradable") printf "Listing... Done\nbash/stable 5.2-2 amd64 [upgradable from: 5.2-1]\n" ;;
  "apt-mark showmanual") printf "vim\ngit\n" ;;
  "dpkg-query --show"*) printf "ii \tbash\t5.2-1\tamd64\t7000\nrc \told\t1.0\tamd64\t10\nii \tvim\t9.0\tamd64\t3000\n" ;;
  "rpm --query --all"*) printf "bash\t5.2-1.fc40\tx86_64\t8000000\t1700000000\nvim\t9.0-1.fc40\tx86_64\t3000000\t1700000100\n" ;;
  "dnf check-update --quiet") printf "\nbash.x86_64     5.2-2.fc40     updates\n"; exit 100 ;;
  "pacman -Qe") printf "bash 5.2-1\nvim 9.0-1\n" ;;
  "pacman -Qu") printf "vim 9.0-1 -> 9.1-1\n" ;;
  "pacman -Qdtq") ;;
  "pacman -Qi") printf "Name            : bash\nInstalled Size  : 9.50 MiB\n\nName            : vim\nInstalled Size  : 1.20 MiB\n\n" ;;
  "yay -Qm") printf "foo-git r1-1\n" ;;
  "yay -Qua") printf "foo-git r1-1 -> r2-1\n" ;;
  "systemctl list-units --output=json") printf '[{"unit":"ssh.service","load":"loaded","active":"active","sub":"running","description":"OpenSSH"}]' ;;
  sudo*) printf "SUDO "; exec "$@" ;;
  *) echo "RAN $name $*" ;;
esac
'
    $fake | save ($bin | path join fake)
    chmod +x ($bin | path join fake)
    for name in [apt apt-get apt-cache apt-mark dpkg dpkg-query dpkg-reconfigure rpm dnf yum pacman yay sudo tmux systemctl zypper snap] {
        ^ln -sf fake ($bin | path join $name)
    }
    "Start-Date: 2026-10-01  10:00:00\nCommandline: apt install vim\nRequested-By: me (1000)\nInstall: vim:amd64 (9.0)\nEnd-Date: 2026-10-01  10:00:05\n\nStart-Date: 2026-10-02  11:00:00\nCommandline: apt upgrade\nEnd-Date: 2026-10-02  11:01:00\n" | save ($dir | path join history.log)

    let plugins = [apt dpkg rpm yum pacman yay rmux systemd dnf suse snap] | each {|name| $"use ($ROOT | path join plugins $'($name).nu' | to nuon) *" } | str join "; "
    let setup = $"$env.PATH = \($env.PATH | prepend ($bin | to nuon)); $env.OMN_SUDO = ($bin | path join sudo | to nuon); ($plugins)"
    def run-in [code: string] { nu-run $"($setup); ($code)" | get stdout | str trim }
    def table-of [code: string] { run-in $"($code) | to nuon" | from nuon }

    # Commands: the exact command line, and root only where needed.
    for case in [
        ["apti vim", "SUDO RAN apt install vim"]
        ["aptuu", "SUDO RAN apt update\nSUDO RAN apt upgrade"]
        ["apts foo", "RAN apt search foo"]
        ["dpi x.deb", "SUDO RAN dpkg --install x.deb"]
        ["dpown /bin/ls", "RAN dpkg --search /bin/ls"]
        ["rpmqf /bin/ls", "RAN rpm --query --file /bin/ls"]
        ["rpmi x.rpm", "SUDO RAN rpm --upgrade --verbose --hash x.rpm"]
        ["yi vim -y", "SUDO RAN dnf install vim -y"]
        ["yli", "RAN dnf list --installed"]
        ["$env.OMN_YUM = 'yum'; yu", "SUDO RAN yum upgrade"]
        ["pacupg", "SUDO RAN pacman -Syu"]
        ["pacrem vim", "SUDO RAN pacman -Rns vim"]
        ["pacown /bin/ls", "RAN pacman -Qo /bin/ls"]
        ["pacrmorphans", "no orphans"]
        ["yaupg", "RAN yay -Syu"]
        ["yarem foo", "RAN yay -Rns foo"]
        ["$env.OMN_MUX = 'tmux'; tkss work", "RAN tmux kill-session -t work"]
        ["sc-restart sshd", "SUDO RAN systemctl restart sshd"]
        ["sc-enable-now sshd", "SUDO RAN systemctl enable --now sshd"]
        ["sc-status sshd", "RAN systemctl status sshd"]
        ["scu-restart pipewire", "RAN systemctl --user restart pipewire"]
        ["dnfi vim", "SUDO RAN dnf install vim"]
        ["dnfs vim", "RAN dnf search vim"]
        ["zin vim", "SUDO RAN zypper install vim"]
        ["si code --classic", "SUDO RAN snap install code --classic"]
    ] {
        assert equal (run-in $case.0) $case.1 $case.0
    }

    # Tables parsed from the canned output.
    assert equal (table-of aptup) [{package: bash, suite: stable, version: "5.2-2", arch: amd64, current: "5.2-1"}]
    assert equal (table-of aptman) [vim git]
    let history = table-of $"apth --file ($dir | path join history.log | to nuon)"
    assert equal ($history | get command) ["apt install vim" "apt upgrade"]
    assert equal ($history | get by) ["me (1000)" null]
    assert equal (table-of "dpls | get package") [bash vim]
    assert equal (table-of "dpsz 1 | get 0.size | into int") 7168000
    assert equal (table-of "rpmls vim | get package") [vim]
    assert equal (table-of "rpmlast 1 | get package") [vim]
    assert equal (table-of ycu) [{package: bash, arch: x86_64, version: "5.2-2.fc40", repo: updates}]
    assert equal (table-of "pacexp | get package") [bash vim]
    assert equal (table-of pacout) [{package: vim, current: "9.0-1", version: "9.1-1"}]
    assert equal (table-of "pacsz | get package") [bash vim]
    assert equal (table-of "sct | get unit") [ssh.service]
    assert equal (table-of yaaur) [{package: foo-git, version: r1-1}]
    assert equal (table-of yaout) [{package: foo-git, current: r1-1, version: r2-1}]
}

# Utility plugins (no external tools, or fake ones).
def test-utils [dir: path] {
    mkdir $dir
    let bin = $dir | path join bin
    mkdir $bin
    let clip = $dir | path join clipboard.txt
    $"#!/bin/sh\ncat > ($clip)\n" | save ($bin | path join wl-copy)
    chmod +x ($bin | path join wl-copy)
    let use = [jump dotenv genpass encode64 urltools jsontools isodate perms copypath colored-man-pages]
        | each {|name| $"use ($ROOT | path join plugins $'($name).nu' | to nuon) *" } | str join "; "
    let setup = $"$env.OMN_CONFIG_DIR = ($dir | path join cfg | to nuon); $env.PATH = \($env.PATH | prepend ($bin | to nuon)); ($use)"
    def run-in [code: string] { nu-run $"($setup); ($code)" | get stdout | str trim }

    # jump: mark, jump, list, unmark
    let place = $dir | path join some/place
    mkdir $place
    assert equal (run-in $"cd ($place | to nuon); mark spot; cd /; jump spot; pwd" | lines | last) $place
    assert equal (run-in "marks | get name | to nuon" | from nuon) [spot]
    assert equal (run-in "unmark spot; marks | length") "0"

    # dotenv: comments, export, quotes, inline comments
    "# comment\nexport A=1\nB=\"two words\"\nC='x # y'\nD=plain # note\n\nbad line\n" | save ($dir | path join .env)
    let loaded = run-in $"cd ($dir | to nuon); dotenv; [$env.A $env.B $env.C $env.D] | to nuon" | lines | last | from nuon
    assert equal $loaded ["1" "two words" "x # y" plain]

    # genpass
    assert equal (run-in "genpass 30 | str length") "30"
    assert equal (run-in "genpass -n 3 | length") "3"
    assert ((run-in "genpass-apple") =~ '^[a-z0-9A-Z]{6}-[a-z0-9A-Z]{6}-[a-z0-9A-Z]{6}$')

    # encode64, urltools, jsontools
    assert equal (run-in "e64 'hello world'") "aGVsbG8gd29ybGQ="
    assert equal (run-in "'aGVsbG8gd29ybGQ=' | d64") "hello world"
    assert equal (run-in "encode64 hi") "aGk="
    assert equal (run-in "urlencode 'a b&c'") "a%20b%26c"
    assert equal (run-in "'a%20b' | urldecode") "a b"
    assert equal (run-in "'{\"a\":1}' | is_json") "true"
    assert equal (run-in "'{nope' | is_json") "false"
    assert equal (run-in "'{\"a\":[1]}' | pp_json | from json | to nuon") "{a: [1]}"

    # isodate
    assert ((run-in "isodate") =~ '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{4}$')
    assert ((run-in "isodate_basic_utc") =~ '^\d{8}T\d{6}Z$')

    # perms
    let tree = $dir | path join perms
    mkdir ($tree | path join sub)
    "x" | save ($tree | path join sub/f)
    ^chmod 700 ($tree | path join sub)
    ^chmod 600 ($tree | path join sub/f)
    run-in $"set755 ($tree | to nuon); set644 ($tree | to nuon)" | ignore
    assert equal (^stat -c '%a' ($tree | path join sub) | str trim) "755"
    assert equal (^stat -c '%a' ($tree | path join sub/f) | str trim) "644"

    # copypath through a fake wl-copy
    run-in $"copypath ($place | to nuon)" | ignore
    assert equal (open --raw $clip) $place

    # colored-man-pages sets less colours on load
    assert equal (run-in "$env.LESS_TERMCAP_md | ansi strip | str length") "0"
    assert equal (run-in "$env.GROFF_NO_SGR") "1"
}

# git-flow-avh against the real git-flow, in a scratch repository.
def test-git-flow [dir: path] {
    if (which git-flow | is-empty) { print "  (git-flow not installed, skipped)"; return }
    let repo = $dir | path join repo
    mkdir $repo
    cd $repo
    ^git init --quiet --initial-branch=main
    ^git config user.email t@example.invalid
    ^git config user.name tester
    "a" | save a.txt
    ^git add a.txt
    ^git commit --quiet -m first
    let plugin = $"use ($ROOT | path join plugins/git-flow-avh.nu | to nuon) *"
    def flow [code: string] { nu-run $"($plugin); ($code)" | get stdout | str trim }

    flow "gfli -d out+err> /dev/null" | ignore
    assert equal (^git branch --show-current | str trim) develop
    flow "gflfs login out+err> /dev/null; gflbs crash out+err> /dev/null" | ignore
    assert equal (^git branch --show-current | str trim) bugfix/crash
    let open = flow "gflt | select kind name current | to nuon" | from nuon
    assert equal $open [{kind: bugfix, name: crash, current: true} {kind: feature, name: login, current: false}]

    # finish the current branch without naming it
    ^git checkout --quiet feature/login
    "b" | save b.txt
    ^git add b.txt
    ^git commit --quiet -m login
    flow "gflffc out+err> /dev/null" | ignore
    assert equal (^git branch --show-current | str trim) develop
    assert ((^git log --format=%s develop | lines) | any { $in == login })
    assert not ((flow "gflt | get name | to nuon" | from nuon) | any { $in == login })

    # gcd / gcr follow the configured names
    flow "gflrs 1.0 out+err> /dev/null; gcd out+err> /dev/null" | ignore
    assert equal (^git branch --show-current | str trim) develop
    flow "gcr out+err> /dev/null" | ignore
    assert equal (^git branch --show-current | str trim) release/1.0
    let wrong = ^$nu.current-exe --no-config-file --commands $"($plugin); gcd; gflffc" | complete
    assert str contains $wrong.stderr "not on a feature branch"
}

# Ports of Oh My Zsh function plugins, and a sample of the generated ones.
def test-ports [dir: path] {
    mkdir $dir
    let bin = $dir | path join bin
    mkdir $bin
    let opened = $dir | path join opened.txt
    let fake = '#!/bin/sh
name=$(basename "$0")
case "$name" in
  xdg-open) echo "$1" >> OPENED ;;
  aws) [ "$1 $2 $3" = "configure get region" ] && echo eu-west-3 ;;
  *) echo "RAN $name $*" ;;
esac
' | str replace OPENED $opened
    $fake | save ($bin | path join fake)
    chmod +x ($bin | path join fake)
    for name in [xdg-open yarn php rake code pre-commit npm lando aws] {
        ^ln -sf fake ($bin | path join $name)
    }
    let home = $env.OMN_TEST_HOME
    def plugins-code [names: list<string>] {
        $names | each {|name| $"use ($ROOT | path join plugins $'($name).nu' | to nuon) *" } | str join "; "
    }
    def run-in [names: list<string>, code: string] {
        nu-run $"$env.PATH = \($env.PATH | prepend ($bin | to nuon)); (plugins-code $names); ($code)" | get stdout | str trim
    }
    def last-opened [] { open --raw $opened | lines | last }

    # generated plugins: plain alias, bash wrapper with arguments, ^external, main
    assert equal (run-in [laravel] "artisan migrate --force") "RAN php artisan migrate --force"
    assert equal (run-in [yarn] "yuca --x") "RAN yarn global upgrade\nRAN yarn cache clean --x"
    assert str contains (run-in [lol] "nomz | lines | first") "PID"
    assert equal (run-in [rake] "rake db:migrate") "RAN rake db:migrate"

    # frontend-search, jira: URLs handed to xdg-open
    run-in [frontend-search] "caniuse flex box" | ignore
    assert equal (last-opened) "https://caniuse.com/#search=flex%20box"
    run-in [frontend-search] "reactjs hooks" | ignore
    assert equal (last-opened) "https://google.com/search?as_sitesearch=reactjs.org/&as_q=hooks"
    run-in [jira] "$env.JIRA_URL = 'https://j.example'; jira abc-12 m" | ignore
    assert equal (last-opened) "https://j.example/browse/ABC-12#add-comment"
    run-in [jira] "$env.JIRA_URL = 'https://j.example'; $env.JIRA_NAME = 'me'; jira assigned" | ignore
    assert str contains (last-opened) "jqlQuery=assignee+%3D+%22me%22"

    # vscode, pre-commit, lando
    assert equal (run-in [vscode] "vscd a b") "RAN code --diff a b"
    assert equal (run-in [vscode] "vsc") "RAN code ."
    assert equal (run-in [pre-commit] "prcra") "RAN pre-commit run --all-files"
    let site = $dir | path join Sites/blog/sub
    mkdir $site
    "" | save ($dir | path join Sites/blog/.lando.yml)
    let lando_env = $"$env.LANDO_ZSH_SITES_DIRECTORY = ($dir | path join Sites | to nuon)"
    assert equal (run-in [lando] $"($lando_env); cd ($site | to nuon); npm i") "RAN lando npm i"
    assert equal (run-in [lando] $"($lando_env); cd ($dir | to nuon); npm i") "RAN npm i"

    # gradle: the nearest gradlew wins
    let project = $dir | path join gradle-project
    mkdir ($project | path join app/src)
    "#!/bin/sh\necho \"WRAPPER $*\"\n" | save ($project | path join gradlew)
    chmod +x ($project | path join gradlew)
    assert equal (run-in [gradle] $"cd ($project | path join app/src | to nuon); gradle build") "WRAPPER build"

    # pj
    mkdir ($dir | path join projects/alpha)
    assert equal (run-in [pj] $"$env.PROJECT_PATHS = [($dir | path join projects | to nuon)]; pj alpha; pwd") ($dir | path join projects/alpha)

    # aws
    mkdir ($home | path join .aws)
    "[default]\nregion = x\n[profile work]\nregion = eu-west-3\n" | save --force ($home | path join .aws/config)
    assert equal (run-in [aws] "aws_profiles | to nuon" | from nuon) [default work]
    assert equal (run-in [aws] "asp work; [$env.AWS_PROFILE $env.AWS_PROFILE_REGION] | to nuon" | from nuon) [work eu-west-3]

    # git-commit
    let repo = $dir | path join commit-repo
    mkdir $repo
    cd $repo
    ^git init --quiet
    ^git config user.email t@example.invalid
    ^git config user.name tester
    "x" | save x.txt
    ^git add x.txt
    run-in [git-commit] "gcfeat -s ui -a add a thing out+err> /dev/null" | ignore
    assert equal (^git log -1 --format=%s | str trim) "feat(ui)!: add a thing"

    # universalarchive, round-tripped through extract
    let ua = $dir | path join ua
    mkdir ($ua | path join docs)
    cd $ua
    "hello" | save docs/a.txt
    assert equal (run-in [universalarchive] "ua tgz docs") "docs.tgz"
    assert equal (run-in [universalarchive] "ua tgz docs") "docs_1.tgz"
    assert equal (run-in [universalarchive] "ua zst docs/a.txt") "a.zst"
    mkdir out
    cd out
    run-in [extract] $"extract ($ua | path join docs.tgz | to nuon)" | ignore
    assert equal (open docs/a.txt) "hello"

    # torrent, tt, shell-proxy
    cd $dir
    assert equal (run-in [torrent] "magnet_to_torrent 'magnet:?xt=urn:btih:abc123&dn=file'") "file.torrent"
    assert equal (open --raw file.torrent | str trim) "d10:magnet-uri34:magnet:?xt=urn:btih:abc123&dn=filee"
    assert equal (run-in [tt] "tt 86400") "1970-01-02 00:00:00"
    assert equal (run-in [tt] "tt '1970-01-02'") "86400"
    let proxy = run-in [shell-proxy] "$env.SHELLPROXY_URL = 'http://p:3128'; $env.SHELLPROXY_NO_PROXY = 'localhost'; proxy enable; let on = [$env.http_proxy $env.HTTPS_PROXY $env.no_proxy]; proxy disable; [$on ($env.http_proxy? == null)] | to nuon" | from nuon
    assert equal $proxy [[http://p:3128 http://p:3128 localhost] true]

    # chucknorris reads Oh My Zsh's fortunes when it is installed
    let omz = $env.ZSH? | default ("~/.oh-my-zsh" | path expand)
    if ($omz | path join plugins/chucknorris | path exists) {
        assert ((run-in [chucknorris] $"$env.ZSH = ($omz | to nuon); chuck") | str contains "Chuck")
    }

    # uv-env: the PWD hook activates and deactivates the project's .venv
    let uvp = $dir | path join uvproj
    mkdir ($uvp | path join .venv/bin)
    "" | save ($uvp | path join pyproject.toml)
    "" | save ($uvp | path join uv.lock)
    "" | save ($uvp | path join .venv/bin/activate)
    let uv = run-in [uv-env] $"let hook = $env.config.hooks.env_change.PWD | last; do --env $hook null ($uvp | to nuon); let inside = $env.VIRTUAL_ENV; let path_ok = \($env.PATH.0 == ($uvp | path join .venv/bin | to nuon)); do --env $hook ($uvp | to nuon) '/'; [$inside $path_ok \($env.VIRTUAL_ENV? == null)] | to nuon" | from nuon
    assert equal $uv [($uvp | path join .venv) true true]

    # ssh: hosts table from ~/.ssh/config
    mkdir ($home | path join .ssh)
    "Host web\n  HostName 10.0.0.5\n  User deploy\n\nHost *.internal\n  User x\n\nHost db\n  Port 2222\n" | save --force ($home | path join .ssh/config)
    assert equal (run-in [ssh] "ssh-hosts | select host hostname user port | to nuon" | from nuon) [[host hostname user port]; [web 10.0.0.5 deploy null] [db null null "2222"]]

    # ssh-agent: starts one agent, and the next shell reuses it.
    # Only ever kill the agent this test started (read from the sandbox
    # cache), never one inherited from the user's session.
    if (which ssh-agent | is-not-empty) {
        def agent-shell [] {
            with-env {HOME: $home, SSH_AUTH_SOCK: "", SSH_AGENT_PID: ""} {
                ^$nu.current-exe --no-config-file --commands $"$env.OMN_SSH_AGENT_ARGS = [-T]; use ($ROOT | path join plugins/ssh-agent.nu | to nuon) *; $env.SSH_AGENT_PID? | default ''" | complete
            }
        }
        let first = agent-shell
        let second = agent-shell
        let cache = glob ($home | path join .ssh/environment-*) | get --optional 0
        let started = if $cache == null { "" } else {
            open --raw $cache | parse --regex 'SSH_AGENT_PID=(?<pid>\d+);' | get --optional pid.0 | default ""
        }
        let is_ours = ($started | is-not-empty) and ($started == ($first.stdout | str trim)) and (
            (do { ^ps -o comm= -p $started } | complete | get stdout | str trim) == "ssh-agent"
        )
        if $is_ours { ^kill $started }
        assert str contains $first.stderr "Starting ssh-agent"
        assert $is_ours $"no agent started by the test: ($first.stderr)"
        assert equal ($second.stdout | str trim) $started
        assert equal $second.stderr ""
    }
}

# Oh My Zsh aliases that need more than a plain alias: binstubs, chained
# aliases, env prefixes, renamed docker/podman/git commands, editors' launchers.
def test-aliases [dir: path] {
    mkdir $dir
    let bin = $dir | path join bin
    mkdir $bin
    let opened = $dir | path join opened.txt
    let fake = '#!/bin/sh
name=$(basename "$0")
case "$name $*" in
  "docker ps --quiet"|"podman ps --quiet") printf "c1\nc2\n" ;;
  "emacsclient -a  -n -e"*) echo nil ;;
  "gvim --serverlist") echo GVIM ;;
  "git rev-parse --show-toplevel") exit 1 ;;
  "printenv"*) env | sed -n "s/^$1=//p" ;;
  xdg-open*) echo "$1" >> OPENED ;;
  *) echo "RAN $name $*" ;;
esac
' | str replace OPENED $opened
    $fake | save ($bin | path join fake)
    chmod +x ($bin | path join fake)
    for name in [rails rake bundle hanami rvm mvn docker podman emacsclient subl gvim kamal shopify yarn xdg-open printenv] {
        ^ln -sf fake ($bin | path join $name)
    }
    def run-in [names: list<string>, code: string] {
        let use = $names | each {|name| $"use ($ROOT | path join plugins $'($name).nu' | to nuon) *" } | str join "; "
        nu-run $"$env.PATH = \($env.PATH | prepend ($bin | to nuon)); ($use); ($code)" | get stdout | str trim
    }

    # generated: a chained alias, an env prefix, a continued line
    assert equal (run-in [rvm] "gemsets") "RAN rvm gemset list"

    # rvm use: a fake rvm tree. Set rvm_path and clear GEM_*: the user's own
    # (inherited) must never be read or changed.
    let rvm = $dir | path join rvm
    for sub in [rubies/ruby-3.4.9/bin rubies/ruby-3.4.10/bin rubies/ruby-2.7.8/bin gems/ruby-3.4.10@app gems/ruby-3.4.10@global config] {
        mkdir ($rvm | path join $sub)
    }
    "default=ruby-2.7.8\n" | save ($rvm | path join config/alias)
    let rproj = $dir | path join rproj
    mkdir ($rproj | path join sub)
    "3.4\n" | save ($rproj | path join .ruby-version)
    "app\n" | save ($rproj | path join .ruby-gemset)
    let rvm_env = $"$env.rvm_path = ($rvm | to nuon); hide-env --ignore-errors GEM_HOME GEM_PATH RUBY_VERSION MY_RUBY_HOME"
    let used = run-in [rvm] $"($rvm_env); cd ($rproj | path join sub | to nuon); rvm use; [$env.RUBY_VERSION $env.GEM_HOME $env.GEM_PATH \($env.PATH | first 3)] | to nuon" | lines | last | from nuon
    assert equal $used [
        ruby-3.4.10
        ($rvm | path join gems/ruby-3.4.10@app)
        $"($rvm | path join gems/ruby-3.4.10@app):($rvm | path join gems/ruby-3.4.10@global)"
        [($rvm | path join gems/ruby-3.4.10@app/bin) ($rvm | path join gems/ruby-3.4.10@global/bin) ($rvm | path join rubies/ruby-3.4.10/bin)]
    ]
    let switched = run-in [rvm] $"($rvm_env); rvm use 3.4.10; rvm use default; [$env.RUBY_VERSION \($env.PATH | where { str starts-with ($rvm | path join rubies) } | length)] | to nuon" | lines | last | from nuon
    assert equal $switched [ruby-2.7.8 1]
    let system = run-in [rvm] $"($rvm_env); rvm use 2.7; rvm use system; [\($env.GEM_HOME? == null) \($env.PATH | where { str starts-with ($rvm | path join gems) } | is-empty)] | to nuon" | lines | last | from nuon
    assert equal $system [true true]
    let missing = try { run-in [rvm] $"($rvm_env); rvm use 3.4.9@nope"; "" } catch {|err| $err.msg }
    assert str contains $missing "gemset ruby-3.4.9@nope does not exist"
    assert equal (run-in [rvm] "rvm list") "RAN rvm list"

    # rvm's cd hook: switch in a project, keep it inside, back to default outside,
    # keep a manual choice outside projects, warn once for a missing ruby
    mkdir ($dir | path join rplain)
    mkdir ($dir | path join rbad)
    "9.9\n" | save ($dir | path join rbad/.ruby-version)
    let hook_code = [
        $rvm_env
        "let hook = $env.config.hooks.env_change.PWD | last"
        "def state [] { [($env.RUBY_VERSION? | default none) ($env.GEM_HOME? | default none | path basename)] }"
        $"do --env $hook null ($rproj | path join sub | to nuon); let a = state"
        $"do --env $hook ($rproj | path join sub | to nuon) ($rproj | to nuon); let b = state"
        $"do --env $hook ($rproj | to nuon) ($dir | path join rplain | to nuon); let c = state"
        $"rvm use 3.4.9 | ignore; do --env $hook ($dir | path join rplain | to nuon) ($dir | to nuon); let d = state"
        $"do --env $hook ($dir | to nuon) ($dir | path join rbad | to nuon); let e = state"
        "[$a $b $c $d $e] | to nuon"
    ] | str join "; "
    let hooked = nu-run $"$env.PATH = \($env.PATH | prepend ($bin | to nuon)); use ($ROOT | path join plugins/rvm.nu | to nuon) *; ($hook_code)"
    assert equal ($hooked.stdout | lines | last | from nuon) [
        [ruby-3.4.10 ruby-3.4.10@app] [ruby-3.4.10 ruby-3.4.10@app] [ruby-2.7.8 ruby-2.7.8] [ruby-3.4.9 ruby-3.4.9] [ruby-3.4.9 ruby-3.4.9]
    ]
    assert str contains $hooked.stderr "rvm: ruby-9.9 is not installed"
    assert equal (run-in [hanami] "hdtp; HET printenv HANAMI_ENV") "RAN hanami db prepare\ntest"
    assert equal (run-in [yarn] "yuil") "RAN yarn upgrade-interactive"

    # rails / rake: the project's binstub, bundler, or the installed tool
    let app = $dir | path join app
    mkdir ($app | path join bin)
    "#!/bin/sh\necho \"STUB $*\"\n" | save ($app | path join bin/rails)
    chmod +x ($app | path join bin/rails)
    "" | save ($app | path join Gemfile)
    let in_app = $"cd ($app | to nuon)"
    assert equal (run-in [rails] $"($in_app); rc") "STUB console"
    assert equal (run-in [rails] $"($in_app); rdm cache STEP=2") "STUB db:migrate:cache STEP=2"
    assert equal (run-in [rails] $"($in_app); rdm --trace") "STUB db:migrate --trace"
    assert equal (run-in [rails] $"($in_app); rkdm") "RAN bundle exec rake db:migrate"
    assert equal (run-in [rails] $"cd ($dir | to nuon); rs; rake -T") "RAN rails server\nRAN rake -T"
    assert equal (run-in [rails] "RET printenv RAILS_ENV") "test"

    # mvn: the nearest mvnw, else mvn
    let mvnp = $dir | path join mvnp
    mkdir ($mvnp | path join sub)
    "#!/bin/sh\necho \"WRAPPER $*\"\n" | save ($mvnp | path join mvnw)
    chmod +x ($mvnp | path join mvnw)
    assert equal (run-in [mvn] $"cd ($mvnp | path join sub | to nuon); mvnci") "WRAPPER clean install"
    assert equal (run-in [mvn] $"cd ($dir | to nuon); mvnci; mvn! -q") "RAN mvn clean install\nRAN mvn -f ./pom.xml -q"

    # docker, podman: Oh My Zsh's names
    assert equal (run-in [docker] "drit alpine; dlo web; dsta") "RAN docker container run --interactive --tty alpine\nRAN docker container logs web\nRAN docker stop c1 c2"
    assert equal (run-in [docker] "dclF") "RAN docker compose logs --follow --tail 0"
    assert equal (run-in [podman] "pr alpine; prm! web; psta") "RAN podman container run alpine\nRAN podman container rm --force web\nRAN podman stop c1 c2"

    # git: develop and main branches, in a scratch repository
    let repo = $dir | path join repo
    mkdir $repo
    cd $repo
    ^git init --quiet --initial-branch=main
    ^git config user.email t@example.invalid
    ^git config user.name tester
    ^git commit --quiet --allow-empty --message first
    ^git branch devel
    assert equal (run-in [git] $"cd ($repo | to nuon); git-develop-branch") "devel"
    run-in [git] $"cd ($repo | to nuon); gcd out+err> /dev/null; gswm out+err> /dev/null" | ignore
    assert equal (^git branch --show-current | str trim) "main"
    run-in [git] $"cd ($repo | to nuon); gcd out+err> /dev/null" | ignore
    assert equal (^git branch --show-current | str trim) "devel"
    cd $dir

    # emacs: a new frame when none is open
    assert equal (run-in [emacs] "emacs a.txt") "RAN emacsclient --alternate-editor= --create-frame --no-wait a.txt"
    # sublime: projects
    let proj = $dir | path join proj
    mkdir ($proj | path join .git)
    mkdir ($proj | path join sub)
    assert equal (run-in [sublime] $"cd ($proj | path join sub | to nuon); stp") $"RAN subl ($proj)"
    run-in [sublime] $"stn ($proj | to nuon)" | ignore
    assert equal (open --raw ($proj | path join proj.sublime-project) | from json | get folders.0.path) "."
    assert equal (run-in [sublime] $"cd ($proj | path join sub | to nuon); stp") $"RAN subl ($proj | path join proj.sublime-project)"
    # vim-interaction, kamal, shopify
    assert equal (run-in [vim-interaction] "cd /tmp; vvsp 'a b'") "RAN gvim --servername GVIM --remote-send :vsp<cr>:args! /tmp/a\\ b<cr>"
    assert equal (run-in [kamal] "kad") "RAN kamal deploy"
    assert equal (run-in [shopify] "shop theme dev") "RAN shopify theme dev"

    # web-search: Oh My Zsh's engines, bangs and home pages
    run-in [web-search] "google nu shell; ddg; wiki rust; rscrate serde" | ignore
    assert equal (open --raw $opened | lines) ["https://www.google.com/search?q=nu%20shell" "https://www.duckduckgo.com" "https://www.duckduckgo.com/?q=%21w%20rust" "https://crates.io/search?q=serde"]
}

# The web installer (www/public/install.nu), on a local fake release.
def test-get [dir: path] {
    let version = "9.9.9"
    let name = $"oh-my-nu-($version)"
    let release = $dir | path join release
    let src = $dir | path join src | path join $name
    mkdir $release $src
    for item in [oh-my-nu.nu install.nu VERSION lib plugins] { cp --recursive ($ROOT | path join $item) $src }
    ^tar -czf ($release | path join $"($name).tar.gz") -C ($src | path dirname) $name
    let sum = open --raw ($release | path join $"($name).tar.gz") | hash sha256
    $"($sum)  ($name).tar.gz\n" | save ($release | path join SHA256SUMS)

    let home = $dir | path join share/oh-my-nu
    let cfg = $dir | path join cfg
    let vars = {OMN_HOME: $home, OMN_VERSION: $"v($version)", OMN_RELEASE_DIR: $release, OMN_CONFIG_DIR: $cfg, OMN_AUTOLOAD_FILE: ($dir | path join autoload/oh-my-nu.nu)}
    let installer = $ROOT | path join www/public/install.nu
    # Run as documented: nu -c (http get .../install.nu)
    let get = {|extra = {}| with-env ($vars | merge {HOME: $env.OMN_TEST_HOME} | merge $extra) { ^$nu.current-exe --no-config-file --commands (open --raw $installer) | complete } }

    let first = do $get
    assert equal $first.exit_code 0 $first.stderr
    assert str contains $first.stdout $"oh-my-nu ($version) is in ($home)"
    assert ($home | path join plugins/git.nu | path exists)
    assert equal (open ($cfg | path join plugins.nuon)) [common]
    assert str contains (open --raw ($dir | path join autoload/oh-my-nu.nu)) ($home | path join plugins/common.nu)

    # An update replaces the files and keeps the enabled plugins.
    nu-run $"$env.OMN_CONFIG_DIR = ($cfg | to nuon); $env.OMN_AUTOLOAD_FILE = ($dir | path join autoload/oh-my-nu.nu | to nuon); use ($home | path join oh-my-nu.nu | to nuon) *; omn enable git" | ignore
    "x" | save ($home | path join stale)
    let second = do $get
    assert equal $second.exit_code 0 $second.stderr
    assert not ($home | path join stale | path exists)
    assert equal (open ($cfg | path join plugins.nuon)) [common git]

    # A bad checksum leaves the install alone.
    "x" | save ($home | path join keep)
    $"('' | fill --character 0 --width 64)  ($name).tar.gz\n" | save --force ($release | path join SHA256SUMS)
    let bad = do $get
    assert not equal $bad.exit_code 0
    assert str contains $bad.stderr "checksum mismatch"
    assert ($home | path join keep | path exists)

    # Never replaces a directory that isn't oh-my-nu.
    let other = $dir | path join other
    mkdir $other
    let refused = do $get {OMN_HOME: $other}
    assert str contains $refused.stderr "is not oh-my-nu"
}

def main [] {
    let dir = $env.OMN_TEST_DIR? | default (mktemp --directory)
    mkdir $dir
    $env.OMN_TEST_HOME = ($dir | path join home)
    mkdir $env.OMN_TEST_HOME
    let tests = [
        [name, run];
        [parse, {|| test-parse }]
        [names, {|| test-names }]
        [manager, {|| test-manager ($dir | path join manager) }]
        [extract, {|| test-extract ($dir | path join extract-test) }]
        [git, {|| test-git ($dir | path join git-test) }]
        [rmux, {|| test-rmux ($dir | path join rmux-test) }]
        [distro, {|| test-distro ($dir | path join distro-test) }]
        [utils, {|| test-utils ($dir | path join utils-test) }]
        [git-flow, {|| test-git-flow ($dir | path join git-flow-test) }]
        [ports, {|| test-ports ($dir | path join ports-test) }]
        [aliases, {|| test-aliases ($dir | path join aliases-test) }]
        [get, {|| test-get ($dir | path join get-test) }]
    ]
    let failed = $tests | each {|t|
        try {
            do $t.run
            print $"ok   ($t.name)"
            null
        } catch {|err|
            print $"FAIL ($t.name): ($err.msg)\n($err.debug? | default '' | str substring 0..400)"
            $t.name
        }
    } | compact
    if ($failed | is-not-empty) { exit 1 }
}

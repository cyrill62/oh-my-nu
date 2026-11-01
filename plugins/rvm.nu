# description: Oh My Zsh's rvm aliases, plus `rvm use` for nushell, switching on cd from .ruby-version and .ruby-gemset
# requires: rvm

def rvm-path [] { $env.rvm_path? | default ("~/.rvm" | path expand) }

# PATH as a list, whatever the shell's conversion settings
def path-list [] {
    let path = $env.PATH
    if ($path | describe) == string { $path | split row (char esep) } else { $path }
}

# NAME in DIR or its nearest parent, else null
def project-file [name: string, dir: path] {
    mut dir = $dir
    loop {
        let file = $dir | path join $name
        if ($file | path exists) { return $file }
        if $dir == "/" { return null }
        $dir = $dir | path dirname
    }
}

# First word of a project file (.ruby-version, .ruby-gemset)
def read-project-file [file: path] {
    open --raw $file | lines | str trim | where {|line| ($line | is-not-empty) and not ($line starts-with '#') } | get --optional 0
}

# The ruby a project asks for (3.4@app), from .ruby-version and .ruby-gemset
# in DIR or a parent, else null
def project-ruby [dir: path] {
    let version_file = project-file .ruby-version $dir
    if $version_file == null { return null }
    let version = read-project-file $version_file
    if $version == null { return null }
    let gemset_file = project-file .ruby-gemset $dir
    let gemset = if $gemset_file == null { null } else { read-project-file $gemset_file }
    if $gemset == null or ($version | str contains "@") { $version } else { $"($version)@($gemset)" }
}

# An installed ruby matching WANTED: an rvm alias (default...), an exact
# name (ruby-3.4.10, 3.4.10, jruby-9.4.8.0) or the newest one matching a
# partial version (3.4, ruby-3)
def resolve-ruby [wanted: string] {
    let rvm = rvm-path
    let alias_file = $rvm | path join config/alias
    let aliases = if ($alias_file | path exists) {
        open --raw $alias_file | lines | parse "{name}={target}"
    } else { [] }
    let wanted = $aliases | where name == $wanted | get --optional 0.target | default $wanted
    let installed = if ($rvm | path join rubies | path exists) {
        ls ($rvm | path join rubies) | where type == dir | get name | path basename
    } else { [] }
    let names = if ($wanted =~ '^\d') { [$"ruby-($wanted)"] } else { [$wanted] }
    let exact = $installed | where $it in $names
    if ($exact | is-not-empty) { return ($exact | first) }
    let partial = $installed | where {|ruby| $names | any {|name| ($ruby starts-with $"($name).") or ($ruby starts-with $"($name)-") } }
    if ($partial | is-empty) {
        error make --unspanned {msg: $"($names | first) is not installed: rvm install ($wanted)"}
    }
    $partial | sort --natural | last
}

# Drop rvm's rubies and gems from PATH (keeps $rvm_path/bin)
def --env clear-rvm-path [] {
    let rvm = rvm-path
    $env.PATH = path-list | where {|dir| not ($dir starts-with ($rvm | path join rubies)) and not ($dir starts-with ($rvm | path join gems)) }
}

# Switch this shell to a ruby and gemset, as `rvm use` does in bash/zsh:
# PATH, GEM_HOME, GEM_PATH, MY_RUBY_HOME, IRBRC and RUBY_VERSION. Without a
# ruby, read .ruby-version (and .ruby-gemset) here or in a parent directory.
def --env rvm-use [
    ruby?: string    # 3.4.10, 3.4, ruby-3.4@gemset, @gemset, default or system
    --default        # also make it rvm's default ruby
    --create         # create the gemset if it doesn't exist
    --quiet          # don't say which ruby is in use
] {
    let rvm = rvm-path
    if $ruby == system {
        # hide-env first: after another --env call, nushell 0.116 drops it
        hide-env --ignore-errors GEM_HOME GEM_PATH MY_RUBY_HOME IRBRC RUBY_VERSION
        clear-rvm-path
        if not $quiet { print "Now using system ruby." }
        return
    }
    let wanted = if $ruby != null { $ruby } else {
        let project = project-ruby $env.PWD
        if $project == null {
            error make --unspanned {msg: "no ruby given and no .ruby-version here or in a parent directory"}
        }
        $project
    }
    let parts = $wanted | split row "@"
    let version = $parts.0
    let gemset = $parts | get --optional 1 | default --empty null
    let name = if ($version | is-empty) {
        $env.RUBY_VERSION? | default { error make --unspanned {msg: "no ruby in use: give one, e.g. rvm use 3.4@($gemset)"} }
    } else { resolve-ruby $version }
    let ruby_home = $rvm | path join rubies $name
    let gem_home = $rvm | path join gems (if $gemset == null { $name } else { $"($name)@($gemset)" })
    let global = $rvm | path join gems $"($name)@global"
    if $gemset != null and not ($gem_home | path exists) {
        if not $create {
            error make --unspanned {msg: $"gemset ($name)@($gemset) does not exist: rvm use ($name)@($gemset) --create"}
        }
        mkdir $gem_home
    }

    hide-env --ignore-errors MAGLEV_HOME RBXOPT
    clear-rvm-path
    let rvm_bin = $rvm | path join bin
    let path = path-list | prepend [($gem_home | path join bin) ($global | path join bin) ($ruby_home | path join bin)]
    $env.PATH = if $rvm_bin in $path { $path } else { $path | append $rvm_bin }
    $env.GEM_HOME = $gem_home
    $env.GEM_PATH = $"($gem_home):($global)"
    $env.MY_RUBY_HOME = $ruby_home
    $env.IRBRC = $ruby_home | path join .irbrc
    $env.RUBY_VERSION = $name

    if $default {
        ^rvm alias create default (if $gemset == null { $name } else { $"($name)@($gemset)" })
    }
    if not $quiet {
        print (if $gemset == null { $"Using ($ruby_home)" } else { $"Using ($ruby_home) with gemset ($gemset)" })
    }
}

# Like rvm in bash/zsh, switch ruby when cd enters a project with a
# .ruby-version (and .ruby-gemset), and back to rvm's default (else the system
# ruby) when it leaves the projects. A ruby chosen with `rvm use` outside a
# project is kept. $env.OMN_RVM_AUTO = false turns this off.
export-env {
    let hook = {|before, after|
        if ($env.OMN_RVM_AUTO? | default true) == false { return }
        let wanted = try { project-ruby $after } catch { null }
        let current = $env.OMN_RVM_PROJECT? | default ""
        if $wanted == null {
            if ($current | is-not-empty) {
                hide-env --ignore-errors OMN_RVM_PROJECT
                let has_default = rvm-path | path join config/alias | do {|file| ($file | path exists) and (open --raw $file | str contains "default=") } $in
                try { rvm-use (if $has_default { "default" } else { "system" }) --quiet } catch {|err| print --stderr $"rvm: ($err.msg)" }
            }
        } else if $wanted != $current {
            try {
                rvm-use $wanted --quiet
                $env.OMN_RVM_PROJECT = $wanted
            } catch {|err|
                $env.OMN_RVM_PROJECT = $wanted
                print --stderr $"rvm: ($err.msg)"
            }
        }
    }
    $env.config = ($env.config | upsert hooks.env_change.PWD ($env.config.hooks?.env_change?.PWD? | default [] | append $hook))
}

# rvm; `rvm use` switches this nushell (rvm's own can only change a bash/zsh shell)
export def --env --wrapped main [...args] {
    if ($args | get --optional 0) == use {
        let rest = $args | skip 1
        let ruby = $rest | where { not ($in starts-with "-") } | get --optional 0
        let unknown = $rest | where { ($in starts-with "-") and $in not-in [--default --create] }
        if ($unknown | is-not-empty) {
            error make --unspanned {msg: $"rvm use: unsupported option ($unknown | str join ' ') \(only --default and --create)"}
        }
        rvm-use $ruby --default=("--default" in $rest) --create=("--create" in $rest)
    } else {
        ^rvm ...$args
    }
}

export alias rubies = rvm list rubies
export alias rvms = rvm gemset
export alias gemsets = rvm gemset list

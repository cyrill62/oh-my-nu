# oh-my-nu: Oh My Zsh-style alias plugins for nushell.
#
# Enabled plugins are written as `use` lines into a file in nushell's
# autoload directory, so they load at startup without editing config.nu.

const ROOT = path self | path dirname
# Set from the VERSION file by tools/set-version.nu
const VERSION = "0.1.0"

def config-dir [] {
    $env.OMN_CONFIG_DIR? | default (
        $env.XDG_CONFIG_HOME? | default ($env.HOME | path join .config) | path join oh-my-nu
    )
}

def state-file [] { config-dir | path join plugins.nuon }

def autoload-file [] {
    $env.OMN_AUTOLOAD_FILE? | default ($nu.user-autoload-dirs | first | path join oh-my-nu.nu)
}

def header [file: path, key: string] {
    open --raw $file
    | lines
    | take while { str starts-with '#' }
    | parse --regex ('^#\s*' + $key + ':\s*(?<value>.*)$')
    | get --optional value.0
    | default ""
    | str trim
}

# Names a plugin file exports (a module's `main` is named after the plugin)
def exports [file: path] {
    let stem = $file | path parse | get stem
    open --raw $file
    | lines
    | parse --regex "^export (?:alias|def(?: --[a-z-]+)*) '?(?<name>[^\\s'\\[=]+)"
    | get name
    | each { if $in == main { $stem } else { $in } }
}

# Built-in plugins, overridden or extended by ~/.config/oh-my-nu/custom/*.nu
def plugins [] {
    let builtin = glob ($ROOT | path join plugins/*.nu) | each { {file: $in, custom: false} }
    let custom = glob (config-dir | path join custom/*.nu) | each { {file: $in, custom: true} }
    $builtin ++ $custom
    | insert name { get file | path parse | get stem }
    | reverse
    | uniq-by name
    | sort-by name
    | insert description {|p| header $p.file description }
    | insert requires {|p| header $p.file requires | split row ' ' | where { is-not-empty } }
    # `a|b` in `requires` means either tool will do.
    | insert missing {|p|
        $p.requires | where {|need| $need | split row '|' | all {|bin| which $bin | is-empty } }
    }
}

# Why a plugin file can't be loaded, or null if it parses
def load-error [file: path] {
    if (nu-check --as-module $file) { return null }
    # nu-check prints its diagnostic: rerun it in a child to capture the message.
    let report = ^$nu.current-exe --no-config-file --commands $"nu-check --as-module --debug ($file | to nuon)" | complete
    let text = $report.stderr | ansi strip | lines | str trim
    let message = $text | where { $in starts-with 'x ' } | get --optional 0 | default "does not parse" | str replace --regex '^x\s+' '' | str trim --right --char '.'
    let place = $text | parse --regex '\[(?<file>[^\]]+):(?<line>\d+):(?<col>\d+)\]' | get --optional 0
    if $place == null { $message } else { $"($message) \(line ($place.line))" }
}

# Plugin files the autoload file loads
def autoloaded [] {
    let target = autoload-file
    if not ($target | path exists) { return [] }
    open --raw $target | lines | parse --regex '^use (?<file>".*") \*$' | get file | each { from nuon }
}

def enabled [] {
    if (state-file | path exists) { open (state-file) } else { [] }
}

def save-enabled [names: list<string>] {
    mkdir (state-file | path dirname)
    $names | save --force (state-file)
}

def known [names: list<string>] {
    let available = plugins | get name
    let unknown = $names | where { $in not-in $available }
    if ($unknown | is-not-empty) {
        error make --unspanned {
            msg: $"unknown plugin: ($unknown | str join ', ') \(available: ($available | str join ', '))"
        }
    }
}

# Oh My Zsh-style alias plugins for nushell
#
#   omn list [--enabled (-e)]    plugins; -e: only the enabled ones
#   omn enable PLUGIN...         enable plugins (new shell or `omn reload` to load them)
#   omn disable PLUGIN...        disable plugins
#   omn aliases [PLUGIN]         aliases and commands, of the enabled plugins or one
#   omn info PLUGIN              a plugin's description, file and commands
#   omn clashes                  names defined by several enabled plugins
#   omn sync                     rewrite the autoload file from the enabled list
#   omn paths                    files and directories oh-my-nu uses
#   omn reload                   restart nushell
#   omn --version (-v)           the oh-my-nu version
#
# `omn help` explains every command's options; `omn help COMMAND` shows one.
@example "Only the enabled plugins" { omn list --enabled }
@example "Every command with its options" { omn help }
@example "The installed version" { omn --version }
export def omn [
    --version (-v)  # print the oh-my-nu version
] {
    if $version { $"v($VERSION)" } else { help omn }
}

def subcommands [] {
    scope commands | where name starts-with "omn " | get name | str replace "omn " ""
}

# One usage line from a command's signature: omn list [--enabled (-e)]
def usage [command: record] {
    let params = $command.signatures | values | first | where parameter_type not-in [input output]
    let parts = $params | each {|p|
        let flag = if $p.short_flag == null { $"--($p.parameter_name)" } else { $"--($p.parameter_name) \(-($p.short_flag))" }
        match $p.parameter_type {
            "switch" => $"[($flag)]"
            "named" => $"[($flag) <($p.syntax_shape)>]"
            "rest" => $"<($p.parameter_name)>..."
            _ => (if $p.is_optional { $"[($p.parameter_name)]" } else { $"<($p.parameter_name)>" })
        }
    }
    [$command.name ...$parts] | str join ' '
}

# Explain oh-my-nu's commands and their options: omn help [COMMAND]
@example "Every command with its options and examples" { omn help }
@example "One command in detail" { omn help list }
export def "omn help" [command?: string@subcommands] {
    let commands = scope commands | where name == omn or name starts-with "omn " | sort-by name
    if $command != null {
        let name = if ($command | str starts-with "omn ") { $command } else { $"omn ($command)" }
        if $name not-in $commands.name {
            error make --unspanned {msg: $"unknown command '($command)', use one of: (subcommands | str join ', ')"}
        }
        return (help ...($name | split row ' '))
    }
    let blocks = $commands | each {|c|
        let params = $c.signatures | values | first | where parameter_type not-in [input output]
        let options = $params | where { $in.description | is-not-empty } | each {|p|
            let flag = match $p.parameter_type {
                "switch" | "named" => (if $p.short_flag == null { $"--($p.parameter_name)" } else { $"--($p.parameter_name), -($p.short_flag)" })
                _ => $p.parameter_name
            }
            $"      ($flag | fill --width 18) ($p.description)"
        }
        let examples = $c.examples | each { $"      e.g. ($in.example)" }
        [$"  (usage $c)" $"      ($c.description)" ...$options ...$examples] | str join "\n"
    }
    print ([
        $"oh-my-nu ($VERSION): Oh My Zsh-style alias plugins for nushell"
        ""
        ...$blocks
        ""
        "Details of one command: omn help COMMAND (or: help omn COMMAND)"
    ] | str join "\n")
}

# Plugins and whether they are enabled and loaded
#
# status is one of: loaded; skipped: needs TOOL (a required tool is missing);
# error: MESSAGE (the plugin file does not parse); not synced (run `omn sync`);
# empty for disabled plugins.
@example "Every plugin" { omn list }
@example "Only the enabled plugins" { omn list --enabled }
@example "Only the plugins loaded in new shells" { omn list --loaded }
@example "Enabled plugins that are not loaded, and why" { omn list --failed }
export def "omn list" [
    --enabled (-e)  # only the enabled plugins
    --loaded (-l)   # only the loaded plugins
    --failed (-f)   # only enabled plugins that are not loaded (missing tool, error, not synced)
] {
    let on = enabled
    let in_autoload = autoloaded
    plugins
    | insert enabled {|p| $p.name in $on }
    | where {|p| not ($enabled or $failed) or $p.enabled }
    | insert status {|p|
        if not $p.enabled {
            ""
        } else if $p.file in $in_autoload {
            "loaded"
        } else if ($p.missing | is-not-empty) {
            $"skipped: needs ($p.missing | str join ', ')"
        } else {
            let error = load-error $p.file
            if $error != null { $"error: ($error)" } else { "not synced: run `omn sync`" }
        }
    }
    | where {|p| not $loaded or $p.status == "loaded" }
    | where {|p| not $failed or ($p.status != "loaded") }
    | select name enabled status description custom
}

# Enable plugins (takes effect in the next shell, or after `omn reload`)
@example "Enable two plugins" { omn enable docker kubectl }
export def "omn enable" [
    ...names: string  # plugins to enable (see `omn list`)
] {
    known $names
    save-enabled (enabled | append $names | uniq)
    omn sync
}

# Disable plugins
@example "Disable a plugin" { omn disable eza }
export def "omn disable" [
    ...names: string  # plugins to disable (see `omn list --enabled`)
] {
    known $names
    save-enabled (enabled | where { $in not-in $names })
    omn sync
}

# Rewrite the autoload file from the enabled plugins
@example "After installing a tool a skipped plugin needs" { omn sync }
export def "omn sync" [] {
    let all = plugins
    let on = enabled
    let rows = $on | each {|name| $all | where name == $name | get --optional 0 } | compact
    let available = $rows | where { $in.missing | is-empty }
    let skipped = $rows | where { $in.missing | is-not-empty }
    # A plugin that does not parse would break every new shell: leave it out.
    let checked = $available | insert error {|p| load-error $p.file }
    let broken = $checked | where error != null
    let loaded = $checked | where error == null | reject error
    let lines = [
        "# Generated by oh-my-nu: edit with `omn enable` / `omn disable`."
        $"use ($ROOT | path join oh-my-nu.nu | to nuon) *"
    ] ++ ($loaded | each { $"use ($in.file | to nuon) *" })
    let target = autoload-file
    mkdir ($target | path dirname)
    $lines | str join "\n" | $in + "\n" | save --force $target
    print $"oh-my-nu: ($loaded | length) plugins in ($target)"
    for p in $skipped {
        print $"  skipped ($p.name): ($p.missing | str join ', ') not found"
    }
    for p in $broken {
        print $"  error in ($p.name), not loaded: ($p.error)"
    }
    # As in Oh My Zsh, plugins may define the same name; the later one wins.
    let clashes = $loaded
    | each {|p| exports $p.file | each {|name| {name: $name, plugin: $p.name} } }
    | flatten
    | group-by name
    | items {|name, rows| {name: $name, plugins: ($rows.plugin | uniq)} }
    | where { ($in.plugins | length) > 1 }
    if ($clashes | is-not-empty) {
        print $"  ($clashes | length) names are defined by several plugins \(the last one listed wins):"
        for c in ($clashes | first 10) {
            print $"    ($c.name): ($c.plugins | str join ', ')"
        }
        if ($clashes | length) > 10 { print "    ... (see `omn clashes`)" }
    }
    if ($loaded | is-not-empty) {
        print "  start a new shell (or run `omn reload`) to use them"
    }
}

# Names defined by more than one enabled plugin, and which one wins
@example "Which plugin's gst wins" { omn clashes | where name == gst }
export def "omn clashes" [] {
    let on = enabled
    let all = plugins
    $on
    | each {|name| $all | where name == $name | get --optional 0 }
    | compact
    | where { $in.missing | is-empty }
    | each {|p| exports $p.file | each {|name| {name: $name, plugin: $p.name} } }
    | flatten
    | group-by name
    | items {|name, rows| {name: $name, plugins: ($rows.plugin | uniq), wins: ($rows.plugin | last)} }
    | where { ($in.plugins | length) > 1 }
}

# Aliases and commands of a plugin (default: the enabled ones)
@example "Everything the enabled plugins define" { omn aliases }
@example "One plugin" { omn aliases git }
@example "Find the shortcut for something" { omn aliases | where does =~ push }
export def "omn aliases" [
    plugin?: string  # a plugin, enabled or not (default: all enabled plugins)
] {
    let names = if $plugin == null { enabled } else { known [$plugin]; [$plugin] }
    plugins
    | where name in $names
    | each {|p|
        let lines = open --raw $p.file | lines
        $lines | enumerate | each {|row|
            let alias = $row.item | parse --regex '^export alias (?<name>\S+) = (?<expansion>.+)$'
            let def = $row.item | parse --regex '^export def (?:--\w+ )*(?<name>"[^"]+"|\S+)'
            if ($alias | is-not-empty) {
                {plugin: $p.name, name: ($alias.0.name | str trim --char "'"), does: $alias.0.expansion}
            } else if ($def | is-not-empty) {
                let doc = $lines | get --optional ($row.index - 1) | default ""
                let name = if $def.0.name == "main" { $p.name } else { $def.0.name }
                {plugin: $p.name, name: $name, does: ($doc | str replace --regex '^#\s*' '')}
            }
        } | compact
    }
    | flatten
}

# Show a plugin's description, file and commands
@example "About the git plugin" { omn info git }
export def "omn info" [
    plugin: string  # the plugin to describe
] {
    known [$plugin]
    let p = plugins | where name == $plugin | first
    print $"($p.name): ($p.description)"
    print $"file: ($p.file)"
    if ($p.missing | is-not-empty) { print $"missing: ($p.missing | str join ', ')" }
    omn aliases $plugin
}

# Paths used by oh-my-nu
@example "Where enabled plugins are stored" { omn paths | get state }
export def "omn paths" [] {
    {
        plugins: ($ROOT | path join plugins)
        custom: (config-dir | path join custom)
        state: (state-file)
        autoload: (autoload-file)
    }
}

# Restart nushell to load changes
@example "Load newly enabled plugins" { omn reload }
export def "omn reload" [] { exec $nu.current-exe }

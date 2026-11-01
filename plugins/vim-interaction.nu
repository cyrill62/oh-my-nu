# description: Oh My Zsh's vim-interaction aliases: open files in a running gvim
# requires: gvim

# Edit files in a running gvim (starting one if needed), running Vim
# commands before or after
export def callvim [
    ...files: path
    --before (-b): string  # command to run before editing the first file
    --after (-a): string   # command to run after editing the first file
    --name (-n): string    # gvim server to connect to (default: the last one)
] {
    if ($files | is-empty) and $before == null and $after == null {
        print "usage: callvim [-b cmd] [-a cmd] [-n name] [file ... fileN]"
        return
    }
    mut server = $name | default (^gvim --serverlist | lines | last | default "")
    if ($server | is-empty) {
        ^gvim
        while ($server | is-empty) {
            sleep 100ms
            $server = ^gvim --serverlist | lines | last | default ""
        }
    }
    # `:commands` need a carriage return to run
    def with-cr [cmd: string] {
        if ($cmd starts-with ":") and not ($cmd ends-with "<cr>") { $cmd + "<cr>" } else { $cmd }
    }
    let args = if ($files | is-empty) { "" } else {
        let quoted = $files | path expand | each { str replace --all ' ' '\ ' } | str join ' '
        $":args! ($quoted)<cr>"
    }
    ^gvim --servername $server --remote-send $"(with-cr ($before | default '<esc>'))($args)(with-cr ($after | default ''))"
}

export alias v = callvim
export alias vvsp = callvim -b ':vsp'
export alias vhsp = callvim -b ':sp'
export alias vk = callvim -b ':wincmd k'
export alias vj = callvim -b ':wincmd j'
export alias vl = callvim -b ':wincmd l'
export alias vh = callvim -b ':wincmd h'

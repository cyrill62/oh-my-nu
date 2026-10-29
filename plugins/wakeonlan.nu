# description: Wake machines described in ~/.wakeonlan/NAME (Oh My Zsh's wakeonlan)
# requires: wakeonlan

def machines [] {
    let dir = "~/.wakeonlan" | path expand
    if ($dir | path exists) { ls --short-names $dir | where type == file | get name } else { [] }
}

# Send a magic packet to the machine configured in ~/.wakeonlan/NAME
export def wake [name: string@machines] {
    let config = "~/.wakeonlan" | path expand | path join $name
    if not ($config | path exists) {
        error make --unspanned {msg: $"There is no configuration file at \"($config)\"."}
    }
    ^wakeonlan -f $config
}

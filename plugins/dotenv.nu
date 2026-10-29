# description: Load KEY=value pairs from a .env file into the environment (Oh My Zsh's dotenv, on demand)
# requires:

# Parse a .env file into a record (comments, `export`, quotes handled)
export def "from dotenv" []: string -> record {
    lines
    | str trim
    | where {|line| ($line | is-not-empty) and not ($line starts-with '#') }
    | str replace --regex '^export\s+' ''
    | parse --regex '^(?<key>[A-Za-z_][A-Za-z0-9_]*)\s*=\s*(?<value>.*)$'
    | update value {|row|
        let v = $row.value
        if ($v =~ '^".*"$') {
            $v | str substring 1..-2 | str replace --all '\n' "\n" | str replace --all '\"' '"'
        } else if ($v =~ "^'.*'$") {
            $v | str substring 1..-2
        } else {
            $v | str replace --regex '\s+#.*$' '' | str trim
        }
    }
    | reduce --fold {} {|row, acc| $acc | upsert $row.key $row.value }
}

# Load a .env file (default ./.env) into this shell's environment
export def --env main [file: path = ".env"] {
    let vars = open --raw $file | from dotenv
    load-env $vars
    print $"loaded ($vars | columns | length) variables from ($file)"
}

# description: Password generators (Oh My Zsh's genpass-*)
# requires:

# Random password of letters, digits and symbols
export def main [length: int = 24, --count (-n): int = 1] {
    let alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!#%+-.:=?@_~" | split chars
    1..$count | each {
        1..$length | each { $alphabet | get (random int 0..(($alphabet | length) - 1)) } | str join
    } | if $count == 1 { first } else { $in }
}

# Apple-style password: xxxxxx-xxxxxx-xxxxxx with one digit and one capital
export def genpass-apple [--count (-n): int = 1] {
    let letters = "bcdfghjkmnpqrstvwxzaeiouy" | split chars
    1..$count | each {
        mut chars = 1..18 | each { $letters | get (random int 0..(($letters | length) - 1)) }
        let digit = random int 0..17
        $chars = ($chars | update $digit { random int 0..9 | into string })
        let upper = (0..17 | where { $in != $digit } | shuffle | first)
        $chars = ($chars | update $upper { str uppercase })
        $chars | chunks 6 | each { str join } | str join '-'
    } | if $count == 1 { first } else { $in }
}

# Passphrase of random words (needs a word list: $env.OMN_WORDS or /usr/share/dict/words)
export def genpass-xkcd [words: int = 5, --separator (-s): string = "-"] {
    let file = $env.OMN_WORDS? | default /usr/share/dict/words
    if not ($file | path exists) {
        error make --unspanned {msg: $"no word list at ($file): install one (e.g. sys-apps/miscfiles, wamerican) or set OMN_WORDS"}
    }
    let list = open --raw $file | lines | where { $in =~ '^[a-z]{3,8}$' }
    1..$words | each { $list | get (random int 0..(($list | length) - 1)) } | str join $separator
}

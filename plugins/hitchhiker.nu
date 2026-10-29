# description: Hitchhiker's Guide quotes, one at shell start (Oh My Zsh's hitchhiker; reads its fortunes file)
# requires:

use ../lib/root.nu [random-fortune omz-plugin-dir]

# A random Hitchhiker's Guide quote
export def main [] { random-fortune (omz-plugin-dir hitchhiker | path join fortunes/hitchhiker) }

# A random Hitchhiker's Guide quote, thought by a cow
export def hitchhiker_cow [] { main | ^cowthink }

# Like Oh My Zsh, greet with a quote when the shell starts.
export-env {
    let file = $env.ZSH? | default ("~/.oh-my-zsh" | path expand) | path join plugins/hitchhiker/fortunes/hitchhiker
    if ($file | path exists) and ($env.OMN_QUIET? != true) {
        let entries = open --raw $file | split row --regex '(?m)^%\n' | str trim | where { is-not-empty }
        print ($entries | get (random int 0..(($entries | length) - 1)))
    }
}

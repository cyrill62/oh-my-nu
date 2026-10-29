# description: Upload a file, a directory (as tar.gz) or the input to transfer.sh (Oh My Zsh's transfer)
# requires: curl

# Upload and print the download URL; --encrypt (-c) encrypts with gpg first
export def main [item?: string, --encrypt (-c), --host: string = "https://transfer.sh"] {
    let input = $in
    let piped = $input != null
    if $item == null and not $piped {
        error make --unspanned {msg: "usage: transfer FILE|DIR [--encrypt], or: open x | transfer NAME"}
    }
    let tmp = mktemp --tmpdir transfer.XXXXXX
    let name = if $piped { $item | default "stdin" } else { $item | path basename | str replace --all --regex '[^a-zA-Z0-9._-]' '-' }
    if $piped {
        $input | save --force --raw $tmp
    } else if ($item | path type) == dir {
        ^tar -C ($item | path expand | path dirname) -czf $tmp ($item | path expand | path basename)
    } else if ($item | path exists) {
        cp $item $tmp
    } else {
        error make --unspanned {msg: $"File ($item) doesn't exist."}
    }
    let upload = if $encrypt { let enc = $"($tmp).asc"; ^gpg --armor --symmetric --output $enc $tmp; $enc } else { $tmp }
    let suffix = if (not $piped) and ($item | path type) == dir { ".tar.gz" } else { "" }
    let url = ^curl --silent --upload-file $upload $"($host)/($name)($suffix)" | str trim
    rm --force $tmp $"($tmp).asc"
    $url
}

# description: Paste text, a file or the input to sprunge.us and get its URL (Oh My Zsh's sprunge)
# requires: curl

# sprunge FILE, sprunge some text, or: open notes.txt | sprunge
export def main [...text: string] {
    let input = $in
    let data = if $input != null {
        $input | into string
    } else if ($text | length) == 1 and ($text.0 | path exists) {
        open --raw $text.0 | decode
    } else if ($text | is-not-empty) {
        $text | str join ' '
    } else {
        error make --unspanned {msg: "usage: sprunge FILE | sprunge TEXT... | ... | sprunge"}
    }
    $data | ^curl --silent -F 'sprunge=<-' http://sprunge.us | str trim
}

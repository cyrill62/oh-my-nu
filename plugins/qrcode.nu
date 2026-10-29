# description: QR codes from the terminal through qrcode.show: qrcode TEXT, qrsvg TEXT (Oh My Zsh's qrcode)
# requires:

# QR code of the text (or the input) as terminal art
export def main [...text: string] {
    let input = $in
    let data = if $input != null { $input | into string } else { $text | str join ' ' }
    http post --max-time 10sec https://qrcode.show $data
}

# QR code of the text (or the input) as SVG
export def qrsvg [...text: string] {
    let input = $in
    let data = if $input != null { $input | into string } else { $text | str join ' ' }
    http post --max-time 10sec --headers [Accept image/svg+xml] https://qrcode.show $data
}

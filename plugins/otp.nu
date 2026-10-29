# description: One-time passwords from gpg-encrypted secrets: ot NAME, otp_add_device NAME (Oh My Zsh's otp)
# requires: oathtool gpg

use ../lib/root.nu [clipcopy]

def home [] {
    $env.OTP_HOME? | default (
        if (not ("~/.otp" | path expand | path exists)) and ($env.XDG_DATA_HOME? | is-not-empty) {
            $env.XDG_DATA_HOME | path join otp
        } else {
            "~/.otp" | path expand
        }
    )
}

# Profiles that have a secret
export def otp_devices [] {
    let dir = home
    if not ($dir | path exists) { return [] }
    glob ($dir | path join '*.otp.asc') | each { path basename | str replace '.otp.asc' '' }
}

# Print the current TOTP code of a profile and copy it to the clipboard
export def ot [profile: string@otp_devices] {
    let file = home | path join $"($profile).otp.asc"
    if not ($file | path exists) {
        error make --unspanned {msg: $"missing profile ($profile), you might need to create it first using otp_add_device"}
    }
    let key = ^gpg --quiet --decrypt $file | str trim
    let code = ^oathtool --totp --base32 $key | str trim
    try { clipcopy $code }
    $code
}

# Store a new secret (encrypted to your gpg key): paste it, then press ctrl+d
export def otp_add_device [profile: string] {
    let dir = home
    mkdir $dir
    let file = $dir | path join $"($profile).otp.asc"
    print "Enter an email address attached to your GPG private key, then paste the secret configuration key followed by ^D"
    rm --force $file
    ^gpg --armor --encrypt --output $file /dev/stdin
}

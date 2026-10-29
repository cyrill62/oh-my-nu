# description: Copy a Bitwarden password with rbw for 20 seconds: rbwpw SERVICE (Oh My Zsh's rbw)
# requires: rbw

use ../lib/root.nu [clipcopy]

def services [] { do { ^rbw ls } | complete | get stdout | lines }

# Copy SERVICE's password to the clipboard and clear it 20 seconds later
export def rbwpw [service: string@services] {
    if (do { ^rbw unlock } | complete).exit_code != 0 {
        error make --unspanned {msg: "rbw is locked"}
    }
    let password = do { ^rbw get $service } | complete | get stdout | str trim --right --char "\n"
    if ($password | is-empty) {
        error make --unspanned {msg: $"($service) not found"}
    }
    # A token, so only the latest copy clears the clipboard.
    let token_file = $env.XDG_CACHE_HOME? | default ("~/.cache" | path expand) | path join oh-my-nu/rbwpw
    mkdir ($token_file | path dirname)
    let token = random uuid
    $token | save --force $token_file
    clipcopy $password
    print $"password for ($service) copied!"
    job spawn {
        sleep 20sec
        if (open --raw $token_file) == $token {
            clipcopy ""
            rm --force $token_file
        }
    } | ignore
}

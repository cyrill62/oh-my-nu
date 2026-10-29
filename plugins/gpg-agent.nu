# description: Point gpg-agent at this terminal and use it as the SSH agent (Oh My Zsh's gpg-agent)
# requires: gpgconf

export-env {
    let tty = do --ignore-errors { ^tty | complete } | get --optional stdout | default "" | str trim
    if ($tty | str starts-with '/dev/') {
        $env.GPG_TTY = $tty
    }
    # Use gpg-agent's ssh socket, unless another agent is already forwarded.
    if ($env.SSH_AUTH_SOCK? | is-empty) {
        let socket = do --ignore-errors { ^gpgconf --list-dirs agent-ssh-socket | complete } | get --optional stdout | default "" | str trim
        if ($socket | is-not-empty) and ($socket | path exists) {
            $env.SSH_AUTH_SOCK = $socket
        }
    }
}

# Tell gpg-agent to use the current terminal for pinentry (after switching tty)
export def gpg-update-tty [] { ^gpg-connect-agent updatestartuptty /bye | ignore }

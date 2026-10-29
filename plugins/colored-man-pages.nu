# description: Colours in man pages, through less (Oh My Zsh's colored-man-pages)
# requires: man

export-env {
    $env.LESS_TERMCAP_mb = (ansi --escape '1;31m')       # blink: bold red
    $env.LESS_TERMCAP_md = (ansi --escape '1;31m')       # bold: bold red
    $env.LESS_TERMCAP_me = (ansi reset)
    $env.LESS_TERMCAP_so = (ansi --escape '1;44;33m')    # standout: yellow on blue
    $env.LESS_TERMCAP_se = (ansi reset)
    $env.LESS_TERMCAP_us = (ansi --escape '1;32m')       # underline: bold green
    $env.LESS_TERMCAP_ue = (ansi reset)
    $env.GROFF_NO_SGR = "1"                              # let less colour groff output
}

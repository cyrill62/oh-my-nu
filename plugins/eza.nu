# description: eza listings with icons and git status, next to nushell's ls (and Oh My Zsh's eza names)
# requires: eza

export alias lx = eza --icons --group-directories-first
export alias lxa = eza --icons --group-directories-first --all
export alias lxl = eza --icons --group-directories-first --long --git --header
export alias lxla = eza --icons --group-directories-first --long --git --header --all
export alias lxt = eza --icons --tree --level=2
export alias lxta = eza --icons --tree --level=2 --all --ignore-glob=.git

# Oh My Zsh's eza names
export alias la = eza -la
export alias ldot = eza -ld .*
export alias lD = eza -lD
export alias lDD = eza -lDa
export alias ll = eza -l
export alias lsd = eza -d
export alias lsdl = eza -dl
export alias lS = eza -l -ssize
export alias lT = eza -l -snewest

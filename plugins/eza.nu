# description: eza listings with icons and git status, next to nushell's ls
# requires: eza

export alias lx = eza --icons --group-directories-first
export alias lxa = eza --icons --group-directories-first --all
export alias lxl = eza --icons --group-directories-first --long --git --header
export alias lxla = eza --icons --group-directories-first --long --git --header --all
export alias lxt = eza --icons --tree --level=2
export alias lxta = eza --icons --tree --level=2 --all --ignore-glob=.git

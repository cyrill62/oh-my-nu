# description: yay shortcuts (AUR helper; Oh My Zsh's archlinux names), plus AUR tables
# requires: yay

use ../lib/root.nu [c-locale]

# yay asks for sudo itself, so these are plain aliases.
export alias yaupg = yay -Syu
export alias yasu = yay -Syu --noconfirm
export alias yain = yay -S
export alias yains = yay -U
export alias yainsd = yay -S --asdeps
export alias yarem = yay -Rns
export alias yarep = yay -Si
export alias yareps = yay -Ss
export alias yaloc = yay -Qi
export alias yalocs = yay -Qs
export alias yalst = yay -Qe
export alias yaorph = yay -Qtd
export alias yamir = yay -Syy
export alias yaclean = yay -Sc
export alias yaclr = yay -Scc
export alias yastat = yay -Ps
export alias yacl = yay -Yc

# Packages installed from the AUR (foreign) as a table
export def yaaur [] { c-locale yay -Qm | lines | parse '{package} {version}' }

# AUR packages with updates as a table
export def yaout [] { c-locale yay -Qua | lines | parse --regex '^(?<package>\S+) (?<current>\S+) -> (?<version>\S+)' }

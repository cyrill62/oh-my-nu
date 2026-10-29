# description: Oh My Zsh's systemd aliases (sc-*, scu-* for --user), journalctl, units table
# requires: systemctl

use ../lib/root.nu [as-root c-locale]

export alias sc-list-units = systemctl list-units

export alias sc-is-active = systemctl is-active

export alias sc-status = systemctl status

export alias sc-show = systemctl show

export alias sc-help = systemctl help

export alias sc-list-unit-files = systemctl list-unit-files

export alias sc-is-enabled = systemctl is-enabled

export alias sc-list-jobs = systemctl list-jobs

export alias sc-show-environment = systemctl show-environment

export alias sc-cat = systemctl cat

export alias sc-list-timers = systemctl list-timers

# systemctl start (as root)
export def --wrapped sc-start [...args] { as-root systemctl start ...$args }

# systemctl stop (as root)
export def --wrapped sc-stop [...args] { as-root systemctl stop ...$args }

# systemctl reload (as root)
export def --wrapped sc-reload [...args] { as-root systemctl reload ...$args }

# systemctl restart (as root)
export def --wrapped sc-restart [...args] { as-root systemctl restart ...$args }

# systemctl try-restart (as root)
export def --wrapped sc-try-restart [...args] { as-root systemctl try-restart ...$args }

# systemctl isolate (as root)
export def --wrapped sc-isolate [...args] { as-root systemctl isolate ...$args }

# systemctl kill (as root)
export def --wrapped sc-kill [...args] { as-root systemctl kill ...$args }

# systemctl reset-failed (as root)
export def --wrapped sc-reset-failed [...args] { as-root systemctl reset-failed ...$args }

# systemctl enable (as root)
export def --wrapped sc-enable [...args] { as-root systemctl enable ...$args }

# systemctl disable (as root)
export def --wrapped sc-disable [...args] { as-root systemctl disable ...$args }

# systemctl reenable (as root)
export def --wrapped sc-reenable [...args] { as-root systemctl reenable ...$args }

# systemctl preset (as root)
export def --wrapped sc-preset [...args] { as-root systemctl preset ...$args }

# systemctl mask (as root)
export def --wrapped sc-mask [...args] { as-root systemctl mask ...$args }

# systemctl unmask (as root)
export def --wrapped sc-unmask [...args] { as-root systemctl unmask ...$args }

# systemctl link (as root)
export def --wrapped sc-link [...args] { as-root systemctl link ...$args }

# systemctl load (as root)
export def --wrapped sc-load [...args] { as-root systemctl load ...$args }

# systemctl cancel (as root)
export def --wrapped sc-cancel [...args] { as-root systemctl cancel ...$args }

# systemctl set-environment (as root)
export def --wrapped sc-set-environment [...args] { as-root systemctl set-environment ...$args }

# systemctl unset-environment (as root)
export def --wrapped sc-unset-environment [...args] { as-root systemctl unset-environment ...$args }

# systemctl edit (as root)
export def --wrapped sc-edit [...args] { as-root systemctl edit ...$args }

# systemctl enable --now (as root)
export def --wrapped sc-enable-now [...args] { as-root systemctl enable --now ...$args }

# systemctl disable --now (as root)
export def --wrapped sc-disable-now [...args] { as-root systemctl disable --now ...$args }

# systemctl mask --now (as root)
export def --wrapped sc-mask-now [...args] { as-root systemctl mask --now ...$args }

export alias scu-list-units = systemctl --user list-units

export alias scu-is-active = systemctl --user is-active

export alias scu-status = systemctl --user status

export alias scu-show = systemctl --user show

export alias scu-help = systemctl --user help

export alias scu-list-unit-files = systemctl --user list-unit-files

export alias scu-is-enabled = systemctl --user is-enabled

export alias scu-list-jobs = systemctl --user list-jobs

export alias scu-show-environment = systemctl --user show-environment

export alias scu-cat = systemctl --user cat

export alias scu-list-timers = systemctl --user list-timers

export alias scu-start = systemctl --user start

export alias scu-stop = systemctl --user stop

export alias scu-reload = systemctl --user reload

export alias scu-restart = systemctl --user restart

export alias scu-try-restart = systemctl --user try-restart

export alias scu-isolate = systemctl --user isolate

export alias scu-kill = systemctl --user kill

export alias scu-reset-failed = systemctl --user reset-failed

export alias scu-enable = systemctl --user enable

export alias scu-disable = systemctl --user disable

export alias scu-reenable = systemctl --user reenable

export alias scu-preset = systemctl --user preset

export alias scu-mask = systemctl --user mask

export alias scu-unmask = systemctl --user unmask

export alias scu-link = systemctl --user link

export alias scu-load = systemctl --user load

export alias scu-cancel = systemctl --user cancel

export alias scu-set-environment = systemctl --user set-environment

export alias scu-unset-environment = systemctl --user unset-environment

export alias scu-edit = systemctl --user edit

export alias scu-enable-now = systemctl --user enable --now

export alias scu-disable-now = systemctl --user disable --now

export alias scu-mask-now = systemctl --user mask --now

export alias sc-failed = systemctl --failed

export alias jf = journalctl --follow

export alias jfu = journalctl --follow --unit

export alias jb = journalctl --boot

# Units as a table (--all for inactive ones too)
export def sct [--all (-a), --user (-u)] {
    let flags = (if $all { ["--all"] } else { [] }) ++ (if $user { ["--user"] } else { [] })
    c-locale systemctl list-units ...$flags --output=json | from json | select unit load active sub description
}

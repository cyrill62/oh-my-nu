# description: Oh My Zsh's systemd aliases (sc-*, scu-* for --user), journalctl, units table
# requires: systemctl

use ../lib/root.nu [as-root c-locale]

export alias sc-cat = systemctl cat

export alias sc-get-default = systemctl get-default

export alias sc-help = systemctl help

export alias sc-is-active = systemctl is-active

export alias sc-is-enabled = systemctl is-enabled

export alias sc-is-failed = systemctl is-failed

export alias sc-is-system-running = systemctl is-system-running

export alias sc-list-dependencies = systemctl list-dependencies

export alias sc-list-jobs = systemctl list-jobs

export alias sc-list-sockets = systemctl list-sockets

export alias sc-list-timers = systemctl list-timers

export alias sc-list-unit-files = systemctl list-unit-files

export alias sc-list-units = systemctl list-units

export alias sc-show = systemctl show

export alias sc-show-environment = systemctl show-environment

export alias sc-status = systemctl status

# systemctl add-requires (as root)
export def --wrapped sc-add-requires [...args] { as-root systemctl add-requires ...$args }

# systemctl add-wants (as root)
export def --wrapped sc-add-wants [...args] { as-root systemctl add-wants ...$args }

# systemctl cancel (as root)
export def --wrapped sc-cancel [...args] { as-root systemctl cancel ...$args }

# systemctl daemon-reexec (as root)
export def --wrapped sc-daemon-reexec [...args] { as-root systemctl daemon-reexec ...$args }

# systemctl daemon-reload (as root)
export def --wrapped sc-daemon-reload [...args] { as-root systemctl daemon-reload ...$args }

# systemctl default (as root)
export def --wrapped sc-default [...args] { as-root systemctl default ...$args }

# systemctl disable (as root)
export def --wrapped sc-disable [...args] { as-root systemctl disable ...$args }

# systemctl edit (as root)
export def --wrapped sc-edit [...args] { as-root systemctl edit ...$args }

# systemctl emergency (as root)
export def --wrapped sc-emergency [...args] { as-root systemctl emergency ...$args }

# systemctl enable (as root)
export def --wrapped sc-enable [...args] { as-root systemctl enable ...$args }

# systemctl halt (as root)
export def --wrapped sc-halt [...args] { as-root systemctl halt ...$args }

# systemctl import-environment (as root)
export def --wrapped sc-import-environment [...args] { as-root systemctl import-environment ...$args }

# systemctl isolate (as root)
export def --wrapped sc-isolate [...args] { as-root systemctl isolate ...$args }

# systemctl kexec (as root)
export def --wrapped sc-kexec [...args] { as-root systemctl kexec ...$args }

# systemctl kill (as root)
export def --wrapped sc-kill [...args] { as-root systemctl kill ...$args }

# systemctl link (as root)
export def --wrapped sc-link [...args] { as-root systemctl link ...$args }

# systemctl list-machines (as root)
export def --wrapped sc-list-machines [...args] { as-root systemctl list-machines ...$args }

# systemctl load (as root)
export def --wrapped sc-load [...args] { as-root systemctl load ...$args }

# systemctl mask (as root)
export def --wrapped sc-mask [...args] { as-root systemctl mask ...$args }

# systemctl preset (as root)
export def --wrapped sc-preset [...args] { as-root systemctl preset ...$args }

# systemctl preset-all (as root)
export def --wrapped sc-preset-all [...args] { as-root systemctl preset-all ...$args }

# systemctl reenable (as root)
export def --wrapped sc-reenable [...args] { as-root systemctl reenable ...$args }

# systemctl reload (as root)
export def --wrapped sc-reload [...args] { as-root systemctl reload ...$args }

# systemctl reload-or-restart (as root)
export def --wrapped sc-reload-or-restart [...args] { as-root systemctl reload-or-restart ...$args }

# systemctl reset-failed (as root)
export def --wrapped sc-reset-failed [...args] { as-root systemctl reset-failed ...$args }

# systemctl rescue (as root)
export def --wrapped sc-rescue [...args] { as-root systemctl rescue ...$args }

# systemctl restart (as root)
export def --wrapped sc-restart [...args] { as-root systemctl restart ...$args }

# systemctl revert (as root)
export def --wrapped sc-revert [...args] { as-root systemctl revert ...$args }

# systemctl set-default (as root)
export def --wrapped sc-set-default [...args] { as-root systemctl set-default ...$args }

# systemctl set-environment (as root)
export def --wrapped sc-set-environment [...args] { as-root systemctl set-environment ...$args }

# systemctl set-property (as root)
export def --wrapped sc-set-property [...args] { as-root systemctl set-property ...$args }

# systemctl start (as root)
export def --wrapped sc-start [...args] { as-root systemctl start ...$args }

# systemctl stop (as root)
export def --wrapped sc-stop [...args] { as-root systemctl stop ...$args }

# systemctl switch-root (as root)
export def --wrapped sc-switch-root [...args] { as-root systemctl switch-root ...$args }

# systemctl try-reload-or-restart (as root)
export def --wrapped sc-try-reload-or-restart [...args] { as-root systemctl try-reload-or-restart ...$args }

# systemctl try-restart (as root)
export def --wrapped sc-try-restart [...args] { as-root systemctl try-restart ...$args }

# systemctl unmask (as root)
export def --wrapped sc-unmask [...args] { as-root systemctl unmask ...$args }

# systemctl unset-environment (as root)
export def --wrapped sc-unset-environment [...args] { as-root systemctl unset-environment ...$args }

export alias sc-hibernate = systemctl hibernate

export alias sc-hybrid-sleep = systemctl hybrid-sleep

export alias sc-poweroff = systemctl poweroff

export alias sc-reboot = systemctl reboot

export alias sc-suspend = systemctl suspend

# systemctl enable --now (as root)
export def --wrapped sc-enable-now [...args] { as-root systemctl enable --now ...$args }

# systemctl disable --now (as root)
export def --wrapped sc-disable-now [...args] { as-root systemctl disable --now ...$args }

# systemctl mask --now (as root)
export def --wrapped sc-mask-now [...args] { as-root systemctl mask --now ...$args }

export alias sc-failed = systemctl --failed

# systemctl edit --full (as root)
export def --wrapped sc-edit-full [...args] { as-root systemctl edit --full ...$args }

export alias scu-cat = systemctl --user cat

export alias scu-get-default = systemctl --user get-default

export alias scu-help = systemctl --user help

export alias scu-is-active = systemctl --user is-active

export alias scu-is-enabled = systemctl --user is-enabled

export alias scu-is-failed = systemctl --user is-failed

export alias scu-is-system-running = systemctl --user is-system-running

export alias scu-list-dependencies = systemctl --user list-dependencies

export alias scu-list-jobs = systemctl --user list-jobs

export alias scu-list-sockets = systemctl --user list-sockets

export alias scu-list-timers = systemctl --user list-timers

export alias scu-list-unit-files = systemctl --user list-unit-files

export alias scu-list-units = systemctl --user list-units

export alias scu-show = systemctl --user show

export alias scu-show-environment = systemctl --user show-environment

export alias scu-status = systemctl --user status

export alias scu-add-requires = systemctl --user add-requires

export alias scu-add-wants = systemctl --user add-wants

export alias scu-cancel = systemctl --user cancel

export alias scu-daemon-reexec = systemctl --user daemon-reexec

export alias scu-daemon-reload = systemctl --user daemon-reload

export alias scu-default = systemctl --user default

export alias scu-disable = systemctl --user disable

export alias scu-edit = systemctl --user edit

export alias scu-emergency = systemctl --user emergency

export alias scu-enable = systemctl --user enable

export alias scu-halt = systemctl --user halt

export alias scu-import-environment = systemctl --user import-environment

export alias scu-isolate = systemctl --user isolate

export alias scu-kexec = systemctl --user kexec

export alias scu-kill = systemctl --user kill

export alias scu-link = systemctl --user link

export alias scu-list-machines = systemctl --user list-machines

export alias scu-load = systemctl --user load

export alias scu-mask = systemctl --user mask

export alias scu-preset = systemctl --user preset

export alias scu-preset-all = systemctl --user preset-all

export alias scu-reenable = systemctl --user reenable

export alias scu-reload = systemctl --user reload

export alias scu-reload-or-restart = systemctl --user reload-or-restart

export alias scu-reset-failed = systemctl --user reset-failed

export alias scu-rescue = systemctl --user rescue

export alias scu-restart = systemctl --user restart

export alias scu-revert = systemctl --user revert

export alias scu-set-default = systemctl --user set-default

export alias scu-set-environment = systemctl --user set-environment

export alias scu-set-property = systemctl --user set-property

export alias scu-start = systemctl --user start

export alias scu-stop = systemctl --user stop

export alias scu-switch-root = systemctl --user switch-root

export alias scu-try-reload-or-restart = systemctl --user try-reload-or-restart

export alias scu-try-restart = systemctl --user try-restart

export alias scu-unmask = systemctl --user unmask

export alias scu-unset-environment = systemctl --user unset-environment

export alias scu-enable-now = systemctl --user enable --now

export alias scu-disable-now = systemctl --user disable --now

export alias scu-mask-now = systemctl --user mask --now

export alias scu-failed = systemctl --user --failed

export alias scu-edit-full = systemctl --user edit --full

export alias jf = journalctl --follow

export alias jfu = journalctl --follow --unit

export alias jb = journalctl --boot

# Units as a table (--all for inactive ones too)
export def sct [--all (-a), --user (-u)] {
    let flags = (if $all { ["--all"] } else { [] }) ++ (if $user { ["--user"] } else { [] })
    c-locale systemctl list-units ...$flags --output=json | from json | select unit load active sub description
}

# description: snap shortcuts (Oh My Zsh's snap names)
# requires: snap

use ../lib/root.nu [as-root]

export alias sv = snap version
export alias sf = snap find
export alias sin = snap info
export alias sl = snap list
export alias schg = snap changes

# Install snaps
export def --wrapped si [...args] { as-root snap install ...$args }

# Remove snaps
export def --wrapped sr [...args] { as-root snap remove ...$args }

# Refresh snaps
export def --wrapped sref [...args] { as-root snap refresh ...$args }

# Revert a snap
export def --wrapped srev [...args] { as-root snap revert ...$args }

# Enable a snap
export def --wrapped se [...args] { as-root snap enable ...$args }

# Disable a snap
export def --wrapped sd [...args] { as-root snap disable ...$args }

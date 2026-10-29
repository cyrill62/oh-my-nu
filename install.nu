# Enables oh-my-nu: `nu install.nu [PLUGIN...]` (default: a sensible set).
use oh-my-nu.nu *

def main [...plugins: string] {
    let defaults = [common]
    let wanted = if ($plugins | is-empty) { $defaults } else { $plugins }
    omn enable ...$wanted
}

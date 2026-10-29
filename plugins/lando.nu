# description: Run artisan, composer, drush, npm, php, wp, yarn... through lando inside Lando projects (Oh My Zsh's lando)
# requires: lando
#
# $env.LANDO_ZSH_SITES_DIRECTORY (default ~/Sites) and
# $env.LANDO_ZSH_CONFIG_FILE (default .lando.yml) as in Oh My Zsh.

# Whether the current directory is inside a Lando project under the sites directory
def in-lando [] {
    let sites = $env.LANDO_ZSH_SITES_DIRECTORY? | default ("~/Sites" | path expand)
    let config = $env.LANDO_ZSH_CONFIG_FILE? | default ".lando.yml"
    mut dir = pwd
    if not ($dir | str starts-with $"($sites)/") { return false }
    while $dir != $sites {
        if ($dir | path join $config | path exists) { return true }
        $dir = $dir | path dirname
    }
    false
}

def --wrapped via-lando [cmd: string, ...args] {
    if (in-lando) { ^lando $cmd ...$args } else { run-external $cmd ...$args }
}

export def --wrapped artisan [...args] { via-lando artisan ...$args }
export def --wrapped composer [...args] { via-lando composer ...$args }
export def --wrapped drush [...args] { via-lando drush ...$args }
export def --wrapped gulp [...args] { via-lando gulp ...$args }
export def --wrapped npm [...args] { via-lando npm ...$args }
export def --wrapped php [...args] { via-lando php ...$args }
export def --wrapped wp [...args] { via-lando wp ...$args }
export def --wrapped yarn [...args] { via-lando yarn ...$args }

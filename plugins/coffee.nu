# description: Oh My Zsh's coffee aliases: compile CoffeeScript snippets, from the clipboard too
# requires: coffee

use ../lib/root.nu [clipcopy clippaste]

# Compile a CoffeeScript snippet to JavaScript
export def cf [code: string] { ^coffee -peb $code }

# Compile a CoffeeScript snippet and copy the JavaScript
export def cfc [code: string] { clipcopy (cf $code) }

# Compile the clipboard's CoffeeScript
export def cfp [] { cf (clippaste) }

# Compile the clipboard's CoffeeScript and copy the JavaScript back
export def cfpc [] { clipcopy (cfp) }

# description: Search front-end files: ajs/acss with ack, fjs/fcss by name (Oh My Zsh's sfffe)
# requires: ack

# Search JavaScript files with ack
export def --wrapped ajs [...args] { ^ack ...$args '--type' js }

# Search CSS files with ack
export def --wrapped acss [...args] { ^ack ...$args '--type' css }

# .js files whose name starts with PREFIX
export def fjs [prefix: string = ""] { glob $"**/($prefix)*.js" | path relative-to (pwd) }

# .css files whose name starts with PREFIX
export def fcss [prefix: string = ""] { glob $"**/($prefix)*.css" | path relative-to (pwd) }

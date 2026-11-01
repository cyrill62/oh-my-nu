# description: Oh My Zsh's shopify aliases, through the project's node_modules/.bin/shopify when there is one
# requires: shopify

# The nearest node_modules/.bin/shopify up to $HOME, else the installed one
def shopify-bin [] {
    mut dir = $env.PWD
    while $dir != "/" and $dir != $env.HOME {
        let bin = $dir | path join node_modules/.bin/shopify
        if ($bin | path exists) { return $bin }
        $dir = $dir | path dirname
    }
    "shopify"
}

# shopify, through the project's node_modules/.bin/shopify when there is one
export def --wrapped shop [...rest] { run-external (shopify-bin) ...$rest }

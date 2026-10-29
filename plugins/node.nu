# description: Open the Node.js API docs for your node version: node-docs [SECTION] (Oh My Zsh's node)
# requires: node

use ../lib/root.nu [open-url]

# Open the docs of a section (fs, http...) for the installed node version
export def node-docs [section: string = "all"] {
    open-url $"https://nodejs.org/docs/(^node --version | str trim)/api/($section).html"
}

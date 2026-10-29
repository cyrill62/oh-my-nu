# description: Search the web from the shell: google, ddg, github, crates, docsrs...
# requires: xdg-open

const ENGINES = {
    google: "https://www.google.com/search?q="
    ddg: "https://duckduckgo.com/?q="
    github: "https://github.com/search?type=code&q="
    crates: "https://crates.io/search?q="
    docsrs: "https://docs.rs/releases/search?query="
    nushell: "https://www.nushell.sh/search.html?q="
    wiki: "https://en.wikipedia.org/w/index.php?search="
    gentoo: "https://packages.gentoo.org/packages/search?q="
    youtube: "https://www.youtube.com/results?search_query="
}

# Open a web search: web-search ENGINE TERMS... (engines: google ddg github crates docsrs nushell wiki gentoo youtube)
export def main [engine: string, ...terms: string] {
    let base = $ENGINES | get --optional $engine
    if $base == null {
        error make --unspanned {msg: $"unknown engine '($engine)', use one of: ($ENGINES | columns | str join ', ')"}
    }
    let url = $base + ($terms | str join ' ' | url encode)
    ^xdg-open $url out+err> /dev/null
}

export def google [...terms: string] { main google ...$terms }
export def ddg [...terms: string] { main ddg ...$terms }
export def ghs [...terms: string] { main github ...$terms }
export def crates [...terms: string] { main crates ...$terms }
export def docsrs [...terms: string] { main docsrs ...$terms }
export def wiki [...terms: string] { main wiki ...$terms }
export def gpkg [...terms: string] { main gentoo ...$terms }

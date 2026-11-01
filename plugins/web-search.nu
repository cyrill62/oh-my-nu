# description: Search the web from the shell (Oh My Zsh's web-search engines and names): google, ddg, github, rscrate...
# requires:

use ../lib/root.nu [open-url]

const ENGINES = {
    google: "https://www.google.com/search?q="
    bing: "https://www.bing.com/search?q="
    brave: "https://search.brave.com/search?q="
    yahoo: "https://search.yahoo.com/search?p="
    duckduckgo: "https://www.duckduckgo.com/?q="
    startpage: "https://www.startpage.com/do/search?q="
    yandex: "https://yandex.ru/yandsearch?text="
    github: "https://github.com/search?q="
    baidu: "https://www.baidu.com/s?wd="
    ecosia: "https://www.ecosia.org/search?q="
    goodreads: "https://www.goodreads.com/search?q="
    qwant: "https://www.qwant.com/?q="
    givero: "https://www.givero.com/search?q="
    stackoverflow: "https://stackoverflow.com/search?q="
    wolframalpha: "https://www.wolframalpha.com/input/?i="
    archive: "https://web.archive.org/web/*/"
    scholar: "https://scholar.google.com/scholar?q="
    ask: "https://www.ask.com/web?q="
    youtube: "https://www.youtube.com/results?search_query="
    deepl: "https://www.deepl.com/translator#auto/auto/"
    dockerhub: "https://hub.docker.com/search?q="
    gems: "https://rubygems.org/search?query="
    npmpkg: "https://www.npmjs.com/search?q="
    packagist: "https://packagist.org/?query="
    gopkg: "https://pkg.go.dev/search?m=package&q="
    maven: "https://central.sonatype.com/search?q="
    pypi: "https://pypi.org/search/?q="
    aur: "https://aur.archlinux.org/packages?O=0&K="
    archwiki: "https://wiki.archlinux.org/index.php?search="
    wikipedia: "https://en.wikipedia.org/w/index.php?search="
    chatgpt: "https://chatgpt.com/?q="
    grok: "https://grok.com/?q="
    claudeai: "https://claude.ai/new?q="
    reddit: "https://www.reddit.com/search/?q="
    ppai: "https://www.perplexity.ai/search/new?q="
    rscrate: "https://crates.io/search?q="
    rsdoc: "https://docs.rs/releases/search?query="
    nushell: "https://www.nushell.sh/search.html?q="
    gentoo: "https://packages.gentoo.org/packages/search?q="
}

# Open a web search: web-search ENGINE TERMS..., or the engine's home page
# without terms. Add engines with $env.WEB_SEARCH_ENGINES = {name: "https://...?q="}.
export def main [engine: string, ...terms: string] {
    let engines = $ENGINES | merge ($env.WEB_SEARCH_ENGINES? | default {})
    let base = $engines | get --optional $engine
    if $base == null {
        error make --unspanned {msg: $"Search engine '($engine)' not supported. Use one of: ($engines | columns | str join ', ')"}
    }
    let url = if ($terms | is-empty) {
        $base | url parse | $"($in.scheme)://($in.host)"
    } else {
        $base + ($terms | str join ' ' | url encode)
    }
    open-url $url
}

# Oh My Zsh's name for web-search
export alias web_search = main

export def bing [...terms: string] { main bing ...$terms }
export def brs [...terms: string] { main brave ...$terms }
export def google [...terms: string] { main google ...$terms }
export def yahoo [...terms: string] { main yahoo ...$terms }
export def ddg [...terms: string] { main duckduckgo ...$terms }
export def sp [...terms: string] { main startpage ...$terms }
export def yandex [...terms: string] { main yandex ...$terms }
export def github [...terms: string] { main github ...$terms }
export def baidu [...terms: string] { main baidu ...$terms }
export def ecosia [...terms: string] { main ecosia ...$terms }
export def goodreads [...terms: string] { main goodreads ...$terms }
export def qwant [...terms: string] { main qwant ...$terms }
export def givero [...terms: string] { main givero ...$terms }
export def stackoverflow [...terms: string] { main stackoverflow ...$terms }
export def wolframalpha [...terms: string] { main wolframalpha ...$terms }
export def archive [...terms: string] { main archive ...$terms }
export def scholar [...terms: string] { main scholar ...$terms }
export def ask [...terms: string] { main ask ...$terms }
export def youtube [...terms: string] { main youtube ...$terms }
export def deepl [...terms: string] { main deepl ...$terms }
export def dockerhub [...terms: string] { main dockerhub ...$terms }
export def gems [...terms: string] { main gems ...$terms }
export def npmpkg [...terms: string] { main npmpkg ...$terms }
export def packagist [...terms: string] { main packagist ...$terms }
export def gopkg [...terms: string] { main gopkg ...$terms }
export def maven [...terms: string] { main maven ...$terms }
export def pypi [...terms: string] { main pypi ...$terms }
export def aur [...terms: string] { main aur ...$terms }
export def archwiki [...terms: string] { main archwiki ...$terms }
export def wikipedia [...terms: string] { main wikipedia ...$terms }
export def chatgpt [...terms: string] { main chatgpt ...$terms }
export def grokcom [...terms: string] { main grok ...$terms }
export def claudeai [...terms: string] { main claudeai ...$terms }
export def reddit [...terms: string] { main reddit ...$terms }
export def ppai [...terms: string] { main ppai ...$terms }
export def rscrate [...terms: string] { main rscrate ...$terms }
export def rsdoc [...terms: string] { main rsdoc ...$terms }
export def gpkg [...terms: string] { main gentoo ...$terms }

# DuckDuckGo bangs
export def wiki [...terms: string] { main duckduckgo "!w" ...$terms }
export def news [...terms: string] { main duckduckgo "!n" ...$terms }
export def map [...terms: string] { main duckduckgo "!m" ...$terms }
export def image [...terms: string] { main duckduckgo "!i" ...$terms }
export def ducky [...terms: string] { main duckduckgo "!" ...$terms }

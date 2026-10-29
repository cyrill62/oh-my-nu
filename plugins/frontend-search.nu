# description: Search front-end documentation sites from the shell (Oh My Zsh's frontend-search)
# requires:

use ../lib/root.nu [open-url]

# Site search through google, or duckduckgo with $env.FRONTEND_SEARCH_FALLBACK = "duckduckgo"
# ($env.FRONTEND_SEARCH_FALLBACK_LUCKY = "true" jumps to the first result)
def fallback [site: string] {
    if ($env.FRONTEND_SEARCH_FALLBACK_LUCKY? == "true") {
        $"https://duckduckgo.com/?q=!ducky+site%3A($site)+"
    } else if ($env.FRONTEND_SEARCH_FALLBACK? == "duckduckgo") {
        $"https://duckduckgo.com/?sites=($site)&q="
    } else {
        $"https://google.com/search?as_sitesearch=($site)&as_q="
    }
}

def sites [] {
    {
        angular: "https://angular.io/?search="
        angularjs: (fallback angularjs.org)
        bem: (fallback bem.info)
        bootsnipp: "https://bootsnipp.com/search?q="
        bundlephobia: "https://bundlephobia.com/result?p="
        caniuse: "https://caniuse.com/#search="
        codepen: "https://codepen.io/search/pens?q="
        compassdoc: "http://compass-style.org/search?q="
        cssflow: "http://www.cssflow.com/search?q="
        dartlang: (fallback dart.dev)
        emberjs: (fallback emberjs.com/)
        flowtype: (fallback flow.org/en/docs/)
        fontello: "http://fontello.com/#search="
        github: "https://github.com/search?q="
        html5please: "https://html5please.com/#"
        jestjs: (fallback jestjs.io)
        jquery: "https://api.jquery.com/?s="
        lodash: "https://devdocs.io/lodash/index#"
        mdn: "https://developer.mozilla.org/search?q="
        nodejs: (fallback nodejs.org/en/docs/)
        npmjs: "https://www.npmjs.com/search?q="
        packagephobia: "https://packagephobia.now.sh/result?p="
        qunit: "https://api.qunitjs.com/?s="
        reactjs: (fallback reactjs.org/)
        smacss: (fallback smacss.com)
        stackoverflow: "https://stackoverflow.com/search?q="
        typescript: (fallback www.typescriptlang.org/docs)
        unheap: "http://www.unheap.com/?s="
        vuejs: (fallback vuejs.org)
        nextjs: (fallback nextjs.org)
    }
}

def site-names [] { sites | columns }

# Search a front-end site: frontend SITE TERMS... (without terms, opens the site's search page)
export def main [site: string@site-names, ...terms: string] {
    let base = sites | get --optional $site
    if $base == null {
        error make --unspanned {msg: $"unknown site '($site)', use one of: (site-names | str join ', ')"}
    }
    open-url ($base + ($terms | str join ' ' | url encode))
}

export def angular [...terms: string] { main angular ...$terms }
export def angularjs [...terms: string] { main angularjs ...$terms }
export def bem [...terms: string] { main bem ...$terms }
export def bootsnipp [...terms: string] { main bootsnipp ...$terms }
export def bundlephobia [...terms: string] { main bundlephobia ...$terms }
export def caniuse [...terms: string] { main caniuse ...$terms }
export def codepen [...terms: string] { main codepen ...$terms }
export def compassdoc [...terms: string] { main compassdoc ...$terms }
export def cssflow [...terms: string] { main cssflow ...$terms }
export def dartlang [...terms: string] { main dartlang ...$terms }
export def emberjs [...terms: string] { main emberjs ...$terms }
export def flowtype [...terms: string] { main flowtype ...$terms }
export def fontello [...terms: string] { main fontello ...$terms }
export def github [...terms: string] { main github ...$terms }
export def html5please [...terms: string] { main html5please ...$terms }
export def jestjs [...terms: string] { main jestjs ...$terms }
export def jquery [...terms: string] { main jquery ...$terms }
export def lodash [...terms: string] { main lodash ...$terms }
export def mdn [...terms: string] { main mdn ...$terms }
export def nodejs [...terms: string] { main nodejs ...$terms }
export def npmjs [...terms: string] { main npmjs ...$terms }
export def packagephobia [...terms: string] { main packagephobia ...$terms }
export def qunit [...terms: string] { main qunit ...$terms }
export def reactjs [...terms: string] { main reactjs ...$terms }
export def smacss [...terms: string] { main smacss ...$terms }
export def stackoverflow [...terms: string] { main stackoverflow ...$terms }
export def typescript [...terms: string] { main typescript ...$terms }
export def unheap [...terms: string] { main unheap ...$terms }
export def vuejs [...terms: string] { main vuejs ...$terms }
export def nextjs [...terms: string] { main nextjs ...$terms }

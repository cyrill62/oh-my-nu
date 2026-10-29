# description: A random quote from quotationspage.com (Oh My Zsh's rand-quote)
# requires:

# Print a random quote
export def quote [] {
    let page = try { http get --raw --max-time 3sec https://www.quotationspage.com/random.php | decode iso-8859-1 } catch { return }
    let match = $page | parse --regex '<dt class="quote"><a[^>]*>(?<quote>.*?)</a>.*?<dd class="author">.*?<b>(?:<a[^>]*>)?(?<author>[^<]+)' | get --optional 0
    if $match != null {
        print $"(ansi yellow)($match.author)(ansi reset): “(ansi magenta)($match.quote | str trim)(ansi reset)”"
    }
}

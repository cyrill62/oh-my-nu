# description: A random hitokoto (Japanese/Chinese quote) from v1.hitokoto.cn (Oh My Zsh's hitokoto)
# requires:

# Print a random hitokoto
export def main [] {
    let data = try { http get --max-time 3sec https://v1.hitokoto.cn } catch { return }
    print $"(ansi yellow)($data.from)(ansi reset): “(ansi magenta)($data.hitokoto)(ansi reset)”"
}

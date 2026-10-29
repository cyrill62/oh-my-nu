# description: Turn proxy variables on and off: proxy enable|disable|status (Oh My Zsh's shell-proxy)
# requires:
#
# The proxy comes from $env.SHELLPROXY_URL (and $env.SHELLPROXY_NO_PROXY), or
# from an executable ~/.config/proxy (or $env.SHELLPROXY_CONFIG) printing the
# URL on its first line and the no_proxy list on its second. Unlike Oh My Zsh,
# ssh is not routed through the proxy.

const NAMES = [HTTP_PROXY HTTPS_PROXY FTP_PROXY RSYNC_PROXY ALL_PROXY]

def settings [] {
    mut url = $env.SHELLPROXY_URL? | default ""
    mut no_proxy = $env.SHELLPROXY_NO_PROXY? | default ""
    let config = $env.SHELLPROXY_CONFIG? | default ("~/.config/proxy" | path expand)
    if ($url | is-empty) and ($config | path exists) {
        let lines = run-external $config | lines | str trim
        $url = $lines | get --optional 0 | default ""
        if ($no_proxy | is-empty) { $no_proxy = $lines | get --optional 1 | default "" }
    }
    if ($url | is-empty) {
        error make --unspanned {msg: $"shell-proxy: no proxy configuration found.\nSet SHELLPROXY_URL or create an executable config file at ($config)"}
    }
    {url: $url, no_proxy: $no_proxy}
}

def actions [] { [enable disable status] }

# Set, unset or show the proxy variables
export def --env proxy [action: string@actions] {
    let all = $NAMES ++ ($NAMES | str lowercase)
    match $action {
        "enable" => {
            let s = settings
            load-env ($all | reduce --fold {} {|name, acc| $acc | insert $name $s.url })
            if ($s.no_proxy | is-not-empty) { load-env {NO_PROXY: $s.no_proxy, no_proxy: $s.no_proxy} }
        }
        "disable" => { hide-env --ignore-errors ...$all NO_PROXY no_proxy }
        "status" => {
            $all ++ [NO_PROXY no_proxy] | each {|name| {name: $name, value: ($env | get --optional $name)} } | where value != null
        }
        _ => { error make --unspanned {msg: "usage: proxy enable|disable|status"} }
    }
}

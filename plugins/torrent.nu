# description: Turn a magnet link into a .torrent file (Oh My Zsh's torrent)
# requires:

# Write HASH.torrent (or NAME.torrent) for a magnet link; returns the file name
export def magnet_to_torrent [magnet: string] {
    let hash = $magnet | parse --regex 'xt=urn:btih:(?<h>[^&/]+)' | get --optional h.0
    if $hash == null { error make --unspanned {msg: "not a magnet link (no xt=urn:btih:)"} }
    let name = $magnet | parse --regex 'dn=(?<n>[^&/]+)' | get --optional n.0 | default $hash
    let file = $"($name).torrent"
    $"d10:magnet-uri($magnet | str length):($magnet)e\n" | save --force $file
    $file
}

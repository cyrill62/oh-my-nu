# description: URL encode/decode (Oh My Zsh's urltools), on strings or pipelines
# requires:

# Percent-encode the argument or the input
export def urlencode [text?: string] { let input = $in; $text | default $input | url encode --all }

# Decode a percent-encoded argument or input
export def urldecode [text?: string] { let input = $in; $text | default $input | url decode }

# description: JSON helpers (Oh My Zsh's jsontools): pp_json, is_json, ...
# requires:

# Pretty-print JSON from the input
export def pp_json [] { from json | to json --indent 2 }

# Whether the input is valid JSON
export def is_json [] { try { from json | ignore; true } catch { false } }

# Percent-encode the input as JSON
export def urlencode_json [] { from json | to json --raw | url encode --all }

# Decode percent-encoded JSON from the input
export def urldecode_json [] { url decode | from json | to json --indent 2 }

# description: base64 helpers (Oh My Zsh's encode64): e64, d64 on strings or pipelines
# requires:

# base64-encode the argument or the input
export def main [text?: string] { let input = $in; $text | default $input | encode base64 }

# base64-decode the argument or the input to text
export def decode64 [text?: string] { let input = $in; $text | default $input | decode base64 | decode }

# base64-encode a file
export def encodefile64 [file: path] { open --raw $file | encode base64 }

# base64-encode a file
export def ef64 [file: path] { encodefile64 $file }

# base64-encode the argument or the input
export def e64 [text?: string] { let input = $in; $text | default $input | encode base64 }

# base64-decode the argument or the input to text
export def d64 [text?: string] { let input = $in; $text | default $input | decode base64 | decode }

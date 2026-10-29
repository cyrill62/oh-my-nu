# description: Create an archive in any format: ua FORMAT FILES... (Oh My Zsh's universalarchive)
# requires:

const FORMATS = [7z bz2 gz lzma lzo rar tar tbz tgz tlz txz tZ xz Z zip zst]

def formats [] { $FORMATS }

# Archive files into NAME.FORMAT (name from the file, or the parent directory for several files)
export def ua [format: string@formats, ...files: path] {
    if ($files | is-empty) or $format not-in $FORMATS {
        error make --unspanned {msg: $"usage: ua FORMAT FILES...\nformats: ($FORMATS | str join ', ')"}
    }
    let first = $files.0 | path expand
    if not ($first | path exists) { error make --unspanned {msg: $"($first) not found"} }
    let base = if ($files | length) > 1 {
        $first | path dirname | path basename
    } else if ($first | path type) == file {
        $first | path parse | get stem
    } else {
        $first | path basename
    }
    mut output = $"($base).($format)"
    mut n = 1
    while ($output | path exists) {
        $output = $"($base)_($n).($format)"
        $n += 1
    }
    let out = $output
    let one = $files.0
    match $format {
        "7z" => { ^7z a -bso0 $out ...$files }
        "bz2" => { ^bzip2 --keep --stdout $one | save --raw $out }
        "gz" => { ^gzip --keep --stdout $one | save --raw $out }
        "lzma" => { ^lzma --keep --stdout $one | save --raw $out }
        "lzo" => { ^lzop --stdout $one | save --raw $out }
        "rar" => { ^rar a $out ...$files }
        "tar" => { ^tar -cf $out ...$files }
        "tbz" => { ^tar -cjf $out ...$files }
        "tgz" => { ^tar -czf $out ...$files }
        "tlz" => { ^tar --lzma -cf $out ...$files }
        "txz" => { ^tar -cJf $out ...$files }
        "tZ" => { ^tar -cZf $out ...$files }
        "xz" => { ^xz --keep --stdout $one | save --raw $out }
        "Z" => { ^compress -c $one | save --raw $out }
        "zip" => { ^zip -qr $out ...$files }
        "zst" => { ^zstd --quiet --stdout $one | save --raw $out }
    }
    $out
}

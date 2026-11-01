# description: `extract` any archive (tar.*, zip, 7z, rar, gz, xz, zst...)
# requires: tar

# Extract archives into the current directory, picking the tool by extension
export def main [
    ...archives: path
    --remove (-r)  # delete each archive after a successful extraction
] {
    if ($archives | is-empty) {
        error make --unspanned {msg: "usage: extract [-r] ARCHIVE..."}
    }
    for archive in $archives {
        if not ($archive | path exists) {
            error make --unspanned {msg: $"($archive): no such file"}
        }
        let name = $archive | path basename | str lowercase
        let command = match $name {
            $n if ($n =~ '\.(tar\.gz|tgz)$') => [tar xzf $archive]
            $n if ($n =~ '\.(tar\.bz2|tbz2?)$') => [tar xjf $archive]
            $n if ($n =~ '\.(tar\.xz|txz)$') => [tar xJf $archive]
            $n if ($n =~ '\.(tar\.zst|tzst)$') => [tar --zstd -xf $archive]
            $n if ($n =~ '\.(tar\.lz|tar\.lzma|tlz)$') => [tar --lzma -xf $archive]
            $n if ($n =~ '\.tar$') => [tar xf $archive]
            $n if ($n =~ '\.(zip|jar|war|whl|apk|xpi|epub)$') => [unzip -o $archive]
            $n if ($n =~ '\.7z$') => [7z x $archive]
            $n if ($n =~ '\.rar$') => [unrar x -o+ $archive]
            $n if ($n =~ '\.gz$') => [gunzip --keep $archive]
            $n if ($n =~ '\.bz2$') => [bunzip2 --keep $archive]
            $n if ($n =~ '\.xz$') => [unxz --keep $archive]
            $n if ($n =~ '\.zst$') => [unzstd $archive]
            $n if ($n =~ '\.lzma$') => [unlzma --keep $archive]
            $n if ($n =~ '\.z$') => [uncompress $archive]
            _ => { error make --unspanned {msg: $"($archive): unknown archive type"} }
        }
        run-external ...$command
        if $remove and $env.LAST_EXIT_CODE == 0 {
            rm $archive
        }
    }
}

export alias x = main

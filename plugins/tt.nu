# description: Convert between Unix timestamps and dates: tt, tt 1700000000, tt "2026-10-29 12:00:00" (Oh My Zsh's tt)
# requires:

# No argument: now as a timestamp; a timestamp: its date; a date: its timestamp
export def main [value?: string] {
    if $value == null {
        date now | format date '%s' | into int
    } else if ($value | str contains '-') {
        let text = if ($value | str contains ' ') { $value } else { $"($value) 00:00:00" }
        $text | into datetime --format '%Y-%m-%d %H:%M:%S' --timezone local | format date '%s' | into int
    } else {
        $value | into datetime --format '%s' | date to-timezone local | format date '%Y-%m-%d %H:%M:%S'
    }
}

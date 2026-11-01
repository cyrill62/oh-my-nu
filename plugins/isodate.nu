# description: ISO 8601 dates (Oh My Zsh's isodate): isodate, isodate_utc, isodate_basic...
# requires:

# Local time, e.g. 2026-10-29T14:03:12+0100
export def main [] { date now | format date '%Y-%m-%dT%H:%M:%S%z' }

# UTC time, e.g. 2026-10-29T13:03:12Z
export def isodate_utc [] { date now | date to-timezone UTC | format date '%Y-%m-%dT%H:%M:%SZ' }

# Basic format in UTC (for file names), e.g. 20261029T130312Z
export def isodate_basic [] { date now | date to-timezone UTC | format date '%Y%m%dT%H%M%SZ' }

# Same as isodate_basic
export def isodate_basic_utc [] { isodate_basic }

# Seconds since the epoch
export def unixstamp [] { date now | format date '%s' | into int }

# Date and time in the locale's format
export def date_locale [] { date now | format date '%c' }

# Today's date, e.g. 2026-10-29
export def isoday [] { date now | format date '%Y-%m-%d' }

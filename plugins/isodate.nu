# description: ISO 8601 dates (Oh My Zsh's isodate): isodate, isodate_utc, isodate_basic...
# requires:

# Local time, e.g. 2026-10-29T14:03:12+01:00
export def main [] { date now | format date '%Y-%m-%dT%H:%M:%S%:z' }

# UTC time, e.g. 2026-10-29T13:03:12Z
export def isodate_utc [] { date now | date to-timezone UTC | format date '%Y-%m-%dT%H:%M:%SZ' }

# Basic format (for file names), e.g. 20261029T140312+0100
export def isodate_basic [] { date now | format date '%Y%m%dT%H%M%S%z' }

# Basic format in UTC, e.g. 20261029T130312Z
export def isodate_basic_utc [] { date now | date to-timezone UTC | format date '%Y%m%dT%H%M%SZ' }

# Today's date, e.g. 2026-10-29
export def isoday [] { date now | format date '%Y-%m-%d' }

# description: Oh My Zsh's rsync aliases
# requires: rsync

export alias rsync-copy = rsync --archive --verbose --compress --human-readable --progress
export alias rsync-move = rsync --archive --verbose --compress --human-readable --progress --remove-source-files
export alias rsync-update = rsync --archive --verbose --compress --human-readable --progress --update
export alias rsync-synchronize = rsync --archive --verbose --compress --human-readable --progress --update --delete

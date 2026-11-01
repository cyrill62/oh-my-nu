# description: Oh My Zsh's lighthouse aliases: open a ticket of the project's .lighthouse-url
# requires:

use ../lib/root.nu [open-url]

# Open a Lighthouse ticket of the project in .lighthouse-url
export def lho [ticket: string] {
    if not (".lighthouse-url" | path exists) {
        print "There is no .lighthouse-url file in the current directory..."
        return
    }
    print $"Opening ticket #($ticket)"
    open-url $"(open --raw .lighthouse-url | str trim)/tickets/($ticket)"
}

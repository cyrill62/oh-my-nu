# description: Chuck Norris facts: chuck, chuck_cow (Oh My Zsh's chucknorris; reads its fortunes file)
# requires:

use ../lib/root.nu [random-fortune omz-plugin-dir]

# A random Chuck Norris fact
export def chuck [] { random-fortune (omz-plugin-dir chucknorris | path join fortunes/chucknorris) }

# A random Chuck Norris fact, thought by a cow
export def chuck_cow [] { chuck | ^cowthink }

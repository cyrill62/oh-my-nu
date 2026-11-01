# description: Oh My Zsh's ansible aliases
# requires: ansible

export alias a = ansible
export alias aconf = ansible-config
export alias acon = ansible-console
export alias ainv = ansible-inventory
export alias aplaybook = ansible-playbook
export alias adoc = ansible-doc
export alias agal = ansible-galaxy
export alias apull = ansible-pull
export alias aval = ansible-vault
export alias aver = ansible --version

# Create a role skeleton with ansible-galaxy and show it
export def arinit [name: string] {
    print $"Ansible Role : ($name) Creating...."
    ^ansible-galaxy init $name
    if (which tree | is-not-empty) { ^tree $name }
}

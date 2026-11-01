# description: podman shortcuts (Oh My Zsh's podman names), plus tables
# requires: podman

export alias pbl = podman build
export alias pcin = podman container inspect
export alias pcls = podman container ls
export alias pclsa = podman container ls --all
export alias pib = podman image build
export alias pii = podman image inspect
export alias pils = podman image ls
export alias pipu = podman image push
export alias pirm = podman image rm
export alias pit = podman image tag
export alias pmif = podman machine info
export alias pmit = podman machine init
export alias pmis = podman machine inspect
export alias pml = podman machine list
export alias pmo = podman machine os
export alias pmrm = podman machine rm
export alias pms = podman machine set
export alias pmss = podman machine ssh
export alias pmst = podman machine start
export alias pmsp = podman machine stop
export alias plo = podman container logs
export alias pnc = podman network create
export alias pncn = podman network connect
export alias pndcn = podman network disconnect
export alias pni = podman network inspect
export alias pnls = podman network ls
export alias pnrm = podman network rm
export alias ppo = podman container port
export alias ppu = podman pull
export alias pr = podman container run
export alias prit = podman container run --interactive --tty
export alias prm = podman container rm
export alias 'prm!' = podman container rm --force
export alias pst = podman container start
export alias prs = podman container restart
export alias pstp = podman container stop
export alias ptop = podman top
export alias pvi = podman volume inspect
export alias pvls = podman volume ls
export alias pvprune = podman volume prune
export alias pxc = podman container exec
export alias pxcit = podman container exec --interactive --tty

# Stop every running container
export def psta [] {
    let ids = ^podman ps --quiet | lines
    if ($ids | is-not-empty) { ^podman stop ...$ids }
}

# Not in Oh My Zsh
export alias pdps = podman ps
export alias pdpsa = podman ps --all
export alias pdlf = podman container logs --follow
export alias pdsp = podman system prune
export alias pdpod = podman pod
export alias pdco = podman compose
export alias pdcup = podman compose up
export alias pdcdn = podman compose down

# Containers as a table (--all for stopped ones too)
export def pdpst [--all (-a)] {
    let all = if $all { [--all] } else { [] }
    ^podman ps ...$all --format json | from json | select --optional Id Names Image State Status Ports
}

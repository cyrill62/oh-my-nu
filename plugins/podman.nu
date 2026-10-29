# description: podman shortcuts (docker plugin's names with a pd prefix), plus tables
# requires: podman

export alias pdbl = podman build
export alias pdps = podman ps
export alias pdpsa = podman ps --all
export alias pdi = podman images
export alias pdrun = podman run
export alias pdrit = podman run --interactive --tty --rm
export alias pdex = podman exec --interactive --tty
export alias pdl = podman logs
export alias pdlf = podman logs --follow
export alias pdrm = podman rm
export alias pdrmi = podman rmi
export alias pdst = podman start
export alias pdstp = podman stop
export alias pdpu = podman pull
export alias pdvls = podman volume ls
export alias pdnls = podman network ls
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

# description: docker and docker compose shortcuts (Oh My Zsh's docker and docker-compose names), plus tables
# requires: docker

export alias dbl = docker build
export alias dcin = docker container inspect
export alias dcls = docker container ls
export alias dclsa = docker container ls --all
export alias dcprune = docker container prune
export alias dib = docker image build
export alias dii = docker image inspect
export alias dils = docker image ls
export alias dipu = docker image push
export alias dipru = docker image prune --all
export alias dirm = docker image rm
export alias dit = docker image tag
export alias dlo = docker container logs
export alias dlf = docker container logs --follow
export alias dnc = docker network create
export alias dncn = docker network connect
export alias dndcn = docker network disconnect
export alias dni = docker network inspect
export alias dnls = docker network ls
export alias dnprune = docker network prune
export alias dnrm = docker network rm
export alias dpo = docker container port
export alias dps = docker ps
export alias dpsa = docker ps --all
export alias dpu = docker pull
export alias dr = docker container run
export alias drit = docker container run --interactive --tty
export alias drm = docker container rm
export alias 'drm!' = docker container rm --force
export alias dsprune = docker system prune
export alias dst = docker container start
export alias drs = docker container restart
export alias dstp = docker container stop
export alias dsts = docker stats
export alias dtop = docker top
export alias dvi = docker volume inspect
export alias dvls = docker volume ls
export alias dvprune = docker volume prune
export alias dxc = docker container exec
export alias dxcit = docker container exec --interactive --tty

# Stop every running container
export def dsta [] {
    let ids = ^docker ps --quiet | lines
    if ($ids | is-not-empty) { ^docker stop ...$ids }
}

# docker compose (Oh My Zsh's docker-compose names)
export alias dco = docker compose
export alias dcb = docker compose build
export alias dcc = docker compose config
export alias dce = docker compose exec
export alias dcps = docker compose ps
export alias dcrestart = docker compose restart
export alias dcrm = docker compose rm
export alias dcr = docker compose run
export alias dcstop = docker compose stop
export alias dcup = docker compose up
export alias dcupb = docker compose up --build
export alias dcupd = docker compose up --detach
export alias dcupdb = docker compose up --detach --build
export alias dcupw = docker compose up --watch
export alias dcupwb = docker compose up --watch --build
export alias dcdn = docker compose down
export alias dcl = docker compose logs
export alias dclf = docker compose logs --follow
export alias dclF = docker compose logs --follow --tail 0
export alias dcpull = docker compose pull
export alias dcstart = docker compose start
export alias dck = docker compose kill
export alias dcv = docker compose version
export alias dcsts = docker compose stats
export alias dci = docker compose images

# Containers as a table (--all for stopped ones too)
export def dpst [--all (-a)] {
    let all = if $all { [--all] } else { [] }
    ^docker ps ...$all --format '{{json .}}'
    | lines
    | each { from json }
    | select --optional ID Names Image State Status Ports
}

# Images as a table
export def dilst [] {
    ^docker images --format '{{json .}}'
    | lines
    | each { from json }
    | select --optional Repository Tag ID CreatedSince Size
}

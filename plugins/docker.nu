# description: docker and docker compose shortcuts, plus container tables
# requires: docker

export alias dbl = docker build
export alias dps = docker ps
export alias dpsa = docker ps --all
export alias di = docker images
export alias dr = docker run
export alias drit = docker run --interactive --tty --rm
export alias dex = docker exec --interactive --tty
export alias dl = docker logs
export alias dlf = docker logs --follow
export alias drm = docker rm
export alias drmi = docker rmi
export alias dst = docker start
export alias dstp = docker stop
export alias dpu = docker pull
export alias dvls = docker volume ls
export alias dnls = docker network ls
export alias dsp = docker system prune

export alias dco = docker compose
export alias dcup = docker compose up
export alias dcupd = docker compose up --detach
export alias dcdn = docker compose down
export alias dcps = docker compose ps
export alias dclf = docker compose logs --follow
export alias dcb = docker compose build
export alias dcr = docker compose run
export alias dcrestart = docker compose restart

# Containers as a table (--all for stopped ones too)
export def dpst [--all (-a)] {
    let all = if $all { [--all] } else { [] }
    ^docker ps ...$all --format '{{json .}}'
    | lines
    | each { from json }
    | select --optional ID Names Image State Status Ports
}

# Images as a table
export def dit [] {
    ^docker images --format '{{json .}}'
    | lines
    | each { from json }
    | select --optional Repository Tag ID CreatedSince Size
}

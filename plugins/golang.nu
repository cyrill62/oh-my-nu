# description: Oh My Zsh's go aliases
# requires: go

export alias gob = go build
export alias goc = go clean
export alias god = go doc
export alias gof = go fmt
export alias gofa = go fmt ./...
export alias gofx = go fix
export alias gog = go get
export alias goga = go get ./...
export alias goi = go install
export alias gol = go list
export alias gom = go mod
export alias gomt = go mod tidy
export alias gor = go run
export alias got = go test
export alias gota = go test ./...
export alias gov = go vet
export alias gove = go version
export alias gow = go work
export alias goenv = go env

# Go to $GOPATH (default ~/go)
export def --env gopa [] { cd (^go env GOPATH | str trim) }

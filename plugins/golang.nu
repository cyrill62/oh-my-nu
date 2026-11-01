# description: Oh My Zsh's go aliases
# requires: go

export alias gob = go build
export alias goc = go clean
export alias god = go doc
export alias goe = go env
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
export alias goto = go tool
export alias gotoc = go tool compile
export alias gotod = go tool dist
export alias gotofx = go tool fix
export alias gov = go vet
export alias gove = go version
export alias gow = go work

# Go to $GOPATH (default ~/go)
export def --env gopa [] { cd (^go env GOPATH | str trim) }

# Go to $GOPATH/bin
export def --env gopb [] { cd (^go env GOPATH | str trim | path join bin) }

# Go to $GOPATH/src
export def --env gops [] { cd (^go env GOPATH | str trim | path join src) }

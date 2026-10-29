# description: Oh My Zsh's npm aliases, plus a package.json scripts table
# requires: npm

export alias npmg = npm install --global
export alias npmS = npm install --save
export alias npmD = npm install --save-dev
export alias npmF = npm install --force
export alias npmO = npm outdated
export alias npmU = npm update
export alias npmV = npm --version
export alias npmL = npm list
export alias npmL0 = npm list --depth=0
export alias npmst = npm start
export alias npmt = npm test
export alias npmR = npm run
export alias npmP = npm publish
export alias npmI = npm init
export alias npmi = npm info
export alias npmSe = npm search
export alias npmrd = npm run dev
export alias npmrb = npm run build
export alias npmci = npm ci
export alias npmx = npx

# Put ./node_modules/.bin first on PATH
export def --env npmE [] {
    $env.PATH = ($env.PATH | prepend ("node_modules/.bin" | path expand) | uniq)
}

# Scripts of ./package.json as a table
export def npms [] {
    open package.json | get --optional scripts | default {} | transpose name command
}

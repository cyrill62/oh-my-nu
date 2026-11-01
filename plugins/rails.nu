# description: Oh My Zsh's rails aliases, through the project's binstubs
# requires: ruby

# The project's rails: bin/stubs/rails, bin/rails, script/rails (Rails 3),
# script/<command> (Rails 2), or the installed one.
def --wrapped rails-command [...rest] {
    if ("bin/stubs/rails" | path exists) {
        ^./bin/stubs/rails ...$rest
    } else if ("bin/rails" | path exists) {
        ^./bin/rails ...$rest
    } else if ("script/rails" | path exists) {
        ^ruby script/rails ...$rest
    } else if ("script/server" | path exists) {
        ^ruby $"script/($rest | get 0? | default '')" ...($rest | skip 1)
    } else {
        ^rails ...$rest
    }
}

# The project's rake: bin/stubs/rake, bin/rake, `bundle exec rake` with a
# Gemfile, or the installed one.
def --wrapped rake-command [...rest] {
    if ("bin/stubs/rake" | path exists) {
        ^./bin/stubs/rake ...$rest
    } else if ("bin/rake" | path exists) {
        ^./bin/rake ...$rest
    } else if (which bundle | is-not-empty) and (("Gemfile" | path exists) or ("gems.rb" | path exists)) {
        ^bundle exec rake ...$rest
    } else {
        ^rake ...$rest
    }
}

# A db task, for one database when the first argument is a bare word
# (`rdm cache` runs db:migrate:cache); flags, VAR=value and tasks pass through.
def --wrapped rails-db [task: string, ...rest] {
    let database = $rest | get 0?
    if $database != null and not ($database starts-with "-" or $database =~ "[=:]") {
        print --stderr $"Running: rails ($task):($database) ($rest | skip 1 | str join ' ')"
        rails-command $"($task):($database)" ...($rest | skip 1)
    } else {
        rails-command $task ...$rest
    }
}

# rails, run through the project's binstub when there is one
export def --wrapped main [...rest] { rails-command ...$rest }

# rake, run through the project's binstub or bundler when there is one
export def --wrapped rake [...rest] { rake-command ...$rest }

# RAILS_ENV=development, then the command line (`RED rake db:migrate`)
export def --wrapped RED [...rest] { with-env {RAILS_ENV: development} { run-external ...$rest } }
# RAILS_ENV=production, then the command line
export def --wrapped REP [...rest] { with-env {RAILS_ENV: production} { run-external ...$rest } }
# RAILS_ENV=test, then the command line
export def --wrapped RET [...rest] { with-env {RAILS_ENV: test} { run-external ...$rest } }

export alias rc = rails-command console
export alias rcs = rails-command console --sandbox
export alias rd = rails-command destroy
export alias rdb = rails-command dbconsole
export alias rdmrs = rails-command db:migrate:reset
export alias rdmtc = rails-command db:migrate db:test:clone
export alias rds = rails-command db:seed
export alias rdtc = rails-command db:test:clone
export alias rdtp = rails-command db:test:prepare
export alias rgen = rails-command generate
export alias rgm = rails-command generate migration
export alias rlc = rails-command log:clear
export alias rmd = rails-command middleware
export alias rn = rails-command notes
export alias rp = rails-command plugin
export alias rr = rails-command routes
export alias rrc = rails-command routes --controller
export alias rre = rails-command routes --expanded
export alias rrg = rails-command routes --grep
export alias rru = rails-command routes --unused
export alias rs = rails-command server
export alias rsb = rails-command server --bind
export alias rsd = rails-command server --debugger
export alias rsp = rails-command server --port
export alias rsts = rails-command stats
export alias rt = rails-command test
export alias rta = rails-command test:all
export alias ru = rails-command runner

# db tasks: an optional database name first (`rdm cache STEP=2`)
export def --wrapped rdc [...rest] { rails-db db:create ...$rest }
export def --wrapped rdd [...rest] { rails-db db:drop ...$rest }
export def --wrapped rdm [...rest] { rails-db db:migrate ...$rest }
export def --wrapped rdmd [...rest] { rails-db db:migrate:down ...$rest }
export def --wrapped rdmr [...rest] { rails-db db:migrate:redo ...$rest }
export def --wrapped rdms [...rest] { rails-db db:migrate:status ...$rest }
export def --wrapped rdmu [...rest] { rails-db db:migrate:up ...$rest }
export def --wrapped rdr [...rest] { rails-db db:rollback ...$rest }
export def --wrapped rdrs [...rest] { rails-db db:reset ...$rest }
export def --wrapped rdsl [...rest] { rails-db db:schema:load ...$rest }

export alias fmns = foreman start

export alias rkdc = rake-command db:create
export alias rkdd = rake-command db:drop
export alias rkdm = rake-command db:migrate
export alias rkdmd = rake-command db:migrate:down
export alias rkdmr = rake-command db:migrate:redo
export alias rkdms = rake-command db:migrate:status
export alias rkdmtc = rake-command db:migrate db:test:clone
export alias rkdmu = rake-command db:migrate:up
export alias rkdr = rake-command db:rollback
export alias rkdrs = rake-command db:reset
export alias rkds = rake-command db:seed
export alias rkdsl = rake-command db:schema:load
export alias rkdtc = rake-command db:test:clone
export alias rkdtp = rake-command db:test:prepare
export alias rklc = rake-command log:clear
export alias rkmd = rake-command middleware
export alias rkn = rake-command notes
export alias rksts = rake-command stats
export alias rkt = rake-command test

export alias devlog = tail -f log/development.log
export alias prodlog = tail -f log/production.log
export alias testlog = tail -f log/test.log

# Rails 2 scripts
export alias sc = ruby script/console
export alias sd = ruby script/server --debugger
export alias sg = ruby script/generate
export alias sp = ruby script/plugin
export alias sr = ruby script/runner
export alias ssp = ruby script/spec
export alias sstat = thin --stats /thin/stats start

# Rails 2 console on a remote host, in the app's directory
export def remote_console [
    host: string  # ssh destination
    dir: string   # the application's directory there
] {
    ^ssh $host $"\( cd ($dir) && ruby script/console production \)"
}

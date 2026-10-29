# description: Open Jira issues, projects and boards from the shell (Oh My Zsh's jira)
# requires:
#
# Settings, as in Oh My Zsh: .jira-url / ~/.jira-url / $env.JIRA_URL,
# .jira-prefix / ~/.jira-prefix / $env.JIRA_PREFIX, .jira-default-action /
# ~/.jira-default-action / $env.JIRA_DEFAULT_ACTION, $env.JIRA_NAME,
# $env.JIRA_RAPID_BOARD, $env.JIRA_RAPID_VIEW, $env.JIRA_TEMPO_PATH.

use ../lib/root.nu [open-url]

# A setting from ./.jira-NAME, ~/.jira-NAME or an environment variable
def setting [file: string, var: string] {
    let found = [$file ("~" | path expand | path join $file)] | where { path exists } | get --optional 0
    if $found != null { open --raw $found | str trim } else { $env | get --optional $var | default "" }
}

def actions [] { [new mine project dashboard tempo assigned reported branch dumpconfig help] }

# The issue key of the current branch: feature/ABC-123-fix -> ABC-123
export def jira_branch [] {
    let prefix = setting .jira-prefix JIRA_PREFIX
    let name = ^git rev-parse --abbrev-ref HEAD | str trim | split row '/' | last
    let parts = $name | split row '_'
    let issue = if ($parts | length) == 1 and ($name | str contains '-') {
        let p = $name | split row '-'
        $"($p.0)-($p.1)"
    } else {
        $parts.0
    }
    if ($issue | str lowercase | str starts-with ($prefix | str lowercase)) { $issue } else { $"($prefix)($issue)" }
}

# jira [new|mine|project KEY|dashboard [VIEW]|tempo|assigned [NAME]|reported [NAME]|branch|ISSUE [m]]
export def main [action?: string@actions, extra?: string] {
    let action = $action | default (setting .jira-default-action JIRA_DEFAULT_ACTION | if ($in | is-empty) { "new" } else { $in })
    let url = setting .jira-url JIRA_URL
    if ($url | is-empty) {
        error make --unspanned {msg: "JIRA URL is not specified anywhere. Use a .jira-url file, ~/.jira-url or $env.JIRA_URL"}
    }
    let prefix = setting .jira-prefix JIRA_PREFIX
    match $action {
        "new" => { open-url $"($url)/secure/CreateIssue!default.jspa" }
        "mine" => { open-url $"($url)/issues/?filter=-1" }
        "project" => { open-url $"($url)/jira/software/c/projects/($extra)/summary" }
        "dashboard" => {
            if ($env.JIRA_RAPID_BOARD? == "true") {
                let view = $extra | default ($env.JIRA_RAPID_VIEW? | default "")
                open-url (if ($view | is-empty) { $"($url)/secure/RapidBoard.jspa" } else { $"($url)/secure/RapidBoard.jspa?rapidView=($view)" })
            } else {
                open-url $"($url)/secure/Dashboard.jspa"
            }
        }
        "tempo" => { open-url $"($url)($env.JIRA_TEMPO_PATH? | default '/secure/Tempo.jspa')" }
        "assigned" | "reported" => {
            let lookup = if $action == "reported" { "reporter" } else { "assignee" }
            let name = $extra | default ($env.JIRA_NAME? | default "")
            if ($name | is-empty) { error make --unspanned {msg: "JIRA_NAME not specified"} }
            let query = $"($lookup)+%3D+%22($name)%22+AND+resolution+%3D+unresolved+ORDER+BY+priority+DESC%2C+created+ASC"
            open-url $"($url)/secure/IssueNavigator.jspa?reset=true&jqlQuery=($query)"
        }
        "dumpconfig" => {
            {JIRA_URL: $url, JIRA_PREFIX: $prefix, JIRA_NAME: $env.JIRA_NAME?, JIRA_RAPID_VIEW: $env.JIRA_RAPID_VIEW?, JIRA_RAPID_BOARD: $env.JIRA_RAPID_BOARD?, JIRA_DEFAULT_ACTION: $env.JIRA_DEFAULT_ACTION?, JIRA_TEMPO_PATH: $env.JIRA_TEMPO_PATH?}
        }
        "help" | "usage" => { help jira }
        _ => {
            let issue = if $action == "branch" { jira_branch } else { $"($prefix)($action | str uppercase)" }
            let fragment = if $extra == "m" { "#add-comment" } else { "" }
            open-url $"($url)/browse/($issue)($fragment)"
        }
    }
}

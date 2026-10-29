# description: AWS profile and region switching (Oh My Zsh's aws): asp, asr, agp, agr, aws_profiles
# requires: aws

def config-file [] { $env.AWS_CONFIG_FILE? | default "~/.aws/config" | path expand }

# Profiles of the AWS config
export def aws_profiles [] {
    if not (config-file | path exists) { return [] }
    open --raw (config-file) | lines | parse --regex '^\[(?:profile\s+)?(?<name>[^\]]+)\]' | get name | where { not ($in starts-with 'sso-session') }
}

# AWS regions (from the CLI)
export def aws_regions [] {
    ^aws ec2 describe-regions --output json | from json | get Regions.RegionName | sort
}

# Current profile
export def agp [] { $env.AWS_PROFILE? }

# Current region
export def agr [] { $env.AWS_REGION? }

# Set the AWS profile (no argument: clear it); `asp NAME login [session]` also runs sso login
export def --env asp [profile?: string@aws_profiles, action?: string, session?: string] {
    if $profile == null {
        hide-env --ignore-errors AWS_DEFAULT_PROFILE AWS_PROFILE AWS_EB_PROFILE AWS_PROFILE_REGION
        print "AWS profile cleared."
        return
    }
    let profiles = aws_profiles
    if $profile not-in $profiles {
        error make --unspanned {msg: $"Profile '($profile)' not found in '(config-file)'. Available profiles: ($profiles | str join ', ')"}
    }
    $env.AWS_DEFAULT_PROFILE = $profile
    $env.AWS_PROFILE = $profile
    $env.AWS_EB_PROFILE = $profile
    $env.AWS_PROFILE_REGION = (do { ^aws configure get region } | complete | get stdout | str trim)
    match $action {
        "login" => { if $session == null { ^aws sso login } else { ^aws sso login --sso-session $session } }
        "logout" => { ^aws sso logout }
        _ => {}
    }
}

# Set the AWS region (no argument: clear it)
export def --env asr [region?: string] {
    if $region == null {
        hide-env --ignore-errors AWS_DEFAULT_REGION AWS_REGION
        print "AWS region cleared."
        return
    }
    $env.AWS_DEFAULT_REGION = $region
    $env.AWS_REGION = $region
}

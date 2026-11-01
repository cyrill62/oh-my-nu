# description: Oh My Zsh's opentofu aliases (tt*), plus an outputs table
# requires: tofu

export alias tt = tofu
export alias tta = tofu apply
export alias 'tta!' = tofu apply -auto-approve
export alias ttc = tofu console
export alias ttd = tofu destroy
export alias 'ttd!' = tofu destroy -auto-approve
export alias ttf = tofu fmt
export alias ttfr = tofu fmt -recursive
export alias tti = tofu init
export alias ttiu = tofu init -upgrade
export alias tto = tofu output
export alias ttp = tofu plan
export alias ttv = tofu validate
export alias tts = tofu state
export alias ttsl = tofu state list
export alias ttt = tofu test
export alias ttsh = tofu show
export alias ttap = tofu apply -parallelism=1
export alias ttapp = tofu apply tfplan
export alias ttir = tofu init -reconfigure
export alias ttiur = tofu init -upgrade -reconfigure
export alias ttpo = tofu plan -out tfplan
export alias ttr = tofu refresh
export alias ttws = tofu workspace

# Outputs as a record
export def ttot [] { ^tofu output -json | from json | transpose name info | each {|o| {name: $o.name, value: $o.info.value, sensitive: $o.info.sensitive} } }

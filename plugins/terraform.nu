# description: Oh My Zsh's terraform aliases (tf*), plus an outputs table
# requires: terraform

export alias tf = terraform
export alias tfa = terraform apply
export alias 'tfa!' = terraform apply -auto-approve
export alias tfc = terraform console
export alias tfd = terraform destroy
export alias 'tfd!' = terraform destroy -auto-approve
export alias tff = terraform fmt
export alias tffr = terraform fmt -recursive
export alias tfi = terraform init
export alias tfiu = terraform init -upgrade
export alias tfo = terraform output
export alias tfp = terraform plan
export alias tfv = terraform validate
export alias tfs = terraform state
export alias tfsl = terraform state list
export alias tft = terraform test
export alias tfsh = terraform show
export alias tfw = terraform workspace
export alias tfap = terraform apply -parallelism=1
export alias tfapp = terraform apply tfplan
export alias tfdp = terraform destroy -parallelism=1
export alias tfir = terraform init -reconfigure
export alias tfiur = terraform init -upgrade -reconfigure
export alias tfpo = terraform plan -out tfplan
export alias tfwl = terraform workspace list
export alias tfws = terraform workspace select

# Outputs as a record
export def tfot [] { ^terraform output -json | from json | transpose name info | each {|o| {name: $o.name, value: $o.info.value, sensitive: $o.info.sensitive} } }

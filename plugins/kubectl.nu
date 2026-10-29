# description: Oh My Zsh's kubectl aliases, plus a pods table
# requires: kubectl

export alias k = kubectl
export alias kaf = kubectl apply -f
export alias kak = kubectl apply -k
export alias kca = kubectl --all-namespaces
export alias keti = kubectl exec --stdin --tty
export alias kcuc = kubectl config use-context
export alias kcsc = kubectl config set-context
export alias kcdc = kubectl config delete-context
export alias kccc = kubectl config current-context
export alias kcgc = kubectl config get-contexts
export alias kdel = kubectl delete
export alias kdelf = kubectl delete -f
export alias kd = kubectl describe
export alias ke = kubectl edit
export alias kg = kubectl get
export alias kga = kubectl get all
export alias kgaa = kubectl get all --all-namespaces
export alias kgp = kubectl get pods
export alias kgpa = kubectl get pods --all-namespaces
export alias kgpw = kubectl get pods --watch
export alias kgpwide = kubectl get pods -o wide
export alias kgpl = kubectl get pods -l
export alias kdp = kubectl describe pods
export alias kep = kubectl edit pods
export alias kdelp = kubectl delete pods
export alias kgs = kubectl get svc
export alias kds = kubectl describe svc
export alias kes = kubectl edit svc
export alias kdels = kubectl delete svc
export alias kgd = kubectl get deployment
export alias kdd = kubectl describe deployment
export alias ked = kubectl edit deployment
export alias kdeld = kubectl delete deployment
export alias ksd = kubectl scale deployment
export alias krsd = kubectl rollout status deployment
export alias krrd = kubectl rollout restart deployment
export alias kgi = kubectl get ingress
export alias kdi = kubectl describe ingress
export alias kgns = kubectl get namespaces
export alias kcn = kubectl config set-context --current --namespace
export alias kgcm = kubectl get configmaps
export alias kgsec = kubectl get secret
export alias kgno = kubectl get nodes
export alias kdno = kubectl describe node
export alias kgss = kubectl get statefulset
export alias kgds = kubectl get daemonset
export alias kgj = kubectl get job
export alias kgcj = kubectl get cronjob
export alias kgpvc = kubectl get pvc
export alias kl = kubectl logs
export alias klf = kubectl logs --follow
export alias kpf = kubectl port-forward
export alias kcp = kubectl cp
export alias ktn = kubectl top node
export alias ktp = kubectl top pod

# Pods as a table (--all-namespaces with -A)
export def kgpt [--all-namespaces (-A)] {
    let scope = if $all_namespaces { [--all-namespaces] } else { [] }
    ^kubectl get pods ...$scope -o json
    | from json
    | get items
    | each {|pod| {
        namespace: $pod.metadata.namespace
        name: $pod.metadata.name
        phase: $pod.status.phase
        ready: ($pod.status.containerStatuses? | default [] | where ready | length)
        restarts: ($pod.status.containerStatuses? | default [] | get --optional restartCount | math sum)
        node: ($pod.spec.nodeName? | default "")
        created: ($pod.metadata.creationTimestamp | into datetime)
    } }
}

# description: Oh My Zsh's kubectl aliases, plus a pods table
# requires: kubectl

export alias k = kubectl
export alias kaf = kubectl apply -f
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

export alias kapk = kubectl apply -k
export alias kcrc = kubectl config rename-context
export alias kdelk = kubectl delete -k
export alias kge = kubectl get events --sort-by=.lastTimestamp
export alias kgew = kubectl get events --sort-by=.lastTimestamp --watch
export alias kgpn = kubectl get pods -n
export alias kgpsl = kubectl get pods --show-labels
export alias kgpall = kubectl get pods --all-namespaces -o wide
export alias kgsa = kubectl get svc --all-namespaces
export alias kgsw = kubectl get svc --watch
export alias kgswide = kubectl get svc -o wide
export alias kgia = kubectl get ingress --all-namespaces
export alias kei = kubectl edit ingress
export alias kdeli = kubectl delete ingress
export alias kens = kubectl edit namespace
export alias kdns = kubectl describe namespace
export alias kdelns = kubectl delete namespace
export alias kgcma = kubectl get configmaps --all-namespaces
export alias kecm = kubectl edit configmap
export alias kdcm = kubectl describe configmap
export alias kdelcm = kubectl delete configmap
export alias kgseca = kubectl get secret --all-namespaces
export alias kesec = kubectl edit secret
export alias kdsec = kubectl describe secret
export alias kdelsec = kubectl delete secret
export alias kgda = kubectl get deployment --all-namespaces
export alias kgdw = kubectl get deployment --watch
export alias kgdwide = kubectl get deployment -o wide
export alias kgrs = kubectl get replicaset
export alias kdrs = kubectl describe replicaset
export alias kers = kubectl edit replicaset
export alias krh = kubectl rollout history
export alias kru = kubectl rollout undo
export alias kgssa = kubectl get statefulset --all-namespaces
export alias kgssw = kubectl get statefulset --watch
export alias kgsswide = kubectl get statefulset -o wide
export alias kess = kubectl edit statefulset
export alias kdss = kubectl describe statefulset
export alias kdelss = kubectl delete statefulset
export alias ksss = kubectl scale statefulset
export alias krsss = kubectl rollout status statefulset
export alias krrss = kubectl rollout restart statefulset
export alias kl1h = kubectl logs --since 1h
export alias kl1m = kubectl logs --since 1m
export alias kl1s = kubectl logs --since 1s
export alias klf1h = kubectl logs --since 1h -f
export alias klf1m = kubectl logs --since 1m -f
export alias klf1s = kubectl logs --since 1s -f
export alias kgnosl = kubectl get nodes --show-labels
export alias keno = kubectl edit node
export alias kdelno = kubectl delete node
export alias kgpvca = kubectl get pvc --all-namespaces
export alias kgpvcw = kubectl get pvc --watch
export alias kepvc = kubectl edit pvc
export alias kdpvc = kubectl describe pvc
export alias kdelpvc = kubectl delete pvc
export alias kdsa = kubectl describe sa
export alias kdelsa = kubectl delete sa
export alias kgdsa = kubectl get daemonset --all-namespaces
export alias kgdsw = kubectl get daemonset --watch
export alias keds = kubectl edit daemonset
export alias kdds = kubectl describe daemonset
export alias kdelds = kubectl delete daemonset
export alias kecj = kubectl edit cronjob
export alias kdcj = kubectl describe cronjob
export alias kdelcj = kubectl delete cronjob
export alias kej = kubectl edit job
export alias kdj = kubectl describe job
export alias kdelj = kubectl delete job

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

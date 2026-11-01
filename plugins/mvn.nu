# description: Oh My Zsh's maven aliases, through the project's mvnw when there is one
# requires: mvn|mvnw

# The nearest executable mvnw up the directory tree, else mvn
def --wrapped mvn-or-mvnw [...args] {
    mut dir = $env.PWD
    while $dir != "/" and not (($dir | path join mvnw | path exists) and ($dir | path join mvnw | path type) == file) {
        $dir = $dir | path dirname
    }
    let wrapper = $dir | path join mvnw
    if ($wrapper | path exists) {
        print --stderr $"Running `($wrapper)`..."
        run-external $wrapper ...$args
    } else {
        ^mvn ...$args
    }
}

# mvn, through the project's mvnw when there is one
export def --wrapped main [...args] { mvn-or-mvnw ...$args }

# mvn on the pom.xml at the root of the git repository
export def --wrapped 'mvn!' [...args] {
    let root = do { ^git rev-parse --show-toplevel } | complete | get stdout | str trim
    mvn-or-mvnw -f ($root | default --empty "." | path join pom.xml) ...$args
}

export alias mvnag = mvn-or-mvnw archetype:generate
export alias mvnboot = mvn-or-mvnw spring-boot:run
export alias mvnc = mvn-or-mvnw clean
export alias mvncd = mvn-or-mvnw clean deploy
export alias mvnce = mvn-or-mvnw clean eclipse:clean eclipse:eclipse
export alias mvnci = mvn-or-mvnw clean install
export alias mvncie = mvn-or-mvnw clean install eclipse:eclipse
export alias mvncini = mvn-or-mvnw clean initialize
export alias mvncist = mvn-or-mvnw clean install -DskipTests
export alias mvncisto = mvn-or-mvnw clean install -DskipTests --offline
export alias mvncom = mvn-or-mvnw compile
export alias mvncp = mvn-or-mvnw clean package
export alias mvnct = mvn-or-mvnw clean test
export alias mvncv = mvn-or-mvnw clean verify
export alias mvncvst = mvn-or-mvnw clean verify -DskipTests
export alias mvnv = mvn-or-mvnw verify
export alias mvnvst = mvn-or-mvnw verify -DskipTests
export alias mvndp = mvn-or-mvnw deploy
export alias mvndocs = mvn-or-mvnw dependency:resolve -Dclassifier=javadoc
export alias mvndt = mvn-or-mvnw dependency:tree
export alias mvne = mvn-or-mvnw eclipse:eclipse
export alias mvnfmt = mvn-or-mvnw fmt:format
export alias mvnjetty = mvn-or-mvnw jetty:run
export alias mvnp = mvn-or-mvnw package
export alias mvnqdev = mvn-or-mvnw quarkus:dev
export alias mvns = mvn-or-mvnw site
export alias mvnsrc = mvn-or-mvnw dependency:sources
export alias mvnt = mvn-or-mvnw test
export alias mvntc = mvn-or-mvnw tomcat:run
export alias mvntc7 = mvn-or-mvnw tomcat7:run
export alias mvn-updates = mvn-or-mvnw versions:display-dependency-updates

# Not in Oh My Zsh
export alias mvni = mvn-or-mvnw install
export alias mvndr = mvn-or-mvnw dependency:resolve
export alias mvncio = mvn-or-mvnw clean install -o

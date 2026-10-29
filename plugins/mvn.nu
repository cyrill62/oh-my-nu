# description: Oh My Zsh's maven aliases
# requires: mvn

export alias mvnc = mvn clean
export alias mvnci = mvn clean install
export alias mvncist = mvn clean install -DskipTests
export alias mvnct = mvn clean test
export alias mvncv = mvn clean verify
export alias mvncp = mvn clean package
export alias mvnp = mvn package
export alias mvnt = mvn test
export alias mvni = mvn install
export alias mvnv = mvn verify
export alias mvndt = mvn dependency:tree
export alias mvndr = mvn dependency:resolve
export alias mvns = mvn site
export alias mvnsrc = mvn dependency:sources
export alias mvnfmt = mvn fmt:format
export alias mvncio = mvn clean install -o

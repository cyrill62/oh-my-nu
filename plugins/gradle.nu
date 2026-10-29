# description: Run the project's ./gradlew from any subdirectory, else gradle (Oh My Zsh's gradle)
# requires: gradle|gradlew

# Nearest gradlew up the directory tree, else gradle
export def --wrapped main [...args] {
    mut dir = pwd
    while $dir != "/" {
        let wrapper = $dir | path join gradlew
        if ($wrapper | path exists) {
            run-external $wrapper ...$args
            return
        }
        $dir = $dir | path dirname
    }
    ^gradle ...$args
}

########## PATHS ##########

if [ -x "/opt/homebrew/bin/brew" ]; then
    ## For Apple Silicon Macs
    export PATH="/opt/homebrew/bin:$PATH"
fi

if [ -x "/usr/libexec/java_home" ]; then
    export ES_JAVA_HOME=$(/usr/libexec/java_home)
    export JAVA_HOME=$(/usr/libexec/java_home)
fi


########## ALIASES AND FUNCTIONS ##########

##### Gradle #####

spotless() {
    args="";
    if [ $# -gt 0 ]; then
        for chart in $@
        do
            args=":${chart}:spotlessApply ${args}"
        done
    else
        args="spotlessApply"
    fi
    echo "running ./gradlew ${args}"
    ./gradlew ${args}
}


##### GIT #####
alias gstash="git stash"
alias gstat="git status"
alias gspop="git stash pop"
alias gpush="git push origin @"
alias gpforce="git push origin @ --force"
alias gprforce="git pull origin main --rebase && git push origin @ --force"
alias gpo="git pull --rebase origin"
alias glog="git log --oneline"
alias gref="git reflog"
alias gs="git switch"
alias gsc="git switch --create"
alias gcp="git cherry-pick"
gcpo() {
    git fetch origin $1 && git cherry-pick $1
}
alias grsoft="git reset --soft"
alias grhard="git reset --hard"


##### BREW #####
alias bsearch="brew search"
alias binfo="brew info"
alias bfinl="brew install"
alias bcinl="brew install --cask"

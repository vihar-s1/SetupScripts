##### Set PATHS #####

if [ -x "/opt/homebrew/bin/brew" ]; then
    ## For Apple Silicon Macs
    export PATH="/opt/homebrew/bin:$PATH"
fi

if [ -x "/usr/libexec/java_home" ]; then
    # export ES_JAVA_HOME=$(/usr/libexec/java_home)
    export JAVA_HOME=$(/usr/libexec/java_home)
fi


##### Common Purpose Alias #####

### git Alias ###
alias gstat="git status"
alias gstash="git stash"
alias gspop="git stash pop"
alias gsdrop="git stash drop"
alias gpush="git push origin @"
alias gpforce="git push origin @ --force"
alias gprforce="git pull origin main --rebase && git push origin @ --force"
alias gpo="git pull --rebase origin"
alias glog="git log --oneline"
alias gref="git reflog"
alias gs="git switch"
alias gsc="git switch --create"
alias gfo="git fetch origin"
alias gcp="git cherry-pick"
gcpo() {
    git fetch origin $1 && git cherry-pick $1
}
alias grsoft="git reset --soft"
alias grhard="git reset --hard"
alias gri="git rebase -i"
grih() {
    git rebase -i HEAD~$1
}
alias gb="git branch"
alias gbD="git branch -D"

### Brew Alias ###
alias bsearch="brew search"
alias binfo="brew info"
alias bfin="brew install"
alias bcin="brew install --cask"

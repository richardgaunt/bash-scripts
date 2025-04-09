
# Get git branch.
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$SCRIPT_DIR/git.sh"
# Update bash prompt.
set_bash_prompt() {
    git_branch="$(parse_git_branch)"
    # Get current time in HH:MM:SS format
    current_time="$(date +%H:%M:%S)"
    if [ -n "$git_branch" ]; then
        PS1='${debian_chroot:+($debian_chroot)}\[\033[38;5;240m\]<${current_time}>\[\033[00m\]\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\[\033[38;5;208m\][${git_branch}]\[\033[00m\]\$ '
    else
        PS1='${debian_chroot:+($debian_chroot)}\[\033[38;5;240m\]<${current_time}>\[\033[00m\]\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    fi
}


#!/bin/bash

# Add to your .bashrc or .bash_profile
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

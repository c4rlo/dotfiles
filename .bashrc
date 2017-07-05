#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Options
shopt -s autocd extglob checkwinsize
HISTCONTROL=ignoredups
MAILCHECK=

# Tab completion
complete -d -o bashdefault cd mkdir rmdir pushd popd
complete -A enabled builtin
complete -c type
complete -u su

# Prompt
function prompt_jobs {
    local status=$?  # we need to preserve this
    local running=$(jobs -pr | wc -l)
    local stopped=$(jobs -ps | wc -l)
    if [[ $running -eq 0 && $stopped -eq 0 ]]; then
        return $status
    fi
    printf ' \001\e[2m\002('
    if [[ $running -ne 0 ]]; then
        printf "${running}r"
        if [[ $stopped -ne 0 ]]; then
            printf ','
        fi
    fi
    if [[ $stopped -ne 0 ]]; then
        printf "${stopped}s"
    fi
    printf ')\001\e[0m\002'
    return $status
}
function prompt_exitstatus {
    local status=$?
    if [[ $status -ne 0 ]]; then
        printf " \001\e[31m\002${status}"
    fi
}
if [ "$PS1" ]; then
    . /usr/share/git/completion/git-prompt.sh
    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWSTASHSTATE=1
    PS1='\t \[\e[1m\]\w$(__git_ps1 " (%s)")\[\e[0m\]$(prompt_jobs)$(prompt_exitstatus) \[\e[0m\e[1m\]\$\[\e[0m\] '
    case $TERM in
    xterm*)
        PROMPT_COMMAND='echo -ne "\033]0;${PWD/#$HOME/~}\007"'
        ;;
    esac
fi

# Aliases
alias ls='ls --color=auto'
alias ll='ls -l --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias vim='vim --servername VIM'
alias v=vim
alias vd=vimdiff
alias vf='vim $(fzf)'
alias vp='vim -p'
alias gs='git status --short --branch'
alias gdt='git difftool'
alias gds='git diff --stat'
alias gc='git commit'
alias gb='git branch'
alias gco='git checkout'
alias tmux='tmux -2'

# Functions

function mkcd
{
    [[ -n "$1" ]] || return 1
    mkdir -p "$1" && cd "$1"
}

function vupd
{
    echo '* vim -E -c PlugUpgrade -c q >/dev/null'
    vim -E -c PlugUpgrade -c q >/dev/null
    echo '* vim -c PlugUpdate'
    vim -c PlugUpdate -c 'norm D'
}

function with
{
    local -i rc=0
    while true; do
        local prompt=
        if ((rc != 0)); then
            prompt=$'\e[31m'${rc}$'\e[0m '
        fi
        prompt="${prompt}"$'$ \e[1m'"$@"$'\e[0m '
        local args
        read -e -p "${prompt}" args || break
        eval "local -a a=(${args})"
        "$@" "${a[@]}"
        rc=$?
    done
    echo
}

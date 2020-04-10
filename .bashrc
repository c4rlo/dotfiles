#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Options
shopt -s autocd extglob checkwinsize
HISTCONTROL=ignoredups
MAILCHECK=
CDPATH=:~/src:~/play

# Tab completion
complete -d -o bashdefault cd mkdir rmdir pushd popd
complete -A enabled builtin
complete -c type
complete -u su
. /usr/share/bash-completion/completions/pacman
. /usr/share/bash-completion/completions/git
. /usr/share/bash-completion/completions/rg
. /usr/share/bash-completion/completions/systemctl
. /usr/share/bash-completion/completions/journalctl
. /usr/share/fzf/completion.bash
. ~/google-cloud-sdk/completion.bash.inc

# Key bindings
. /usr/share/fzf/key-bindings.bash

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
alias l='ls -A --color=auto'
alias ll='ls -l --color=auto'
alias la='ls -Al --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias v=vim
alias vd='vim -d'
alias vp='vim -p'
alias vo='vim -O'
alias gs='git status --short --branch'
alias gdt='git difftool'
alias gds='git diff --stat'
alias gc='git commit'
alias gb='git branch'
alias gco='git checkout'
alias lsblk='lsblk -o NAME,MOUNTPOINT,LABEL,PARTLABEL,TYPE,FSTYPE,SIZE,FSUSE%'

# Functions

function mkcd
{
    [[ -n "$1" ]] || return 1
    mkdir -p "$1" && cd "$1"
}

function clonecd
{
    local dir="${!###*[:/]}"
    git clone "$@" && cd "$dir"
}

function upd
{
    /usr/lib/systemd/systemd-networkd-wait-online &&
    sudo pacman -Sc --noconfirm &&
    sudo pacman -Syu --noconfirm &&
    rustup update &&
    cargo install-update -a
}

function vupd
{
    vim -E -c PlugUpgrade -c q >/dev/null
    vim -c PlugUpdate -c 'norm D'
}

function vpgs {
    local status
    status="$(git status -s --no-renames)" || return 1
    local -a files
    files=($(while IFS='\n' read line; do
                  echo "${line:3}"
              done <<<"$status"))
    vim -p "${files[@]}"
}

function pkgs
{
    pacman -Qq$@ |
        fzf --preview 'pacman -Qil {}' --layout=reverse \
            --bind 'enter:execute(pacman -Qil {} | less)'
}

function fixwifi
{
    echo "Stopping iwd" &&
    sudo systemctl stop iwd &&
    echo "Removing ath10k_pci kernel module" &&
    sudo modprobe -r ath10k_pci &&
    echo "Re-loading ath10k_pci kernel module" &&
    sudo modprobe ath10k_pci &&
    echo "Waiting a bit" &&
    sleep 3 &&
    echo "Starting iwd" &&
    sudo systemctl start iwd
}

function aoc
{
    local day=$1
    [[ -z "$day" ]] && day=$(date +%d)
    local base=~/play/adventofcode2019
    local dir=$base/$day
    if [[ ! -d $dir ]]; then
        mkdir $dir
        cp $base/solution_template.py $dir/solution.py
    fi
    cd $dir
}

source /home/carlo/.config/broot/launcher/bash/br

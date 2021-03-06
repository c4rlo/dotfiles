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
. /usr/share/fzf/completion.bash
. ~/google-cloud-sdk/completion.bash.inc
. ~/.invoke-completion.sh

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
    xterm*|alacritty)
        PROMPT_COMMAND='echo -ne "\033]0;${PWD/#$HOME/\~}\007"'
        ;;
    esac
    if [[ -n "$VIRTUAL_ENV" ]]; then
        . "$VIRTUAL_ENV"/bin/activate
    fi
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

function jctl
{
    # systemd default if 'SYSTEMD_LESS' not provided is 'FRSXMK'. We remove the
    # 'S' option to get back word wrap.
    SYSTEMD_LESS=FRXMK journalctl -o with-unit --no-hostname -e -n 20000 -b "$@"
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
    sudo systemctl start iwd &&
    echo "Waiting a bit" &&
    sleep 2 &&
    echo "Restarting systemd-networkd" &&
    sudo systemctl restart systemd-networkd
}

function priv
{
    case $1 in
        on)
            if systemctl is-active -q ~/private; then
                echo "Already active"
                return 1
            fi
            sudo systemctl start ~/private
            ;;
        off)
            if ! systemctl is-active -q ~/private; then
                echo "Already inactive"
                return 1
            fi
            sudo systemctl stop ~/private
            ;;
        *)
            echo "Usage: priv on|off"
            return 1
    esac
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

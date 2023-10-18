#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Options
shopt -s autocd extglob checkwinsize
HISTCONTROL=ignoredups
MAILCHECK=

# Tab completion; note that /etc/bash.bashrc already loads
# /usr/share/bash-completion/bash_completion, which sets up most of it.
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

# zoxide (modifies $PROMPT_COMMAND)
eval "$(zoxide init bash)"

# Aliases
alias ls='ls --color=auto'
alias l='ls -A --color=auto'
alias ll='ls -l --color=auto'
alias la='ls -Al --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias v=nvim
alias lsblk='lsblk -o NAME,MOUNTPOINT,LABEL,PARTLABEL,TYPE,FSTYPE,FSVER,SIZE,FSUSE%'
alias ip='ip -color=auto'

# The git completion gets loaded on-demand by
# /usr/share/bash-completion/bash_completion, but we have to explicitly load it
# now in order to load the '__git_complete' function.
. /usr/share/bash-completion/completions/git
alias gs='git status --short --branch'
__git_complete gs _git_status
alias gdt='git difftool'
__git_complete gdt _git_difftool
alias gds='git diff --stat'
__git_complete gds _git_diff
alias gc='git commit'
__git_complete gc _git_commit
alias gb='git branch'
__git_complete gb _git_branch
alias gco='git checkout'
__git_complete gco _git_checkout

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
    local -
    set -x
    /usr/lib/systemd/systemd-networkd-wait-online &&
    paru -Sc --noconfirm &&
    paru -Syu &&
    paru -c
    # /usr/lib/systemd/systemd-networkd-wait-online && archupd
}

function vupd
{
    vim -E -c PlugUpgrade -c q >/dev/null
    vim -c PlugUpdate -c 'norm D'
}

function nvupd
{
    nvim -c 'Lazy sync'
}

function vigs {
    local -a files
    while IFS=' ' read -d '' -r -a fields; do
        [[ "${fields[0]}" != '#' ]] && files+=("${fields[8]}")
    done < <(git status -uno --no-renames --porcelain=2 -z)
    nvim "$@" "${files[@]}"
}

function gd {
    nvim -c "DiffviewOpen $*"
}

function pkgs
{
    pacman -Qq$@ |
        fzf --preview 'pacman -Qil {}' --layout=reverse \
            --bind 'enter:execute(pacman -Qil {} | less)'
}

function confdiff {
    local file=$(realpath $1)
    local owner=$(pacman -Qqo $file)
    if [[ -z $owner ]]; then
        echo "$file is not owned by any package" >&2
    fi
    local pkgver=$(pacman -Q $owner | sed 's/ /-/')
    if [[ -z $file || -z $pkgver ]]; then
        echo "fail" >&2
        return 1
    fi
    local pkgfile=/var/cache/pacman/pkg/$pkgver-x86_64.pkg.tar.zst
    if [[ ! -f $pkgfile ]]; then
        pkgfile=/var/cache/pacman/pkg/$pkgver-any.pkg.tar.zst
    fi
    if [[ ! -f $pkgfile ]]; then
        echo "$pkgfile does not exist" >&2
        return 1
    fi
    nvim -d <(tar -xOf $pkgfile ${file#/}) $file
}

function jctl
{
    journalctl -o short-full --no-hostname -e -n 20000 -b "$@"
}

function fixwifi
{
    echo "Re-loading ath10k_pci kernel module" &&
    sudo /usr/local/bin/wifi_repair

    # echo "Stopping iwd" &&
    # sudo systemctl stop iwd &&
    # echo "Removing ath10k_pci kernel module" &&
    # sudo modprobe -r ath10k_pci &&
    # echo "Re-loading ath10k_pci kernel module" &&
    # sudo modprobe ath10k_pci &&
    # echo "Waiting a bit" &&
    # sleep 3 &&
    # echo "Starting iwd" &&
    # sudo systemctl start iwd &&
    # echo "Waiting a bit" &&
    # sleep 2 &&
    # echo "Restarting systemd-networkd" &&
    # sudo systemctl restart systemd-networkd
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

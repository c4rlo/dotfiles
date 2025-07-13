#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Options
shopt -s autocd extglob failglob globstar checkhash checkjobs histappend
HISTCONTROL=ignoredups
HISTSIZE=10000
HISTTIMEFORMAT='[%F %T %Z] '
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
PS0='\[\e[2 q\]'  # set cursor style to block; gets reset near end of PS1
. /usr/share/git/completion/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWSTASHSTATE=1
PS1='\t \[\e[1m\]\w$(__git_ps1 " (%s)")\[\e[0m\]$(prompt_jobs)$(prompt_exitstatus) \[\e[0m\e[1m\]\$\[\e[0m\e[ q\] '
case $TERM in
xterm*|alacritty|foot)
    PROMPT_COMMAND='echo -ne "\033]0;${PWD/#$HOME/\~}\007"'
    ;;
esac
if [[ -n "$VIRTUAL_ENV" ]]; then
    . "$VIRTUAL_ENV"/bin/activate
fi

# zoxide (modifies $PROMPT_COMMAND)
eval "$(zoxide init bash)"

# Aliases
alias ls='ls --color=auto'
alias l='ls -A --color=auto'
alias ll='ls -l --color=auto'
alias la='ls -Al --color=auto'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias v=nvim
alias lsblk='lsblk -o NAME,MOUNTPOINT,LABEL,PARTLABEL,TYPE,FSTYPE,FSVER,SIZE,FSUSE%'
alias ip='ip -color=auto'
alias ffmpeg='ffmpeg -hide_banner'
alias ffprobe='ffprobe -hide_banner'

declare -A git_aliases=(
    [gs]='status --short --branch'
    [gdt]='difftool'
    [gds]='diff --stat'
    [gc]='commit'
    [gb]='branch'
    [gco]='checkout'
)
for a in "${!git_aliases[@]}"; do alias $a="git ${git_aliases[$a]}"; done
function _comp_gitalias {
    declare -F __git_complete >/dev/null || . /usr/share/bash-completion/completions/git
    local -r gitcmd="${git_aliases[$1]%% *}"
    # We are relying on a git bash completion impl detail here; alternatively,
    # we could figure out the correct completion function using "complete -p $1".
    local -r compfunc="__git_wrap_git_$gitcmd" 
    # The below line sets up $compfunc as the completion function; hence next time
    # completion for $1 happens, that will get called directly, rather than this function.
    __git_complete "$1" "_git_$gitcmd"
    "$compfunc" "$@"
}
complete -o bashdefault -o default -o nospace -F _comp_gitalias "${!git_aliases[@]}"

alias gfm="git fetch origin main:main"

# Functions

function mkcd
{
    [[ -n "$1" ]] || return 1
    mkdir -p "$1" && cd "$1"
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

function clonecd
{
    local dir="${!###*[:/]}"
    git clone "$@" && cd "$dir"
}

function rgv
{
    rg --vimgrep "$@" | nvim -q -
}

# https://junegunn.github.io/fzf/tips/ripgrep-integration/
# https://github.com/junegunn/fzf/blob/master/ADVANCED.md#using-fzf-as-the-secondary-filter
function rfv
{
    if [[ $# -lt 1 ]]; then
        echo "usage: $FUNCNAME ARGS..." >&2
        return 2
    fi
    rg --color=always --line-number --no-heading --smart-case "$@" |
        fzf --ansi \
            --color "hl:-1:underline,hl+:-1:underline:reverse" \
            --delimiter : \
            --preview 'bat --style=numbers -f --italic-text=always {1} --highlight-line {2}' \
            --preview-window 'up,35%,border-bottom,+{2}+1/2' \
            --bind 'enter:become(nvim {1} +{2})' \
            --bind 'ctrl-o:execute(nvim {1} +{2})'
}

function pkgs
{
    pacman -Qq$@ |
        fzf --preview 'pacman -Qil {}' --layout=reverse \
            --bind 'enter:execute(pacman -Qil {} | less -+F)'
}

function upd
{
    local -
    set -x
    while ! ping -c1 -w1 archlinux.org >/dev/null; do sleep 0.1; done
    paru -Sc --noconfirm &&
    paru -Syu &&
    paru -c
}

function vupd
{
    vim -E -c PlugUpgrade -c q >/dev/null
    vim -c PlugUpdate -c 'norm D'
}

function nvupd
{
    nvim -c 'autocmd User VeryLazy ++once Lazy sync'
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

function _contains_match
{
    local -r pattern=$1
    shift
    for a in "$@"; do
        if [[ "$a" =~ $pattern ]]; then return 0; fi
    done
    return 1
}

function sctl
{
    if _contains_match '^(start|stop|reload|restart|reload-or-restart|kill|enable|disable|mask|unmask|edit|revert|daemon-reload)$' "$@" &&
      ! _contains_match '^--user$' "$@"
    then
        sudo systemctl "$@"
    else
        systemctl "$@"
    fi
}
function _comp_sctl {
    declare -F _systemctl >/dev/null || . /usr/share/bash-completion/completions/systemctl
    _systemctl "$@"
}
complete -F _comp_sctl sctl

function jctl
{
    journalctl -o short-full --no-hostname -e -n 20000 -b "$@"
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

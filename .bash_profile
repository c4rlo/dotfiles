#
# ~/.bash_profile
#

export EDITOR=vim
export PS_PERSONALITY=linux

export CMAKE_GENERATOR=Ninja
export CTEST_OUTPUT_ON_FAILURE=ON
export CTEST_PROGRESS_OUTPUT=ON

# Set up PATH
. ~/google-cloud-sdk/path.bash.inc
export PATH=$HOME/bin:$HOME/.local/bin/:$HOME/.cargo/bin:$HOME/go/bin:$PATH

[[ -f ~/.bashrc ]] && . ~/.bashrc

[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx

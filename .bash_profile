#
# ~/.bash_profile
#

export EDITOR=nvim
export PS_PERSONALITY=linux

export FZF_DEFAULT_COMMAND='fd --type f'

export CMAKE_GENERATOR=Ninja
export CTEST_OUTPUT_ON_FAILURE=ON
export CTEST_PROGRESS_OUTPUT=ON

# Set up PATH
. ~/google-cloud-sdk/path.bash.inc
export PATH=$HOME/bin:$HOME/.local/bin/:$HOME/.cargo/bin:$HOME/go/bin:$PATH

[[ -f ~/.bashrc ]] && . ~/.bashrc

if systemctl -q is-active graphical.target && [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]
then
    export \
        NO_AT_BRIDGE=1 \
        QT_QPA_PLATFORMTHEME=qt5ct \
        QT_QPA_PLATFORM=wayland \
        MOZ_ENABLE_WAYLAND=1
    exec systemd-cat sway
fi

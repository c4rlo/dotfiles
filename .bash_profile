#
# ~/.bash_profile
#

export EDITOR=nvim \
       LESS='FRMK--use-color' \
       SYSTEMD_LESS='FRMK--use-color' \
       PS_PERSONALITY=linux \
       FZF_DEFAULT_COMMAND='fd --type f' \
       CMAKE_GENERATOR=Ninja \
       CTEST_OUTPUT_ON_FAILURE=ON \
       CTEST_PROGRESS_OUTPUT=ON

# Set up PATH
. ~/google-cloud-sdk/path.bash.inc
export PATH=$HOME/bin:$HOME/.local/bin/:$HOME/.cargo/bin:$HOME/go/bin:$PATH

if [[ -z "$WAYLAND_DISPLAY" && $XDG_VTNR -eq 1 ]]
then
    export \
        NO_AT_BRIDGE=1 \
        GTK_A11Y=none \
        QT_QPA_PLATFORMTHEME=qt5ct \
        QT_QPA_PLATFORM=wayland
    exec systemd-cat sway
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc

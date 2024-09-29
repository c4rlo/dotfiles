#
# ~/.profile
#

export EDITOR=nvim \
       LESS='FRMK--use-color' \
       SYSTEMD_LESS='FRMK--use-color' \
       PS_PERSONALITY=linux \
       CMAKE_EXPORT_COMPILE_COMMANDS=ON \
       CMAKE_GENERATOR=Ninja \
       CMAKE_COLOR_DIAGNOSTICS=ON \
       CTEST_OUTPUT_ON_FAILURE=ON \
       CTEST_PROGRESS_OUTPUT=ON

export PATH=$HOME/bin:$HOME/.local/bin/:$HOME/.cargo/bin:$HOME/go/bin:$HOME/google-cloud-sdk/bin:$PATH

if uwsm check may-start; then
    # GUI-relevant env vars are set in ~/.config/uwsm/env
    exec systemd-cat -t uwsm_start uwsm start -S sway
fi

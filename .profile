#
# ~/.profile
#

export EDITOR=nvim \
       LESS='FRMK--use-color' \
       SYSTEMD_LESS='FRMK--use-color' \
       PS_PERSONALITY=linux \
       FZF_DEFAULT_COMMAND='fd --type f' \
       CMAKE_EXPORT_COMPILE_COMMANDS=ON \
       CMAKE_GENERATOR=Ninja \
       CMAKE_COLOR_DIAGNOSTICS=ON \
       CTEST_OUTPUT_ON_FAILURE=ON \
       CTEST_PROGRESS_OUTPUT=ON

export PATH=$HOME/bin:$HOME/.local/bin/:$HOME/.cargo/bin:$HOME/go/bin:$HOME/google-cloud-sdk/bin:$PATH

# https://github.com/Vladimir-csp/uwsm/issues/28
i=0
while ! systemctl is-active -q graphical.target; do
    sleep 0.2
    i=$((i+1))
    if [ $i -gt 50 ]; then
        echo "graphical.target did not start!"
        break
    fi
done

if uwsm check may-start; then
    # GUI-relevant env vars are set in ~/.config/uwsm-env
    exec uwsm start -S sway
fi

#
# ~/.profile
#

# Avoid setting env vars twice, can happen due to uwsm startup sequence
if [ -z "$INPUTRC" ]; then
    export PATH=$HOME/src/local/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/go/bin:$HOME/opt/google-cloud-sdk/bin:$PATH \
           EDITOR=nvim \
           INPUTRC=~/.config/readline/inputrc \
           LESS='FRMKx4--use-color' \
           SYSTEMD_LESS='FRMK--use-color' \
           PS_PERSONALITY=linux \
           PYTHON_HISTORY=~/.local/state/python_history \
           SQLITE_HISTORY=~/.local/state/sqlite_history \
           GNUPGHOME=~/.local/share/gnupg \
           CMAKE_EXPORT_COMPILE_COMMANDS=ON \
           CMAKE_GENERATOR=Ninja \
           CMAKE_COLOR_DIAGNOSTICS=ON \
           CTEST_OUTPUT_ON_FAILURE=ON \
           CTEST_PROGRESS_OUTPUT=ON \
           CLAUDE_CONFIG_DIR=~/.config/claude \
           CODEX_HOME=~/.config/codex \
           OCI_CONFIG_FILE=~/.config/oci
fi


if [ -z "$WAYLAND_DISPLAY" ] && [ "${XDG_VTNR:-}" = 1 ] && uwsm check may-start; then
    # GUI-relevant env vars are set in ~/.config/uwsm/env
    exec uwsm start sway
fi

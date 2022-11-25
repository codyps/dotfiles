: ${XDG_CONFIG_HOME:=$HOME/.config}

# note: typically will be something like `/run/user/1000` and is set by session
# manager (unlike other XDG variables).  unclear what is the most reasonable
# fallback for this var when it is not setup.
: ${XDG_RUNTIME_DIR:=/run}

# ccache:
#  Not currently included, using `/etc/ccache.conf` edit is cleaner

# pass: otherwise it uses `~/.password-store`
export PASSWORD_STORE_DIR="${XDG_CONFIG_HOME}/password-store"

# tmux: config file can only be passed via `-f`, needs a wrapper to really work reliably.
alias tmux='tmux -f "${XDG_CONFIG_HOME}/tmux/tmux.conf"'
# tmux: otherwise uses `/tmp` for tempfiles.
export TMUX_TMPDIR="${XDG_RUNTIME_DIR}/tmux"

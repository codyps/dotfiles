: ${XDG_CONFIG_HOME:=$HOME/.config}

# ccache:
#  Not currently included, using `/etc/ccache.conf` edit is cleaner

# pass: otherwise it uses `~/.password-store`
export PASSWORD_STORE_DIR=${XDG_CONFIG_HOME}/password-store

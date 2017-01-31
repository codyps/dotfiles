#! /bin/bash

mkdir -p $HOME/.cache
exec >>$HOME/.cache/xsession-errors-$DISPLAY 2>&1
echo "====== $(date) ====== "

[ -f ~/dotfiles/_.xprofile ] && . ~/dotfiles/_.xprofile

echo "LAUNCH"
exec i3

#exec ck-launch-session --sh-syntax --exit-with-session i3

#if which dbus-launch >/dev/null; then
#	exec dbus-launch i3
#else
#	exec i3
#fi

#! /bin/bash

mkdir -p $HOME/.cache
exec >>$HOME/.cache/xsession-errors-$DISPLAY
echo "====== $(date) ====== "
#exec ck-launch-session --sh-syntax --exit-with-session i3

[ -f ~/dotfiles/_.xprofile ] && . ~/dotfiles/_.xprofile
echo "LAUNCH"
#exec ck-launch-session --sh-syntax --exit-with-session i3
exec dbus-launch i3

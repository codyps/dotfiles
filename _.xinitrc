#! /bin/sh

[ -f ~/dotfiles/_.xprofile ] && . ~/dotfiles/_.xprofile
echo "LAUNCH"
#exec ck-launch-session --sh-syntax --exit-with-session i3
exec dbus-launch i3

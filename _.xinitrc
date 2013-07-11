#! /bin/sh
[ -f ~/dotfiles/_.xprofile ] && . ~/dotfiles/_.xprofile
exec dbus-launch i3

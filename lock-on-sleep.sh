#!/bin/sh

# for pm-utils, install in
# /etc/pm/sleep.d/
# for systemd, install in
# /usr/lib/systemd/system-sleep/

# FIXME: allow a different lock per user.

lock_screen()
{
    ## based on "/usr/bin/xflock4"
    if ps auxc | grep x[s]creensaver > /dev/null 2>&1; then
        XLOCK="xscreensaver-command -lock"
    elif ps auxc | grep gnome-[s]creensaver > /dev/null 2>&1; then
        XLOCK="gnome-screensaver-command --lock"
    elif ps auxc | grep startkde > /dev/null 2>&1; then
        XLOCK="dbus-send --session --dest=org.kde.krunner \
                  --type='method_call' --print-reply \
                  /ScreenSaver org.freedesktop.ScreenSaver.Lock"
    elif ps auxc | grep xautolock > /dev/null 2>&1; then
        XLOCK="xautolock -enable; xautolock -locknow"
    elif [ -x /usr/bin/i3lock ]; then
        XLOCK="i3lock"
    else
        XLOCK="xlock -mode blank $*"
    fi

    ## based on "/etc/acpi/sleep.sh" and "/usr/share/acpi-support/power-funcs"
    for x in /tmp/.X11-unix/*; do
        displaynum=`echo $x | sed s#/tmp/.X11-unix/X##`
        user=`who | grep -m1 "(:$displaynum)" | awk '{print $1}'`
        if [ x"$user" = x"" ]; then
            user=`who | grep -m1 ":$displaynum" | awk '{print $1}'`
        fi
        if [ x"$user" != x"" ]; then
            export DISPLAY=":$displaynum"
            su -c "$XLOCK" "$user"
            return 0
        fi
    done
}

case "$1" in
    # pm-utils|pm-utils|systemd
    suspend|hibernate|pre*)
        lock_screen
        ;;
esac

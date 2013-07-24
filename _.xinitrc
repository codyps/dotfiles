#! /bin/bash
mkdir -p $HOME/.cache
exec >>$HOME/.cache/xsession-errors-$DISPLAY
echo "====== $(date) ====== "
if [ -f ~/.xprofile ]; then
	. ~/.xprofile
fi
exec ck-launch-session --sh-syntax --exit-with-session i3

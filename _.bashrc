# vi: ft=sh

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

my_UID=`id -u`
my_GID=`id -g`

PS1='\[\033[01;34m\]\w\[\033[00m\] \$ '

shopt -s histappend histreedit histverify
shopt -s globstar checkwinsize

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000000
unset HISTFILESIZE

PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

. ~/dotfiles/_.zsh/rc/paths.rc
. ~/dotfiles/_.zsh/rc/alias.rc

font_change_deja () {
	local font
	[[ $# -eq 1 ]] && font=$1 || font=12.98
	font_change "xft:DejaVu Sans Mono-$font"
}
font_change_pro () {
	local font
	[[ $# -eq 1 ]] && font=$1 || font=11
	font_change "xft:profont:pixelsize=$font"
}
font_change_anon () {
	local font
	[[ $# -eq 1 ]] && font=$1 || font=11
	font_change "xft:Anonymous Pro-$font"
}
font_change () {
	printf '\33]50;%s\007' "$1"
}
fc_xft_px_sz () {
	font_change `printf "xft:%s:pixelsize=%s"`
}

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
if [ -x /usr/bin/lesspipe ]; then
	export LESSOPEN="|lesspipe %s"
fi

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
#HISTCONTROL=ignoredups:ignorespace

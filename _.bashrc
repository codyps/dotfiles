
# If not running interactively, don't do anything
[ -z "$PS1" ] && return

PS1='\[\033[01;34m\]\w\[\033[00m\] \$ '

shopt -s histappend globstar checkwinsize

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=2000000

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

function font_change_deja () {
	local font
	[[ $# -eq 1 ]] && font=$1 || font=12.98

	font_change "xft:DejaVu Sans Mono-$font"
}

function font_change () {
	printf '\33]50;%s\007' "$1"
}

function fc_xft_px_sz () {
	font_change `printf "xft:%s:pixelsize=%s"`
}

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"
if [ -x /usr/bin/lesspipe ]; then
	export LESSOPEN="|lesspipe %s"
fi

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
HISTCONTROL=ignoredups:ignorespace

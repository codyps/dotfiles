# vi: ft=sh

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

my_UID=`id -u`
my_GID=`id -g`

PS1='\[\033[01;34m\]\w\[\033[00m\] \$ '

shopt -s histappend histreedit histverify
shopt -s globstar checkwinsize

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
# History is a signed 32 bit value in bash. This is the max.
HISTSIZE=$(printf "%d" 0x7fffffff)
HISTFILESIZE=$HISTSIZE

PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

. ~/dotfiles/_.zsh/rc/paths.rc
. ~/dotfiles/_.shell

# don't put duplicate lines in the history. See bash(1) for more options
# ... or force ignoredups and ignorespace
#HISTCONTROL=ignoredups:ignorespace

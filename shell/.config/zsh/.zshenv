# Skip the not really helping Ubuntu global compinit
skip_global_compinit=1
export WORDCHARS='*/?_-.[]~&;!#$%^(){}<>~` '
export KEYTIMEOUT=10
export REPORTTIME=60
export ESCDELAY=1
[[ $(readlink -e ~/tmp) == "" ]] && rm -f ~/tmp
[[ ! -L ${HOME}/tmp ]] && { rm -f ~/tmp && tmp_loc=$(mktemp -d) && ln -fs "${tmp_loc}" ${HOME}/tmp }
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]] && [[ $USER = "neg" ]]; then startx; fi

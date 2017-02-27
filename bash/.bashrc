# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# Bash keyboard shortcuts
# CTRL+E   (Go to end of line)
# CTRL+A   (Go to beginning of line)
# ALT+F    (Jump forward no next whitespace)
# ALT+B    (Jump back to previous whitespace)
# ALT+Backspace  (Delete word behind cursor)
# ALT+D    (Delete word in front of cursor)
# CTRL+W   (cut word behind cursor, placing in buffer, you can chain multiple words)
# CTRL+U   (cut entire line into buffer)
# CTRL+Y   ("yank" out whatever is in the buffer. aka paste)

# change timezone to PDT/PST
export TZ="/usr/share/zoneinfo/America/Los_Angeles"

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Alias'
alias nano='nano -c -m'                                                          # colorized nano
alias ping='ping -c 5'                                                              # Ping address 5 times
alias peekaboo='sudo netstat -plunt'                                                # Show current network connections
alias cmon='sudo $(history -p !!)'                                                  # Redo last command as root
alias ls='ls --color=auto'                                                          # Colorize ls
alias grep='grep --color=auto'                                                      # Colorize grep
alias histg="history | grep"                                                        # Search through comman history: histg [keyword]
alias ..='cd ..'                                                                    # Go up a directory
alias ...='cd ../..'                                                                # Go up two directories
alias busy='cat /dev/urandom | hexdump -C | grep "ca fe"'                           # Create hexdump of /dev/urandom to look busy
alias nyan='telnet -e ^c nyancat.dakko.us'                                          # Nyan Cat
alias nethack='telnet nethack.alt.org'                                              # Telnet game
alias update='sudo apt-get update && sudo apt-get upgrade'                          # Update system
alias get='sudo apt-get install'                                                    # Get a package
alias remove='sudo apt-get --purge remove'                                          # Remove a package
alias t='(tmux has-session 2>/dev/null && tmux attach) || (tmux new-session)'       # open previous tmux session or new one if none others exist
alias prettyjson='python -m json.tool'						    # pretty print json

# Functions
mcd() { mkdir -p "$1" && cd "$1";}                                                  # Make a directory and cd into it
cls() { cd "$1" && ls;}                                                             # cd into a directory and ls it
backup() { cp -- "$1"{,.bak};}                                                      # Backup a file to file.bak
md5check() { md5sum "$1" | grep "$2";}                                              # Compare md5sum of file to key
killmeteor() { kill `ps ax | grep [m]eteor | awk '{print $1}'`; }                   # kill all running instances of meteor
checkport() { lsof -i:$1; }                                                         # check for any programs using a given port   


# Extract an archive file: extract [file]
extract() { 
    if [ -f $1 ] ; then 
      case $1 in 
        *.tar.bz2)   tar xvjf $1    ;; 
        *.tar.gz)    tar xvzf $1    ;; 
        *.bz2)       bunzip2 $1     ;; 
        *.rar)       unrar e $1     ;; 
        *.gz)        gunzip $1      ;; 
        *.tar)       tar xvf $1     ;; 
        *.tbz2)      tar xvjf $1    ;; 
        *.tgz)       tar xvzf $1    ;; 
        *.zip)       unzip $1       ;; 
        *.Z)         uncompress $1  ;; 
        *.7z)        7z x $1        ;; 
        *)     echo "'$1' cannot be extracted via extract()" ;; 
         esac 
     else 
         echo "'$1' is not a valid file" 
     fi 
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

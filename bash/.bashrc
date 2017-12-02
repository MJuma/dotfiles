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

# Alias'
alias nano='nano -c -m'                                                             # colorized nano
alias ping='ping -c 5'                                                              # Ping address 5 times
alias cmon='sudo $(history -p !!)'                                                  # Redo last command as root
alias grep='grep --color=auto'                                                      # Colorize grep
alias histg="history | grep"                                                        # Search through comman history: histg [keyword]
alias ..='cd ..'                                                                    # Go up a directory
alias ...='cd ../..'                                                                # Go up two directories
alias busy='cat /dev/urandom | hexdump -C | grep "ca fe"'                           # Create hexdump of /dev/urandom to look busy
alias nyan='telnet -e ^c nyancat.dakko.us'                                          # Nyan Cat
alias nethack='telnet nethack.alt.org'                                              # Telnet game
alias t='(tmux has-session 2>/dev/null && tmux attach) || (tmux new-session)'       # open previous tmux session or new one if none others exist
alias prettyjson='python -m json.tool'						                                  # pretty print json
alias npmg='npm list -g --depth=0'						                                      # list all globally install npm packages
alias ascii="man ascii"                                                             # man page listing the ascii codes

# Functions
mcd() { mkdir -p "$1" && cd "$1";}                                                  # Make a directory and cd into it
cls() { cd "$1" && ls;}                                                             # cd into a directory and ls it
backup() { cp -- "$1"{,.bak};}                                                      # Backup a file to file.bak
md5check() { md5sum "$1" | grep "$2";}                                              # Compare md5sum of file to key
killmeteor() { kill `ps ax | grep [m]eteor | awk '{print $1}'`; }                   # kill all running instances of meteor
checkport() { lsof -i:$1; }                                                         # check for any programs using a given port   
wttr() { curl -s "wttr.in/$1"; }                                                    # returns the weather in the given location   

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

parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$(parse_git_branch)\[\033[00m\] \$ "
else
    PS1="${debian_chroot:+($debian_chroot)}\u@\h:\w\$(parse_git_branch)\[\033[00m\] \$ "
fi

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

case "$OSTYPE" in
  solaris*) 
    ;;
  darwin*)
    eval $(thefuck --alias)
    [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

    cdf() {
        target=`osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)'`
        if [ "$target" != "" ]; then
            cd "$target"; pwd
        else
            echo 'No Finder window found' >&2
        fi
    }

    alias ls='ls -G'                                              # Colorize ls
    alias update='brew update && brew upgrade'                          # Update system
    ;; 
  linux*)
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

    alias peekaboo='sudo netstat -plunt'                                                # Show current network connections
    alias ls='ls --color=auto'                                                          # Colorize ls
    alias update='sudo apt-get update && sudo apt-get upgrade'                          # Update system
    alias get='sudo apt-get install'                                                    # Get a package
    alias remove='sudo apt-get --purge remove'                                          # Remove a package
    alias xres="xrdb -merge ~/.Xresources"
    ;;
  bsd*)     
    ;;
  msys* | cygwin*)    
    ;;
  *)        
    echo "unknown: $OSTYPE" ;;
esac

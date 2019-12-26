# ~/.bashrc: executed by bash(1) for non-login shells.

# Bash keyboard shortcuts
# CTRL+A                (Go to beginning of line)
# CTRL+E                (Go to end of line)
# ALT+F                 (Jump forward no next whitespace)
# ALT+B                 (Jump back to previous whitespace)
# ALT+Backspace         (Delete word behind cursor)
# ALT+D                 (Delete word in front of cursor)
# CTRL+W                (cut word behind cursor, placing in buffer, you can chain multiple words)
# CTRL+U                (cut entire line into buffer)
# CTRL+Y                ("yank" out whatever is in the buffer. aka paste)

# If not running interactively, don't do anything
# [[ $- != *i* ]] && return
case $- in
    *i*) ;;
      *) return;;
esac

######
## Environment Variables
######
export TZ="/usr/share/zoneinfo/America/Los_Angeles"         # Set timezone to PDT/PST

######
## Shell Behavior
######
shopt -s histappend                                         # Append to the history file, don't overwrite it
shopt -s checkwinsize                                       # Check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s expand_aliases                                     # Aliases are expanded

# Enable bash completion
if ! shopt -oq posix; then
    if [ -r /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -r /etc/bash_completion ]; then
        . /etc/bash_completion
    elif [ -f /usr/local/etc/bash_completion ]; then
        . /usr/local/etc/bash_completion
    elif [ -f $(brew --prefix)/etc/bash_completion ]; then
        . $(brew --prefix)/etc/bash_completion
    fi
fi
complete -cf sudo

######
## Shell History
######
HISTCONTROL=ignoreboth                                      # Don't put duplicate lines or lines starting with space in the history.
HISTSIZE=10000                                              # Number of lines stored in memory for a running bash session
HISTFILESIZE=20000                                          # Number of lines stored in bash history file

######
## Shell Config
######
# Set window title of X terminals
case ${TERM} in 
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		;;
	screen*)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		;;
    *)        
        PROMPT_COMMAND='history -a'
        ;;
esac

######
## Shell Prompt
######
parse_git_branch() {
    git_branch=$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')

    if [ $git_branch ]; then
        git_status=$(git status --porcelain 2>/dev/null)
        git_tracked_changes_count=$(for i in "$git_status"; do echo "$i"; done | grep -v '^?? ' | sed '/^$/d' | wc -l | sed "s/ //g")
        git_untracked_changes_count=$(for i in "$git_status"; do echo "$i"; done | grep '^?? ' | sed '/^$/d' | wc -l | sed "s/ //g")

        echo -e " (${git_branch}:${git_tracked_changes_count}:${git_untracked_changes_count})"
    fi
}

if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
    match_lhs=""
    [[ -f ~/.dir_colors ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
    [[ -z ${match_lhs}  ]] && type -P dircolors >/dev/null && match_lhs=$(dircolors --print-database)
    [[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]]

    if type -P dircolors >/dev/null && [[ -f ~/.dir_colors ]]; then
        eval $(dircolors -b ~/.dir_colors)
    fi

    if [[ ${EUID} == 0 ]] ; then
        PS1='\[\033[01;32m\]\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(parse_git_branch)\[\033[00m\] \$ '
	else
        PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]$(parse_git_branch)\[\033[00m\] \$ '
	fi
else
    if [[ ${EUID} == 0 ]]; then
        PS1='\u@\h: \W$(parse_git_branch)\[\033[00m\] \$ '
    else
        PS1='\u@\h: \w$(parse_git_branch)\[\033[00m\] \$ '
    fi
fi

# Add Debian Chroot to Prompt if available
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
    PS1="${debian_chroot:+($debian_chroot)}$PS1"
fi

######
## Aliases
######
alias sudo="sudo -E"                                                                                    # Preserve environment variables when calling sudo
alias cp="cp -i"                                                                                        # Confirm before overwriting files and directories
alias df='df -h'                                                                                        # Human readable disk space usage
alias free='free -m'                                                                                    # Free memory and swap in Mebibytes
alias atop='watch -n 3 "free; echo; uptime; echo; ps aux  --sort=-%cpu | head -n 11; echo; who"'        # Show free memory, uptime & ps updated every 3s
alias nano='nano -c -m'                                                                                 # nano with cursor position shown and mouse support enabled
alias ping='ping -c 5'                                                                                  # Ping address 5 times
alias grep='grep --colour=auto'                                                                         # Colorize grep
alias egrep='egrep --colour=auto'                                                                       # Colorize egrep
alias fgrep='fgrep --colour=auto'                                                                       # Colorize fgrep
alias ..='cd ..'                                                                                        # Go up a directory
alias ...='cd ../..'                                                                                    # Go up two directories
alias cmon='sudo $(history -p !!)'                                                                      # Redo last command as root
alias histg="history | grep"                                                                            # Search through comman history: histg [keyword]
alias t='(tmux has-session 2>/dev/null && tmux attach) || (tmux new-session)'                           # Open previous tmux session or new one if none others exist
alias busy='cat /dev/urandom | hexdump -C | grep "ca fe"'                                               # Create hexdump of /dev/urandom to look busy
alias prettyjson='python -m json.tool'						                                            # Pretty print json
alias npmg='npm list -g --depth=0'						                                                # List all globally install npm packages
alias ascii="man ascii"                                                                                 # man page listing the ascii codes
alias nethack='telnet nethack.alt.org'                                                                  # Telnet game

######
## Functions
######
mcd() { mkdir -p "$1" && cd "$1";}                                                                      # Make a directory and cd into it
cls() { cd "$1" && ls;}                                                                                 # cd into a directory and ls it
backup() { cp -- "$1"{,.bak};}                                                                          # Backup a file to file.bak
md5check() { md5sum "$1" | grep "$2";}                                                                  # Compare md5sum of file to key
checkport() { lsof -i:$1; }                                                                             # Check for any programs using a given port   
randfile() { find $1 -type f | shuf -n 1; }                                                             # Returns a random file within a given dir recursively
wttr() { curl -s "wttr.in/$1"; }                                                                        # Returns the weather in the given location   

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

######
## Path
######
if [ -d "$HOME/.nvm" ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                                            # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"                          # This loads nvm bash_completion
fi

if [ -d "$HOME/.yarn/bin" ]; then
    export PATH=$PATH:$HOME/.yarn/bin
fi

######
## OS && Distribution Specific
######
case "$OSTYPE" in
    linux*)
        alias peekaboo='sudo netstat -plunt'                                                    # Show network connections with options PID, listening sockets, udp, numeric address, tcp
        alias ls='ls --color=auto'                                                              # Colorize ls
        alias xres="xrdb -merge ~/.Xresources"                                                  # Reload ~/.Xresources
        alias rebuild-fonts="fc-cache -f -v"                                                    # Rebuilds font cache

        case "$(lsb_release -is | awk '{print tolower($0)}')" in
            arch* | manjaro*)
                alias get='yay -S'                                                              # Get a package
                alias remove='yay -Ru'                                                          # Remove a package
                alias update='yay -Syyu'                                                        # Update package list and upgrade packages
                alias clean='yay -Sc'                                                           # Removes unused packages
                alias search='yay -Ss'                                                          # Search package list for a package
                alias info='yay -Si'                                                            # Search package list for a package
                alias pkstats='yay -P --stats'                                                  # Shows statistics for installed packages and system health
                ;;
            debian* | ubuntu* | elementary*)
                alias get='sudo apt install'                                                    # Get a package
                alias remove='sudo apt purge'                                                   # Remove a package
                alias update='sudo apt update && sudo apt-get upgrade'                          # Update repository index and upgrade packages
                alias upgrade='sudo apt full-upgrade'                                           # Upgrade packages with auto-handling of dependencies
                alias clean='sudo apt autoremove'                                               # Removes unused packages
                alias search='apt-cache search'                                                 # Search repository for a package
                alias policy='apt-cache policy'                                                 # Show priority selection for a package
                ;;
            *)
                echo "Unknown Lunux Distribution: $(lsb_release -is)"
                ;;
        esac
        ;;
    darwin*)
        eval $(thefuck --alias)
        
        alias ls='ls -G'                                                                        # Colorize ls
        alias peekaboo='sudo netstat -p tcp -van | grep LISTEN'                                 # Show network connections with options PID, listening sockets, udp, numeric address, tcp
        alias update='brew update && brew upgrade'                                              # Update homebrew formulae and upgrade packages

        cdf() {
            target=`osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)'`
            if [ "$target" != "" ]; then
                cd "$target"; pwd
            else
                echo 'No Finder window found' >&2
            fi
        }
        ;; 
    solaris*) 
        ;;
    bsd*)     
        ;;
    msys* | cygwin*)    
        ;;
    *)        
        echo "Unknown OS Type: $OSTYPE"
        ;;
esac

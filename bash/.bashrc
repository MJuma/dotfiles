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
## Shell Behavior
######
shopt -s histappend                                         # Append to the history file, don't overwrite it
shopt -s checkwinsize                                       # Check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s expand_aliases                                     # Aliases are expanded

if [[ $CODESPACES ]]; then
    HISTFILEBASE=/workspaces/.codespaces/.persistedshare
else
    HISTFILEBASE=$HOME
fi

if [[ $TMUX_PANE ]]; then
    HISTFILE=$HISTFILEBASE/.bash_history_tmux_${TMUX_PANE:1}        # Set a differetn history file for each tmux pane
else
    HISTFILE=$HISTFILEBASE/.bash_history
fi

######
## Bash Completion
######
if ! shopt -oq posix; then
    [ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
    [ -r /etc/bash_completion ] && . /etc/bash_completion
    [ -r /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
    [ type brew &> /dev/null ] && [ -f $(brew --prefix)/etc/bash_completion ] && . $(brew --prefix)/etc/bash_completion

    if [ -d /etc/bash_completion.d ]; then
        for bcfile in /etc/bash_completion.d/* ; do
            [ -f "$bcfile" ] && . $bcfile
        done
    fi

    if [ -d ~/.bash_completion.d ]; then
        for bcfile in ~/.bash_completion.d/* ; do
            [ -f "$bcfile" ] && . $bcfile
        done
    fi

    if [ ! -r "$HOME/.config/.git-completion.bash" ] && [ type curl &> /dev/null ]; then
        curl -fLo "$HOME/.config/.git-completion.bash" --create-dirs https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
    fi
    [ -r "$HOME/.config/.git-completion.bash" ] && . "$HOME/.config/.git-completion.bash"
fi
complete -cf sudo


######
## Shell Config (window title of X terminals)
######
case ${TERM} in 
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
		PROMPT_COMMAND='history -a;history -n;echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		;;
	screen*)
		PROMPT_COMMAND='history -a;history -n;echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		;;
    *)        
        PROMPT_COMMAND='history -a;history -n'
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
source "$HOME/.config/bash/aliases.sh"

######
## Functions
######
source "$HOME/.config/bash/functions.sh"

######
## Variables
######
source "$HOME/.config/bash/variables.sh"

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
                alias remove='yay -Rsu'                                                         # Remove a package
                alias update='yay -Syyu'                                                        # Update package list and upgrade packages
                alias clean='yay -Sc && yay -Qtdq | yay -Rns -'                                 # Removes unused packages and removes unused orphaned packages
                alias search='yay -Ss'                                                          # Search package list for a package
                alias info='yay -Si'                                                            # Search package list for a package
                alias pkstats='yay -P --stats'                                                  # Shows statistics for installed packages and system health

                [ -r /usr/share/fzf/completion.bash ] && . /usr/share/fzf/completion.bash       # fzf bash completion
                [ -r /usr/share/fzf/key-bindings.bash ] && . /usr/share/fzf/key-bindings.bash   # fzf key bindings
                ;;
            debian* | ubuntu* )
                alias get='sudo apt install'                                                    # Get a package
                alias remove='sudo apt purge'                                                   # Remove a package
                alias update='sudo apt update && sudo apt-get upgrade'                          # Update repository index and upgrade packages
                alias upgrade='sudo apt full-upgrade'                                           # Upgrade packages with auto-handling of dependencies
                alias clean='sudo apt autoremove'                                               # Removes unused packages
                alias search='apt-cache search'                                                 # Search repository for a package
                alias policy='apt-cache policy'                                                 # Show priority selection for a package
                alias fd=fdfind                                                                 # Map fd to fd from fdfind in debian
                alias bat=batcat                                                                # Map bat to bat from batcat in debian
                alias cat=batcat                                                                # Map cat to bat

                [ -r /usr/share/doc/fzf/examples/completion.bash ] && . /usr/share/doc/fzf/examples/completion.bash         # fzf bash completion
                [ -r /usr/share/doc/fzf/examples/key-bindings.bash ] && . /usr/share/doc/fzf/examples/key-bindings.bash     # fzf key bindings
                ;;
            *)
                echo "Unknown Lunux Distribution: $(lsb_release -is)"
                ;;
        esac
        ;;
    darwin*)
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

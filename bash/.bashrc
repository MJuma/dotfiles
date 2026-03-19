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
    HISTFILE=/workspaces/.codespaces/.persistedshare/.bash_history
else
    mkdir -p "$HOME/.local/state/bash"
    HISTFILE="$HOME/.local/state/bash/history"
fi

######
## Bash Completion
######
if ! shopt -oq posix; then
    [ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion
    [ -r /etc/bash_completion ] && . /etc/bash_completion
    [ -r /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
    type brew &>/dev/null && [ -f "$(brew --prefix)/etc/bash_completion" ] && . "$(brew --prefix)/etc/bash_completion"

    if [ -d /etc/bash_completion.d ]; then
        for bcfile in /etc/bash_completion.d/* ; do
            [ -f "$bcfile" ] && . "$bcfile"
        done
    fi

    if [ -d ~/.bash_completion.d ]; then
        for bcfile in ~/.bash_completion.d/* ; do
            [ -f "$bcfile" ] && . "$bcfile"
        done
    fi

    if [ ! -r "$HOME/.config/.git-completion.bash" ] && type curl &>/dev/null; then
        (curl -fLo "$HOME/.config/.git-completion.bash" --create-dirs \
            https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash &)
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
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return

    local tracked=0 untracked=0
    while IFS= read -r line; do
        if [[ "$line" == '?? '* ]]; then
            ((untracked++))
        elif [[ -n "$line" ]]; then
            ((tracked++))
        fi
    done < <(git status --porcelain 2>/dev/null)

    echo -e " (${branch}:${tracked}:${untracked})"
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
[ -f "$HOME/.config/bash/aliases.sh" ] && source "$HOME/.config/bash/aliases.sh"

######
## Functions
######
[ -f "$HOME/.config/bash/functions.sh" ] && source "$HOME/.config/bash/functions.sh"

######
## Variables
######
[ -f "$HOME/.config/bash/variables.sh" ] && source "$HOME/.config/bash/variables.sh"

######
## OS && Distribution Specific
######
case "$OSTYPE" in
    linux*)
        distro_id=
        if [ -r /etc/os-release ]; then
            distro_id=$(. /etc/os-release && echo "$ID")
        fi
        case "$distro_id" in
            arch | manjaro)
                [ -r /usr/share/fzf/completion.bash ] && . /usr/share/fzf/completion.bash       # fzf bash completion
                [ -r /usr/share/fzf/key-bindings.bash ] && . /usr/share/fzf/key-bindings.bash   # fzf key bindings
                ;;
            debian | ubuntu)
                [ -r /usr/share/doc/fzf/examples/completion.bash ] && . /usr/share/doc/fzf/examples/completion.bash         # fzf bash completion
                [ -r /usr/share/doc/fzf/examples/key-bindings.bash ] && . /usr/share/doc/fzf/examples/key-bindings.bash     # fzf key bindings
                ;;
            fedora)
                [ -r /usr/share/fzf/shell/key-bindings.bash ] && . /usr/share/fzf/shell/key-bindings.bash   # fzf key bindings
                ;;
            mariner | azurelinux)
                type fzf &>/dev/null && eval "$(fzf --bash)"                                    # fzf shell integration
                ;;
            *)
                echo "Unknown Linux Distribution: ${distro_id:-unknown}"
                ;;
        esac
        unset distro_id
        ;;
    darwin*)
        [ -r /opt/homebrew/opt/fzf/shell/completion.bash ] && . /opt/homebrew/opt/fzf/shell/completion.bash             # fzf bash completion (Apple Silicon)
        [ -r /opt/homebrew/opt/fzf/shell/key-bindings.bash ] && . /opt/homebrew/opt/fzf/shell/key-bindings.bash         # fzf key bindings (Apple Silicon)
        [ -r /usr/local/opt/fzf/shell/completion.bash ] && . /usr/local/opt/fzf/shell/completion.bash                   # fzf bash completion (Intel)
        [ -r /usr/local/opt/fzf/shell/key-bindings.bash ] && . /usr/local/opt/fzf/shell/key-bindings.bash               # fzf key bindings (Intel)
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

# Machine-specific overrides (credentials, tokens, etc.)
[ -f ~/.bashrc.local ] && source ~/.bashrc.local

# ~/.zshrc: executed by zsh(1) for interactive shells.

# Zsh keyboard shortcuts
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
[[ -o interactive ]] || return

######
## Shell Behavior
######
setopt ALIASES                      # Enable alias expansion
setopt CORRECT                      # Correct command spelling errors
setopt EXTENDED_GLOB                # Enable extended globbing
setopt NO_CASE_GLOB                 # Case insensitive globbing
setopt RC_EXPAND_PARAM              # Expand parameters in command substitution
setopt NO_CHECK_JOBS                # Don't check for running jobs when exiting the shell
setopt NUMERIC_GLOB_SORT            # Sort numeric filenames in globbing
setopt AUTO_CD                      # Change to a directory by typing its name

zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'   # Case insensitive tab completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"                             # Colored completion (different colors for dirs/files/etc)
zstyle ':completion:*' rehash true                                                  # automatically find new executables in path 
zstyle ':completion:*' menu select                                                  # Highlight menu selection
# Speed up completions
zstyle ':completion:*' accept-exact '*(N)'                                          # Accept exact matches
zstyle ':completion:*' use-cache on                                                 # Use caching
zstyle ':completion:*' cache-path ~/.zsh/cache                                      # Cache path

######
## History
######
setopt INC_APPEND_HISTORY           # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY                # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST       # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS             # Don\'t record an entry that was just recorded again.
setopt HIST_FIND_NO_DUPS            # Do not display a line previously found.
setopt HIST_IGNORE_SPACE            # Don\'t record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS            # Don\'t write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS           # Remove superfluous blanks before recording entry.
HISTSIZE=10000
SAVEHIST=10000

if [[ -n ${CODESPACES:-} ]]; then
    HISTFILEBASE=/workspaces/.codespaces/.persistedshare
else
    HISTFILEBASE=$HOME
fi

if [[ -n ${TMUX_PANE:-} ]]; then
    HISTFILE=$HISTFILEBASE/.zsh_history_tmux_${TMUX_PANE:1}
else
    HISTFILE=$HISTFILEBASE/.zsh_history
fi

######
## Keybindings
######
bindkey '^[Oc' forward-word         # Ctrl+Right
bindkey '^[Od' backward-word        # Ctrl+Left
bindkey '^[[1;5D' backward-word     # Ctrl+Left
bindkey '^[[1;5C' forward-word      # Ctrl+Right
bindkey '^H' backward-kill-word     # delete previous word with ctrl+backspace
bindkey '^U' backward-kill-line     # Ctrl+U delete from cursor to beginning of line (like bash)
bindkey '^[[Z' undo                 # Shift+tab undo last action


######
## Autoload and Initialization
######
autoload -U compinit colors zcalc bashcompinit   # Load zsh functions for completion, colors, and calculations
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C  # Skip security check for faster startup
fi
colors                              # Initialize terminal colors
bashcompinit                        # Enable bash completion compatibility

######
## Window Title
######
precmd() {
    emulate -L zsh
    setopt prompt_subst

    # if $2 is unset use $1 as default
    # if it is set and empty, leave it as is
    : ${2=$1}

    case ${TERM} in
        xterm*|putty*|rxvt*|konsole*|ansi|mlterm*|alacritty|kitty|wezterm|st*)
            # Set xterm title: user@host:cwd
            printf '\033]0;%s@%s:%s\007' "$USER" "${HOST%%.*}" "${PWD/#$HOME/~}"
            ;;
        screen*|tmux*)
            printf '\033_%s@%s:%s\033\\' "$USER" "${HOST%%.*}" "${PWD/#$HOME/~}"
            ;;
        *)
            # Try to use terminfo to set the title
            # If the feature is available set title
            if [[ -n "$terminfo[fsl]" ]] && [[ -n "$terminfo[tsl]" ]]; then
                echoti tsl
                print -Pn "$1"
                echoti fsl
            fi
                ;;
    esac
}

######
## Prompt
######
setopt PROMPT_SUBST

parse_git_branch() {
    # Use git status --porcelain=v1 for faster parsing
    local git_status
    git_status=$(git status --porcelain=v1 2>/dev/null) || return
    
    local git_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    [[ -z $git_branch ]] && return
    
    # Single pass through status
    local tracked=0 untracked=0
    while IFS= read -r line; do
        [[ $line == "?? "* ]] && ((untracked++)) || ((tracked++))
    done <<< "$git_status"
  
    printf " (%s:%d:%d)" "$git_branch" "$tracked" "$untracked"
}

if [[ ${EUID} -eq 0 ]]; then
    PROMPT='%{$fg_bold[green]%}%m%{$reset_color%}:%{$fg_bold[blue]%}%~%{$reset_color%}$(parse_git_branch) $ '
else
    PROMPT='%{$fg_bold[green]%}%n@%m%{$reset_color%}:%{$fg_bold[blue]%}%~%{$reset_color%}$(parse_git_branch) $ '
fi

# Add Debian Chroot to Prompt if available
if [[ -z "$debian_chroot" && -r /etc/debian_chroot ]]; then
    debian_chroot=$(< /etc/debian_chroot)
    PROMPT="${debian_chroot:+($debian_chroot)}$PROMPT"
fi

######
## Source aliases/functions/variables
######
if [[ -r "$HOME/.config/bash/aliases.sh" ]]; then
    source "$HOME/.config/bash/aliases.sh"
fi

if [[ -r "$HOME/.config/bash/functions.sh" ]]; then
    source "$HOME/.config/bash/functions.sh"
fi

if [[ -r "$HOME/.config/bash/variables.sh" ]]; then
    source "$HOME/.config/bash/variables.sh"
fi

######
## OS && Distribution Specific
######
case "$OSTYPE" in
    linux*)
        case "$(lsb_release -is | awk '{print tolower($0)}')" in
            arch* | manjaro*)
                [ -r /usr/share/fzf/completion.zsh ] && . /usr/share/fzf/completion.zsh       # fzf zsh completion
                [ -r /usr/share/fzf/key-bindings.zsh ] && . /usr/share/fzf/key-bindings.zsh   # fzf key bindings
                ;;
            debian* | ubuntu* )
                [ -r /usr/share/doc/fzf/examples/completion.zsh ] && . /usr/share/doc/fzf/examples/completion.zsh         # fzf zsh completion
                [ -r /usr/share/doc/fzf/examples/key-bindings.zsh ] && . /usr/share/doc/fzf/examples/key-bindings.zsh     # fzf key bindings
                ;;
            *)
                echo "Unknown Linux Distribution: $(lsb_release -is)"
                ;;
        esac
        ;;
    darwin*)
        [ -r /opt/homebrew/opt/fzf/shell/completion.zsh ] && source /opt/homebrew/opt/fzf/shell/completion.zsh
        [ -r /opt/homebrew/opt/fzf/shell/key-bindings.zsh ] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
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
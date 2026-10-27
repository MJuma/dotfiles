# ~/.zshrc: executed by zsh(1) for interactive shells.
#
# Zsh Startup File Load Order:
#   1. ~/.zshenv     - All shells (login, interactive, scripts, agents)
#   2. /etc/zprofile - Login shells only (runs path_helper on macOS)
#   3. ~/.zprofile   - Login shells only
#   4. /etc/zshrc    - Interactive shells only
#   5. ~/.zshrc      - Interactive shells only (this file)
#   6. /etc/zlogin   - Login shells only
#   7. ~/.zlogin     - Login shells only
#
# Machine-specific config (PATH, Homebrew, NVM) belongs in ~/.zshenv
# so non-interactive shells (e.g. Copilot agents, scripts) have access.
# This file is symlinked from dotfiles and shared across machines.

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
## PATH
######
# ~/.local/bin first for user-level installs (-U drops later copies, e.g. where macOS path_helper moved it)
typeset -U path
path=("$HOME/.local/bin" $path)

######
## Shell Behavior
######
setopt ALIASES                      # Enable alias expansion
setopt CORRECT                      # Correct command spelling errors
setopt NO_EXTENDED_GLOB             # Disable extended globbing
# setopt NO_CASE_GLOB                 # Case insensitive globbing (disabled for case sensitive completion)
setopt RC_EXPAND_PARAM              # Expand parameters in command substitution
setopt NO_CHECK_JOBS                # Don't check for running jobs when exiting the shell
setopt NUMERIC_GLOB_SORT            # Sort numeric filenames in globbing
setopt AUTO_CD                      # Change to a directory by typing its name

# Force case sensitive completion
zstyle ':completion:*' matcher-list ''                                              # Case sensitive tab completion
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
setopt SHARE_HISTORY                # Share history between all sessions (also writes each command immediately).
setopt HIST_EXPIRE_DUPS_FIRST       # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS             # Don\'t record an entry that was just recorded again.
setopt HIST_FIND_NO_DUPS            # Do not display a line previously found.
setopt HIST_IGNORE_SPACE            # Don\'t record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS            # Don\'t write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS           # Remove superfluous blanks before recording entry.
HISTSIZE=10000
SAVEHIST=10000

if [[ -n ${CODESPACES:-} ]]; then
    HISTFILE=/workspaces/.codespaces/.persistedshare/.zsh_history
else
    mkdir -p "$HOME/.local/state/zsh"
    HISTFILE="$HOME/.local/state/zsh/history"
fi

######
## Keybindings
######
bindkey -e                          # Emacs keymap (zsh picks vi mode when $EDITOR contains "vi")
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
# Full compinit (with security check) at most once a day; (#q) needs extended_glob
() {
    setopt local_options extended_glob
    local zcompdump=${ZDOTDIR:-$HOME}/.zcompdump
    if [[ ! -e $zcompdump || -n $zcompdump(#qN.mh+24) ]]; then
        # touch only if the security check passed; compinit leaves an unchanged dump untouched
        compinit -d "$zcompdump" && touch "$zcompdump"
    else
        compinit -C -d "$zcompdump"  # Skip security check for faster startup
    fi
}
colors                              # Initialize terminal colors
bashcompinit                        # Enable bash completion compatibility

######
## Window Title
######
_set_window_title() {
    emulate -L zsh
    local title="${USER}@${HOST%%.*}:${PWD/#$HOME/~}"

    case ${TERM} in
        xterm*|putty*|rxvt*|konsole*|ansi|mlterm*|alacritty|kitty|wezterm|st*)
            printf '\033]0;%s\007' "$title"
            ;;
        screen*|tmux*)
            printf '\033_%s\033\\' "$title"
            ;;
        *)
            # Try to use terminfo to set the title
            # If the feature is available set title
            if [[ -n "$terminfo[fsl]" ]] && [[ -n "$terminfo[tsl]" ]]; then
                echoti tsl
                print -rn -- "$title"
                echoti fsl
            fi
            ;;
    esac
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _set_window_title

######
## Prompt
######
setopt PROMPT_SUBST

# Git segment: the branch is read synchronously (a few ms) and the dirty counts come from a
# background git status (zle -F), so a big repo or a cold cache never delays the prompt.
# Shows (branch:?) until the first status for a repo finishes, then (branch) or (branch:tracked:untracked)
typeset -g _git_prompt_info= _git_prompt_branch= _git_prompt_key= _git_prompt_rerun=0
typeset -g _git_prompt_fd=${_git_prompt_fd-} _git_prompt_fd_key=${_git_prompt_fd_key-}  # keep a running status across re-sourcing
typeset -gA _git_prompt_counts                  # "tracked untracked" per git dir and branch

# Runs in the background; prints "tracked untracked", or nothing if git status fails
_git_prompt_status() {
    emulate -L zsh
    local out
    out=$(git status --porcelain=v1 2>/dev/null) || return
    local -a lines untracked
    lines=(${(f)out})
    untracked=(${(M)lines:#\?\? *})
    print -r -- "$(( ${#lines} - ${#untracked} )) ${#untracked}"
}

_git_prompt_render() {
    emulate -L zsh
    local branch=${_git_prompt_branch//\%/%%}   # keep % in branch names out of prompt expansion
    if [[ -z $_git_prompt_key ]]; then
        _git_prompt_info=
    elif (( ! ${+_git_prompt_counts[$_git_prompt_key]} )); then
        _git_prompt_info=" ($branch:?)"
    else
        local -a counts
        counts=(${=_git_prompt_counts[$_git_prompt_key]})
        if (( counts[1] + counts[2] == 0 )); then
            _git_prompt_info=" ($branch)"
        else
            _git_prompt_info=" ($branch:${counts[1]}:${counts[2]})"
        fi
    fi
}

# One status at a time across all repos: closing the pipe wouldn't stop an abandoned git status,
# so prompts drawn while one runs (even in another repo) set _git_prompt_rerun and wait for it
_git_prompt_start() {
    _git_prompt_rerun=0
    _git_prompt_fd_key=$_git_prompt_key
    exec {_git_prompt_fd}< <(_git_prompt_status)
    zle -F -w $_git_prompt_fd _git_prompt_done
}

# zle -F widget: the background status finished (zle passes its fd)
_git_prompt_done() {
    emulate -L zsh
    local fd=$1 key=$_git_prompt_fd_key result
    IFS= read -r -u $fd result
    zle -F $fd
    exec {fd}<&-
    [[ $fd == $_git_prompt_fd ]] || return 0  # superseded
    _git_prompt_fd=
    [[ $result == <->' '<-> ]] && _git_prompt_counts[$key]=$result  # keep the last counts if git status failed
    # Later prompts may be in another repo or follow changes this status missed
    [[ -n $_git_prompt_key ]] && (( _git_prompt_rerun )) && _git_prompt_start
    # reset-prompt would erase a completion menu or list (one stays on screen even while typing), so
    # redraw only at a fresh prompt (zle-line-init when a line-init hook is set); otherwise the next prompt shows it
    if [[ $key == $_git_prompt_key && $LASTWIDGET == (|accept-line|send-break|*zle-line-init) ]]; then
        _git_prompt_render
        zle reset-prompt
    fi
    return 0
}
zle -N _git_prompt_done

_git_prompt_precmd() {
    emulate -L zsh
    local git_dir branch
    if git_dir=$(git rev-parse --absolute-git-dir 2>/dev/null) &&
        branch=$(git symbolic-ref --short HEAD 2>/dev/null); then
        _git_prompt_branch=$branch
        _git_prompt_key="$git_dir|$branch"
    else
        _git_prompt_branch= _git_prompt_key=
    fi

    if [[ -z $_git_prompt_key ]]; then
        _git_prompt_info=
        return
    fi
    if [[ ! -t 0 ]]; then                       # no line editor reading a terminal to redraw: branch only
        _git_prompt_info=" (${branch//\%/%%})"
        return
    fi
    _git_prompt_render

    if [[ -n $_git_prompt_fd ]]; then
        _git_prompt_rerun=1
        return
    fi
    _git_prompt_start
}
add-zsh-hook precmd _git_prompt_precmd

if [[ ${EUID} -eq 0 ]]; then
    PROMPT='%{$fg_bold[green]%}%m%{$reset_color%}:%{$fg_bold[blue]%}%~%{$reset_color%}${_git_prompt_info} $ '
else
    PROMPT='%{$fg_bold[green]%}%n@%m%{$reset_color%}:%{$fg_bold[blue]%}%~%{$reset_color%}${_git_prompt_info} $ '
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

if [[ -r "$HOME/.config/bash/variables.sh" ]]; then
    source "$HOME/.config/bash/variables.sh"
fi

if [[ -r "$HOME/.config/bash/functions.sh" ]]; then
    source "$HOME/.config/bash/functions.sh"
fi

######
## OS && Distribution Specific
######
# Only fzf is set up here and it needs the line editor, which reads from a terminal on stdin.
# Without one (e.g. VS Code's environment probe) fzf's option restore prints "can't change option: zle"
if [[ -t 0 ]]; then
    case "$OSTYPE" in
        linux*)
            local distro_id
            if [ -r /etc/os-release ]; then
                distro_id=$(. /etc/os-release && echo "$ID")
            fi
            case "$distro_id" in
                arch | manjaro | endeavouros)
                    [ -r /usr/share/fzf/completion.zsh ] && . /usr/share/fzf/completion.zsh       # fzf zsh completion
                    [ -r /usr/share/fzf/key-bindings.zsh ] && . /usr/share/fzf/key-bindings.zsh   # fzf key bindings
                    ;;
                debian | ubuntu)
                    [ -r /usr/share/doc/fzf/examples/completion.zsh ] && . /usr/share/doc/fzf/examples/completion.zsh         # fzf zsh completion
                    [ -r /usr/share/doc/fzf/examples/key-bindings.zsh ] && . /usr/share/doc/fzf/examples/key-bindings.zsh     # fzf key bindings
                    ;;
                fedora)
                    [ -r /usr/share/fzf/shell/key-bindings.zsh ] && . /usr/share/fzf/shell/key-bindings.zsh   # fzf key bindings
                    ;;
                mariner | azurelinux)
                    type fzf &>/dev/null && eval "$(fzf --zsh)"                                     # fzf shell integration
                    ;;
                *)
                    echo "Unknown Linux Distribution: ${distro_id:-unknown}"
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
fi

# Machine-specific overrides (credentials, tokens, etc.)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

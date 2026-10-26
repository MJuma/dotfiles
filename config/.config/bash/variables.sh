######
## Bash Global Variables
######
export EDITOR='vim'                                                                             # Set line editor
export VISUAL='vim'                                                                             # Set visual editor
# VS Code can only open a window from its own terminal or a local (non-SSH) desktop session
if command -v code &>/dev/null; then
    if [[ $TERM_PROGRAM == vscode ]] || [[ -z $SSH_CONNECTION && ( $OSTYPE == darwin* || -n $DISPLAY || -n $WAYLAND_DISPLAY ) ]]; then
        export VISUAL='code --wait'
    fi
fi

######
## Shell History
######
HISTCONTROL=ignoreboth                                                                          # Don't put duplicate lines or lines starting with space in the history.
HISTSIZE=10000                                                                                  # Number of lines stored in memory for a running bash session
HISTFILESIZE=20000                                                                              # Number of lines stored in bash history file

######
## rg
######
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgreprc"

######
## fd
######
# Debian/Ubuntu install fd as fdfind, and the fd alias doesn't apply to `command` or fzf's shells
FD_BIN=$(command -v fdfind || command -v fd)
export FD_OPTIONS="--hidden --absolute-path --exclude .git --exclude node_modules"

######
## Fzf
######
export FZF_TMUX_OPTS='-r 40%'
export FZF_DEFAULT_OPTS="
    --extended
    --multi
    --height=40%
    --layout=reverse
    --bind='ctrl-p:toggle-preview,ctrl-j:preview-down,ctrl-k:preview-up,ctrl-o:execute(code {1})'
    --preview='
        [[ \$(file --mime {}) =~ binary ]] && echo {} is a binary file ||
        (
            bat --style=numbers --color=always {} ||
            cat {}
        ) 2> /dev/null
    '
    --preview-window='right:hidden:wrap' 
    --border
    --color=dark
    --color=fg:-1,bg:-1,hl:#c678dd,fg+:#ffffff,bg+:#4b5263,hl+:#d858fe
    --color=info:#98c379,prompt:#61afef,pointer:#be5046,marker:#e5c07b,spinner:#61afef,header:#61afef
"
export FZF_DEFAULT_COMMAND="
    (rg --files --line-number --hidden --smart-case) ||
    (${FD_BIN:-fd} --type f --type l $FD_OPTIONS) ||
    (git ls-files --cached --others --exclude-standard)
"
# Without fd, leave these unset so fzf falls back to its built-in file walker
if [[ -n $FD_BIN ]]; then
    export FZF_CTRL_T_COMMAND="$FD_BIN $FD_OPTIONS"
    export FZF_ALT_C_COMMAND="$FD_BIN --type d $FD_OPTIONS"
else
    unset FZF_CTRL_T_COMMAND FZF_ALT_C_COMMAND
fi

######
## bat
######
export BAT_PAGER="less --RAW-CONTROL-CHARS --quit-if-one-screen --mouse"
export BAT_THEME="OneHalfDark"

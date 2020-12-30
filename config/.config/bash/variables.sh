#!/bin/bash

######
## Bash Global Variables
######
export TZ="/usr/share/zoneinfo/America/Los_Angeles"                                             # Set timezone to PDT/PST
export EDITOR='vim'                                                                             # Set line editor
[[ -z $DISPLAY ]] && export VISUAL='vim' || export VISUAL='code'                                # Set visual or terminal editor

######
## Shell History
######
HISTCONTROL=ignoreboth                                                                          # Don't put duplicate lines or lines starting with space in the history.
HISTSIZE=10000                                                                                  # Number of lines stored in memory for a running bash session
HISTFILESIZE=20000                                                                              # Number of lines stored in bash history file

######
## Path
######
export PATH=$PATH:$HOME/bin
if [ -d "$HOME/.yarn/bin" ]; then
    export PATH=$PATH:$HOME/.yarn/bin
fi

######
## rg
######
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgreprc"

######
## fd
######
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
    (fd --type f --type l $FD_OPTIONS) ||
    (git ls-files --cached --others --exclude-standard)
"
export FZF_CTRL_T_COMMAND="fd $FD_OPTIONS"
export FZF_ALT_C_COMMAND="fd --type d $FD_OPTIONS"

######
## bat
######
export BAT_PAGER="less --RAW-CONTROL-CHARS --quit-if-one-screen --mouse"
export BAT_THEME="OneHalfDark"

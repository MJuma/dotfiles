#!/bin/bash

alias sudo="sudo -E "                                                                                   # Preserve environment variables when calling sudo
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
alias dotfiles='code ~/dotfiles'                                                                        # Opens the dotfiles repo in a text editor
alias hosts='code /etc/hosts'                                                                           # Opens the hosts file in a repo

if [ -x /usr/bin/bat ]; then
    alias cat='bat --paging=never'                                                                      # Swap cat with bat
    alias man='man --pager=bat'                                                                         # Page man using bat
fi

if  [ type xclip &> /dev/null ]; then
    alias pbcopy='xclip -i -selection clipboard'                                                        # Copy selection to clipboard
    alias pbpaste='xclip -o -selection clipboard'                                                       # Paste selection from clipboard
    alias pbclear='echo "" | xclip -i -selection clipboard'                                             # Clear clipboard
fi

if [[ $DESKTOP_SESSION == "plasma" ]]; then
    alias kder='kquitapp5 plasmashell || killall plasmashell && kstart5 plasmashell'                    # Restart KDE DE
fi

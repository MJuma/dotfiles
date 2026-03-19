alias sudo="sudo -E "                                                                                   # Preserve environment variables when calling sudo
alias cp="cp -i"                                                                                        # Confirm before overwriting files and directories
alias df='df -h'                                                                                        # Human readable disk space usage
alias free='free -m'                                                                                    # Free memory and swap in Mebibytes
alias atop='watch -n 3 "free; echo; uptime; echo; ps aux  --sort=-%cpu | head -n 11; echo; who"'        # Show free memory, uptime & ps updated every 3s
alias nano='nano -c -m'                                                                                 # nano with cursor position shown and mouse support enabled
alias ping='ping -c 5'                                                                                  # Ping address 5 times
alias grep='grep --color=auto'                                                                         # Colorize grep
alias egrep='egrep --color=auto'                                                                       # Colorize egrep
alias fgrep='fgrep --color=auto'                                                                       # Colorize fgrep
alias ..='cd ..'                                                                                        # Go up a directory
alias ...='cd ../..'                                                                                    # Go up two directories
alias histg="history | grep"                                                                            # Search through comman history: histg [keyword]
alias t='(tmux has-session 2>/dev/null && tmux attach) || (tmux new-session)'                           # Open previous tmux session or new one if none others exist
alias busy='cat /dev/urandom | hexdump -C | grep "ca fe"'                                               # Create hexdump of /dev/urandom to look busy
alias prettyjson='python3 -m json.tool'						                                            # Pretty print json
alias npmg='npm list -g --depth=0'						                                                # List all globally install npm packages
alias ascii="man ascii"                                                                                 # man page listing the ascii codes
alias nethack='telnet nethack.alt.org'                                                                  # Telnet game
alias dotfiles='code ~/dotfiles'                                                                        # Opens the dotfiles repo in a text editor
alias hosts='code /etc/hosts'                                                                           # Opens the hosts file in a repo

if [ -x /usr/bin/bat ]; then
    alias cat='bat --paging=never'                                                                      # Swap cat with bat
    alias man='man --pager=bat'                                                                         # Page man using bat
fi

if type xclip &>/dev/null; then
    alias pbcopy='xclip -i -selection clipboard'                                                        # Copy selection to clipboard
    alias pbpaste='xclip -o -selection clipboard'                                                       # Paste selection from clipboard
    alias pbclear='echo "" | xclip -i -selection clipboard'                                             # Clear clipboard
fi

if [[ $DESKTOP_SESSION == "plasma" ]]; then
    alias kder='kquitapp5 plasmashell || killall plasmashell && kstart5 plasmashell'                    # Restart KDE DE
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

        distro_id=
        if [ -r /etc/os-release ]; then
            distro_id=$(. /etc/os-release && echo "$ID")
        fi
        case "$distro_id" in
            arch | manjaro)
                alias get='yay -S'                                                              # Get a package
                alias remove='yay -Rsu'                                                         # Remove a package
                alias update='yay -Syyu'                                                        # Update package list and upgrade packages
                alias clean='yay -Sc && yay -Qtdq | yay -Rns -'                                 # Removes unused packages and removes unused orphaned packages
                alias search='yay -Ss'                                                          # Search package list for a package
                alias info='yay -Si'                                                            # Search package list for a package
                alias pkstats='yay -P --stats'                                                  # Shows statistics for installed packages and system health
                ;;
            debian | ubuntu)
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
                ;;
            fedora)
                alias get='sudo dnf install'                                                    # Get a package
                alias remove='sudo dnf remove'                                                  # Remove a package
                alias update='sudo dnf upgrade --refresh'                                       # Update repository metadata and upgrade packages
                alias clean='sudo dnf autoremove'                                               # Removes unused packages
                alias search='dnf search'                                                       # Search repository for a package
                alias info='dnf info'                                                           # Show package details
                ;;
            mariner | azurelinux)
                alias get='sudo tdnf install'                                                   # Get a package
                alias remove='sudo tdnf remove'                                                 # Remove a package
                alias update='sudo tdnf upgrade'                                                # Upgrade packages
                alias clean='sudo tdnf autoremove'                                              # Removes unused packages
                alias search='tdnf search'                                                      # Search repository for a package
                alias info='tdnf info'                                                          # Show package details
                ;;
            *)
                ;;
        esac
        unset distro_id
        ;;
    darwin*)
        alias ls='ls -G'                                                                        # Colorize ls
        alias peekaboo='sudo netstat -p tcp -van | grep LISTEN'                                 # Show network connections with options PID, listening sockets, udp, numeric address, tcp
        alias get='brew install'                                                                # Get a package
        alias remove='brew uninstall'                                                           # Remove a package
        alias update='brew update && brew upgrade'                                              # Update homebrew formulae and upgrade packages
        alias clean='brew autoremove && brew cleanup'                                           # Removes unused packages and clears download cache
        ;; 
    solaris*) 
        ;;
    bsd*)     
        ;;
    msys* | cygwin*)    
        ;;
    *)        
        ;;
esac

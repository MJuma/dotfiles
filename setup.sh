#!/bin/bash
set -euo pipefail

dryRun=false
while getopts "n" option; do
    case ${option} in
        n ) dryRun=true ;;
    esac
done

if test -t 1; then # if terminal
    ncolors=$(which tput > /dev/null && tput colors) # supports color
    if test -n "$ncolors" && test $ncolors -ge 8; then
        termcols=$(tput cols)
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        black="$(tput setaf 0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
        white="$(tput setaf 7)"
    fi
fi

print_bold() {
    title="$1"
    text="$2"

    echo
    echo "${blue}================================================================================${normal}"
    echo "${blue}================================================================================${normal}"
    echo
    echo -e "  ${bold}${magenta}${title}${normal}"
    echo
    echo -e "  ${text}"
    echo
    echo "${blue}================================================================================${normal}"
    echo "${blue}================================================================================${normal}"
    echo
}

# Validate dependencies needed to setup dotfiles
validate_dependencies() {
    dependencies=( "curl" "stow" )
    for i in "${dependencies[@]}"
    do
        command -v $i >/dev/null 2>&1 || {
            echo -e "\n${red}ERROR:${normal} Dependency missing: ${yellow}$i${normal}";
            echo -e "Install dependency and rerun to continue\n"
            exit 1;
        }
    done
}

# Backup old files to avoid overwriting
filesMovedOutput=""
backup_old_files() {
    oldfiles=(
        ".bashrc"
        ".config/alacritty"
        ".config/bash"
        ".config/ripgreprc"
        ".config/vim"
        ".gitconfig"
        ".nanorc"
        ".tmux.conf"
        ".vimrc"
        ".zshrc"
        "scripts"
    )
    for i in "${oldfiles[@]}"
    do
        if [[ -f "$HOME/$i" ]]; then
            if !([[ -h "$HOME/$i" ]] && [[ $(readlink "$HOME/$i") == *dotfiles* ]]); then
                if [[ $dryRun = false ]]; then
                    mv "$HOME/$i" "$HOME/$i-old"
                fi
                filesMovedOutput="${filesMovedOutput}\n\t$HOME/$i ${blue}=>${normal} $HOME/$i-old"
            fi
        fi
    done
}

# Use stow to link dotfiles to $HOME directory
linkedFilesOutput=""
stow_dotfiles() {
    IFS=$'\n'
    dotfiles=($(find . -mindepth 1 -maxdepth 1 -type d -not -path '*/\.*' | sed 's|.*/||' | grep -v -E "PowerShell|pwsh"))
    unset IFS
    for dotfile in "${dotfiles[@]}"
    do
        local stowOutput
        if [[ $dryRun = true ]]; then
            stowOutput=$(stow -n -v --no-folding -t $HOME $dotfile 2>&1)
        else
            stowOutput=$(stow -v --no-folding -t $HOME $dotfile 2>&1)
        fi

        while IFS= read -r line; do
            if [[ "$line" == *"LINK"* ]]; then
                local target source
                target=$(echo "$line" | cut -c 7- | awk -F ' => ' '{print $1}')
                source=$(echo "$line" | cut -c 7- | awk -F ' => ' '{print $2}')
                linkedFilesOutput="${linkedFilesOutput}\n\t${target} ${blue}=>${normal} ${source}"
            fi
        done <<< "$stowOutput"
    done
}

if [[ $dryRun = true ]]; then
    dryRunMessage="${yellow} (Dry Run)${normal}"
fi

print_bold \
    "                            dotfiles setup                            " \
    "This script will$dryRunMessage:
    - Validate dependencies needed exist
    - Backup any existing dotfiles
    - Link dotfiles from this repo to \$HOME ($HOME)"

echo -n "Running step: Validate dependencies"
validate_dependencies
echo " (${green}Success${normal})"

echo -n "Running step: Backup existing files"
backup_old_files
echo " (${green}Success${normal})"

echo -n "Running step: Link dotfiles"
stow_dotfiles
echo " (${green}Success${normal})"

print_bold \
    "                       dotfiles setup complete                           " \
    "
    Files backed up:
    ${filesMovedOutput}

    Files linked:
    ${linkedFilesOutput}
    "

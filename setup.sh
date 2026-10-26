#!/bin/bash
set -euo pipefail

# Package discovery and stow paths are relative to the repo root
cd "$(dirname "${BASH_SOURCE[0]}")"

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
bold="${bold:-}"
underline="${underline:-}"
standout="${standout:-}"
normal="${normal:-}"
black="${black:-}"
red="${red:-}"
green="${green:-}"
yellow="${yellow:-}"
blue="${blue:-}"
magenta="${magenta:-}"
cyan="${cyan:-}"
white="${white:-}"

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

# Install the Brewfile's tools on macOS; runs before validation because a fresh Mac has no stow yet
install_brew_packages() {
    if [[ $OSTYPE != darwin* ]]; then
        echo " (${yellow}Skipped${normal}: not macOS)"
        return
    fi
    if ! command -v brew >/dev/null 2>&1; then
        echo " (${yellow}Skipped${normal}: install Homebrew from https://brew.sh first)"
        return
    fi

    echo
    if [[ $dryRun = true ]]; then
        brew bundle check --no-upgrade --verbose --file=Brewfile || true
    elif brew bundle install --no-upgrade --file=Brewfile; then
        echo "Homebrew packages (${green}Success${normal})"
    else
        echo "Homebrew packages (${yellow}Failed${normal}, continuing; see the brew output above)"
    fi
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

# Stow packages: every top-level directory except the Windows-only pwsh
packages=()
for dir in */; do
    [[ $dir == pwsh/ ]] || packages+=("${dir%/}")
done

# Paths a package links into $HOME, relative to the package root
package_files() {
    (cd "$1" && find . \( -type f -o -type l \) | sed 's|^\./||')
}

# A parent folder that's a symlink out of this repo would make backups rename files where it points, and stow can't link through it
check_symlinked_parents() {
    local package file dir resolved repo
    repo=$(pwd -P)
    for package in "${packages[@]}"; do
        while IFS= read -r file; do
            dir=$file
            while [[ $dir == */* ]]; do
                dir=${dir%/*}
                if [[ -L $HOME/$dir ]] && resolved=$(cd "$HOME/$dir" 2>/dev/null && pwd -P) &&
                    [[ $resolved != "$repo" && $resolved != "$repo"/* ]]; then
                    echo " (${red}Failed${normal})"
                    echo -e "\n${red}ERROR:${normal} ~/$dir is a symlink to $resolved, so stow can't link ${yellow}$file${normal} through it." >&2
                    echo -e "Replace ~/$dir with a real folder and rerun. Nothing was backed up or linked.\n" >&2
                    exit 1
                fi
            done
        done < <(package_files "$package")
    done
}

# Backup old files to avoid overwriting
filesMovedOutput=""
backup_old_files() {
    local package file target
    check_symlinked_parents
    for package in "${packages[@]}"; do
        while IFS= read -r file; do
            target="$HOME/$file"
            # -ef follows symlinks, so targets already linked to this repo are skipped
            if [[ -e $target || -L $target ]] && [[ ! $target -ef $package/$file ]]; then
                # stow replaces its own broken links into this repo, e.g. after a file moves between packages
                if [[ -L $target && ! -e $target && $(readlink "$target") == *"${PWD##*/}/"* ]]; then
                    continue
                fi
                if [[ $dryRun = false ]]; then
                    mv "$target" "$target-old"
                fi
                filesMovedOutput="${filesMovedOutput}\n\t$target ${blue}=>${normal} $target-old"
            fi
        done < <(package_files "$package")
    done
}

# Use stow to link dotfiles to $HOME directory
linkedFilesOutput=""
stow_dotfiles() {
    local package file stowOutput line target source
    for package in "${packages[@]}"; do
        if [[ $dryRun = true ]]; then
            # stow -n would report the files that a real run backs up first as conflicts
            while IFS= read -r file; do
                if [[ ! $HOME/$file -ef $package/$file ]]; then
                    linkedFilesOutput="${linkedFilesOutput}\n\t${file} ${blue}=>${normal} ${package}/${file}"
                fi
            done < <(package_files "$package")
            continue
        fi

        if ! stowOutput=$(stow -v --no-folding -t "$HOME" "$package" 2>&1); then
            echo " (${red}Failed${normal})"
            echo -e "\n${red}ERROR:${normal} stow could not link ${yellow}${package}${normal}:\n${stowOutput}\n" >&2
            exit 1
        fi

        while IFS= read -r line; do
            if [[ "$line" == *"LINK"* ]]; then
                target=$(echo "$line" | cut -c 7- | awk -F ' => ' '{print $1}')
                source=$(echo "$line" | cut -c 7- | awk -F ' => ' '{print $2}')
                linkedFilesOutput="${linkedFilesOutput}\n\t${target} ${blue}=>${normal} ${source}"
            fi
        done <<< "$stowOutput"
    done
}

if [[ $dryRun = true ]]; then
    dryRunMessage="${yellow} (Dry Run)${normal}"
else
    dryRunMessage=""
fi

print_bold \
    "                            dotfiles setup                            " \
    "This script will$dryRunMessage:
    - Install the Brewfile's packages with Homebrew (macOS only)
    - Validate dependencies needed exist
    - Backup any existing dotfiles
    - Link dotfiles from this repo to \$HOME ($HOME)"

echo -n "Running step: Install Homebrew packages"
install_brew_packages

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

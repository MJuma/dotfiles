#!/bin/bash

mcd() { mkdir -p "$1" && cd "$1";}                                                                      # Make a directory and cd into it
cls() { cd "$1" && ls;}                                                                                 # cd into a directory and ls it
backup() { cp -- "$1"{,.bak};}                                                                          # Backup a file to file.bak
md5check() { md5sum "$1" | grep "$2";}                                                                  # Compare md5sum of file to key
checkport() { lsof -i:$1; }                                                                             # Check for any programs using a given port   
randfile() { find $1 -type f | shuf -n 1; }                                                             # Returns a random file within a given dir recursively
wttr() { curl -s "wttr.in/$1"; }                                                                        # Returns the weather in the given location 
dut() { du -d 1 -h 2> >(grep -v 'du: cannot') $1 | sort -h; }                                           # Returns the disk usage totals for a given directory   

# Extract an archive file: extract [file]
extract() { 
    if [ -f $1 ] ; then 
      case $1 in 
        *.tar.bz2)   tar xvjf $1    ;; 
        *.tar.gz)    tar xvzf $1    ;; 
        *.bz2)       bunzip2 $1     ;; 
        *.rar)       unrar e $1     ;; 
        *.gz)        gunzip $1      ;; 
        *.tar)       tar xvf $1     ;; 
        *.tbz2)      tar xvjf $1    ;; 
        *.tgz)       tar xvzf $1    ;; 
        *.zip)       unzip $1       ;; 
        *.Z)         uncompress $1  ;; 
        *.7z)        7z x $1        ;; 
        *)     echo "'$1' cannot be extracted via extract()" ;; 
         esac 
     else 
         echo "'$1' is not a valid file" 
     fi 
}

# Use fd instead of the default find for fzf '**' shell completions.
# - The first argument to the function ($1) is the base path to start traversal
_fzf_compgen_path() {
    command fd --hidden --follow --exclude .git --exclude node_modules . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
    command fd --type d --hidden --follow --exclude .git --exclude node_modules . "$1"
}

# # Open the selected filewith default editor
# #   - CTRL-O to open with `open` command,
# #   - CTRL-E or Enter key to open with the $EDITOR
fo() {
  IFS=$'\n' out=("$(fzf-tmux --query="$1" --exit-0 --expect=ctrl-o,ctrl-e)")
  key=$(head -1 <<< "$out")
  file=$(head -2 <<< "$out" | tail -1)
  if [ -n "$file" ]; then
    [ "$key" = ctrl-o ] && open "$file" || ${EDITOR:-vim} "$file"
  fi
}

# using ripgrep combined with preview
# find-in-file - usage: fif <searchTerm>
fif() {
  if [ ! "$#" -gt 0 ]; then echo "Need a string to search for!"; return 1; fi
  rg --no-messages -n $1 | fzf --delimiter : --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' --preview-window +{2}-/2
}

# fbr - checkout git branch (including remote branches)
fbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# fcoc - checkout git commit
fcoc() {
  local commits commit
  commits=$(git log --pretty=oneline --abbrev-commit --reverse) &&
  commit=$(echo "$commits" | fzf --tac +s +m -e) &&
  git checkout $(echo "$commit" | sed "s/ .*//")
}

frepl() {
    if [ ! "$#" -gt 0 ]; then echo "REPL type required. Must be one of: awk, sed, jq, ls, man"; return 1; fi
    case "$1" in
        awk)
            echo '' | fzf --height=100% --print-query --preview 'echo "a\nb\nc\nd" | awk {q}' --preview-window='right:nohidden:wrap'
            ;;
        sed)
            echo '' | fzf --height=100% --print-query --preview 'echo "a\nb\nc\nd" | sed -n {q}' --preview-window='right:nohidden:wrap' 
            ;;
        jq)
            if [ ! "$#" -eq 2 ]; then echo "Requires second arg"; return 1; fi
            echo '' | fzf --height=100% --print-query --preview "jq --color-output -r {q} $2" --preview-window='right:nohidden:60%:wrap'
            ;;
        ls)
            echo '' | fzf --height=100% --preview 'ls -al {q}' --preview-window='right:nohidden:wrap'
            ;;
        man)
            echo '' | fzf --height=100% --preview 'man {q}' --preview-window='right:nohidden:60%:wrap'
            ;;
        *)
            echo "Unknown REPL type"
            ;;
    esac
}

# caniuse: https://sidneyliebrand.io/blog/combining-caniuse-with-fzf
fcani() {
    if [ ! -r "$HOME/Downlaods/cani.json" ]; then
        curl -fLo "$HOME/Downlaods/cani.json" --create-dirs https://raw.githubusercontent.com/Fyrd/caniuse/master/data.json
    fi
}
"""""""""""""""""""" PLUGINS
filetype off

" Vundle

	set rtp+=~/.vim/bundle/vundle/
	call vundle#rc()

    " Setting up Vundle - the vim plugin bundler
        let iCanHazVundle=1
        let vundle_readme=expand("~/.vim/bundle/vundle/README.md")
        if !filereadable(vundle_readme) 
        "if !isdirectory("~/.vim/bundle/vundle")
            echo "Installing Vundle.."
            echo ""
            silent !mkdir -p ~/.vim/bundle
            silent !git clone https://github.com/gmarik/vundle ~/.vim/bundle/vundle
            let iCanHazVundle=0
        endif
        set rtp+=~/.vim/bundle/vundle/
        call vundle#rc()
        Bundle 'gmarik/vundle'
    " Setting up Vundle - the vim plugin bundler end

    " Bundles
        Bundle 'gmarik/vundle'
	Bundle 'matchit.zip'
	Bundle 'The-NERD-Commenter'
	Bundle 'The-NERD-tree'
	Bundle 'vim-powerline'
	Bundle 'Command-T'
	Bundle 'Lokaltog/vim­-powerline'
    " Bundles end
    if iCanHazVundle == 0
        echo "Installing Bundles, please ignore key map error messages"
        echo ""
    :BundleInstall
    endif
" Vundle end

"""""""""""""""""""" GLOBAL
let mapleader=","
colorscheme mustang
set gfn=terminus
set go=

syntax on
filetype plugin indent on
set encoding=utf-8
set hidden

set showcmd         				" Show (partial) command in status line.

set nowrap

set backspace=2     				" Influences the working of <BS>, <Del>, CTRL-W
                    				" and CTRL-U in Insert mode. This is a list of items,
                    				" separated by commas. Each item allows a way to backspace
                    				" over something.

set autoindent      				" Copy indent from current line when starting a new line
                    				" (typing <CR> in Insert mode or when using the "o" or "O"
                    				" command).

set copyindent

set number          				" Show line numbers.

set shiftround

set ignorecase      				" Ignore case in search patterns.

set smartcase       				" Override the 'ignorecase' option if the search pattern
                    				" contains upper case characters.

set hlsearch        				" When there is a previous search pattern, highlight all
                    				" its matches.
set incsearch       				" While typing a search command, show immediately where the
                    				" so far typed pattern matches.
set history=1000

set undolevels=1000

set title

set visualbell

set noerrorbells

set list

set listchars=tab:>.,trail:.,extends:#,nbsp:.

set ttyfast

set mouse=a					" Enable the use of the mouse.

set nocompatible

set backup

set backupdir=~/.vim_backup

set noswapfile

set fileformats=unix,dos,mac

set laststatus=2

set expandtab       				" Use the appropriate number of spaces to insert a <Tab>.
                    				" Spaces are used in indents with the '>' and '<' commands
                    				" and when 'autoindent' is on. To insert a real tab when
                    				" 'expandtab' is on, use CTRL-V <Tab>.
set softtabstop=2

set tabstop=4       				" Number of spaces that a <Tab> in the file counts for.

set shiftwidth=4    				" Number of spaces to use for each step of (auto)indent.

set ruler           				" Show the line and column number of the cursor position,
                    				" separated by a comma.
set wildignore=*.swp,*.bak

set wildmode=longest,list

set smarttab        				" When on, a <Tab> in front of a line inserts blanks
                    				" according to 'shiftwidth'. 'tabstop' is used in other
                    				" places. A <BS> will delete a 'shiftwidth' worth of space
                    				" at the start of the line.

set showmatch       				" When a bracket is inserted, briefly jump to the matching
                    				" one.The jump is only done if the match can be seen on the
                    				" screen. The time to show the match can be set with
                    				" 'matchtime'.

set background=dark 				" When set to "dark", Vim will try to use colors that look
                    				" good on a dark background. When set to "light", Vim will
                    				" try to use colors that look good on a light background.
                    				" Any other value is illegal.

set textwidth=79    				" Maximum width of text that is being inserted. A longer
                    				" line will be broken after white space to get this width.

set formatoptions=c,q,r,t 				" This is a sequence of letters which describes how
                    				" automatic formatting is to be done.
                    				"
                    				" letter    meaning when present in 'formatoptions'
                    				" ------    ---------------------------------------
                    				" c         Auto-wrap comments using textwidth, inserting
                    				"           the current comment leader automatically.
                    				" q         Allow formatting of comments with "gq".
                    				" r         Automatically insert the current comment leader
                    				"           after hitting <Enter> in Insert mode. 
                    				" t         Auto-wrap text using textwidth (does not apply
                    				"           to comments)

"""""""""""""""""""" KEYBINDINGS

map cc <leader>c<space>
map  # {v}! par 72<CR>
map  & {v}! par 72j<CR>
map  <F6> :setlocal spell! spelllang=en<CR>
map  <F12> :set invhls<CR>
cmap <C-g> <C-u><ESC>
command! -bang W w<bang>

"""""""""""""""""""" PLUGINS

let g:Powerline_symbols = 'fancy'
let g:CommandTMaxFiles=5000
let g:CommandTMaxHeight=12
map <C-o> :CommandT<CR>
let g:CommandTAcceptSelectionMap = '<CR>'
let g:CommandTCancelMap = '<C-g>'

let NERDChristmasTree = 1
let NERDTreeSortOrder = ['\/$', '\.js*', '\.cpp$', '\.h$', '*']
nmap <c-b> :NERDTreeToggle<cr>
nmap <C-n> <c-w><left><down><c-w><c-w>
nmap <C-p> <c-w><left><up><c-w><c-w>
nmap <C-o> <c-w><left><CR>

"""""""""""""""""""" FILES SPECIFIC
au BufRead mutt-*        set ft=mail
au BufRead mutt-*        set invhls
au BufNewFile *.html 0r ~/.vim/templates/html.txt
au BufRead,BufNewFile *.jsm setfiletype javascript
au BufRead,BufNewFile *.xul setfiletype xml
au filetype html,xml set listchars-=tab:>.

"""""""""""""""""""" CUSTOM FUNCTIONS

""" Toggle relative/absolute numbering
function! NumberToggle()
  if(&relativenumber == 1)
    set number
  else
    set relativenumber
  endif
endfunc

nnoremap <F10> :call NumberToggle()<cr>

""" FocusMode
function! ToggleFocusMode()
  if (&foldcolumn != 12)
    set laststatus=0
    set numberwidth=10
    set foldcolumn=12
    set noruler
    hi FoldColumn ctermbg=none
    hi LineNr ctermfg=0 ctermbg=none
    hi NonText ctermfg=0
  else
    set laststatus=2
    set numberwidth=4
    set foldcolumn=0
    set ruler
    execute 'colorscheme ' . g:colors_name
  endif
endfunc
nnoremap <F1> :call ToggleFocusMode()<cr>

" http://vimdoc.sourceforge.net/htmldoc/options.html

""""" TMUX """""
if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"          " allows cursor change in tmux mode
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"

    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"                                      " support true colors in tmux
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"                                      " see `:h xterm-true-color` for more info
else
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

""""" Plugins """""
source $HOME/.config/vim/plugin-config/vim-plug.vim
source $HOME/.config/vim/plugin-config/lightline.vim
source $HOME/.config/vim/plugin-config/nerdtree.vim

""""" COLORS """""
syntax enable                                                                   " enable syntax highlighting
set termguicolors                                                               " enable true colors in vim
set background=dark                                                             " adjust colors for dark backgrounds
let g:onedark_hide_endofbuffer=0                                                " don't hide end-of-buffer filler lines (~)
let g:onedark_termcolors=256                                                    " configure onedark for 256 color terminal

colorscheme onedark                                                             " select color scheme from $HOME/.vim/colors/

""""" Spaces & Tabs """""
set autoindent                                                                  " copies indent from current line when starting new line
set softtabstop=4   	                                                        " in edit mode, sets the number of spaces for a tab
set shiftwidth=4                                                                " number of space characters inserted for indentation
set expandtab       	                                                        " turns all tabs into spaces
filetype indent on                                                              " enables filetype detection
                                                                                " also loads filetype-specific indent files from ~/.vim/indent/{lang}.vim

""""" UI Config """""
set number                                                                      " show line numbers
set cursorline                                                                  " highlight current line
set mouse=a                                                                     " enable mouse support
set mousefocus                                                                  " focus window on mouse
set showcmd                                                                     " show command in bottom bar
set wildmenu                                                                    " visual autocomplete for command menu
set lazyredraw                                                                  " redraw only when we need to.
set showmatch                                                                   " highlight matching [{()}]
set laststatus=2                                                                " always display status line (0=never, 1=at least 2 windows, 2=always)
set noshowmode                                                                  " hide vim status line in favor of plugin status line

""""" Searching """""
set incsearch                                                                   " search as characters are entered
set hlsearch                                                                    " highlight matches

""""" Folding """""
set foldenable                                                                  " enable folding
set foldlevelstart=10                                                           " open most folds by default
set foldnestmax=10                                                              " 10 nested fold max
set foldmethod=indent                                                           " fold based on indent level

""""" Key Remap """""
let mapleader=","
nnoremap <leader><space> :nohlsearch<CR>	                                    " turn off search highlight. Maps to ,<space>
nnoremap <space> za							                                    " space open/closes folds
nnoremap <leader>h <C-W>h
nnoremap <leader>j <C-W>j
nnoremap <leader>k <C-W>k
nnoremap <leader>l <C-W>l

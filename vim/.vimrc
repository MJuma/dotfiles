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

""""" General """""
set nocompatible

""""" Plugins """""
source $HOME/.config/vim/plugin-config/vim-plug.vim
"source $HOME/.config/vim/plugin-config/onedark.vim
source $HOME/.config/vim/plugin-config/lightline.vim

""""" COLORS """""
syntax enable                                                                   " enable syntax highlighting
set termguicolors                                                               " enable true colors in vim
let g:onedark_hide_endofbuffer=0                                                " don't hide end-of-buffer filler lines (~)
let g:onedark_termcolors=256                                                    " configure onedark for 256 color terminal

colorscheme onedark                                                             " select color scheme from $HOME/.vim/colors/

""""" Spaces & Tabs """""
set tabstop=4       	                                                        " in normal mode, sets the number of spaces to convert a tab to
set softtabstop=4   	                                                        " in edit mode, sets the number of spaces for a tab
set expandtab       	                                                        " turns all tabs into spaces
set shiftwidth=2                        " Change the number of space characters inserted for indentation
set smartindent                         " Makes indenting smart
set autoindent                          " Good auto indent

""""" UI Config """""                                                       
set number                                                                      " show line numbers
set showcmd                                                                     " show command in bottom bar
set cursorline                                                                  " highlight current line
filetype indent on                                                              " enables filetype detection 
						                                                        " also loads filetype-specific indent files from ~/.vim/indent/{lang}.vim
set wildmenu                                                                    " visual autocomplete for command menu
set lazyredraw                                                                  " redraw only when we need to.
set showmatch                                                                   " highlight matching [{()}]
set laststatus=2                                                                " always display status line (0=never, 1=at least 2 windows, 2=always)
set noshowmode                                                                  " hide vim status line in favor of plugin status line
set noshowmode  " to get rid of thing like --INSERT--
set noshowcmd  " to get rid of display of last command
set shortmess+=F  " to get rid of the file name displayed in the command line bar
set background=dark                     " tell vim what the background color looks like

""""" Searching """""                                                       
set incsearch                                                                   " search as characters are entered
set hlsearch                                                                    " highlight matches

""""" Folding """""                                                     
set foldenable                                                                  " enable folding
set foldlevelstart=10                                                           " open most folds by default
set foldnestmax=10                                                              " 10 nested fold max
set foldmethod=indent                                                           " fold based on indent level

""""" Key Remap """""
nnoremap <leader><space> :nohlsearch<CR>	                                    " turn off search highlight. Maps to ,<space>
nnoremap <space> za							                                    " space open/closes folds

nnoremap <leader>n :NERDTreeFocus<CR>
nnoremap <C-t> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFind<CR>

" Exit Vim if NERDTree is the only window left.
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() |
    \ quit | endif

" nnoremap <C-p> :FZF<CR>
nnoremap <C-p> :Files<Cr>
nnoremap <C-g> :Rg<Cr>
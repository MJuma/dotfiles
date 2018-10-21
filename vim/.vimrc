""""" COLORS """""
syntax enable           " enable syntax processing
colorscheme darcula

""""" Spaces & Tabs """""
set tabstop=4       	" in normal mode, sets the number of spaces to convert a tab to
set softtabstop=4   	" in edit mode, sets the number of spaces for a tab
set expandtab       	" turns all tabs into spaces

""""" UI Config """""
set number              " show line numbers
set showcmd             " show command in bottom bar
set cursorline          " highlight current line
filetype indent on      " enables filetype detection 
						" also loads filetype-specific indent files from ~/.vim/indent/{lang}.vim
set wildmenu            " visual autocomplete for command menu
set lazyredraw          " redraw only when we need to.
set showmatch           " highlight matching [{()}]

""""" Searching """""
set incsearch           " search as characters are entered
set hlsearch            " highlight matches

""""" Folding """""
set foldenable          " enable folding
set foldlevelstart=10   " open most folds by default
set foldnestmax=10      " 10 nested fold max
set foldmethod=indent   " fold based on indent level

""""" TMUX """""
" allows cursor change in tmux mode
if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif


""""" Key Remap """""
nnoremap <leader><space> :nohlsearch<CR>	" turn off search highlight. Maps to ,<space>
nnoremap <space> za							" space open/closes folds

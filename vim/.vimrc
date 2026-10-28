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

""""" Leader """""
let mapleader=","                                                               " set before the plugin configs so their <leader> mappings use it

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

silent! colorscheme onedark                                                     " select color scheme from $HOME/.vim/colors/ (missing until PlugInstall finishes)

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

""""" Clipboard """""
" Send yanks to the terminal's clipboard with OSC 52, which also works over ssh and through tmux
function! s:Osc52Yank() abort
    if v:event.operator !=# 'y' || index(['', '"', '+', '*'], v:event.regname) < 0
        return
    endif
    if exists('*base64_encode') && exists('*str2blob')
        let l:lines = v:event.regtype ==# 'V' ? v:event.regcontents + [''] : v:event.regcontents
        let l:encoded = base64_encode(str2blob(l:lines))                        " str2blob joins the lines with newlines
    else
        let l:text = join(v:event.regcontents, "\n") . (v:event.regtype ==# 'V' ? "\n" : '')
        let l:encoded = substitute(system('base64', l:text), '\n', '', 'g')       " GNU base64 wraps lines
    endif
    if strlen(l:encoded) > 1000000                                              " tmux drops escape sequences over 1MiB
        echohl WarningMsg | echo 'Yank too large to copy to the clipboard' | echohl None
        return
    endif
    call echoraw("\e]52;c;" . l:encoded . "\x07")
endfunction

if exists('##TextYankPost') && exists('*echoraw') && !has('gui_running')
    augroup osc52_yank
        autocmd!
        autocmd TextYankPost * call s:Osc52Yank()
    augroup END
endif

""""" Folding """""
set foldenable                                                                  " enable folding
set foldlevelstart=10                                                           " open most folds by default
set foldnestmax=10                                                              " 10 nested fold max
set foldmethod=indent                                                           " fold based on indent level

""""" Key Remap """""
" turn off search highlight. Maps to ,<space>
nnoremap <leader><space> :nohlsearch<CR>
" space open/closes folds
nnoremap <space> za
nnoremap <leader>h <C-W>h
nnoremap <leader>j <C-W>j
nnoremap <leader>k <C-W>k
nnoremap <leader>l <C-W>l
" show leader mappings after a pause (loads vim-which-key on demand)
nnoremap <silent> <leader> :<C-u>WhichKey ','<CR>

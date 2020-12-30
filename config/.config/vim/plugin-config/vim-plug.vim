if empty(glob('~/.vim/autoload/plug.vim'))                                      " install vim-plug if doesn't exist
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs 
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')                                               " Specify a directory for plugins

Plug 'joshdick/onedark.vim'                                                     " OneDark theme
Plug 'sheerun/vim-polyglot'                                                     " Language packs
Plug 'itchyny/lightline.vim'                                                    " status line
Plug 'tpope/vim-fugitive'                                                       " git integration
Plug 'psliwka/vim-smoothie'                                                     " smooth scrolling
Plug 'preservim/nerdtree'                                                       " file system explorer
Plug 'junegunn/fzf'                                                             " fzf
Plug 'tpope/vim-commentary'                                                     " comment out code
Plug 'jiangmiao/auto-pairs'                                                     " auto add closing brackets and braces
Plug 'alvan/vim-closetag'                                                       " auto add closing HTML tabs
Plug 'neoclide/coc.nvim', {'branch': 'release'}                                 " intellisense
Plug 'yuki-ycino/fzf-preview.vim', { 'branch': 'release' }                      " fzf preview
Plug 'junegunn/gv.vim'                                                          " git commit browser
Plug 'rhysd/git-messenger.vim'                                                  " git line commit blame
Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }            " shows keymappings for vim
Plug 'wfxr/minimap.vim'                                                         " minimap
Plug 'justinmk/vim-sneak'                                                       " jump to a location by typing the characters there

call plug#end()                                                                 " Initialize plugin system

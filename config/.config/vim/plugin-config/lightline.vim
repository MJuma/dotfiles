let g:lightline = {
    \ 'colorscheme': 'onedark',
    \ 'active': {
    \     'left': [ 
    \          [ 'mode', 'paste' ],
    \          [ 'gitbranch', 'readonly', 'filename', 'modified' ] 
    \     ],
    \     'right': [
    \          [ 'lineinfo' ],
    \          [ 'percent' ],
    \          [ 'fileformat', 'fileencoding', 'filetype' ]
    \     ]
    \ },
    \ 'inactive': {
    \     'left': [ 
    \          [ 'filename' ]
    \     ],
    \     'right': [
    \          [ 'lineinfo' ],
    \          [ 'percent' ]
    \     ]
    \ },
    \ 'tabline': {
    \     'left': [ 
    \          [ 'tabs' ]
    \     ],
    \     'right': [
    \          [ 'close' ]
    \     ]
    \ },
    \ 'tab': {
    \     'active': [ 'tabnum', 'filename', 'modified' ],
    \     'inactive': [ 'tabnum', 'filename', 'modified' ]
    \ },
    \ 'component_function': {
    \     'gitbranch': 'FugitiveHead'   
    \ },
    \ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2" },                                                                                                                                                                                      
    \ 'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3" },
    \ }
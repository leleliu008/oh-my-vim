set nocompatible              " be iMproved
filetype off                  " required!

au BufNewFile,BufRead ~/.fishrc set filetype=fish

au BufNewFile,BufRead *.kt  set filetype=kotlin
au BufNewFile,BufRead *.kts set filetype=kotlin

au BufReadPost *.kt  setlocal filetype=kotlin
au BufReadPost *.kts setlocal filetype=kotlin

call plug#begin('~/.vim/bundle')

Plug 'ycm-core/YouCompleteMe'

"https://github.com/ervandew/supertab
"Plug 'ervandew/supertab'

"https://github.com/scrooloose/nerdtree
Plug 'scrooloose/nerdtree'

Plug 'ryanoasis/vim-devicons'

"https://github.com/Xuyuanp/nerdtree-git-plugin
"Plug 'Xuyuanp/nerdtree-git-plugin'

"https://github.com/godlygeek/tabular
Plug 'godlygeek/tabular'

"https://github.com/mattn/emmet-vim
Plug 'mattn/emmet-vim'

"https://github.com/mattn/emmet-vim
Plug 'dracula/vim'

"Plug 'udalov/kotlin-vim'
"Plug 'othree/html5.vim'

"https://github.com/tpope/vim-fugitive
Plug 'tpope/vim-fugitive'

"https://github.com/sheerun/vim-polyglot
Plug 'sheerun/vim-polyglot'

"https://github.com/artur-shaik/vim-javacomplete2
Plug 'artur-shaik/vim-javacomplete2'

"https://github.com/ekalinin/Dockerfile.vim
"Plug 'ekalinin/Dockerfile.vim'

"https://github.com/vim-airline/vim-airline
Plug 'vim-airline/vim-airline'

"https://github.com/iamcco/markdown-preview.vim
Plug 'iamcco/markdown-preview.vim'

"https://github.com/vim-ruby/vim-ruby/wiki/VimRubySupport
Plug 'vim-ruby/vim-ruby'

"https://github.com/dag/vim-fish
"Plug 'dag/vim-fish'

"https://github.com/majutsushi/tagbar
Plug 'majutsushi/tagbar'

"https://github.com/Yggdroot/indentLine
"Plug 'Yggdroot/indentLine'

"https://github.com/tmhedberg/SimpylFold
"Plug 'tmhedberg/SimpylFold'

"https://github.com/jiangmiao/auto-pairs
"Plug 'jiangmiao/auto-pairs'


call plug#end()

let g:mkdp_path_to_chrome = "open -a Google\\ Chrome"
let g:mkdp_browserfunc = 'MKDP_browserfunc_default'
let g:mkdp_auto_start = 1
let g:mkdp_auto_open = 1
let g:mkdp_auto_close = 1
let g:mkdp_refresh_slow = 0
let g:mkdp_command_for_global = 0
let g:mkdp_open_to_the_world = 0

let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ 'Ignored'   : '☒',
    \ "Unknown"   : "?"
    \ }

"vim-airline/vim-airline的配置
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_symbols.linenr                   = ''
let g:airline_symbols.maxlinenr                = ' '

let w:airline_skip_empty_sections              = 1
let g:airline_section_b                        = '%{FugitiveHead()}'
let g:airline_section_c                        = ''
let g:airline_section_x                        = '%{&filetype}'
let g:airline_section_warning                  = ''

let g:airline#extensions#tabline#enabled       = 1
let g:airline#extensions#tabline#fnamemod      = ':~'
let g:airline#extensions#tabline#fnamecollapse = 0

let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#branch#displayed_head_limit = 10

"taglist.vim的配置
let Tlist_Ctags_Cmd         = 'ctags'
let Tlist_Show_One_File     = 1       "不同时显示多个文件的tag，只显示当前文件的
let Tlist_WinWidt           = 28      "设置taglist的宽度
let Tlist_Exit_OnlyWindow   = 1       "如果taglist窗口是最后一个窗口，则退出vim
"let Tlist_Use_Right_Window = 1       "在右侧窗口中显示taglist窗口
"let Tlist_Use_Left_Windo   = 1       "在左侧窗口中显示taglist窗口

"Valloric/YouCompleteMe的配置
let g:ycm_server_keep_logfiles                = 1
let g:ycm_server_log_level                    = 'debug'
let g:ycm_cache_omnifunc                      = 1
let g:ycm_server_python_interpreter           = '/usr/local/bin/python'
let g:ycm_global_ycm_extra_conf               = '~/.ycm_extra_conf.py'
let g:ycm_collect_identifiers_from_tags_files = 1    " 开启 YCM 标签补全引擎
let g:ycm_min_num_of_chars_for_completion     = 1    " 从第一个键入字符就开始罗列匹配项
let g:ycm_seed_identifiers_with_syntax        = 1    " 语法关键字补全
let g:ycm_goto_buffer_command                 = 'horizontal-split' " 跳转打开上下分屏
let g:ycm_key_invoke_completion               = '<C-\>'
let g:ycm_semantic_triggers                   = {
    \'c,cpp,java,kotlin,groovy,dart,go,erlang,perl,python,ruby,shell,cs,lua,javascript,html,css': ['re!\w{2}']
\}
let g:ycm_language_server = [
    \{ 
    \   'name': 'kotlin',
    \   'filetypes': [ 'kotlin' ], 
    \   'cmdline': [ expand( '$HOME/.lsp/kotlin-language-server/server/build/install/server/bin/kotlin-language-server' ) ],
    \},
    \{
    \   'name': 'ruby',
    \   'cmdline': [ expand( '$HOME/.lsp/ruby-language-server/bin/solargraph' ), 'stdio' ],
    \   'filetypes': [ 'ruby' ],
    \},
    \{  'name': 'vim',
    \   'filetypes': [ 'vim' ],
    \   'cmdline': [ expand( '$HOME/.lsp/vim-language-server/node_modules/.bin/vim-language-server' ), '--stdio' ]
    \},
    \{  'name': 'docker',
    \   'filetypes': [ 'dockerfile' ], 
    \   'cmdline': [ expand( '$HOME/.lsp/dockerfile-language-server/node_modules/.bin/docker-langserver' ), '--stdio' ]
    \},
    \{  'name': 'yaml',
    \   'cmdline': [ 'node', expand( '$HOME/.lsp/yaml-language-server/node_modules/.bin/yaml-language-server' ), '--stdio' ],
    \   'filetypes': [ 'yaml' ],
    \},
    \{  'name': 'json',
    \   'cmdline': [ 'node', expand( '$HOME/.lsp/json-language-server/node_modules/.bin/vscode-json-languageserver' ), '--stdio' ],
    \   'filetypes': [ 'json' ],
    \},
    \{  'name': 'vue',
    \   'filetypes': [ 'vue' ], 
    \   'cmdline': [ expand( '$HOME/.lsp/vue-language-server/node_modules/.bin/vls' ) ]
    \}
\]
let g:syntastic_java_checkers = []
map <F2> :YcmCompleter GoToDefinition<CR>
map <F3> :YcmCompleter GoToDeclaration<CR>
map <F4> :YcmCompleter GoToDefinitionElseDeclaration<CR>


"mattn/emmet-vim的配置
let g:user_emmet_leader_key      = '<C-z>'
"let g:user_emmet_expandabbr_key = '<Tab>'
let g:user_emmet_mode            = 'a'
"Enable just for html/css
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall

let g:indentLine_enabled = 1

" 必须手动输入za来折叠（和取消折叠）
set foldmethod=indent                " 根据每行的缩进开启折叠
set foldlevel=99
" 使用空格键会是更好的选择,所以在你的配置文件中加上这一行命令吧：
nnoremap <space> za
" 希望看到折叠代码的文档字符串？
let g:SimpylFold_docstring_preview=1

filetype plugin indent on     " required!

syntax enable
syntax on

"设置支持256色
set t_Co=256

"设置主题
colorsche dracula

"设置背景颜色
set background=light

set ofu=syntaxcomplete#Complete

set ts=4      "ts是tabstop的缩写，设置TAB宽为4个空格
set expandtab
set number    "显示行号
set sm        "自动匹配} ] ) ,编程时用
set sw=4      "shiftwidth 右移一次4个字符
set encoding=UTF-8
set langmenu=en_US.UTF-8
language message en_US.UTF-8

"https://www.cnblogs.com/leisurelylicht/p/Mac-deVIM-zhongdelete-jian-shi-xiao-de-yuan-yin-he.html
set backspace=2

autocmd FileType java setlocal omnifunc=javacomplete#Complete

autocmd FileType ruby,eruby let g:rubycomplete_buffer_loading = 1
autocmd FileType ruby,eruby let g:rubycomplete_classes_in_global = 1
autocmd FileType ruby,eruby let g:rubycomplete_rails = 1

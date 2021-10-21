" vim: sts=4:sw=4:et
" File: .vimrc
" Author: robertking <superobertking@icloud.com>
" Date: 12/04/2019
" Last Modified Date: 06/20/2020 06:40:00
" Last Modified By: robertking <superobertking@icloud.com>

" Basic settings
syntax on
set mouse=a
set number relativenumber
set hidden
set ruler
set cursorline
set incsearch
set inccommand=nosplit
set autoread
set foldclose=all
set hlsearch
set showcmd
set ffs=unix
let mapleader = "\<space>"
set notimeout nottimeout
nmap <leader><C-c> <NOP>
xmap <leader><C-c> <NOP>

" set keymap=dvorak
func! ToggleDvorak()
    if &keymap == 'dvorak'
        set keymap=
    elseif &keymap == ''
        set keymap=dvorak
    endif
endfunction
" C-m is also carriage return
" nnoremap <silent> <C-m> :call ToggleDvorak()<CR>

set list
" Note the symbol tailing space: '∙' (UTF-8: e2 88 99) may be much larger
" than '·' (UTF-8: c2 b7) in some fonts.
" set listchars=tab:\ \ ,nbsp:¬,extends:»,precedes:«,trail:·
" set listchars=tab:\|\ ,nbsp:¬,extends:»,precedes:«,trail:·
set listchars=tab:\⎜\ ,nbsp:¬,extends:»,precedes:«,trail:·
" ⎜(LEFT PARENTHESIS EXTENSION, U+239C)
"    (looks more on the left in macOS character viewer)
" ⎢(LEFT SQUARE BRACKET EXTENSION, U+23A2)
" set listchars=tab:>-,nbsp:¬,extends:»,precedes:«,trail:·

set fileencodings=ucs-bom,utf-8,gbk,default,latin1

command! -nargs=* Wrap set wrap linebreak nolist
" set formatoptions=jatcroql
" set textwidth=80
set linebreak

nnoremap <leader>w :call ToggleWrapping()<CR>
function! ToggleWrapping()
  if &fo =~ 'a'
    set fo-=a
    echo "Text Wrapping Off"
  else
    set fo+=a
    echo "Text Wrapping On"
  endif
endfunction

" https://andrew.stwrt.ca/posts/project-specific-vimrc/
set exrc
" set nomodeline
set secure

" netrw
let g:netrw_banner = 0
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_liststyle = 3
let g:netrw_list_hide = netrw_gitignore#Hide()
let g:netrw_ftpextracmd = 'passive'
let g:netrw_ftp_cmd="ncftp -p"
" let g:netrw_ftp_cmd = "ftp -p"

""" Plugins
if has('nvim')
call plug#begin('~/.local/share/nvim/plugged')

" Vim
" Plug 'itchyny/lightline.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#show_tabs = 1
let g:airline#extensions#branch#enabled = 1
" Do not ignore `term://`
let g:airline#extensions#tabline#ignore_bufadd_pat =
  \ '!|defx|gundo|nerd_tree|startify|tagbar|undotree|vimfiler'

" Start screen
Plug 'mhinz/vim-startify'
let g:startify_session_persistence = 1
let g:startify_session_persistence = 1
let g:startify_bookmarks = [
    \ {'c': '~/.vimrc'},
    \ {'f': '~/.config/fish/config.fish'},
    \ ]

" Go to specific line&col. I'd love it be built-in.
Plug 'wsdjeg/vim-fetch'

Plug 'majutsushi/tagbar'
let g:tagbar_left=1
nnoremap <leader>t :TagbarToggle<CR>

" Tree file sidebar
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeToggle' }
set shell=bash
Plug 'tiagofumo/vim-nerdtree-syntax-highlight', { 'on': 'NERDTreeToggle' }
" Plug 'ryanoasis/vim-devicons'
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
nmap <C-n> :NERDTreeToggle<CR>

" LSP server
if has('nvim')
    Plug 'neovim/nvim-lspconfig'
    Plug 'nvim-lua/completion-nvim'
else
    Plug 'dense-analysis/ale'
    let g:ale_set_balloons = 1
    let g:ale_set_loclist = 0   " Wired settings
    " let g:airline#extensions#ale#enabled = 1
    let g:ale_completion_enabled = 1
    " let g:ale_floating_preview = 1
    " let g:ale_hover_to_preview = 1
    " let g:ale_keep_list_window_open = 1
endif

func! Cj()
    if len(filter(getwininfo(), 'v:val.quickfix && !v:val.loclist')) != 0
        " https://www.reddit.com/r/vim/comments/5ulthc/how_would_i_detect_whether_quickfix_window_is_open/
        " filter(range(1, winnr('$')), 'getwinvar(v:val, "&ft") == "qf"')
        " Also, do a wrapping
        " https://github.com/romainl/vim-qf/blob/master/autoload/qf/wrap.vim<Paste>
        try
            cnext
        catch /^Vim\%((\a\+)\)\=:E553/
            cfirst
        catch /^Vim\%((\a\+)\)\=:E\%(325\|776\|42\):/
        endtry
        " Also, remember there are `:cnf` and `:cpf` to jump to first of files.
    elseif &diff
        norm! ]c
    elseif &spell
        norm! ]s
        " Also, remember there are `z=`, `zg` and `zug` commands
    else
        " https://stackoverflow.com/a/18547013
        " It's essential to use the (remapping) :normal
        lua vim.lsp.diagnostic.goto_next({enable_popup=false})
        " exe "norm \<Plug>(ale_next_wrap)"
    endif
endfunction

func! Ck()
    if len(filter(getwininfo(), 'v:val.quickfix && !v:val.loclist')) != 0
        try
            cprevious
        catch /^Vim\%((\a\+)\)\=:E553/
            clast
        catch /^Vim\%((\a\+)\)\=:E\%(325\|776\|42\):/
        endtry
    elseif &diff
        norm! [c
    elseif &spell
        norm! [s
    else
        lua vim.lsp.diagnostic.goto_prev({enable_popup=false})
        " exe "norm \<Plug>(ale_previous_wrap)"
    endif
endfunction

nmap <silent> <C-j> :call Cj()<CR>
nmap <silent> <C-k> :call Ck()<CR>

if &diff
" Vim also built-in `do` and `dp`
omap <silent> dgr :diffget *REMOTE*<CR>
omap <silent> dgl :diffget *LOCAL*<CR>
omap <silent> dgb :diffget *BASE*<CR>
nmap <silent> dgr :diffget *REMOTE*<CR>
nmap <silent> dgl :diffget *LOCAL*<CR>
nmap <silent> dgb :diffget *BASE*<CR>
" If using nvim, run
" git config --global mergetool.vimdiff.path '/usr/local/bin/nvim'
" git config --global merge.tool 'vimdiff'
endif

" Git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Sublime-like minimap
" Plug 'wfxr/minimap.vim'
" let g:minimap_auto_start = 1
nnoremap <leader>km  :MinimapToggle<CR>

" Commenets
Plug 'scrooloose/nerdcommenter'
" nmap <M-_> <Plug>NERDComMinimalComment
" vmap <M-_> <Plug>NERDComMinimalComment<CR>gv
" imap <M-_> <C-o><Plug>NERDComMinimalComment
nnoremap <leader><space>  :call NERDComment(0, "toggle")<CR>
" nnoremap <C-n>            :call NERDComment(0, "toggle")<CR>
vnoremap <C-n>            :call NERDComment(0, "toggle")<CR>gv
" inoremap <C-n>            <C-o>:call NERDComment(0, "toggle")<CR>
let g:NERDSpaceDelims = 1

Plug 'vim-scripts/loremipsum'

Plug 'alpertuna/vim-header'
let g:header_field_author = 'yiweiyang'
let g:header_auto_add_header = 0
let g:header_field_author_email = 'yangyiwei2000@gmail.com'
let g:header_alignment = 0
let g:header_field_timestamp_format = '%m/%d/%Y %T'

" Auto closing
Plug 'jiangmiao/auto-pairs'
au FileType rust     let b:AutoPairs = AutoPairsDefine({'\w\zs<': '>'}) | call AutoPairsTryInit() | call AutoPairsInit()
let g:AutoPairsShortcutFastWrap = '<A-f>'
" <M-p> : Toggle Autopairs
" <M-b> : BackInsert

" Rename
Plug 'danro/rename.vim'

" TabNine
" Plug 'zxqfl/tabnine-vim', { 'for': ['rust', 'c', 'cpp', 'markdown'] }

" Rust
" Plug 'rust-lang/rust.vim', { 'for': 'rust' }
au BufRead,BufNewFile *.toml setfiletype cfg
" Plug 'racer-rust/vim-racer', { 'for': 'rust' }


" ALE settings begin
if !has('nvim')

nnoremap <silent> K :ALEHover<CR>
nnoremap <silent> gd :ALEGoToDefinition<CR>
nnoremap <silent> gr :ALEFindReferences<CR>

let g:ale_list_window_size = 5
let g:ale_close_preview_on_insert = 0
let g:ale_virtualtext_cursor = 1
let g:ale_linters = {'rust': ['rustc'], 'python': ['flake8'], 'c': ['clangd'], 'cpp': ['clangd'], 'json': ['jsonlint'], 'javascript': ['eslint'], 'ocaml': ['merlin']}
let g:ale_fixers = {'rust': ['rustfmt'], 'python': ['autopep8'], 'json': ['fixjson']}
let g:ale_fix_on_save = 1
let g:ale_rust_rustc_options = '-Z no-codegen --edition 2018'
" , 'c': ['clang'], 'cpp': ['clang']
" Must set specific version name if not using the the fault 'nightly'
" (since rls is not always availabe for nightly)
" or use '' to let rls choose by itself
" Changed by an PR
" let g:ale_rust_rls_toolchain = ''
let g:ale_rust_rustfmt_options = '--edition 2018'
let g:ale_rust_rls_config = {
      \   'rust': {
      \     'clippy_preference': 'on',
      \     'racer_completion': 'false'
      \   }
      \ }
if 1
    let g:ale_sign_error = '✖'
    let g:ale_sign_warning = '⚠'  " cannot seen via mosh
else
    " let g:ale_sign_error = 'x'
    let g:ale_sign_error = '✗'
    let g:ale_sign_warning = '!'
endif
" I wanted a red sign for error and a blue sign for warning. In the material
" theme we could use `Question` for blue.
hi link ALEErrorSign    Error
hi link ALEWarningSign  Question
hi link ALEVirtualTextError     Error
hi link ALEVirtualTextWarning   Question

endif  " ALE settings end

" Rust tags
" autocmd BufRead *.rs :setlocal tags=./rusty-tags.vi;/,$RUST_SRC_PATH/rusty-tags.vi
" autocmd BufWritePost *.rs :silent! exec "!rusty-tags vi --quiet --start-dir=" . expand('%:p:h') . "&" | redraw!

" Auto format
" Plug 'chiel92/vim-autoformat'
Plug 'rhysd/vim-clang-format', { 'for': ['c', 'cpp'] }
let g:clang_format#code_style = 'google'
let g:clang_format#style_options = {
            \ "AllowShortIfStatementsOnASingleLine" : "true",
            \ "AlwaysBreakTemplateDeclarations" : "true",
            \ "AccessModifierOffset" : -4,
            \ "Standard" : "C++17",
            \ "BreakBeforeBraces" : "Linux",
            \ "AlwaysBreakAfterDefinitionReturnType" : "false",
            \ "ColumnLimit" : 80,
            \ "IndentCaseLabels": "false",
            \ }
" autocmd FileType c,cpp ClangFormatAutoEnable

" Insert header guard for C/C++ header files
" Excerpt from https://github.com/ryanphuang/vimrc/blob/master/vimrc
function! s:insert_gates()
    let gatename = substitute(toupper(expand("%:t")), "\\.", "_", "g")
    execute "normal! i#ifndef __" . gatename . "__"
    execute "normal! o#define __" . gatename . "__"
    execute "normal! 3o"
    execute "normal! Go#endif /* __" . gatename . "__ */"
    normal! kk
endfunction
autocmd BufNewFile *.{h,hpp} call <SID>insert_gates()

" Clang
" Plug 'justmao945/vim-clang'
" let g:clang_c_options = '-std=gnu11'
" let g:clang_cpp_options = '-std=c++11 -stdlib=libc++'
" Plug 'Rip-Rip/clang_complete', { 'for': ['c', 'cpp'] }
" let g:clang_library_path='/Applications/Xcode.app/Contents/Frameworks/libclang.dylib'

" ISPC
Plug 'Twinklebear/ispc.vim', { 'for': ['ispc'] }

" Fish
Plug 'dag/vim-fish', { 'for': 'fish' }

" Change root to git working dir, excluding (default) Makefile
Plug 'airblade/vim-rooter'
let g:rooter_patterns = ['.git', '_darcs', '.hg', '.bzr', '.svn']

" Fuzzy finder
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'ojroques/nvim-lspfuzzy'
let g:fzf_colors = { 'border': ['fg', 'Label'] }
let g:fzf_tags_command = 'ctags -R --languages=c,c++'

" Files
map <leader>kp :Files<CR>
map <C-p> :GFiles<CR>
nmap <leader>b :Buffers<CR>
" Workaround to have this trailing space in command
nmap <leader>f :Rg  <BS>
xmap <leader>f y:Rg <C-R>=escape(@",'/\')<CR>
nmap <leader>m :Marks<CR>
nmap <leader>r :Tags<CR>
nmap <leader>kr :BTags<CR>

" Quick alignment
Plug 'junegunn/vim-easy-align'
xmap <leader>a <Plug>(EasyAlign)
nmap <leader>a <Plug>(EasyAlign)

" Saved for future Linux use
" 'junegunn/vim-emoji'

" deoplete
" if has('nvim')
"   Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" else
"   Plug 'Shougo/deoplete.nvim'
"   Plug 'roxma/nvim-yarp'
"   Plug 'roxma/vim-hug-neovim-rpc'
" endif

let g:deoplete#enable_at_startup = 1
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

" Plug 'sebastianmarkow/deoplete-rust' ", { 'for': 'rust' }

" let g:deoplete#sources#rust#racer_binary='/Users/vicoryang/.cargo/bin/racer'
let g:deoplete#sources#rust#show_duplicates=0
" set completeopt=longest,menuone


" " ncm2
" Plug 'ncm2/ncm2'
" Plug 'roxma/nvim-yarp'
" Plug 'ncm2/ncm2-bufword'
" Plug 'ncm2/ncm2-path'
" Plug 'ncm2/ncm2-racer'

" Highlight RGB color
Plug 'chrisbra/Colorizer', { 'for': ['css', 'html'], 'on': 'ColorToggle' }
" let g:colorizer_auto_color = 1
let g:colorizer_auto_filetype='css,html'
nnoremap <leader>c :ColorToggle<CR>

" Web dev
Plug 'mattn/emmet-vim'
let g:user_emmet_leader_key=','
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall

" Plug 'vim-scripts/AutoComplPop'

" Color Scheme
" kaicataldo's
let g:material_theme_style = 'default'
let g:material_terminal_italics = 1
" hzchirs's
" let g:material_style='palenight'

let g:airline_theme='material'

Plug 'kaicataldo/material.vim', { 'frozen': 1, 'commit': '5aabe47' }
" Plug 'hzchirs/vim-material'

" Fallback theme under mosh
" Plug 'liuchengxu/space-vim-dark'

" Workaround for nvim sudo
if has("nvim")
    Plug 'lambdalisue/suda.vim'
    let g:suda#prefix = 'suda://'
    " multiple protocols can be defined too
    let g:suda#prefix = ['suda://', 'sudo://', '_://']
    " let g:suda_smart_edit = 1
end

call plug#end()

" Deoplete
" call deoplete#custom#source('_',  'max_menu_width', 0)
" call deoplete#custom#source('_',  'max_abbr_width', 0)
" call deoplete#custom#source('_',  'max_info_width', 5)
" call deoplete#custom#source('_',  'max_kind_width', 0)

" Color Scheme
" colorscheme delek
" peachpuff
" morning
""" kaicataldo's material (seems to not support non-gui)
set background=dark
colorscheme material
""" hzchirs's material
" colorscheme vim-material
""" space-vim-dark
" colorscheme space-vim-dark
" hi Comment cterm=italic guifg=#5C6370 ctermfg=59

" Old terminal and old mosh does not support 24-bit  color (HEAD mosh already
" supports 24-bit color)
if 1
if (has("nvim"))
  "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif
if (has("termguicolors"))
  set termguicolors
  " set notermguicolors
endif
endif

set completeopt=menuone,noinsert,noselect

" LSP settings
if has('nvim')

" I wanted a red sign for error and a blue sign for warning. In the material
" theme we could use `Question` for blue.
hi link LspDiagnosticsDefaultError    Error
hi link LspDiagnosticsDefaultWarning  Question

lua << EOF
local nvim_lsp = require('lspconfig')
local nvim_complete = require('completion')
require('lspfuzzy').setup{}

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', '<C-w>d', '<C-w>v<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', '<leader>R', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', opts)
  -- buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  -- buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  -- buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  -- buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  -- buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  -- buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  -- buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<leader>K', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  -- buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  -- buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<leader>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  -- buf_set_keymap('n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)

  nvim_complete.on_attach()

end

-- Use a loop to conveniently call 'setup' on multiple servers and
-- map buffer local keybindings when the language server attaches
local servers = { 'clangd', 'rust_analyzer' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
end
nvim_lsp.ocamllsp.setup {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  },
  --root_dir = nvim_lsp.util.root_pattern("dune", "*.opam", "esy.json", "package.json", ".git")
}

-- Signs
local signs = { Error = "✖ ", Warning = "⚠ ", Hint = "i ", Information = "i " }
-- local signs = { Error = "✗ ", Warning = "! ", Hint = "i ", Information = "i " }

for type, icon in pairs(signs) do
  local hl = "LspDiagnosticsSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end
EOF

endif


" Color
" highlight Pmenu ctermbg=grey
" highlight PmenuSel ctermbg=grey

" Vim Split
set splitbelow
set splitright

" Settings for Rust
" let g:rustfmt_autosave = 1
" let g:racer_cmd = '/Users/victoryang/.cargo/bin/racer'
let g:racer_experimental_completer = 1
let g:racer_insert_paren = 1

" au FileType rust nmap gd <Plug>(rust-def)
" au FileType rust nmap gs <Plug>(rust-def-split)
" au FileType rust nmap gx <Plug>(rust-def-vertical)
" au FileType rust nmap <leader>gd <Plug>(rust-doc)


" Build
au Filetype *tex setfiletype tex
au FileType *tex nnoremap <A-b> :w<CR> :!pdflatex -halt-on-error -shell-escape %<CR>
" au FileType *tex nnoremap <A-b> :w<CR> :!bibtex report && pdflatex -halt-on-error -shell-escape %<CR>
" au FileType *tex nnoremap <A-b> :w<CR> :!xelatex -halt-on-error -shell-escape %<CR>
if !has('nvim')
au FileType *tex ALEDisable
endif
" Spell check
au FileType *tex,markdown,text,gitcommit setlocal spell spelllang=en_us,cjk
" text auto wrapping
" au FileType *tex set textwidth=80
" au FileType text set textwidth=80
let g:airline#extensions#wordcount#filetypes = ['asciidoc', 'help', 'mail', 'markdown', 'org', 'rst', 'tex', 'text', 'plaintex']

" Auto update `lastMod` for Hugo and keep correct position
func! UpdateLastMod()
    " Only when modified and not template
    if &modified && expand('%:t') != 'default.md'
        let save_cursor = getpos(".")
        exe '%s/^lastMod:.*$/lastMod: ' . strftime('%FT%T%z') . '/e'
        call setpos('.', save_cursor)
    endif
endfunction
au FileType markdown aut BufWritePre * call UpdateLastMod()

""" Key mappings

" Jump to start and end
" map H ^
" map L $

" inoremap <C-s> <Esc>:w<CR>
inoremap <C-s> <Esc>
nnoremap <C-s> :w<CR>

" Tabs
" inoremap <A-q>     <Esc>:bprevious<CR>
" inoremap <A-tab>   <Esc>:bnext<CR>
" nnoremap <A-q>     :bprevious<CR>
" nnoremap <A-tab>   :bnext<CR>
inoremap <A-q>     <Esc>:bprevious<CR>
inoremap <A-tab>   <Esc>:bnext<CR>
nnoremap <M-q>     :bprevious<CR>
nnoremap <M-tab>   :bnext<CR>
" Also, <C-6> is going to previous edited buffer
" Work around for iPadOS, DK why it send 'tab' instead of '\[tab'.
nnoremap <F11>     :bnext<CR>
nnoremap <silent> <M-w> :call CloseBuf()<CR>
" nnoremap <C-t>     :tabnew<CR>
" inoremap <c-s-tab> <Esc>:tabprevious<cr>
" inoremap <c-tab>   <Esc>:tabnext<cr>
nnoremap <S-Tab>   :tabprevious<CR>
nnoremap <C-Tab>   :tabnext<CR>
" Work around for iPadOS
nnoremap <F12>     :tabnext<CR>
nnoremap <S-q>     :tabclose<CR>
" inoremap <C-t>     <Esc>:tabnew<CR>

func! CloseBuf()
    if len(getbufinfo({'buflisted':1})) == 1
        bdelete
    else
        bprevious
        bdelete #
    endif
endfunction

" Terminal
tnoremap <Esc> <C-\><C-n>
if has('nvim')
tnoremap <M-q>   <C-\><C-n>:bprevious<CR>
tnoremap <M-Tab> <C-\><C-n>:bnext<CR>
else
tnoremap <C-w><C-w> <C-w>.
tnoremap <C-w><C-c> <NOP>
endif

" Identation
set autoindent
set tabstop=8
set softtabstop=4 shiftwidth=4 expandtab
" set softtabstop=8 shiftwidth=8 noexpandtab
au FileType java,json,html,javascript,tex,markdown,gitcommit set softtabstop=2 shiftwidth=2 expandtab
au FileType ocaml set softtabstop=2 shiftwidth=2 expandtab
" Also see `:retab` command
" To insert a real tab when 'expandtab' is on, use CTRL-V<Tab>.

" Delete
nnoremap <BS> h"_x
nnoremap <Del> "_x
xnoremap <BS> "_d
" xnoremap <leader>p "_dP

" Move lines
nnoremap <M-j> :m .+1<CR>==
nnoremap <M-k> :m .-2<CR>==
inoremap <M-j> <Esc>:m .+1<CR>==gi
inoremap <M-k> <Esc>:m .-2<CR>==gi
vnoremap <M-j> :m '>+1<CR>gv=gv
vnoremap <M-k> :m '<-2<CR>gv=gv

" Motion
" Ctrl+c as Esc
inoremap <C-c> <Esc>
vnoremap <C-c> <Esc>
onoremap <C-c> <Esc>
nnoremap <C-c> :noh<return>
" Exit search
" nnoremap <esc> :noh<return> " Causing some vim to have a `c` after starting
endif " Vim Plug, WT? why vim does not parse the above map correctly
" Hardmode
" inoremap <UP> <NOP>
" inoremap <DOWN> <NOP>
" inoremap <LEFT> <NOP>
" inoremap <RIGHT> <NOP>
" nnoremap <UP> <NOP>
" nnoremap <DOWN> <NOP>
" nnoremap <LEFT> <NOP>
" nnoremap <RIGHT> <NOP>
nnoremap <silent> j gj
nnoremap <silent> k gk
nnoremap <silent> 0 g0
nnoremap <silent> ^ g^
nnoremap <silent> $ g$
nnoremap <silent> gj j
nnoremap <silent> gk k
nnoremap <silent> g0 0
nnoremap <silent> g^ ^
nnoremap <silent> g$ $
set whichwrap+=<,>,[,],h,l

cnoremap <C-A> <Home>
cnoremap <C-B> <Left>
cnoremap <C-D> <Del>
cnoremap <C-E> <End>
cnoremap <C-F> <Right>
cnoremap <C-N> <Down>
cnoremap <C-P> <Up>
" cnoremap <Esc>b <S-Left>
" cnoremap <Esc>f <S-Right>
cnoremap <Esc><C-B> <S-Left>
cnoremap <Esc><C-F> <S-Right>

" Clipboard
" vnoremap <M-c> :w !pbcopy<CR><CR>
" * for PRIMARY (selection), + for CLIPBOARD (C-c/C-v), see *quotestar*
noremap <leader>y "+y
noremap <leader>p "+p
noremap <leader>Y "*y
noremap <leader>P "*p
autocmd InsertLeave * set nopaste

" Avoid ':q' directly when there are more buffers, because restarting session
" would be wasteful.
cnoremap <silent><expr> <CR>
    \ getcmdtype() == ":" && index(["q"], getcmdline()) >= 0
    \ && len(getbufinfo({'buflisted':1})) > 2 && winnr('$') == 1 && tabpagenr('$') == 1
    \ ? "<C-c>:echo 'Many buffers left! Use :qa.'<CR>" : "<CR>"

" Axis
highlight MatchParen term=underline cterm=underline ctermbg=NONE gui=underline guibg=NONE
if has('nvim')
set fcs=eob:\   " Do not show ~ for EOB in nvim. Note that it's a backslash whitespace.
endif
set colorcolumn=80
" highlight EndOfBuffer ctermfg=black ctermbg=black

" Goto last closed position
" Copied from default.vim
" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid, when inside an event handler
" (happens when dropping a file on gvim) and for a commit message (it's
" likely a different one than last time).
autocmd BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g`\""
  \ | endif

" Save views
" au BufWinLeave * if &filetype !=# '' | silent! mkview | endif
" au BufWinEnter * if &filetype !=# '' | silent! loadview | endif

" Auto remove trailing spaces and keep correct position
func! TrimWhiteSpace()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfunction
command! TrimWhiteSpace call TrimWhiteSpace()
" Also see `:retab` command

" https://vim.fandom.com/wiki/Search_for_visually_selected_text
" Search for selected text, forwards or backwards.
vnoremap // y/\V<C-R>=escape(@",'/\')<CR><CR>

nnoremap / /\v\c

" let &t_SI = "\e[6 q"
" let &t_EI = "\e[2 q"
" reset cursor on start:
" augroup ChangeCursor
" au!
" autocmd VimEnter * silent !fish -c 'echo -ne "\e[2 q"'
" Not working
" autocmd VimLeave * silent !fish -c 'echo -ne "\e[6 q"'
" augroup END

" try
  " source .vimrc
" catch
  " " No such file? No problem; just ignore it.
" endtry

inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

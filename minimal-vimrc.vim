"------------------------------------------------------------------------------
" QOL defaults
"------------------------------------------------------------------------------

set path+=**

" Nice menu when typing `:find *.py`
set wildmode=longest,list,full
set wildmenu
" Ignore files
set wildignore+=*.pyc
set wildignore+=*_build/*
set wildignore+=**/coverage/*
set wildignore+=**/node_modules/*
set wildignore+=**/android/*
set wildignore+=**/ios/*
set wildignore+=**/.git/*

syntax enable

set autoread
set encoding=utf-8

set backspace=indent,eol,start

" buffer opening orientation
set splitbelow
set splitright


" copy indent from current line when starting a new line
" see http://vim.wikia.com/wiki/Restoring_indent_after_typing_hash
" for a discussion of smartindent, cindent, autoindent
set smartindent
" see http://vimcasts.org/episodes/tabs-and-spaces/ for a great
" overview of tab options
" Width for tab characters present in a file being edited
set tabstop=4
" number of spaces to use for each step of (auto)indent. For <, >, etc.
set shiftwidth=4
" number of spaces that a <Tab> counts for when typing TAB, backspace, etc.
set softtabstop=4
" expand TAB keystroke to spaces.
set expandtab

" Minimal number of screen lines to keep above and below the cursor.
set scrolloff=10

" Show line numbers relative to the cursor, instead of absolute
set number relativenumber

" show the line and column number of the cursor position
set ruler

" Work on the whole line by default when substituting
set gdefault

" show search results as you type thate search pattern
set incsearch
" when a bracket is inserted, briefly jump to the matching one
set showmatch
" when there is a previous search pattern, highlight all its matches.
set hlsearch
" ignore case when searching with a pattern in all lower case
set ignorecase
" case sensitive search when upper case is used in the pattern
set smartcase

" indicates a fast terminal connection, improves smoothness of redrawing
set ttyfast

" set temp files directory
set directory=~/.tmp//,/tmp//
set undodir=~/.tmp//,/tmp//
set backupdir=~/.tmp//,/tmp//

" persistent undo history that survives closing the file
set undofile

" don't save backup/swap files
set nobackup
set nowb
set noswapfile

set colorcolumn=80

" set leader to space
let mapleader = " "

"------------------------------------------------------------------------------
" Basic remaps
"------------------------------------------------------------------------------

" clear search highlight
nnoremap <silent> <Esc> :nohlsearch<CR><Esc>

" Disable arrows in Normal, Visual, and Operator-pending modes
noremap <Up> <Nop>
noremap <Down> <Nop>
noremap <Left> <Nop>
noremap <Right> <Nop>

" split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Move visual selection
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

" greatest remap ever: paste over selection, retain last edit register
vnoremap <leader>p "_dP

" next greatest remap ever : asbjornHaland - os clipboard yank
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>Y gg"+yG

" delete into void register
nnoremap <leader>d "_d
vnoremap <leader>d "_d
" Run make with F5
nnoremap <F5> :make<CR>

"------------------------------------------------------------------------------
" Better QuickFix
"------------------------------------------------------------------------------

" Pin Quickfix window to the bottom
:autocmd FileType qf wincmd J

function! ToggleQuickFix()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
        copen
    else
        cclose
    endif
endfunction

nnoremap <silent> <leader>q :call ToggleQuickFix()<CR>

" Go to next/previous quickfix item
nnoremap qj :cnext<CR>zz
nnoremap qk :cprev<CR>zz

" Go to first/last quickfix item
nnoremap Qk :cfirst<CR>zz
nnoremap Qj :clast<CR>zz

" auto open quick fix on content
augroup QuickFixAutoOpen
autocmd!
autocmd QuickFixCmdPost [^l]* cwindow
autocmd QuickFixCmdPost l* lwindow
augroup END

"------------------------------------------------------------------------------
" Searching
"------------------------------------------------------------------------------

function! RunGrepCmd(cmd, query)
    if executable(a:cmd)
        " Execute ripgrep and capture output
        let l:grep_cmd = a:cmd . ' --vimgrep --smart-case ' . shellescape(a:query)
        let l:results = system(l:grep_cmd)

        " Populate the quickfix list with the results
        cgetexpr l:results
    else
        echo a:cmd . " executable not found"
    endif
endfunction

command! -nargs=+ Rg call RunGrepCmd('rg', <q-args>)
command! -nargs=+ Ag call RunGrepCmd('ag', <q-args>)

if executable('rg')
    set grepprg=rg\ --vimgrep\ --smart-case
    set grepformat=%f:%l:%c:%m
elseif executable('ag')
    " Use ag for grep
    set grepprg=ag\ --vimgrep
    set grepformat=%f:%l:%c:%m
endif

" use ws in visual mode to search word across files
vnoremap ws y:vimgrep "<c-r>"" %<CR>

"------------------------------------------------------------------------------
" Linting / Formatting
"------------------------------------------------------------------------------

if executable('jq')
    autocmd FileType json setlocal equalprg=jq\ .
endif

if executable('xmllint')
    autocmd FileType xml silent! %!xmllint --format --recover - 2>/dev/null
endif

if executable('eslint')
    augroup eslint_config
    autocmd!
    autocmd FileType javascript setlocal shortmess+=a
    autocmd FileType javascript setlocal makeprg=eslint\--fix\ --format\ compact\ %
    autocmd FileType javascript setlocal errorformat=%f:\ line\ %l\\,\ col\ %c\\,\ %m,%-G%.%#
augroup END

    autocmd BufWritePost *.js,*.jsx,*.ts,*.tsx make! | redraw!
    command EslintFixAll execute '!eslint\--fix\ --format\ compact\ %' | edit!
endif

function! FixIndent()
    " Replace tabs/spaces based on expandtab/softtabstop/tabstop
    retab
    " Reindent the whole file
    normal! gg=G
    endfunction

" Command to call FixIndent
command! FI call FixIndent()

augroup remove_whitespace
    autocmd!
    autocmd BufWritePre * %s/\s\+$//e
    autocmd BufWritePre * %s/\($\n\s*\)\+\%$//e
augroup END

"------------------------------------------------------------------------------
" Misc
"------------------------------------------------------------------------------

" save file as root
command W execute 'silent w !sudo tee % > /dev/null' | edit!
colorscheme desert

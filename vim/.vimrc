"------------------------------------------------------------------------------
" QOL defaults
"------------------------------------------------------------------------------

" set leader to space
let mapleader = " "

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

" line wrap is evil
set nowrap

" folding
set foldlevel=5
set foldmethod=indent

"------------------------------------------------------------------------------
" Indentation
"------------------------------------------------------------------------------

" Enable filetype detection, plugins, and indent scripts
filetype plugin indent on

set autoindent
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

" prevent conflicts
set nosmartindent
set nocindent

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

" Append next line onto current preserve cursor position
nnoremap J mzJ`z

" Better search hit navigation
nnoremap n nzzzv
nnoremap N Nzzzv


" 1/2 Page Up / Down
nnoremap <C-d> <C-d>zz
nnoremap <C-u> <C-u>zz

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
nnoremap <silent> <F5> :silent make! \| redraw!<CR>
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

nnoremap <silent> <leader>q <Cmd>call ToggleQuickFix()<CR>

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
    autocmd FileType xml setlocal equalprg=xmllint\ --recover\ --format\ -
endif

if executable('eslint')
    function! s:ESLintPopulateQuickfix(output)
        " Filter to only lines matching file:line:col: message
        let pattern = '^.\+:\d\+:\d\+:.\+$'
        let filtered = join(filter(split(a:output, "\n"), 'v:val =~ pattern'), "\n")

        " Populate quickfix with any remaining lint messages
        if empty(filtered)
            cclose
        else
            cgetexpr filtered
            copen
        endif
    endfunction

    function! ESLintMake() abort
        let output = system('eslint --format=unix ' . expand('%') . ' 2>/dev/null')

        if v:shell_error == 2
            echohl WarningMsg
            echom 'ESLint runtime error - no diagnostics loaded'
            echohl None
            return
        endif
        call s:ESLintPopulateQuickfix(output)
    endfunction

    function! ESLintFormat(lnum, count) abort
        let lines = getline(a:lnum, a:lnum + a:count - 1)
        let input = join(lines, "\n")

        let result = system('eslint --fix-dry-run --stdin --stdin-filename ' . expand('%') . ' 2>/dev/null', input)

        if v:shell_error == 2
            echohl WarningMsg
            echom 'ESLint runtime error - falling back to vim internal formatting'
            echohl None
            return 1  " tell vim to fall back to internal formatting
        endif

        let formatted = split(result, "\n", 1)
        call deletebufline('%', a:lnum, a:lnum + a:count - 1)
        call appendbufline('%', a:lnum - 1, formatted)
        return 0
    endfunction

    function! ESLintFix() abort
        let filepath = expand('%')

        " Save buffer to disk first so eslint --fix can read it
        write

        " Run eslint --fix, capture any output (warnings/errors)
        let output = system('eslint --fix --format=unix ' . filepath . ' 2>/dev/null')

        if v:shell_error == 2
            echohl WarningMsg
            echom 'ESLint runtime error — buffer unchanged'
            echohl None
            return
        endif

        " Reload buffer to reflect changes eslint --fix wrote to disk
        edit!
        call s:ESLintPopulateQuickfix(output)
    endfunction

    augroup javascript_lint
        autocmd!
        autocmd FileType javascript setlocal equalprg=
        autocmd FileType javascript setlocal formatexpr=ESLintFormat(v:lnum,v:count)
        autocmd FileType javascript setlocal errorformat=%f:%l:%c:\ %m
        autocmd FileType javascript nnoremap <buffer> <silent> <F5> :call ESLintMake()<CR>
    augroup END

    command! ESLintFix call ESLintFix()

endif

function! FixIndent()
    " Replace tabs/spaces based on expandtab/softtabstop/tabstop
    retab
    " Reindent the whole file
    normal! gg=G
    endfunction

" Command to call FixIndent
command! FI call FixIndent()

function! TrimTrailingSpaces()
    %s/\s\+$//e
endfunction

function! RemoveEmptyTrailingLines()
    %s/\($\n\s*\)\+\%$//e
endfunction

augroup remove_whitespace
    autocmd!
    autocmd BufWritePre * call TrimTrailingSpaces()
    autocmd BufWritePre * call RemoveEmptyTrailingLines()
augroup END

nnoremap <leader>ws <Cmd>call TrimTrailingSpaces() <Bar> call RemoveEmptyTrailingLines()<CR>

"------------------------------------------------------------------------------
" Register editor
"------------------------------------------------------------------------------

let g:regEd_BufferName = "__RegEditor__"

function! s:RegEdOpen(reg, new_win)
    let l:content = getreg(a:reg, 1, 1)
    if empty(l:content)
        echo 'Register ' . a:reg . ' is empty, nothing to edit.'
        return
    endif

    let split_win = a:new_win

    " If the current buffer is modified then open the scratch buffer in a new
    " window
    if !split_win && &modified
        let split_win = 1
    endif

    " Check whether the buffer is already created
    let bufnum = bufnr(g:regEd_BufferName)
    if bufnum == -1
        " open a new scratch buffer
        if split_win
            exe "new " . g:regEd_BufferName
        else
            exe "edit " . g:regEd_BufferName
        endif
    else
        " Buffer is already created. Check whether it is open
        " in one of the windows
        let winnum = bufwinnr(bufnum)
        if winnum != -1
            " Jump to the window which has the scratch buffer if we are not
            " already in that window
            if winnr() != winnum
                exe winnum . "wincmd w"
            endif
        else
            " Create a new buffer
            if split_win
                exe "split +buffer" . bufnum
            else
                exe "buffer " . bufnum
            endif
        endif
    endif
    let bufnum = bufnr(g:regEd_BufferName)
    if getbufvar(bufnum, "&mod")
        echo "Buffer is modified, showing previous value"
        return
    endif
    let g:regEd_CurrentReg = a:reg
    call deletebufline(bufnum, 1, '$')
    call setbufline(bufnum, 1, l:content)
endfunction

function! s:RegEdConfigBuffer()
    setlocal buftype=nofile
    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal buflisted
endfunction

function! s:RegEdSetRegister()
    let bufnum = bufnr(g:regEd_BufferName)
    let l:buffer_lines = getbufline(bufnum, 1, '$')
    let l:full_content = join(l:buffer_lines, "\n")
	let l:reg_mode = getregtype(g:regEd_CurrentReg)
    call setreg(g:regEd_CurrentReg, l:full_content, l:reg_mode)
endfunction

augroup RegEdit
    autocmd!
    autocmd BufLeave __RegEditor__  call s:RegEdSetRegister()
    autocmd BufNewFile __RegEditor__ call s:RegEdConfigBuffer()
augroup END

command! -nargs=1 RegEdit call s:RegEdOpen(<args>, 0)
command! -nargs=1 RegEditSplit call s:RegEdOpen(<args>, 1)

"------------------------------------------------------------------------------
" ListChars
"------------------------------------------------------------------------------

function! ShowStdListChars()
    setlocal listchars=tab:▸\ ,trail:·,extends:→
    setlocal list
endfunction

function! ShowAllListChars()
    setlocal listchars=tab:▸\ ,trail:·,extends:→,precedes:←,nbsp:×,eol:↲
    setlocal list
endfunction

function! HideListChars()
    setlocal nolist
endfunction

augroup ListChars
    autocmd!
    autocmd BufEnter * if &buftype == '' | call ShowStdListChars() | endif
augroup END

nnoremap <leader>lc <Cmd>call ShowStdListChars()<CR>
nnoremap <leader>LC <Cmd>call ShowAllListChars()<CR>
nnoremap <leader>ln <Cmd>call HideListChars()<CR>

"------------------------------------------------------------------------------
" Toggle Comments (emulate mini.comment plugin)
"------------------------------------------------------------------------------

function! ToggleComment() range
    if empty(&commentstring)
        echoerr "ToggleComment: 'commentstring' is empty for this filetype"
        return
    endif
    if &commentstring !~# '%s'
        echoerr "ToggleComment: 'commentstring' has no %s placeholder: " .. &commentstring
        return
    endif
    if a:firstline == 0 || a:lastline == 0
        echoerr "ToggleComment: empty range"
        return
    endif

    let l:before = escape(matchstr(&commentstring, '^.\{-}\ze%s'), '/\^$.*~[]')
    let l:after  = escape(matchstr(&commentstring, '%s\zs.*$'),    '/\^$.*~[]')
    let l:pattern = '^' .. l:before .. '.\{-}' .. l:after .. '$'

    " Decide intent from the first line in the range
    let l:first_line = getline(a:firstline)
    let l:should_uncomment = l:first_line =~# l:pattern

    for lnum in range(a:firstline, a:lastline)
        let line = getline(lnum)
        if l:should_uncomment
            if line =~# l:pattern
                let inner = matchstr(line, '^' .. l:before .. '\zs.\{-}\ze' .. l:after .. '$')
                call setline(lnum, inner)
            else
                echom "ToggleComment: line " .. lnum .. " does not match commentstring, skipping"
            endif
        else
            call setline(lnum, printf(&commentstring, line))
        endif
    endfor
endfunction

function! s:ToggleCommentOpfunc(type)
    execute "'[,']call ToggleComment()"
endfunction

" Normal mode: takes a motion/textobject (e.g. gcap, gcip, gc3j)
nnoremap <silent> gc :set operatorfunc=<SID>ToggleCommentOpfunc<CR>g@

" Visual mode: operates over the visual selection
xnoremap <silent> gc :call ToggleComment()<CR>

"------------------------------------------------------------------------------
" Misc
"------------------------------------------------------------------------------

" save file as root
command W execute 'silent w !sudo tee % > /dev/null' | edit!

" handy vimrc manipulation
nnoremap <leader>ve :edit $MYVIMRC<CR>
nnoremap <leader>vs :source $MYVIMRC<CR>

" set colorscheme
colorscheme desert

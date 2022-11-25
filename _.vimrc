" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

let mapleader=" "

set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'scrooloose/nerdtree'
"Bundle 'scrooloose/syntastic'
Bundle 'Valloric/YouCompleteMe'
Bundle 'tpope/vim-sleuth'
Bundle 'docunext/closetag.vim'
Bundle 'kevinw/pyflakes-vim'
Bundle 'majutsushi/tagbar'
Bundle 'jistr/vim-nerdtree-tabs'

filetype plugin indent on

set viminfo='50,\"5000,:1000,%,n~/.viminfo

set autoread
set autowrite
set autowriteall

" Write the file to disk (if needed) every 30 seconds.
" setting updatetime also changes how often a swapfile is written
set updatetime=30
au CursorHold * silent! update
au FocusLost  * silent! update

try
	set undodir=~/.vim_runtime/undodir
	set undofile
catch
endtry

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
endif
set history=1000	" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set incsearch		" do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

"runtime bundle/vim-pathogen/autoload/pathogen.vim
"call pathogen#infect()

au BufNewFile,BufRead *.of  set filetype=forth
au BufNewFile,BufRead *.fth set filetype=forth

"setlocal spell spelllang=en_us
let c_space_errors = 1

map <ESC><Right> <ESC>:tabnext<CR>
map <ESC><Left>  <ESC>:tabprev<CR>
map <M-Right> <ESC>:tabn<CR>
map <M-Left>  <ESC>:tabp<CR>

set tags=tags;/

map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

highlight RedundantSpaces ctermbg=red guibg=red
match RedundantSpaces /\s\+$\| \+\ze\t/

let g:easytags_updatetime_autodisable = 1

let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBufs = 1

set updatetime=4000

"noremap <C-TAB> <C-W>w
"noremap <C-S-TAB> <C-W>W

if has("cscope")
	set cscopetag cscopeverbose
	if has('quickfix')
		set cscopequickfix=s-,c-,d-,i-,t-,e-
	endif

	cnoreabbrev csa cs add
	cnoreabbrev csf cs find
	cnoreabbrev csk cs kill
	cnoreabbrev csr cs reset
	cnoreabbrev css cs show
	cnoreabbrev csh cs help

	set csto=0
	set cst
	set nocsverb
	" add any database in current directory
	if filereadable("cscope.out")
		cs add cscope.out
		" else add database pointed to by environment
	elseif $CSCOPE_DB != ""
		cs add $CSCOPE_DB
	endif
endif

if has("clang_complete")
	set completeopt = menu,menuone,longest
	set pumheight = 15
	"let g:clang_complete_auto = 0
	let g:clang_complete_copen = 1
endif

let g:NERDTreeIgnore=['\.[oda]$', '\~$']
let g:c_syntax_for_h = 1

set wildmode=longest:list
map <Leader>n <plug>NERDTreeTabsToggle<CR>

func! s:FTheader()
  if match(getline(1, min([line("$"), 200])), '^@\(interface\|end\|class\)') > -1
    setf objc
  elseif match(getline(1, min([line("$"), 200])), '^@\(namespace\|using\|<[^.]*>\|class\)') > -1
    setf cpp
  elseif exists("g:c_syntax_for_h")
    setf c
  elseif exists("g:ch_syntax_for_h")
    setf ch
  else
    setf cpp
  endif
endfunc

let g:ycm_global_ycm_extra_conf = '~/dotfiles/.ycm_extra_conf_2.py'
let g:ycm_extra_conf_globlist = [ '~/g/peerduct/*', '~/g/doirc/*', '~/g/items/*', '~/g/trashdrive/*', '~/g/fount/*', '~/g/trifles/*', '~/trifles/**', '~/g/ridl/*', '~/H/titan/*']

map <F1> <ESC>
imap <F1> <ESC>

" Append modeline after last line in buffer.
" Use substitute() instead of printf() to handle '%%s' modeline in LaTeX
" files.
function! AppendModeline()
  let l:modeline = printf(" vim: set ts=%d sw=%d tw=%d %set :",
        \ &tabstop, &shiftwidth, &textwidth, &expandtab ? '' : 'no')
  let l:modeline = substitute(&commentstring, "%s", l:modeline, "")
  call append(line("$"), l:modeline)
endfunction
nnoremap <silent> <Leader>ml :call AppendModeline()<CR>

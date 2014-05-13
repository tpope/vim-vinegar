" vinegar.vim - combine with netrw to create a delicious salad dressing
" Maintainer:   Tim Pope <http://tpo.pe/>

if exists("g:loaded_vinegar") || v:version < 700 || &cp
  finish
endif
let g:loaded_vinegar = 1

function! s:fnameescape(file) abort
  if exists('*fnameescape')
    return fnameescape(a:file)
  else
    return escape(a:file," \t\n*?[{`$\\%#'\"|!<")
  endif
endfunction

if !exists('g:vinegar_nerdtree')
  let g:vinegar_nerdtree = 0
endif

let s:dotfiles = '\(^\|\s\s\)\zs\.\S\+'

let g:netrw_sort_sequence = '[\/]$,*,\%(' . join(map(split(&suffixes, ','), 'escape(v:val, ".*$~")'), '\|') . '\)[*@]\=$'
let s:escape = 'substitute(escape(v:val, ".$~"), "*", ".*", "g")'
let g:netrw_list_hide =
      \ join(map(split(&wildignore, ','), '"^".' . s:escape . '. "$"'), ',') . ',^\.\.\=/\=$' .
      \ (get(g:, 'netrw_list_hide', '')[-strlen(s:dotfiles)-1:-1] ==# s:dotfiles ? ','.s:dotfiles : '')
let g:netrw_banner = 0
let s:netrw_up = ''

nnoremap <silent> <Plug>VinegarUp :call <SID>opendir('edit')<CR>
if empty(maparg('-', 'n'))
  nmap - <Plug>VinegarUp
endif

nnoremap <silent> <Plug>VinegarSplitUp :call <SID>opendir('split')<CR>
nnoremap <silent> <Plug>VinegarVerticalSplitUp :call <SID>opendir('vsplit')<CR>

function! s:opendir(cmd)
  if !g:vinegar_nerdtree
    let df = ','.s:dotfiles
    if expand('%:t')[0] ==# '.' && g:netrw_list_hide[-strlen(df):-1] ==# df
      let g:netrw_list_hide = g:netrw_list_hide[0 : -strlen(df)-1]
    endif
  endif
  if &filetype ==# 'netrw'
    let currdir = fnamemodify(b:netrw_curdir, ':t')
    execute s:netrw_up
    call s:seek(currdir)
  else
    if empty(expand('%'))
      execute a:cmd '.'
    else
      let currfile = expand('%:t')
      execute a:cmd '%:h'
      call s:seek(currfile)
    endif
  endif
endfunction

function! s:seek(file)
  let pattern = '^\s*'.escape(a:file, '.*[]~\').'[/*|@=]\=\%($\|\t\)'
  call search(pattern, 'wc')
  return pattern
endfunction

augroup vinegar
  autocmd!
  autocmd FileType netrw call s:setup_vinegar()
  autocmd FileType nerdtree call s:setup_vinegar()
augroup END

function! s:escaped(first, last) abort
  let files = getline(a:first, a:last)
  call filter(files, 'v:val !~# "^\" "')
  call map(files, 'substitute(v:val, "[/*|@=]\\=\\%(\\t.*\\)\\=$", "", "")')
  if g:vinegar_nerdtree
    let curdir = b:NERDTreeRoot.path.str()
  else
    let curdir = b:netrw_curdir
  endif
  return join(map(files, 'fnamemodify(curdir."/".v:val,":~:.")'), ' ')
endfunction

function! s:setup_vinegar() abort
  if g:vinegar_nerdtree
    exec 'nmap <buffer> -' g:NERDTreeMapUpdir
  else
    if empty(s:netrw_up)
      " save netrw mapping
      let s:netrw_up = maparg('-', 'n')
      " saved string is like this:
      " :exe "norm! 0"|call netrw#LocalBrowseCheck(<SNR>172_NetrwBrowseChgDir(1,'../'))<CR>
      " remove <CR> at the end (otherwise raises "E488: Trailing characters")
      let s:netrw_up = strpart(s:netrw_up, 0, strlen(s:netrw_up)-4)
    endif
    nmap <buffer> - <Plug>VinegarUp
    nnoremap <buffer> <silent> cg :exe 'keepjumps cd ' .<SID>fnameescape(b:netrw_curdir)<CR>
    nnoremap <buffer> <silent> cl :exe 'keepjumps lcd '.<SID>fnameescape(b:netrw_curdir)<CR>
    exe 'syn match netrwSuffixes =\%(\S\+ \)*\S\+\%('.join(map(split(&suffixes, ','), s:escape), '\|') . '\)[*@]\=\S\@!='
    hi def link netrwSuffixes SpecialKey
  endif
  nnoremap <buffer> ~ :edit ~/<CR>
  nnoremap <buffer> . :<C-U> <C-R>=<SID>escaped(line('.'), line('.') - 1 + v:count1)<CR><Home>
  xnoremap <buffer> . <Esc>: <C-R>=<SID>escaped(line("'<"), line("'>"))<CR><Home>
  nmap <buffer> ! .!
  xmap <buffer> ! .!
endfunction

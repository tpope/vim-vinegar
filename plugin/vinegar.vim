" vinegar.vim - combine with netrw to create a delicious salad dressing
" Maintainer:   Tim Pope <http://tpo.pe/>

if exists("g:loaded_vinegar") || v:version < 700 || &cp
  finish
endif
let g:loaded_vinegar = 1

if !exists("g:vinegar_ignore")
  let g:vinegar_ignore = ""
endif

function! s:fnameescape(file) abort
  if exists('*fnameescape')
    return fnameescape(a:file)
  else
    return escape(a:file," \t\n*?[{`$\\%#'\"|!<")
  endif
endfunction

let g:netrw_sort_sequence = '[\/]$,*,\%(' . join(map(split(&suffixes, ','), 'escape(v:val, ".*$~")'), '\|') . '\)[*@]\=$'
let s:escape = 'substitute(escape(v:val, ".$~"), "*", ".*", "g")'
let s:hide_list = split(&wildignore, ',') + split(g:vinegar_ignore, ',')
let g:netrw_list_hide = join(map(s:hide_list, '"^".' . s:escape . '. "$"'), ',') . ',^\.\.\=/\=$'
let g:netrw_banner = 0
let s:netrw_up = ''

nnoremap <silent> <Plug>VinegarUp :call <SID>opendir('edit')<CR>
if empty(maparg('-', 'n'))
  nmap - <Plug>VinegarUp
endif

nnoremap <silent> <Plug>VinegarSplitUp :call <SID>opendir('split')<CR>
nnoremap <silent> <Plug>VinegarVerticalSplitUp :call <SID>opendir('vsplit')<CR>

function! s:opendir(cmd)
  if &filetype ==# 'netrw'
    let currdir = fnamemodify(b:netrw_curdir, ':t')
    execute s:netrw_up
    call <SID>seek(currdir)
  else
    if empty(expand('%'))
      execute a:cmd '.'
    else
      execute a:cmd '%:h'
      call s:seek(expand('#:t'))
    endif
  endif
endfunction

function! s:seek(file)
  let pattern = '^'.escape(a:file, '.*[]~\').'[/*|@=]\=\%($\|\t\)'
  call search(pattern, 'wc')
  return pattern
endfunction

augroup vinegar
  autocmd!
  autocmd FileType netrw call s:setup_vinegar()
augroup END

function! s:escaped(first, last) abort
  let files = getline(a:first, a:last)
  call filter(files, 'v:val !~# "^\" "')
  call map(files, 'substitute(v:val, "[/*|@=]\\=\\%(\\t.*\\)\\=$", "", "")')
  return join(map(files, 'fnamemodify(b:netrw_curdir."/".v:val,":~:.")'), ' ')
endfunction

function! s:setup_vinegar() abort
  if empty(s:netrw_up)
    " save netrw mapping
    let s:netrw_up = maparg('-', 'n')
    " saved string is like this:
    " :exe "norm! 0"|call netrw#LocalBrowseCheck(<SNR>172_NetrwBrowseChgDir(1,'../'))<CR>
    " remove <CR> at the end (otherwise raises "E488: Trailing characters")
    let s:netrw_up = strpart(s:netrw_up, 0, strlen(s:netrw_up)-4)
  endif
  nmap <buffer> - <Plug>VinegarUp
  nnoremap <buffer> ~ :edit ~/<CR>
  nnoremap <buffer> . :<C-U> <C-R>=<SID>escaped(line('.'), line('.') - 1 + v:count1)<CR><Home>
  xnoremap <buffer> . <Esc>: <C-R>=<SID>escaped(line("'<"), line("'>"))<CR><Home>
  nmap <buffer> ! .!
  xmap <buffer> ! .!
  nnoremap <buffer> <silent> cd :exe 'keepjumps cd ' .<SID>fnameescape(b:netrw_curdir)<CR>
  nnoremap <buffer> <silent> cl :exe 'keepjumps lcd '.<SID>fnameescape(b:netrw_curdir)<CR>
  exe 'syn match netrwSuffixes =\%(\S\+ \)*\S\+\%('.join(map(split(&suffixes, ','), s:escape), '\|') . '\)[*@]\=\S\@!='
  hi def link netrwSuffixes SpecialKey
endfunction

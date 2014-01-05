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

let s:hide = ',\(^\|\s\s\)\zs\.\S\+'
let s:escape = 'substitute(escape(v:val, ".*$~"), "*", ".*", "g")'
let g:netrw_sort_sequence = '[\/]$,*,\%(' . join(map(split(&suffixes, ','), s:escape), '\|') . '\)[*@]\=$'
let g:netrw_list_hide = join(map(split(&wildignore, ','), '"^".' . s:escape . '. "$"'), ',') . ',^\.\.\=/\=$'
let g:netrw_banner = 0

nmap <silent> <unique> - :call <SID>VinegarUp()<CR>

function! s:VinegarUp()
  let l:oldpwd = exists('b:netrw_curdir') ? b:netrw_curdir : expand('%')
  let l:keepalt = (&filetype == 'netrw' || empty(expand('%'))) ? 'keepalt ' : ''
  execute l:keepalt .'edit '. fnameescape(fnamemodify(expand('%'), ':h'))
  let l:pattern = '^'.escape(fnamemodify(l:oldpwd, ':t'), '.*[]~\').'[/*|@=]\=\%($\|\t\)'
  call search(l:pattern, 'wc')
endfunction

function! s:VinegarDown()
  execute 'keepalt edit '. fnameescape(s:escaped(line('.'), line('.')))
endfunction

function s:SavePosn()
  if !exists('w:vinegar_lastpos')
    let w:vinegar_lastpos = {}
  endif
  if &filetype == 'netrw'
    let w:vinegar_lastpos[b:netrw_curdir] = netrw#NetrwSavePosn()
  endif
endfunction

function! s:RestorePosn()
  if &filetype == 'netrw' && exists('w:vinegar_lastpos') && has_key(w:vinegar_lastpos, b:netrw_curdir)
    keepj call netrw#NetrwRestorePosn(w:vinegar_lastpos[b:netrw_curdir])
  endif
endfunction

augroup vinegar
  autocmd!
  " XXX This gets triggered TWICE upon opening a buffer!
  autocmd FileType netrw call s:setup_vinegar()
augroup END

function! s:escaped(first, last) abort
  let files = getline(a:first, a:last)
  call filter(files, 'v:val !~# "^\" "')
  call map(files, 'substitute(v:val, "[/*|@=]\\=\\%(\\t.*\\)\\=$", "", "")')
  return join(map(files, 'fnamemodify(b:netrw_curdir."/".v:val,":~:.")'), ' ')
endfunction

function! s:setup_vinegar() abort
  augroup vinegar
    autocmd! BufLeave <buffer> call s:SavePosn()
    " Adding a ! here will prevent <CR> from restoring position.
    " Having the call to s:RestorePosn() here is better than in the <CR>
    " mapping, since it will work even if the buffer gets opened with :b
    autocmd BufEnter <buffer> call s:RestorePosn()
  augroup END
  nmap <buffer> <silent> <C-^> :keepalt edit #<CR>
  nmap <buffer> <silent> <C-O> :keepalt normal! <C-O><CR>:call <SID>RestorePosn()<CR>
  nmap <buffer> <silent> - :call <SID>VinegarUp()<CR>
  nmap <buffer> <silent> <CR> :call <SID>VinegarDown()<CR>
  nnoremap <buffer> ~ :keepalt edit ~/<CR>
  nnoremap <buffer> . :<C-U> <C-R>=<SID>escaped(line('.'), line('.') - 1 + v:count1)<CR><Home>
  xnoremap <buffer> . <Esc>: <C-R>=<SID>escaped(line("'<"), line("'>"))<CR><Home>
  nmap <buffer> ! .!
  xmap <buffer> ! .!
  nnoremap <buffer> <silent> cd :exe 'keepjumps cd ' .<SID>fnameescape(b:netrw_curdir)<CR>
  nnoremap <buffer> <silent> cl :exe 'keepjumps lcd '.<SID>fnameescape(b:netrw_curdir)<CR>
  exe 'syn match netrwSuffixes =\%(\S\+ \)*\S\+\%('.join(map(split(&suffixes, ','), s:escape), '\|') . '\)[*@]\=\S\@!='
  hi def link netrwSuffixes SpecialKey
endfunction

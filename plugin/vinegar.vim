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

nnoremap <silent> <Plug>VinegarUp :if empty(expand('%'))<Bar>edit .<Bar>else<Bar>edit %:h<Bar>call <SID>seek(expand('%:t'))<Bar>endif<CR>
if empty(maparg('-', 'n'))
  nmap - <Plug>VinegarUp
endif

function! s:seek(file)
  let pattern = '^'.escape(expand('#:t'), '.*[]~\').'[/*|@=]\=\%($\|\t\)'
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
  nmap <buffer> - <Plug>VinegarUp
  nnoremap <buffer> ~ :edit ~/<CR>
  nnoremap <buffer> . :<C-U> <C-R>=<SID>escaped(line('.'), line('.') - 1 + v:count1)<CR><Home>
  xnoremap <buffer> . <Esc>: <C-R>=<SID>escaped(line("'<"), line("'>"))<CR><Home>
  nmap <buffer> ! .!
  xmap <buffer> ! .!
  nnoremap <silent> cd :exe 'keepjumps cd ' .<SID>fnameescape(b:netrw_curdir)<CR>
  nnoremap <silent> cl :exe 'keepjumps lcd '.<SID>fnameescape(b:netrw_curdir)<CR>
  exe 'syn match netrwSuffixes =\%(\S\+ \)*\S\+\%('.join(map(split(&suffixes, ','), s:escape), '\|') . '\)[*@]\=\S\@!='
  hi def link netrwSuffixes SpecialKey
endfunction

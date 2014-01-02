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

function! s:seek()
  if !empty(w:dirstack)
    let l:tail = fnamemodify(substitute(w:dirstack[-1], "/$", "", ""), ':t')
    let pattern = '^'.escape(l:tail, '.*[]~\').'[/*|@=]\=\%($\|\t\)'
    call search(pattern, 'wc')
  endif
endfunction

function! s:VinegarUp()
  call s:pushd()
  if exists(':Rexplore')
    Rexplore
  else
    Explore
    call s:seek()
  endif
endfunction

function s:pushd()
  if !exists('w:dirstack')
    let w:dirstack = []
  endif
  if &filetype == 'netrw'
    call add(w:dirstack, b:netrw_curdir)
  elseif !empty(expand('%'))
    call add(w:dirstack, expand('%'))
  endif
endfunction

function! s:popd()
  if exists('w:dirstack') && !empty(w:dirstack)
    if w:dirstack[-1] == b:netrw_curdir
      call remove(w:dirstack, -1)
      if !empty(w:dirstack)
        call s:seek()
      endif
    else
      let w:dirstack = []
    endif
  endif
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
  if maparg('-', 'n') !~ 'pushd'
    execute 'nmap <buffer> <silent> - :call <SID>pushd()<Bar>'. substitute(escape(maparg('-', 'n'), '|'), '<CR>', '<Bar>call <SID>seek()<CR>', '')
  endif
  if maparg('<CR>', 'n') !~ 'popd'
    execute 'nmap <buffer> <silent> <CR> '. substitute(escape(maparg('<CR>', 'n'), '|'), '<CR>', '<Bar>call <SID>popd()<CR>', '')
  endif
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

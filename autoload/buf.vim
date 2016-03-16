" File: buffer.vim
" Author: romgrk
" Description: buffer utils
" Date: 10 Sep 2015
" !::exe [so %]

if !exists('s:map') | let s:map = {} | end
if !exists('g:BufferFilters') " {{{
    let g:BufferFilters = {
    \ 'listed': "v:val.listed()  == 1",
    \ 'term':   "v:val.type()    == 'terminal'",
    \ 'panel':  "v:val.ispanel() == 1",
    \}
end " }}}

augroup BufferTag
    au!
    au BufWinEnter * call buf#_tag(0+expand('<abuf>'))
augroup END

" Buffer class
fu! buf# (...) " {{{
    let num = s:num(a:000)

    if !bufexists(num)
        echoerr 'Buffer ' . num . ' does not exist; ' . string(a:000) | end

    if exists('s:map[l:num]')
        return s:map[num] | end

    let buffer = {}
    let buffer.nr = num
    call extend(buffer, deepcopy(s:Buffer))
    let s:map[num] = buffer
    return buffer
endfu " }}}

let s:Buffer = {}
fun! s:Buffer._ (...) dict " {{{
    if (a:0 == 1)
        call getbufvar(self.nr, a:1)
    else | call setbufvar(self.nr, a:1, a:2) | endif
endfu " }}}
fun! s:Buffer.name (...) dict " {{{
    if (a:0 == 0) | return bufname(self.nr)
    else          | call buf#cmd(self.nr, 'file ' . a:1)  | endif
endfu " }}}
fun! s:Buffer.ft (...) dict " {{{
    if (a:0 == 0) | return getbufvar(self.nr, '&ft')
    else          | call setbufvar(self.nr, '&ft', a:1) | endif
endfu " }}}
fun! s:Buffer.type (...) dict " {{{
    if (a:0 == 0) | return getbufvar(self.nr, '&buftype')
    else          | call setbufvar(self.nr, '&buftype', a:1) | endif
endfu " }}}
fun! s:Buffer.modified (...) dict " {{{
    if (a:0 == 0) | return getbufvar(self.nr, '&modified')
    else          | call setbufvar(self.nr, '&modified', a:1) | endif
endfu " }}}
fun! s:Buffer.modifiable (...) dict " {{{
    if (a:0 == 0) | return getbufvar(self.nr, '&modifiable')
    else          | call setbufvar(self.nr, '&modifiable', a:1) | endif
endfu " }}}
fun! s:Buffer.listed (...) dict " {{{
    if (a:0 == 0) | return getbufvar(self.nr, '&buflisted')
    else          | call setbufvar(self.nr, '&buflisted', a:1) | endif
endfu " }}}
fun! s:Buffer.visible () dict " 1: visible;  2: current buffer {{{
    return (bufwinnr(self.nr) != -1) + (bufwinnr(self.nr) == winnr())
endfu " }}}
fun! s:Buffer.hidden () dict " {{{
    return buf#hidden(self.nr)
endfu " }}}
fun! s:Buffer.winnr () dict " []: windows displaying buffer {{{
    return map(win#list('v:val.bufnr() == ' . self.nr), 'v:val.winnr')
endfu " }}}
fun! s:Buffer.win () dict " []: window displaying buffer {{{
    if bufwinnr(self.nr) != -1
        return win#(bufwinnr(self.nr))
    end
endfu " }}}
fun! s:Buffer.ext () dict " {{{
    return buf#ext(self.nr)
endfu " }}}
fun! s:Buffer.tail () dict " {{{
    return buf#tail(self.nr)
endfu " }}}
fun! s:Buffer.dir () dict " {{{
    return buf#dir(self.nr)
endfu " }}}
fun! s:Buffer.ispanel () dict " {{{
    return buf#ispanel(self.nr)
endfu " }}}
fun! s:Buffer.isfile () dict " {{{
    return buf#isfile(self.nr)
endfu " }}}

fu! s:Buffer.cmd (...) dict " {{{
    return buf#cmd(self.nr, a:000)
endfu " }}}
fu! s:Buffer.open (...) dict " {{{
    let win = win#( (a:0 == 0) ? a:1 : 0 )
    if (win.exists())
        call win.display(self.nr)
        "call win.focus()
    end
    return self
endfu " }}}
fu! s:Buffer.close (...) dict " {{{
    for winnr in self.winnr()
        let win = win#(winnr)
        call win.cmd('bnext')
        if (win.bufnr() == self.nr)
            call win.cmd('enew')
        end
    end
    call buf#delete(self.nr)
    return self
endfu " }}}
fu! s:Buffer.delete (...) dict " {{{
    call buf#delete(self.nr, get(a:, 1, 0) )
    return self
endfu " }}}

" Buffer info

fu! buf#ft (ref) " {{{
    return getbufvar(a:ref, '&ft')
endfu " }}}
fu! buf#type (ref) " {{{
    return getbufvar(a:ref, '&buftype')
endfu " }}}
fu! buf#modL (ref) " {{{
    return getbufvar(a:ref, '&modifiable')
endfu " }}}
fu! buf#modF (ref) " {{{
    return getbufvar(a:ref, '&modified')
endfu " }}}
fu! buf#listD (ref) " {{{
    return getbufvar(a:ref, '&buflisted')
endfu " }}}
fu! buf#visible (ref) " {{{
    return (bufwinnr(ref) != -1)
endfu " }}}
fu! buf#hidden (ref) " {{{
    return bufloaded(ref) & !buf#visible(ref)
endfu " }}}
fu! buf#activity (ref) " 0: none;      1: active       2: current {{{
    if type(a:ref) == type(1)
        let num = a:ref        | else
        let num = bufnr(a:ref) | end
    if bufnr('%') == num
        return 2 | endif
    if bufwinnr(num) != -1
        return 1 | endif
    return 0
endfu " }}}
fu! buf#tail (ref) " {{{
    if type(a:ref)==type(1)
        let num = a:ref        | else
        let num = bufnr(a:ref) | end
    return fnamemodify(bufname(num), ':t')
endfunc " }}}
fu! buf#ext (ref) " {{{
    if type(a:ref)==type(1)
        let num = a:ref        | else
        let num = bufnr(a:ref) | end
    return fnamemodify(bufname(num), ':e')
endfunc " }}}
fu! buf#dir (ref) " {{{
    if type(a:ref)==type(1)
        let num = a:ref        | else
        let num = bufnr(a:ref) | end
    return fnamemodify(bufname(num), ':p:h')
endfunc " }}}
fu! buf#ispanel (...) " {{{
    let num = s:num(a:000)
    if !bufexists(num) | return 0 | end
    let type = buf#type(num)
    if type=='nofile'   | return 1 | end
    if type=='nowrite'  | return 1 | end
    if type=='help'     | return 1 | end
    if type=='quickfix' | return 1 | end
    if type=='terminal' | return 1 | end
    let ft = buf#ft(num)
    if ft==?'gitcommit' | return 1 | end
    if ft==?'vimfiler'  | return 1 | end
    if ft==?'unite'     | return 1 | end
    let name = bufname(num)
    if name=~?'term://'   | return 1 | end
    if name=~?'vimfiler:' | return 1 | end
    if name=~?'NERD_'     | return 1 | end
    if name=~?'__Tagbar'  | return 1 | end
    if name=~?'__Gundo'   | return 1 | end
    if name=~?'unite'     | return 1 | end
    if name=~?'ControlP'  | return 1 | end
    return 0
endfu " }}}
fu! buf#isfile (...) " {{{
    let num = s:num(a:000)
    if !bufexists(num)  | return 0 | end
    if !buf#modL(num)   | return 0 | end
    if buf#ispanel(num) | return 0 | end
    "if !getbufvar(a:ref, '&buflisted') | return 0 | end
    return 1
endfu " }}}

fu! buf#_tag (nr) " {{{
    call setbufvar(a:nr, 'panel', buf#ispanel(a:nr))
endfu " }}}

" Buffer listing

fu! buf#first (...) " {{{
    let list = []
    for line in split(buf#ls_dump(1), "\n")
        call add(list, 0+matchstr(line, '\v\d+'))
    endfor
    let expr = a:1
    let expr = substitute(expr, '&\w\+', 'getbufvar(nr, "\0")', 'g')
    for nr in list
        if eval(expr)
            return nr | end
    endfor
    return -1
endfu " }}}
fu! buf#previous (...) " {{{
    return call('buf#sort', ['v:val < '] + a:000)
endfu " }}}
fu! buf#next (...) " {{{
    return call('buf#sort', ['v:val > '] + a:000)
endfu " }}}
fu! buf#sort (sortExpr, ...) " {{{
    let fun  = (type(a:1) == 3) ? 'buf#list' : 'buf#filter'
    let args = (type(a:1) == 3) ? a:1 : a:000
    if type(args[0])==0
        let current = args[0]
        let args    = args[1:]
    else
        let current = bufnr('%') | end
    let list = call(fun, args)
    if empty(list)  | return -1 | end
    if fun ==# 'buf#list'
        call map(list, 'v:val.nr') | end
    let first = list[0]
    if len(list)==1 | return first | end
    call filter(list, a:sortExpr . current)
    if empty(list)
        return first
    else
        return list[0] |end
endfu " }}}
fu! buf#list (...)  " {{{
    let list = []
    for line in split(buf#ls_dump(1), "\n")
        call add(list, buf#(0+matchstr(line, '\v\d+')))
    endfor
    for f in a:000
        if exists('g:BufferFilters["'.f.'"]')
            echo g:BufferFilters[f]
            call filter(list, g:BufferFilters[f])
        else
            echo f
            call filter(list, f)                  | endif
    endfor
    return list
endfunc " }}}
fu! buf#filter (...) " {{{
    let list = []
    for line in split(buf#ls_dump(1), "\n")
        call add(list, 0+matchstr(line, '\v\d+'))
    endfor
    for a_expr in a:000
        let expr = a_expr
        let expr = substitute(expr, '&\w\+', 'getbufvar(v:val, "\0")', 'g')
        call filter(list, expr)
    endfor
    return list
endfu " }}}
fu! buf#files ()  " buffer numbers, for listed files {{{
    let list = []
    for line in split(buf#ls_dump(), "\n")
        call add(list, (0+matchstr(line, '\v\d+')))
    endfor
    call filter(list, 'v:val!=0')
    call filter(list, 'buf#modL(v:val)')
    call filter(list, '!buf#ispanel(v:val)')
    return list
endfunc " }}}
fu! buf#ls_dump (...)  " {{{
    let dump = '' |redir=>dump
    silent! exe (a:0>0?'ls!':'ls') |redir END
    return dump
endfu " }}}

" Buffer manipulation

fu! buf#delete (...) " (ref, bang) {{{
    let nr = s:num(a:000)
    let bang = (a:0 > 1 && a:2) ? '!' : ''
    execute nr . 'bdelete' . bang
endfu " }}}
fu! buf#cmd (...) " {{{
    let num  = s:num(a:000)
    let saved_buffer = bufnr('%')
    let args = type(a:2)==3? a:2 : a:000[1:]
    let saved_ei = &eventignore
    set eventignore=all
    for cmd in args
        exe num . 'bufdo ' . cmd
    endfor
    exe 'b' . saved_buffer
    let &eventignore = saved_ei
endfu " }}}

" Helpers

fu! buf#scope ()
    return s:
endfu

" @returns the bufnr() from whatever data is fed to
"          it as parameter
func! s:num (arr) " {{{
    if empty(a:arr) || empty(a:arr[0])
        return bufnr('%') | end

    let ref = a:arr[0]
    let ref_t = type(ref)
    if _#isNumber(ref)
        return ref
    elseif _#isObject(ref)
        return ref['bufnr']()
    elseif _#isString(ref)
        return (ref =~# '^w\d\+$')
                    \? winbufnr(ref[1:])
                    \: ref
    end
    return bufnr(ref)
endfu " }}}

" call a:1 with (a:2 as arglist if present, [] otherwise)
fu! s:c (...) " {{{
    if (a:0==1) | return call(a:1, [])
    else        | return call(a:1, a:2) | end
endfunc "}}}
fu! s:f (...) " => get first element of func():List or -1 {{{
    if (a:0==1) | return get(call(a:1, []), 0, -1)
    else        | return get(call(a:1, a:2), 0, -1) | end
endfunc "}}}



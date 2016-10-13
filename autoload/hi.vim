" !::exe [so %]
" Author: romgrk
" Description: hightlight helpers
" Date: 07 Oct 2015
" this is the README:
" highlight autoload function very handy for scripting the syntax-hl

" hi#fg and hi#bg ('GoupName' [, color:String])
"   are both getter and setters
" hi#( name [, group:[] | fg [,bg [,attr ] ] ] )
"   can get/set or define your group without error

" a group-hl definition may be
" (name && ( 1, 2 or 4 arguments)) || (Array of (2, 3 or 4 arguments))
" where arguments are assumed to be (in order): gui-foreground-color, gui-background-color, attributes
" (no cterm handling)

" Useful trick example:
" <C-r>=hi#fg('Function')<CR>
" gives you the foreground color for group Function


" NOTE A {ref} argument means either the number:ID or the string:name
"       of the group. Either one is uniquely identifiable.


" hi#( name [, group:[] | fg [,bg [,attr ] ] ] )
"  - general getter/setter
function! hi# (...)
    if (a:0 == 1 && hi#exists(a:1))
        return hi#group(a:1)
    end

    let name = a:1
    let group = _#type(a:2)=='List' ? a:2 : a:000[1:]

    if hi#exists(name)
        return hi#set(name, group)
    else
        return hi#create(name, group)
    end
endfu

" Return the syntax-group ID
function! hi#ref (ref)
    return type(a:ref) ? hlID(a:ref) : a:ref
endfu
" (Alias) Return the syntax-group ID
function! hi#synID (ref)
    return hi#ref(a:ref)
endfu
" Return the highlight-group ID
function! hi#transID (ref)
    return synIDtrans(hi#ref(a:ref))
endfu
" (Alias) Return the highlight-group ID
function! hi#id (ref)
    return synIDtrans(hi#ref(a:ref))
endfu
" Returns the syntax-group name
function! hi#name (id)
    if (_#isString(a:id) && !(a:id =~ '^\d\+$'))
        return a:id
    end
    return synIDattr(a:id, 'name')
endfu


" Returns the displayed FG color
function! hi#fg (name, ...)
    if a:0
        exe 'hi ' . a:name . ' guifg=' . (len(a:1) ? a:1 : 'None')
    else
        let id = hi#ref(a:name)
        let fg = synIDattr(id, 'fg')
        let fg# = synIDattr(hi#id(a:name), 'fg#')
        if (fg# !=# fg && !empty(fg))
            return fg#
        else
            return fg
        end
    end
endfu
" Returns the displayed BG color
function! hi#bg (name, ...)
    if a:0
        exe 'hi ' . a:name . ' guibg=' . (len(a:1) ? a:1 : 'None')
    else
        let id = hi#ref(a:name)
        let bg = synIDattr(id, 'bg')
        let bg# = synIDattr(id, 'bg#')
        if (bg# !=# bg && !empty(bg))
            return bg#
        else
            return bg
        end
    end
endfu
" Returns the displayed special color
function! hi#sp (name, ...)
    if a:0
        exe 'hi ' . a:name . ' guisp=' . (len(a:1) ? a:1 : 'None')
    else
        let id = hi#ref(a:name)
        let sp = synIDattr(id, 'sp')
        let sp# = synIDattr(id, 'sp#')
        if (sp# !=# sp && !empty(sp))
            return sp#
        else
            return sp
        end
    end
endfu
" Returns the displayed attributes
function! hi#attr (ref, ...)
    if (a:0)
        call hi#setAttributes(a:ref, a:1)
    else
        return join(hi#getAttributes(a:ref), ',')
    end
endfu

function! hi#bold(ref, ...)
    let id = hi#ref(a:ref)
    if (!a:0)
        return synIDattr(id, 'bold') == 1
    end
    call hi#setAttribute(id, 'bold', a:1)
    return hi#(id)
endfunc
function! hi#italic(ref, ...)
    let id = hi#ref(a:ref)
    if (!a:0)
        return synIDattr(id, 'italic') == 1
    end
    call hi#setAttribute(id, 'italic', a:1)
    return hi#(id)
endfunc
function! hi#reverse(ref, ...)
    let id = hi#ref(a:ref)
    if (!a:0)
        return synIDattr(id, 'reverse') == 1
    end
    call hi#setAttribute(id, 'reverse', a:1)
    return hi#(id)
endfunc
function! hi#standout(ref, ...)
    let id = hi#ref(a:ref)
    if (!a:0)
        return synIDattr(id, 'standout') == 1
    end
    call hi#setAttribute(id, 'standout', a:1)
    return hi#(id)
endfunc
function! hi#underline(ref, ...)
    let id = hi#ref(a:ref)
    if (!a:0)
        return synIDattr(id, 'underline') == 1
    end
    call hi#setAttribute(id, 'underline', a:1)
    return hi#(id)
endfunc
function! hi#undercurl(ref, ...)
    let id = hi#ref(a:ref)
    if (!a:0)
        return synIDattr(id, 'undercurl') == 1
    end
    call hi#setAttribute(id, 'undercurl', a:1)
    return hi#(id)
endfunc

let s:attributes = [
        \ 'bold',
        \ 'italic',
        \ 'reverse',
        \ 'standout',
        \ 'underline',
        \ 'undercurl'] " 'inverse',

function! hi#hasAttribute (ref, attr)
    return synIDattr(hi#ref(a:ref), a:attr)
endfunc
function! hi#getAttributes (ref)
    let id = hi#ref(a:ref)
    let result = []
    for attr in s:attributes
        if synIDattr(id, attr)
            call add(result, attr)
        end
    endfor
    return result
endfunc
function! hi#setAttributes (ref, attr)
    let name = hi#name(a:ref)
    if empty(a:attr) || a:attr is? 'none'
        exe 'hi ' . name . ' gui=none'
    else
        exe 'hi ' . name . ' gui=' .
                    \ (_#isList(a:attr) ? join(a:attr, ',') : a:attr)
    end
    return hi#(a:ref)
endfunc
function! hi#addAttributes (ref, attr)
    let name = hi#name(a:ref)
    if a:attr is? 'none'
        exe 'hi ' . name . ' gui=none'
    else
        let list = hi#getAttributes(name)
        let list += _#isString(a:attr)
                    \ ? split(a:attr, ',')
                    \ : a:attr

        call sort(list)
        call uniq(list)

        if len(list) > 1
            call filter(list, 'v:val !=? "none"')
        end

        exe 'hi ' . name . ' gui=' .  join(list, ',')
    end
    return hi#(a:ref)
endfunc
function! hi#setAttribute (ref, attr, value)
    if (a:value)
        call hi#addAttributes(a:ref, [ a:attr ])
    else
        let list = hi#getAttributes(a:ref)
        call filter(list, 'v:val !=? a:attr')
        call hi#setAttributes(a:ref, list)
    end
    return hi#(a:ref)
endfunc

" hi#create( name, { [Group] | [fg[, bg[, attr[, sp]]]] } )
function! hi#create (name, ...)
    let name = a:name
    let group = a:0==1 ? a:1 : a:000
    let fg    = get(group, 0, '')
    let bg    = get(group, 1, '')
    let attr  = get(group, 2, '')
    let sp    = get(group, 3, '')
    let cmd = 'hi! ' . name .
        \(fg!='' ?   ' guifg=' . fg : '') .
        \(bg!='' ?   ' guibg=' . bg : '') .
        \(sp!='' ?   ' guisp=' . sp : '') .
        \(attr!='' ? ' gui='   . attr : '')
    exec cmd
    let id = hlID(name)
    return [fg, bg, attr, sp, id, name]
endfu

" hi#set ( name, { [Group] | [fg[, bg[, attr[, sp]]]] } )
function! hi#set (name, ...)
    let name = a:name
    let group = _#type(a:1)=='List' ? a:1 : a:000

    let fg    = get(group, 0, '')
    let bg    = get(group, 1, '')
    let attr  = get(group, 2, '')
    let sp    = get(group, 3, '')

    let cmd = 'hi! ' . name .
        \ (len(fg)    ? ' guifg=' . fg   : '') .
        \ (len(bg)    ? ' guibg=' . bg   : '') .
        \ (len(sp)    ? ' guisp=' . sp   : '') .
        \ (len(attr)  ? ' gui=' . attr   : '')

    try | silent exe cmd
    catch /.*/
        return []
    endtry

    let id = hlID(name)
    return [fg, bg, attr, id, name]
endfu

" (link, target)
function! hi#link (from, to)
    if !hi#exists(a:to)
        call hi#(a:to, '')
    end
    execute 'hi! link ' . a:from . ' ' . a:to
endfu
" (target, link)
function! hi#alias (name, as)
    call hi#link(a:as, a:name)
endfu


" Note find another name?
" takes a linked group as argument, and makes it «real»,
" aka.  defines it with the properties its current target
function! hi#fullfill (ref)
    let sid = hi#synID(a:ref)
    let tid = hi#transID(a:ref)

    if !hi#exists(tid)
        throw 'Highlight group for ' . a:ref . ':' . tid . ' doesn''t exist.'
    end

    let name = synIDattr(sid, 'name')
    let hl_data = hi#(tid)[0:4]

    return  hi#(name, hl_data)
endfu

function! hi#current ()
    return synIDattr(synstack(line('.'), col('.'))[-1], 'name')
endfunc

" @r: String-hlName or Number-hlID
" Returns:
"     0 -> doesnt exist
"     1 -> linked
"     2 -> set
" (and this is epic logic if you try to understand the calculation)
function! hi#exists (r)
    let id = type(a:r) ? hlID(a:r) : a:r
    let tID = synIDtrans(id)
    return !!(id * tID) + (tID == id)
endfu

" true if group is linked
function! hi#islink (name)
    let id = hlID(a:name)
    return synIDtrans(id) != id
endfu

" true if group is defined
function! hi#isdefined (name)
    if !hlexists(a:name) | return 0 | end
    return !hi#islink(a:name)
endfu

" returns [fg, bg, attr, sp, id, name]
function! hi#get (ref, ...)
    if _#type(a:ref) == 'String'
        let name = a:ref
        let id   = synIDtrans(hlID(name))
    elseif _#type(a:ref) == 'Number'
        let id   = a:ref
        let name = synIDattr(id, 'name')
    end
    if !empty(a:000)
        return synIDattr(id, a:1)
    end
    let fg   = synIDattr(id, 'fg#')
    let bg   = synIDattr(id, 'bg#')
    let sp   = synIDattr(id, 'sp#')
    let attr = synIDattr(id, 'attr')
    return [fg, bg, attr, sp, id, name]
endfu

" return [fg, bg, attr, id, name]
function! hi#group (...)
    " null group
    if !(a:0) | return [0, 0, 0, 0, 0] | end

    let ref = (a:0 == 1) ? a:1 : a:000
    let typ = _#type(ref)
    if typ == 'String'
        let name = ref
        let id   = synIDtrans(hlID(name))
    elseif typ == 'Number'
        let id   = ref
        let name = synIDattr(id, 'name')
    elseif typ == 'List'
        "return hi#fill(ref)
        return [
          \ get(ref,  0,  ''),
          \ get(ref,  1,  ''),
          \ get(ref,  2,  ''),
          \ get(ref,  3,  ''),
          \ get(ref,  4,  ''),  ]
    elseif typ == 'Dict'
        return [
          \ get(ref,  'fg',    ''),
          \ get(ref,  'bg',    ''),
          \ get(ref,  'attr',  ''),
          \ get(ref,  'sp',    ''),
          \ get(ref,  'id',     0),
          \ get(ref,  'name',  ''),  ]
    end
    let fg   = hi#fg(id)
    let bg   = hi#bg(id)
    let sp   = hi#sp(id)
    let attr = hi#attr(id)
    return [fg, bg, attr, sp, id, name]
endfu

function! hi#clear (name)
    let e = hi#exists(a:name)
    if !(e) | return | end
    if (e - 1)
        let cmd = 'hi! clear ' . a:name
    else
        let cmd = 'hi! def link ' . a:name . ' NONE'
    end
    silent! exe cmd
endfu

function! hi#fill (group, ...)
    let group   = hi#group(a:group)
    let default = (a:0 == 1) ? hi#group(a:1) : hi#group('Normal')
    if empty(default[0])
        let default[0] = hi#fg('Normal')
    end
    if empty(default[1])
        let default[1] = hi#bg('Normal')
    end
    for i in range(0, 2)
        if empty(group[i])
            let group[i] = default[i]
        end
    endfor
    return [
      \ get(group, 0, default[0]),
      \ get(group, 1, default[1]),
      \ get(group, 2, default[2]),
      \ get(group, 3,  0),
      \ get(group, 4, ''), ]
endfu

function! hi#compose (rule, ...)
    let r = a:rule
    if r == 'fg'       | let [fg, _,     _, _, _] = hi#group(a:1)
                         let [_,  bg, attr, _, _] = hi#group()
    elseif r == 'inv' || r == 'inverse'
                         let [bg, fg, attr, _, _] = hi#group(a:1)
    elseif r == 'fgbg' | let [fg, _,  attr, _, _] = hi#group(a:1)
                         let [_,  bg, _,    _, _] = hi#group(a:2)
    elseif r == 'fgfg' | let [fg, _,  attr, _, _] = hi#group(a:1)
                         let [bg, _,  _,    _, _] = hi#group(a:2)
    elseif r == 'bgfg' | let [_,  bg, _,    _, _] = hi#group(a:1)
                         let [fg, _,  attr, _, _] = hi#group(a:2)
    elseif r == 'bgbg' | let [_,  fg, _,    _, _] = hi#group(a:1)
                         let [_,  bg, attr, _, _] = hi#group(a:2)
    else               | return 0                 | end

    let group = [ fg, bg, attr, '']
    return group
endfu

" License: JSON
" @romgrk, np.

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


" hi#( name [, group:[] | fg [,bg [,attr ] ] ] )
"  - general getter/setter
fu! hi# (...)
    if (a:0 == 1)
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

fu! hi#id (name)
    return synIDtrans(hlID(a:name))
endfu

fu! hi#fg (name, ...)
    if a:0
        exe 'hi ' . a:name . ' guifg=' . (len(a:1) ? a:1 : 'None')
    else
        return synIDattr(hi#id(a:name), 'fg#') | end
endfu

fu! hi#bg (name, ...)
    if a:0
        exe 'hi ' . a:name . ' guibg=' . (len(a:1) ? a:1 : 'None')
    else
        return synIDattr(hi#id(a:name), 'bg#') | end
endfu

fu! hi#attr (name, ...)
    if a:0
        exe 'hi ' . a:name . ' gui=' . (len(a:1) ? a:1 : 'None')
    else
        return synIDattr(hi#id(a:name), 'attr') | end
endfu

fu! hi#name (id)
    return synIDattr(id, 'name')
endfu

" create        name, { [group] OR fg, bg, attr }
fu! hi#create (name, ...)
    let name = a:name
    let group = a:0==1 ? a:1 : a:000
    let fg    = get(group, 0, '')
    let bg    = get(group, 1, '')
    let attr  = get(group, 2, '')
    let cmd = 'hi! ' . name .
        \(fg!='' ?   ' guifg=' . fg : '') .
        \(bg!='' ?   ' guibg=' . bg : '') .
        \(attr!='' ? ' gui='   . attr : '')
    exe cmd
    let id = hlID(name)
    return [fg, bg, attr, id, name]
endfu

" overwrite     name, { [group] OR fg, bg, attr }
fu! hi#set (name, ...)
    let name = a:name
    let group = _#type(a:1)=='List' ? a:1 : a:000

    let fg    = get(group, 0, '')
    let bg    = get(group, 1, '')
    let attr  = get(group, 2, '')
    "let fg    = (fg==''   ? 'None' : fg   )
    "let bg    = (bg==''   ? 'None' : bg   )
    "let attr  = (attr=='' ? 'None' : attr )

    let cmd = 'hi ' . name .
        \ (len(fg)    ? ' guifg=' . fg   : '') .
        \ (len(bg)    ? ' guibg=' . bg   : '') .
        \ (len(attr)  ? ' gui=' . attr   : '')

    try | silent exe cmd
    catch /.*/
        echoerr v:exception
        echoerr name . ' ' . group
        echoerr cmd
        return | endtry

    let id = hlID(name)
    return [fg, bg, attr, id, name]
endfu

" Returns:
"     0 -> doesnt exist
"     1 -> linked
"     2 -> set
" (and this is epic logic if you try to understand the calculation)
fu! hi#exists (r)
    let id = type(a:r) ? hlID(a:r) : a:r
    let tID = synIDtrans(id)
    return !!(id * tID) + (tID == id)
endfu

" true if group is linked
fu! hi#islink (name)
    let id = hlID(a:name)
    return synIDtrans(id) != id
endfu

" true if group is defined
fu! hi#isdefined (name)
    if !hlexists(name) | return 0 | end
    return !hi#islink(name)
endfu

" returns [fg, bg, attr, id, name]
fu! hi#get (ref)
    if _#type(a:ref) == 'String'
        let name = a:ref
        let id   = synIDtrans(hlID(name))
    elseif _#type(a:ref) == 'Number'
        let id   = a:ref
        let name = synIDattr(id, 'name')
    end
    let fg   = synIDattr(id, 'fg#')
    let bg   = synIDattr(id, 'bg#')
    let attr = synIDattr(id, 'attr')
    return [fg, bg, attr, id, name]
endfu

" return [fg, bg, attr, id, name]
fu! hi#group (...)
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
          \ get(ref,  3,   0),
          \ get(ref,  4,  ''),  ]
    elseif typ == 'Dict'
        return [
          \ get(ref,  'fg',    ''),
          \ get(ref,  'bg',    ''),
          \ get(ref,  'attr',  ''),
          \ get(ref,  'id',     0),
          \ get(ref,  'name',  ''),  ]
    end
    let fg   = synIDattr(id, 'fg#')
    let bg   = synIDattr(id, 'bg#')
    let attr = synIDattr(id, 'attr')
    return [fg, bg, attr, id, name]
endfu

fu! hi#clear (name)
    let e = hi#exists(a:name)
    if !(e) | return | end
    if (e - 1)
        let cmd = 'hi! clear ' . a:name
    else
        let cmd = 'hi! def link ' . a:name . ' NONE'
    end
    silent! exe cmd
endfu

fu! hi#fill (group, ...)
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

fu! hi#compose (rule, ...)
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

    let group = [ fg, bg, attr, 0, 0 ]
    return group
endfu

" License: JSON
" @romgrk, np.

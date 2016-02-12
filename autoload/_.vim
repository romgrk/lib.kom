

let s:types = [0, 1, 2, 3, 4, 5]
let s:types[0] = 'Number'
let s:types[1] = 'String'
let s:types[2] = 'Function'
let s:types[3] = 'List'
let s:types[4] = 'Dict'
let s:types[5] = 'Float'

func! _#each (list, Fn)
    let cmd = ''
    if _#isFunc(a:Fn)
        let cmd = 'call a:Fn(l:val)'
    else
        let cmd = substitute(a:Fn, 'v:val', 'l:val', '')
    end
    for val in a:list
        execute cmd
    endfor
endfu
func! _#times (count, Fn)
    for idx in range(a:count)
        if _#isFunc(a:Fn)
            call a:Fn()
        elseif _#isString(a:Fn)
            execute a:Fn
        else | throw 'invalid argument Fn: ' . string(a:Fn) | end
    endfor
endfu

fu! _#type (obj)
    return s:types[type(a:obj)]
endfu
fu! _#typeof (obj)
    return s:types[type(a:obj)]
endfu
fu! _#isNumber (arg)
    return (type(a:arg)==0)
endfu
fu! _#isString (arg)
    return (type(a:arg)==1)
endfu
fu! _#isFunc (arg)
    return (type(a:arg)==2)
endfu
fu! _#isList (arg)
    return (type(a:arg)==3)
endfu
fu! _#isDict (arg)
    return (type(a:arg)==4)
endfu
fu! _#isFloat (arg)
    return (type(a:arg)==5)
endfu



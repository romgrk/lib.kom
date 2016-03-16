" !::exe [so %]

let s:types = [0, 1, 2, 3, 4, 5]
let s:types[0] = 'Number'
let s:types[1] = 'String'
let s:types[2] = 'Function'
let s:types[3] = 'List'
let s:types[4] = 'Dict'
let s:types[5] = 'Float'

" each call
func! _#each (iterable, Fn)
    if _#isDict(a:iterable)
        for key in keys(a:iterable)
            let val = get(a:iterable, key)
            call call(a:Fn, [key, val], a:iterable)
            unlet! val
        endfor
    else
        for key in range(len(a:iterable))
            let val = get(a:iterable, key)
            call call(a:Fn, [val])
            unlet! val
        endfor
    end
endfu

" each execute
fu! _#eachx (iterable, command)
    if _#isDict(a:iterable)
        let keys = keys(a:iterable)
    else
        let keys = range(len(a:iterable))
    end

    let command = substitute(a:command, 'v:\(val\|key\)', 'l:\1', 'g')

    for key in keys
        let val = get(a:iterable, key)
        "let g:res .= string([command, key, val]) . "\n"
        "call call(a:Fn, [key, val], a:iterable)
        execute command
        unlet! val
    endfor
endfu

func! _#times (count, Fn) abort
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
fu! _#isObject (arg) " alias
    return (type(a:arg)==4)
endfu
fu! _#isFloat (arg)
    return (type(a:arg)==5)
endfu



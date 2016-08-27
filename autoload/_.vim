" !::exe [so %]

let s:types = range(8)
let s:types[0] = 'Number'
let s:types[1] = 'String'
let s:types[2] = 'Function'
let s:types[3] = 'List'
let s:types[4] = 'Dict'
let s:types[5] = 'Float'
let s:types[6] = 'Boolean'
let s:types[7] = 'Null'

" function! _# (string, ...)
    " let string = _#isString(a:string)
                " \ ? a:string : string(a:string)
    " let q      = get(a:, 1, "'")
    " let escape = get(a:, 2, q)
    " return q . escape(string, q) . q
" endfunc

" @params prompt,       ...
"         [hi, prompt], ...
function! _#Input(...) " {{{
    let [hlgroup, prompt] = a:0 && _#isArray(a:1)
                \ ? [a:1[0], a:1[1]]
                \ : ['Question', a:1]

    if (prompt[-1:] =~# '\w')
        let prompt .= ' '
    end

    exec 'echohl ' . hlgroup

    call inputsave()
    let  input = call('input', [prompt] + a:000[1:2])
    call inputrestore()

    echohl None

    return input
endfu " }}}

function! _#Trim (...)
        if _#isEmpty(a:000)
        throw 'TypeError: no arguments'
    elseif (len(a:000) > 1)
        return map(copy(a:000), 'string#Trim(v:val)')
    elseif _#isString(a:1)
        return string#Trim(a:1)
    elseif _#isList(a:1)
        return string#Trim(join(a:1, "\n"))
    end
endfunc

"_#toObject ( {from} ) => Dict
function! _#toObject (from)

    if _#isDict(a:from)
        return a:from | end

    let o = {}

    for key in range(len(a:from))
        let o[key] = a:from[key]
    endfor

    return l:o
endfunc


" Functionnal:

" _#forEach ( {iterable}, {callback}[, ...{data} ])
function! _#forEach (iterable, Fn, ...)
        if _#isList(a:iterable)
        let keys = range(len(a:iterable))
    elseif _#isDict(a:iterable)
        let keys = keys(a:iterable)
    elseif _#isString(a:iterable)
        let keys = range(len(a:iterable))
    else
        throw 'TypeError: typeof(a:iterable) == "' . _#typeof(a:iterable) . '"'
    end

    let this = _#toObject(a:iterable)

    for key in keys
        let val = a:iterable[key]
        call call(a:Fn, [val, key] + a:000, this)
        unlet! val
    endfor
endfunc

" each .. call
function! _#each (iterable, Fn, ...)
    if _#isDict(a:iterable)
        for key in keys(a:iterable)
            let val = get(a:iterable, key)
            call call(a:Fn, [key, val] + a:000, a:iterable)
            unlet! val
        endfor
    elseif _#isList(a:iterable)
        for key in range(len(a:iterable))
            let val = get(a:iterable, key)
            call call(a:Fn, [val] + a:000)
            unlet! val
        endfor
    elseif _#isNumber(a:iterable)
        for n in range(a:iterable)
            let val = n
            call call(a:Fn, [val] + a:000)
            unlet! val
        endfor
    end
endfu

" each .. execute
function! _#eachx (iterable, command)
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

" _#times (count:Number, Fn:Function)
function! _#times (count, Fn)
    for idx in range(a:count)
        if _#isFunc(a:Fn)
            call a:Fn()
        elseif _#isString(a:Fn)
            execute a:Fn
        else | throw 'invalid argument Fn: ' . string(a:Fn) | end
    endfor
endfu

" _#repeat ( {count}, {fn} [, data:List] [, self:Dict] )
function! _#repeat (count, fn, ...)
    let d = {}
    let d.Fn = _#isFunc(a:fn) ? a:fn : function(a:fn)
    let data = (a:0 == 1) && _#isObject(a:1) ?
                \ v:null : a:1
    let this = get(a:, 2,
                \ _#isObject(get(a:, 1)) ? a:1 : d )

    "       ) -> [nc]
    "    [] ) -> []
    " 'str' ) -> ['str', nc]
    for nc in range(a:count)
        let args = _#isList(data) ? data :
                    \ _#isNull(data) ?
                        \ [nc] : [data, nc]
        call call(d.Fn, args , this)
    endfor
endfu

" _#reduce ( {list} )
function! _#reduce (v, ...)
    let memo = get(a:, 1, [])

    if _#isList(a:v)
        for i in range(len(a:v))
            call _#reduce(a:v[i], memo)
        endfor
    else
        let memo += [a:v]
    end
    return memo
endfunc


" Section: Type testing
fu! _#type (obj)
    return s:types[type(a:obj)]
endfu
fu! _#typeof (obj)
    return tolower(s:types[type(a:obj)])
endfu
fu! _#isInteger (arg)
    return (type(a:arg)==0)
endfu
fu! _#isNumber (arg)
    let t = type(a:arg)
    return (t==0 || t==5)
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
fu! _#isArray (arg)             " Alias
    return (type(a:arg)==3)
endfu
fu! _#isDict (arg)
    return (type(a:arg)==4)
endfu
fu! _#isObject (arg)            " Alias
    return (type(a:arg)==4)
endfu
fu! _#isFloat (arg)
    return (type(a:arg)==5)
endfu
fu! _#isBoolean (arg)
    return (type(a:arg)==6)
endfu
fu! _#isNull (arg)
    return (type(a:arg)==7)
endfu
fu! _#isEmpty (arg)
    return empty(a:arg)
endfu
fu! _#isFalse (arg)
    return !(a:arg)
endfu
fu! _#isTrue (arg)
    return !!(a:arg)
endfu



## lib.kom
> scripting tools

Scripting functions for syntax highlighthing and buffer/window management.
Also comes with `_.vim`, wich is the start of a kind-of adaptation of
`lodash`/`underscore` to `vimL`, that I will hopefully never have to complete.

Example: exchange buffers between current window and second window
```vim
let other = win#(2).buf()
call win#(2).open(buf#())
call win#().open(other)
```

## Buffer/window static functions

#### `buf#filter(...)` & `win#filter(...)`
 - take `...`, a variadic number of filter-expressions, where `v:val` is replaced
   by their winnr/bufnr, and `&flags` by their local values
 - return the filtered list of bufnr/winnr
Examples:
```vim
" Print all &buflisted buffers, where filetype is "vim" and
" that have a bufnr higher than 10.
echo buf#filter('&buflisted', '&ft=="vim"', 'v:val > 10')
" => [11, 20, 21]

" Print windows that contain a modified buffer
echo win#filter('&modified')
" => [1, 3]
```

#### `*#first(...)`, `*#previous(...)` & `*#next(...)`
 - take the same filter-expressions as `*#filter(...)`
 - return the first/previous/next matching bufnr/winnr
Example:
```vim
" If you have neovim and terminals:
com! PrevTerm execute 'buffer ' . buf#previous('&buftype == "terminal"')
com! NextTerm execute 'buffer ' . buf#next('&buftype == "terminal"')
```

#### Buffer & Window objects
> Object-oriented vimscript (this is absurd)

Get the object instances through `win#()` and `buf#()`.
No argument gets you the current instance.
You can specify the `number`, the `name` or the symbol(`"%"`, `"$"`, etc.)
Objects are cached. (`buf#(𝒙) == buf#(𝒙)` and `win#(𝒙) == win#(𝒙)`)
You can also select `'b' . bufnr` from `win#()` and `'w' . winnr` from `buf#()`.
```vim
let altBuffer = buf#('#')
let altWin    = win#('b#') " Might return null!

let secondWindow = win#(2)
let secondWindowBuffer = buf#('w2')
" buf#('w2')       == win#(2).buf()
" buf#('w2').win() == win#(2)

" buf#() == buf#('%') == buf#(0)
" win#() == win#('%') == win#(0)
```
`winnr()`s always keep updated to go like 1,2,3,etc. which means that
if you close window #1, then window #2 becomes window #1.
However, the “secondWindow” object will still point to the
same window. (black magic)

`win#().open(buf [, keepFocus])`:
```vim
" All three following calls have the same effect:
call win#(2).open(4)
call win#(2).open(buf#(4))
call win#(2).open(bufname(4))
" buffer #4 is opened in window #2
```

`win#().focus()`, `win#().blur()`, `win#().hasFocus()`:
```vim
if (!win#(1).hasFocus())
    call win#(1).focus()
else
    call win#(1).blur()
    " blur() attempts <C-W><C-P> first, <C-W>w second
end
```

`win#().cmd()`:
```vim
call win#(3).cmd('bprevious')
```

## Color

```vim

echo color#Darken('#599eff', '0.2')
" => #477ecc
echo color#HexToRGB('#599eff')
" => [89, 158, 255]
echo color#RGBtoHSL([89, 158, 255])
" => [0.59739, 1.0, 0.67451]

" Lighten/darken the color under the cursor (this is actually useful)
nnoremap <expr><M--> color#Test(expand('<cword>'))
            \? '"_ciw' . color#Darken(expand('<cword>')) . "\<Esc>"
            \: "\<Nop>"
nnoremap <expr><M-=> color#Test(expand('<cword>'))
            \? '"_ciw' . color#Lighten(expand('<cword>')) . "\<Esc>"
            \: "\<Nop>"

```

(if you find this useful, let me know, I might write more documentation)

### hi.vim - highlighting

`hi#fg` and `hi#bg ('GoupName' [, color:String])`
  are both getter and setters
`hi#( name [, group:[] | fg [,bg [,attr ] ] ] )`
  can get/set or define your group without error

a group-hl definition may be:
  (name && ( 1, 2 or 4 arguments)) || (Array of (2, 3 or 4 arguments))

where arguments are assumed to be (in order): gui-foreground-color, gui-background-color, attributes
(no cterm handling)

Useful trick example:

```vim
<C-r>=hi#fg('Function')<CR>
```

gives you the foreground color for group Function

```vim
fu! hi# (...)
fu! hi#fg (name, ...)
fu! hi#bg (name, ...)
" the rest:  check the source for more details
fu! hi#id (name)
fu! hi#attr (name, ...)
fu! hi#name (id)
fu! hi#create (name, ...)
fu! hi#set (name, ...)
fu! hi#exists (r)
fu! hi#islink (name)
fu! hi#isdefined (name)
fu! hi#get (ref)
fu! hi#group (...)
fu! hi#clear (name)
fu! hi#fill (group, ...)
fu! hi#compose (rule, ...)
```


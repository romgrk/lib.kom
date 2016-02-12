
## Scripting autoload functions

Very useful for setting syntax highlighthing, or buffer/window
related changes.

Also comes with `_.vim`, wich is the start of a kind-of adaptation of
`lodash`/`underscore` to `vimL`, that I will hopefully never have to 
complete.

undocumented:
 - _.vim
 - color.vim
 - buf.vim
 - win.vim

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

  `<C-r>=hi#fg('Function')<CR>`

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


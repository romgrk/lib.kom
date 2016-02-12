
" where    r,g,b ∈ [0, 255]

" RGB color format
let g:hexColorPattern = '\v(\x{2})(\x{2})(\x{2})'

" @params (r, g, b)
" @params ([r, g, b])
" @returns String           A RGB color
fu! color#RGBtoHex (...)
    let [r, g, b] = ( a:0==1 ? a:1 : a:000 )
    let num = printf('%02x', float2nr(r)) . ''
          \ . printf('%02x', float2nr(g)) . ''
          \ . printf('%02x', float2nr(b)) . ''
    return '#' . num
endfu

" @param {String|Number} color   The color to parse
fu! color#HexToRGB (color)
    if type(a:color) == type(5)
        let color = printf('%x', a:color)
    else
        let color = a:color | end

    let matches = matchlist(color, g:hexColorPattern)

    if len(matches) < 4
        echohl Error
        echom 'Couldnt parse ' . string(color) . ' ' .  string(matches)
        echohl None
        return | end

    let r = str2nr(matches[1], 16)
    let g = str2nr(matches[2], 16)
    let b = str2nr(matches[3], 16)

    return [r, g, b]
endfu


" Converts an HSL color value to RGB. Conversion formula
" adapted from http://en.wikipedia.org/wiki/HSL_color_space.
" Assumes h, s, and l are contained in the set [0, 1] and
" returns r, g, and b in the set [0, 255].
" @param   Number  h       The hue
" @param   Number  s       The saturation
" @param   Number  l       The lightness
" @returns Array           The RGB representation
fu! color#HSLtoRGB(...) " (h, s, l)
    let [h, s, l] = ( a:0==1 ? a:1 : a:000 )

    let r = str2float(0)
    let g = str2float(0)
    let b = str2float(0)

    if (s == 0.0) " achromatic
        let r = l
        let g = l
        let b = l
    else
        let q = l < 0.5 ? l * (1 + s) : l + s - l * s
        let p = 2 * l - q
        let r = color#Hue2RGB(p, q, h + 0.33333)
        let g = color#Hue2RGB(p, q, h)
        let b = color#Hue2RGB(p, q, h - 0.33333)
    end

    return [r * 255.0, g * 255.0, b * 255.0]
endfunc

fu! color#RGBtoHSL(...)
    let [r, g, b] = ( a:0==1 ? a:1 : a:000 )
    let max = max([r, g, b])
    let min = min([r, g, b])

    let r   = str2float(r)
    let g   = str2float(g)
    let b   = str2float(b)
    let max = str2float(max)
    let min = str2float(min)

    let max = max / 255
    let min = min / 255
    let r = r / 255
    let g = g / 255
    let b = b / 255
    let h = str2float(0)
    let s = str2float(0)
    let l = (max + min) / 2

    if (max == min)
        let h = 0   " achromatic
        let s = 0   " achromatic
    else
        let d = max - min
        let s = (l > 0.5 ? d / (2 - max - min)
                       \ : d / (max + min)     )
        if (max == r)
            let h = (g - b) / d + (g < b ? 6 : 0)
        end
        if (max == g)
            let h = (b - r) / d + 2
        end
        if (max == b)
            let h = (r - g) / d + 4
        end
        let h = h / 6
    end

    return [h, s, l]
endfunction

func! color#Hue2RGB(...) " (p, q, t)
    let [p, q, t] = ( a:0==1 ? a:1 : a:000 )

    if(t < 0) | let t += 1 | end
    if(t > 1) | let t -= 1 | end

    if(t < 1/6) | return (p + (q - p) * 6 * t)         | end
    if(t < 1/2) | return (q)                           | end
    if(t < 2/3) | return (p + (q - p) * (2/3 - t) * 6) | end
    return p
endfunc

" Composited functions:

fu! color#HexToHSL (color)
    let [r, g, b] = color#HexToRGB(a:color)
    return color#RGBtoHSL(r, g, b)
endfu

fu! color#HSLtoHex (...)
    let [h, s, l] = ( a:0==1 ? a:1 : a:000 )
    let [r, g, b] = color#HSLtoRGB(h, s, l)
    return color#RGBtoHex(r, g, b)
endfu

fu! color#lighten(color, ...)
    let amount = a:0 ? str2float(a:1) : 5.0

    if(amount < 1.0)
        let amount = 1.0 + amount
    else
        let amount = 1.0 + (amount / 100.0)
    end

    let rgb = color#HexToRGB(a:color)
    let rgb = map(rgb, 'v:val * amount')
    let rgb = map(rgb, 'v:val > 255.0 ? 255.0 : v:val')
    let rgb = map(rgb, 'float2nr(v:val)')
    let hex = color#RGBtoHex(rgb)
    return hex
endfu

fu! color#darken(color, ...)
    let amount = a:0 ? str2float(a:1) : 5.0

    if(amount < 1.0)
        let amount = 1.0 - amount
    else
        let amount = 1.0 - (amount / 100.0)
    end

    if(amount < 0.0)
        let amount = 0.0 | end


    let rgb = color#HexToRGB(a:color)
    let rgb = map(rgb, 'v:val * amount')
    let rgb = map(rgb, 'v:val > 255.0 ? 255.0 : v:val')
    let rgb = map(rgb, 'float2nr(v:val)')
    let hex = color#RGBtoHex(rgb)
    return hex
endfu


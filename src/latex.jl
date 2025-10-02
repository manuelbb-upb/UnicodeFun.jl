function print_modifier(io, mod, substring)
    if mod == "^"
        to_superscript(io, substring)
    elseif mod == "_"
        to_subscript(io, substring)
    elseif mod == "bb"
        to_blackboardbold(io, substring)
    elseif mod == "bf"
        to_boldface(io, substring)
    elseif mod == "it"
        to_italic(io, substring)
    elseif mod == "bfit"
        to_bolditalic(io, substring)
    elseif mod == "cal"
        to_caligraphic(io, substring)
    elseif mod == "frak"
        to_frakture(io, substring)
    elseif mod == "mono"
        to_mono(io, substring) # leave unmodified for now
    else
        _substring = try_sym_modifier(mod, substring) # we could also directly `io` and use `UCM.apply_style` instead of the `sym` commands in `try_sym_modifier`
        if isnothing(_substring)
            error("Modifier $mod not supported")
        end
        print(io, _substring)
    end
end

function try_sym_modifier(mod, substring)
    _substring = if mod == "symbf"
        symbf(substring)
    elseif mod == "symsf"
        symsf(substring)
    elseif mod=="symup"
        symup(substring)
    elseif mod=="symit"
        symit(substring)
    elseif mod=="symtt"
        symtt(substring)
    elseif mod=="symbb"
        symbb(substring)
    elseif mod=="symcal"
        symcal(substring)
    elseif mod=="symbfsf"
        symbfsf(substring)
    elseif mod=="symbfup"
        symbfup(substring)
    elseif mod=="symbfit"
        symbfit(substring)
    elseif mod=="symsfup"
        symsfup(substring)
    elseif mod=="symsfit"
        symsfit(substring)
    elseif mod=="symbbit"
        symbbit(substring)
    elseif mod=="symfrak"
        symfrak(substring)
    elseif mod=="symbfcal"
        symbfcal(substring)
    elseif mod=="symbfsfup"
        symbfsfup(substring)
    elseif mod=="symbffrak"
        symbffrak(substring)
    else
        nothing
    end
    return _substring
end

"""
Base findnext doesn't handle utf8 strings correctly
"""
function utf8_findnext(A::AbstractString, v::Char, idx::Integer)
    while true
        lastidx = idx
        elem_idx = iterate(A, idx)
        elem_idx === nothing && break
        elem, idx = elem_idx
        elem == v && return lastidx
    end
    0
end

function to_latex(text; normalize=false)
    io = IOBuffer()
    charidx = iterate(text)
    charidx === nothing && return ""
    char, idx = charidx
    started = true
    while true
        started || (charidx = iterate(text, idx))
        started = false
        charidx === nothing && break
        char, idx = charidx
        if char in ('^', '_', '\\')
            mod = string(char)
            if mod == "\\"
                ss = SubString(text, idx, lastindex(text))
                for mod_candidate in ("bb", "bfit", "bf", "it", "cal", "frak", "mono")  # `bfit` has to come before `bf`
                    if startswith(ss, mod_candidate)
                        mod = mod_candidate
                        break
                    end
                end
                for mod_candidate in ucm_modifiers
                    if startswith(ss, mod_candidate)
                        mod = mod_candidate
                        break
                    end
                end
                if mod == "\\" # no match was found
                    # is this a latex symbol?
                    for (k, v) in latex_symbol_map
                        if startswith(ss, k)
                            print(io, v) # replace
                            for i in 1:length(k) # move forward
                                idx = nextind(text, idx)
                            end
                            break
                        end
                    end
                    continue # ignore '\' mod
                else
                    for i in 1:length(mod) # move forward
                        idx = nextind(text, idx)
                    end
                end
            end
            char, idx = iterate(text, idx)
            if char == '{'
                i = utf8_findnext(text, '}', idx)
                if i == 0
                    error("Invalid latex. Couldn't find matching } in $(text[idx:end])")
                end
                print_modifier(io, mod, SubString(text, idx, prevind(text, i)))
                char, idx = iterate(text, i)
            else
                print_modifier(io, mod, char)
            end
        else
            if normalize
                print(io, UCM._sym(char))
            else
                print(io, char)
            end
        end
    end
    return String(take!(io))
end

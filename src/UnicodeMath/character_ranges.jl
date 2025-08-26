# This file takes inspiration from source file `um-code-usv.dtx`
# of the UNICODE-MATH package  <wspr.io/unicode-math>
# by
# Copyright 2006-2019  Will Robertson, LPPL "maintainer"
# Copyright 2010-2017  Philipp Stephani
# Copyright 2011-2017  Joseph Wright
# Copyright 2012-2015  Khaled Hosny

# The contents of this file are licensed accordingly:
#
# Copyright 2025 M. Berkemeier
#
# The contents of this file may be distributed and/or modified under the
# conditions of the LaTeX Project Public License, either version 1.3
# of this license or (at your option) any later version.
#  The latest version of this license is in
#   https://www.latex-project.org/lppl.txt
# and version 1.3c or later is part of all distributions of LaTeX
# version 2008 or later.

# We generate two "tables" in here:
#
# `const chars_by_range_style_name = all_chars()`
# `const chars_to_ucmchars = inverse_char_dict(chars_by_range_style_name)`
#
# `chars_by_range_style_name` is a dict-of-dict-of-dict (?)
# * char_range (:Greek, :greek, :Latin, …)
#   =>  style (:up, :bfup, …) 
#     => name ("a", "Gamma", "1", … )
#        => ucm_ch::UCMChar
#
# `chars_to_ucmchars` is an inverse look-up dict, mapping 
# Chars to UCMChars, if they are defined in `chars_by_range_style_name`. 


mutable struct UCMChar
    name :: String
    char :: Char
    char_range :: Symbol
    latex_cmd :: String
    style :: Symbol
end

function Base.show(io::IO, ucmchar::UCMChar)
    print(io, "UCMChar('$(ucmchar.char)')")
end

const cmd_prefixes = Base.ImmutableDict(
    :up => "",
    :it => "mit",
    :bfup => "mbf",
    :bfit => "mbfit",
    :sfup => "msans",
    :sfit => "mitsans",
    :bfsfup => "mbfit",
    :bfsfit => "mbfitsans",
    :cal => "mscr",
    :bfcal => "mbfscr",
    :bb => "Bbb",
    :frak => "mfrak",
    :bffrak => "mbffrak",
    :tt => "mtt"
)

function UCMChar(; name, char, char_range, style)
    global cmd_prefixes
    name = string(name)
    if style == :up && (char_range == :Latin || char_range == :latin || char_range == :num)
        latex_cmd = name
    else
        suffix = if char_range == :num 
            if name == "0"
                "zero"
            elseif name == "1"
                "one"
            elseif name == "2"
                "two"
            elseif name == "3"
                "three"
            elseif name == "4"
                "four"
            elseif name == "5"
                "five"
            elseif name == "6"
                "six"
            elseif name == "7"
                "seven"
            elseif name == "8"
                "eight"
            elseif name == "9"
                "nine"
            else
                "UnknownNumber"
            end
        else
            name
        end
        latex_prefix = get(cmd_prefixes, style, "")
        latex_cmd = "\\$(latex_prefix)$(suffix)"
    end
    return UCMChar(
        name, char, char_range, latex_cmd, style
    )
end

_cap(n) = startswith(n, "var") ? "var" * uppercasefirst(n[4:end]) : uppercasefirst(n)
_decap(n) = startswith(n, "var") ? "var" * lowercasefirst(n[4:end]) : lowercasefirst(n)

function collect_chars(
    range_symb,
    char_names,
    usv_dict,
    extras_dict=Dict(),
    fixes=Dict{Char,Char}()
)
    chars_dict = SpecialDict{Symbol, SpecialDict}()

    for (sn, cp) in pairs(usv_dict)
        dict_sn = SpecialDict(
            n => let ch = Char(cp + i - 1);
                UCMChar(
                    name=n, char=get(fixes, ch, ch), style=sn, char_range=range_symb) 
            end for (i, n) = enumerate(char_names) 
        )
        chars_dict[sn] = dict_sn
        !haskey(extras_dict, sn) && continue
    
        extras = extras_dict[sn]

        for (n, cp) in extras
            if haskey(dict_sn, n)
                dict_sn[n].char = Char(cp)
            else
                dict_sn[n] = UCMChar(;
                    name=n, char=Char(cp), style=sn, char_range=range_symb)
            end
        end


    end
    return chars_dict
end

#%%
const names_Greek = (
    "Alpha", "Beta", "Gamma", "Delta", "Epsilon", 
    "Zeta", "Eta", "Theta", "Iota", "Kappa",
    "Lambda", "Mu", "Nu", "Xi", "Omicron",
    "Pi", "Rho", "varTheta", "Sigma", "Tau", 
    "Upsilon", "Phi", "Chi", "Psi", "Omega",
)

const usv_Greek = Dict(
    :up => 0x391,
    :it => 0x1D6E2,
    :bfup => 0x1D6A8,
    :bfit => 0x1D71C,
    :bfsfup => 0x1D756,
    :bfsfit => 0x1D790
)

const extras_Greek = Dict(
    :up => SpecialDict(
        "varTheta" => 0x3F4,
        "Digamma" => 0x3DC,
    ),
    :bfup => SpecialDict(
        "varTheta" => 0x1D6B9,
        "Digamma" => 0x1D7CA,
    ),
    :it => SpecialDict(
        "varTheta" => 0x1D6F3,
    ),
    :bfit => SpecialDict(
        "varTheta" => 0x1D72D,
    ),
    :bfsfit => SpecialDict(
        "varTheta" => 0x1D7A1,
    ),
    :bb => SpecialDict(
        "Gamma" => 0x1D6E4,
        "Pi" => 0x0213F,
    )
)

const names_greek = begin 
    ng = _decap.(names_Greek) |> collect

    # rename lowercase symbols according to LaTeX conventions:
    for i in eachindex(ng)
        if ng[i] == "phi" || ng[i] == "epsilon"
            ng[i] = "var" * ng[i]
        end
    end
    tuple(ng...)
end

const usv_greek = Dict(
    :up => 0x3B1,
    :it => 0x1D6FC,
    :bfup => 0x1D6C2,
    :bfit => 0x1D736,
    :bfsfup => 0x1D770,
    :bfsfit => 0x1D7AA,
)

const extras_greek = Dict(
    :up => SpecialDict(
        "epsilon" => 0x3F5,
        "vartheta" => 0x3D1,
        "varkappa" => 0x3F0,
        "phi" => 0x3D5,
        "varrho" => 0x3F1,
        "varpi" => 0x3D6,
        "digamma" => 0x3DD,
    ),
    :it => SpecialDict(
        "epsilon" => 0x1D716,
        "vartheta" => 0x1D717,
        "varkappa" => 0x1D718,
        "phi" =>      0x1D719,
        "varrho" =>   0x1D71A,
        "varpi" =>    0x1D71B,
    ),
    :bfit => SpecialDict(
        "epsilon" => 0x1D750,
        "vartheta" => 0x1D751,
        "varkappa" => 0x1D752,
        "phi" => 0x1D753,
        "varrho" => 0x1D754,
        "varpi" => 0x1D755,
    ),
    :bfup => SpecialDict(
        "epsilon" => 0x1D6DC,
        "vartheta" => 0x1D6DD,
        "varkappa" => 0x1D6DE,
        "phi" => 0x1D6DF,
        "varrho" => 0x1D6E0,
        "varpi" => 0x1D6E1,
        "digamma" => 0x1D7CB,
    ),
    :bfsfup => SpecialDict(
        "epsilon" =>  0x1D78A,
        "vartheta" => 0x1D78B,
        "varkappa" => 0x1D78C,
        "phi" =>      0x1D78D,
        "varrho" =>   0x1D78E,
        "varpi" =>    0x1D78F,
    ),
    :bfsfit => SpecialDict(
        "epsilon" =>  0x1D7C4,
        "vartheta" => 0x1D7C5,
        "varkappa" => 0x1D7C6,
        "phi" =>      0x1D7C7,
        "varrho" =>   0x1D7C8,
        "varpi" =>    0x1D7C9,
    ),
    :bb => SpecialDict(
        "gamma" => 0x0213D,
        "pi" => 0x0213C,
    )
)
    
const names_Latin = (
    "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R",
    "S", "T", "U", "V", "W", "X", "Y", "Z"
)
const names_latin = _decap.(names_Latin)
const names_num = ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9")

const usv_Latin = Dict(
    :up => 65,
    :it => 0x1D434,
    :bb => 0x1D538,
    :cal => 0x1D49C,
    :frak => 0x1D504,
    :sfup => 0x1D5A0,
    :sfit => 0x1D608,
    :tt => 0x1D670,
    :bfup => 0x1D400,
    :bfit => 0x1D468,
    :bffrak => 0x1D56C,
    :bfcal => 0x1D4D0,
    :bfsfup => 0x1D5D4,
    :bfsfit => 0x1D63C,
)

extras_Latin = Dict(
    :cal => SpecialDict(
        "B" => 0x212C,
        "E" => 0x2130,
        "F" => 0x2131,
        "H" => 0x210B,
        "I" => 0x2110,
        "L" => 0x2112,
        "M" => 0x2133,
        "R" => 0x211B,
    ),
    :bb => SpecialDict(
        "C" =>          0x2102,
        "H" =>          0x210D,
        "N" =>          0x2115,
        "P" =>          0x2119,
        "Q" =>          0x211A,
        "R" =>          0x211D,
        "Z" =>          0x2124,
    ),
    :frak => SpecialDict(
        "C" => 0x212D,
        "H" => 0x210C,
        "I" => 0x2111,
        "R" => 0x211C,
        "Z" => 0x2128,
    ),
    :bbit => SpecialDict(
        "D" => 0x2145
    )
)

const extras_latin = Dict(
    :cal => SpecialDict(
        "e" => 0x212F,
        "g" => 0x210A,
        "o" => 0x2134
    ),
    :it => SpecialDict(
        "h" => 0x0210E,
    ),
    :bbit => SpecialDict(
        "d" => 0x2146,
        "e" => 0x2147,
        "i" => 0x2148,
        "j" => 0x2149,
    )
)
const usv_latin = Dict(
    :up => 97,
    :it => 0x1D44E,
    :bb => 0x1D552,
    :cal => 0x1D4B6,
    :frak => 0x1D51E,
    :sfup => 0x1D5BA,
    :sfit => 0x1D622,
    :tt => 0x1D68A,
    :bfup => 0x1D41A,
    :bfit => 0x1D482,
    :bffrak => 0x1D586,
    :bfcal => 0x1D4EA,
    :bfsfup => 0x1D5EE,
    :bfsfit => 0x1D656
)

const usv_num = Dict(
    :up => 48,
    :bb => 0x1D7D8,
    :sfup => 0x1D7E2,
    :tt => 0x1D7F6,
    :bfup => 0x1D7CE,
    :bfsfup => 0x1D7EC
)
const names_partial = ("partial",)
const usv_partial = Dict(
    :up => 0x02202,
    :it => 0x1D715,
    :bfup => 0x1D6DB,
    :bfit => 0x1D74F,
    :bfsfup => 0x1D789,
    :bfsfit => 0x1D7C3,
)

const names_Nabla = ("Nabla",)
const usv_Nabla = Dict(
    :up => 0x02207,
    :it => 0x1D6FB,
    :bfup => 0x1D6C1,
    :bfit => 0x1D735,
    :bfsfup => 0x1D76F,
    :bfsfit => 0x1D7A9,
)

const names_dotless = ("dotlessi", "dotlessj")
const usv_dotless = Dict(
    :up => 0x00131,
    :it => 0x1D6A4
)
const extras_dotless = Dict(
    :up => SpecialDict(
        "dotlessj" => 0x00237,
    ),
    :it => SpecialDict(
        "dotlessi" => 0x1D6A4,
    )
)

const chars_dotless = Dict(
    :up => SpecialDict(
        "dotlessi" => UCMChar("dotlessi", Char(0x00131), :dotless, "", :up),
        "dotlessj" => UCMChar("dotlessi", Char(0x00237), :dotless, "", :up)
    ),
    :it => SpecialDict(
        "dotlessi" => UCMChar("dotlessi", Char(0x1D6A4), :dotless, "\\imath", :it),
        "dotlessj" => UCMChar("dotlessi", Char(0x1D6A5), :dotless, "\\jmath", :it),
    )
)

function all_chars()
    chars_Greek = collect_chars(:Greek, names_Greek, usv_Greek, extras_Greek)
    chars_greek = collect_chars(:greek, names_greek, usv_greek, extras_greek)

    chars_Latin = collect_chars(:Latin, names_Latin, usv_Latin, extras_Latin)
    chars_latin = collect_chars(:latin, names_latin, usv_latin, extras_latin)
    chars_num = collect_chars(:num, names_num, usv_num)

    chars_Nabla = collect_chars(:Nabla, names_Nabla, usv_Nabla)
    chars_partial = collect_chars(:partial, names_partial, usv_partial)

    return Dict(
        :Greek => chars_Greek,
        :greek => chars_greek,
        :Latin => chars_Latin,
        :latin => chars_latin,
        :num => chars_num,
        :Nabla => chars_Nabla,
        :partial => chars_partial,
        :dotless => chars_dotless
    )
end

function inverse_char_dict(all_chars_dict)
    d = SpecialDict{Char, UCMChar}()
    for (rn, chd) = pairs(all_chars_dict)
        for (sn, ucms) = pairs(chd)
            for (n, uch) = pairs(ucms)
                ch = uch.char
                if haskey(d, ch)
                    @warn """
                    '$(ch)' already assigned:
                    is : range=$(d[ch].char_range), style=$(d[ch].style),
                    new: range=$(uch.char_range), style=$(uch.style)"""
                else
                    d[ch] = uch
                end
            end
        end
    end
    return d
end

const chars_by_range_style_name = all_chars()
const chars_to_ucmchars = inverse_char_dict(chars_by_range_style_name)
#=
import Unicode as U
for (rn, chd) = pairs(ucm_chars)
    for (sn, ucms) = pairs(chd)
        for (n, uch) = pairs(ucms)
            U.isassigned(uch.char) && continue
            @show rn, sn, n
        end
    end
end
=#
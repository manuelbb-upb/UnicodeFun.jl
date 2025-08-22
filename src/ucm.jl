# commands similar to the `\sym...` commands in `unicode-math`

include("usv.jl")   # dict `char_groups` for mapping unicode characters
                    # `group_name => Dict(style_name => [char1, …, charN])`
                    # e.g.:
                    # `:latin` => Dict(:up => ['a', ..., 'z'])
include("idx.jl")   # indexing dictionary `char_idx`
                    # `char => `(group_name, pos, styles)`

# suffixes for font styles supported by `\sym` command
const style_names = (
    :up, :it, :bb, :cal, :frak, :tt,
    :sfup, :sfit,
    :bfup, :bfit, :bfcal, :bffrak, 
    :bfsfup, :bfsfit,
)   # `bf` and `bfsf` not enabled due to ambiguous notation standards

# modifier strings supported by `to_latex` command, e.g., `\symup`, `\symbfit` 
const sym_modifiers = Tuple(
    "sym$(sn)" for sn in style_names
)

# special printing function called from within `to_latex`:
function print_sym_modifier(io, mod, substring)
    modsymb = Symbol(mod[4:end])
    return _print_sym_modifier(io, Val(modsymb), substring)
end
function _print_sym_modifier(io, ::Val{sn}, substring) where sn
    error("Modifier `sym$(sn)` not supported.")
end

# define functions `apply_symup`, `apply_symit` etc.
for sn in style_names
    f = Symbol(:apply_sym, sn)
    @eval begin
        function $(f)(c::Char)
            meta = get(char_idx, c, nothing)
            isnothing(meta) && return c
            (group_name, i, styles) = meta
            !haskey(char_groups, group_name) && return c
            !haskey(char_groups[group_name], $(Meta.quot(sn))) && return c
            styled_chars = char_groups[group_name][$(Meta.quot(sn))]
            if i > length(styled_chars)
                return c
            end
            return styled_chars[i]
        end
        $f(io::IO, x::Char) = print(io, $f(x))
        $f(io::IO, x::AbstractString) = for char in x
            print(io, $f(char))
        end
        $f(x::AbstractString) = sprint() do io
            $f(io, x)
        end
        _print_sym_modifier(io, ::Val{$(Meta.quot(sn))}, substring)=$f(io, substring)
    end
end
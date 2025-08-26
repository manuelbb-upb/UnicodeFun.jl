# commands similar to the `\sym...` commands in `unicode-math`
include("UnicodeMath/UnicodeMath.jl")
import .UnicodeMath as UM
const (default_normal_styles, default_substitutions, default_aliases) = UM.config_dicts(; math_style=:literal) 

default_normal_styles_ref = Ref(default_normal_styles)
default_substitutions_ref = Ref(default_substitutions)
default_aliases_ref = Ref(default_aliases)

function ucm_configure!(; kwargs...)
    global default_normal_styles_ref, default_substitutions_ref, default_aliases_ref
    ns, s, a = UM.config_dicts(; kwargs...)
    default_normal_styles_ref[] = ns
    default_substitutions_ref[] = s
    default_aliases_ref[] = a
    return nothing
end

# suffixes for font styles supported by `\sym` command
const style_names = (
    :bfsfup, :bfsfit,
    :bfsf,
    :bfup, :bfit, 
    :bfcal, :bffrak, 
    :sfup, :sfit,
    :bbit,
    :up, :it, :bb, :cal, :frak, :tt,
    :sf, :bf, 
)
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
    f = Symbol(:_sym, sn)
    @eval begin
        function $(f)(c::Char)
            global default_normal_styles_ref, default_substitutions_ref, default_aliases_ref

            return UM.apply_style(c, $(Meta.quot(sn)); 
                normal_styles = default_normal_styles_ref[],
                substitutions = default_substitutions_ref[],
                aliases = default_aliases_ref[]
            )
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
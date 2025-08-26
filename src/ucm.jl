# commands similar to the `\sym...` commands in `unicode-math`
include("UnicodeMath/UnicodeMath.jl")
import .UnicodeMath as UM

for (cmd_symb, ucm_cmd) = pairs(UM.extra_commands)
    push!(latex_symbol_map, string(cmd_symb) => ucm_cmd.char)
end

# suffixes for font styles supported by `\sym` command
const style_names = Symbol.(
    tuple( sort([string(sn) for sn=UM.all_styles]; by=length, rev=true)... )
)

# modifier strings supported by `to_latex` command, e.g., `\symup`, `\symbfit` 
const sym_modifiers = Tuple(
    "sym$(sn)" for sn in style_names
)

# special printing function called from within `to_latex`:
function print_sym_modifier(io, mod, substring)
    modsymb = Symbol(mod[4:end])
    if !(modsymb in style_names)
        error("Modifier `sym$(modsymb)` not supported.")
    end
    return UM.sym_style(io, substring, modsymb)
end
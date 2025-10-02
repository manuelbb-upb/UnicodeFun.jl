module UnicodeFun

using REPL

include("UnicodeMath/src/UnicodeMath.jl")
import .UnicodeMath as UCM

# Here, we collect and reverse the REPL's latex autocompletion map.
const repl_symbols_unsorted = Dict(
    k[2:end] => v[1] for (k, v) in REPL.REPLCompletions.latex_symbols
)
# Also collect extra symbols defined by submodule UnicodeMath.
const ucm_symbols_dict = Dict(
    ucm_cmd.latex_cmd[2:end] => ucm_cmd.glyph for ucm_cmd in values(UCM.extra_commands)
)

# Collect all symbols, giving precedence to REPL definitions:
const symbols_unsorted = merge(ucm_symbols_dict, repl_symbols_unsorted) |> pairs |> collect
# Build substitution list for `to_latex`:
const latex_symbol_map = sort!(symbols_unsorted, by=(x)-> length(x[1]), rev=true)

include("sub_super_scripts.jl")
export to_superscript, to_subscript
export to_fraction, to_fraction_nl

include("fontstyles.jl")
export to_blackboardbold
export to_boldface
export to_italic
export to_caligraphic
export to_frakture
export to_underline
export to_overline
export to_bolditalic

include("latex.jl")
export to_latex

include("roots.jl")
export to_root

end # module

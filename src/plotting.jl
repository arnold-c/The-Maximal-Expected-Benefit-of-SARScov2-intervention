using CairoMakie
using Makie: Makie
using ColorSchemes: ColorSchemes
using Core: GeneratedFunctionStub
using DataFrames: DataFrames

"""
    extract_categorical_colors(;
    	continuous_color_scheme,
    	start = 1,
    	stop = size(continuous_color_scheme),
    	length = 11,
    	rev = false,
    )

Take a continuous color scheme and convert into a discrete scheme.
Used when plotting distributions that differ by assortativity.
"""
function extract_categorical_colors(;
    continuous_color_scheme,
    start = 1,
    stop = size(continuous_color_scheme),
    length = 11,
    rev = false,
)
    colscheme = rev ? reverse(continuous_color_scheme) : continuous_color_scheme

    indices = Int64.(floor.(LinRange(start, stop, length)))

    return colscheme[indices]
end

off_diag_beta_scaling_col = extract_categorical_colors(;
    continuous_color_scheme = ColorSchemes.matter, start = 40
)

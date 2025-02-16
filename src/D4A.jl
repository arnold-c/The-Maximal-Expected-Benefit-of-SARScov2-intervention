module D4A

using StaticArrays: beta
using Data4ActionUtils
export classLprop,
    classMprop,
    classHprop,
    classLprop,
    classMprop,
    classHprop,
    obs_final_Cs,
    CopyColumns, CopyRows, CopyConstant

include(
    "DrWatson-convenience-funs.jl"
)
export figsdir, analysisdir, lcadir

include("plot-theme.jl")
export custom_theme

include("plotting.jl")
export extract_categorical_colors, off_diag_beta_scaling_col

include("lca-simulation-plots.jl")
export lca_simulation_plots_tables

include("abc-plots.jl")
export distance_whisker_plot

include("intervention-plots.jl")
export intervention_plot

include("table-functions.jl")
export beta_dist_table

@static if false
    include("../manuscripts/lca/scripts/lca-plots.jl")
end

end

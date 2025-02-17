#%%
using DrWatson
@quickactivate "Data4Action"

using Data4Action
using Data4ActionUtils: Data4ActionUtils
using CairoMakie

#%%
manuscriptsdir(args...) = DrWatson.projectdir("manuscripts", "lca", args...)
manuscript_scripts(args...) = manuscriptsdir("scripts", args...)

manuscript_files(args...) = manuscriptsdir("manuscript_files", args...)
manuscript_plotdir(args...) = manuscript_files("plots", args...)
manuscript_tabledir(args...) = manuscript_files("tables", args...)

supplemental_files(args...) = manuscriptsdir("supplemental_files", args...)
supplemental_plotdir(args...) = supplemental_files("plots", args...)
supplemental_tabledir(args...) = supplemental_files("tables", args...)

mkpath(manuscript_plotdir())
mkpath(supplemental_plotdir())
mkpath(manuscript_tabledir())
mkpath(supplemental_tabledir())

#%%
set_theme!(
    custom_theme;
    linewidth = 6,
)

update_theme!(; size = (1300, 800))

#%%
for (
    beta_mat_method,
    fig_tag,
    whisker_fig_num,
    intervention_fig_num,
    plot_output_dir,
    table_output_dir,
) in zip(
    [CopyColumns, CopyRows, CopyConstant],
    ["copy-cols", "copy-rows", "constant"],
    ["fig-1", nothing, nothing],
    ["fig-2", nothing, nothing],
    [manuscript_plotdir, supplemental_plotdir, supplemental_plotdir],
    [supplemental_tabledir, supplemental_tabledir, supplemental_tabledir],
)
    lca_simulation_plots_tables(
        beta_mat_method;
        plot_output_dir = plot_output_dir,
        table_output_dir = table_output_dir,
        whiskerlinewidth = 6,
        whiskerwidth = 28,
        strokewidth = 2,
        markersize = 36,
        whisker_fig_num = whisker_fig_num,
        intervention_fig_num = intervention_fig_num,
        fig_tag = fig_tag,
        panel_fontsize = 35,
    )
end

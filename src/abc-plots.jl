using DrWatson: DrWatson
using CairoMakie
using ColorSchemes: ColorSchemes
using StatsBase: median

"""
    distance_whisker_plot(
    	off_diag_beta_scaling_range,
    	abcreject_vec;
    	whiskerlinewidth = 6,
    	whiskerwidth = 28,
    	strokewidth = 2,
    	markersize = 36,
    	output_dir = manuscript_plotdir,
    	fig_tag = "copy-cols",
    	off_diag_beta_scaling_col = off_diag_beta_scaling_col,
    	return_plot = false,
    	kwargs...,
    )

Create a whisker plot for ABC distances, showing median, minimum, and maximum distances, separated by assortativity (off_diag_beta_scaling).
Can return the plot to display, or save to file.
"""
function distance_whisker_plot(
    off_diag_beta_scaling_range,
    abcreject_vec;
    whiskerlinewidth = 6,
    whiskerwidth = 28,
    strokewidth = 2,
    markersize = 36,
    output_dir = DrWatson.plotsdir(),
    fig_tag = "copy-cols",
    off_diag_beta_scaling_col = off_diag_beta_scaling_col,
    return_plot = false,
    kwargs...,
)
    kwargs_dict = Dict{Symbol,Any}(kwargs)

    distance_whisker_fig = Figure()
    distance_whisker_ax = Axis(
        distance_whisker_fig[1, 1];
        ylabel = "Distance",
        xlabel = "Between Group Mixing",
    )

    min_dist = zeros(Float64, length(abcreject_vec))
    max_dist = zeros(Float64, length(abcreject_vec))
    median_dist = zeros(Float64, length(abcreject_vec))
    for i in eachindex(abcreject_vec)
        min_dist[i] = minimum(abcreject_vec[i].distances)
        max_dist[i] = maximum(abcreject_vec[i].distances)
        median_dist[i] = median(abcreject_vec[i].distances)
    end

    rangebars!(
        distance_whisker_ax,
        off_diag_beta_scaling_range,
        min_dist,
        max_dist;
        color = off_diag_beta_scaling_col,
        linewidth = whiskerlinewidth,
        whiskerwidth = whiskerwidth,
        direction = :y,
    )

    scatter!(
        distance_whisker_ax,
        off_diag_beta_scaling_range,
        median_dist;
        color = off_diag_beta_scaling_col,
        strokecolor = :white,
        strokewidth = strokewidth,
        markersize = markersize,
    )

    if return_plot
        return distance_whisker_fig
    end

    plotname = "abc-distance-whiskers_$(fig_tag).png"
    if haskey(kwargs_dict, :whisker_fig_num) &&
        !isnothing(kwargs_dict[:whisker_fig_num])
        plotname = "$(kwargs_dict[:whisker_fig_num])_" * plotname
    end

    plotpath = output_dir(plotname)

    save(
        plotpath,
        distance_whisker_fig,
    )

    return nothing
end

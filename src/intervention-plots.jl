using DrWatson: DrWatson
using CairoMakie
using ColorSchemes: ColorSchemes
using DataFrames: DataFrames
using StructArrays: StructArrays

"""
    intervention_plot(
    	all_inter_final_size,
    	off_diag_beta_range,
    	inter_range,
    	seroprev_type = :overall_seroprev,
    	central_measure_label = "mean",
    	bounds_quantile = 0.05;
    	output_dir = DrWatson.plotsdir(),
    	fig_tag = "copy-cols",
    	linewidth = 6,
    	barplot_width = 0.5,
    	panel_fontsize = 35,
    	return_plot = false,
    	CIs = false,
    	kwargs...,
    )

Create a plot demonstrating the effect of an intervention to increase adherence, and include a schematic illustrating how increasing adherence affects population sizes.
`return_plot` can be used to either return the plot for display, or to save to file.
"""
function intervention_plot(
    all_inter_final_size,
    off_diag_beta_range,
    inter_range,
    seroprev_type = :overall_seroprev,
    central_measure_label = "mean",
    bounds_quantile = 0.05;
    output_dir = DrWatson.plotsdir(),
    fig_tag = "copy-cols",
    linewidth = 6,
    barplot_width = 0.5,
    panel_fontsize = 35,
    return_plot = false,
    CIs = false,
    kwargs...,
)
    kwargs_dict = Dict{Symbol,Any}(kwargs)

    transriskdf = DataFrames.DataFrame(;
        Adherence = ["Low Adherence", "Medium Adherence", "High Adherence"],
        Risk = sort(obs_final_Cs; rev = true),
        Pop = [classLprop, classMprop, classHprop],
    )
    transrisk_cols = extract_categorical_colors(;
        continuous_color_scheme = ColorSchemes.matter, start = 1, stop = 150,
        length = 3, rev = true,
    )

    inter_reductions = Data4ActionUtils.all_inter_seroprev_reduction(
        all_inter_final_size,
        off_diag_beta_range,
        inter_range,
        seroprev_type,
        central_measure_label,
        bounds_quantile,
    )

    interstacked_fig = Figure()
    interstacked_ga = interstacked_fig[1, 1] = GridLayout()
    interstacked_line_ax = Axis(
        interstacked_ga[1, 1];
        xlabel = "Intervention Size", ylabel = "Final Size Percent Change",
        yticks = (0:-0.2:-1, string.(0:-20:-100) .* "%"),
    )

    if CIs
        for off_diag_beta_scaling in off_diag_beta_range
            off_diag_beta_scaling_inter_reductions = filter(
                sa -> sa.off_diag_beta_scaling == off_diag_beta_scaling,
                inter_reductions,
            )
            off_diag_beta_scaling_seroprev_summary = StructArrays.StructArray(
                off_diag_beta_scaling_inter_reductions.seroprev_results_summary
            )

            band!(
                interstacked_line_ax,
                convert.(
                    Float64,
                    off_diag_beta_scaling_inter_reductions.intervention_size,
                ),
                convert.(
                    Float64,
                    off_diag_beta_scaling_seroprev_summary.upper_quantile,
                ),
                convert.(
                    Float64,
                    off_diag_beta_scaling_seroprev_summary.lower_quantile,
                );
                alpha = 0.5,
            )
        end
    end

    for off_diag_beta_scaling in off_diag_beta_range
        off_diag_beta_scaling_inter_reductions = filter(
            sa -> sa.off_diag_beta_scaling == off_diag_beta_scaling,
            inter_reductions,
        )
        lines!(
            interstacked_line_ax,
            off_diag_beta_scaling_inter_reductions.intervention_size,
            StructArrays.StructArray(
                off_diag_beta_scaling_inter_reductions.seroprev_results_summary
            ).central_measure;
            linewidth = linewidth,
            label = string(off_diag_beta_scaling),
        )
    end

    axislegend("Between-Group\nMixing"; orientation = :horizontal)

    interstacked_bar_ax = Axis(
        interstacked_ga[2, 1];
        ylabel = "Relative Group Size",
    )

    inter_range_schematic = [0.0, 0.5, 1.0]
    @assert sum(map(x -> in(x, inter_range), inter_range_schematic)) ==
        length(inter_range_schematic)

    for (i, intersize) in pairs(inter_range_schematic)
        newpopsize = zeros(3)
        newpopsize[1:2] = transriskdf.Pop[1:2] .* (1 - intersize)
        newpopsize[3] =
            transriskdf.Pop[3] + sum(transriskdf.Pop[1:2] .- newpopsize[1:2])

        # Reverse order for plotting so high adherence builds up, not down
        newpopsize = reverse(newpopsize)

        barplot!(
            interstacked_bar_ax, repeat([i], 3), newpopsize;
            stack = 1:3,
            color = 1:3,
            colormap = reverse(transrisk_cols),
            width = barplot_width,
        )
    end

    Legend(
        interstacked_ga[3, :],
        [
            PolyElement(; color = color, strokecolor = :transparent)
            for color in transrisk_cols
        ],
        transriskdf.Adherence;
        orientation = :horizontal,
    )

    hidexdecorations!(interstacked_bar_ax)
    hideydecorations!(interstacked_bar_ax; label = false, ticklabels = false)
    hidespines!(interstacked_bar_ax)

    rowgap!(interstacked_ga, 10)
    rowsize!(interstacked_ga, 2, Relative(0.25))

    for (label, layout) in
        zip(["a", "b"], [interstacked_ga[1, 1], interstacked_ga[2, 1]])
        Label(layout[1, 1, TopLeft()], label;
            fontsize = panel_fontsize,
            font = :bold,
            padding = (0, 0, 20, 0),
            halign = :right)
    end

    if return_plot
        return interstacked_fig
    end

    plotname = "intervention-stacked-bar_$(fig_tag).png"
    if haskey(kwargs_dict, :intervention_fig_num) &&
        !isnothing(kwargs_dict[:intervention_fig_num])
        plotname = "$(kwargs_dict[:intervention_fig_num])_" * plotname
    end

    plotpath = output_dir(plotname)

    save(
        plotpath,
        interstacked_fig,
    )

    return nothing
end

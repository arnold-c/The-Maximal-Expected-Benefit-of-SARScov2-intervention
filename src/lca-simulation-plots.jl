using Data4ActionUtils: Data4ActionUtils
using StaticArrays: StaticArrays
using ColorSchemes: ColorSchemes
using LabelledArrays: LabelledArrays
using CSV: CSV

"""
    lca_simulation_plots_tables(
    	beta_mat_method;
    	tspan = (0.0, 200.0),
    	seed = 1234,
    	n_samples = Int64(1e3),
    	nparticles = 200,
    	off_diag_beta_scaling_range = range(0.0, 1.0; step = 0.1),
    	inter_range = range(0.0; stop = 1.0, step = 0.1),
    	beta_table_percentiles = 95,
    	plot_output_dir = joinpath(),
    	table_output_dir = joinpath(),
    	whiskerlinewidth = 6,
    	whiskerwidth = 28,
    	strokewidth = 2,
    	markersize = 36,
    	intervention_linewidth = 6,
    	intervention_barplot_width = 0.5,
    	intervention_panel_fontsize = 20,
    	fig_tag = "copy-cols",
    	off_diag_beta_scaling_col = off_diag_beta_scaling_col,
    	kwargs...,
    )

Wrapper function to run ABC simulations and create distance whisker plot of ABC fits, write summary table of diagonal beta values to CSV, create intervention plots, and print to stdout the summary of the intervention reductions.

  - `n_samples` refers to the number of random values drawn for each parameter in the initial ABC fitting of the Rejection Sampling process.
  - `nparticles` refers to the number of successful fits required to complete the ABC fitting, after the initial ABC step has completed (that is used to determine the distance threshold for acceptance).
"""
function lca_simulation_plots_tables(
    beta_mat_method;
    tspan = (0.0, 200.0),
    seed = 1234,
    n_samples = Int64(1e3),
    nparticles = 200,
    off_diag_beta_scaling_range = range(0.0, 1.0; step = 0.1),
    inter_range = range(0.0; stop = 1.0, step = 0.1),
    beta_table_percentiles = 95,
    plot_output_dir = DrWatson.plotsdir(),
    table_output_dir = DrWatson.projectdir(),
    whiskerlinewidth = 6,
    whiskerwidth = 28,
    strokewidth = 2,
    markersize = 36,
    intervention_linewidth = 6,
    intervention_barplot_width = 0.5,
    intervention_panel_fontsize = 20,
    fig_tag = "copy-cols",
    off_diag_beta_scaling_col = off_diag_beta_scaling_col,
    kwargs...,
)
    initial_states = Data4ActionUtils.create_state_labels_sv(
        0.99 * classHprop,
        0.99 * classMprop,
        0.99 * classLprop,
        0.01 * classHprop,
        0.01 * classMprop,
        0.01 * classLprop,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
    )

    gamma = 1 / 8

    sir_parameters = Data4ActionUtils.ABCSetupParameters(
        gamma,
        initial_states,
        tspan,
        obs_final_Cs,
    )

    abcreject_vec = Data4ActionUtils.run_abc(
        off_diag_beta_scaling_range,
        sir_parameters,
        beta_mat_method;
        n_samples = n_samples,
    )

    distance_whisker_plot(
        off_diag_beta_scaling_range,
        abcreject_vec;
        off_diag_beta_scaling_col = off_diag_beta_scaling_col,
        whiskerlinewidth = whiskerlinewidth,
        whiskerwidth = whiskerwidth,
        strokewidth = strokewidth,
        markersize = markersize,
        output_dir = plot_output_dir,
        fig_tag = fig_tag,
        kwargs...,
    )

    min_off_diag_scaling = calculate_lowest_dist_off_diag_scaling(abcreject_vec)

    beta_table = beta_dist_table(
        abcreject_vec,
        [0.0, min_off_diag_scaling, 1.0],
        beta_table_percentiles,
    )

    CSV.write(
        table_output_dir("beta-dist-table_$(fig_tag).csv"),
        beta_table,
    )

    all_inter_final_size = Data4ActionUtils.intervention_effect(
        off_diag_beta_scaling_range,
        inter_range,
        sir_parameters,
        abcreject_vec,
        beta_mat_method;
        nparticles = nparticles,
    )

    intervention_plot(
        all_inter_final_size,
        (0.0, min_off_diag_scaling, 1.0),
        inter_range,
        :overall_seroprev,
        "mean",
        0.05;
        return_plot = false,
        linewidth = intervention_linewidth,
        barplot_width = intervention_barplot_width,
        panel_fontsize = intervention_panel_fontsize,
        output_dir = plot_output_dir,
        fig_tag = fig_tag,
        kwargs...,
    )

    @show beta_mat_method

    inter_reductions = Data4ActionUtils.all_inter_seroprev_reduction(
        all_inter_final_size,
        [0.0, min_off_diag_scaling, 1.0],
        inter_range,
        :overall_seroprev,
        "mean",
        0.05,
    )

    for off_diag_beta_scaling in [0.0, min_off_diag_scaling, 1.0]
        off_diag_beta_scaling_inter_reductions = filter(
            sa -> sa.off_diag_beta_scaling == off_diag_beta_scaling,
            inter_reductions,
        )
        off_diag_beta_scaling_seroprev_summary = StructArrays.StructArray(
            off_diag_beta_scaling_inter_reductions.seroprev_results_summary
        )

        @show off_diag_beta_scaling
        inter_reduction_df = DataFrames.DataFrame(
            "Intervention Size" =>
                off_diag_beta_scaling_inter_reductions.intervention_size,
            "Lower Quantile" =>
                off_diag_beta_scaling_seroprev_summary.lower_quantile,
            "Median" => off_diag_beta_scaling_seroprev_summary.central_measure,
            "Upper Quantile" =>
                off_diag_beta_scaling_seroprev_summary.upper_quantile,
        )
        println(inter_reduction_df)
    end
    return nothing
end

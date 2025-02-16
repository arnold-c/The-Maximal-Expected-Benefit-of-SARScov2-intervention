using Data4ActionUtils
using StaticArrays
using Distances: Distances
using LabelledArrays

@testset "SIR-ABC.jl" verbose = true begin
    tspan = (0.0, 200.0)
    seed = 1234
    n_samples = Int64(1e3)
    nparticles = 200
    off_diag_beta_range = range(0.0, 1.0; step = 0.1)
    inter_range = range(0.0; stop = 1.0, step = 0.1)
    whiskerlinewidth = 6
    whiskerwidth = 28
    strokewidth = 2
    markersize = 36
    intervention_linewidth = 6
    intervention_barplot_width = 2
    intervention_panel_fontsize = 20

    initial_states = create_state_labels_sv(
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

    @testset "Distance" begin
        a = [1.0, 2.0, 3.0]
        b = [1.5, 1.5, 2.0]

        distance = Distances.evaluate(
            Distances.Euclidean(), a, b
        )
        @test isequal(
            distance,
            sqrt(sum((a .- b) .^ 2)),
        )
    end

    @testset "ABC SIR Model" begin
        abc_input_params = ABCInputParameters(0.1, 0.5, 1.0)

        constants = ABCConstants(
            Data4ActionUtils.beta_LL,
            1.0,
            gamma,
            initial_states,
            tspan,
        )

        abc_output = abc_sirmodel(
            abc_input_params, constants, obs_final_Cs, CopyColumns
        )

        @test isequal(
            length(propertynames(abc_output)), 3
        )

        @test isequal(
            propertynames(abc_output), (:distance, :seroprev_results, :beta_mat)
        )

        @test isequal(
            length(propertynames(abc_output.seroprev_results)),
            4,
        )

        @test isequal(
            propertynames(abc_output.seroprev_results),
            (
                :class_L_seroprev,
                :class_M_seroprev,
                :class_H_seroprev,
                :overall_seroprev,
            ),
        )

        @test isequal(
            abc_output.beta_mat,
            [
                0.1 0.5 1.0
                0.1 0.5 1.0
                0.1 0.5 1.0
            ],
        )
    end

    sir_parameters = ABCSetupParameters(
        gamma,
        initial_states,
        tspan,
        obs_final_Cs,
    )

    @testset "Initial ABC" begin
        # @profview Data4ActionUtils.initial_abc(
        #     off_diag_beta_range,
        #     sir_parameters,
        #     CopyColumns;
        #     n_samples = 100,
        # )
    end

    abcreject_vec = run_abc(
        off_diag_beta_range,
        sir_parameters,
        CopyColumns,
    )

    @testset "beta Matrix" begin
        # for completely assortative all off-diagonals = 0
        @test isequal(
            abcreject_vec[1].params.off_diag_beta_scaling[1],
            abcreject_vec[1].params.off_diag_beta_scaling[end],
        )
        @test isequal(
            abcreject_vec[1].params.off_diag_beta_scaling[1],
            0.0,
        )
        @test isequal(
            length(unique(abcreject_vec[1].params.beta_mat[1][:, 1])),
            2,
        )
        @test isequal(
            sum(abcreject_vec[1].params.beta_mat[1][2:3, 1]),
            0,
        )

        # When homogeneous mixing and copy-columns structure, only a single
        # beta value should be present in a column
        @test isequal(
            abcreject_vec[end].params.off_diag_beta_scaling[1],
            1.0,
        )
        for i in eachindex(abcreject_vec[end].params.beta_mat)
            @test isequal(
                length(unique(abcreject_vec[end].params.beta_mat[i][:, 1])),
                1,
            )
        end

        # Check correct ordering of diagonals in 10 randomly selected simulations
        for i in rand(eachindex(abcreject_vec[5].params.beta_mat), 10)
            @test isequal(
                abcreject_vec[5].params.beta_mat[i][1, 1] <=
                abcreject_vec[5].params.beta_mat[i][2, 2] <=
                abcreject_vec[5].params.beta_mat[i][3, 3],
                true,
            )
        end
    end
end

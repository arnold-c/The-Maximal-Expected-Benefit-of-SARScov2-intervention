using Data4ActionUtils
using StaticArrays
using LabelledArrays

@testset "SIR-utils.jl" verbose = true begin
    @testset "Correct beta Draws" begin
        @test isequal(
            correct_beta_draw_order(0.5, 0.5),
            (0.5, 0.5),
        )

        @test isequal(
            correct_beta_draw_order(0.5, 1.0),
            (0.5, 1.0),
        )

        @test isequal(
            correct_beta_draw_order(1.0, 0.5),
            (0.5, 1.0),
        )
    end

    @testset "Reshape beta mats" begin
        vec_of_beta_mats = [
            [
                1 0 0
                0 2 0
                0 0 3
            ],
            [
                1 1 1
                2 2 2
                3 3 3
            ],
        ]
        @test isequal(
            reshape_vec_of_beta_mat(vec_of_beta_mats)[:, :, 1],
            vec_of_beta_mats[1],
        )

        @test isequal(
            reshape_vec_of_beta_mat(vec_of_beta_mats)[:, :, 2],
            vec_of_beta_mats[2],
        )
    end

    @testset "SIR simulation" begin
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

        # Want to use views in sir_ode to reduce allocations, so perform check before passing
        # states to ODE problem and solver
        @test isequal(
            propertynames(initial_states),
            (
                :S_H, :S_M, :S_L,
                :I_H, :I_M, :I_L,
                :R_H, :R_M, :R_L,
                :C_H, :C_M, :C_L,
                :lambda_H, :lambda_M, :lambda_L,
            ),
        )

        gamma = 1 / 8

        beta_mat_p = create_beta_mat_parameters_sv(
            0.1,
            0.5,
            beta_LL,
            1.0,
            1.0,
        )

        beta_mat = create_beta_mat(beta_mat_p, CopyColumns)

        @test isequal(
            beta_mat * initial_states[[:I_H, :I_M, :I_L]],
            beta_mat * @view(initial_states[4:6])
        )

        @test isequal(
            beta_mat * initial_states[[:I_H, :I_M, :I_L]],
            [
                beta_mat.beta_HH * initial_states.I_H +
                beta_mat.beta_HM * initial_states.I_M +
                beta_mat.beta_HL * initial_states.I_L,
                beta_mat.beta_MH * initial_states.I_H +
                beta_mat.beta_MM * initial_states.I_M +
                beta_mat.beta_ML * initial_states.I_L,
                beta_mat.beta_LH * initial_states.I_H +
                beta_mat.beta_LM * initial_states.I_M +
                beta_mat.beta_LL * initial_states.I_L,
            ],
        )

        sir_parameters = SIRParameters(
            beta_mat,
            gamma,
        )

        tspan = (0.0, 200.0)

        sir_sol = Data4ActionUtils.fit_solve_sir(
            sir_ode,
            initial_states,
            tspan,
            sir_parameters;
            save_everystep = true,
        )

        @test isequal(
            Data4ActionUtils.fit_solve_sir(
            sir_ode,
            initial_states,
            tspan,
            sir_parameters;
            save_everystep = true
    ).u[end],
            Data4ActionUtils.fit_solve_sir(
            sir_ode,
            initial_states,
            tspan,
            sir_parameters;
            save_everystep = false
    ).u[end],
        )

        @test typeof(sir_sol.u) <: Vector{<:SLArray}

        sir_df = Data4ActionUtils.create_sir_df(sir_sol)

        sir_df

        @test (sir_df[end, :C_L] / classLprop) >=
            (sir_df[end, :C_H] / classHprop)
    end
end

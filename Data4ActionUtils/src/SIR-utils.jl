using StaticArrays: StaticArrays
using LabelledArrays: LabelledArrays
using OrdinaryDiffEq: OrdinaryDiffEq
using DataFrames: DataFrames
using UnPack: @unpack

"""
    create_state_labels_sv(state_changes)

Create a Static Labeled Vector of the changes of each state in the SIR differential equation model
"""
const create_state_labels_sv = LabelledArrays.@SLVector Float64 (
    :S_H,
    :S_M,
    :S_L,
    :I_H,
    :I_M,
    :I_L,
    :R_H,
    :R_M,
    :R_L,
    :C_H,
    :C_M,
    :C_L,
    :lambda_H,
    :lambda_M,
    :lambda_L,
)

"""
    create_beta_mat_parameters_sv(parameters)

Create a Static Labeled Vector of the parameters required to pass into the beta matrix creation function
"""
const create_beta_mat_parameters_sv = LabelledArrays.@SLVector Float64 (
    :beta_HH,
    :beta_MM,
    :beta_LL,
    :off_diag_beta_scaling,
    :rho,
)

const create_abc_parameters_sv = LabelledArrays.@SLVector Float64 (
    :beta_HH_prior, :beta_MM_prior, :rho_prior
)

"""
    sir_ode(states, parameters, tspan)

The SIR model that returns the change in states at each step.
Require states, parameters, and tspan in order, as a requirement of the ODE solver
"""
function sir_ode(states, parameters, tspan)
    @unpack beta_mat, gamma = parameters

    d_lambda_vec = StaticArrays.SVector{3,Float64}(
        beta_mat * @view(states[4:6])
    )
    inf_vec = StaticArrays.SVector{3,Float64}(
        d_lambda_vec .* @view(states[1:3])
    )
    recov_vec = StaticArrays.SVector{3,Float64}(gamma * @view(states[4:6]))

    return create_state_labels_sv(
        vcat(
            -inf_vec, inf_vec .- recov_vec, recov_vec, inf_vec, d_lambda_vec
        ),
    )
end

"""
    fit_solve_sir(ode, initial_states, tspan, parameters; saveat = 0.1)

Returns the ODE solution for the fit SIR model.

  - `save_everystep` selects whether all ODE solution steps are saved, or just the first and last positions. Defaults to `false` as trajectories are not plotted and slows the ABC unnecessarily.
"""
function fit_solve_sir(
    ode, initial_states, tspan, parameters; save_everystep = false, kwargs...
)
    prob = OrdinaryDiffEq.ODEProblem{false}(
        ode, initial_states, tspan, parameters;
        save_everystep = save_everystep,
    )

    return OrdinaryDiffEq.solve(prob; kwargs...)
end

"""
    create_sir_df(sir_sol)

Returns a DataFrame with the SIR model solution with variable names collected from the SIR solution.
The SIR ODE function should return a LabelledArrays.SLVector that contain the state names to be extracted by DataFrames.DataFrame
"""
function create_sir_df(sir_sol)
    sir_df = DataFrames.DataFrame(sir_sol)
    DataFrames.rename!(
        sir_df,
        [:time, keys(sir_sol.u[1])...],
    )
    return sir_df
end

"""
    create_sir_df(sir_sol, states_label, λ_label)

Returns a DataFrame with the SIR model solution with variable names.

The `states_labels` and `λ_labels` are used to name the columns of the DataFrame and must be in the same order as the SVector output by the SIR model i.e. S_H, S_M, ..., λ_L.
"""
function create_sir_df(sir_sol, states_labels, λ_labels)
    sir_df = DataFrames.DataFrame(sir_sol)
    DataFrames.rename!(
        sir_df,
        [:time, states_labels..., λ_labels...],
    )
    return sir_df
end

"""
    extract_sir_lambdas(sir_df)

Returns a long DataFrame with the λs from the SIR model solution.
"""
function extract_sir_lambdas(sir_df)
    sir_lambdas = (
        df -> DataFrames.stack(
            df,
            DataFrames.Not(:time); variable_name = :λ,
            value_name = :value,
        )
    )(
        DataFrames.select(sir_df, :times => DataFrames.ByRow(==(r"λ")))
    )

    return sir_lambdas
end

"""
    fit_sir_model(ode, states, tspan, parameters; states_label = states_label, λ_labels = λ_labels)

Returns the 3 DataFrames: the wide-format SIR solution values, the λ values, and the wide-format SIR solution.

Calls `create_sv_parameters`, `fit_solve_sir`, `create_sir_df`, and `extract_sir_lambdas`
"""
function fit_sir_model(
    ode,
    states,
    tspan,
    parameters;
    states_labels = states_labels,
    λ_labels = λ_labels,
    saveat = [],
)
    sol = fit_solve_sir(ode, states, tspan, parameters; saveat = saveat)

    sir_df = create_sir_df(sol, states_labels, λ_labels)

    lambdas_df = extract_sir_lambdas(sir_df)

    DataFrames.select!(
        sir_df,
        DataFrames.Not(λ_labels),
    )

    sir_df_long = DataFrames.stack(
        sir_df,
        states_labels; variable_name = :state, value_name = :proportion,
    )

    return sir_df, lambdas_df, sir_df_long
end

"""
    sir_model_finalsize(ode, states, tspan, p)

Simulates the SIR model and returns the final size of the epidemic.
"""
function sir_model_finalsize(ode, states, tspan, p)
    sol = fit_solve_sir(ode, states, tspan, p)

    return vec(Array(sol)[(end - 5):(end - 3), end])
end

"""
    correct_beta_draw_order(beta_HH_prior, beta_MM_prior)

Ensures that the betas are in the correct order for the SIR model i.e. beta_HH <= beta_MM, where HH refers to within-group mixing for the High Adherence group.
Important for the ABC sampling where the betas are independently sampled from a uniform distribution.
"""
function correct_beta_draw_order(beta_HH_prior, beta_MM_prior)
    if beta_HH_prior > beta_MM_prior
        beta_MM_prior, beta_HH_prior = beta_HH_prior, beta_MM_prior
    end

    return beta_HH_prior, beta_MM_prior
end

"""
    reshape_vec_of_beta_mat(vec_of_beta_mats)

Reshape a vector of beta matrices (e.g., created as a StructArray during ABC) into a 3D array, for easier manipulation
"""
function reshape_vec_of_beta_mat(vec_of_beta_mats)
    return reshape(reduce(hcat, vec_of_beta_mats), (3, 3, :))
end

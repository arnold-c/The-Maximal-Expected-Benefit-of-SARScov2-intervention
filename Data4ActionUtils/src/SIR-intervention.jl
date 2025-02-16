using StaticArrays: StaticArrays
using UnPack: @unpack
using StatsBase: StatsBase
using StructArrays: StructArrays
using Match: Match

"""
    intervention_effect(
    	off_diag_beta_scaling_range,
    	inter_range,
    	sir_parameters,
    	abcreject_vec,
    	beta_mat_method;
    	nparticles=200,
    )

Calculate the effect of a range of interventions for all degrees of assortativity.
`nparticles` refers to the number of simulations accepted during the ABC fitting process.

Returns a 3D array of structs (of InterventionEffect) that is reshaped as a struct of arrays for easier manipulation.
"""
function intervention_effect(
    off_diag_beta_scaling_range,
    inter_range,
    sir_parameters,
    abcreject_vec,
    beta_mat_method;
    nparticles = 200,
)
    @assert length(off_diag_beta_scaling_range) == length(abcreject_vec)

    @unpack gamma, initial_states, tspan = sir_parameters

    all_inter_final_size = Array{InterventionEffect}(
        undef, nparticles, length(off_diag_beta_scaling_range),
        length(inter_range),
    )

    for (off_diag_beta_scaling_num, off_diag_beta_scaling) in
        pairs(off_diag_beta_scaling_range)
        for (inter_num, inter_size) in pairs(inter_range)
            for sim_num in eachindex(1:nparticles)
                seroprev_results = calculate_inter_final_size(
                    sir_ode, initial_states, tspan,
                    abcreject_vec[off_diag_beta_scaling_num].params[sim_num],
                    gamma,
                    beta_mat_method;
                    inter_size = inter_size,
                )

                all_inter_final_size[sim_num, off_diag_beta_scaling_num, inter_num] = InterventionEffect(
                    seroprev_results,
                    off_diag_beta_scaling,
                    inter_size,
                )
            end
        end
    end
    all_inter_final_size = StructArrays.StructArray(all_inter_final_size)
    return all_inter_final_size
end

"""
    calculate_inter_final_size(
    	ode,
    	initial_states,
    	tspan,
    	beta_parameters,
    	gamma,
    	beta_mat_method;
    	inter_size = 1.0,
    )

Calculate the final size of an SIR model with an intervention that reduces the
transmission rate between two subpopulations.

# Arguments

  - `ode`: the ODE function that describes the SIR model
  - `initial_states`: the initial values of the S, I, and R compartments
  - `tspan`: the time span of the simulation
  - `beta_parameters`: a ABCParams struct that contains parameter values required to construct the beta transmission matrix
  - `gamma`: the recovery rate
  - `beta_mat_method`:
  - `inter_size`: the size of the intervention, as a fraction of the original transmission rate between subpopulations

# Returns

An array with the final sizes of the S, I, and R compartments, and the total number of infections.
"""
function calculate_inter_final_size(
    ode,
    initial_states,
    tspan,
    beta_parameters,
    gamma,
    beta_mat_method;
    inter_size = 1.0,
)
    @unpack beta_LL, beta_MM, beta_HH, off_diag_beta_scaling, rho =
        beta_parameters

    inter_beta_MM, inter_beta_LL = map(
        beta_other -> calculate_inter_beta_reduction(
            beta_other, beta_HH, inter_size
        ),
        [beta_MM, beta_LL],
    )

    beta_mat_p = (;
        beta_HH = beta_HH,
        beta_MM = inter_beta_MM,
        beta_LL = inter_beta_LL,
        off_diag_beta_scaling,
        rho = rho,
    )

    beta_mat_inter = create_beta_mat(beta_mat_p, beta_mat_method)

    p_inter = SIRParameters(beta_mat_inter, gamma)

    final_seroprevs = sir_model_finalsize(
        ode, initial_states, tspan, p_inter
    )

    seroprev_results = SeroprevResults(final_seroprevs..., sum(final_seroprevs))

    return seroprev_results
end

"""
    calculate_inter_beta_reduction(
        beta_other,
        beta_HH,
        inter_size,
    )

Calculate the reduced value of beta after an intervention. A 100% reduction results in the beta value of the High Adherence group, whereas a 50% reduction results in a beta value that is the mean of the initial beta value and the value of the High Adherence group.
"""
function calculate_inter_beta_reduction(
    beta_other,
    beta_HH,
    inter_size,
)
    return beta_other - (beta_other - beta_HH) * inter_size
end

"""
    all_inter_seroprev_reduction(
    	seroprev_results,
    	off_diag_beta_scaling_range,
    	intervention_size_range,
    	seroprev_type = :overall_seroprev,
    	central_measure_label = "mean",
    	bounds_quantile = 0.05,
    )

Calculate seroprevalence reductions for all interventions included in the `seroprev_results` struct of arrays (SeroprevResults)
"""
function all_inter_seroprev_reduction(
    seroprev_results,
    off_diag_beta_scaling_range,
    intervention_size_range,
    seroprev_type = :overall_seroprev,
    central_measure_label = "mean",
    bounds_quantile = 0.05,
)
    intervention_effect_summary = Array{InterventionEffectSummary}(
        undef,
        length(intervention_size_range),
        length(off_diag_beta_scaling_range),
    )

    for (j, off_diag_beta_scaling) in pairs(off_diag_beta_scaling_range)
        baseline_seroprev = extract_seroprevs(
            seroprev_results,
            off_diag_beta_scaling,
            0.0,
            seroprev_type,
        )
        for (i, intervention_size) in pairs(intervention_size_range)
            intervention_effect_summary[i, j] = InterventionEffectSummary(
                calculate_inter_seroprev_reduction(
                    baseline_seroprev,
                    extract_seroprevs(
                        seroprev_results,
                        off_diag_beta_scaling,
                        intervention_size,
                        seroprev_type,
                    ),
                    central_measure_label,
                    bounds_quantile,
                ),
                off_diag_beta_scaling,
                intervention_size,
            )
        end
    end

    return StructArrays.StructArray(intervention_effect_summary)
end

"""
    calculate_inter_seroprev_reduction(
    	seroprev_results::T1,
    	off_diag_beta_scaling::T2,
    	intervention_size::T2,
    	seroprev_type = :overall_seroprev,
    	central_measure_label = "mean",
    	bounds_quantile = 0.05,
    ) where {T1<:StructArrays.StructArray{<:InterventionEffect},T2<:AbstractFloat}

Calculate the reduction in seroprevalence resulting from an intervention with given effectiveness.
"""
function calculate_inter_seroprev_reduction(
    seroprev_results::T1,
    off_diag_beta_scaling::T2,
    intervention_size::T2,
    seroprev_type = :overall_seroprev,
    central_measure_label = "mean",
    bounds_quantile = 0.05,
) where {T1<:StructArrays.StructArray{<:InterventionEffect},T2<:AbstractFloat}
    return calculate_inter_seroprev_reduction(
        extract_seroprevs(
            seroprev_results,
            off_diag_beta_scaling,
            0.0,
            seroprev_type,
        ),
        extract_seroprevs(
            seroprev_results,
            off_diag_beta_scaling,
            intervention_size,
            seroprev_type,
        ),
        central_measure_label,
        bounds_quantile,
    )
end

function calculate_inter_seroprev_reduction(
    baseline_seroprev_results::T1,
    intervention_seroprev_results::T1,
    central_measure_label = "mean",
    bounds_quantile = 0.05,
) where {T1<:Vector{<:AbstractFloat}}
    return calculate_seroprev_summary(
        (intervention_seroprev_results .- baseline_seroprev_results) ./
        baseline_seroprev_results,
        central_measure_label,
        bounds_quantile,
    )
end

"""
    extract_seroprevs(
    	seroprev_results::T1,
    	off_diag_beta_scaling::T2,
    	intervention_size::T2,
    	seroprev_type=:overall_seroprev
    ) where {T1<:StructArrays.StructArray{<:InterventionEffect},T2<:AbstractFloat}

Extract the appropriate vector of seroprevalence values from the StructArray of results.
The SA is filtered by the value of the off diagonal beta scaling value (assortativity), and the size of the intervention applied.
Only one seroprevalence value is extracted e.g., overall, or Low-Ahderence class, etc.

Returns a vector of seroprevalence values of the same type as the underlying data in the StructArray e.g., Float64
"""
function extract_seroprevs(
    seroprev_results::T1,
    off_diag_beta_scaling::T2,
    intervention_size::T2,
    seroprev_type = :overall_seroprev,
) where {T1<:StructArrays.StructArray{<:InterventionEffect},T2<:AbstractFloat}
    seroprev_vec = Vector{
        typeof(seroprev_results.seroprev_results[1][1])
    }(
        undef, size(seroprev_results.seroprev_results, 1)
    )

    seroprev_vec .= getproperty(
        StructArrays.StructArray(
            StructArrays.StructArray(
                filter(
                    sa ->
                        sa.off_diag_beta_scaling == off_diag_beta_scaling &&
                            sa.intervention_size == intervention_size,
                    seroprev_results,
                ),
            ).seroprev_results,
        ),
        seroprev_type,
    )
    return seroprev_vec
end

"""
    calculate_seroprev_summary(
    	seroprev_vec,
    	central_measure_label = "mean",
    	bounds_quantile = 0.05,
    )

Calculate the summary results (central measures, lower & upper quantile) for a given seroprevalence value.
Returns a SeroprevResultsSummary struct that contains labels for the type of seroprevalence returned (i.e., overall or class-specific), as well as the size of the quantile bounds.
"""
function calculate_seroprev_summary(
    seroprev_vec,
    central_measure_label = "mean",
    bounds_quantile = 0.05,
)
    lower_quantile = StatsBase.quantile(seroprev_vec, bounds_quantile / 2)
    upper_quantile = StatsBase.quantile(seroprev_vec, 1 - bounds_quantile / 2)
    central_measure = Match.@match central_measure_label begin
        "mean" => StatsBase.mean(seroprev_vec)
        "mode" => extract_mode(seroprev_vec)
        "median" => StatBase.median(seroprev_vec)
        _ => error(
            "Seroprevalence central measure must be one of mean, mode, or median"
        )
    end

    return SeroprevResultsSummary(
        central_measure,
        lower_quantile,
        upper_quantile,
        central_measure_label,
        bounds_quantile,
    )
end

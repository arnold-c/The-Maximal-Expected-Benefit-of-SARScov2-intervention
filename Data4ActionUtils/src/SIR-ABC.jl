using StaticArrays: StaticArrays
using Distributions: Distributions
using Distances: Distances
using ProgressMeter: ProgressMeter
using UnPack: @unpack
using Random: Random
using StatsBase: StatsBase
using StructArrays: StructArrays

"""
    run_abc(
    	off_diag_beta_scaling_range,
    	sir_parameters,
    	beta_mat_method;
    	seed = 1234,
    	nparticles = 200,
    	n_samples = Int64(1e3),
    )

Intake the SIR parameters, beta matrix creation structure, and the range of assortativities, and parameterize the model using ABC Rejection Sampling.

  - `n_samples` refers to the number of random values drawn for each parameter in the initial ABC fitting of the Rejection Sampling process.
  - `nparticles` refers to the number of successful fits required to complete the ABC fitting, after the initial ABC step has completed (that is used to determine the distance threshold for acceptance).
"""
function run_abc(
    off_diag_beta_scaling_range,
    sir_parameters,
    beta_mat_method;
    seed = 1234,
    nparticles = 200,
    n_samples = Int64(1e3),
)
    init_abc_params_posterior = initial_abc(
        off_diag_beta_scaling_range,
        sir_parameters,
        beta_mat_method;
        seed = seed,
        n_samples = n_samples,
    )

    @unpack gamma, initial_states, tspan = sir_parameters

    # set thresholds for subsequent ABC as the 0.5th percentile for distances in initial ABC
    Random.seed!(seed)
    thresholds = map(
        i -> StatsBase.quantile(init_abc_params_posterior[i].distances, 0.005),
        eachindex(off_diag_beta_scaling_range),
    )

    abcreject_vec = Vector{ABCRejectionResults}(
        undef, length(off_diag_beta_scaling_range)
    )

    for (i, off_diag_beta_scaling) in pairs(off_diag_beta_scaling_range)
        constants = ABCConstants(
            beta_LL,
            off_diag_beta_scaling,
            gamma,
            initial_states,
            tspan,
        )

        abcreject_vec[i] = simulateABCRejection(
            abc_sirmodel,
            ABCInputParametersDistributions(
                repeat([Distributions.Uniform(0.0, 1.0)], 3)...
            ),
            constants,
            obs_final_Cs,
            beta_mat_method,
            thresholds[i],
            nparticles;
            progress = true,
        )
    end

    return abcreject_vec
end

"""
    initial_abc(
    	off_diag_beta_scaling_range,
    	sir_parameters,
    	beta_mat_method;
    	seed = 1234,
    	n_samples = Int64(1e3),
    )

Run the initial ABC step in the fitting process.
Creates `n_samples` random parameter sets from a Uniform distribution and simulates forward to produce a distance between the final seroprevalence values and the observed seroprevalences.
Returns a vector of initial ABC results containing the parameter sets and associated distances, for each level of assortativity in `off_diag_beta_scaling_range`.
"""
function initial_abc(
    off_diag_beta_scaling_range,
    sir_parameters,
    beta_mat_method;
    seed = 1234,
    n_samples = Int64(1e3),
)
    Random.seed!(seed)
    @unpack gamma, initial_states, tspan = sir_parameters

    # Set to one to ensure off diagonal betas correspond to assortativity correctly
    @assert beta_LL == 1.0

    init_abc_params_posterior = Vector{ABCInitialResults}(
        undef, length(off_diag_beta_scaling_range)
    )
    abc_params = Vector{ABCParams}(undef, n_samples)

    prog = ProgressMeter.Progress(
        n_samples * length(off_diag_beta_scaling_range)
    )
    for (off_diag_num, off_diag_beta_scaling) in
        pairs(off_diag_beta_scaling_range)
        distances = zeros(Float64, n_samples)
        for run in 1:(n_samples)
            beta_HH, beta_MM = correct_beta_draw_order(
                rand(Distributions.Uniform(0.0, 1.0)),
                rand(Distributions.Uniform(0.0, 1.0)),
            )

            params = ABCInputParameters(
                beta_HH,
                beta_MM,
                rand(Distributions.Uniform(0.0, 1.0)),
            )

            constants = ABCConstants(
                beta_LL,
                off_diag_beta_scaling,
                gamma,
                initial_states,
                tspan,
            )

            distances[run], beta_mat = abc_sirmodel(
                params, constants, obs_final_Cs, beta_mat_method
            )[(:distance, :beta_mat)]

            abc_params[run] = ABCParams(
                beta_HH,
                beta_MM,
                beta_LL,
                off_diag_beta_scaling,
                params.rho_prior,
                beta_mat,
            )
        end
        abc_params = StructArrays.StructArray(abc_params)
        init_abc_params_posterior[off_diag_num] = ABCInitialResults(
            abc_params,
            distances,
        )
        ProgressMeter.next!(prog)
    end

    return init_abc_params_posterior
end

"""
    abc_sirmodel(params, constants, targetdata, beta_mat_method)

Simulate an SIR model and calculate the distance between the simulated data and the target data.

# Arguments

  - `params`: A ABCInputParameters struct of model parameters.
  - `constants`: A ABCConstants struct of constants required for the simulation.
  - `targetdata`: The target data to compare the simulated data to.
  - `beta_mat_method`: the method (a struct) used to create the beta transmission matrix from input parameters

# Returns

A tuple containing the distance between the simulated data seroprevalence and the target data seroprevalence, the simulated data seroprevalence struct, and the beta matrix used to generate the simulated data.
"""
function abc_sirmodel(params, constants, targetdata, beta_mat_method)
    @unpack beta_HH_prior, beta_MM_prior, rho_prior = params
    @unpack beta_LL, off_diag_beta_scaling, gamma, initial_states, tspan =
        constants

    beta_mat_p = create_beta_mat_parameters_sv(
        beta_HH_prior,
        beta_MM_prior,
        beta_LL,
        off_diag_beta_scaling,
        rho_prior,
    )

    beta_mat = create_beta_mat(beta_mat_p, beta_mat_method)

    p_run = SIRParameters(beta_mat, gamma)

    final_seroprevs = sir_model_finalsize(
        sir_ode, initial_states, tspan, p_run
    )

    distance = Distances.evaluate(
        Distances.Euclidean(), final_seroprevs, targetdata
    )

    seroprev_results = SeroprevResults(final_seroprevs..., sum(final_seroprevs))

    return (; distance, seroprev_results, beta_mat)
end

"""
    simulateABCRejection(simfunction, priors, constants, targetdata, threshold, nparticles;
        maxiterations=nothing, progress=false)

Simulate an Approximate Bayesian Computation (ABC) rejection algorithm to estimate the parameters of a model.

# Arguments

  - `simfunction::Function`: A function that simulates the model and returns the distance between the simulated data and the target data, the simulated data, and the parameters used to generate the simulated data.
  - `priors::ABCInputParametersDistributions`: A struct of prior distributions for the model parameters.
  - `constants`: A tuple of constants required for the simulation.
  - `targetdata`: The target data to compare the simulated data to.
  - `threshold`: The maximum distance between the simulated data and the target data that is considered acceptable.
  - `nparticles`: The number of particles to simulate (successfully return distances < threshold).
  - `maxiterations=nothing`: The maximum number of iterations to run the simulation. If not specified, defaults to 1000 times the number of particles.
  - `progress=false`: Whether to display a progress bar during the simulation.

# Returns

An `ABCRejectionResults` object containing the accepted parameters, simulated seroprevalence, distances, number of simulations run, number of particles accepted, and acceptance ratio.
"""
function simulateABCRejection(
    simfunction::T1,
    priors::T2,
    constants,
    targetdata,
    beta_mat_method,
    threshold,
    nparticles;
    maxiterations = nothing,
    progress = false,
) where {T1<:Function,T2<:ABCInputParametersDistributions}
    if isnothing(maxiterations)
        maxiterations = 1000 * nparticles
    end

    @assert propertynames(priors) ==
        (:beta_HH_prior, :beta_MM_prior, :rho_prior)

    p = ProgressMeter.Progress(nparticles, "ABC Rejection Sampling")

    nsims = 0
    naccepted = 0
    accratio = 0
    seroprev_results = Vector{SeroprevResults}(undef, nparticles)

    accepted_distances = zeros(Float64, nparticles)
    abc_params = Vector{ABCParams}(undef, nparticles)
    while naccepted < nparticles && nsims < maxiterations
        beta_HH_run, beta_MM_run = correct_beta_draw_order(
            rand(priors.beta_HH_prior), rand(priors.beta_MM_prior)
        )

        corrected_params = ABCInputParameters(
            beta_HH_run,
            beta_MM_run,
            rand(priors.rho_prior),
        )

        distance, sim_seroprev, beta_mat = simfunction(
            corrected_params, constants, targetdata, beta_mat_method
        )

        if distance < threshold
            naccepted += 1
            seroprev_results[naccepted] = sim_seroprev

            accepted_distances[naccepted] = distance
            abc_params[naccepted] = ABCParams(
                beta_HH_run,
                beta_MM_run,
                constants.beta_LL,
                constants.off_diag_beta_scaling,
                corrected_params.rho_prior,
                beta_mat,
            )

            if progress == true
                ProgressMeter.next!(p)
            end
        end

        nsims += 1
    end

    if naccepted < nparticles && nsims == maxiterations
        @info "Warning: Only $naccepted particles naccepted, $nsims simulations run. You might want to try a smaller threshold or increase maxiterations."
    end

    abc_params = StructArrays.StructArray(abc_params)
    seroprev_results = StructArrays.StructArray(seroprev_results)

    accratio = round(naccepted / nsims; digits = 3)

    return ABCRejectionResults(
        abc_params,
        seroprev_results,
        accepted_distances,
        nsims,
        naccepted,
        accratio,
    )
end

"""
    calculate_lowest_dist_off_diag_scaling(abcreject_vec)

Calculate the degree of assortativity (off diagonal beta scaling value) that results in the smallest ABC distances (best fit).
"""
function calculate_lowest_dist_off_diag_scaling(abcreject_vec)
    off_diag_beta_scaling = 0.0
    min_dist = 1.0
    for i in eachindex(abcreject_vec)
        med_dist = StatsBase.median(abcreject_vec[i].distances)
        if i == 1 || med_dist < min_dist
            off_diag_beta_scaling =
                abcreject_vec[i].params[i].off_diag_beta_scaling
            min_dist = med_dist
        end
    end
    return off_diag_beta_scaling
end

using DataFrames: DataFrames
using StructArrays: StructArrays
using StatsBase: StatsBase
using Printf: @sprintf

"""
    beta_dist_table(
    	abcreject_vec,
    	off_diag_beta_scalings = [0.0, 0.5, 1.0],
    	percentiles = 95,
    )

Create and return a data frame of diagonal beta transmission values for given values of assortativity (off_diag_beta_scalings), with associated percentile intervals.
"""
function beta_dist_table(
    abcreject_vec,
    off_diag_beta_scalings = [0.0, 0.5, 1.0],
    percentiles = 95,
)
    @assert percentiles > 0 && percentiles < 100
    lower_quantile = (100 - percentiles) / 200
    upper_quantile = 1 - lower_quantile

    beta_table = DataFrames.DataFrame(
        "Beta Parameter" => ["Beta LL", "Beta MM", "Beta HH"]
    )

    for off_diag_beta_scaling in off_diag_beta_scalings
        assort_reject_vec = StructArrays.StructVector(
            filter(
                x ->
                    x.params.off_diag_beta_scaling[1] ==
                    off_diag_beta_scaling,
                abcreject_vec,
            ),
        )

        @assert length(assort_reject_vec.params) == 1
        assort_params = assort_reject_vec.params[1]

        assort_beta_vec = Vector{String}(
            undef, 3
        )
        for (i, beta) in pairs([:beta_HH, :beta_MM, :beta_LL])
            assort_beta = assort_params.rho .* getproperty(assort_params, beta)

            assort_lower_beta, assort_median_beta, assort_upper_beta = StatsBase.quantile(
                assort_beta, [lower_quantile, 0.5, upper_quantile]
            )

            assort_beta_vec[i] = @sprintf "%.4f (%.4f - %.4f)" assort_median_beta assort_lower_beta assort_upper_beta
        end

        beta_table[!, "$off_diag_beta_scaling"] = assort_beta_vec
    end

    return beta_table
end

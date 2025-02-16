import Base: getindex
using StructArrays: StructArrays
using LabelledArrays: LabelledArrays
using Distributions: Distributions

struct ABCParams
    beta_HH
    beta_MM
    beta_LL
    off_diag_beta_scaling
    rho
    beta_mat
end

struct SeroprevResults
    class_L_seroprev
    class_M_seroprev
    class_H_seroprev
    overall_seroprev
end

Base.getindex(x::SeroprevResults, i::Int) = getfield(x, i)
function Base.getindex(x::SeroprevResults, i::UnitRange{<:Int})
    return map(ind -> getfield(x, ind), i)
end
function Base.getindex(x::SeroprevResults, i::T) where {T<:Tuple}
    return collect(map(ind -> getfield(x, ind), i))
end

struct ABCRejectionResults{T1<:Int,T2<:AbstractFloat,T3<:Vector{<:T2}}
    params
    seroprevs
    distances::T3
    nsims::T1
    naccepted::T1
    accratio::T2
end

struct ABCInitialResults{
    T1<:StructArrays.StructArray{<:ABCParams},T2<:Vector{<:AbstractFloat}
}
    params::T1
    distances::T2
end

struct InterventionEffect{T1<:SeroprevResults}
    seroprev_results::T1
    off_diag_beta_scaling
    intervention_size
end

struct SeroprevResultsSummary{T2<:AbstractString,T1<:AbstractFloat}
    central_measure::T1
    lower_quantile::T1
    upper_quantile::T1
    central_measure_label::T2
    quantile_vals::T1
end

struct InterventionEffectSummary{T1<:SeroprevResultsSummary}
    seroprev_results_summary::T1
    off_diag_beta_scaling
    intervention_size
end

abstract type AbstractBetaMatMethod end
struct CopyColumns <: AbstractBetaMatMethod end
struct CopyRows <: AbstractBetaMatMethod end
struct CopyConstant <: AbstractBetaMatMethod end

struct SIRParameters{T1<:LabelledArrays.SLArray,T2}
    beta_mat::T1
    gamma::T2
end

struct ABCInputParameters{T1<:AbstractFloat}
    beta_HH_prior::T1
    beta_MM_prior::T1
    rho_prior::T1
end

struct ABCInputParametersDistributions{T1<:Distributions.Distribution}
    beta_HH_prior::T1
    beta_MM_prior::T1
    rho_prior::T1
end

struct ABCConstants{T1<:AbstractFloat,T2<:LabelledArrays.SLArray,T3<:Tuple}
    beta_LL::T1
    off_diag_beta_scaling::T1
    gamma::T1
    initial_states::T2
    tspan::T3
end

struct ABCSetupParameters{
    T1<:AbstractFloat,
    T2<:LabelledArrays.SLArray,
    T3<:Tuple,
    T4<:AbstractVector{<:T1},
}
    gamma::T1
    initial_states::T2
    tspan::T3
    obs_final_Cs::T4
end

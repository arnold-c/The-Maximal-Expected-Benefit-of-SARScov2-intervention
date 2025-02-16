module Data4ActionUtils

include("SIR-structs.jl")
export ABCRejectionResults,
    ABCInitialResults, SeroprevResults, ABCParams, InterventionEffect,
    CopyColumns, CopyRows,
    CopyConstant, SeroprevResultsSummary, InterventionEffectSummary,
    SIRParameters, ABCConstants, ABCSetupParameters, ABCInputParameters

include("SIR-constants.jl")
export classLprop, classMprop, classHprop, beta_LL, obs_final_Cs

include("SIR-utils.jl")
export sir_ode, sir_model_finalsize, correct_beta_draw_order, run_abc,
    reshape_vec_of_beta_mat, create_beta_mat_parameters_sv,
    create_state_labels_sv

include("utils.jl")
export extract_mode

include("SIR-beta-matrices.jl")
export create_beta_mat

include("SIR-ABC.jl")
export abcrejection,
    abc_sirmodel, simulateABCRejection, calculate_lowest_dist_off_diag_scaling

include("SIR-intervention.jl")
export calculate_inter_final_size,
    intervention_effect,
    calculate_inter_beta_reduction,
    calculate_seroprev_summary,
    calculate_inter_seroprev_reduction,
    extract_seroprevs

@static if false
    include("../test/runtests.jl")
    include("../test/SIR-structs.jl")
    include("../test/SIR-beta-matrices.jl")
    include("../test/SIR-utils.jl")
    include("../test/SIR-ABC.jl")
    include("../test/SIR-intervention.jl")
end

end

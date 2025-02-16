using UnPack: @unpack
using LabelledArrays: @SLArray

"""
	beta_mat_sa(beta_mat)

Convert a beta transmission matrix into a Static Labeled Array
"""
const beta_mat_sa = @SLArray (3, 3) Tuple([
    :beta_HH :beta_HM :beta_HL
    :beta_MH :beta_MM :beta_ML
    :beta_LH :beta_LM :beta_LL
])


"""
    create_beta_mat(parameters, ::Type{CopyColumns})

Create a beta transmission matrix that sets the off-diagonal elements equal to a scaled version of the diagonal elements in the same column.
For example, `beta_HL = off_diag_beta_scaling * beta_LL`.

=====================================================================================================

"""
function create_beta_mat(parameters, ::Type{CopyColumns})
    @unpack beta_HH, beta_MM, beta_LL, off_diag_beta_scaling, rho =
        parameters
    betas = (beta_HH, beta_MM, beta_LL)

    beta_mat = ones(Float64, 3, 3)
    for j in 1:3, i in 1:3
        if i == j
            beta_mat[i, j] = betas[i]
        else
            beta_mat[i, j] = betas[j] * off_diag_beta_scaling
        end
    end
    beta_mat *= rho

    return beta_mat_sa(beta_mat)
end

"""
    create_beta_mat(parameters, ::Type{CopyRows})

Create a beta transmission matrix that sets the off-diagonal elements equal to a scaled version of the diagonal elements in the same row.
For example, `beta_HL = off_diag_beta_scaling * beta_HH`.

=====================================================================================================
"""
function create_beta_mat(parameters, ::Type{CopyRows})
    @unpack beta_HH, beta_MM, beta_LL, off_diag_beta_scaling, rho =
        parameters
    betas = (beta_HH, beta_MM, beta_LL)
    beta_mat = ones(Float64, 3, 3)
    for j in 1:3, i in 1:3
        if i == j
            beta_mat[i, j] = betas[i]
        else
            beta_mat[i, j] = betas[i] * off_diag_beta_scaling
        end
    end
    beta_mat *= rho

    return beta_mat_sa(beta_mat)
end

"""
    create_beta_mat(parameters, ::Type{CopyConstant})

Create a beta transmission matrix that sets the off-diagonal elements equal to a scaled version of the highest risk transmission value, `beta_LL`.
For example, `beta_HL = off_diag_beta_scaling * beta_LL`.

=====================================================================================================
"""
function create_beta_mat(parameters, ::Type{CopyConstant})
    @unpack beta_HH, beta_MM, beta_LL, off_diag_beta_scaling, rho =
        parameters
    betas = (beta_HH, beta_MM, beta_LL)
    beta_mat = ones(Float64, 3, 3)
    for j in 1:3, i in 1:3
        if i == j
            beta_mat[i, j] = betas[i]
        else
            beta_mat[i, j] = beta_LL * off_diag_beta_scaling
        end
    end
    beta_mat *= rho

    return beta_mat_sa(beta_mat)
end

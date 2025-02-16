using KernelDensity: KernelDensity

"""
    extract_mode(abc_vector)

Return the mode of a vector of values.
"""
function extract_mode(abc_vector)
    U = KernelDensity.kde(abc_vector)
    imax = findmax(U.density)[2]
    U_mode = U.x[imax]

    return U_mode
end

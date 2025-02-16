using Data4ActionUtils
using Test
using Aqua
using JET

@testset "Data4ActionUtils.jl" verbose = true begin
    # @testset "Code quality (Aqua.jl)" begin
    #     Aqua.test_all(Data4ActionUtils)
    # end
    # @testset "Code linting (JET.jl)" begin
    #     JET.test_package(Data4ActionUtils; target_defined_modules=true)
    # end
    include("SIR-structs.jl")
    include("SIR-beta-matrices.jl")
    include("SIR-utils.jl")
    include("SIR-ABC.jl")
    include("SIR-intervention.jl")
end

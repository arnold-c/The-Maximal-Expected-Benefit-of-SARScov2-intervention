using .Data4ActionUtils

@testset "SIR-structs.jl" begin
    @testset "SeroprevResults" begin
        seroprev_results = SeroprevResults(1.0, 2.0, 3.0, 6.0)
        @test isequal(
            seroprev_results[1],
            seroprev_results.class_L_seroprev,
        )

        @test isequal(
            seroprev_results[(1, 2)],
            [
                seroprev_results.class_L_seroprev,
                seroprev_results.class_M_seroprev,
            ],
        )

        @test isequal(
            sum(seroprev_results[1:3]),
            seroprev_results.overall_seroprev,
        )
        @test isequal(
            seroprev_results.overall_seroprev,
            6.0,
        )
    end
end

using .Data4ActionUtils
using StructArrays

@testset "SIR-intervention.jl" verbose = true begin
    @testset "Beta Reduction" begin
        @test isequal(
            calculate_inter_beta_reduction(
                2.0, 1.0, 1.0
            ),
            1.0,
        )

        @test isequal(
            calculate_inter_beta_reduction(
                2.0, 1.0, 0.0
            ),
            2.0,
        )

        @test isequal(
            calculate_inter_beta_reduction(
                2.0, 1.0, 0.5
            ),
            1.5,
        )

        @test isequal(
            calculate_inter_beta_reduction(
                2.0, 1.0, 0.7
            ),
            1.3,
        )
    end

    @testset "Extract seroprevalence" begin
        seroprev_results = StructArray(
            repeat(
                [InterventionEffect(
                    SeroprevResults(0.2, 0.1, 0.0, 0.3),
                    1.0,
                    1.0
                )],
                10
            )
        )

        @test isequal(
            extract_seroprevs(
                seroprev_results,
                1.0,
                1.0,
                :overall_seroprev
            ),
            repeat(Float64[0.3], 10)
        )
        @test isequal(
            extract_seroprevs(
                seroprev_results,
                1.0,
                1.0,
                :class_L_seroprev
            ),
            repeat(Float64[0.2], 10)
        )
    end

    @testset "Seroprevalence reduction" begin
        # all_inter_seroprev_reduction()
    end
end

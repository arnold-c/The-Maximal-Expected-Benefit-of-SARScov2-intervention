using .Data4ActionUtils
using StaticArrays
using StaticArrays: beta

@testset "SIR-beta-matrices.jl" verbose = true begin
    params = create_beta_mat_parameters_sv(
        1,
        5,
        10,
        0.5,
        1,
    )

    params2 = create_beta_mat_parameters_sv(
        1,
        5,
        10,
        0.5,
        0.1,
    )

    @testset "Copy Columns" begin
        beta_mat = create_beta_mat(params, CopyColumns)
        ref_mat = [
            1 2.5 5
            0.5 5 5
            0.5 2.5 10
        ]

        @test isequal(
            beta_mat,
            ref_mat,
        )
        beta_mat2 = create_beta_mat(params2, CopyColumns)
        @test isequal(
            beta_mat2,
            ref_mat .* 0.1,
        )
    end

    @testset "Copy Rows" begin
        beta_mat = create_beta_mat(params, CopyRows)
        ref_mat = [
            1 0.5 0.5
            2.5 5 2.5
            5 5 10
        ]

        @test isequal(
            beta_mat,
            ref_mat,
        )
        beta_mat2 = create_beta_mat(params2, CopyRows)
        @test isequal(
            beta_mat2,
            ref_mat .* 0.1,
        )
    end

    @testset "Copy Constant" begin
        beta_mat = create_beta_mat(params, CopyConstant)
        ref_mat = [
            1 5 5
            5 5 5
            5 5 10
        ]
        @test isequal(
            beta_mat,
            ref_mat,
        )
        beta_mat2 = create_beta_mat(params2, CopyConstant)
        @test isequal(
            beta_mat2,
            ref_mat .* 0.1,
        )
    end

    @testset "Labelling" begin
        beta_mat = create_beta_mat(params, CopyColumns)

        @test isequal(
            propertynames(beta_mat),
            Tuple([
                :beta_HH :beta_HM :beta_HL
                :beta_MH :beta_MM :beta_ML
                :beta_LH :beta_LM :beta_LL
            ])
        )

        @test isequal(
            beta_mat.beta_HH,
            1
        )

        @test isequal(
            beta_mat.beta_LL,
            10
        )

        @test isequal(
            beta_mat.beta_HL,
            5
        )

        @test isequal(
            beta_mat.beta_LH,
            0.5
        )

    end
end

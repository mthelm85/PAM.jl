using Distances
using PAM
using Test

@testset "PAM.jl" begin
    X = rand(2, 100)
    D = pairwise(Euclidean(), X, dims=2)
    k = 4

    pam(D,k)
end

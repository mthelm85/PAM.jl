using BenchmarkTools
using Distances
using PAM

X = rand(2, 100)
D = pairwise(Euclidean(), X, dims=2)
k = 4

@btime pam($D,$k)
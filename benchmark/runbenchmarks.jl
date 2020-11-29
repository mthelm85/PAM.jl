using BenchmarkTools
using Distances
import PAM.build_phase
import PAM.swap_phase

X = rand(2, 100)
D = pairwise(Euclidean(), X, dims=2)
k = 4

M = build_phase(D,k)

function swap_phase2(D,k,M)
    converged = false

    while converged == false
        M = deepcopy(M)
        Mⱼ = Vector{Int}(undef,k)
        global assignments = [findmin([D[i,m] for m in M])[2] for i in 1:size(D,1)]
        # Find minimum sum for each cluster (i.e. find the best medoid)
        for j in 1:k
            cluster = assignments .== j
            distances = sum(D[cluster, cluster][:,i] for i in 1:sum(cluster))
            Mⱼ[j] = findfirst(x -> x == findmin(distances)[2], cumsum(cluster))
        end

        if sort(M) == sort(Mⱼ) 
            converged = true
        else
            M = Mⱼ
        end
    end

    return (medoids=M,assignments=assignments)
end

@btime swap_phase($D,$k,$M)
@btime swap_phase2($D,$k,$M)
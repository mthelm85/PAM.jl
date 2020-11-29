using BenchmarkTools
using Distances
using StaticArrays
# import PAM.build_phase
# import PAM.swap_phase

X = rand(2, 100)
D = pairwise(Euclidean(), X, dims=2)
k = 4

function build_phase(D,k)
    N = size(D,1)
    total_dists = [sum(D[:,j]) for j in 1:N]

    # initialize medoids with index of object with shortest distance to all others
    medoids = Int[findmin(total_dists)[2]]

    for j in 1:k-1 
        TD = Vector{Float64}(undef,N)
        for a in 1:N
            td = 0.0
            for i in 1:N
                td += min(D[a,i], [D[i,m] for m in medoids]...)
            end
            TD[a] = td
        end
        push!(medoids, findmin(TD)[2])
    end

    return medoids
end

build_phase(D,k)

@btime build_phase($D,$k)
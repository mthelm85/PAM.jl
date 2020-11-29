using BenchmarkTools
using Distances
using ProfileView
# import PAM.build_phase
import PAM.swap_phase

X = rand(2, 5)
D = pairwise(Euclidean(), X, dims=2)
k = 2

function build_phase(D,k)
    N = size(D,1)
    total_dists = [sum(D[:,j]) for j in 1:N]

    medoids = Int[findmin(total_dists)[2]]
    for j in 1:k-1 
        TD = Vector{Float64}(undef,N)
        for a in 1:N
            td = 0.0
            for i in 1:N
                td += reduce(min, (D[i,m] for m in medoids), init=D[a,i])
            end
            TD[a] = td
        end
        push!(medoids, findmin(TD)[2])
    end

    return medoids
end

# Faster version
function build_phase2(D, k)
    N = size(D, 1)
    E = deepcopy(D)
    CurrMin = [sum(E[:,j]) for j in 1:N]
    Flags = fill(1, N)
    medoids = Vector{Int}(undef, k)
    @inbounds for loop in 1:k
        TempMin, Idx = CurrMin[1], 1
        for Pt in 2:N
            Flags[Pt] != 1 && continue
            if Flags[Idx] != 1
                TempMin, Idx = CurrMin[Pt], Pt
            elseif TempMin > CurrMin[Pt]
                TempMin, Idx = CurrMin[Pt], Pt
            end
        end
        medoids[loop] = Idx
        Flags[Idx] = 0
        for i in 1:N, j in 1:N
            if E[j,i] > D[i,Idx]
                CurrMin[j] -= E[j, i] - D[i, Idx]
                E[j,i] = D[i,Idx]
            end
        end
    end
    return medoids
end

M = build_phase(D,k)

function swap_phase(D,k,M)
    # Perform clustering
    assignments = [findmin([D[i,m] for m in M])[2] for i in 1:size(D,1)]

    Mⱼ = Vector{Int}(undef,k)

    # Find minimum sum for each cluster (i.e. find the best medoid)
    for j in 1:k
        distances = sum(D[assignments .== j, assignments .== j][:,i] for i in 1:sum(assignments .== j))
        Mⱼ[j] = findfirst(x -> x == findmin(distances)[2], cumsum(assignments .== j))
    end

    if sort(M) == sort(Mⱼ) 
        return (medoids=Mⱼ,assignments=assignments)
    else
        swap_phase(D,k,Mⱼ)
    end
end
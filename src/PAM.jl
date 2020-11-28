module PAM

using Distances

export pam

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
                td += minimum(vcat(D[a,i],[D[i,m] for m in medoids]...))
            end
            TD[a] = td
        end
        push!(medoids, findmin(TD)[2])
    end

    return medoids
end

function swap_phase(D,k,M)
    # Perform clustering
    assignments = [findmin([D[i,m] for m in M])[2] for i in 1:size(D,1)]

    # M₁
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

function pam(D,k)
    M = build_phase(D,k)
    return swap_phase(D,k,M)
end

end

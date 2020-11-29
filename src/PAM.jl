module PAM

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
                td += reduce(min, (D[i,m] for m in medoids), init=D[a,i])
            end
            TD[a] = td
        end
        push!(medoids, findmin(TD)[2])
    end

    return medoids
end

function swap_phase(D,k,M)
    M = copy(M)
    Mⱼ = similar(M)
    # Perform clustering
    assignments = Int[findmin(view(D, i,M))[2] for i in axes(D,1)]
    cumulative = similar(assignments)
    while true
        # Find minimum sum for each cluster (i.e. find the best medoid)
        for i in 1:k
            cluster = assignments .== i
            cumsum!(cumulative, cluster)
            D_slice = view(D, cluster, cluster)
            distances = sum(@view D_slice[:,i] for i in 1:last(cumulative))
            smallest_distance_idx = findmin(distances)[2]
            Mⱼ[i] = findfirst(==(smallest_distance_idx), cumulative)::Int
        end
        if sort(M) == sort(Mⱼ)
            return (medoids=M,assignments=assignments)
        else
            M,Mⱼ = Mⱼ,M
        end
    end
end

function pam(D,k)
    M = build_phase(D,k)
    return swap_phase(D,k,M)
end

end

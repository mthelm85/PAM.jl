function build_phase(D, k)
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
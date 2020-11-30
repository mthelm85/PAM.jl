# PAM

### About

Partioning around medoids, in Julia.

* [Wikipedia page about PAM](https://en.wikipedia.org/wiki/K-medoids)
* [Findings Groups in Data (Chapter 2)](https://www.google.com/books/edition/Finding_Groups_in_Data/YeFQHiikNo0C?hl=en&gbpv=0)
* [Faster k-Medoids Clustering](https://arxiv.org/pdf/1810.05691.pdf)

### Usage

This package exports a single function:

```julia
pam(D::Array, k::Int)
```

`D` is a distance matrix and `k` is the number of groups desired.

### Example

```julia
using Distances

X = rand(2, 10)
D = pairwise(Euclidean(), X, dims=2)
k = 2

results = pam(D,k)

# Output:

(medoids = [8, 2], assignments = [2, 2, 2, 2, 2, 1, 1, 1, 1, 1])
```

### Cluster Quality Comparison

I've compared the results of the cluster quality from this implementation to the k-Medoids implementations in Clustering.jl as well as the `pam` function from R's `cluster` package. To compare the quality of the clusters, clustering was performed 1,000 times for different size matrices and values of `k`. At each iteration, the mean silhouette score was computed. Finally, the mean of all 1,000 mean silhouette scores was computed:



The comparisons were generated with the following code:

```julia
using Clustering
using Distances
using RCall
using StatsBase
using StatsPlots
using PAM

trials = 1_000
pamjl = Vector{Float64}(undef,trials)
rpam = Vector{Float64}(undef,trials)
clusteringjl = Vector{Float64}(undef,trials)
m = 2
n = 10
clusters = 2

for i in 1:trials
    X = rand(m, n)
    D = pairwise(Euclidean(), X, dims=2)
    Y = X'
    k = clusters
    @rput Y
    @rput k
    R"
    library(cluster)
    r_results = pam(Y,2)
    r_assignments = r_results[3]
    "
    pamjl_assignments = pam(D,k).assignments
    rpam_assignments = @rget r_assignments
    clusteringjl_assignments = kmedoids(D,k).assignments
    pamjl[i] = mean(silhouettes(pamjl_assignments, D))
    rpam[i] = mean(silhouettes(rpam_assignments[:clustering], D))
    clusteringjl[i] = mean(silhouettes(clusteringjl_assignments, D))
end

bar(
    [mean(pamjl),mean(rpam),mean(clusteringjl)],
    fillalpha=0.8,
    color=:orange,
    # xlabel="Package",
    ylabel="Mean of mean silhouette scores",
    legend=false,
    title="k = $clusters, X = $m × $n",
    xticks=(1:3, ["PAM.jl", "R clustering", "Clustering.jl"])
)
```
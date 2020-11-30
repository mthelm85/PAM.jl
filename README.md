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
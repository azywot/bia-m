include("utils/random_gen.jl")


n = 5
counts, histogram = permutation_test(n, factorial(n) * 1000)
histogram

include("utils/random_gen.jl")


n = 5
randomness_measure, counts, histogram = permutation_test(n, factorial(n) * 1000)
randomness_measure
histogram

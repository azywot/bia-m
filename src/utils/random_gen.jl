using Plots
using Statistics

"""
## Generate a random permutation of items 1..n.

- `n::Int`: number of items

returns: a permutation as a list
"""
function generate_random_permutation(n::Int)

    elements = collect(1:n)
    permutation = []

    while !isempty(elements)
        selected_idx = rand(1:length(elements))
        selected_element = elements[selected_idx]
        deleteat!(elements, selected_idx)
        push!(permutation, selected_element)
    end

    return permutation
end


"""
## Generating pairs of random but unique numbers 0..n-1 (for RW and SA).

- `n::Int`: number of items

returns: a list of randomly generated pairs
"""
function generate_random_pairs(n::Int)

    if n % 2 != 0
        error("Number of elements must be even.")
    end

    permutation = generate_random_permutation(n)
    pairs = [(permutation[i], permutation[i+1]) for i in 1:2:length(permutation)]
    return pairs

end


"""
## Generate a random unique pair from given range.

- `n::Int`: number of items

returns: a generated pair
"""
function generate_random_pair(n::Int)
    x1 = rand(0:n-1)
    x2 = (rand(0:n-2) + x1 + 1) % n
    return x1+1, x2+1
end


"""
## Assess permutation randomness
Histogram of unique permutations. TR function should generate each permutation with the same probability.
Therefore, std of number of occurences of unique permutation is used as randomness measure
1 - perfectly random, 0 - not random

- `n::Int`: number of items
- `num_samples::Int`: number of permuations to generate

returns: std of occurences, dictionary with permutations counts, histogram
"""
function permutation_test(n::Int, num_samples::Int)
    counts = Dict()
    for _ in 1:num_samples
        perm = generate_random_permutation(n)
        perm_str = join(perm)
        counts[perm_str] = get(counts, perm_str, 0) + 1
    end
    vals = collect(values(counts))
    histogram = bar(collect(keys(counts)), vals,
        orientation=:vertical,
        legend=false,
        title="Histogram of unique permuations",
        xlabel="Permutation",
        ylabel="Occurences")
    return 1 - std(vals) / num_samples, counts, histogram
end


# n = 5
# randomness_measure, counts, histogram = permutation_test(n, factorial(n) * 1000)
# randomness_measure
# histogram
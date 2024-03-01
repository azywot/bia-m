"""
## Generate a random permutation of items 1..n.

- `n::Int`: number of items

returns: a permutation as a list
"""
function generate_random_permutation(n)

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
function generate_random_pairs(n)

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
function generate_random_pair(n)
    x1 = rand(1:n)
    x2 = (rand(1:n-1) + x1 + 1) % (n + 1)
    return x1, x2
end


"""
## Assess permutation randomness
?uniform histogram of numbers on positions, uniqness of permutations?

- `n::Int`: number of items

returns: some measure of assessment
"""
function assess_perm_randomness(n)
    # TODO
    return 0
end
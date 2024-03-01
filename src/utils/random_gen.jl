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
## Generating pairs of random but unique numbers 0..n–1 (for RW and SA).

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

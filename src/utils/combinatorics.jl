"""
## Generate all possible paris from 1...n.

- `n::Int`: number of items

returns: possible paris from 1...n
"""
function generate_all_pairs(n::Int)
    pairs = []
    for i in 1:n
        for j in i+1:n
            push!(pairs, (i, j))
        end
    end 
    return pairs
end
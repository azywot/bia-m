include("../utils/random_gen.jl")
include("../utils/eval.jl")


"""
# Perform random search
- `N::Int`: number of nodes
- `distance_matrix::Matrix{Int}`: matrix of distances between nodes
- `time_limit::Float`: stopping condition

returns: best permutation found along with its cost
"""
function random_search(N, distance_matrix=nothing, time_limit)
    best_permutation = generate_random_permutation(N)
    best_cost = evaluate_solution(best_permutation, distance_matrix)

    start_time = time()

    while time() - start_time < time_limit
        permutation = generate_random_permutation(N)
        cost = evaluate_solution(permutation, distance_matrix)
        if cost < best_cost
            best_permutation = permutation
            best_cost = cost
        end
    end

    return best_permutation, best_cost
end

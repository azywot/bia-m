include("../utils/random_gen.jl")
include("../utils/eval.jl")


"""
# Perform random search
- `N::Int`: number of nodes
- `distance_matrix::Matrix{Int}`: matrix of distances between nodes
- `time_limit::Float`: stopping condition

returns: best permutation found along with its distance
"""
function random_search(N, distance_matrix=nothing, time_limit)
    best_permutation = generate_random_permutation(N)
    best_distance = evaluate_solution(best_permutation, distance_matrix)

    start_time = time()

    while time() - start_time < time_limit
        permutation = generate_random_permutation(N)
        distance = evaluate_solution(permutation, distance_matrix)
        if distance < best_distance
            best_permutation = permutation
            best_distance = distance
        end
    end

    return best_permutation, best_distance
end

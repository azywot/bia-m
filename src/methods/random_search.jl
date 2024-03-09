include("common.jl")
include("../utils/random_gen.jl")
include("../utils/eval.jl")


"""
# Perform random search
- `solution::Vector{Int}`: initial solution
- `distance_matrix::Matrix{Int}`: matrix of distances between nodes
- `config::Dict{K, V}`: dictionary of configuration

returns: best permutation found along with its distance
"""
function random_search(initial_solution, distance_matrix, config = Dict())

    N = length(initial_solution)
    best_solution = deepcopy(initial_solution)
    best_distance = evaluate_solution(best_solution, distance_matrix)

    time_limit = get(config, "time_limit", TIME_LIMIT)
    start_time = time()

    while time() - start_time < time_limit
        permutation = generate_random_permutation(N)
        distance = evaluate_solution(permutation, distance_matrix)
        if distance < best_distance
            best_solution = permutation
            best_distance = distance
        end
    end

    return best_solution, best_distance
end

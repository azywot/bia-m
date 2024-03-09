include("common.jl")
include("../utils/random_gen.jl")
include("../utils/eval.jl")


"""
# Perform random search
- `solution::Vector{Int}`: initial solution
- `distance_matrix::Matrix{Int}`: matrix of distances between nodes
- `config::Dict{K, V}`: dictionary of configuration

returns: `Solution`: a random search solution
"""
function random_search(initial_solution, distance_matrix, config = Dict())

    N = length(initial_solution)
    best_solution = deepcopy(initial_solution)
    best_cost = evaluate_solution(best_solution, distance_matrix)
    algorithm_steps = 0
    evaluated_solutions = 0

    time_limit = get(config, "time_limit", TIME_LIMIT)
    start_time = time()

    while time() - start_time < time_limit
        permutation = generate_random_permutation(N)
        cost = evaluate_solution(permutation, distance_matrix)
        if cost < best_cost
            best_solution = permutation
            best_cost = cost
            algorithm_steps += 1
        end
        evaluated_solutions += 1
    end

    return Solution(Vector{Int}(best_solution), Int(best_cost), algorithm_steps, evaluated_solutions) 
end

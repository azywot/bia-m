include("constants.jl")
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
    evaluated_solutions = 0

    time_limit = get(config, "time_limit", TIME_LIMIT)
    start_time = time()
    quality_over_time = get(config, "quality_over_time", false)
    if quality_over_time
        times_qualities = []
        optimal_cost = config["optimal_cost"]
        push!(times_qualities, (round(time()-start_time; digits=2), calculate_solution_quality(best_cost, optimal_cost)))
    end

    while time() - start_time < time_limit
        permutation = generate_random_permutation(N)
        cost = evaluate_solution(permutation, distance_matrix)
        if cost < best_cost
            best_solution = permutation
            best_cost = cost
            if quality_over_time
                push!(times_qualities, (round(time()-start_time; digits=2), calculate_solution_quality(best_cost, optimal_cost)))
            end
        end
        evaluated_solutions += 1
    end
    final_solution = Solution(Vector{Int}(best_solution), Int(best_cost), -1, evaluated_solutions) 
    
    if quality_over_time
        return final_solution, times_qualities
    end
    
    return final_solution
end

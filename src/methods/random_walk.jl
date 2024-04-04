include("constants.jl")
include("local_search.jl")
include("../utils/random_gen.jl")
include("../utils/eval.jl")

"""
# Perform random walk
- `solution::Vector{Int}`: initial solution
- `distance_matrix::Matrix{Int}`: matrix of distances between nodes
- `config::Dict{K, V}` dictionary of configuration

returns: `Solution`: a random walk solution
"""
function random_walk(initial_solution, distance_matrix, config = Dict())

    N = length(initial_solution)
    current_solution = deepcopy(initial_solution)
    current_cost = evaluate_solution(initial_solution, distance_matrix)
    best_solution = deepcopy(initial_solution)
    best_cost = current_cost
    evaluated_solutions = 0

    time_limit = minimum([get(config, "time_limit", TIME_LIMIT), TIME_LIMIT])
    start_time = time()

    quality_over_time = get(config, "quality_over_time", false)
    if quality_over_time
        times_qualities = []
        optimal_cost = OPTIMUM_COST[config["instance"]]
        push!(times_qualities, (round(time()-start_time; digits=2), calculate_solution_quality(best_cost, optimal_cost)))
    end

    # TODO: verify if it's correct!
    while (time() - start_time) < time_limit
        indices = generate_random_pair(N)
        new_solution, delta = generate_intra_route_move(current_solution, distance_matrix, indices, get(config, "mode", "edge"))
        current_solution = new_solution
        current_cost += delta 

        if current_cost < best_cost
            best_solution = deepcopy(current_solution)
            best_cost = current_cost
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
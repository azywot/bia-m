using LinearAlgebra

include("constants.jl")
include("local_search.jl")
include("../utils/eval.jl")
include("../utils/random_gen.jl")
include("../utils/read_data.jl")


function simulated_annealing(initial_solution, distance_matrix, config=Dict())
    N = length(initial_solution)
    current_solution = deepcopy(initial_solution)
    distance_matrix = deepcopy(distance_matrix)
    best_cost = evaluate_solution(initial_solution, distance_matrix)
    algorithm_steps = 0
    evaluated_solutions = 0
    no_improve = 0
    evaluated_solutions = 0
    ### SA params
    L = N^2
    temperature = 100
    alpha = 0.9
    P = 10
    ###

    start_time = time()
    time_limit = minimum([get(config, "time_limit", TIME_LIMIT), TIME_LIMIT])
    quality_over_time = get(config, "quality_over_time", false)
    if quality_over_time
        times_qualities = []
        optimal_cost = OPTIMUM_COST[config["instance"]]
        push!(times_qualities, (round(time() - start_time; digits=2), calculate_solution_quality(best_cost, optimal_cost)))
    end

    node_pairs = generate_all_pairs(N)

    while (no_improve < P * L) & ((time() - start_time) < time_limit)
        # (temperature > 0.01) or (no_improve < P * L)
        node_pairs = shuffle(node_pairs)

        for indices in node_pairs
            new_solution, delta =
                generate_intra_route_move(current_solution, distance_matrix, indices, get(config, "mode", "edge"))
            if delta < 0 || rand() < exp(-delta / temperature)
                current_solution = deepcopy(new_solution)
                best_cost += delta
                algorithm_steps += 1
            end
            evaluated_solutions += 1
        end
        temperature *= alpha
    end
    final_solution = Solution(Vector{Int}(current_solution), Int(best_cost), algorithm_steps, evaluated_solutions)
    if quality_over_time
        return final_solution, times_qualities
    end
    return final_solution
end

# tsp = read_tsp_file("data/SEL_tsp/berlin52.tsp")
# instance_size = size(tsp.distance_matrix, 1)
# initial_solution = generate_random_permutation(instance_size)
# sol = simulated_annealing(initial_solution, tsp.distance_matrix)

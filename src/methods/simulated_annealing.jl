using LinearAlgebra

include("constants.jl")
include("local_search.jl")
include("../utils/eval.jl")
include("../utils/random_gen.jl")
include("../utils/read_data.jl")


function simulated_annealing(initial_solution, distance_matrix, config=Dict())
    N = length(initial_solution)
    distance_matrix = deepcopy(distance_matrix)
    current_solution = deepcopy(initial_solution)
    current_cost = evaluate_solution(current_solution, distance_matrix)
    best_solution = deepcopy(initial_solution)
    best_cost = current_cost
    algorithm_steps = 0
    evaluated_solutions = 0
    no_improve = 0
    evaluated_solutions = 0
    node_pairs = generate_all_pairs(N)
    ### SA params
    L = length(node_pairs)
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

    while (temperature > 0.001) & (no_improve < P * L) & ((time() - start_time) < time_limit)
        node_pairs = shuffle(node_pairs)
        for indices in node_pairs
            new_solution, delta =
                generate_intra_route_move(current_solution, distance_matrix, indices, get(config, "mode", "edge"))
            if delta < 0 || rand() < exp(-delta / temperature)
                current_solution = deepcopy(new_solution)
                current_cost += delta
                algorithm_steps += 1
                if  current_cost < best_cost
                    best_solution = deepcopy(current_solution)
                    best_cost = current_cost
                    if quality_over_time
                        push!(times_qualities, (round(time() - start_time; digits=2), calculate_solution_quality(best_cost, optimal_cost)))
                    end
                end
            end
            evaluated_solutions += 1
        end
        temperature *= alpha
        no_improve += 1
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

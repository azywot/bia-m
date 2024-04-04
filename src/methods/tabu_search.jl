using Combinatorics
using Random
using StatsBase

include("constants.jl")
include("../utils/eval.jl")
include("../utils/combinatorics.jl")


"""
Select candidate moves for Tabu search.
"""
function select_candidate_moves(edge_pairs, solution, distance_matrix, config)

    num_moves_to_check = Int(round(get(config, "candidate_frac_check", 0.2) * length(edge_pairs)))
    candidate_moves = sample(edge_pairs, num_moves_to_check, replace=false)
    candidate_moves_final = []

    for cand_indices in candidate_moves
        cand_sol, cand_delta = generate_intra_route_move(solution, distance_matrix, cand_indices, get(config, "mode", "edge"))
        push!(candidate_moves_final, (cand_indices, cand_sol, cand_delta))
    end

    number_to_retain = Int(round(get(config, "candidate_frac_retain", 0.2) * length(edge_pairs)))
    candidate_moves_final = sort(candidate_moves_final, by=x -> x[3])[1:number_to_retain]

    return candidate_moves_final
end


"""
Update the tabu list.
"""
function update_tabu_moves(tabu_moves, move, tabu_tenure)

    n = size(tabu_moves)[1]
    for i in 1:n
        for j in i+1:n
            if tabu_moves[i, j] > 0
                tabu_moves[i, j] -= 1
            end
        end
    end 

    tabu_moves[move[1], move[2]] = tabu_tenure
end


"""
Generate a Tabu search solution given a starting solution and a mode.
- `solution::Vector{Int}`: initial solution
- `distance_matrix::Matrix{Int}`: matrix of distances between nodes
- `config::Dict{K, V}`: dictionary of configuration

returns: `Solution`: a Tabu search solution
"""
function tabu_search(solution, distance_matrix, config = Dict())

    N =  size(distance_matrix)[1]
    tabu_moves = zeros(N, N)

    distance_matrix = deepcopy(distance_matrix)
    best_solution = deepcopy(solution)
    best_cost = evaluate_solution(best_solution, distance_matrix)
    algorithm_steps = 0
    evaluated_solutions = 0

    edge_pairs = generate_all_pairs(length(solution))
    tabu_tenure = round(Int, length(solution) / get(config, "tabu_tenure_denom", 4)) # tabu tenure
    no_improvement_iterations = 0
    current_solution = deepcopy(solution)
    current_cost = deepcopy(best_cost)

    patience = get(config, "patience", 100) # stopping condition
    quality_over_time = get(config, "quality_over_time", false)
    time_limit = minimum([get(config, "time_limit", TIME_LIMIT), TIME_LIMIT])
    start_time = time()

    if quality_over_time
        times_qualities = []
        optimal_cost = OPTIMUM_COST[config["instance"]]
        push!(times_qualities, (round(time()-start_time; digits=2), calculate_solution_quality(best_cost, optimal_cost)))
    end

    while (no_improvement_iterations < patience) & ((time() - start_time) < time_limit)

        all_tabu = true # flag for possible aspiration criteria application
        candidate_moves = select_candidate_moves(edge_pairs, current_solution, distance_matrix, config)
        evaluated_solutions += Int(round(get(config, "candidate_frac_check", 0.2) * length(edge_pairs)))

        for (cand_indices, cand_sol, cand_delta) in candidate_moves

            if tabu_moves[cand_indices[1], cand_indices[2]] == 0 || current_cost + cand_delta < best_cost

                current_solution = deepcopy(cand_sol)
                current_cost += cand_delta

                if current_cost < best_cost
                    best_solution = deepcopy(current_solution)
                    best_cost = current_cost
                    algorithm_steps += 1
                    update_tabu_moves(tabu_moves, cand_indices, tabu_tenure)

                    if quality_over_time
                        push!(times_qualities, (round(time()-start_time; digits=2), calculate_solution_quality(best_cost, optimal_cost)))
                    end
                    
                    no_improvement_iterations = 0 
                else
                    no_improvement_iterations += 1
                end
                all_tabu = false
                break
            end
        end

        if all_tabu
            min_tabu_tenure = maximum(tabu_moves)
            min_tabu_move = nothing
            min_tabu_sol = nothing
            min_tabu_delta = nothing

            for (cand_indices, cand_sol, cand_delta) in candidate_moves
                if tabu_moves[cand_indices[1], cand_indices[2]] < min_tabu_tenure
                    min_tabu_tenure = tabu_moves[cand_indices[1], cand_indices[2]]
                    min_tabu_move = cand_indices
                    min_tabu_sol = cand_sol
                    min_tabu_delta = cand_delta
                end
            end

            current_solution = deepcopy(min_tabu_sol)
            current_cost += min_tabu_delta

            if current_cost < best_cost
                best_solution = deepcopy(current_solution)
                best_cost = current_cost
                algorithm_steps += 1
                update_tabu_moves(tabu_moves, min_tabu_move, tabu_tenure)

                if quality_over_time
                    push!(times_qualities, (round(time()-start_time; digits=2), calculate_solution_quality(best_cost, optimal_cost)))
                end
                
                no_improvement_iterations = 0 
            else
                no_improvement_iterations += 1
            end
        end
    end

    final_solution = Solution(Vector{Int}(best_solution), Int(best_cost), algorithm_steps, evaluated_solutions) 

    if quality_over_time
        return final_solution, times_qualities
    end
    
    return final_solution
end

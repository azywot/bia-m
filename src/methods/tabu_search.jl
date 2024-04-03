using Combinatorics
using Random
using StatsBase

include("constants.jl")
include("../utils/eval.jl")
include("../utils/combinatorics.jl")


"""
Select candidate moves for Tabu search.
"""
function select_candidate_moves(edge_pairs, best_solution, distance_matrix, config)

    num_moves_to_check = Int(round(get(config, "candidate_frac_check", 0.2) * length(edge_pairs)))
    candidate_moves = sample(edge_pairs, num_moves_to_check, replace=false)
    candidate_moves_final = []

    for cand_indices in candidate_moves
        cand_sol, cand_delta = generate_intra_route_move(best_solution, distance_matrix, cand_indices, get(config, "mode", "edge"))
        push!(candidate_moves_final, (cand_indices, cand_sol, cand_delta))
    end

    number_to_retain = Int(round(get(config, "candidate_frac_retain", 0.2) * length(edge_pairs)))
    candidate_moves_final = sort(candidate_moves_final, by=x -> x[3])[1:number_to_retain]

    return candidate_moves_final
end


"""
Update the tabu list.
"""
function update_tabu_list(tabu_list, move, tabu_tenure)

    for key in keys(tabu_list)
        tabu_list[key] -= 1
        if tabu_list[key] <= 0
            delete!(tabu_list, key)
        end
    end
    
    tabu_list[move] = tabu_tenure
end


"""
Generate a Tabu search solution given a starting solution and a mode.
- `solution::Vector{Int}`: initial solution
- `distance_matrix::Matrix{Int}`: matrix of distances between nodes
- `config::Dict{K, V}`: dictionary of configuration

returns: `Solution`: a Tabu search solution
"""
function tabu_search(solution, distance_matrix, config = Dict())
    distance_matrix = deepcopy(distance_matrix)
    best_solution = deepcopy(solution)
    best_cost = evaluate_solution(best_solution, distance_matrix)
    algorithm_steps = 0
    evaluated_solutions = 0

    edge_pairs = generate_all_pairs(length(solution))
    tabu_tenure = Int(length(solution) / get(config, "tabu_tenure_denom", 4)) # tabu tenure
    tabu_list = Dict{Tuple{Int, Int}, Int}()
    no_improvement_iterations = 0
    patience = get(config, "patience", 100) # stopping condition

    quality_over_time = get(config, "quality_over_time", false)
    if quality_over_time
        times_qualities = []
        optimal_cost = OPTIMUM_COST[config["instance"]]
        start_time = time()
        push!(times_qualities, (round(time()-start_time; digits=2), calculate_solution_quality(best_cost, optimal_cost)))
    end

    while no_improvement_iterations < patience
        best_delta = 0
        best_solution_found = nothing
        best_solution_move = nothing

        all_tabu = true
        candidate_moves = select_candidate_moves(edge_pairs, best_solution, distance_matrix, config)
        for (cand_indices, cand_sol, cand_delta) in candidate_moves
            new_solution, delta = cand_sol, cand_delta

            # TODO: regions?
            if (!haskey(tabu_list, cand_indices) & (delta < best_delta || best_solution_found === nothing)) ||  ((delta < best_delta) & (best_cost + delta < best_cost))

                best_solution_found = deepcopy(new_solution)
                best_solution_move = deepcopy(cand_indices)
                best_delta = delta

                evaluated_solutions += 1
                all_tabu = false
            end
        end

        if all_tabu
            # TODO
            println("ALL TABU!")
        end

        if best_solution_found !== nothing
            best_solution = deepcopy(best_solution_found)
            best_cost += best_delta
            algorithm_steps += 1
            update_tabu_list(tabu_list, best_solution_move, tabu_tenure)

            if quality_over_time
                push!(times_qualities, (round(time()-start_time; digits=2), calculate_solution_quality(best_cost, optimal_cost)))
            end

            no_improvement_iterations += 1 # = 0 TODO: remove
        else
            no_improvement_iterations += 1
        end
    end

    final_solution = Solution(Vector{Int}(best_solution), Int(best_cost), algorithm_steps, evaluated_solutions) 

    if quality_over_time
        return final_solution, times_qualities
    end
    
    return final_solution
end

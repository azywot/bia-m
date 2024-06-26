using Combinatorics
using Random

include("constants.jl")
include("../utils/eval.jl")
include("../utils/combinatorics.jl")

"""
Generate an intra route solution.
- `solution::Vector{Int}`: solution
- `dm::Matrix{Int}`: matrix of distances between nodes
- `indices::Vector{Int}`: indices of nodes to be swapped (either the nodes or its edges)
- `mode::String`: mode of the local search, either "node" or "edge"
- `reverse_search::Bool`: whether to reverse edge search or not

returns: a local search solution and its delta
"""
function generate_intra_route_move(solution, dm, indices, mode, reverse_search = false)
    n = length(solution)
    sol = deepcopy(solution)
    i, j = indices[1], indices[2]
    if i > j
        i, j = j, i
    end
    
    # if nodes are already connected by edge
    if mod(i + 1, n) == mod(j, n) || mod(j + 1, n) == mod(i, n)
        return sol, 0
    end

    if mode == "node"
        plus_i = dm[sol[mod(j - 2, n)], sol[i]] + dm[sol[i], sol[mod(j, n)+1]]
        plus_j = dm[sol[mod(i - 2, n)+1], sol[j]] + dm[sol[j], sol[mod(i, n)+1]]
        minus_i = dm[sol[mod(i - 2, n)+1], sol[i]] + dm[sol[i], sol[mod(i, n)+1]]
        minus_j = dm[sol[mod(j - 2, n)], sol[j]] + dm[sol[j], sol[mod(j, n)+1]]

        delta = plus_i + plus_j - minus_i - minus_j
        sol[i], sol[j] = sol[j], sol[i]

    elseif mode == "edge"

        plus, minus = 0, 0
        if reverse_search
            plus = dm[sol[i], sol[j]] + dm[sol[mod(i - 2, n)+1], sol[mod(j - 2, n)+1]]
            minus = dm[sol[mod(i - 2, n)+1], sol[i]] + dm[sol[mod(j - 2, n)+1], sol[j]]
        else
            plus = dm[sol[i], sol[j]] + dm[sol[mod(i, n)+1], sol[mod(j, n)+1]]
            minus = dm[sol[i], sol[mod(i, n)+1]] + dm[sol[j], sol[mod(j, n)+1]]
        end


        delta = plus - minus
        if i < j
            lower = i
            upper = j
        else
            lower = j
            upper = i
        end

        if reverse_search
            if lower == 1
                sol = vcat(reverse(sol[lower:upper-1]), sol[upper:end])
            else
                sol = vcat(sol[1:lower-1], reverse(sol[lower:upper-1]), sol[upper:end])
            end
        else
            if upper == n
                sol = vcat(sol[1:lower], reverse(sol[lower+1:upper]))
            else
                sol = vcat(sol[1:lower], reverse(sol[lower+1:upper]), sol[upper+1:end])
            end
        end
    end
    return sol, delta
end


# """
# Generate an inter route solution.
# - `solution::Vector{Int}`: solution
# - `distance_matrix::Matrix{Int}`: matrix of distances between nodes
# - `new_node::Int`: number of node to be inserted
# - `idx::Int`: index at which new node will be inserted

# returns: a local search solution and its delta
# """
# function generate_inter_route_move(solution, dm, new_node, idx)
#     n = length(solution)
#     sol = deepcopy(solution)
#     old_node = solution[idx]

#     plus =
#         dm[sol[mod(idx - 2, n)+1], new_node] +
#         dm[new_node, sol[mod(idx, n)+1]]
#     minus =
#         dm[sol[mod(idx - 2, n)+1], old_node] +
#         dm[old_node, sol[mod(idx, n)+1]]

#     delta = plus - minus
#     sol[idx] = new_node

#     return sol, delta
# end


"""
Generate a local search greedy solution given a starting solution and a mode.
- `solution::Vector{Int}`: initial solution
- `distance_matrix::Matrix{Int}`: matrix of distances between nodes
- `config::Dict{K, V}`: dictionary of configuration

returns: `Solution`: a greedy local search solution
"""
function local_greedy_search(solution, distance_matrix, config = Dict())
    N, _ = size(distance_matrix)
    distance_matrix = deepcopy(distance_matrix)
    best_solution = deepcopy(solution)
    best_cost = evaluate_solution(best_solution, distance_matrix)
    algorithm_steps = 0
    evaluated_solutions = 0

    node_pairs = generate_all_pairs(length(solution))
    delta = -1
    
    quality_over_time = get(config, "quality_over_time", false)
    if quality_over_time
        times_qualities = []
        optimal_cost = OPTIMUM_COST[config["instance"]]
        start_time = time()
        push!(times_qualities, (round(time()-start_time; digits=2), calculate_solution_quality(best_cost, optimal_cost)))
    end

    while delta < 0
        new_solution = nothing
        delta = 0
        intra_count = 0
        # inter_count = 0

        node_pairs = shuffle(node_pairs)
        # unvisited = collect(setdiff(Set(1:N), Set(best_solution)))
        # candidate_idx_pairs =
        #     shuffle(vec(collect(Iterators.product(unvisited, 1:length(best_solution)))))

        while delta >= 0 &&
            (intra_count < length(node_pairs)) # || inter_count < length(candidate_idx_pairs))
            # if rand() < 0.5 && intra_count < length(node_pairs)
            intra_count += 1
            indices = node_pairs[intra_count]
            new_solution, delta = generate_intra_route_move(best_solution, distance_matrix, indices, get(config, "mode", "edge"))
            # elseif inter_count < length(candidate_idx_pairs)
            #     inter_count += 1
            #     candidate_node, idx = candidate_idx_pairs[inter_count]
            #     new_solution, delta = generate_inter_route_move(
            #         best_solution,
            #         distance_matrix,
            #         candidate_node,
            #         idx,
            #     )
            # end
            if delta < 0
                best_solution = deepcopy(new_solution)
                best_cost += delta
                algorithm_steps += 1

                if quality_over_time
                    push!(times_qualities, (round(time()-start_time; digits=2), calculate_solution_quality(best_cost, optimal_cost)))
                end
            end
            
            evaluated_solutions += 1
        end
    end

    final_solution = Solution(Vector{Int}(best_solution), Int(best_cost), algorithm_steps, evaluated_solutions) 

    if quality_over_time
        return final_solution, times_qualities
    end
    
    return final_solution
end


"""
Generate a local search steepest solution given a starting solution and a mode.
- `solution::Vector{Int}`: initial solution
- `distance_matrix::Matrix{Int}`: matrix of distances between nodes
- `config::Dict{K, V}`: dictionary of configuration

returns: `Solution`: a steepest local search solution
"""
function local_steepest_search(solution, distance_matrix, config = Dict())

    distance_matrix = deepcopy(distance_matrix)
    best_solution = deepcopy(solution)
    best_cost = evaluate_solution(best_solution, distance_matrix)
    algorithm_steps = 0
    evaluated_solutions = 0

    node_pairs = generate_all_pairs(length(solution))
    best_delta = -1

    quality_over_time = get(config, "quality_over_time", false)
    if quality_over_time
        times_qualities = []
        optimal_cost = OPTIMUM_COST[config["instance"]]
        start_time = time()
        push!(times_qualities, (round(time()-start_time; digits=2), calculate_solution_quality(best_cost, optimal_cost)))
    end

    while best_delta < 0
        best_delta = 0
        best_solution_found = nothing
        # unvisited = collect(setdiff(Set(1:N), Set(best_solution)))

        node_pairs = shuffle(node_pairs)

        for indices in node_pairs
            new_solution, delta =
                generate_intra_route_move(best_solution, distance_matrix, indices, get(config, "mode", "edge"))
            if delta < best_delta
                best_solution_found = deepcopy(new_solution)
                best_delta = delta
            end
            evaluated_solutions += 1
        end

        # candidate_idx_pairs =
        #     vec(collect(Iterators.product(unvisited, 1:length(best_solution))))
        # for pair in candidate_idx_pairs
        #     new_solution, delta = generate_inter_route_move(
        #         best_solution,
        #         distance_matrix,
        #         pair[1],
        #         pair[2],
        #     )
        #     if delta < best_delta
        #         best_solution_found = deepcopy(new_solution)
        #         best_delta = delta
        #     end
        # end

        if best_delta < 0
            best_solution = deepcopy(best_solution_found)
            best_cost += best_delta
            algorithm_steps += 1
            
            if quality_over_time
                push!(times_qualities, (round(time()-start_time; digits=2), calculate_solution_quality(best_cost, optimal_cost)))
            end
        end
    end

    final_solution = Solution(Vector{Int}(best_solution), Int(best_cost), algorithm_steps, evaluated_solutions) 

    if quality_over_time
        return final_solution, times_qualities
    end
    
    return final_solution
end
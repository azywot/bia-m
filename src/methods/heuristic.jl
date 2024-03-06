include("../utils/eval.jl")


"""
# Generate a heuristic (nearest neighbor) solution
- `N::Int`: number of nodes
- `distance_matrix::Matrix{Int}`: matrix of distances between nodes

returns: a nearest neighbor solution, cost
"""
function heuristic(N, distance_matrix)
    distance_matrix_temp = deepcopy(distance_matrix)
    solution = [rand(1:N)]

    while length(solution) != ceil(N)
        min_index = argmin(distance_matrix_temp[solution[end], :])
        distance_matrix_temp[solution[end], min_index] = 10^10
        distance_matrix_temp[:, solution[end]] .= 10^10
        push!(solution, min_index)
    end
    cost = evaluate_solution(solution, distance_matrix)
    return solution, cost
end

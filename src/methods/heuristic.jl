include("common.jl")
include("../utils/eval.jl")


"""
# Generate a heuristic (nearest neighbor) solution
- `solution::Vector{Int}`: initial solution
- `distance_matrix::Matrix{Int}`: matrix of distances between nodes
- `config::Dict{K, V}`: dictionary of configuration

returns: `Solution`: a nearest neighbor solution
"""
function heuristic(solution, distance_matrix, config = nothing)

    N = length(solution)
    distance_matrix_temp = deepcopy(distance_matrix)
    solution = [solution[1]]

    while length(solution) != ceil(N)
        min_index = argmin(distance_matrix_temp[solution[end], :])
        distance_matrix_temp[solution[end], min_index] = 10^10
        distance_matrix_temp[:, solution[end]] .= 10^10
        push!(solution, min_index)
    end
    cost = evaluate_solution(solution, distance_matrix)

    return Solution(Vector{Int}(solution), Int(cost), -1, -1) 
end

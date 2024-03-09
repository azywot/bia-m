"""
# Evaluate a solution
- `solution::Vector{Int64}`: a permutation of nodes
- `distance_matrix::Matrix{Int64}`: matrix of distances between nodes

returns: total value of the solution
"""
function evaluate_solution(solution, distance_matrix)
    total_cost = 0

    for i in eachindex(solution)
        if i == length(solution)
            total_cost += distance_matrix[solution[i], solution[1]]
        else
            total_cost += distance_matrix[solution[i], solution[i+1]]
        end
    end

    return total_cost
end

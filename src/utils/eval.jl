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


"""
Calculate the quality of a solution with respect to the best solution.

- `cost::Vector{Int}`: solution cost
- `best_cost::Vector{Int}`: best solution cost

returns: solutions'quality
"""
function calculate_solution_quality(cost, best_cost)
    # relative quality (difference)
    return (cost-best_cost)/best_cost
end

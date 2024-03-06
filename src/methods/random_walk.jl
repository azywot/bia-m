include("local_search.jl")
include("../utils/random_gen.jl")

# Random walk (Jaszkiewicz slides)

# generate and evaluate a random solution
# repeat
#     randomly modify and evaluate the current solution
# until the stopping conditions are met
# return the best solution found

# • Random modification may be faster than generating a random solution from scratch
# • Sampling of the solutions space is less uniform
"""
# Perform random walk
- `initial_solution::Vector{Int}`: initial solution (permutation)
- `distance_matrix::Matrix{Int}`: matrix of distances between nodes
- `time_limit::Float`: stopping condition
- `mode::String`: mode of the neighbourhood, either "node" or "edge"

returns: permutation along with its distance
"""
function random_walk(initial_solution, distance_matrix, time_limit = 10, mode = "node")

    N = length(initial_solution)
    best_solution = deepcopy(initial_solution)

    start_time = time()

    while (time() - start_time) < time_limit
        indices = generate_random_pair(N)
        new_solution, delta = generate_intra_route_move(best_solution, distance_matrix, indices, mode)

        if delta < 0
            best_solution = deepcopy(new_solution)
        end 
    end

    return best_solution, evaluate_solution(best_solution, distance_matrix)
end
include("local_search.jl")
include("../utils/random_gen.jl")

"""
# Perform random walk
- `N::Int`: number of nodes
- `distance_matrix::Matrix{Int}`: matrix of distances between nodes
- `time_limit::Float`: stopping condition

returns: permutation along with its distance
"""
function random_walk(N, distance_matrix, time_limit)
    current_city = rand(1:N)
    visited_cities = [current_city]
    total_distance = 0
    start_time = time()

    while (time() - start_time) < time_limit
        while length(visited_cities) < N
            possible_cities = setdiff(1:N, visited_cities)
            if isempty(possible_cities)
                break
            end
            next_city = rand(possible_cities)
            total_distance += distance_matrix[current_city, next_city]

            current_city = next_city
            push!(visited_cities, current_city)
        end
    end

    if length(visited_cities) == N
        total_distance += distance_matrix[current_city, visited_cities[1]]
    end

    return visited_cities, total_distance
end


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
function random_walk_v2(initial_solution, distance_matrix, time_limit = 10, mode = "node")

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
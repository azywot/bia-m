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

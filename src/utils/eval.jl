import Base: isless

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

mutable struct SolutionInfo
    solution::Vector{Int}
    cost::Int
    edge_distance_best::Int
    # edge_distance_avg::Float64
end


function SolutionInfo(solution::Vector{Int}, cost::Int)
    edge_distance_best = 0.0
    # edge_distance_avg = 0.0
    return SolutionInfo(solution, cost, edge_distance_best)#, edge_distance_avg)
end


function Base.show(io::IO, info::SolutionInfo)
    println(io, "SolutionInfo")
    println(io, "solution: ", info.solution)
    println(io, "cost: ", info.cost)
    println(io, "edge similarity (wrt the best solution): ", info.edge_distance_best)
    # println(io, "edge similarity (on average): ", info.edge_distance_avg)
end

function isless(a::SolutionInfo, b::SolutionInfo)
    return a.cost < b.cost
end


"""
Get the set of edges of a solution.

- `solution::Vector{Int}`: solution

returns: a set of edges of the solution (as sorted tuples)
"""
function get_solution_edges_set(solution)
    n = length(solution)
    edges = []
    for i in eachindex(solution)
        if i == n
            nodes = solution[i], solution[1]
        else
            nodes = solution[i], solution[i+1]
        end
        push!(edges, (minimum(nodes), maximum(nodes)))
    end
    return Set(edges)
end


"""
Calculate the distance between two solutions.

- `solution1::Vector{Int}`: first solution
- `solution2::Vector{Int}`: second solution

returns: the distance between two solutions
"""
function calculate_solution_distance(solution1, solution2)

    edge_intersection = intersect(get_solution_edges_set(solution1), get_solution_edges_set(solution2))
    return length(solution1) - length(edge_intersection)
end


"""
Perform similarity tests on a solution.

- `iterations::Int`: number of iterations
- `distance_matrix::Matrix{Int}`: matrix of distances between nodes
- `cost_vector::Vector{Int}`: vector of costs of node
- `coords::Vector{Tuple{Int, Int}}`: vector of coordinates of nodes
- `best_solution::Vector{Int}`: best solution
- `method::Function`: method to use to generate the solution
- `verbose::Bool`: whether to print the results

returns: a dataframe containing the results
"""
function perform_similarity_tests(iterations, distance_matrix, method = local_greedy_search, best_solution = nothing, verbose = false)
    N = size(distance_matrix)[1]
    solution_infos = []

    if verbose
        println("Generating solutions...")
    end

    if isnothing(best_solution)
        iterations_1 = iterations+1
    else
        iterations_1 = iterations
    end

    for i in 1:iterations_1
        solution, solution_cost = method(generate_random_permutation(N), distance_matrix)
        push!(solution_infos, SolutionInfo(solution, solution_cost))
    end

    if isnothing(best_solution)
        solution_infos = sort(solution_infos)
        best_solution = solution_infos[1]
        deleteat!(solution_infos, 1)
    end

    if verbose
        println("Calculating average solution similarities...")
    end
    for i in 1:iterations
        edge_distance_best = calculate_solution_distance(solution_infos[i].solution, best_solution)
        solution_infos[i].edge_distance_best = edge_distance_best
        # for j in i+1:iterations
        #     edge_distance = calculate_solution_distance(solution_infos[i].solution, solution_infos[j].solution)
        #     solution_infos[i].edge_distance_avg += edge_distance/iterationss
        #     solution_infos[j].edge_distance_avg += edge_distance/iterations
        # end 
    end

    if verbose
        println(solution_infos)
    end

    # TODO: avg & std

    df = DataFrame()
    fields = filter(f -> f != :solution, fieldnames(SolutionInfo))
    for field in fields
        df[!, Symbol(field)] = getfield.(solution_infos, field)
    end

    return df
end
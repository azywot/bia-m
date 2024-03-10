include("../methods/all_methods.jl")
include("../methods/common.jl")

using DataFrames

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
Performance tests on a an algorithm.

- `iterations::Int`: number of iterations
- `distance_matrix::Matrix{Int}`: matrix of distances between nodes
- `method::Function`: method to use to generate the solution
- `best_solution`: best solution to compare
- `config::Dict{K, V}`: dictionary of configuration
- `verbose::Bool`: whether to print the results

returns: a dataframe containing the results
"""
function performance_test(iterations, distance_matrix, method = local_greedy_search, 
                            best_solution = nothing, config = Dict(), verbose = false)

    N = size(distance_matrix)[1]
    solution_infos = []

    if verbose
        println("Generating solutions...")
    end

    if isnothing(best_solution) || isempty(best_solution)
        iterations_1 = iterations+1
    else
        iterations_1 = iterations
    end

    for i in 1:iterations_1
        solution = method(generate_random_permutation(N), distance_matrix, config)
        push!(solution_infos, solution)
    end

    if isnothing(best_solution)
        solution_infos = sort(solution_infos)
        best_solution = solution_infos[1].solution
        deleteat!(solution_infos, 1)
    end

    if verbose
        println("Calculating solution distances...")
    end
    for i in 1:iterations
        edge_distance_best = calculate_solution_distance(solution_infos[i].solution, best_solution)
        solution_infos[i].edge_distance_best = edge_distance_best
    end

    if verbose
        println(solution_infos)
    end

    df = DataFrame()
    fields = filter(f -> f != :solution, fieldnames(Solution))
    for field in fields
        df[!, Symbol(field)] = getfield.(solution_infos, field)
    end
    df.method .= string(method)

    if iterations_1 == iterations+1
        df.optimum .= false # optimum is only estimated
    else
        df.optimum .= true
    end

    return df
end
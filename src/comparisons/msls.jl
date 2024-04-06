using Statistics

include("../methods/local_search.jl")
include("../utils/random_gen.jl")
include("../utils/read_data.jl")


"""
Plot costs with correlation as title

- `x_bests::List`: list of xs corresponding to the best solutions so far
- `bests::List`: list of best solutions so far
- `costs::List`: list of costs of solutions so far
- `means::List`: list of means of solutions so far
- `stds::List`: list of stds solutions so far
- `save_path::Str`: path to save the plot
"""
function plot_msls(x_bests, bests, costs, means, stds, save_path)
    x = collect(1:length(costs))
    fig = scatter(x, costs, color=:lightgray, label="Cost", markersize=3, xlabel="Number of restarts", ylabel="Cost")
    plot!(x_bests, bests, linecolor=:magenta, linewidth=4, marker=:star, markercolor=:magenta, markersize=6, label="Best cost")
    plot!(x, means, color=:blue, linewidth=3, label = "mean")
    plot!(x, means .- stds, fillrange=means .+ stds, fillalpha=0.35, c=1, label="std", linealpha=0)
    file_path = joinpath(save_path * ".png")
    savefig(fig, file_path)
end

"""
# Perform a multiple start local search algorithm and track statictics.
- `method::Function`: method to use to generate the solution
- `distance_matrix::Matrix{Int}`: matrix of distances between nodes
- `iterations::Int`: number of iterations to run the algorithm
- `instance::String`: instance name

returns: a multiple start local search solution
"""
function multiple_start_local_search(
    method,
    distance_matrix,
    iterations,
    instance
)
    N = size(distance_matrix)[1]
    best_solution = []
    best_cost = Inf
    bests = []
    x_bests = []
    costs = []
    means = []
    stds = []

    for i = 1:iterations
        initial_solution = generate_random_permutation(N)
        solution =
            method(initial_solution, distance_matrix)
        push!(costs, solution.cost)
        push!(means, mean(costs))
        push!(stds, std(costs))
        if solution.cost < best_cost
            best_solution = solution
            best_cost = solution.cost
            push!(bests, best_cost)
            push!(x_bests, i)
        end
    end
    save_path = "output/msls/$method/$instance"
    plot_msls(x_bests, bests, costs, means, stds, save_path)
    return best_solution
end


"""
# Run msls experiments
- `directory_path::String`: path to directory with instances
- `instances::List`: list of instances to perform test
- `iterations::Int`: number of iterations to run the algorithm
"""
function assess_number_of_restarts(directory_path, instances, iterations=300)
    methods = [local_steepest_search]
    for method in methods
        for instance in instances
            println(method, instance)
            filename = joinpath(directory_path, instance * ".tsp")
            tsp = read_tsp_file(filename)
            multiple_start_local_search(method, tsp.distance_matrix, iterations, instance)
        end
    end
end


directory_path = "data/SEL_tsp"
chosen_instances = ["tsp225"]
assess_number_of_restarts(directory_path, chosen_instances)

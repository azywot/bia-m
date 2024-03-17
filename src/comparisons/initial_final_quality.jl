using CSV
using Plots
using Statistics
using StatsBase

include("../methods/local_search.jl")
include("../utils/random_gen.jl")
include("../utils/read_data.jl")


"""
Plot costs with correlation as title

- `df::DataFrame`: dataframe with initial and final columns
- `save_path::Str`: path to save the plot
"""
function plot_costs(df, save_path)
    corr = corspearman(Float64.(df.initial), Float64.(df.final))
    corr = round(corr, digits=3)
    fig = scatter(
        df.initial,
        df.final,
        xlabel="Initial cost",
        ylabel="Final cost",
        title="Correlation: $corr",
        legend=false,
    )
    file_path = joinpath(save_path * ".png")
    savefig(fig, file_path)
end


"""
Compare initial solution cost with final solution cost (G,S)

- `iterations::Int`: number of iterations
- `instances::List`: list of instances to perform test
- `directory_path::Str`: path to directory containing instances
"""
function initial_final_quality(iterations, tsp, method, instance)
    N = size(tsp.distance_matrix)[1]
    costs_i = []
    costs_f = []
    for i in 1:iterations
        initial_solution = generate_random_permutation(N)
        initial_cost = evaluate_solution(initial_solution, tsp.distance_matrix)
        final_solution = method(initial_solution, tsp.distance_matrix)
        final_cost = final_solution.cost
        push!(costs_i, initial_cost)
        push!(costs_f, final_cost)
    end
    save_path = "output/initial_final_quality/$method/$instance"
    df = DataFrame(initial=costs_i, final=costs_f)
    CSV.write(joinpath(save_path * ".csv"), df)
    plot_costs(df, save_path)

end


"""
# Run quality comparison experiments
- `directory_path::String`: path to directory with instances
- `instances::List`: list of instances to perform test
- `iterations::Int`: number of iterations to run the algorithm
"""
function assess_qualities(directory_path, instances, iterations)
    methods = [local_greedy_search, local_steepest_search]
    for method in methods
        for instance in instances
            println(method, instance)
            filename = joinpath(directory_path, instance * ".tsp")
            tsp = read_tsp_file(filename)
            initial_final_quality(iterations, tsp, method, instance)
        end
    end
end


directory_path = "data/SEL_tsp"
chosen_instances = ["berlin52", "st70"]
assess_qualities(directory_path, chosen_instances, 200)

using CSV
using Plots

include("../methods/local_search.jl")
include("../utils/random_gen.jl")
include("../utils/read_data.jl")


function plot_costs(df, save_path)
    fig = scatter(
        df.initial,
        df.final,
        xlabel="Initial cost",
        ylabel="Final cost",
        legend=false,
    )

    file_path = joinpath(save_path * ".png")
    savefig(fig, file_path)
end


function initial_final_quality(iterations, instances, directory_path)
    methods = [local_greedy_search, local_steepest_search]
    for method in methods
        for instance in instances
            println(method, instance)
            filename = joinpath(directory_path, instance * ".tsp")
            tsp = read_tsp_file(filename)
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
    end
end


directory_path = "data/SEL_tsp"
INSTANCES = ["berlin52", "ch150", "gil262",
    "pcb1173", "pr76", "pr226",
    "pr439", "pr1002", "rat575",
    "st70", "tsp225", "u724"]
initial_final_quality(200, INSTANCES, directory_path)

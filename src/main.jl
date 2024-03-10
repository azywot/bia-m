include("utils/random_gen.jl")
include("utils/read_data.jl")
include("utils/eval.jl")
include("utils/performance_test.jl")

include("methods/heuristic.jl")
include("methods/local_search.jl")
include("methods/random_search.jl")
include("methods/random_walk.jl")

using DataFrames
using CSV

# n = 5
# randomness_measure, counts, histogram = permutation_test(n, factorial(n) * 1000)
# randomness_measure
# histogram

# READ SELECTED INSTANCES
directory_path = "data/SEL_tsp"
INSTANCES = ["berlin52", "ch150", "gil262", 
                "pcb1173", "pr76", "pr226", 
                "pr439", "pr1002", "rat575", 
                "st70","tsp225", "u724"]
      
RESULTS_PATH = "results/performance_test.csv"
RESULTS_STATS_PATH = "results/performance_test_stats.csv"

# ["berlin52", "ch150", "pr76", "pr1002", "st70","tsp225"] - for these instances we know the optimum
METHODS = [random_search, 
            random_walk, 
            heuristic, 
            local_greedy_search, 
            local_steepest_search]

ITERATIONS = 10

# TEST
# filename = "data/SEL_tsp/ch150.tsp"
# test_tsp = read_tsp_file(filename)
# println(test_tsp)

# N = size(test_tsp.distance_matrix)[1]
# initial_solution = generate_random_permutation(N)
# initial_cost = evaluate_solution(initial_solution, test_tsp.distance_matrix)
# println("Initial solution cost: ", initial_cost)

# for method in METHODS
#     solution = method(initial_solution, test_tsp.distance_matrix)
#     println(uppercase(replace("$method", "_" => " ")), ":\n", solution)
# end

# SHORTENED LISTS TO CHECK
METHODS = [heuristic, local_greedy_search]
INSTANCES = ["berlin52", "pr76", "st70"]
CONFIG = Dict("time_limit" => 1)

results_list = []
column_names = [:instance, :method, :avg_distance_best, :std_distance_best, :avg_alg_steps, :avg_eval_sol]
results_stats_df = DataFrame([Vector{Any}() for _ in column_names], column_names)

for method in METHODS
    for instance in INSTANCES
        fielname = joinpath(directory_path, instance * ".tsp")
        tsp = read_tsp_file(fielname)

        if !isempty(tsp.opt_tour)
            performance_df = performance_test(ITERATIONS, tsp.distance_matrix, method, tsp.opt_tour, CONFIG)
        else
            println(tsp.name, " does not have an optimum defined!")
            # TODO: need to prepare estimations, e.g. run 100 steepest ls and save the best solution for each instance to a file
            performance_df = performance_test(ITERATIONS, tsp.distance_matrix, method, nothing, CONFIG)
        end

        push!(results_list, performance_df)
        performance_df.instance .= tsp.name

        new_row = DataFrame(instance=[tsp.name], method=[method], 
                            avg_distance_best=[mean(performance_df.edge_distance_best)], std_distance_best=[std(performance_df.edge_distance_best)], 
                            avg_alg_steps=[mean(performance_df.algorithm_steps)], avg_eval_sol=[mean(performance_df.evaluated_solutions)])
        results_stats_df = vcat(results_stats_df, new_row)
    end
end

# SAVE RESULTS
CSV.write(RESULTS_PATH, vcat(results_list...))
CSV.write(RESULTS_STATS_PATH, results_stats_df)
include("utils/random_gen.jl")
include("utils/read_data.jl")
include("utils/eval.jl")
include("utils/performance_test.jl")

include("methods/heuristic.jl")
include("methods/local_search.jl")
include("methods/random_search.jl")
include("methods/random_walk.jl")

include("plots/solutions_quality.jl")

using DataFrames, CSV
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
# filename = "data/SEL_tsp/pr76.tsp"
# test_tsp = read_tsp_file(filename)
# println(test_tsp)

# N = size(test_tsp.distance_matrix)[1]
# initial_solution = generate_random_permutation(N)
# initial_cost = evaluate_solution(initial_solution, test_tsp.distance_matrix)
# println("Initial solution cost: ", initial_cost)

# config = Dict("quality_over_time" => true,
#                 "optimal_cost" => evaluate_solution(test_tsp.opt_tour, test_tsp.distance_matrix),
#                 "time_limit" => 3)

# final_solution, time_qual = local_greedy_search(initial_solution, test_tsp.distance_matrix, config)
# time_qual

# final_solution, time_qual = random_search(initial_solution, test_tsp.distance_matrix, config)
# time_qual
# # TODO: transform time_qual!

# for method in METHODS
#     solution = method(initial_solution, test_tsp.distance_matrix)
#     println(uppercase(replace("$method", "_" => " ")), ":\n", solution)
# end

# SHORTENED LISTS TO CHECK
METHODS = [heuristic, local_greedy_search, local_steepest_search]
INSTANCES = ["berlin52", "pr76", "st70", "ch150"]
CONFIG = Dict("time_limit" => 10)

results_list = []
column_names = [:instance, :method, :best_case_quality, :worst_case_quality,
                 :avg_quality, :std_quality, :avg_alg_steps, :avg_eval_sol, :running_time]
results_stats_df = DataFrame([Vector{Any}() for _ in column_names], column_names)

for method in METHODS
    for instance in INSTANCES
        # println(method, ":\t", instance)
        fielname = joinpath(directory_path, instance * ".tsp")
        tsp = read_tsp_file(fielname)

        if !isempty(tsp.opt_tour)
            performance_df, running_time = performance_test(ITERATIONS, tsp.distance_matrix, method, tsp.opt_tour, CONFIG)
        else
            println(tsp.name, " does not have an optimum defined!")
            performance_df, running_time = performance_test(ITERATIONS, tsp.distance_matrix, method, nothing, CONFIG)
        end

        push!(results_list, performance_df)
        performance_df.instance .= tsp.name

        best_case = argmin(performance_df.cost)
        worst_case = argmax(performance_df.cost)

        new_row = DataFrame(instance=[tsp.name], method=[method],
                            best_case_quality=[performance_df.quality[best_case]], worst_case_quality=[performance_df.quality[worst_case]],
                            avg_quality=[mean(performance_df.quality)], std_quality=[std(performance_df.quality)], 
                            avg_alg_steps=[mean(performance_df.algorithm_steps)], avg_eval_sol=[mean(performance_df.evaluated_solutions)],
                            running_time=[running_time])
        results_stats_df = vcat(results_stats_df, new_row)

        create_solution_quality_plot(performance_df, instance, "$method", "results/solution_quality_plots")
    end
end

# SAVE RESULTS
results_df = vcat(results_list...)
CSV.write(RESULTS_PATH, results_df)
CSV.write(RESULTS_STATS_PATH, results_stats_df)

create_solution_quality_plot(results_stats_df, "results/")

# TODO (Agata): Efficiency of algorithms i.e., quality over time (suggest a good measure and justify your choice) 
# data = CSV.File("results/performance_test.csv") |> DataFrame
# create_solution_quality_plot(data, "berlin52", "$heuristic", "results/solution_quality_plots")
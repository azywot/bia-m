include("methods/constants.jl")
include("methods/all_methods.jl")
include("utils/performance_test.jl")

# 2.1.1, 2.1.3
# instances = ["berlin52", "ch150", "gil262", 
#                 "pcb1173", "pr76", "pr226", 
#                 "pr439", "pr1002", "rat575", 
#                 "st70","tsp225", "u724"]
# instances = ["berlin52", "ch150", "gil262", 
#             "pr76", "pr226", 
#             "pr439", "rat575", 
#             "st70","tsp225", "u724"]
config = Dict{String, Any}("quality_over_time" => true, "similarity_analysis" => true)
instances = ["berlin52", "pr76", "st70"]
methods = [ 
            local_steepest_search, # sets the time for random_* methods
            local_greedy_search, 
            heuristic, 
            random_walk, 
            random_search, 
        ]
iterations = 10
run_performance_analysis(instances, methods, iterations, config)

# 2.1.2, 2.1.4, 2.1.5
df = CSV.read("results/performance_test_stats.csv", DataFrame)
df = df[:, [:instance, :method, :running_time, :avg_alg_steps, :avg_eval_sol]]
latex_table = performance_results_to_latex(df)
println(latex_table)

# 2.2.1, 2.2.2 - DONE
# 2.2.3
config = Dict{String, Any}("similarity_analysis" => true)
similarity_instances = ["berlin52", "ch150", "tsp225"]
similarity_methods = [ 
            local_steepest_search,
            local_greedy_search, 
        ]
similarity_iterations = 100
run_performance_analysis(similarity_instances, similarity_methods, similarity_iterations, config)
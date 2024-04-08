include("methods/constants.jl")
include("methods/all_methods.jl")
include("utils/performance_test.jl")

using CSV

# 2.1.1, 2.1.3
# instances = ["berlin52", "ch150", "gil262", 
#                 "pcb1173", "pr76", "pr226", 
#                 "pr439", "pr1002", "rat575", 
#                 "st70","tsp225", "u724"]
config = Dict{String, Any}("quality_over_time" => true,
                            "method_config" => (
                                # Dict(), # G
                                Dict(), # S
                                Dict("suffix" => "frac_4", "candidate_frac_check" => 0.4), # TS
                                Dict("suffix" => "SA_SUFFIX"),   # SA
                                Dict(), # H
                                Dict(), # RW
                                Dict() # RS
                            )
                        )
instances = ["berlin52", "st70", "pr76"]#, "ch150","tsp225", "pr226", "gil262", "pr439"]#, "rat575", "u724"]
methods = [ 
            # local_steepest_search, # sets the time for random_* methods
            local_greedy_search, 
            tabu_search,
            simulated_annealing,
            # heuristic, 
            # random_walk, 
            # random_search, 
        ]
iterations = 10
run_performance_analysis(instances, methods, iterations, config)

# 2.1.3 Algorithms' efficiency - (quality_initial - quality_final)/time
data_dict = Dict("instance" => [], 
                 "method" => [],
                 "avg_efficiency" => [],
                 "std_efficiency" => [])
for instance in instances
    for method in methods
        df = CSV.read("results/time_quality/$instance"*"_$method.csv", DataFrame)

        first_avg, first_std =  df[1, "avg_quality"], df[1, "std_quality"]
        last_avg, last_std, total_time =  df[end, "avg_quality"], df[end, "std_quality"], df[end, "time"]
        avg_efficiency = (first_avg - last_avg)/total_time
        std_efficiency = (first_std - last_std)/total_time

        push!(data_dict["instance"], instance)
        push!(data_dict["method"], method)
        push!(data_dict["avg_efficiency"], avg_efficiency)
        push!(data_dict["std_efficiency"], std_efficiency)
    end
end
df = DataFrame(data_dict)
create_solution_efficiency_plot(df, "results/efficiency")
create_solution_efficiency_plot(df, "results/efficiency", true)


# 2.1.2, 2.1.4, 2.1.5
df = CSV.read("results/performance_test_stats.csv", DataFrame)
df = df[:, [:instance, :method, 
            :avg_running_time, :std_running_time,  
            :avg_alg_steps, :std_alg_steps,
            :avg_eval_sol, :std_eval_sol]]
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
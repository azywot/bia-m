include("../utils/random_gen.jl")
include("../utils/read_data.jl")
include("../utils/parse_time_tuples.jl")

include("../methods/all_methods.jl")
include("../methods/constants.jl")
include("../plots/solutions_quality.jl")
include("../plots/solutions_similarity.jl")
include("eval.jl")

using DataFrames, CSV, Dates

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
Calculate the similarity between two solutions. 
The similarity is defined as the ratio between intersecting edges and solutions' length

- `solution1::Vector{Int}`: first solution
- `solution2::Vector{Int}`: second solution

returns: the distance between two solutions
"""
function calculate_solution_similarity(solution1, solution2)

    if isnothing(solution1) || isnothing(solution2) || isempty(solution1) || isempty(solution2)
        return -1
    end

    edge_intersection = intersect(get_solution_edges_set(solution1), get_solution_edges_set(solution2))
    return length(edge_intersection)/length(solution1)
end


"""
Performance tests on a an algorithm.

- `iterations::Int`: number of iterations
- `distance_matrix::Matrix{Int}`: matrix of distances between nodes
- `instance::String`: instance name
- `method::Function`: method to use to generate the solution
- `best_solution`: best solution to compare
- `config::Dict{String, Any}`: dictionary of configuration

returns: a dataframe containing the results, running_time
"""
function performance_test(iterations, distance_matrix, instance, method = local_greedy_search, best_solution = nothing,  config = Dict())

    results = Dict()
    N = size(distance_matrix)[1]
    solution_infos = []
    running_times = []
    time_list = []
    quality_list = []

    quality_over_time = get(config, "quality_over_time", false) && "$method" != "heuristic" # this is ugly 

    for i in 1:iterations

        if quality_over_time
            start_time = time()
            solution, times_qualities = method(generate_random_permutation(N), distance_matrix, config)
            end_time = time()

            t, q = transform_time_tuples(times_qualities)
            if length(t) > length(time_list)
                time_list = t
            end
            if !isempty(q)
                push!(quality_list, q)
            end
        else
            start_time = time()
            solution = method(generate_random_permutation(N), distance_matrix, config)
            end_time = time()
        end
        push!(running_times, end_time - start_time)
        push!(solution_infos, solution)
    end
    
    for i in 1:iterations
        similarity_best = calculate_solution_similarity(solution_infos[i].solution, best_solution)
        solution_infos[i].similarity_best = similarity_best
        quality = calculate_solution_quality(solution_infos[i].cost, OPTIMUM_COST[instance])
        solution_infos[i].quality = quality
    end

    df = DataFrame()
    fields = filter(f -> f != :solution, fieldnames(Solution))
    for field in fields
        df[!, Symbol(field)] = getfield.(solution_infos, field)
    end
    df.method .= string(method)

    results["df"] = df
    results["running_time"] = running_times
    quality_avg, quality_std = compute_average_std_lists(quality_list)
    results["quality_over_time"] = [time_list, quality_avg, quality_std]
    
    return results
end


"""
# Run a performance analysis.
- `instances::Vector{String}`: instances names
- `methods::Matrix{Any}`: methods to check
- `iterations::Int`: number of iterations for an experiment
- `config::Dict{String, Any}`: dictionary of configuration

returns: nothing
"""
function run_performance_analysis(instances, methods, iterations, config = Dict())

    date_string = Dates.format(Dates.today(), "dd-mm-yyyy")
    results_path = "results/performance_test_$date_string.csv"
    results_stats_path = "results/performance_test_stats_$date_string.csv"
    time_quality_dir = "results/time_quality/"

    results_list = []
    column_names = [:instance, :method, :best_case_quality, :worst_case_quality,
                    :avg_quality, :std_quality, 
                    :avg_alg_steps, :std_alg_steps, 
                    :avg_eval_sol, :std_eval_sol, 
                    :avg_running_time, :std_running_time]
    results_stats_df = DataFrame([Vector{Any}() for _ in column_names], column_names)
    
    for instance in instances
        config["instance"] = instance
        config["time_limit"] = nothing
        for (idx, method) in enumerate(methods)

            method_config = get(config, "method_config", Dict())
            if !isempty(method_config) && length(method_config) >= idx
                method_config = method_config[idx]
            end
            
            println(instance, ":\t", method, "\tconfig", method_config)
            method_suffix = haskey(method_config, "suffix") && length(method_config["suffix"]) > 0 ? "$method" * "_" * method_config["suffix"] : method

            fielname = joinpath(DATA_DIR, instance * ".tsp")
            tsp = read_tsp_file(fielname)

            results = performance_test(iterations, tsp.distance_matrix, instance, method, tsp.opt_tour, merge(config, method_config))
            performance_df, running_times = results["df"], results["running_time"]
            performance_df.method .= "$method_suffix"

            if !isempty(results["quality_over_time"][1])
                time_quality_df = DataFrame(time = results["quality_over_time"][1], 
                                            avg_quality = results["quality_over_time"][2],
                                            std_quality = results["quality_over_time"][3])
                CSV.write(time_quality_dir * "$instance" * "_$method_suffix.csv", time_quality_df)
            elseif get(config, "quality_over_time", false) && "$method_suffix" == "heuristic"
                time_quality_df = DataFrame(time = [mean(running_times)], 
                                            avg_quality = [mean(performance_df.quality)],
                                            std_quality = [std(performance_df.quality)])
                CSV.write(time_quality_dir * "$instance" * "_$method_suffix.csv", time_quality_df)
            end

            if isnothing(config["time_limit"])
                config["time_limit"] = maximum(running_times)
            end

            push!(results_list, performance_df)
            performance_df.instance .= tsp.name

            best_case = argmin(performance_df.cost)
            worst_case = argmax(performance_df.cost)

            new_row = DataFrame(instance=[tsp.name], method=["$method_suffix"],
                                best_case_quality=[performance_df.quality[best_case]], worst_case_quality=[performance_df.quality[worst_case]],
                                avg_quality=[mean(performance_df.quality)], std_quality=[std(performance_df.quality)], 
                                avg_alg_steps=[mean(performance_df.algorithm_steps)], std_alg_steps=[std(performance_df.algorithm_steps)], 
                                avg_eval_sol=[mean(performance_df.evaluated_solutions)], std_eval_sol=[std(performance_df.evaluated_solutions)],
                                avg_running_time=[mean(running_times)], std_running_time=[std(running_times)])

            results_stats_df = vcat(results_stats_df, new_row)

            # SAVE PLOTS (SIMILARITY) - NOTE: only for ones with a optimal solution known
            if get(config, "similarity_analysis", false) && !isempty(tsp.opt_tour)
                create_solution_similarity_plot(performance_df, instance, "$method_suffix", "results/solution_similarity_plots")
            end

            if get(config, "quality_over_time", false)
                create_quality_over_time_plot(instance, time_quality_dir)
            end
        end
        # Save/update results every instance
        results_df = vcat(results_list...)
        CSV.write(results_path, results_df)
    
        results_stats_df.method = map(string, results_stats_df.method)
        CSV.write(results_stats_path, results_stats_df)
    
        # SAVE PLOTS (QUALITY)
        create_solution_quality_plots(results_stats_df, "results/quality")
        without_random = filter(row -> !(row.method in ["random_search", "random_walk"]), results_stats_df)
        create_solution_quality_plots(without_random, "results/quality_without_random")
    end
end

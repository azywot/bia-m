include("methods/constants.jl")
include("methods/all_methods.jl")
include("utils/performance_test.jl")


# 2.1.1, 2.1.2, 2.1.4, 2.1.5 - DONE (TODO: tableka)
# instances = ["berlin52", "ch150", "gil262", 
#                 "pcb1173", "pr76", "pr226", 
#                 "pr439", "pr1002", "rat575", 
#                 "st70","tsp225", "u724"]
instances = ["berlin52", "pr76", "st70"]
methods = [ 
            local_steepest_search, # sets the time for random_* methods
            local_greedy_search, 
            # heuristic, 
            random_walk, 
            random_search, 
        ]
iterations = 10
run_performance_analysis(instances, methods, iterations)


# 2.2.1 - to change (Zuza)
# cost -> quality


# 2.2.2 - DONE


# 2.2.3
similarity_instances = ["berlin52", "ch150", "tsp225"] # select some interesting instances
similarity_methods = [ 
            local_steepest_search,
            local_greedy_search, 
        ]
similarity_iterations = 100
run_performance_analysis(similarity_instances, similarity_methods, similarity_iterations, true)


# 2.1.3 TODO (Agata)
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
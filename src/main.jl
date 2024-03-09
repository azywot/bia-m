include("utils/random_gen.jl")
include("utils/read_data.jl")
include("utils/eval.jl")
include("utils/performance_tests.jl")

include("methods/heuristic.jl")
include("methods/local_search.jl")
include("methods/random_search.jl")
include("methods/random_walk.jl")

n = 5
randomness_measure, counts, histogram = permutation_test(n, factorial(n) * 1000)
randomness_measure
histogram

# READ SELECTED INSTANCES
directory_path = "data/SEL_tsp"
INSTANCES = ["berlin52", "ch150", "gil262", 
                "pcb1173", "pr76", "pr226", 
                "pr439", "pr1002", "rat575", 
                "st70","tsp225", "u724"]

for tsp in INSTANCES
    fielname = joinpath(directory_path, tsp * ".tsp")
    tsp = read_tsp_file(fielname)
    println(tsp)
end


# TEST
filename = "data/SEL_tsp/pr76.tsp"
test_tsp = read_tsp_file(filename)
println(test_tsp)

N = size(test_tsp.distance_matrix)[1]
initial_solution = generate_random_permutation(N)
initial_cost = evaluate_solution(initial_solution, test_tsp.distance_matrix)
println("Initial solution cost: ", initial_cost)

random_search_sol, random_search_cost = random_search(initial_solution, test_tsp.distance_matrix)
println("Random search cost: ", random_search_cost)

heuristic_sol, heuristic_cost = heuristic(initial_solution, test_tsp.distance_matrix)
println("Heuristic cost: ", heuristic_cost)

random_walk_sol, random_walk_cost = random_walk(initial_solution, test_tsp.distance_matrix)
println("Random walk cost: ", random_walk_cost)

ls_greedy_sol, ls_greedy_cost = local_greedy_search(initial_solution, test_tsp.distance_matrix)
println("Local greedy search cost: ", ls_greedy_cost)

ls_steepest_sol, ls_steepest_cost = local_steepest_search(initial_solution, test_tsp.distance_matrix)
println("Local steepest search cost: ", ls_steepest_cost)

# TODO: plot it (will do shortly)
similarity_df = performance_tests(100, test_tsp.distance_matrix, local_steepest_search, ls_steepest_sol)
mean(similarity_df.edge_distance_best)
std(similarity_df.edge_distance_best)
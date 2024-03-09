include("utils/random_gen.jl")
include("utils/read_data.jl")
include("utils/eval.jl")
include("utils/performance_tests.jl")

include("methods/heuristic.jl")
include("methods/local_search.jl")
include("methods/random_search.jl")
include("methods/random_walk.jl")

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


METHODS = [random_search, 
            random_walk, 
            heuristic, 
            local_greedy_search, 
            local_steepest_search]

for method in METHODS
    solution = method(initial_solution, test_tsp.distance_matrix)
    println(uppercase(replace("$method", "_" => " ")), ":\n", solution)
end

# TODO: plot it (will do shortly)
similarity_df = performance_tests(10, test_tsp.distance_matrix, local_greedy_search, ls_steepest_sol)
mean(similarity_df.edge_distance_best)
std(similarity_df.edge_distance_best)
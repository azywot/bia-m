include("utils/random_gen.jl")
include("utils/read_data.jl")

n = 5
randomness_measure, counts, histogram = permutation_test(n, factorial(n) * 1000)
randomness_measure
histogram

# TEST
filename = "data/SEL_tsp/a280.tsp"
test_tsp = read_tsp_file(filename)
println(test_tsp)

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
include("utils/random_gen.jl")
include("utils/read_data.jl")


n = 5
randomness_measure, counts, histogram = permutation_test(n, factorial(n) * 1000)
randomness_measure
histogram


filename = "data/SEL_tsp/a280.tsp"
tsp_dict = read_tsp_file(filename)
println("TSP instance:\n", tsp_dict)


directory_path = "data/SEL_tsp"
tsp_files = filter(file -> endswith(file, ".tsp"), readdir(directory_path))

for tsp in tsp_files
    fielname = joinpath(directory_path, tsp)
    tsp_dict = read_tsp_file(fielname)
    print(tsp_dict["NAME"], tsp_dict["COMMENT"], "\n")
end
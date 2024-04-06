using LinearAlgebra

include("constants.jl")
include("local_search.jl")
include("../utils/eval.jl")
include("../utils/random_gen.jl")
include("../utils/read_data.jl")


# function calculate_cost(matrix, tour)
#     return sum(matrix[tour[i], tour[i+1]] for i in 1:length(tour)-1)
# end


# plots: params for chosen instances

# TODO other methods?
function generate_neighbor(tour)
    n = length(tour)
    i, j = rand(1:n), rand(1:n)
    tour[i], tour[j] = tour[j], tour[i]
    return tour
end

function simulated_annealing(distace_matrix, initial_solution, temperature, alpha, max_iter, P, L)
    current_tour = initial_solution
    best_cost = evaluate_solution(current_tour, distace_matrix)
    no_improve = 0
    evaluated_solutions = 0

    for iteration in 1:max_iter
        for _ in 1:L
            new_tour = generate_neighbor(copy(current_tour))
            new_cost = evaluate_solution(new_tour, distace_matrix)
            delta = new_cost - best_cost
            if delta <= 0 || rand() < exp(-delta / temperature)
                current_tour = new_tour
                best_cost = new_cost
                no_improve = 0
            end
            evaluated_solutions += 1
        end
        temperature *= alpha

        # stopping criterion 1
        # if temperature < 0.01
        #     break
        # end

        # stopping criterion 2
        no_improve += 1
        if no_improve > P * L
            break
        end
    end
    final_solution = Solution(Vector{Int}(current_tour), Int(best_cost), -1, evaluated_solutions)

    return current_tour, best_cost
end

tsp = read_tsp_file("data/SEL_tsp/berlin52.tsp")
instance_size = size(tsp.distance_matrix, 1)
L = instance_size^2
initial_solution = generate_random_permutation(instance_size)
tour, cost = simulated_annealing(tsp.distance_matrix, initial_solution, 100.0, 0.9, 100, 10, L)
println("Best tour: $tour")
println("Cost of best tour: $cost")

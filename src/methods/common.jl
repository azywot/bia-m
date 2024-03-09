import Base: isless
using DataFrames

TIME_LIMIT = 10

mutable struct Solution
    solution::Vector{Int}
    cost::Int
    # algorithm::String # (e.g. random_walk, not necessary now)
    edge_distance_best::Int
    algorithm_steps::Int
    evaluated_solutions::Int
end


function Solution(solution::Vector{Int}, cost::Int, algorithm_steps::Int, evaluated_solutions::Int)
    edge_distance_best = -1
    return Solution(solution, cost, edge_distance_best, algorithm_steps, evaluated_solutions)
end


function Base.show(io::IO, info::Solution)
    println(io, "Solution")
    println(io, "solution: ", info.solution)
    println(io, "cost: ", info.cost)
    println(io, "edge distance (wrt the best solution): ", info.edge_distance_best)
    println(io, "algorithm steps: ", info.algorithm_steps)
    println(io, "evaluated steps: ", info.evaluated_solutions)
end


function isless(a::Solution, b::Solution)
    return a.cost < b.cost
end

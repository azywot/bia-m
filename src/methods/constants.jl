import Base: isless
using DataFrames

TIME_LIMIT = 5
DATA_DIR = "data/SEL_tsp"

OPTIMUM_COST = Dict(
    "berlin52" => 7542,
    "ch150" => 6528,
    "gil262" => 2378,
    "pcb1173" => 56892,
    "pr76" => 108159,
    "pr226" => 80369,
    "pr439" => 107217,
    "pr1002" => 259045,
    "rat575" => 6773,
    "st70" => 675,
    "tsp225" => 3919,
    "u724" => 41910
)
mutable struct Solution
    solution::Vector{Int}
    cost::Int
    # algorithm::String # (e.g. random_walk, not necessary now)
    quality::Float32
    similarity_best::Float32
    algorithm_steps::Int
    evaluated_solutions::Int
end


function Solution(solution::Vector{Int}, cost::Int, algorithm_steps::Int, evaluated_solutions::Int)
    quality = -1
    similarity_best = -1
    return Solution(solution, cost, quality, similarity_best, algorithm_steps, evaluated_solutions)
end


function Base.show(io::IO, info::Solution)
    println(io, "Solution")
    println(io, "solution: ", info.solution)
    println(io, "cost: ", info.cost)
    println(io, "quality (wrt the best solution): ", info.quality)
    println(io, "similarity (wrt the best solution): ", info.similarity_best)
    println(io, "algorithm steps: ", info.algorithm_steps)
    println(io, "evaluated steps: ", info.evaluated_solutions)
end


function isless(a::Solution, b::Solution)
    return a.cost < b.cost
end

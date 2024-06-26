using Distances
using DataFrames
import Base.show

struct TSPInstance
    name::String
    comment::String
    type::String
    edge_weight_type::String
    distance_matrix::Matrix{Int}
    opt_tour::Vector{Int}
end


function show(io::IO, tsp::TSPInstance)
    println(io, "TSPInstance:")
    println(io, "  Name: ", tsp.name)
    println(io, "  Comment: ", tsp.comment)
    println(io, "  Type: ", tsp.type)
    println(io, "  Edge Weight Type: ", tsp.edge_weight_type)
    println(io, "  Distance matrix: ", size(tsp.distance_matrix))
    println(io, "  Optimal solution: ", tsp.opt_tour)
end


"""
## Creates a distance matrix based on a list of nodes.

- `nodes::Vector{Tuple{Int, Tuple{Float32, Float32}}}`: a list of nodes

returns: A distance matrix of nodes. 
"""
function create_distance_matrix(nodes)

    N = length(nodes)
    inf = 1000000

    dm = zeros(N, N)
    for i in 1:N
        node1 = nodes[i]
        for j in i:N
            node2 = nodes[j]
            distance = round(euclidean(node1[2], node2[2]))
            dm[node1[1], node2[1]] = distance 
            dm[node2[1], node1[1]] = distance 
        end
    end

    for i in 1:N
        dm[i, i] = inf
    end

    return dm
end


"""
## Reads a file containing a TSP instance.

- `filename::String`: filename of TSP instance

returns: `TSPInstance`
"""
function read_tsp_file(filename)
    data_dict = Dict{String, Any}()
    node_data = []

    open(filename, "r") do file
        for line in eachline(file)
            if occursin("NODE_COORD_SECTION", uppercase(line))
                break
            end

            parts = split(line, ":")
            key = strip(parts[1])
            value = strip(parts[2])
            data_dict[key] = value
        end

        for line in eachline(file)
            parts = split(line)
            if length(parts) > 1
                node = parse(Int, parts[1])
                coord_1 = parse(Float64, parts[2])
                coord_2 = parse(Float64, parts[3])
                push!(node_data, (node, (coord_1, coord_2)))
            end
            if occursin("EOF", uppercase(line))
                break
            end
        end
    end

    opt_tour_filename = replace(filename, ".tsp" => ".opt.tour")
    opt_tour = []
    in_tour_section = false

    if isfile(opt_tour_filename)
        open(opt_tour_filename, "r") do file
            for line in eachline(opt_tour_filename)
                if occursin("TOUR_SECTION", line)
                    in_tour_section = true
                elseif occursin("EOF", line)
                    break
                elseif in_tour_section && !occursin("-1", line)
                    tour_values = parse.(Int, split(line))
                    opt_tour = vcat(opt_tour, tour_values)
                end
            end
        end
    end

    tsp_instance = TSPInstance(
        get(data_dict, "NAME", ""),
        get(data_dict, "COMMENT", ""),
        get(data_dict, "TYPE", ""),
        get(data_dict, "EDGE_WEIGHT_TYPE", ""),
        create_distance_matrix(node_data),
        opt_tour
    )

    return tsp_instance
end


function performance_results_to_latex(df::DataFrame)

    col_names = names(df)
    n = length(unique(df.method))
    
    latex_str = "\\begin{table}[h]\n"
    latex_str *= "\\centering\n"
    latex_str *= "\\begin{tabular}{"
    
    for i in 1:length(col_names)
        latex_str *= "c|"
    end
    latex_str = latex_str[1:end-1]
    
    latex_str *= "}\n"

    for col in col_names
        latex_str *= "$col & "
    end
    latex_str = latex_str[1:end-2]
    latex_str *= "\\\\\n"
    
    latex_str *= "\\hline\n"
    grouped_df = groupby(df, :instance)
    
    for group in grouped_df
        instance_name = unique(group.instance)[1]
        latex_str *= "\\multirow{$n}{*}{$instance_name} "
        for row in eachrow(group)
            latex_str *= "& "
            for col in col_names[2:end]
                val = row[col]
                if typeof(val) <: Number
                    latex_str *= string(round(val, digits=4)) * " & " # digits
                else
                    latex_str *= string(val) * " & "
                end
            end
            latex_str = latex_str[1:end-2]
            latex_str *= "\\\\\n"
        end
        latex_str *= "\\hline\n"
    end
    
    latex_str *= "\\end{tabular}\n"
    latex_str *= "\\caption{caption}\n"
    latex_str *= "\\label{label}\n"
    latex_str *= "\\end{table}"

    latex_str = replace(latex_str, "local_steepest_search" => "LS")
    latex_str = replace(latex_str, "local_greedy_search" => "LG")
    latex_str = replace(latex_str, "random_walk" => "RW")
    latex_str = replace(latex_str, "random_search" => "RS")
    latex_str = replace(latex_str, "heuristic" => "H")
    latex_str = replace(latex_str, "tabu_search" => "TS")
    latex_str = replace(latex_str, "simulated_annealing" => "SA")
    latex_str = replace(latex_str, "_" => " ")
    latex_str = replace(latex_str, "-1.0" => "-")

    return latex_str
end
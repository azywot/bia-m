using Distances
import Base.show

struct TSPInstance
    name::String
    comment::String
    type::String
    edge_weight_type::String
    distance_matrix::Matrix{Float32}
end


function show(io::IO, tsp::TSPInstance)
    println(io, "TSPInstance:")
    println(io, "  Name: ", tsp.name)
    println(io, "  Comment: ", tsp.comment)
    println(io, "  Type: ", tsp.type)
    println(io, "  Edge Weight Type: ", tsp.edge_weight_type)
    println(io, "  Distance matrix: ", size(tsp.distance_matrix))
end

# TODO: verify the distances with the pdf, ensure the number of decimal places is ok (now it's not set)
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
            distance = euclidean(node1[2], node2[2])
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

returns: Dictionary of TSP instance data
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

    tsp_instance = TSPInstance(
        get(data_dict, "NAME", ""),
        get(data_dict, "COMMENT", ""),
        get(data_dict, "TYPE", ""),
        get(data_dict, "EDGE_WEIGHT_TYPE", ""),
        create_distance_matrix(node_data)
    )

    return tsp_instance
end


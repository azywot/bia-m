import Base.show

struct TSPInstance
    name::String
    comment::String
    type::String
    edge_weight_type::String
    nodes::Vector{Tuple{Int, Tuple{Float32, Float32}}}
end


function show(io::IO, tsp::TSPInstance)
    println(io, "TSPInstance:")
    println(io, "  Name: ", tsp.name)
    println(io, "  Comment: ", tsp.comment)
    println(io, "  Type: ", tsp.type)
    println(io, "  Edge Weight Type: ", tsp.edge_weight_type)
    println(io, "  Nodes:", length(tsp.nodes))
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
        node_data
    )

    return tsp_instance
end


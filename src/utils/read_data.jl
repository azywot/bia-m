"""
## Reads a file containing a TSP instance.

- `filename::String`: filename of TSP instance

returns: Dictionary of TSP instance data
"""
# TODO: adjust the function to handle different data formats, rn it fails for example for bayg29.tsp
function read_tsp_file(filename)
    data_dict = Dict{String, Any}()
    node_data = []

    open(filename, "r") do file
        for line in eachline(file)
            if occursin("NODE_COORD_SECTION", line)
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
        end
    end

    data_dict["NODES"] = node_data
    return data_dict
end


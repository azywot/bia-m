using DataFrames
using Plots


"""
Create a scatter plot depicting the quality of a TSP algorithm for an instance and save it.

- `data::DataFrame`: data
- `instance::String`: the considered
- `method::String`: method considered
- `savepath::String`: path to save 

returns: nothing
"""
function create_solution_quality_plot(data::DataFrame, instance::String, method::String, savepath::String)

    filtered_data = filter(row -> row.instance == instance && row.method == method, data)

    color = filtered_data[1, "optimum"] ? :darkgreen : :green
    scatter(filtered_data.cost, filtered_data.edge_similarity_best, color=color, legend=false)

    quality = filtered_data[1, "optimum"] ? "QUALITY" : "ESTIMATED QUALITY"
    title!("$quality - $(uppercase(instance)) ($(uppercase(replace("$method", "_" => " "))))")

    xlabel!("Cost")
    ylabel!("Edge similarity")

    savefig(savepath * "/quality_$(instance)_$(method).svg")
end
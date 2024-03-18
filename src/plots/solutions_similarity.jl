using DataFrames
using Plots


"""
Create a scatter plot depicting the similarity of a TSP algorithm wrt the optimum and save it.

- `data::DataFrame`: data
- `instance::String`: the considered
- `method::String`: method considered
- `savepath::String`: path to save 

returns: nothing
"""
function create_solution_similarity_plot(data::DataFrame, instance::String, method::String, savepath::String)

    filtered_data = filter(row -> row.instance == instance && row.method == method, data)

    color = filtered_data[1, "optimum"] ? :darkgreen : :green
    scatter(filtered_data.cost, filtered_data.edge_similarity_best, color=color, legend=false)
    title!("$(uppercase(instance)) - $(uppercase(replace("$method", "_" => " ")))")

    xlabel!("Cost")
    ylabel!("Edge similarity (wrt the optimum)")

    savefig(savepath * "/similarity_$(instance)_$(method).svg")
end
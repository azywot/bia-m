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
    scatter(filtered_data.edge_distance_best, filtered_data.cost, color=:green, legend=false)

    title!("QUALITY - $(uppercase(instance)) ($(uppercase(replace("$method", "_" => " "))))")
    xlabel!("Edge Distance")
    ylabel!("Cost")

    savefig(savepath * "/scatter_plot_$(instance)_$(method).svg")
end
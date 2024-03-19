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

    scatter(filtered_data.quality, filtered_data.similarity_best, color=:green, legend=false, ylims = (0,1)) # TODO: should the lim be fixed?
    title!("$(uppercase(instance)) - $(uppercase(replace("$method", "_" => " ")))")

    # both relative distance and similarity are with respect to the optimum/best solution found
    xlabel!("relative distance")
    ylabel!("similarity")

    savefig(savepath * "/similarity_$(instance)_$(method).png")
end
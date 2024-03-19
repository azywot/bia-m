using DataFrames, StatsPlots, CategoricalArrays


function extract_nodes(instance::String)
    digits = filter(x -> isdigit(x), instance)
    return parse(Int, digits)
end


"""
Create a scatter plot depicting the quality of a TSP algorithm for an instance and save it.

- `data::DataFrame`: data
- `instance::String`: the considered
- `method::String`: method considered
- `savepath::String`: path to save 

returns: nothing
"""
function create_solution_quality_plot(data::DataFrame, savepath::String)

    df = deepcopy(data)
    df.method = map(method -> replace(string(method), "_" => " "), df.method)
    df.avg_quality = map(Float64, df.avg_quality)
    df.std_quality = map(Float64, df.std_quality)
    df.nodes = extract_nodes.(df.instance)
    df = sort(df, [:nodes])
    df.instance = CategoricalArray(df.instance, levels = unique(df.instance))

    plot = groupedbar(
                df.instance, 
                df.avg_quality, 
                yerr = df.std_quality, 
                group =  df.method, 
                ylabel = "relative distance", 
                title = "Average distance from the optimum",
                bar_width = 0.67, 
                c = [:blue3 :green :green3 :red2 :red3], 
                markerstrokewidth = 1.5,
            )

    savefig(plot, savepath * "/solution_quality_plot.svg")

end
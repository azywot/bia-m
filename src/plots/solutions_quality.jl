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
function create_solution_quality_plot(data::DataFrame, savepath::String, stat::String = "avg_quality")

    df = deepcopy(data)
    df.method = map(method -> replace(string(method), "_" => " "), df.method)
    df.avg_quality = map(Float32, df.avg_quality)
    df.best_case_quality= map(Float32, df.best_case_quality)
    df.worst_case_quality = map(Float32, df.worst_case_quality)
    df.std_quality = map(Float32, df.std_quality)
    df.nodes = extract_nodes.(df.instance)
    
    method_order = Dict("random search" => 1, "random walk" => 2, "heuristic" => 3, "local greedy search" => 4, "local steepest search" => 5)
    df = sort(df, :method, by = x -> get(method_order, x, length(method_order)))
    df = sort(df, [:nodes])
    df.instance = CategoricalArray(df.instance, levels = unique(df.instance))
    df.method = CategoricalArray(df.method, levels = unique(df.method))

    colors = Dict("random search" => :red, "random walk" => :darkred, "heuristic" => :blue3, "local greedy search" => :green, "local steepest search" => :green3)
    color_list = [get(colors, m, :black) for m in df.method]
    yerr = stat == "avg_quality" ?  df.std_quality : nothing
    prefix = stat == "avg_quality" ?  "Average" : (stat == "best_case_quality" ?  "The best" : "The worst")

    plot = groupedbar(
                df.instance, 
                df[:, Symbol(stat)], 
                yerr = yerr, 
                group =  df.method, 
                ylabel = "relative distance", 
                title = "$prefix distances from the optimum",
                bar_width = 0.67, 
                c = color_list, 
                markerstrokewidth = 1.5,
                ylims = (0, maximum(df.worst_case_quality)+maximum(df.std_quality)),
                legend=:topleft
            )
    
    savefig(plot, savepath * "/solution_quality_plot_$stat.png")

end

function create_solution_quality_plots(data::DataFrame, savepath::String)
    create_solution_quality_plot(data, savepath, "avg_quality")
    create_solution_quality_plot(data, savepath, "best_case_quality")
    create_solution_quality_plot(data, savepath, "worst_case_quality")
end
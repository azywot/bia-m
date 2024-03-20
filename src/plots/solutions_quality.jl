using DataFrames, Plots,StatsPlots, CategoricalArrays, Glob

COLORS = Dict("random_search" => :red, 
              "random_walk" => :darkred, 
              "heuristic" => :blue3, 
              "local_greedy_search" => :green, 
              "local_steepest_search" => :green3)

METHOD_SYMBOLS = Dict("random_search" => "RS", 
                "random_walk" => "RW", 
                "heuristic" => "H", 
                "local_greedy_search" => "G", 
                "local_steepest_search" => "S")

function extract_nodes(instance::String)
    digits = filter(x -> isdigit(x), instance)
    return parse(Int, digits)
end


"""
Create a bar plot depicting the quality of a TSP solutions and save it.

- `data::DataFrame`: data
- `savepath::String`: path to save 
- `stat::String`: statistic to consider

returns: nothing
"""
function create_solution_quality_plot(data::DataFrame, savepath::String, stat::String = "avg_quality")

    df = deepcopy(data)
    df.method = map(string, df.method)
    df.method_renamed = map(method -> get(METHOD_SYMBOLS, method, method), df.method)
    df.avg_quality = map(Float32, df.avg_quality)
    df.best_case_quality= map(Float32, df.best_case_quality)
    df.worst_case_quality = map(Float32, df.worst_case_quality)
    df.std_quality = map(Float32, df.std_quality)
    df.nodes = extract_nodes.(df.instance)
    
    method_order = Dict("RS" => 1, "RW" => 2, "H" => 3, "G" => 4, "S" => 5)
    df = sort(df, :method_renamed, by = x -> get(method_order, x, length(method_order)))
    df = sort(df, [:nodes])
    df.instance = CategoricalArray(df.instance, levels = unique(df.instance))
    df.method_renamed = CategoricalArray(df.method_renamed, levels = unique(df.method_renamed))

    color_list = [get(COLORS, m, :black) for m in df.method]
    yerr = stat == "avg_quality" ?  df.std_quality : nothing
    prefix = stat == "avg_quality" ?  "Average" : (stat == "best_case_quality" ?  "The closest" : "The furthest")

    plot = groupedbar(
                df.instance, 
                df[:, Symbol(stat)], 
                yerr = yerr, 
                group =  df.method_renamed, 
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



"""
Create a line plot depicting the quality over time for different methods for a given instance of TSP.

- `instance::String`: instance name
- `path::String`: data path and the path to save

returns: nothing
"""
function create_quality_over_time_plot(instance::String, path::String)

    files = glob("$instance*.csv", path)
    data = Dict{String, Any}()
    heuristic_df = nothing
    lengths = []

    for file in files 
        method = last(split(file, "/"))
        method = replace(method, instance * "_" => "")
        method = replace(method, ".csv" => "")
        df = CSV.read(file, DataFrame)
        if method == "heuristic"
            heuristic_df = df
        else
            data[method] = df
            push!(lengths, size(df, 1))
        end
    end

    first = true
    for (method, df) in data
        if first
            plot(df.time, 
                df.avg_quality, 
                label=get(METHOD_SYMBOLS, method, method), 
                color=get(COLORS, method, :black), 
                linewidth=2, 
                legend=:topright)
            first = false
        else
            plot!(df.time, 
                  df.avg_quality, 
                  label=get(METHOD_SYMBOLS, method, method), 
                  color=get(COLORS, method, :black), 
                  linewidth=2)
        end
        plot!(df.time, 
                df.avg_quality .- df.std_quality, 
                fillrange=df.avg_quality .+ df.std_quality, 
                fillalpha=0.15, 
                c=get(COLORS, method, :black), 
                linealpha=0,
                label=nothing)
    end
    if !isnothing(heuristic_df)
        scatter!(heuristic_df.time, 
                 heuristic_df.avg_quality, 
                 yerr = heuristic_df.std_quality,
                 label=get(METHOD_SYMBOLS, "heuristic", "heuristic"), 
                 color=get(COLORS, "heuristic", :black), 
                 markersize=5)
    end
    xlabel!("time [s]")
    ylabel!("relative distance")
    title!("$instance - quality over time")
    savefig(path * "$instance" * "_quality_over_time_plot.png")
end

# create_quality_over_time_plot("st70", "results/time_quality/")
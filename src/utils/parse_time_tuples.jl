using Statistics

function compute_average_std_lists(lists)
    if isempty(lists) || minimum(length(lst) for lst in lists) == 0
        return [], []
    end
    max_length = maximum(length(lst) for lst in lists)
    padded_lists = [vcat(lst, fill(lst[end], max_length - length(lst))) for lst in lists]
    
    avg_arr = zeros(Float32, max_length)
    std_arr = zeros(Float32, max_length)
    
    for lst in padded_lists
        avg_arr .+= lst
    end
    avg_arr ./= length(lists)
    
    for lst in padded_lists
        std_arr .+= (lst .- avg_arr).^2
    end
    std_arr = sqrt.(std_arr ./ length(lists))
    
    return avg_arr, std_arr
end

"""
## Transform time tuples to the form that can be plotted.

- `tuples::Vector{Tuple{Float32, Float32}}`: time tuples
- `digits::Int`: precistion

returns: equallly spaced time tuples and their respective best qualities
"""
function transform_time_tuples(tuples, digits = 2)
    increment = 1/10^digits
    time_list = []
    quality_list = []

    time_x = round(tuples[1][1], digits=digits)
    to_be_averaged = [tuples[1][2]]

    for i in 2:length(tuples)
        if round(tuples[i][1], digits=digits) == time_x
            push!(to_be_averaged, tuples[i][2])
        else
            avg_quality = mean(to_be_averaged)
            push!(time_list, time_x)
            push!(quality_list, avg_quality)
            mul = 1
            
            while round(tuples[i][1], digits=digits) - round(time_x + mul*increment, digits=digits) >= increment
                push!(time_list, round(time_x + mul*increment, digits=digits))
                push!(quality_list, avg_quality)
                mul+=1
            end
            push!(time_list, round(time_x + mul*increment, digits=digits))
            push!(quality_list, avg_quality)
                
            time_x = round(tuples[i][1], digits=digits)
            to_be_averaged = [tuples[i][2]]
        end
    end

    if length(time_list) == 0
        return [], []
    end

    time_list[end] = time_x
    quality_list[end] = mean(to_be_averaged)

    to_delete = []
    for t in 2:length(time_list)
        if time_list[t-1] == time_list[t]
            push!(to_delete, t-1)
        end
    end

    deleteat!(time_list, to_delete)
    deleteat!(quality_list, to_delete)
    push!(time_list, round(time_x+increment, digits=digits))
    pushfirst!(quality_list, tuples[1][2])

    return time_list, quality_list
end

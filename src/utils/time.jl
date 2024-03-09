function measure_time(algorithm, max_duration=10, max_iterations=10)
    i = 0
    start_time = time()
    
    # while time() - start_time < max_duration && i < max_iterations
    #     algorithm()
    #     i += 1
    # end
    # NOTE: I changed the loop to match do-while as on the labs
    while true
        algorithm()
        i += 1
        
        if time() - start_time >= max_duration || i >= max_iterations
            break
        end
    end
    
    return (time() - start_time) / i
end

# function test_algorithm()
#     sleep(0.5)
# end

# avg_time = measure_time(test_algorithm)
# println("Average Running Time: $avg_time seconds")
function zscore!(col, μ, σ)
    return (col .- μ) ./ σ
end

function preprocess_vector(x::Vector{Union{Missing, Float64}})
    x_clean = coalesce.(x, median(skipmissing(x)))
    μ = mean(skipmissing(x_clean))
    σ = std(skipmissing(x_clean))
    return zscore!(x_clean, μ, σ), μ, σ
end

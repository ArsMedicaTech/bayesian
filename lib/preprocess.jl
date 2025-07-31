function zscore!(col, μ, σ)
    return (col .- μ) ./ σ
end

function preprocess_vector(x::AbstractVector{<:Real})
    x_clean = if eltype(x) <: Union{Missing, Real}
        coalesce.(x, median(skipmissing(x)))
    else
        x
    end

    μ = mean(x_clean)
    σ = std(x_clean)
    return zscore!(x_clean, μ, σ), μ, σ
end

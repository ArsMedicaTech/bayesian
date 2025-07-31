using Statistics: mean

σ(x) = 1 / (1 + exp(-x))

function logistic_score(chain, param_syms::Vector{Symbol}, inputs::Vector{Float64})
    preds = zeros(length(chain[param_syms[1]]))
    for (i, param) in enumerate(param_syms)
        preds .+= chain[param] .* inputs[i]
    end
    return mean(σ.(preds))
end

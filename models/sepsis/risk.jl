include("../../lib/inference_utils.jl")

using JLSO

const SEPSIS_ARTIFACT = JLSO.load("saved/chain.jls")

function load_chain_dict(artifact::Dict)
    #names = SEPSIS_ARTIFACT[:param_names]
    names = SEPSIS_ARTIFACT[:param_names][1:size(SEPSIS_ARTIFACT[:chain_values], 2)]
    arr   = SEPSIS_ARTIFACT[:chain_values]  # Matrix: (samples × params)
    @assert size(arr, 2) == length(names) "Mismatch: param_names has $(length(names)) but matrix has $(size(arr, 2)) columns"
    Dict(Symbol(n) => arr[:, i] for (i, n) in enumerate(names))
end

const SCALE           = SEPSIS_ARTIFACT[:scaling]
const SEPSIS_CHAIN = load_chain_dict(SEPSIS_ARTIFACT)

@show size(SEPSIS_ARTIFACT[:chain_values])
@show length(SEPSIS_ARTIFACT[:param_names])
@show typeof(SEPSIS_CHAIN)                      # Dict{Symbol, Vector{Float64}}
@show typeof(SEPSIS_CHAIN[:β0]) == Vector{Float64}  # true

function score_sepsis(input::Dict)
    return logistic_score(
        SEPSIS_CHAIN,
        [:β0, :βt, :βhr, :βwbc],
        [1.0, input[:Temp], input[:HR], input[:WBC]]  # Include intercept as 1.0
    )
end

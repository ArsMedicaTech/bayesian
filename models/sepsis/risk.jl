include("../../lib/inference_utils.jl")
using JLSO

const SEPSIS_CHAIN = JLSO.load("models/sepsis/saved_chain.jls")["chain"]

# PREPROCESSING
function preprocess_sepsis(input::Dict)
    # Ensure input has the required fields
    if !haskey(input, :temp) || !haskey(input, :hr) || !haskey(input, :wbc)
        error("Input must contain 'temp', 'hr', and 'wbc' fields.")
    end

    # Impute missing vitals with median
    impute_median!(col) = coalesce.(col, median(skipmissing(col)))
    input.temp = impute_median!(input.temp)
    input.hr = impute_median!(input.hr)
    input.wbc = impute_median!(input.wbc)

    # Normalize
    zscore!(col) = (col .- mean(col)) ./ std(col)
    input.temp_z = zscore!(input.temp)
    input.hr_z = zscore!(input.hr)
    input.wbc_z = zscore!(input.wbc)

    # Convert inputs to Float64
    return Dict(
        :temp => Float64(input.temp),
        :hr => Float64(input.hr),
        :wbc => Float64(input.wbc)
    )
end

function score_sepsis(input::Dict)
    processed = preprocess_sepsis(input)
    return logistic_score(SEPSIS_CHAIN, [:β0, :βt, :βhr, :βwbc], [processed.temp, processed.hr, processed.wbc])
end

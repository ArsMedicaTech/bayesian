include("../../lib/inference_utils.jl")
using JLSO

const SEPSIS_CHAIN = JLSO.load("models/sepsis/saved_chain.jls")["chain"]

# PREPROCESSING
function preprocess_sepsis(input::Dict)
    # Ensure input has the required fields
    if !haskey(input, :Temp) || !haskey(input, :HR) || !haskey(input, :WBC)
        error("Input must contain 'Temp', 'HR', and 'WBC' fields.")
    end

    # Impute missing vitals with median
    impute_median!(col) = coalesce.(col, median(skipmissing(col)))
    input.Temp = impute_median!(input.Temp)
    input.HR = impute_median!(input.HR)
    input.WBC = impute_median!(input.WBC)

    # Normalize
    zscore!(col) = (col .- mean(col)) ./ std(col)
    input.Temp_z = zscore!(input.Temp)
    input.HR_z = zscore!(input.HR)
    input.WBC_z = zscore!(input.WBC)

    # Convert inputs to Float64
    return Dict(
        :Temp => Float64(input.Temp),
        :HR => Float64(input.HR),
        :WBC => Float64(input.WBC)
    )
end

function score_sepsis(input::Dict)
    processed = preprocess_sepsis(input)
    return logistic_score(SEPSIS_CHAIN, [:β0, :βT, :βHR, :βWBC], [processed.Temp, processed.HR, processed.WBC])
end

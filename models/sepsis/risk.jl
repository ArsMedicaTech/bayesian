include("../../lib/inference_utils.jl")
include("preprocess.jl")

using JLSO

const SEPSIS_CHAIN = JLSO.load("models/sepsis/saved_chain.jls")["chain"]

function score_sepsis(input::Dict)
    processed = preprocess_sepsis(input)
    return logistic_score(SEPSIS_CHAIN, [:β0, :βT, :βHR, :βWBC], [processed.Temp, processed.HR, processed.WBC])
end

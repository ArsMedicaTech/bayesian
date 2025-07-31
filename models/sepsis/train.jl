using CSV, DataFrames, Turing, JLSO
include("model.jl")
@info "SepsisModel methods:" methods(SepsisModel)

const TESTING         = get(ENV, "TESTING", "false") == "true"

const MAX_ROWS        = parse(Int, get(ENV, "MAX_ROWS", "1000"))

const N_SAMPLES       = parse(Int, get(ENV, "N_SAMPLES",        "2000"))
const N_ADAPT         = parse(Int, get(ENV, "N_ADAPT",          "1000"))
const DISCARD_INIT    = parse(Int, get(ENV, "DISCARD_INITIAL",  "50"))
const THINNING        = parse(Int, get(ENV, "THINNING",         "2"))
const SHOW_PROGRESS   = get(ENV, "PROGRESS", "true") != "false"   # default true

include("../../lib/preprocess_sepsis_dataset.jl")
include("../../lib/preprocess.jl")

# Preprocess time-series data → one row per patient
preprocess_sepsis_csv("data/sepsis.csv", "data/sepsis_summary.csv")

# Load summarized data
df = CSV.read("data/sepsis_summary.csv", DataFrame)

# Filter for first MAX_ROWS rows for testing
if TESTING && nrow(df) > MAX_ROWS
    @info "Limiting to first $(MAX_ROWS) rows for testing."
    df = df[1:MAX_ROWS, :]
end

dropmissing!(df)

@info "After dropmissing: $(nrow(df)) rows remain"

temp_z, μ_temp, σ_temp = preprocess_vector(df.Temp_max)
hr_z,   μ_hr,   σ_hr   = preprocess_vector(df.HR_mean)
wbc_z,  μ_wbc,  σ_wbc  = preprocess_vector(df.WBC_min)

y_val = convert(Vector{Bool}, df.SepsisLabel .== 1)  # Force it to be Vector{Bool}

model = SepsisModel(temp_z, hr_z, wbc_z, y_val)

@show mean(temp_z), std(temp_z)
@show mean(hr_z), std(hr_z)
@show mean(wbc_z), std(wbc_z)
# If any std == 0.0 or NaN, that will kill your gradients.

try
    @info "Starting sampling..."
    #sampler = NUTS(N_ADAPT, 0.65)
    #chain = sample(model, sampler, N_SAMPLES; discard_initial = DISCARD_INIT, thinning = THINNING, progress = SHOW_PROGRESS)
    
    if TESTING
        @info "Running in TESTING mode, using PG (10) sampler."
        chain = sample(model, PG(10), 10)
    else
        @info "Running in normal mode, using PG (100) sampler."
        chain = sample(model, PG(10), 100)
    end

    if chain == nothing
        @error "Sampling returned nothing, check your model and data."
        return
    end
    
    @info "Sampling complete, chain type = $(typeof(chain))"

    @info "posterior means" mean(chain)

    arr_chain = Array(chain)
    @info "Chain size: $(size(arr_chain))"

    param_names = names(chain)

    scaling_dict = Dict("μ_temp"=>μ_temp, "σ_temp"=>σ_temp, "μ_hr"=>μ_hr, "σ_hr"=>σ_hr, "μ_wbc"=>μ_wbc, "σ_wbc"=>σ_wbc)
    
    JLSO.save("saved/chain.jls", :chain_values => arr_chain, :param_names => param_names, :scaling => scaling_dict)

    @info "Chain saved to 'saved/chain.jls'."

    @info "Sampling completed successfully."
catch e
    @error "Sampling failed: $e"
    Base.show_backtrace(stderr, catch_backtrace())
    rethrow()
end

using CSV, DataFrames, Statistics

"""
    preprocess_sepsis_csv(input_path::String, output_path::String)

Reads a time-series CSV and outputs one row per patient, with summary vitals.
"""
function preprocess_sepsis_csv(input_path::String, output_path::String)
    df = CSV.read(input_path, DataFrame)

    # Ensure proper types
    df.SepsisLabel = coalesce.(df.SepsisLabel, 0)
    df.Patient_ID = string.(df.Patient_ID)

    # Group by patient
    grouped = groupby(df, :Patient_ID)

    # Initialize output container
    rows = DataFrame(
        Patient_ID = String[],
        Temp_max = Union{Missing, Float64}[],
        HR_mean   = Union{Missing, Float64}[],
        WBC_min   = Union{Missing, Float64}[],
        SepsisLabel = Int[]
    )

    for g in grouped
        # Extract patient-wise vectors
        temps = skipmissing(g.Temp)
        hrs   = skipmissing(g.HR)
        wbcs  = skipmissing(g.WBC)

        # Skip if all inputs are missing for this patient
        if isempty(temps) && isempty(hrs) && isempty(wbcs)
            continue
        end

        push!(rows, (
            g.Patient_ID[1],
            isempty(temps) ? missing : maximum(temps),
            isempty(hrs)   ? missing : mean(hrs),
            isempty(wbcs)  ? missing : minimum(wbcs),
            maximum(g.SepsisLabel)  # label is always numeric
        ))
    end

    # Drop patients with missing vital summaries
    dropmissing!(rows, [:Temp_max, :HR_mean, :WBC_min])

    # Save result
    CSV.write(output_path, rows)
end

# Run as a script
if abspath(PROGRAM_FILE) == @__FILE__
    preprocess_sepsis_csv("data/sepsis.csv", "data/sepsis_summary.csv")
end

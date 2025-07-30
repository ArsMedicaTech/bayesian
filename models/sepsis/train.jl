using CSV, DataFrames, Turing, JLSO
include("model.jl")

df = CSV.read("data/sepsis.csv", DataFrame)

model = SepsisModel(df.Temp, df.HR, df.WBC, df.SepsisLabel)
chain = sample(model, NUTS(), 2000; discard_adapt=1000, thinning=2)

JLSO.save("saved/chain.jls", Dict("chain" => chain))

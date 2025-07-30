using CSV, DataFrames, Turing, JLSO
include("model.jl")

df = CSV.read("data/sepsis.csv", DataFrame)
model = SepsisModel(df.temp, df.hr, df.wbc, df.sepsis)
chain = sample(model, NUTS(), 2000; discard_adapt=1000, thinning=2)

JLSO.save("saved/chain.jls", Dict("chain" => chain))

using Turing, Distributions

@model function SepsisModel(temp, hr, wbc, y)
    β0   ~ Normal(0, 5)
    βt   ~ Normal(0, 1)
    βhr  ~ Normal(0, 1)
    βwbc ~ Normal(0, 1)

    for i in eachindex(y)
        η = β0 + βt * temp[i] + βhr * hr[i] + βwbc * wbc[i]
        y[i] ~ BernoulliLogit(η)
    end
end

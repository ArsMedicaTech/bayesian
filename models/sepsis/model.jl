using Turing, Distributions
using StatsFuns: logistic

#const prior_stds = [5.0, 1.0, 1.0, 1.0]  # σ values for β0, βt, βhr, βwbc
#const prior_stds = [1.0, 0.2, 0.2, 0.2]  # σ values for β0, βt, βhr, βwbc
const prior_stds = [10.0, 10.0, 10.0, 10.0]  # σ values for β0, βt, βhr, βwbc

@model function SepsisModel(temp, hr, wbc, y_val)
    y = collect(y_val)
    N = length(y)

    β0   ~ Normal(0, prior_stds[1])
    βt   ~ Normal(0, prior_stds[2])
    βhr  ~ Normal(0, prior_stds[3])
    βwbc ~ Normal(0, prior_stds[4])


    for i in 1:N
        η = β0 + βt * temp[i] + βhr * hr[i] + βwbc * wbc[i]
        #println("Sampling y[$i] ~ BernoulliLogit($η) where y = $(y[i])")
        y[i] ~ BernoulliLogit(η)
        
        #p = logistic(η)
        #y[i] ~ Bernoulli(p)

        #η_capped = clamp(η, -30, 30)   #  σ(±30) is practically 0/1 already
        #y[i] ~ BernoulliLogit(η_capped)
    end
end

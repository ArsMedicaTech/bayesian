#include("lib/http_utils.jl")

include("models/sepsis/risk.jl")
#include("models/stroke/risk.jl")
#include("models/aki/risk.jl")

using HTTP, JSON3

function router(req)
    # readiness probe (`/healthz`)
    if req.target == "/healthz"
        return HTTP.Response(200, "OK")
    end

    if isempty(req.body)
        return HTTP.Response(400, "Empty request body.")
    end
    
    input_string = JSON3.read(String(req.body))
    input = Dict(Symbol(k) => v for (k, v) in input_string)

    if startswith(req.target, "/bayesian/models/")
        model = split(req.target, '/')[end]      # "sepsis"
    else
        return HTTP.Response(404, "Unknown path.")
    end
    
    result = Dict()

    if model == "sepsis"
        result = Dict("sepsis_risk" => score_sepsis(input))
    #elseif model == "stroke"
    #    result = Dict("stroke_risk" => score_stroke(input))
    #elseif model == "aki"
    #    result = Dict("aki_risk" => score_aki(input))
    else
        return HTTP.Response(404, "Unknown model.")
    end

    return HTTP.Response(200, JSON3.write(result))
end

HTTP.serve(router, "0.0.0.0", 8080)

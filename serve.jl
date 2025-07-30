include("lib/http_utils.jl")

include("models/sepsis/risk.jl")
#include("models/stroke/risk.jl")
#include("models/aki/risk.jl")

using HTTP, JSON3

function router(req)
    input = JSON3.read(String(req.body))

    # readiness probe (`/healthz`)
    if req.target == "/healthz"
        return HTTP.Response(200, "OK")
    end

    model = get(req.target, "/models/", "")
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

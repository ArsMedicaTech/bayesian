FROM julia:1.10
WORKDIR /app

COPY Project.toml Manifest.toml ./
RUN julia --project=. -e 'using Pkg; Pkg.instantiate()'

COPY ./lib ./lib
COPY ./models ./models
COPY ./entrypoint.sh ./
RUN chmod +x entrypoint.sh

COPY ./saved ./saved

COPY ./serve.jl ./

EXPOSE 8080
ENTRYPOINT ["./entrypoint.sh"]

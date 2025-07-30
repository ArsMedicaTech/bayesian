FROM julia:1.10
WORKDIR /app

COPY Project.toml Manifest.toml ./
RUN julia --project=. -e 'using Pkg; Pkg.instantiate()'

COPY . .

EXPOSE 8080
ENTRYPOINT ["./entrypoint.sh"]

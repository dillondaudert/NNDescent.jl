using Pkg;
Pkg.activate(joinpath(@__DIR__, "..")); Pkg.instantiate()
Pkg.activate(); Pkg.instantiate()

pushfirst!(LOAD_PATH, joinpath(@__DIR__, ".."))

using Documenter, NearestNeighborDescent

makedocs(
    modules=[NearestNeighborDescent],
    sitename="NearestNeighborDescent.jl",
    pages = [
        "Home" => "index.md",
        "Basic Usage" => "basic.md",
        "KNN Graphs" => [
            "graphs.md",
        ],
    ],
)

deploydocs(
    repo="github.com/dillondaudert/NearestNeighborDescent.jl.git",
    devbranch="v0.3.0-dev",
)

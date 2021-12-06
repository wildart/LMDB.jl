using Documenter, LMDB

makedocs(
    modules = [LMDB],
    clean = false,
    format = Documenter.HTML(),
    sitename = "LMDB.jl",
    authors = "Art Wild, Fabian Gans",
    pages = [
        "Home" => "index.md",
        "Manual" => "manual.md",
        "API" => [
            "Index"=>"api/index.md", 
        ]
    ]
)

deploydocs(
    repo = "github.com/wildart/LMDB.jl.git",
)


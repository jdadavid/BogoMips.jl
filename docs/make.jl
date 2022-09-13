using Documenter, BogoMips

makedocs(
    modules = [BogoMips],
    format = Documenter.HTML(; prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "Jacques David",
    sitename = "BogoMips.jl",
    pages = Any["index.md"]
    # strict = true,
    # clean = true,
    # checkdocs = :exports,
)

deploydocs(
    repo = "github.com/jdadavid/BogoMips.jl.git",
    push_preview = true
)

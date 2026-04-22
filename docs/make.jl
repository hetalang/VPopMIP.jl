using Documenter
using VPopMIP

makedocs(
    sitename = "VPopMIP.jl",
    format = Documenter.HTML(),
    modules = [VPopMIP],
    pages = [
        "Home" => "index.md",
        "Methodology" => "methodology.md",
        "Tutorial" => "tutorial.md",
        "API" => "api.md",
    ],
)

using Documenter
using VPopMIP

makedocs(
    sitename = "VPopMIP.jl",
    format = Documenter.HTML(),
    modules = [VPopMIP],
    pages = [
        "Home" => "index.md",
        "Tutorial" => [ # methods
            "tutorial/braniff2024.md",
        ],
        "API" => "api.md",
    ],
)

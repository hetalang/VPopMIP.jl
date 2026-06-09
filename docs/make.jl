using Documenter
using VPopMIP

makedocs(
    sitename = "VPopMIP.jl",
    format = Documenter.HTML(),
    modules = [VPopMIP],
    root = @__DIR__,
    workdir = joinpath(@__DIR__, ".."),
    pages = [
        "Home" => "index.md",
        "Quick Start" => "quickstart.md",
        "Tutorials" => [ 
            "tutorials/PKPD.md",
            "tutorials/Braniff2024_NSCLC.md",
        ],
        "API" => "api.md",
    ],
)

deploydocs(
    repo   = "github.com/hetalang/VPopMIP.jl.git"
)

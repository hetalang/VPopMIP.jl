using VPopMIP
using Test

@testset "Loading Virtual Population" begin
  include("test_load_vpop.jl")
end

@testset "Subsetting Virtual Population" begin
  include("test_subset_vpop.jl")
end

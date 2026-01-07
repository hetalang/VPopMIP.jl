using DataFrames

df1 = DataFrame(
    id = ["p1", "p2", "p3", "p1", "p2", "p3"],
    scenario = ["scenario1", "scenario1", "scenario1", "scenario2", "scenario2", "scenario2"],
    endpoint1 = [1., 2., 3., 1., 2., 3.],
    endpoint2 = [4.0, 5.0, 6.0, 4.0, 5.0, 6.0],
    endpoint3 = [7.0, 8.0, 9.0, 7.0, 8.0, 9.0],
)

df2 = DataFrame(
    vpname = ["p1", "p2", "p3"],
    scenario = ["scenario1", "scenario1", "scenario1"],
    endpoint1 = [1., 2., 3.],
)

df3 = DataFrame(
    id = ["p1", "p2", "p3"],
    condition = ["con1", "con1", "con1"],
    endpoint1 = [1., 2., 3.],
)

@test_throws ArgumentError load_vpop(df2)
@test_throws ArgumentError load_vpop(df3)
vpop = load_vpop(df1)
@test length(vpop) == 3
@test length(scenarios(vpop)) == 2
@test length(endpoints(vpop)) == 3
vpop
## with rounding

julia> VPopMIP.compute_statistic(vpop, VPopMIP.median, [:PR_t])
6×2 DataFrame
 Row │ scenario  PR_t_function 
     │ String3   Float64
─────┼─────────────────────────
   1 │ T1             1.75
   2 │ T2             2.45
   3 │ T3             4.9
   4 │ T4             0.583333
   5 │ T5             4.9
   6 │ T6             2.1


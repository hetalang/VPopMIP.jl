# A non-small cell lung cancer (NSCLC) model

A non-small cell lung cancer (NSCLC) model is used to demonstrate the VPopMIP approach. The model is described in [An integrated quantitative systems pharmacology virtual population approach for calibration with oncology efficacy endpoints](https://doi.org/10.1002/psp4.13270). A set of 1000 patients was generated using scripts provided in the supplementary materials of that work.
In the original study, individual patient data were used for VPop selection, including three endpoints for 112 patients across two treatment regimens (“drug” and “placebo”). To demonstrate applicability of the proposed method to more realistic settings, we converted individual-level data into summary statistics:

- SLD_baseline: mean and std of baseline tumor size (sum of longest diameters)
- best_dSLD: 25th, 50th, 75th percentiles of the best percentage change in SLD
- PFS: progression free survival data

First, we load the simulated virtual population as a `DataFrame` and use the `load_vpop` function to select the columns in the DataFrame that correspond to clinically reported endpoints and construct `VirtualPopulation`.

```@example Braniff2024
using VPopMIP, CSV, DataFrames, Plots, StatsBase

ppopdf = CSV.read("./models/Braniff2024/ppopdf1000.csv", DataFrame)
ppop = load_vpop(ppopdf; endpoints=["best_dSLD", "time_to_best", "time_to_pfs", "SLD_baseline"])
```

Next, we load the clinical data for the *drug* and *placebo* regimens as summary statistics. For supported clinical data formats and loading options, see the [DigiPopData documentation](https://hetalang.github.io/DigiPopData.jl/dev/).


```@example Braniff2024
metrics_df = CSV.read("./models/Braniff2024/metrics_table.csv", DataFrame; stringtype=String)
data = parse_metric_bindings(metrics_df);
```

Finally, we use the `subset_vpop` function to solve the binary optimization problem, resulting in an optimal subset (the VPop) that matches the clinical data. By default, `SCIP.Optimizer` is used. You can provide a custom optimizer and time/gap settings in `subset_vpop(...; kwargs...)`.

```@example Braniff2024
vpnum = 112
vpop = subset_vpop(ppop, data, vpnum; scip_limits_gap = 0.05)
```

We can also visualize the results and compare patients selected at random with those selected by the MIP algorithm.

```@example Braniff2024
vpopdf = filter(:scenario => x -> x == "drug", DataFrame(vpop))
ppopdf = filter(:scenario => x -> x == "drug", DataFrame(ppop))

rand_vpopdf = ppopdf[sample(1:nrow(ppopdf), vpnum; replace=false), :]
rand_vpop = load_vpop(rand_vpopdf)

sld_drug_df = filter(row -> row.scenario == "drug" && row.endpoint == "SLD_baseline", metrics_df)
best_dsld_drug_df = filter(row -> row.scenario == "drug" && row.endpoint == "best_dSLD", metrics_df)
best_dsld_drug_values = parse.(Float64, strip.(split(best_dsld_drug_df."metric.values"[1], ';')))
pfs_drug_bind = only(filter(d -> d.scenario == "drug" && d.endpoint == "time_to_pfs", data))

function SLD_base_sim_exp(
    df;
    exp_mean = sld_drug_df."metric.mean"[1],
    exp_std = sld_drug_df."metric.sd"[1]
)
    sim_mean = mean(df.SLD_baseline)
    sim_std  = std(df.SLD_baseline)

    default_blue = palette(:default)[1]

    p = plot(
        xticks = ([1, 2], ["Simulation", "Clinical data"]),
        ylabel = "SLD_baseline (mm)",
        legend = :topright,
        xlims = (0.5, 2.5),
        dpi = 400
    )

    x_sim = fill(1, nrow(df)) .+ 0.08 .* randn(nrow(df))

scatter!(
    p,
    x_sim,
    df.SLD_baseline,
    color = RGB(0.3, 0.45, 0.55),  # blue-grey
    alpha = 0.35,
    markersize = 3.5,
    markerstrokewidth = 0,
    label = false
)

    scatter!(
        p,
        [1], [sim_mean],
        yerror = ([sim_std], [sim_std]),
        color = default_blue,
        markersize = 10,
        linewidth = 4,
        label = "Simulation: mean ± std"
    )

    scatter!(
        p,
        [2], [exp_mean],
        yerror = ([exp_std], [exp_std]),
        color = :red,
        markersize = 9,
        markershape = :diamond,
        linewidth = 2,
        label = "Clinical data: mean ± std"
    )

    return p
end

function dSLD_sim_exp(
    df;
    exp_q25 = best_dsld_drug_values[1],
    exp_q50 = best_dsld_drug_values[2],
    exp_q75 = best_dsld_drug_values[3]
)
    sim_q25 = quantile(df.best_dSLD, 0.25)
    sim_q50 = quantile(df.best_dSLD, 0.50)
    sim_q75 = quantile(df.best_dSLD, 0.75)

    default_blue = palette(:default)[1]

    p = plot(
        xticks = ([1, 2], ["Simulation", "Clinical data"]),
        ylabel = "best_dSLD (%)",
        legend = :topright,
        xlims = (0.5, 2.5),
        dpi = 400
    )

    # --- Simulation scatter ---
    x_sim = fill(1, nrow(df)) .+ 0.08 .* randn(nrow(df))

    scatter!(
        p,
        x_sim,
        df.best_dSLD,
        color = RGB(0.3, 0.45, 0.55),  # blue-grey
    alpha = 0.35,
    markersize = 3.5,
    markerstrokewidth = 0,
    label = false
    )

    # --- Simulation median + IQR ---
    scatter!(
        p,
        [1], [sim_q50],
        yerror = ([sim_q50 - sim_q25], [sim_q75 - sim_q50]),
        color = default_blue,
        markersize = 10,
        linewidth = 4,
        label = "Simulation: median + IQR"
    )

    # --- Clinical data ---
    scatter!(
        p,
        [2], [exp_q50],
        yerror = ([exp_q50 - exp_q25], [exp_q75 - exp_q50]),
        color = :red,
        markersize = 9,
        markershape = :diamond,
        linewidth = 2,
        label = "Clinical data: median + IQR"
    )

    return p
end

p11 = SLD_base_sim_exp(rand_vpopdf)
p12 = SLD_base_sim_exp(vpopdf)
p21 = dSLD_sim_exp(rand_vpopdf)
p22 = dSLD_sim_exp(vpopdf)
p31 = plot(rand_vpop, pfs_drug_bind; dpi=400, xguide="Time (days)", yguide="PFS (%)")
p32 = plot(vpop, pfs_drug_bind; dpi=400, xguide="Time (days)", yguide="PFS (%)")

p = plot(
    p11, p12,
    p21, p22,
    p31, p32,
    layout = (3, 2),
    size = (1200, 1200),
    margins=5Plots.mm, 
    plot_title = "Random Selection vs MIP-based Selected VPop (drug regimen)"
)
p
```

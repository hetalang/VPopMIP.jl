using StatsBase

function statistics_summary(vpop::VirtualPopulation, data::AbstractVector)
  stats = DataFrame(scenario=[], endpoint=[], stats=[])
  grpop = groupby(DataFrame(vpop), SCENARIO_COL)
  for d in data
    scn = d.scenario
    ept = d.endpoint
    sim = Vector(grpop[(scn,)][!, ept])
    stats_d = compute_statistics(sim, d.metric)
    push!(stats, (;scenario=scn, endpoint=ept, stats=stats_d))
  end
  return stats
end

function compute_statistics(vpop::VirtualPopulation, data::DigiPopData.MetricBinding)
  scn = data.scenario
  ept = data.endpoint

  grpop = groupby(DataFrame(vpop), SCENARIO_COL)
  sim = Vector(grpop[(scn,)][!, ept])

  return Dict(
      scn => Dict(
          ept => compute_statistics(sim, data.metric)
      )
  )
end

function compute_statistics(sim::AbstractVector, metric::DigiPopData.SurvivalMetric)
  vpnum = length(sim)
  times = metric.values
  yvpop = [survival_num_to_pct(count(x->x<=t, sim),vpnum) for t in times]
  return Dict(:times => times, :survival => yvpop)
end

compute_statistics(sim::AbstractVector, metric::DigiPopData.MeanMetric) = Dict(
  :mean => mean(skipmissing(sim))
)

compute_statistics(sim::AbstractVector, metric::DigiPopData.MeanSDMetric) = Dict(
    :mean => mean(skipmissing(sim)),
    :std => std(skipmissing(sim))
)

compute_statistics(sim::AbstractVector, metric::DigiPopData.QuantileMetric) = Dict(
    :quantiles => quantile(skipmissing(sim), metric.levels)
)

#=
function skip_missing(x, f)
  _x = skipmissing(x)
  if isempty(_x)
    return missing
  else
    return f(_x)
  end
end
=#
survival_num_to_pct(x, vpnum) = 100*(vpnum-x)/vpnum

deepmerge(x::AbstractDict...) = merge(deepmerge, x...)
deepmerge(x::AbstractVector...) = cat(x...; dims=1)
deepmerge(x...) = x[end]

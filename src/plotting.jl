using RecipesBase

function layout_choice(n)
  n == 1 && return (1,1)
  return (ceil(Int, n/2),2)
end


@recipe function plot(vpop::VirtualPopulation, data::AbstractVector)
  nd = length(data)
  (m,n) = layout_choice(nd)
  layout := (m,n)
  size := (400*n,300*m)

  for (i,d) in enumerate(data)
    @series begin
      subplot := i
      (vpop, d)
    end
  end
end

@recipe function plot(vpop::VirtualPopulation, data::DigiPopData.MetricBinding)

  scn = data.scenario
  ept = data.endpoint

  grpop = groupby(DataFrame(vpop), SCENARIO_COL)
  sim = Vector(grpop[(scn,)][!, ept])

  (sim, data.metric)
end

@recipe function plot(sim::AbstractVector, metric::DigiPopData.SurvivalMetric)
  
  vpnum = length(sim)
  stats = compute_statistics(sim, metric)
  times = stats[:times]
  yvpop = stats[:survival]
  ydata = 100 * metric.levels # convert rates to percentage
  
  xguide --> "Time"
  yguide --> "Survival %"
  linetype --> :steppost
  legend --> :topright
  labels --> ["Clinical data" "Simulation"]
  ylims --> (-5,100)
  linewidth --> 3
  xticks --> times 
  yticks --> [0,25,50,75,100]
  (times, [ydata yvpop])
end


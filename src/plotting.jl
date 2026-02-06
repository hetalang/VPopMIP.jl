using RecipesBase

function layout_choice(n)
  n == 1 && return (1,1)
  return (ceil(Int, n/2),2)
end


@recipe function plot(vpop::VirtualPopulation, data::AbstractVector;  survival_dir=:decreasing)
  nd = length(data)
  (m,n) = layout_choice(nd)
  layout := (m,n)
  size := (400*n,300*m)

  plotattributes[:survival_dir] = survival_dir

  for (i,d) in enumerate(data)
    @series begin
      subplot := i
      (vpop, d)
    end
  end
end

@recipe function plot(vpop::VirtualPopulation, data::DigiPopData.MetricBinding; survival_dir=:decreasing)

  scn = data.scenario
  ept = data.endpoint

  grpop = groupby(DataFrame(vpop), SCENARIO_COL)
  sim = Vector(grpop[(scn,)][!, ept])

  plotattributes[:survival_dir] = survival_dir

  (sim, data.metric)
end

@recipe function plot(sim::AbstractVector, metric::DigiPopData.SurvivalMetric)
  
  stats = compute_statistics(sim, metric)
  times = stats[:times]
  dir = get(plotattributes, :survival_dir, :decreasing)

  if dir == :decreasing
    yvpop = stats[:survival]
    ydata = 100 * metric.levels # convert rates to percentage
  elseif dir == :increasing
    yvpop = 100 .- stats[:survival]
    ydata = 100 .- 100 * metric.levels # convert rates to percentage
  else
    error("Invalid survival_dir value. Use :decreasing or :increasing.")
  end
  
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


require("config")
function research(count, one, two, three, four, time)
  local ing = {}
  if one > 0 then ing[#ing + 1] = {"science-pack-1", one} end
  if two > 0 then ing[#ing + 1] = {"science-pack-2", two} end
  if three > 0 then ing[#ing + 1] = {"science-pack-3", three} end
  if four > 0 then ing[#ing + 1] = {"alien-science-pack", four} end
  local unit = {
    count = count or 10,
    ingredients = ing,
    time = time * (one + two + three + four)
  }
  return unit
end

function repl_research(count, one, two, three, four, time)
	if rare_earth_enabled then
		local ing = {}
		if one > 0 then ing[#ing + 1] = {"rare-earth", one} end
		if two > 0 then ing[#ing + 1] = {"rare-earth-magnet", two} end
		if three > 0 then ing[#ing + 1] = {"superconductor", three} end
		if four > 0 then ing[#ing + 1] = {"ion-conduit", four} end
		local unit = {
			count = count or 10,
			ingredients = ing,
			time = time * (one + two + three + four)
		}
		return unit
	else
		three = math.floor(three + four/2)
		return research(count, one, two, three, four, time)
	end
end
require("prototypes.pipe-position")
if rare_earth_enabled then require("prototypes.rare-earth") end
require("prototypes.item-groups")
if rare_earth_enabled then require("prototypes.rare-earth-processing-items") end
if rare_earth_enabled then require("prototypes.replication-lab") end
require("prototypes.replicators")
require("prototypes.replication")
require("fetch_data")
require("prototypes.replication")
local function floor_to_leading_digit(number, leading_digits)
	local leading = leading_digits or 3
	local digits = math.ceil(math.log(number)/math.log(10))
	return math.floor(number * 10^(-digits+leading)) / 10^(-digits+leading)
end

local function add_icon(name, extract_table, add_table, research, tier)
	tier = tier or ""
	local icons = {}
	if extract_table[name].icon then
		table.insert(icons, {icon = extract_table[name].icon})
	else
		icons = extract_table[name].icons
	end
	--print("__replicators__/graphics/icons/repl-tech-overlay" .. tier .. ".png")
	table.insert(icons, {icon = "__replicators__/graphics/icons/repl-tech-overlay" .. tier .. ".png"})
	if research == true then 
		add_table.icon = icons[1].icon
	else
		add_table.icon = nil
		add_table.icons = icons
	end
end

-- returns the tier based on complexity
local function r_tier(complexitity)
	if 0 <= complexitity and complexitity < quantiles[2] then
		return 1
	elseif quantiles[2] <= complexitity and complexitity < quantiles[3] then
		return 2
	elseif quantiles[3] <= complexitity and complexitity < quantiles[4] then
		return 3
	elseif quantiles[4] <= complexitity and complexitity < quantiles[5] then
		return 4
	elseif quantiles[5] <= complexitity and complexitity < quantiles[6] then
		return 5
	end
end


for name, table in pairs(item) do 
	-- add tier based on complexity
	item[name].tier = r_tier(item[name].comp)
	-- add every name in item-table which really exists ingame to recipes
	if data.raw.item[name] then repl_recipe({item = name, tier = item[name].tier})
	elseif data.raw.ammo[name] then repl_recipe({item = name, tier = item[name].tier})
	elseif data.raw.module[name] then repl_recipe({item = name, tier = item[name].tier})
	elseif data.raw.tool[name] then repl_recipe({item = name, tier = item[name].tier}) end
end

for name, table in pairs(fluid) do 
	-- add tier based on complexity
	fluid[name].tier = r_tier(fluid[name].comp)
	
	if data.raw.fluid[name] then repl_recipe({item = name, is_fluid=true, quantity=10, tier = fluid[name].tier}) end
end


for name, tab in pairs(data.raw.recipe) do 
	if tab.category and tab.category:match("replication") == 'replication' then 
		local repl_name = tab.results[1].name -- is the name of an item or fluid
		local repl_amount = tab.results[1].amount
		local icon_path
		if tab.energy_required == 987654321 then --987654321 is an identifier to check if recipe is customized
			if tab.results[1].type == "fluid" then
				--print(repl_type)
				tab.energy_required = floor_to_leading_digit(repl_penalty({time = fluid[repl_name].time, tier = fluid[repl_name].comp}) * repl_amount)
				fluid[repl_name].name = repl_name -- save recipe name with its corresponding product
			else
				--print(repl_name)
				--print(tab.results[1].type)
				--print(item[repl_name])
				tab.energy_required = floor_to_leading_digit(repl_penalty({time = item[repl_name].time, tier = item[repl_name].comp}) * repl_amount)
				local tech = data.raw.technology["repltech-" .. repl_name] -- extracts technology which enable this RECIPE
				
				-- item[repl_name].preq has the technologie which enables this ITEM
				if tech.prerequisites and #tech.prerequisites == 0 and item[repl_name].preq then tech.prerequisites = {item[repl_name].preq} end -- add preq so that the palyer first have to researcj the item and after that he can research the replication recipe
				item[repl_name].name = repl_name
			end
		end
		
		if data.raw.item[repl_name] and data.raw.item[repl_name].localised_name then 
			tab.localised_name = {"recipe-name.repl-recipe", data.raw.item[repl_name].localised_name}
		elseif data.raw.fluid[repl_name] then tab.localised_name = {"recipe-name.repl-recipe", {"fluid-name." .. repl_name}}
		elseif entity_set[repl_name] then tab.localised_name = {"recipe-name.repl-recipe", {"entity-name." .. repl_name}}
		elseif equipment_set[repl_name] then tab.localised_name = {"recipe-name.repl-recipe", {"equipment-name." .. repl_name}}
		else tab.localised_name = {"recipe-name.repl-recipe", {"item-name." .. repl_name}} end
		
		--[[if data.raw.item[repl_name] then tab.icon = data.raw.item[repl_name].icon end
		if data.raw.ammo[repl_name] then tab.icon = data.raw.ammo[repl_name].icon end
		if data.raw.fluid[repl_name] then tab.icon = data.raw.fluid[repl_name].icon end
		if data.raw.module[repl_name] then tab.icon = data.raw.module[repl_name].icon end
		if data.raw.tool[repl_name] then tab.icon = data.raw.tool[repl_name].icon end]]
		if data.raw.item[repl_name] then add_icon(repl_name, data.raw.item, tab, false, item[repl_name].tier)
		elseif data.raw.ammo[repl_name] then add_icon(repl_name, data.raw.ammo, tab, false, item[repl_name].tier) 
		elseif data.raw.fluid[repl_name] then add_icon(repl_name, data.raw.fluid, tab, false, fluid[repl_name].tier) 
		elseif data.raw.module[repl_name] then add_icon(repl_name, data.raw.module, tab, false, item[repl_name].tier) 
		elseif data.raw.tool[repl_name] then add_icon(repl_name, data.raw.tool, tab, false, item[repl_name].tier) end
	end
end
--print(serpent.block(item.recipe))

-- 
for tier=1, 5 do
	local name = "repltech-replication-" .. tier
		-- add all repl-recipes with products that have smaller complexitity than x to a list
		local list = {}
		--print(name)

		for _, rtable in pairs(item) do 
			if rtable.tier == tier then list[#list+1] = rtable.name end
		end
		for _, rtable in pairs(fluid) do
			if rtable.tier == tier then list[#list+1] = rtable.name end -- list will only contain recipe names which already are in data.raw
		end
		-- add list "repltech-replication-tier" as preq to every recipe/research in the list	
		for i= 1, #list do
			local key = "repltech-" .. list[i]
			local tab = data.raw.technology[key]
			tab.prerequisites[#tab.prerequisites + 1] = name -- adds the replicator tech as preq
			
			local unit
			--local reps = tab.unit.count -- reads the previously(data.lua) generated unit count
				-- item[list[i]].comp is the complexitity value of the item withe the name list[i]
			local time
			local reps
			if item[list[i]] then reps = math.ceil(100 * item[list[i]].comp/(150+item[list[i]].comp))+9 else reps = math.ceil(100 * fluid[list[i]].comp/(150+fluid[list[i]].comp))+9 end
			if item[list[i]] then time = math.ceil(16 * item[list[i]].comp/(60+item[list[i]].comp))+19 else time = math.ceil(16 * fluid[list[i]].comp/(60+fluid[list[i]].comp))+19 end
			if     tier == 1 then unit = repl_research(reps, 1, 0, 0, 0, time) 
			elseif tier == 2 then unit = repl_research(reps, 1, 1, 0, 0, time)
			elseif tier == 3 then unit = repl_research(reps, 1, 1, 1, 0, time)
			elseif tier == 4 then unit = repl_research(reps, 1, 1, 1, 1, time)
			elseif tier == 5 then unit = repl_research(reps, 1, 2, 2, 1, time) end
			tab.unit = unit
		
			-- write localised_name for the research
			if data.raw.item[list[i]] and data.raw.item[list[i]].localised_name then 
			tab.localised_name = {"technology-name.repl-tech", data.raw.item[list[i]].localised_name}
			elseif data.raw.fluid[list[i]] then tab.localised_name = {"technology-name.repl-tech", {"fluid-name." .. list[i]}}
			elseif entity_set[list[i]] then tab.localised_name = {"technology-name.repl-tech", {"entity-name." .. list[i]}}
			elseif equipment_set[list[i]] then tab.localised_name = {"technology-name.repl-tech", {"equipment-name." .. list[i]}}
			else tab.localised_name = {"technology-name.repl-tech", {"item-name." .. list[i]}} end
			
			--find icons for the research
			if data.raw.item[list[i]] then add_icon(list[i], data.raw.item, tab, true)
			elseif data.raw.ammo[list[i]] then add_icon(list[i], data.raw.ammo, tab, true)
			elseif data.raw.fluid[list[i]] then add_icon(list[i], data.raw.fluid, tab, true)
			elseif data.raw.module[list[i]] then add_icon(list[i], data.raw.module, tab, true)
			elseif data.raw.tool[list[i]] then add_icon(list[i], data.raw.tool, tab, true) end
			
			--add reserach identifier
			data.raw.technology[key].name = data.raw.technology[key].name .. "-13131"		
			
		end

end

if rare_earth_enabled then
	for _, module in pairs(data.raw.module) do
	  if module.limitation and module.effect.productivity then
		table.insert(module.limitation, "neodymium-plate")
		table.insert(module.limitation, "rare-earth-magnet")
		table.insert(module.limitation, "superconductor")
		table.insert(module.limitation, "ion-conduit")
	  end
	end
end

--it[t]=1








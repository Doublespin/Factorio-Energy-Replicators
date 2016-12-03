require "util"
require("config")
-- to print in factorio log: error("Hi player") error(serpent.block(table_name))
-- Initialise
local recipes = table.deepcopy(data.raw.recipe)
local recipes_copy = table.deepcopy(data.raw.recipe)
item = {}
fluid = {}
-- item and fluids are called replication recipes in my notes

---- Resources that are not ores but can be gathered on the map; Ores are added later based on their generation settings.
-- Vanilla items
item["raw-wood"] = {time = 0.5*2/4, comp = 0}
item["alien-artifact"] = {time = 2000, comp = 100}
-- Bobs items
item["alien-artifact-red"] = {time = 2000, comp = 100}
item["alien-artifact-orange"] = {time = 2000, comp = 100}
item["alien-artifact-yellow"] = {time = 2000, comp = 100}
item["alien-artifact-green"] = {time = 2000, comp = 100}
item["alien-artifact-blue"] = {time = 2000, comp = 100}
item["alien-artifact-purple"] = {time = 2000, comp = 100}

-- Vanilla fluids
fluid["water"] = {time = 0.01, comp = 0}
-- Bobs fluids
fluid["liquid-air"] = {time = 0.1, comp = 5}
fluid["gas-compressed-air"] = {time = 0.1, comp = 5}

-- Table length since "#" operator does not work well nil values inside an array or with sets
local function table_length(table)
	local count = 0
	for _, __ in pairs(table) do
		count = count +1
	end
	return count
end

-- extracts the time value from either the item array or the fluid array
local function get_time(name, rtype)
	if rtype == "item" then
		return item[name].time
	else
		return fluid[name].time
	end
end
-- extracts the complexitity value from either the item array or the fluid array
local function get_comp(name, rtype)
	if rtype == "item" then
		return item[name].comp
	else
		return fluid[name].comp
	end
end

-- Adds a recipe to the item/fluid array
local function add_known_recipe(name, rtable, rtype) -- input: string, table: {time = 1, comp = 1}, string
	if rtype == "item" then
		if item[name]==nil then 
			item[name] = rtable
		-- if it is already in the table then choose the one with smaller complexity, if complexity ist equal then choose the one with smaller time
		elseif item[name].comp > rtable.comp then item[name] = rtable
		elseif item[name].comp == rtable.comp and item[name].time > rtable.time then item[name] = rtable
		end
	elseif rtype == "fluid" then
		if fluid[name]==nil then
			fluid[name] = rtable
		elseif fluid[name].comp > rtable.comp then fluid[name] = rtable
		elseif fluid[name].comp == rtable.comp and fluid[name].time > rtable.time then fluid[name] = rtable
		end
	end
end


local function delete_recipe(name)
	recipes[name] = nil
end

-- function for formation of any ingredients syntax to {{name,amount,type},...}
local function ingred_structure(ing)
	local returnval = {}
	for i, ingredient in pairs(ing) do
		if ingredient[1] and ingredient[2] then -- structure is {"steel-plate", 10}
			returnval[i] = {}
			returnval[i]["name"]= ingredient[1]
			returnval[i]["amount"]= ingredient[2]
			returnval[i]["type"]= "item"
		elseif ingredient.name and ingredient.amount then --structure is {name = "steel-plate", amount = 10, type = "item"}
			returnval[i] = {}
			returnval[i]["name"]= ingredient.name
			returnval[i]["amount"]= ingredient.amount
			returnval[i]["type"]= ingredient.type or "item"
		else
			print(serpent.block(ingredient,{comment=false}))
			error("Repl: Error in ingred_structure, unkown ingredients structure")
		end
	end
	return returnval
end

-- function for formation of any results syntax to {{name,amount,type},...}
local function result_structure(result)
	local returnval = {}
	for i, results in pairs(result) do
		if results[1] and results[2] then -- structure is {"steel-plate", 10}
			returnval[i] = {}
			returnval[i]["name"]= results[1]
			returnval[i]["amount"]= results[2]
			returnval[i]["type"]= "item"
		elseif results.name and results.amount and results.probability then --structure is {name = "steel-plate", amount = 10, type = "item"}
			returnval[i] = {}
			returnval[i]["name"]= results.name
			returnval[i]["amount"]= results.amount * results.probability
			returnval[i]["type"]= results.type or "item"
		elseif results.name and results.amount and not results.probability then
			returnval[i] = {}
			returnval[i]["name"]= results.name
			returnval[i]["amount"]= results.amount
			returnval[i]["type"]= results.type or "item"
		elseif results.name and results.amount_min and results.amount_max and results.probability == nil then
			returnval[i] = {}
			returnval[i]["name"]= results.name
			returnval[i]["amount"]= (results.amount_min + results.amount_max) / 2
			returnval[i]["type"]= results.type or "item"
		elseif results.name and results.amount_min and results.amount_max and results.probability then
			returnval[i] = {}
			returnval[i]["name"]= results.name
			returnval[i]["amount"]= (results.amount_min + results.amount_max) / 2 * results.probability
			returnval[i]["type"]= results.type or "item"
		else
			print(serpent.block(results,{comment=false}))
			error("Repl: Error in result_structure, unkown results structure")
		end
	end
	return returnval
end

-- Based on a normal recipe, this function will use the ingredients and calculate a new replicator recipe
local function make_known_recipe(recipe_table) -- input: {type="recipe", name, ingredients, required_energy, ...} ( The normal table of a recipe like th ones in data.raw)
	if table_length(recipe_table.ingredients) ~= 0 then -- recipes with no ingredients(e.g. liquid air from bobsmod) cant be processed,
		
		-- initialize variables
		local new_krecipe = {}
		local rtime = recipe_table.energy_required or 0.5
		local comp = 0
		local result = {{}}
		
		--check if recipe uses result ore results and restructre them
		if recipe_table.results then
			result=result_structure(recipe_table.results) -- returns structure {{name, amount, type}}
		else
			result[1].name = recipe_table.result
			result[1].amount = recipe_table.result_count or 1
			result[1].type = "item"
		end
		
		-- restructure ingredients
		recipe_table.ingredients = ingred_structure(recipe_table.ingredients)
		
		-- calculate complexitity and time
		for i , material in pairs(recipe_table.ingredients) do

			rtime = rtime + get_time(material.name, material.type) * material.amount
			comp = i + comp + get_comp(material.name, material.type)

		end
		
		
		new_krecipe.time = rtime / result[1].amount -- there should only be one single result item, because multi result recipes need to get splitted. This wil be done later in the code.
		new_krecipe.comp = comp
		add_known_recipe(result[1].name, new_krecipe,  result[1].type)
	end
end

-- Checks if a vanilla recipe only has ingredients that are already known(ingreadients that are in the replcation recipes)
local function contains_known_recipe(recipe_table) -- input: {type="recipe", name, ingredients, required_energy, ...}, output: true/false
	recipe_table.ingredients = ingred_structure(recipe_table.ingredients)
	for i, ingredient_table in pairs(recipe_table.ingredients) do -- example ingredient_table={name="steel", amount=10, type="item"}
		if ingredient_table.type == "item" then 
			if item[ingredient_table.name] == nil then 
				return false
			end
		end
		if ingredient_table.type == "fluid" then 
			if fluid[ingredient_table.name] == nil then 
				return false
			end
		end
	end
	return true
end


-- extract resources from data.raw, will take multiple resources into account
local resources = {}

for name, res in pairs(data.raw.resource) do
	--print(name .. "--" .. serpent.block(res))
	--print(name)
	if res.autoplace and name ~= "rare-earth" then
		local new_hardness = res.minable.hardness
		local new_mining_time = res.minable.mining_time
		local new_infinite = res.infinite or false
		local new_maximum = res.maximum
		local new_normal = res.normal
		local new_minimum = res.minimum
		
		local new_a_coverage = res.autoplace.coverage or 0.02
		local new_a_random_probability_penalty = res.autoplace.random_probability_penalty or 0
		local new_a_richness_multiplier 
		
		
		if res.autoplace.richness_multiplier == 0 and (res.category == "basic-fluid" or res.category == "water") then new_a_richness_multiplier = 30000 * 100 --factor 100 because fludis seem to have too long replication times
		elseif res.autoplace.richness_multiplier == 0 then new_a_richness_multiplier = 1500
		else new_a_richness_multiplier = res.autoplace.richness_multiplier end
		
		
		local new_a_richness_base
		--print(name .. "-.-.-" .. res.autoplace.richness_base)
		if res.autoplace.richness_base == 0 and (res.category == "basic-fluid" or res.category == "water") then new_a_richness_base = 6000 * 100
		elseif res.autoplace.richness_base == 0 then new_a_richness_base = 500 
		else new_a_richness_base = res.autoplace.richness_base end
		--print(name .. "-" .. new_a_richness_base)
		
		
		local new_a_max_probability = res.autoplace.max_probability or 1
		
		
		local result = {{}}
		if res.minable.results then
			result=result_structure(res.minable.results) -- returns structure {{name, amount, type},...}
			for _, resource in pairs(result) do
				if not resources[resource.name] then
					resources[resource.name] = 
						{
						amount = resource.amount * #result, -- one mining operation gives every item of the result array. 
															--This aproximation( "* #result" ) is not representive for cases like this: {{name="res 1", amount=20},{name="res 2", amount=1},{name="res 3", amount=1}
						hardness = new_hardness,
						mining_time = new_mining_time,
						infinite = new_infinite,
						maximum = new_maximum,
						normal = new_normal,
						minimum = new_minimum,
						a_coverage = new_a_coverage,
						a_random_probability_penalty = new_a_random_probability_penalty,
						a_richness_multiplier = new_a_richness_multiplier,
						a_richness_base = new_a_richness_base,
						a_max_probability = new_a_max_probability,
						type = resource.type
						}
				else
					if resources[resource.name].maximum then new_maximum = (new_maximum + resources[resource.name].maximum) / 2 else new_maximum = new_maximum end
					if resources[resource.name].normal then new_normal = (new_normal + resources[resource.name].normal) / 2 else new_normal = new_normal end
					if resources[resource.name].minimum then new_minimum = (new_minimum + resources[resource.name].minimum) / 2 else new_minimum = new_minimum end
					resources[resource.name] = 
						{
						amount = (resource.amount + resources[resource.name].amount) / 2,
						hardness = (new_hardness + resources[resource.name].hardness) / 2,
						mining_time = (new_mining_time + resources[resource.name].mining_time) / 2,
						infinite = new_infinite,
						maximum = new_maximum,
						normal = new_normal,
						minimum = new_minimum,
						a_coverage = (new_a_coverage + resources[resource.name].a_coverage) / 2,
						a_random_probability_penalty = (new_a_random_probability_penalty + resources[resource.name].a_random_probability_penalty) / 2,
						a_richness_multiplier = (new_a_richness_multiplier + resources[resource.name].a_richness_multiplier) / 2,
						a_richness_base = (new_a_richness_base + resources[resource.name].a_richness_base) / 2,
						a_max_probability = (new_a_max_probability + resources[resource.name].a_max_probability) / 2,
						type = resource.type,
						}
				end
			end
		else
			result[1].name = res.minable.result
			result[1].amount = res.minable.result_count or 1
			result[1].type = "item"
			if not resources[result[1].name] then
				resources[result[1].name] = 
					{
					amount = result[1].amount,
					hardness = new_hardness,
					mining_time = new_mining_time,
					infinite = new_infinite,
					maximum = new_maximum,
					normal = new_normal,
					minimum = new_minimum,
					a_coverage = new_a_coverage,
					a_random_probability_penalty = new_a_random_probability_penalty,
					a_richness_multiplier = new_a_richness_multiplier,
					a_richness_base = new_a_richness_base,
					a_max_probability = new_a_max_probability,
					type = result[1].type
					}
			else
				--print(serpent.block(resources[result[1].name]))
				if resources[result[1].name].maximum then new_maximum = (new_maximum + resources[result[1].name].maximum) / 2 else new_maximum = new_maximum end
				if resources[result[1].name].normal then new_normal = (new_normal + resources[result[1].name].normal) / 2 else new_normal = new_normal end
				if resources[result[1].name].minimum then new_minimum = (new_minimum + resources[result[1].name].minimum) / 2 else new_minimum = new_minimum end
				resources[result[1].name] = 
					{
					amount = (result[1].amount + resources[result[1].name].amount) / 2,
					hardness = (new_hardness + resources[result[1].name].hardness) / 2,
					mining_time = (new_mining_time + resources[result[1].name].mining_time) / 2,
					infinite = new_infinite,
					maximum = new_maximum,
					normal = new_normal,
					minimum = new_minimum,
					a_coverage = (new_a_coverage + resources[result[1].name].a_coverage) / 2,
					a_random_probability_penalty = (new_a_random_probability_penalty + resources[result[1].name].a_random_probability_penalty) / 2,
					a_richness_multiplier = (new_a_richness_multiplier + resources[result[1].name].a_richness_multiplier) / 2,
					a_richness_base = (new_a_richness_base + resources[result[1].name].a_richness_base) / 2,
					a_max_probability = (new_a_max_probability + resources[result[1].name].a_max_probability) / 2,
					type = result[1].type,
					}
			end
		end
	end
end

-- Calculates the time of an resources based on their autoplace control settings
for name, res in pairs(resources) do
	--print(serpent.block(name) .. res.type)
	--print(serpent.block(res))
	if not res.a_random_probability_penalty then prob_factor = res.a_max_probability
	elseif res.a_max_probability > res.a_random_probability_penalty then prob_factor = res.a_max_probability - 0.5 * res.a_random_probability_penalty
	else prob_factor = 0.5 * res.a_max_probability^2 / res.a_random_probability_penalty end -- Yes, this is the correct probabilty calculation
	local inf_factor
	if res.infinite and res.normal then inf_factor = math.log(res.normal + 800) / math.log(800) else inf_factor = 1 end
	--print(inf_factor)
	local time = res.hardness * res.mining_time / res.a_coverage / (res.a_richness_multiplier + res.a_richness_base)^(1/2) / prob_factor / res.amount / inf_factor
	resources[name].time = time
end
--print(serpent.block(resources))

-- Adds the resources to the replication recipes
for name, tab in pairs(resources) do
	if tab.type == "item" and (not item[name]) then
		item[name] = {time = tab.time, comp = 0}
	elseif tab.type == "fluid" and (not fluid[name]) then
		fluid[name] = {time = tab.time, comp = 0}
	else
		log("Replicators: Missing resource type")
	end
end
--bre[1]=1


-- split recipes with multiple outputs into seperate recipes
for name, recipe  in pairs(recipes) do
	if recipe.results and #recipe.results > 1 then -- checked for multiple results
		local recipe_name = recipe.name --name from recpet with multiple results
		local results = result_structure(recipe.results) --the multiple results with uniform data structure: no probabilitys, only {name, amount, type}
		local ingred = ingred_structure(recipe.ingredients) --ingredients which produce multiple results
		local full_result_amount = 0
		local new_amount = {}
		for i, rtable in pairs(results) do -- example: rtable = {name=, type=, amount=}
			full_result_amount = full_result_amount + rtable.amount
		end
		for i, rtable in pairs(results) do -- example results has 3 entries: heavy oil, light oil, petrol-> i = 1,2,3
			recipes[recipe_name .. "--" .. i] = table.deepcopy(recipe) -- copy for each result of recipe_name and write it in initial recipes table
			recipes[recipe_name .. "--" .. i].name = recipe_name .. "--" .. i
			recipes[recipe_name .. "--" .. i].results = {rtable}
			recipes[recipe_name .. "--" .. i].ingredients = table.deepcopy(ingred) -- use uniform data structure
			for k, ingredi in pairs(ingred) do -- example ingred { {name="water"....}, {name="oil"....}}-> ingredi = {name="water"....}

				new_amount[k] = ingredi.amount * rtable.amount / full_result_amount -- example: basic oil processing: 3 heavy oil, 3 light oil, 4 petrol: rtable for heavy oil--> rtable.amount=4 , full_result_amount=3+3+4=10, ingredi.amount=10 oil-->new_amount=3
				recipes[recipe_name .. "--" .. i].ingredients[k].amount = new_amount[k]
			end
		end
		delete_recipe(name) --after adding recipes for alle the diffrent results of recipe, the original can be deleted
	end
end

-- deletes blacklisted recipes in recursive blacklist (in config.lua)
for i, name in pairs(recursive_blacklist) do
	delete_recipe(name)
end

-- Recursive iteration through the recipe table to gather the new recipes for the recplication recipes
local j = table_length(recipes)
local l = j + 1
while j < l do -- l will stop loop if j stops decreasing
	for name, recipe_table in pairs(recipes) do
		if contains_known_recipe(recipe_table) then 
			make_known_recipe(recipe_table)
			delete_recipe(name)
		end
	end
	j = table_length(recipes)
	if j == 0 then break end
	l=l-1
end
--print("Not recognized recipes: " .. j)
--print(serpent.block(recipes))


-- deletes blacklisted items in endpoint blacklist (in config.lua)
for i, table in pairs(endpoint_blacklist) do
	local name = table[1]
	if table[2] == "item" then
		item[name] = nil
	elseif table[2] == "fluid" then
		fluid[name] = nil
	else
		log("wrong type in endpoint blacklist; config.lua")
	end
end



-- restructure result node in recipes table; delete multiple results; This is important for the preq: Since replicator only produce single results the technology unlocking would get problems with multi result recipes.
for name, recipe  in pairs(recipes_copy) do
	if recipe.results and #recipe.results > 1 then -- checked for multiple results
		recipes_copy[name] = nil
	elseif recipe.result then 
		recipe.results = {{name = recipe.result, type="item"}} 
		recipe.result = nil -- restructure result node in recipes table
	end
end

-- returns true if technology unlocks the recipe
local function technology_unlock_recipe(technology, recipe_name) 
	if not technology.effects then return false end
	local n = #technology.effects
	for i=1,n do
		--print(serpent.block(technology.effects[i]))
		if technology.effects[i] and technology.effects[i].type == "unlock-recipe" and technology.effects[i].recipe == recipe_name then
			return true
		end
	end
	return false
end

-- find preq for the entries in item: Search for recipes with single result->search for technologie which enables this recipe -> add this tech to preq
for name, rtable in pairs(item) do
	local recipe_name
		for name2, rtable2 in pairs(recipes_copy) do 
			if name == rtable2.results[1].name then 
				recipe_name = name2
				for tech_name, tech in pairs(data.raw.technology) do
					if not tech_name:match("repltech") and technology_unlock_recipe(tech, recipe_name) then
						item[name].preq = tech_name
						--print(serpent.block(item[name]))
					end
				end
			end
		end
end
--[[
for name, rtable in pairs(fluid) do
	local recipe_name
		for name2, rtable2 in pairs(recipes_copy) do 
			if name == rtable2.results[1].name then 
				recipe_name = name2 -- Recept_name for an fluid is know known
				for tech_name, tech in pairs(data.raw.technology) do
					if not tech_name:match("repltech") and technology_unlock_recipe(tech, recipe_name) then
						fluid[name].preq = tech_name
						print(name .. "-----" .. serpent.block(fluid[name]))
					end
				end
			end
		end
end

local debug1 = 0
local debug2 = 0
for _, tab in pairs(item) do
	if tab.preq then debug1=debug1+1 else debug2=debug2+1 end
end
print("debug1: " .. debug1)
print("debug2: " .. debug2)
]]

--print(serpent.block(recipes,{comment=false}))
--print(serpent.block(item,{comment=false}))
--print(serpent.block(fluid,{comment=false}))
--print(table_length(recipes))




---------------------------------------------------------------------------------------------------
----------------Processing of the replcation recipes-----------------------------------------------
---------------------------------------------------------------------------------------------------

item_numbervec = {}
-- puts all non 0 complexity number into an array
for name, rtable in pairs(item) do
	if rtable.comp ~= 0 then
		item_numbervec[#item_numbervec+1] = rtable.comp
	end
end

-- Sums up an number array
local function sum(t)
    local sum = 0
    for k,v in pairs(t) do
        sum = sum + v
    end
    return sum
end

-- rounding function
function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- quantils function: outputs the smallest number that cuts the array in at the length p in percent: quantil(t, 0.5) is the median of t
local function quantil(t, p)
	table.sort(t)
	local n = table_length(t)
	if (n * p) % 1 == 0 then
		return (t[n*p]+t[n*p+1])/2
	else
		return t[round(n*p)]
	end
end

-- Array withe 6 diffrent quantiles; needed for the tiers of the replcatior buildings and research
quantiles = {}
quantiles[1] = 0
quantiles[2] = quantil(item_numbervec, 1/5)
quantiles[3] = quantil(item_numbervec, 2/5)
quantiles[4] = quantil(item_numbervec, 3/5)
quantiles[5] = quantil(item_numbervec, 4/5)
quantiles[6] = item_numbervec[table_length(item_numbervec)]+1


entity_set = {}
equipment_set = {}
-- This function finds all entries in data.raw that have an selection box; basically all (relevant) entities
for category, rtable in pairs(data.raw) do
	for name, rtable2 in pairs(rtable) do 
		if rtable2.selection_box then entity_set[name] = true end
	end
end

-- This function finds all entries in data.raw that have the property placed_as_equipment_result; basically every (relevant) equipment
for category, rtable in pairs(data.raw) do
	for name, rtable2 in pairs(rtable) do 
		if rtable2.placed_as_equipment_result then equipment_set[name] = true end
	end
end

-- the penalty on the time to replcate an item is based median of the complexities of the replicator recipes
pen_factor = quantil(item_numbervec, 0.5)
-- The penalty function 
function repl_penalty(arg)
  local time
  local tier
  if (type(arg) == "table") then
    time = arg["time"]
    tier = arg["tier"] or 0
  else
    time=arg
    tier=0
  end
  return time * (1.1 + math.sqrt(tier) / pen_factor) * replcation_time_factor
end

--it[t]=1
--print(serpent.block(quantiles))
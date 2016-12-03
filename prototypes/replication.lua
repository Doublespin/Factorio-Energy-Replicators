require("config")

--function which represents a "penalty" because you dont need the infrastructure of a vanilla factory. The more "advanced" the higher the penalty



----function to generate only the reseach for 1 ore more replication products.
local function repl_tech(opts)
  ------ definition of variables:
  local tech_name = opts['tech_name']               -- name of the research;if tech_effect==nil then this have to be the name of the item which is going to get enabled
  local tech_icon = opts['icon'] or "__replicators__/graphics/icons/repl-" .. tech_name .. ".png"       -- name of the icon which will be the icon for research
  local reps = opts['reps'] or 20                   -- number of cycles the research needs, will only work if opts["unit"]==nil
  local tier = opts['tier']                         -- tier of the research, keep this consisten with the recipe tier
  local prerequisites = opts['prerequisites']       -- prerequisites of the research. previous tiers are added automatically
  local unit = opts['unit']                         -- specifications for the research (contains research cycle count, cycle length, costs(science packs,...)
  local tech_effect = opts["tech_effect"]           -- all recipe names which should be enabled with this research. input: {"tech1", "tech2",...}
  local effect = {}
  if tech_effect==nil then
    effect={{ type = "unlock-recipe", recipe = "repl-" .. tech_name}}
  else 
    for i, tech in pairs(tech_effect) do
      effect[i] = { type = "unlock-recipe", recipe = tech}
     end
  end


  if unit == nil then
    if tier == 1 then
      unit = repl_research(reps, 1, 1, 0, 0, 5) -- code of "repl_research" is in data.lua
    elseif tier == 2 then
      unit = repl_research(reps, 2, 2, 0, 0, 5)
    elseif tier == 3 then
      unit = repl_research(reps, 0, 2, 2, 0, 6)
    elseif tier == 4 then
      unit = repl_research(reps, 0, 0, 2, 2, 7)
    elseif tier == 5 then
      unit = repl_research(reps, 0, 0, 0, 10, 4)
    end
  end 
  -- Require the previous tier in addition to the prequisites in the arguments
  -- prerequisites[#prerequisites + 1] = 'repltech-replication-' .. tier

  ---------------------- the actual function------------------------------------
    -- adding the research to unlock the recipe
    data:extend({
      {
        name = "repltech-".. tech_name,  type = "technology", order = "zz-" .. tier .. "-" .. tech_name,
        prerequisites = prerequisites,
        icon = tech_icon,
        effects = effect,
        unit = unit,
      }
    })
end


-- function to generate the reseach and the recipe for replication products.
function repl_recipe(opts)
  ------ definition of variables:
  local item = opts['item']                         				-- name of the item which should be replicated
  local reps = opts['reps'] or 20                  					-- number of cycles the research needs
  local tier =  opts['tier'] or 1                       							-- placeholder, will be replaced in data-final-fixes.lua
  local icon = "__replicators__/graphics/icons/repl-default.png" 	-- opts["icon"] or "__replicators__/graphics/icons/repl-" .. item .. ".png" 
																	-- just a placeholder, icon will be picked later (data-final-fixes.lua)
  local prerequisites = opts['prerequisites'] or {}    				-- prerequisites of the research. previous tiers are added automatically
  local quantity = opts['quantity'] or 1            				-- count of items which will be produced at once
  local time = opts["time"] or 987654321             				-- time a replicator needs to produce a product, 
																	-- 987654321 acts as key to recognize custom inputs, will be replaced in data-final-fixes.lua
  local is_fluid = opts["is_fluid"] or false        				-- needed information about the type of the product
  local ingr_type = opts['ingr_type']    							-- type of the ingridient which is needed to produce the product
  local ingr_name = opts["ingr_name"]    							-- name of the ingridient which is needed to produce the product
  local ingr_amount = opts['ingr_amount']							-- amount of the ingridient which is needed to produce the product
  local unit = opts['unit']			                  				-- specifications for the research (contains research cycle count, cycle length, costs(science packs,...)
  local make_research = opts["make_research"] or true				-- genrate research -> every item has its own research; 
																	-- to generate multiple recipes with one research turn it of and use repl_tech()
  local recipe_enabled = opts["recipe_enabled"] or "false" 			-- if true the recipe will be available without any research, inpute has to be a string
  
  
  ------ creates the table for the ingredients
  local ingredients
  if ingr_type ~= nil and ingr_name ~= nil and ingr_amount ~= nil then
    ingredients = {{type=ingr_type, name=ingr_name, amount=ingr_amount}}
  else 
    ingredients = {}
  end

  ------------------------------------------------------------------------------
  ---------------------- the actual function------------------------------------
  ------------------------------------------------------------------------------
  local repl_type
  if is_fluid then repl_type = "fluid" else	repl_type = "item" end
  
  data:extend({
     -- adding the recipe
    {
      type = "recipe",
      category = "replication-"..tier,
      name = "repl-" .. item,
      enabled = recipe_enabled,
      energy_required = time,
      icon = icon,
      ingredients = ingredients,
      results = {{type = repl_type, name = item, amount=quantity}},
      subgroup='replication-recipes',
      order = 'z-' .. tier .. '-' .. item,
    }
  })
 

  -------------- generate research--------------
  if make_research then
    repl_tech({
      tier = tier,
      tech_name = item,
      icon = icon,
      prerequisites = prerequisites,
      reps = reps,
      unit = unit,
    })
  end
end
---------- template for adding a replicator recipe/research
--[[repl_recipe({
  tier =                    -- tier of the recipe/research
  item =                    -- name of item/fluid to produce
  icon =                    -- icon path for the recipe icon
  time =                    -- determines how much time is needed to produce the item; input structure: {time=a_number, tier=another_number}, see penalty function for the calculation
  quantity=                 -- nuber of items which will be produced, if you leave out it will be 1
  is_fluid=                 -- is the item(to produce) a fluid, input: boolean
  ingr_type=                -- type of the ingridient a item needs; input: "fluid" or "item"; if left out it will be "fluid"
  ingr_name=                -- name of the ingridient; if left out it will be "creatine"
  ingr_amount=              -- amount of the ingridient an item needs; if left out it will be this formular: math.floor((2.424 + repl_penalty(time) * 0.1647)*10)/10 * quantity
  prerequisites = {}        -- technologies which needed to be researched before the reasearch for this item will be available
  reps=                     -- cycle the research needs. if left out it will be 100
  unit=                     -- item names their amount and cycles for research;input: {{count= , ingredients ={"item_name", amount=}, time=}}; if this is NOT left ou then reps will have no influnce on research
  make_research = true -- genrate research -> every item has its own research; to generate multiple recipes with one research turn it of and use repl_tech()
  recipe_enabled = "false" -- if true the recipe will be available without any research, inpute has to be a string
  })]]                      -- you have to add a png in the icons folder with this name: repl-<name-of-your-item>.png (ofc without <>)

------------ template for adding a research-----------(not necessary if make_research in repl_recipe is true)
--[[repl_tech({
  tech_name = dytech-ores,                          -- name of the research;if tech_effect==nil then this have to be the name of the item which is going to get enabled
  tech_icon = nil,                                  -- name of the icon which will be the icon for research; path for graphik "__replicators__/graphics/icons/repl-" .. tech_icon .. ".png"
  reps = nil,                                       -- number of cycles the research needs, will only work if opts["unit"]==nil
  tier = 1,                                         -- tier of the research, keep this consisten with the recipe tier
  prerequisites = {},                               -- prerequisites of the research. previous tiers are added automatically
  unit = nil,                                       -- specifications for the research (contains research cycle count, cycle length, costs(science packs,...)
  tech_effect = {dytech-ore-1, dytech-ore-2,...}    -- all recipe names which should be enabled with this research. input: {"tech1", "tech2",...}
  })]] -- nil values dont have be specified. so you can leave the line out



--[[-------- genrate recipe with no reseach-------
repl_recipe({
  tier = 1,                   -- tier of the recipe/research
  item = "copper-plate",                   -- name of item/fluid to produce
  time = plate_speed,                   -- determines how much time is needed to produce the item; input structure: {time=a_number, tier=another_number}, see penalty function for the calculation
  quantity= 1,                -- nuber of items which will be produced, if you leave out it will be 1
  is_fluid= false,                -- is the item(to produce) a fluid, input: boolean
  ingr_type= nil,               -- type of the ingridient a item needs; input: "fluid" or "item"; if left out it will be "fluid"
  ingr_name= nil,               -- name of the ingridient; if left out it will be "creatine"
  ingr_amount= nil,             -- amount of the ingridient an item needs; if left out it will be this formular: math.floor((2.424 + repl_penalty(time) * 0.1647)*10)/10 * quantity
  prerequisites = {},        -- technologies which needed to be researched before the reasearch for this item will be available
  reps= nil,                    -- cycle the research needs. if left out it will be 100
  unit= nil,                   -- item names their amount and cycles for research;input: {{count= , ingredients ={"item_name", amount=}, time=}}; if this is NOT left ou then reps will have no influnce on research
  make_research = false, -- genrate research -> every item has its own research; to generate multiple recipes with one research turn it of and use repl_tech()
  recipe_enabled = "false" -- if true the recipe will be available without any research, inpute has to be a string
  })
repl_recipe({
  tier = 1,                   -- tier of the recipe/research
  item = "iron-plate",                   -- name of item/fluid to produce
  time = plate_speed,                   -- determines how much time is needed to produce the item; input structure: {time=a_number, tier=another_number}, see penalty function for the calculation
  quantity= 1,                -- nuber of items which will be produced, if you leave out it will be 1
  is_fluid= false,                -- is the item(to produce) a fluid, input: boolean
  ingr_type= nil,               -- type of the ingridient a item needs; input: "fluid" or "item"; if left out it will be "fluid"
  ingr_name= nil,               -- name of the ingridient; if left out it will be "creatine"
  ingr_amount= nil,             -- amount of the ingridient an item needs; if left out it will be this formular: math.floor((2.424 + repl_penalty(time) * 0.1647)*10)/10 * quantity
  prerequisites = {},        -- technologies which needed to be researched before the reasearch for this item will be available
  reps= nil,                    -- cycle the research needs. if left out it will be 100
  unit= nil,                    -- item names their amount and cycles for research;input: {{count= , ingredients ={"item_name", amount=}, time=}}; if this is NOT left ou then reps will have no influnce on research
  make_research = false, -- genrate research -> every item has its own research; to generate multiple recipes with one research turn it of and use repl_tech()
  recipe_enabled = "false" -- if true the recipe will be available without any research, inpute has to be a string
  })
---add the research
repl_tech({
  ------ definition of variables:
  tech_name = "metal-plates",               -- name of the research;if tech_effect==nil then this have to be the name of the item which is going to get enabled
  tech_icon = "copper-plate",  -- name of the icon which will be the icon for research, have to be defines if tech_name is not the name of a recipe
  reps = nil,                  -- number of cycles the research needs, will only work if opts["unit"]==nil
  tier = 1,                         -- tier of the research, keep this consisten with the recipe tier
  prerequisites = {"repltech-copper-ore", "repltech-iron-ore"},       -- prerequisites of the research. previous tiers are added automatically
  unit = nil,                         -- specifications for the research (contains research cycle count, cycle length, costs(science packs,...)
  tech_effect = {"repl-iron-plate", "repl-copper-plate"}          -- all recipe names which should be enabled with this research. input: {"tech1", "tech2",...}
})]]

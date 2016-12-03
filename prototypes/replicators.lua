require("config")
local function make_replicator(tier, ingredients)
  ------- variabels -------
-- crafting speed
local base_speed = 1 * replcator_base_speed
local speed_factor = replcator_speed_factor

-- energy usage
local base_power = 110 * replcator_base_power
local power_factor = replcator_power_factor

-- pollution
local base_pollution = 1 / base_power * replcator_base_pollution
        -- keeps the base polution at .. (indipendant from the energy usage)
local pollution_factor = 2.3 / power_factor  * replcator_pollution_factor
        -- keeps the pollution factor at .. (indipendant from the energy usage)

-- categories
local t
local categories = {}
for t=1, tier do
  categories[#categories+1] = 'replication-' .. t, 'crafting', 'advanced-crafting'
end

-- ingridients
if tier > 1 then
  ingredients[#ingredients + 1] = {'replicator-'..(tier-1), 1}
end

--slots
local slots = 1
if tier > 4 then slots = 3
elseif tier > 2 then slots = 2 end


----- actual function
data:extend({
    {
      type = "recipe",
      name = "replicator-"..tier,
      enabled = "false",
      ingredients = ingredients,
      result = "replicator-"..tier,
      subgroup = 'replicators'
    },
    {
      type = "item",
      name = "replicator-"..tier,
      icon = "__replicators__/graphics/icons/replicator-"..tier..".png",
      flags = {"goes-to-quickbar"},
      subgroup = "production-machine",
      order = "a[assembling-machine-4]",
      place_result = "replicator-"..tier,
      stack_size = 50
    },
    {
      type = "assembling-machine",
      name = "replicator-"..tier,
      icon = "__replicators__/graphics/icons/replicator-"..tier..".png",
      flags = {"placeable-neutral", "placeable-player", "player-creation"},
      minable = {hardness = 0.2, mining_time = 0.5, result = "replicator-"..tier},
      max_health = 200,
      corpse = "big-remnants",
      dying_explosion = "big-explosion",
      resistances =
      {
        {
          type = "fire",
          percent = 70
        }
      },
   fluid_boxes =
    {
      {
        production_type = "input",
        pipe_picture = replicatorpipepictures(),
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = -1,
        pipe_connections = {{ type="input", position = {0.0, -2.0} }}
      },
      {
        production_type = "output",
        pipe_picture = replicatorpipepictures(),
        pipe_covers = pipecoverspictures(),
        base_area = 10,
        base_level = 1,
        pipe_connections = {{ type="output", position = {0.0, 2.0} }}
      },
      off_when_no_fluid_recipe = true
    },
      collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
      selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
      light = {intensity = 1.00, size = 8},
      fast_replaceable_group = "replicator",
      animation =
      {
        filename = "__replicators__/graphics/replicator-"..tier..".png",
        priority="high",
        width = 113,
        height = 91,
        frame_count = 33,
        line_length = 11,
        animation_speed = 1/3,
        shift = {0.2, -0.10},
        scale = 1.00
      },
      crafting_categories = categories, "crafting", "advanced-crafting", "crafting-with-fluid",
      crafting_speed = base_speed * speed_factor^(tier-1),
      energy_source =
      {
        type = "electric",
        usage_priority = "secondary-input",
        emissions = base_pollution * pollution_factor^(tier-1),
      },
      energy_usage = (base_power * power_factor^(tier-1)) .. "kW",
      module_specification =
	{
	  module_slots = slots,
	},
      allowed_effects = {"consumption", "speed", "productivity", "pollution"},
      ingredient_count = 0,
      open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
      close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
      working_sound =
      {
        sound = {
          {
            filename = "__base__/sound/lab.ogg",
            volume = 0.7
          },
        },
        idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
        apparent_volume = 1.5,
      }
    }
})

end

-- function to generate the researh for the diffrent replicator buildings and the category tiers for the replication items
local function repl_tier(tier, unit)
  ------ definition of variables
  -- prerequisites
  local preq = {}
  if rare_earth_enabled then
	if tier > 1 then preq[#preq+1] = 'repltech-replication-'..(tier-1) end
	if tier == 2 then preq[#preq + 1] = 'superconductor' end
	if tier == 4 then preq[#preq + 1] = 'ion-conduit' end
  else
  	if tier > 1 then preq[#preq+1] = 'repltech-replication-'..(tier-1) end
  end
  -- effects
  effects = {
    {type = "unlock-recipe", recipe = "replicator-"..tier},
  }

  ------ the actual function
  -- adding the research
  data:extend({
    {
      type = "technology",
      name = "repltech-replication-" .. tier,
      icon = "__replicators__/graphics/icons/replicator-"..tier..".png",
      effects = effects,
      prerequisites = preq,
      unit = unit,
      order = "c-a",
    },
  -- adding the recipe category
    {
      type = "recipe-category",
      name = "replication-"..tier
    }
  })
end



-- adding research
repl_tier(1, research(50, 1, 1, 0, 0, 15))
repl_tier(2, research(100, 2, 1, 0, 0, 25))
repl_tier(3, research(250, 1, 2, 1, 0, 30))
repl_tier(4, research(500, 1, 1, 2, 1, 35))
repl_tier(5, research(800, 1, 2, 3, 2, 40))

-- adding replicator
if rare_earth_enabled then
	make_replicator(1, {
	  {"electronic-circuit", 5},
	  {"rare-earth-magnet", 5},
	  {"iron-plate", 15}
	})
	make_replicator(2, {
	  {"superconductor", 5},
	  {"electronic-circuit", 20},
	})
	make_replicator(3, {
	  {"superconductor", 8},
	  {"engine-unit", 2},
	})
	make_replicator(4, {
	  {"ion-conduit", 4},
	  {"advanced-circuit", 4},
	})
	make_replicator(5, {
	  {"ion-conduit", 8},
	  {"processing-unit", 4},
	})
else 
	make_replicator(1, {
	  {"electronic-circuit", 5},
	  {"copper-plate", 5},
	  {"iron-plate", 20}
	})
	make_replicator(2, {
	  {"steel-plate", 15},
	  {"electronic-circuit", 35},
	})
	make_replicator(3, {
	  {"plastic-bar", 10},
	  {"battery", 10},
	  {"engine-unit", 6},
	})
	make_replicator(4, {
	  {"electric-engine-unit", 6},
	  {"speed-module", 2},
	  {"advanced-circuit", 10},
	})
	make_replicator(5, {
	  {"battery-equipment", 1},
	  {"speed-module-2", 2},
	  {"energy-shield-equipment", 1},
	})
end
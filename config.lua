-------------------------------------------------------------------------------------------------
--Config File------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

-- If you dont want another resource or you add the mod to an existing game:
rare_earth_enabled = true			-- To disable rare-earth generatin and all items which depend on it: replace "true" with "false"

-- Speed of the replcators
replcator_base_speed = 1			-- Higher means faster Replicator: 2 would double the speed (default: 1)
replcator_speed_factor = 2			-- Higher means the speed difference between two replcator tiers gets bigger (default: 2; small changes can have big impact)

-- Energy consumption
replcator_base_power = 1			-- Higher means more energy is needed: 2 would double the energy consumption (default: 1)
replcator_power_factor = 2.2		-- Higher means the energy demand difference between two replcator tiers gets bigger (default: 2.1; small changes can have big impact)

-- Pollution
replcator_base_pollution = 1 		-- Higher means more pollution: 2 would double the pollution (default: 1)
replcator_pollution_factor = 1		-- Higher means the pollution difference between two replcator tiers gets bigger (default: 1; small changes can have big impact)

-- Replication time factor
replcation_time_factor = 1			-- Higher means longer replcation times: 2 will double all replcation times (default = 1)

-- Will give the player some items+researches so he can play the game with every ressource disabled but rare earth
fast_start_enabled = false			-- To enable fast start: replace "false" with "true"

--if you want just one single item to not be replicable, then use this blacklist
endpoint_blacklist = {
	--{"ITEM-name", "type"} type can be "item" or "fluid"
	{"loader", "item"},
	{"fast-loader", "item"},
	{"express-loader", "item"},
	{"player-port", "item"},
	{"void", "item"},
	{"small-plane", "item"},
	{"void", "item"},
	{"water-void", "item"},
}

--if you want every item that uses this one material some where in its making process to not be replicable, then use this blacklist
--useful for box or barrel items
recursive_blacklist = {
	--"RECIPE-name"
	-- example: "iron-plate"; this would delete all items which need iron-plates from list of replicable items: iron-gears, belts,...
	"wooden-box",
	"steel-box",
	"tungsten-box",
	"empty-barrel",
	"gas-canister",
	"empty-canister",
}


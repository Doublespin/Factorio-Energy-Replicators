require("config")


script.on_event(defines.events.on_player_created, function(event)
	if fast_start_enabled then
		for i, player in pairs(game.players) do
			local player = game.players[i]
			player.force.technologies["repltech-replication-1"].researched = true
			player.force.technologies["repltech-stone-13131"].researched = true
			player.force.technologies["repltech-iron-ore-13131"].researched = true
			player.force.technologies["repltech-copper-ore-13131"].researched = true
			player.force.technologies["repltech-water-13131"].researched = true
			player.insert({name='replicator-1', count=2})
			player.insert({name='small-electric-pole', count=5})
			player.insert({name='solar-panel', count=8})
			player.insert({name='accumulator', count=6})
		end
	end
end)








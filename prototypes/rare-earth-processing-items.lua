data:extend({
  {
	  type = "item",
	  name = "neodymium-plate",
	  icon = "__replicators__/graphics/icons/neodymium-plate.png",
	  flags = {"goes-to-main-inventory"},
	  subgroup = "replication-resources",
	  order = "a-a",
	  stack_size = 100,
  },
  {
	   type = "recipe",
	   name = "neodymium-plate",
	   category = "smelting",
	   enabled = "true",
	   energy_required = 3.5,
	   ingredients = {{ "rare-earth", 1}},
	   result = "neodymium-plate"
  },
   {
       type = "recipe",
       name = "rare-earth-magnet",
       energy_required = 1,
       enabled = "true",
       ingredients = {
         {'neodymium-plate', 3},
         {'iron-plate', 3}
       },
       result = "rare-earth-magnet"
   },
   {
     type = "tool",
     name = "rare-earth-magnet",
     icon = "__replicators__/graphics/icons/rare-earth-magnet.png",
     flags = {"goes-to-main-inventory"},
     subgroup = "replication-resources",
     order = "a[ion-conduit]-a",
	 durability = 1,
     stack_size = 100,
   },
   {
     type = 'technology',
     name='superconductor',
     icon = '__replicators__/graphics/icons/superconductor.png',
     effects = {{type = 'unlock-recipe', recipe='superconductor'}},
     prerequisites = {},
     unit = research(40, 1, 0, 0, 0, 5),
     order='a-f-a',
   },
   {
       type = "recipe",
       name = "superconductor",
       energy_required = 1.5,
       enabled = "false",
       ingredients = {
         {'rare-earth-magnet', 5},
         {'steel-plate', 3},
         {'electronic-circuit', 3}
       },
       result = "superconductor"
   },
   {
     type = "tool",
     name = "superconductor",
     icon = "__replicators__/graphics/icons/superconductor.png",
     flags = {"goes-to-main-inventory"},
     subgroup = "replication-resources",
     order = "a[ion-conduit]-b",
	 durability = 1,
     stack_size = 100,
   },
   {
     type = 'technology',
     name='ion-conduit',
     icon = '__replicators__/graphics/icons/ion-conduit.png',
     effects = {{type = 'unlock-recipe', recipe='ion-conduit'}},
     prerequisites = {"superconductor"},
     unit = research(40, 1, 1, 0, 0, 5),
     order='a-f-a',
   },
   {
       type = "recipe",
       name = "ion-conduit",
       energy_required = 3,
       enabled = "false",
       ingredients = {
         {'superconductor', 5},
         {'rare-earth-magnet', 2},
         {'copper-plate', 2},
         {'advanced-circuit', 1}
       },
       result = "ion-conduit"
   },
   {
     type = "tool",
     name = "ion-conduit",
     icon = "__replicators__/graphics/icons/ion-conduit.png",
     flags = {"goes-to-main-inventory"},
     subgroup = "replication-resources",
     order = "a[ion-conduit]-c",
     stack_size = 50,
	 durability = 1,
   },
})
data:extend(
{
----create rare earth item-----
  {
    type = "tool",
    name = "rare-earth",
    icon = "__replicators__/graphics/icons/rare-earth.png",
    flags = {"goes-to-main-inventory"},
    subgroup = "raw-resource",
    order = "f[rare-earth]",
	durability = 1,
    stack_size = 50
  },
  ----create rare earth place control-----
  {
    type = "autoplace-control",
    name = "rare-earth",
    richness = true,
    order = "b-a"
  },
  ----create rare earth noise layer-----
  {
    type = "noise-layer",
    name = "rare-earth"
  },
  ----create rare earth spawn-----
  {
    type = "resource",
    name = "rare-earth",
    icon = "__replicators__/graphics/icons/rare-earth.png",
    flags = {"placeable-neutral"},
    category = "basic-solid",
    order="a-b-a",
    infinite = true,
	normal = 1000,
	minimal = 75,
    minable =
    {
      hardness = 0.7,
      mining_particle = "copper-ore-particle",
      mining_time = 1.5,
      result = "rare-earth"
    },
    collision_box = {{ -0.1, -0.1}, {0.1, 0.1}},
    selection_box = {{ -0.5, -0.5}, {0.5, 0.5}},
    autoplace =
    {
      control = "rare-earth",
      sharpness = 1,
      richness_multiplier = 1500,
      richness_multiplier_distance_bonus = 20,
      richness_base = 750,
      coverage = 0.018,
      peaks =
		{
			{
			noise_layer = "rare-earth",
			noise_octaves_difference = -1.5,
			noise_persistence = 0.3,
			}
		},
      starting_area_size = 600 * 0.011,
	  starting_area_amount = 3500,
    },
    stage_counts = {1000, 600, 400, 200, 100, 50, 20, 1},
    stages =
    {
      sheet =
      {
        filename = "__replicators__/graphics/entity/rare-earth/rare-earth.png",
        priority = "extra-high",
        width = 38,
        height = 38,
        frame_count = 4,
        variation_count = 8
      }
    },
    map_color = {r=0.388, g=0.803, b=0.215}
  }
})
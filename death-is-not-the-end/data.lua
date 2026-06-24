
local hit_effects = require("__base__.prototypes.entity.hit-effects")
local item_sounds = require("__base__.prototypes.item_sounds")
local sounds = require("__base__.prototypes.entity.sounds")
local q = "__test12__"

data:extend({
  {
    type = "custom-input",
    name = "bn-open-menu-hotkey",
    key_sequence = "SHIFT + B",
    consuming = "none"
  },
})

data:extend({{
    type = "item",
    name = "body-capsule",
    icon = "__core__/graphics/icons/entity/character.png",
    icon_size = 64,
    subgroup = "space-platform",
    place_result = "sleeping-body",
    stack_size = 10
}})


local shell = table.deepcopy(data.raw["container"]["iron-chest"])
shell.name = "sleeping-body"
shell.icon = "__core__/graphics/icons/entity/character.png"
shell.inventory_size = 200
shell.minable = {mining_time = 0.5, result = "body-capsule"}


shell.picture = {
    layers = {
        {
            filename = "__base__/graphics/entity/character/level1_dead.png",
            width = 114,
            height = 112,
            shift = util.by_pixel(-7.0,-5.5),
            frame_count = 2,
            scale = 0.5,
            usage = "player"
        },
        {
            filename = "__base__/graphics/entity/character/level1_dead_shadow.png",
            width = 108,
            height = 106,
            shift = util.by_pixel(-3.5,-3.0),
            frame_count = 2,
            draw_as_shadow = true,
            scale = 0.5,
            usage = "player"
        },
        {
            filename = "__base__/graphics/entity/character/level1_dead_mask.png",
            width = 88,
            height = 70,
            shift = util.by_pixel(-2.5,-6.5),
            frame_count = 2,
            apply_runtime_tint = true,
            scale = 0.5,
            usage = "player"
        },
    }
}

shell.selection_box = {{-0.8, -0.8}, {0.8, 0.8}}
shell.collision_box = {{-0.5, -0.5}, {0.5, 0.5}}

data:extend{shell}


data:extend({
  {
    type = "sound",
    name = "bn-transfer-start",
    filename = "__core__/sound/scenario-message.ogg",
    volume = 0.8
  },
  {
    type = "sound",
    name = "bn-transfer-success",
    filename = "__core__/sound/new-objective.ogg",
    volume = 0.8
  },
  {
    type = "sound",
    name = "bn-rupture",
    filename = "__core__/sound/game-lost.ogg",
    volume = 1.0
  }
})

if not data.raw["damage-type"]["biological"] then
    data:extend({
        {
            type = "damage-type",
            name = "biological"
        }
    })
end




local station = table.deepcopy(data.raw["container"]["iron-chest"])
station.name = "neural-server"
station.inventory_size = 0
station.picture = {
  layers = {
    {
      filename = "__base__/graphics/entity/beacon/beacon-shadow.png",
      width = 244,
      height = 176,
      shift = util.by_pixel(12.5, 0.5), --filename =  q .. "/graphics/entity/beacon/beacon-bottom1.png",
      frame_count = 1,
      draw_as_shadow = true,
      scale = 0.5,
    },
    {
      filename =  q .. "/graphics/entity/beakon/beacon-bottom1.png",
      width = 212,
      height = 192,
      --shift = util.by_pixel(12.5, 0.5),
      frame_count = 1,
      --draw_as_shadow = true,
      scale = 0.5,
    },
  }
}
station.radius_visualisation_specification = {
  draw_on_selection = true,
  draw_on_cursor    = true,
  distance = 4.5,
  sprite = {
    filename = "__base__/graphics/entity/beacon/beacon-radius-visualization.png",
    tint = {r = 0, g = 0, b = 0, a = 0.5},
    width = 10,
    height = 10,
  }
}
station.collision_box = {{-1.1, -1.1}, {1.1, 1.1}}
station.selection_box = {{-1.5, -1.5}, {1.5, 1.5}}
data:extend{station}

local station_it = table.deepcopy(data.raw["item"]["iron-chest"])
station_it.name = station.name
station_it.subgroup = "space-platform"
station_it.place_result = station.name
data:extend{station_it}


data:extend{
    {
      type = "sprite",
      name = "recharge_icon",
      filename = "__base__/graphics/icons/signal/signal-alert.png",
      width = 64,
      height = 64,
    }
}



data:extend({
  {
    type = "recipe",
    name = "neural-cooling-recipe",
    icon = "__base__/graphics/icons/fluid/water.png",
    category = "neural-cooling-category",
    enabled = true,
    ingredients = {
      {type = "fluid", name = "water", amount = 50}
    },
    energy_required = 1,
    results = {}
  },
  {
    type = "recipe-category",
    name = "neural-cooling-category"
  }
})


local radiator = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-1"])
radiator.name = "neural-radiator"
radiator.minable = {mining_time = 1, result = "neural-radiator"}
radiator.fixed_recipe = "neural-cooling-recipe"
radiator.crafting_categories = {"neural-cooling-category"}
radiator.fluid_boxes = {
    {
      --hide_connection_info = true,
      --draw_only_when_connected = true,
      secondary_draw_orders = { north = -1 },
      --secondary_draw_orders = {north = -1},
      --pipe_picture = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures,
      --pipe_picture_frozen = require("__space-age__.prototypes.entity.electromagnetic-plant-pictures").pipe_pictures_frozen,
      --pipe_covers = pipecoverspictures(),
      volume = 100,
      production_type = "input",
      pipe_connections =
      {
        { flow_direction = "input-output", direction = 0, position = { 0, -1 }},
        { flow_direction = "input-output", direction = 12, position = {-1, 0}},
        { flow_direction = "input-output", direction = 8, position = {0, 1}},
        { flow_direction = "input-output", direction = 4, position = {1, 0}},
      },
    }
}
radiator.working_sound = {
      sound =
      {
        filename = "__base__/sound/steam-turbine.ogg",
        volume = 0.49,
        modifiers = volume_multiplier("main-menu", 0.7),
        speed_smoothing_window_size = 60,
        advanced_volume_control = {attenuation = "exponential"},
        audible_distance_modifier = 0.8,
      },
      match_speed_to_activity = true,
      max_sounds_per_prototype = 3,
      fade_in_ticks = 4,
      fade_out_ticks = 20
    }
radiator.energy_usage = "2MW"
radiator.graphics_set = require (q .. ".death-is-not-the-end.graphics.scrubber").scrubber_graphics_set
data:extend{radiator}

local radiator_it = table.deepcopy(data.raw["item"]["iron-chest"])
radiator_it.name = radiator.name
radiator_it.subgroup = "space-platform"
radiator_it.icon = q .. "/graphics/entity/scrubber/scrubber-icon.png"
radiator_it.place_result = radiator.name
data:extend{radiator_it}


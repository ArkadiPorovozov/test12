require ("util")
local q = "__test12__"
local b = 1.6
local w = 0.5

local function scrubber_furnace_animation()
  return
  {

    layers =
    {
      util.sprite_load(q .. "/graphics/entity/scrubber/scrubber-animation",
      {
        priority = "high",
        scale = w,
        animation_speed = b,
        frame_count = 60,
      }),
      util.sprite_load(q .. "/graphics/entity/scrubber/scrubber-shadow",
      {
        priority = "high",
        draw_as_shadow = true,
        scale = w,
        repeat_count = 60,
      }),
      util.sprite_load(q .. "/graphics/entity/scrubber/scrubber-color1",
      {
        priority = "high",
        scale = w,
        animation_speed = b,
        frame_count = 60,
        tint = { 251,	206, 177, 0.5 },
      }),
-- -- -- -- -- -- -- -- -- -- --
    --[[
     util.sprite_load(q .. "/graphics/entity/conduit/conduit-color1",
      {
        priority = "high",
        blend_mode = "additive",
        scale = w,
        animation_speed = b,
        frame_count = 60,
        tint = { r = 0.596078431372549, g = 0.0392156862745098, b = 0, a = 1 },
      }),
    ]]
    }
  }
end

--[[
local function  glass_furnace_working()
  return
  {

    fadeout = true,
    effect = "flicker",

    animation = {

      layers = {
        util.sprite_load(q .. "/graphics/entity/glass-furnace/glass-furnace-hr-emission1",
        {
          priority = "high",
          blend_mode = "additive",
          draw_as_glow = true,
          scale = w,
          animation_speed = b,
          frame_count = 80,
        }),
      }
    },
  }
end
]]

--[[
local function  glass_furnace_color_animation()
  return
  {

    layers =
    {
      util.sprite_load(q .. "/graphics/entity/glass-furnace/glass-furnace-hr-color1",
      {
        priority = "high",
        draw_as_glow = true,
        blend_mode = "additive",
        scale = w,
        animation_speed = b,
        frame_count = 80,
        tint = { r = 1, g = 1, b = 1, a = 1 },
      }),
    }
  }
end
]]

--[[
local function wgorking_visualisations_smoke()
  return
  {
    --effect = "flicker",
    --fadeout = true,
    smoke =
    {
      {
        name = "smoke",
        deviation = {0.1, 0.1},
        frequency = 100,
        position = {0.0, -1.2},
        starting_vertical_speed = 10
      }
    }
  }
end
]]

return
{
    scrubber_graphics_set = {
    animation =  scrubber_furnace_animation(),
    working_visualisations = {
       --glass_furnace_working(),
       --scrubber_furnace_animation(),
       --wgorking_visualisations_smoke(),
    },
  },
}
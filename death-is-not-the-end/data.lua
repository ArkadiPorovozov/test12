--[[
-- Предмет для установки тела
data:extend({
  {
    type = "item",
    name = "body-capsule",
    icon = "__core__/graphics/icons/entity/character.png",
    icon_size = 64,
    place_result = "sleeping-body",
    subgroup = "space-platform",
    stack_size = 10
  }
})

-- Сущность спящего тела
local shell = table.deepcopy(data.raw["character-corpse"]["character-corpse"])
shell.name = "sleeping-body"
shell.time_to_live = 0 -- Вечное тело
shell.inventory_size = 255
shell.minable = {mining_time = 0.5, result = "body-capsule"}
shell.flags = {"placeable-player", "player-creation", "not-repairable"}

data:extend{shell}
]]

data:extend({
  {
    type = "custom-input",
    name = "bn-open-menu-hotkey",
    key_sequence = "SHIFT + B",
    consuming = "none"
  },
})
-- Предмет-капсула
data:extend({{
    type = "item",
    name = "body-capsule",
    icon = "__core__/graphics/icons/entity/character.png",
    icon_size = 64,
    subgroup = "space-platform",
    place_result = "sleeping-body",
    stack_size = 10
}})

-- СУЩНОСТЬ: Контейнер с внешностью трупа
local shell = table.deepcopy(data.raw["container"]["iron-chest"])
shell.name = "sleeping-body"
shell.icon = "__core__/graphics/icons/entity/character.png"
shell.inventory_size = 200 -- Огромный инвентарь
shell.minable = {mining_time = 0.5, result = "body-capsule"}

-- ГРАФИКА: Копируем анимацию лежащего тела
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
-- Убираем тень или настраиваем её, если нужно
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
-- Регистрация нового типа урона
if not data.raw["damage-type"]["biological"] then
    data:extend({
        {
            type = "damage-type",
            name = "biological"
        }
    })
end



-- Изменяем терминал: теперь это "storage-tank" или "programmable-speaker", 
-- чтобы на него можно было нажать и поймать событие открытия.
local station = table.deepcopy(data.raw["container"]["iron-chest"])
station.name = "neural-server"
station.inventory_size = 0 -- в нем нет места для вещей, только для Master'а
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

--[[
sleeping_body.picture = {
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
]]


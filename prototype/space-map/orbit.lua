

-- Инициализируем, если еще не создано
data.raw["space-connection"] = data.raw["space-connection"] or {}


local space_locations_to_generate = {
    { base_name = "nauvis",   type = "planet", distance = 1, orientation = 0 },--sosal-
    { base_name = "vulcanus", type = "planet", distance = 1, orientation = 90/360 },
    { base_name = "solar-system-edge", type = "space_location", distance = 200, orientation = 0.5 },
    { base_name = "shattered-planet",  type = "space_location", distance = 250, orientation = 0.5 },

    { base_name = "sosal-1", type = "space_location", distance = 45,  orientation = 0/360 },
    { base_name = "sosal-2", type = "space_location", distance = 45, orientation = 90/360 },
    { base_name = "sosal-3", type = "space_location", distance = 45,  orientation = 180/360 },
    { base_name = "sosal-4", type = "space_location", distance = 45,  orientation = (180+90)/360 },

    { base_name = "sosal-5", type = "space_location", distance = 85,  orientation = 0/360 },
    { base_name = "sosal-6", type = "space_location", distance = 85, orientation = 90/360 },
    { base_name = "sosal-7", type = "space_location", distance = 85,  orientation = 180/360 },
    { base_name = "sosal-8", type = "space_location", distance = 85,  orientation = (180+90)/360 },

    { base_name = "sosal-9",  type = "space_location", distance = 225,  orientation = 0/360 },
    { base_name = "sosal-10", type = "space_location", distance = 225, orientation = 90/360 },
    { base_name = "sosal-11", type = "space_location", distance = 225,  orientation = 180/360 },
    { base_name = "sosal-12", type = "space_location", distance = 225,  orientation = (180+90)/360 },
}

local connections_config = {

    {from = "nauvis", to = "vulcanus", length = 5000},
    {from = "vulcanus", to = "gleba", length = 7000},

    {from = "solar-system-edge", to = "shattered-planet", length = 15000, name = "solar-system-edge-shattered-planet"},


    {from = "sosal-1", to = "sosal-2", length = 10000},
    {from = "sosal-2", to = "sosal-3", length = 10000},
    {from = "sosal-3", to = "sosal-4", length = 10000},
    {from = "sosal-4", to = "sosal-1", length = 10000},

    {from = "sosal-5", to = "sosal-6", length = 30000},
    {from = "sosal-6", to = "sosal-7", length = 30000},
    {from = "sosal-7", to = "sosal-8", length = 30000},
    {from = "sosal-8", to = "sosal-5", length = 30000},

    {from = "sosal-9",  to = "sosal-10", length = 90000},
    {from = "sosal-10", to = "sosal-11", length = 90000},
    {from = "sosal-11", to = "sosal-12", length = 90000},
    {from = "sosal-12", to = "sosal-9",  length = 90000},
}


local space_locations_to_generate = {
    -- Планеты обычно привязаны к центру (солнцу), но можно указать родителя
    { base_name = "nauvis",   type = "planet", distance = 1, orientation = 0 },
    { base_name = "vulcanus", type = "planet", distance = 1, orientation = 90/360 },
    
    -- Пример локации-звезды (на которую будем вешать остальные)
    { base_name = "star", type = "space_location", distance = 100, orientation = 0.1 },

    -- Твои локации "sosal", привязанные к звезде "star"
    { base_name = "sosal-1", type = "space_location", parent_name = "star", distance = 45, orientation = 0/360 },
    { base_name = "sosal-2", type = "space_location", parent_name = "star", distance = 45, orientation = 90/360 },
    { base_name = "sosal-3", type = "space_location", parent_name = "star", distance = 45, orientation = 180/360 },
    { base_name = "sosal-4", type = "space_location", parent_name = "star", distance = 45, orientation = 270/360 },

    -- И так далее... можно менять дистанцию для каждого кольца
    { base_name = "sosal-5", type = "space_location", parent_name = "star", distance = 85, orientation = 0/360 },
    { base_name = "sosal-6", type = "space_location", parent_name = "star", distance = 85, orientation = 90/360 },
}

local function safe_extend(proto)
    if not data.raw[proto.type] or not data.raw[proto.type][proto.name] then
        data:extend{proto}
    end
end

for _, cfg in ipairs(space_locations_to_generate) do
    local name = cfg.base_name
    local dist = cfg.distance
    local orient = cfg.orientation
    
    -- Собираем таблицу орбиты, если указан родитель
    local orbit_data = nil
    if cfg.parent_name then
        orbit_data = {
            parent = {
                type = cfg.parent_type or "space-location", -- По умолчанию родитель - локация
                name = cfg.parent_name or "star",
            },
            distance = dist,
            orientation = orient
        }
    end

    if cfg.type == "planet" then
        local planet = data.raw["planet"][name]
        if planet then
            -- Если планета уже есть, обновляем её позицию или орбиту
            if orbit_data then
                planet.orbit = orbit_data
            else
                planet.distance = dist
                planet.orientation = orient
            end
        else
            -- Если планеты нет, создаем (хотя обычно планеты создаются отдельно)
            safe_extend({
                type = "planet",
                name = name,
                icon = "__core__/graphics/empty.png",
                icon_size = 1,
                orbit = orbit_data,
                distance = orbit_data and nil or dist,
                orientation = orbit_data and nil or orient,
                magnitude = 1,
                asteroid_spawn_definitions = {},
            })
        end

    elseif cfg.type == "space_location" then
        local loc = data.raw["space-location"][name]
        if not loc then
            loc = {
                type = "space-location",
                name = name,
                icon = cfg.icon or {filename = "__core__/graphics/empty.png", size = 1},
                icon_size = 1,
                magnitude = cfg.magnitude or 1,
                label = cfg.label or name,
                asteroid_spawn_definitions = cfg.asteroid_spawn_definitions or {},
            }
            -- Если есть орбита - ставим её, если нет - ставим плоские координаты
            if orbit_data then
                loc.orbit = orbit_data
            else
                loc.distance = dist
                loc.orientation = orient
            end
            safe_extend(loc)
        else
            -- Обновляем существующую
            if orbit_data then
                loc.orbit = orbit_data
            else
                loc.distance = dist
                loc.orientation = orient
            end
        end
    end
end

-- Создание связей
for _, conn in ipairs(connections_config) do
    local conn_name = conn.name or (conn.from .. "_to_" .. conn.to)
    if not data.raw["space-connection"][conn_name] then
        data:extend{{
            type = "space-connection",
            name = conn_name,
            from = conn.from,
            to = conn.to,
            length = conn.length,
            icon = "__space-age__/graphics/icons/solar-system-edge.png",
            icon_size = 64
        }}
    end
end





--[[
data.raw["space-connection"] = {}

local space_locations_to_generate = {
    { base_name = "nauvis",   type = "planet", distance = 1, orientation = 0 },--sosal-
    { base_name = "vulcanus", type = "planet", distance = 1, orientation = 90/360 },
    { base_name = "solar-system-edge", type = "space_location", distance = 200, orientation = 0.5 },
    { base_name = "shattered-planet",  type = "space_location", distance = 250, orientation = 0.5 },

    { base_name = "sosal-1", type = "space_location", distance = 45,  orientation = 0/360 },
    { base_name = "sosal-2", type = "space_location", distance = 45, orientation = 90/360 },
    { base_name = "sosal-3", type = "space_location", distance = 45,  orientation = 180/360 },
    { base_name = "sosal-4", type = "space_location", distance = 45,  orientation = (180+90)/360 },

    { base_name = "sosal-5", type = "space_location", distance = 85,  orientation = 0/360 },
    { base_name = "sosal-6", type = "space_location", distance = 85, orientation = 90/360 },
    { base_name = "sosal-7", type = "space_location", distance = 85,  orientation = 180/360 },
    { base_name = "sosal-8", type = "space_location", distance = 85,  orientation = (180+90)/360 },

    { base_name = "sosal-9",  type = "space_location", distance = 225,  orientation = 0/360 },
    { base_name = "sosal-10", type = "space_location", distance = 225, orientation = 90/360 },
    { base_name = "sosal-11", type = "space_location", distance = 225,  orientation = 180/360 },
    { base_name = "sosal-12", type = "space_location", distance = 225,  orientation = (180+90)/360 },
}

local connections_config = {

    {from = "nauvis", to = "vulcanus", length = 5000},
    {from = "vulcanus", to = "gleba", length = 7000},

    {from = "solar-system-edge", to = "shattered-planet", length = 15000, name = "solar-system-edge-shattered-planet"},


    {from = "sosal-1", to = "sosal-2", length = 10000},
    {from = "sosal-2", to = "sosal-3", length = 10000},
    {from = "sosal-3", to = "sosal-4", length = 10000},
    {from = "sosal-4", to = "sosal-1", length = 10000},

    {from = "sosal-5", to = "sosal-6", length = 30000},
    {from = "sosal-6", to = "sosal-7", length = 30000},
    {from = "sosal-7", to = "sosal-8", length = 30000},
    {from = "sosal-8", to = "sosal-5", length = 30000},

    {from = "sosal-9",  to = "sosal-10", length = 90000},
    {from = "sosal-10", to = "sosal-11", length = 90000},
    {from = "sosal-11", to = "sosal-12", length = 90000},
    {from = "sosal-12", to = "sosal-9",  length = 90000},
}

local function safe_extend(proto)
    if not data.raw[proto.type] or not data.raw[proto.type][proto.name] then
        data:extend{proto}
    end
end

for _, cfg in ipairs(space_locations_to_generate) do
    local name = cfg.base_name
    local dist = cfg.distance
    local orient = cfg.orientation
    if orient < 0 or orient >= 1 then
        error("Orientation for " .. name .. " must be in [0,1)")
    end

    if cfg.type == "planet" then
        if not data.raw["planet"][name] then
            error("Planet prototype '" .. name .. "' not found")
        end

        local loc = data.raw["planet"][name]
        if not loc then
            loc = {
                type = "planet",
                name = name,
                icon = data.raw["planet"][name].icon or {filename = "__core__/graphics/empty.png", size = 1},
                distance = dist,
                orientation = orient,
                gravity_pull = data.raw["planet"][name].gravity_pull or 0,
                label = data.raw["planet"][name].localised_name or name,
                asteroid_spawn_definitions = {},
            }
            safe_extend(loc)
        else
            loc.distance = dist
            loc.orientation = orient
        end

    elseif cfg.type == "space_location" then
        local loc = data.raw["space-location"][name]
        if not loc then
            loc = {
                type = "space-location",
                name = name,
                icon = cfg.icon or {filename = "__core__/graphics/empty.png", size = 1},
                distance = dist,
                orientation = orient,
                gravity_pull = cfg.gravity_pull or 0,
                label = cfg.label or name,
                asteroid_spawn_definitions = cfg.asteroid_spawn_definitions or {},
            }
            safe_extend(loc)
        else
            loc.distance = dist
            loc.orientation = orient
        end
    else
        error("Unknown type: " .. tostring(cfg.type))
    end
end


for _, conn in ipairs(connections_config) do
    local conn_name = conn.name or (conn.from .. "_to_" .. conn.to)
    if not data.raw["space-connection"][conn_name] then
        data:extend{{
            type = "space-connection",
            name = conn_name,
            from = conn.from,
            to = conn.to,
            length = conn.length,
            icon = "__space-age__/graphics/icons/solar-system-edge.png",
        }}
    end
end
]]
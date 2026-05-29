


local space_locations_to_generate = {
    { base_name = "nauvis",   type = "planet", distance = 18, orientation = 0 },
    { base_name = "moshine", type = "planet", distance = 6, orientation = 202.5/360 },
    { base_name = "vulcanus", type = "planet", distance = 6, orientation = 22.5/360 },

    { base_name = "gleba",  type = "planet", distance = 18, orientation = 180/360 },
    { base_name = "fulgora",  type = "planet", distance = 18, orientation = 270/360 },
    --{ base_name = "carna",  type = "planet", distance = 30, orientation = 132.5/360 },

    { base_name = "rubia",  type = "planet", distance = 18, orientation = 90/360 },
    --{ base_name = "cerys",  type = "planet", distance = 20, orientation = 270/360 },

    { base_name = "solar-system-edge", type = "space_location", distance = 250, orientation = 0.5 },
    { base_name = "shattered-planet",  type = "space_location", distance = 260, orientation = 90/360 },

    { base_name = "carna",  type = "planet", distance = 17, orientation = 185/360 },
    { base_name = "tellus",  type = "planet", distance = 21, orientation = 175/360 },

    { base_name = "panglia",  type = "planet", distance = 22, orientation = 180/360 },





    
    { base_name = "sosal-13", type = "space_location", distance = 20,  orientation = 0/360 },
    { base_name = "sosal-14", type = "space_location", distance = 20, orientation = 90/360 },
    { base_name = "sosal-15", type = "space_location", distance = 20,  orientation = 180/360 },
    { base_name = "sosal-16", type = "space_location", distance = 20,  orientation = (180+90)/360 },

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
    {from = "solar-system-edge", to = "shattered-planet", length = 15000, name = "solar-system-edge-shattered-planet"},
--[[
    {from = "nauvis", to = "fulgora", length = 5000},
    {from = "nauvis", to = "rubia", length = 5000},
    {from = "gleba", to = "fulgora", length = 5000},
    {from = "gleba", to = "rubia", length = 5000},
    {from = "moshine", to = "vulcanus", length = 5000},

    {from = "cerys", to = "fulgora", length = 1000},

    {from = "nauvis", to = "vulcanus", length = 5000},
    {from = "gleba", to = "moshine", length = 5000},

    {from = "gleba", to = "tellus", length = 5000},
    {from = "gleba", to = "carna", length = 5000},
    {from = "gleba", to = "panglia", length = 5000},
    --{from = "vulcanus", to = "gleba", length = 7000},
]]
 {from = "nauvis", to = "sosal-13", length = 5000},
 {from = "rubia", to = "sosal-14", length = 5000},
 {from = "gleba", to = "sosal-15", length = 5000},
 {from = "fulgora", to = "sosal-16", length = 5000},


    {from = "sosal-13", to = "sosal-14", length = 10000},
    {from = "sosal-14", to = "sosal-15", length = 10000},
    {from = "sosal-15", to = "sosal-16", length = 10000},
    {from = "sosal-16", to = "sosal-13", length = 10000},

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

-- 1. ОБРАБОТКА ЛОКАЦИЙ И ПЛАНЕТ
for _, cfg in ipairs(space_locations_to_generate) do
    local name = cfg.base_name
    local dist = cfg.distance
    local orient = cfg.orientation
    
    if orient < 0 or orient >= 1 then
        error("Orientation for " .. name .. " must be in [0,1)")
    end

    local p_type = (cfg.type == "planet") and "planet" or "space-location"
    local loc = data.raw[p_type][name]

    -- ПРОВЕРКА: Если это планета и её нет в базе — СКИПАЕМ
    if cfg.type == "planet" and not loc then
        -- Ничего не делаем, Master, этой планеты нет в текущей сборке
    else
        if not loc then
            -- СОЗДАЕМ НОВЫЙ (только для space-location, так как планеты мы скипнули выше)
            local new_proto = {
                type = p_type,
                name = name,
                icon = "__core__/graphics/empty.png",
                icon_size = 64,
                distance = dist,
                orientation = orient,
                magnitude = cfg.magnitude or 1,
                label = cfg.label or name,
                asteroid_spawn_definitions = cfg.asteroid_spawn_definitions or {},
                orbit = {
                    parent = { type = "space-location", name = "star" },
                    distance = dist,
                    orientation = orient
                }
            }
            safe_extend(new_proto)
        else
            -- ОБНОВЛЯЕМ СУЩЕСТВУЮЩИЙ
            loc.distance = dist
            loc.orientation = orient
            loc.orbit = {
                parent = { type = "space-location", name = "star" },
                distance = dist,
                orientation = orient
            }
            if cfg.magnitude then loc.magnitude = cfg.magnitude end
            if cfg.draw_orbit ~= nil then loc.draw_orbit = cfg.draw_orbit end
        end
    end
end

-- 2. ОБРАБОТКА СВЯЗЕЙ С ПРОВЕРКОЙ ПОВЕРХНОСТЕЙ
for _, conn in ipairs(connections_config) do
    -- Проверяем, существуют ли обе точки (from и to)
    local from_exists = data.raw["planet"][conn.from] or data.raw["space-location"][conn.from]
    local to_exists = data.raw["planet"][conn.to] or data.raw["space-location"][conn.to]

    if from_exists and to_exists then
        local conn_name = conn.name or (conn.from .. "_to_" .. conn.to)
        if not data.raw["space-connection"][conn_name] then
            data:extend{{
                type = "space-connection",
                name = conn_name,
                from = conn.from,
                to = conn.to,
                length = conn.length,
                icon = "__space-age__/graphics/icons/solar-system-edge.png",
                icon_size = 64,
            }}
        end
    else
        -- Master, мы не можем построить маршрут, если одной из точек нет в Gym!
        -- log("Skipping connection " .. conn.from .. " -> " .. conn.to .. " because one point is missing")
    end
end
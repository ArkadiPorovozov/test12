
local locations_to_generate = {
    {
        base_name = "sosal",
        variations = 16,
        distance = 30,
        orientation = 0.125,
        icon = "__space-age__/graphics/icons/solar-system-edge.png",
        localised_name = {""},
        order = "f[sosal]",
        subgroup = "planets",
        label_orientation = 0.15,
        solar_power_in_space = 100,
    },

    -- {
    --     base_name = "asteroid-field",
    --     variations = 1,
    --     distance = 150,
    --     orientation = 0.5,
    --     icon = "__space-age__/graphics/icons/asteroid.png",
    --     gravity_pull = 0,
    --     asteroid_spawn_definitions = {},
    -- },
}

for _, cfg in ipairs(locations_to_generate) do
    local count = cfg.variations or 1

    for i = 1, count do
        local name = cfg.base_name
        if count > 1 then
            name = name .. "-" .. i
        end

        local dist = type(cfg.distance) == "table" and cfg.distance[i] or cfg.distance
        local orient = type(cfg.orientation) == "table" and cfg.orientation[i] or cfg.orientation

        if orient < 0 or orient >= 1 then
            error("Orientation for " .. name .. " must be in [0,1)")
        end

        local proto = {
            type = "space-location",
            name = name,
            icon = cfg.icon or "__core__/graphics/empty.png",
            distance = dist or 0,
            orientation = orient or 0,
            gravity_pull = cfg.gravity_pull or 0,
            label = cfg.label or name,
            localised_name = cfg.localised_name or name,
            order = cfg.order,
            subgroup = cfg.subgroup,
            label_orientation = cfg.label_orientation,
            solar_power_in_space = cfg.solar_power_in_space,
            asteroid_spawn_definitions = cfg.asteroid_spawn_definitions or {},
        }

        data:extend{proto}
    end
end
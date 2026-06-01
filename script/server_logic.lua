local config = require("script.config")
local logic  = require("script.logic") 
local server_logic = {}

function server_logic.is_server_available(surface)
    if not surface then return false end
    return surface.count_entities_filtered{name = config.SERVER_BUILDING_NAME} > 0
end

function server_logic.get_server_entity(surface)
    return surface.find_entities_filtered{name = config.SERVER_BUILDING_NAME}[1]
end

function server_logic.get_radiator_stats(surface)
    local server = server_logic.get_server_entity(surface)
    if not server then return 0, 0 end
    local radiators = surface.find_entities_filtered{
        name = config.RADIATOR_NAME, position = server.position, radius = config.RADIATOR_RADIUS
    }
    local total, active = #radiators, 0
    for _, r in ipairs(radiators) do if r.valid and r.is_crafting() then active = active + 1 end end
    return total, active
end

function server_logic.get_cooling_capacity(surface)
    local _, active = server_logic.get_radiator_stats(surface)
    return active * config.BODIES_PER_RADIATOR
end

function server_logic.get_current_shells_count(surface)
    local count = 0
    for _, shell in ipairs(storage.shells or {}) do
        if shell.valid and shell.surface == surface then count = count + 1 end
    end
    return count
end

function server_logic.check_server_limit(entity)
    local servers = entity.surface.find_entities_filtered{name = config.SERVER_BUILDING_NAME}
    return #servers <= config.MAX_HUBS_PER_PLANET
end

function server_logic.upload_to_server(player)
    local server_ent = server_logic.get_server_entity(player.surface)
    if not server_ent then player.print({"big-niga.no-link-error"}); return end
    if player.character then
        local old_shell = player.character.surface.create_entity{name = "sleeping-body", position = player.character.position, force = player.force, color = player.color}
        logic.transfer_items(player.character, old_shell, true)
        player.character.destroy(); table.insert(storage.shells, old_shell)
    end
    player.set_controller{type = defines.controllers.ghost}; player.teleport(server_ent.position, server_ent.surface)
    storage.players[player.index].is_in_server, storage.players[player.index].current_server = true, server_ent
end

function server_logic.clear_server_status(player)
    local p_data = storage.players[player.index]
    if p_data then p_data.is_in_server, p_data.current_server = false, nil end
end

return server_logic
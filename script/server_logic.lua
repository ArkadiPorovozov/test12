local config = require("script.config")
local logic  = require("script.logic") 
local server_logic = {}

-- Проверка наличия сервера
function server_logic.is_server_available(surface)
    if not surface then return false end
    local servers = surface.find_entities_filtered{name = config.SERVER_BUILDING_NAME}
    return #servers > 0
end

-- Поиск объекта сервера
function server_logic.get_server_entity(surface)
    return surface.find_entities_filtered{name = config.SERVER_BUILDING_NAME}[1]
end

-- Лимит серверов
function server_logic.check_server_limit(entity)
    local surface = entity.surface
    local servers = surface.find_entities_filtered{name = config.SERVER_BUILDING_NAME}
    if #servers > config.MAX_HUBS_PER_PLANET then
        game.print("♂️SERVER LIMIT REACHED♂️", {1, 0, 0})
        return false
    end
    return true
end

-- Загрузка на сервер
function server_logic.upload_to_server(player)
    if not player.character then return end
    
    local server_ent = server_logic.get_server_entity(player.surface)
    if not server_ent then
        player.print("♂️ERROR: NO SERVER♂️", {1, 0, 0})
        return
    end

    -- Упаковка Master'а
    local old_char = player.character
    local old_shell = old_char.surface.create_entity{
        name = "sleeping-body", position = old_char.position, force = player.force, color = player.color
    }
    logic.transfer_items(old_char, old_shell, true)
    old_char.destroy()
    table.insert(storage.shells, old_shell)

    -- Вход в систему
    player.set_controller{type = defines.controllers.ghost}
    player.teleport(server_ent.position, server_ent.surface)
    
    local p_data = storage.players[player.index]
    p_data.is_in_server = true
    p_data.current_server = server_ent

    -- РИСУЕМ ЗНАЧОК (ИСПРАВЛЕН СЛОЙ)
    if config.SERVER_GHOST_SPRITE then
        p_data.server_sprite_id = rendering.draw_sprite{
            sprite = config.SERVER_GHOST_SPRITE,
            target = server_ent,
            target_offset = config.SPRITE_OFFSET,
            surface = player.surface,
            scale = config.SPRITE_SCALE,
            render_layer = "higher-object-above-shadow" -- ИСПРАВЛЕНО
        }
    end
    
    player.print("♂️NEURAL LINK ESTABLISHED♂️", {0, 0.8, 1})
end

-- Очистка значка при выходе
function server_logic.clear_server_status(player)
    local p_data = storage.players[player.index]
    if p_data and p_data.server_sprite_id then
        if rendering.is_valid(p_data.server_sprite_id) then
            rendering.destroy(p_data.server_sprite_id)
        end
        p_data.server_sprite_id = nil
    end
    if p_data then
        p_data.is_in_server = false
        p_data.current_server = nil
    end
end

return server_logic
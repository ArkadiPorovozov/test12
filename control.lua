-- ============================================================================
-- СЕКЦИЯ 1: ПОДКЛЮЧЕНИЕ
-- ============================================================================
local config       = require("script.config")
local gui          = require("script.gui")
local logic        = require("script.logic")
local effects      = require("script.effects")
local server_logic = require("script.server_logic")

-- ============================================================================
-- СЕКЦИЯ 2: ИНИЦИАЛИЗАЦИЯ
-- ============================================================================
local function setup_all()
    storage.shells = storage.shells or {}
    storage.players = storage.players or {}
    for _, player in pairs(game.players) do gui.create_main_button(player) end
end

script.on_init(setup_all)
script.on_configuration_changed(setup_all)
script.on_event(defines.events.on_player_created, function(event) setup_all() end)

-- ============================================================================
-- СЕКЦИЯ 3: ЯДРО (ПЕРЕСЕЛЕНИЕ)
-- ============================================================================
function complete_transfer(player, idx)
    storage.shells = storage.shells or {}
    local target_shell = storage.shells[idx]
    
    if not target_shell or not target_shell.valid then 
        player.print("♂️VESSEL LOST♂️", {1, 0, 0})
        return 
    end

    if not server_logic.is_server_available(player.surface) or 
       not server_logic.is_server_available(target_shell.surface) then
        player.print("♂️NO SERVER CONNECTION♂️", {1, 0, 0})
        return
    end

    -- Успешный выход: чистим статус сервера и спрайты
    server_logic.clear_server_status(player)

    local p_data = storage.players[player.index]
    if p_data then
        p_data.slow_death_ticks = 0
        p_data.fatal_death_ticks = 0
        p_data.spasm_stage = nil
        p_data.last_transfer = game.tick
    end

    if player.character then
        local old_char = player.character
        local old_shell = old_char.surface.create_entity{
            name = "sleeping-body", position = old_char.position, force = player.force, color = player.color
        }
        logic.transfer_items(old_char, old_shell, true)
        old_char.destroy()
        table.insert(storage.shells, old_shell)
    end

    player.teleport(target_shell.position, target_shell.surface)
    local new_char = target_shell.surface.create_entity{name = "character", position = target_shell.position, force = player.force}
    player.set_controller{type = defines.controllers.character, character = new_char}
    
    logic.transfer_items(target_shell, new_char, false)
    target_shell.destroy()
    table.remove(storage.shells, idx)

    effects.apply_reincarnation_side_effects(player)
    if config.SOUND_FINISH then player.play_sound{path = config.SOUND_FINISH} end
    if player.gui.screen.body_master_frame then player.gui.screen.body_master_frame.destroy() end
end

-- ============================================================================
-- СЕКЦИЯ 4: ТИКИ (БЛОКИРОВКА И СПРАЙТЫ)
-- ============================================================================
script.on_event(defines.events.on_tick, function(event)
    for p_idx, data in pairs(storage.players or {}) do
        local player = game.get_player(p_idx)
        if player and player.valid then
            
            -- ЖЕСТКАЯ ФИКСАЦИЯ НА СЕРВЕРЕ
            if data.is_in_server and data.current_server and data.current_server.valid then
                -- Телепортируем каждый тик для абсолютной неподвижности
                player.teleport(data.current_server.position)
            elseif data.is_in_server then
                -- Если сервер взорвали, пока Master был внутри
                server_logic.clear_server_status(player)
                player.print("♂️SERVER DESTROYED! NEURAL DISCONNECT♂️", {1, 0, 0})
            end

            if event.tick % 30 == 0 and player.gui.screen.body_master_frame then
                gui.update_timer(player)
            end

            effects.process_tick(player, data, event.tick)

            if data.transfer_target_tick and event.tick >= data.transfer_target_tick then
                complete_transfer(player, data.target_shell_idx)
                data.transfer_target_tick = nil
            end
        end
    end
end)

-- ============================================================================
-- СЕКЦИЯ 5: СОБЫТИЯ
-- ============================================================================
script.on_event(defines.events.on_gui_click, function(event)
    local player = game.get_player(event.player_index)
    local name = event.element.name

    if name == "bn_upload_server" then
        server_logic.upload_to_server(player)
        gui.open_body_menu(player)
    elseif name == "bn_close_menu" then
        player.gui.screen.body_master_frame.destroy()
    elseif name:find("bn_transfer_idx_") then
        local idx = tonumber(name:match("bn_transfer_idx_(%d+)"))
        local target_shell = storage.shells[idx]
        
        if not server_logic.is_server_available(player.surface) or 
           (target_shell and not server_logic.is_server_available(target_shell.surface)) then
            player.print("♂️CONNECTION FAILED♂️", {1, 0, 0})
            return
        end

        storage.players[player.index] = storage.players[player.index] or {}
        local p_data = storage.players[player.index]
        if (p_data.last_transfer and game.tick < p_data.last_transfer + (config.TRANSFER_COOLDOWN * 60)) or p_data.transfer_target_tick then return end

        if config.SOUND_START then player.play_sound{path = config.SOUND_START} end
        p_data.transfer_target_tick = game.tick + (config.TRANSFER_DURATION * 60)
        p_data.target_shell_idx = idx
        gui.update_timer(player)
    end
end)

script.on_event(defines.events.on_gui_opened, function(event)
    if event.entity and event.entity.name == config.SERVER_BUILDING_NAME then
        local player = game.get_player(event.player_index)
        player.opened = nil
        gui.open_body_menu(player)
    end
end)

script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, function(event)
    local entity = event.entity or event.created_entity
    if not entity or not entity.valid then return end
    if entity.name == config.SERVER_BUILDING_NAME then
        if not server_logic.check_server_limit(entity) then
            local player = event.player_index and game.get_player(event.player_index)
            if player then player.insert{name = config.SERVER_BUILDING_NAME, count = 1} end
            entity.destroy()
            return
        end
    end
    if entity.name == "sleeping-body" then
        storage.shells = storage.shells or {}
        table.insert(storage.shells, entity)
        if event.player_index then entity.color = game.get_player(event.player_index).color end
    end
end)

script.on_event({defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity, defines.events.on_entity_died}, function(event)
    if event.entity and event.entity.name == "sleeping-body" then
        for i, shell in ipairs(storage.shells or {}) do if shell == event.entity then table.remove(storage.shells, i); break end end
    end
end)

script.on_event("bn-open-menu-hotkey", function(event)
    gui.open_body_menu(game.get_player(event.player_index))
end)
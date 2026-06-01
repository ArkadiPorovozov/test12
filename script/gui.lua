local Config = require("script.config")
local server_logic = require("script.server_logic")
local GUI = {}

function GUI.create_main_button(player)
    if not player.gui.top.bn_main_button then
        player.gui.top.add{type = "sprite-button", name = "bn_main_button", sprite = "entity/character", tooltip = {"big-niga.hub-title"}}
    end
end

function GUI.open_body_menu(player)
    if player.gui.screen.body_master_frame then player.gui.screen.body_master_frame.destroy() end
    
    local frame = player.gui.screen.add{type = "frame", name = "body_master_frame", caption = {"big-niga.hub-title"}, direction = "vertical"}
    frame.style.minimal_width = 750
    frame.auto_center = true
    player.opened = frame 

    -- Панель статуса
    local info_pane = frame.add{type = "flow", name = "status_flow", direction = "vertical"}
    info_pane.style.bottom_margin = 10
    info_pane.add{type = "label", name = "bn_cd_label", caption = ""}
    info_pane.add{type = "label", name = "bn_transfer_label", caption = ""} 

    -- Статус цифрового призрака
    if not player.character then
        local ghost_flow = frame.add{type = "flow"}
        ghost_flow.style.horizontally_stretchable = true
        local lbl = ghost_flow.add{type = "label", caption = {"big-niga.status-ghost"}}
        lbl.style.font_color = {0, 0.8, 1}
        lbl.style.horizontal_align = "center"
    end

    local scroll = frame.add{type = "scroll-pane", name = "body_scroll", vertical_scroll_policy = "always"}
    scroll.style.maximal_height = 550
    scroll.style.horizontally_stretchable = true

    -- Сбор данных
    local planet_data = {}
    for _, surface in pairs(game.surfaces) do
        if server_logic.is_server_available(surface) then
            local total_rad, active_rad = server_logic.get_radiator_stats(surface)
            planet_data[surface.name] = {
                shells = {}, 
                has_server = true, 
                capacity = active_rad * Config.BODIES_PER_RADIATOR,
                current = server_logic.get_current_shells_count(surface)
            }
        end
    end

    storage.shells = storage.shells or {}
    for i, shell in ipairs(storage.shells) do
        if shell and shell.valid then
            local s_name = shell.surface.name
            if not planet_data[s_name] then planet_data[s_name] = {shells = {}, has_server = false, capacity = 0, current = 0} end
            table.insert(planet_data[s_name].shells, {entity = shell, index = i})
        end
    end

    for surface_name, data in pairs(planet_data) do
        scroll.add{type = "line", direction = "horizontal"}
        
        local header = scroll.add{type = "flow"}
        header.style.vertical_align = "center"
        header.style.top_margin = 5
        header.style.bottom_margin = 5
        
        local title = header.add{type = "label", caption = {"", "[planet=" .. surface_name .. "]  ", surface_name:upper()}}
        title.style.font = "default-bold" 
        title.style.minimal_width = 300

        -- Инфо об охлаждении
        local cool_lbl = header.add{type = "label", caption = {"big-niga.cooling-info", data.current, data.capacity}}
        cool_lbl.style.minimal_width = 180
        cool_lbl.style.font_color = (data.capacity == 0) and {1, 0, 0} or (data.current > data.capacity and {1, 0.5, 0} or {0, 1, 0})

        if data.has_server then
            header.add{type = "button", name = "bn_hub_jump_" .. surface_name, caption = {"big-niga.hub-link-btn"}, style = "tool_button"}
        end

        local table_gui = scroll.add{type = "table", name = "table_" .. surface_name, column_count = 3}
        table_gui.style.horizontal_spacing = 30
        
        for _, item in ipairs(data.shells) do
            table_gui.add{type = "sprite", sprite = "entity/character"}
            local lbl = table_gui.add{type = "label", caption = string.format("X:%d Y:%d", math.floor(item.entity.position.x), math.floor(item.entity.position.y))}
            lbl.style.minimal_width = 200 
            
            table_gui.add{
                type = "button", 
                name = "bn_transfer_idx_" .. item.index, 
                caption = {"big-niga.enter-btn"},
                tags = {surface = surface_name} 
            }
        end
    end
    
    local close_btn = frame.add{type = "button", name = "bn_close_menu", caption = {"big-niga.close-btn"}}
    close_btn.style.horizontally_stretchable = true
    
    GUI.update_timer(player)
end

function GUI.update_timer(player)
    local frame = player.gui.screen.body_master_frame
    if not frame or not frame.valid then return end

    local p_data = storage.players[player.index] or {}
    local current_tick = game.tick
    local cd_left = (p_data.last_transfer or 0) + (Config.TRANSFER_COOLDOWN * 60) - current_tick
    local has_local_server = server_logic.is_server_available(player.surface)

    local cd_lbl = frame.status_flow.bn_cd_label
    if cd_left > 0 then
        cd_lbl.caption = {"big-niga.status-recharging", math.ceil(cd_left/60)}
        cd_lbl.style.font_color = {1, 0, 0}
    else
        cd_lbl.caption = {"big-niga.status-ready"}
        cd_lbl.style.font_color = {0, 1, 0}
    end

    local trans_label = frame.status_flow.bn_transfer_label
    if p_data.transfer_target_tick and p_data.transfer_target_tick > current_tick then
        trans_label.caption = {"big-niga.status-syncing", math.ceil((p_data.transfer_target_tick - current_tick)/60)}
    else trans_label.caption = "" end

    -- ОБНОВЛЕНИЕ КНОПОК
    for _, scroll_child in pairs(frame.body_scroll.children) do
        if scroll_child.type == "table" then
            for _, btn in pairs(scroll_child.children) do
                if btn.type == "button" and btn.tags and btn.tags.surface then
                    local target_surface = game.surfaces[btn.tags.surface]
                    local has_remote_server = server_logic.is_server_available(target_surface)
                    local target_capacity = server_logic.get_cooling_capacity(target_surface)
                    
                    -- УСЛОВИЕ: Линк возможен только если:
                    -- 1. КД прошло
                    -- 2. Локальный сервер онлайн
                    -- 3. Удаленный сервер онлайн
                    -- 4. Охлаждение на планете назначения ВООБЩЕ РАБОТАЕТ (capacity > 0)
                    local can_jump = (cd_left <= 0) and has_local_server and has_remote_server and (target_capacity > 0)
                    
                    btn.style = can_jump and "confirm_button" or "red_button"
                    btn.enabled = (cd_left <= 0) and not p_data.transfer_target_tick
                end
            end
        end
    end
end

return GUI
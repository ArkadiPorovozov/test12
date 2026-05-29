local Config = require("script.config")
local server_logic = require("script.server_logic")
local GUI = {}

function GUI.create_main_button(player)
    if not player.gui.top.bn_main_button then
        player.gui.top.add{type = "sprite-button", name = "bn_main_button", sprite = "entity/character", tooltip = "♂️BODY HUB♂️"}
    end
end

function GUI.open_body_menu(player)
    if player.gui.screen.body_master_frame then player.gui.screen.body_master_frame.destroy() end
    
    local frame = player.gui.screen.add{type = "frame", name = "body_master_frame", caption = "♂️NEURAL SERVER HUB♂️", direction = "vertical"}
    frame.style.minimal_width = 600
    frame.auto_center = true
    player.opened = frame

    -- Кнопка загрузки в облако
    local server_section = frame.add{type = "flow", direction = "horizontal"}
    if player.character then
        server_section.add{type = "button", name = "bn_upload_server", caption = "♂️UPLOAD TO SERVER♂️"}
    else
        server_section.add{type = "label", caption = "♂️STATUS: ONLINE (DIGITAL GHOST)♂️"}.style.font_color = {0, 0.8, 1}
    end

    -- Статусы КД и Линка
    local status_flow = frame.add{type = "flow", name = "status_flow", direction = "vertical"}
    status_flow.add{type = "label", name = "bn_cd_label", caption = "♂️READY♂️"}
    status_flow.add{type = "label", name = "bn_transfer_label", caption = ""} 

    local scroll = frame.add{type = "scroll-pane", name = "body_scroll", vertical_scroll_policy = "always"}
    scroll.style.maximal_height = 400

    local table_gui = scroll.add{type = "table", name = "body_table", column_count = 4}
    table_gui.style.horizontal_spacing = 30
    
    table_gui.add{type = "label", caption = "VESSEL"}
    table_gui.add{type = "label", caption = "COORD"}
    table_gui.add{type = "label", caption = "PLANET"}
    table_gui.add{type = "label", caption = "ACTION"}

    storage.shells = storage.shells or {}
    for i, shell in ipairs(storage.shells) do
        if shell and shell.valid then
            table_gui.add{type = "sprite", sprite = "entity/character"}
            table_gui.add{type = "label", caption = string.format("[%d, %d]", math.floor(shell.position.x), math.floor(shell.position.y))}
            table_gui.add{type = "label", caption = "[img=surface/" .. shell.surface.name .. "] " .. shell.surface.name}
            table_gui.add{type = "button", name = "bn_transfer_idx_" .. i, caption = "♂️ENTER♂️"}
        end
    end
    
    frame.add{type = "button", name = "bn_close_menu", caption = "CLOSE"}
    GUI.update_timer(player)
end

function GUI.update_timer(player)
    local frame = player.gui.screen.body_master_frame
    if not frame or not frame.valid then return end
    local p_data = storage.players[player.index] or {}
    local current_tick = game.tick
    
    local cd_left = (p_data.last_transfer or 0) + (Config.TRANSFER_COOLDOWN * 60) - current_tick
    local cd_label = frame.status_flow.bn_cd_label
    if cd_left > 0 then
        cd_label.caption = "♂️RECHARGING♂️: " .. math.ceil(cd_left/60) .. "s"
        cd_label.style.font_color = {1, 0.2, 0.2}
    else
        cd_label.caption = "♂️SYSTEMS READY♂️"
        cd_label.style.font_color = {0.2, 1, 0.2}
    end

    local trans_label = frame.status_flow.bn_transfer_label
    local is_linking = false
    if p_data.transfer_target_tick and p_data.transfer_target_tick > current_tick then
        is_linking = true
        local time_left = math.ceil((p_data.transfer_target_tick - current_tick) / 60)
        trans_label.caption = "♂️ESTABLISHING LINK♂️: " .. time_left .. "s..."
        trans_label.style.font_color = {1, 1, 0}
    else
        trans_label.caption = ""
    end

    local table_gui = frame.body_scroll.body_table
    local is_busy = (cd_left > 0) or is_linking
    for _, element in pairs(table_gui.children) do
        if element.type == "button" and element.name:find("bn_transfer_idx_") then
            element.enabled = not is_busy
        end
    end
end

return GUI
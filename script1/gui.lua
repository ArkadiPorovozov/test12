local Logic = require("script1.logic")
local GUI = {}

function GUI.update_inventory_grid(player, platform)
    local frame = player.gui.screen.oc_frame
    if not frame then return end
    local inv_frame = frame.main_flow.left_side.oc_inv_frame
    inv_frame.clear()
    local scroll = inv_frame.add{type = "scroll-pane", vertical_scroll_policy = "always"}
    scroll.style.maximal_height = 400
    local table_gui = scroll.add{type = "table", column_count = 6}
    if not platform or not platform.hub or not platform.hub.valid then return end
    local p_data = storage.players[player.index]
    for _, item in pairs(platform.hub.get_inventory(defines.inventory.hub_main).get_contents()) do
        local is_in_cart = p_data.cart and p_data.cart[item.name] ~= nil
        table_gui.add{type = "sprite-button", name = "oc_add_" .. item.name, sprite = "item/" .. item.name, number = item.count, tooltip = item.name, toggled = is_in_cart}
    end
end

function GUI.refresh_cart(player)
    local frame = player.gui.screen.oc_frame
    if not frame then return end
    local cart_scroll = frame.main_flow.right_side.cart_scroll
    cart_scroll.clear()
    local p_data = storage.players[player.index]
    local platform = player.force.platforms[p_data.selected_platform_index]
    
    local chests_ready = Logic.get_dispatch_chests_count(platform)
    local status_lbl = frame.main_flow.right_side.oc_status
    status_lbl.caption = "CRATES READY: " .. chests_ready
    status_lbl.style.font_color = (chests_ready > 0) and {0,1,0} or {1,0,0}

    local table_cart = cart_scroll.add{type = "table", column_count = 3}
    for name, qty in pairs(p_data.cart or {}) do
        table_cart.add{type = "sprite", sprite = "item/" .. name}
        table_cart.add{type = "textfield", name = "oc_qty_" .. name, text = tostring(qty)}.style.width = 60
        table_cart.add{type = "button", name = "oc_rem_" .. name, caption = "X"}
    end
end

function GUI.draw_main(player)
    if player.gui.screen.oc_frame then player.gui.screen.oc_frame.destroy() end
    local frame = player.gui.screen.add{type = "frame", name = "oc_frame", caption = {"orbital-cargo.hub-title"}, direction = "vertical"}
    frame.auto_center = true
    player.opened = frame
    local main_flow = frame.add{type = "flow", name = "main_flow", direction = "horizontal"}
    
    local left = main_flow.add{type = "flow", name = "left_side", direction = "vertical"}
    left.style.minimal_width = 400
    local target_name = player.surface.planet and player.surface.planet.name or player.surface.name
    left.add{type = "label", caption = {"orbital-cargo.surface-label", target_name:upper()}}
    
    -- ВЫЗОВ ИСПРАВЛЕННОЙ ФУНКЦИИ
    local platforms = Logic.find_platforms_at_player_location(player)
    
    local p_names, p_indices = {}, {}
    for _, p in pairs(platforms) do table.insert(p_names, p.name); table.insert(p_indices, p.index) end
    left.add{type = "label", caption = {"orbital-cargo.select-ship"}}
    local list = left.add{type = "drop-down", name = "oc_platform_select", items = p_names}
    
    storage.players[player.index] = storage.players[player.index] or {cart = {}}
    local p_data = storage.players[player.index]
    p_data.platforms = p_indices
    left.add{type = "frame", name = "oc_inv_frame", direction = "vertical"}.style.minimal_height = 400
    
    local right = main_flow.add{type = "flow", name = "right_side", direction = "vertical"}
    right.style.minimal_width = 280
    right.add{type = "label", name = "oc_status", caption = "READY: 0"}
    local cart_scroll = right.add{type = "scroll-pane", name = "cart_scroll", vertical_scroll_policy = "always"}
    cart_scroll.style.maximal_height = 380
    
    if #p_indices > 0 then
        list.selected_index = 1
        p_data.selected_platform_index = p_indices[1]
        GUI.update_inventory_grid(player, player.force.platforms[p_indices[1]])
    end
    
    local btn_f = frame.add{type = "flow"}
    btn_f.add{type = "button", name = "oc_confirm", caption = {"orbital-cargo.confirm-btn"}, style = "confirm_button"}
    btn_f.add{type = "button", name = "oc_close", caption = {"orbital-cargo.close-btn"}}
    GUI.refresh_cart(player)
end

return GUI
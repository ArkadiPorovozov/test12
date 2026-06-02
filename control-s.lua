-- ============================================================================
-- СЕКЦИЯ 1: ПОДКЛЮЧЕНИЕ МОДУЛЕЙ
-- ============================================================================
local CFG   = require("script1.config")
local Logic = require("script1.logic")
local GUI   = require("script1.gui")

-- ============================================================================
-- СЕКЦИЯ 2: ИНИЦИАЛИЗАЦИЯ И АКТИВАЦИЯ СИСТЕМ
-- ============================================================================
local function setup_all()
    storage.players = storage.players or {}
    storage.active_drops = storage.active_drops or {}
    
    -- Гарантируем, что у каждого игрока есть таблица данных
    for _, player in pairs(game.players) do
        if player.valid then
            storage.players[player.index] = storage.players[player.index] or {cart = {}, platforms = {}}
            -- Пробуждаем ярлык на панели
            player.set_shortcut_available("oc-shortcut", true)
        end
    end
end

script.on_init(setup_all)
script.on_configuration_changed(setup_all)
script.on_event(defines.events.on_player_created, function(e) setup_all() end)

-- ============================================================================
-- СЕКЦИЯ 3: ОБРАБОТКА ТИКОВ (ПОЛЕТ И АНТИ-КРАЖА)
-- ============================================================================
script.on_event(defines.events.on_tick, function(event)
    -- 1. Движение летящих сундуков и урон при падении
    Logic.process_drops(event.tick)

    -- 2. Блокировка манипуляторов (Защита Диспетчера)
    -- Проверяем раз в 20 тиков для экономии ресурсов
    if event.tick % 20 == 0 then
        for _, surface in pairs(game.surfaces) do
            if surface.platform then -- Проверяем только орбитальные платформы
                local inserters = surface.find_entities_filtered{type = "inserter"}
                for _, ins in ipairs(inserters) do
                    local hand = ins.held_stack
                    if hand and hand.valid_for_read and hand.name == CFG.CHEST_ITEM then
                        -- Если манипулятор держит ящик и стоит рядом с Диспетчером
                        local dispatcher = surface.find_entities_filtered{
                            name = CFG.DISPATCHER_NAME, 
                            position = ins.position, 
                            radius = 2
                        }
                        if #dispatcher > 0 then
                            -- Бьем по рукам: возвращаем ящик в завод и очищаем руку
                            dispatcher[1].get_inventory(defines.inventory.assembling_machine_output).insert(hand)
                            hand.clear()
                        end
                    end
                end
            end
        end
    end
end)

-- ============================================================================
-- СЕКЦИЯ 4: ОБРАБОТКА GUI (КЛИКИ И ВЗАИМОДЕЙСТВИЕ)
-- ============================================================================
script.on_event(defines.events.on_gui_click, function(event)
    local p = game.get_player(event.player_index)
    if not p or not p.valid then return end
    
    local p_data = storage.players[p.index]
    local name = event.element.name

    -- Закрытие
    if name == "oc_close" then 
        if p.gui.screen.oc_frame then p.gui.screen.oc_frame.destroy() end
    
    -- Добавление/Удаление из корзины (Слева)
    elseif name:find("oc_add_") then
        local item = name:match("oc_add_(.*)")
        p_data.cart = p_data.cart or {}
        if p_data.cart[item] then 
            p_data.cart[item] = nil 
        else 
            p_data.cart[item] = 50 -- Количество по умолчанию
        end
        GUI.refresh_cart(p)
        event.element.toggled = (p_data.cart[item] ~= nil)

    -- Быстрое удаление из корзины (Справа)
    elseif name:find("oc_rem_") then
        local item = name:match("oc_rem_(.*)")
        p_data.cart[item] = nil
        GUI.refresh_cart(p)
        -- Снимаем подсветку в основном инвентаре
        local pl = p.force.platforms[p_data.selected_platform_index]
        if pl then GUI.update_inventory_grid(p, pl) end

    -- ПОДТВЕРЖДЕНИЕ ЗАКАЗА
    elseif name == "oc_confirm" then
        local plat = p.force.platforms[p_data.selected_platform_index]
        if not plat then return end
        
        local dispatched_count = 0
        for it_name, qty in pairs(p_data.cart or {}) do
            -- Logic.start_drop теперь возвращает РЕАЛЬНОЕ кол-во сброшенных ресурсов
            local actual = Logic.start_drop(p, plat, it_name, qty)
            if actual > 0 then
                p.print({"orbital-cargo.cargo-arrived-count", actual, it_name})
                dispatched_count = dispatched_count + 1
            end
        end

        if dispatched_count > 0 then
            p_data.cart = {} -- Очищаем корзину после успеха
            if p.gui.screen.oc_frame then p.gui.screen.oc_frame.destroy() end
        end
    end
end)

-- Обновление количества при ручном вводе
script.on_event(defines.events.on_gui_text_changed, function(event)
    if event.element.name:find("oc_qty_") then
        local item = event.element.name:match("oc_qty_(.*)")
        if storage.players[event.player_index] then
            storage.players[event.player_index].cart[item] = tonumber(event.element.text) or 0
        end
    end
end)

-- Смена платформы в выпадающем списке
script.on_event(defines.events.on_gui_selection_state_changed, function(event)
    if event.element.name == "oc_platform_select" then
        local p = game.get_player(event.player_index)
        local p_data = storage.players[p.index]
        local platform_idx = p_data.platforms[event.element.selected_index]
        
        p_data.selected_platform_index = platform_idx
        p_data.cart = {} -- Сброс корзины при переключении корабля
        
        local platform = p.force.platforms[platform_idx]
        if platform then
            GUI.update_inventory_grid(p, platform)
            GUI.refresh_cart(p)
        end
    end
end)

-- ============================================================================
-- СЕКЦИЯ 5: СПОСОБЫ ВЫЗОВА МЕНЮ
-- ============================================================================

-- По кнопке-ярлыку (Shortcut)
script.on_event(defines.events.on_lua_shortcut, function(event)
    if event.prototype_name == "oc-shortcut" then
        local p = game.get_player(event.player_index)
        if p.gui.screen.oc_frame then p.gui.screen.oc_frame.destroy() else GUI.draw_main(p) end
    end
end)

-- По горячим клавишам (SHIFT + G)
script.on_event("oc-open-menu", function(event)
    local p = game.get_player(event.player_index)
    if p.gui.screen.oc_frame then p.gui.screen.oc_frame.destroy() else GUI.draw_main(p) end
end)

-- Закрытие на ESC или E (стандартные правила 2.0)
script.on_event(defines.events.on_gui_closed, function(event)
    if event.element and event.element.name == "oc_frame" then
        event.element.destroy()
    end
end)

-- Открытие через клик по зданию Хаба платформы (опционально)
script.on_event(defines.events.on_gui_opened, function(event)
    -- Если Master на платформе и открыл её Хаб
    if event.entity and event.entity.name == "cargo-bay" then
        -- Можно добавить авто-открытие меню здесь
    end
end)
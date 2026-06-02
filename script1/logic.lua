local CFG = require("script1.config")
local Logic = {}

-- ПОИСК ПЛАТФОРМ (Синхронизировано с GUI)
function Logic.find_platforms_at_player_location(player)
    local found = {}
    local planet = player.surface.planet
    local target_name = planet and planet.name or player.surface.name
    local platforms = player.force.platforms
    if not platforms then return found end
    for _, p in pairs(platforms) do
        if p.space_location and p.space_location.name == target_name then
            table.insert(found, p)
        end
    end
    return found
end

-- Проверка ящиков в Диспетчерах
function Logic.get_dispatch_chests_count(platform)
    if not platform or not platform.surface then return 0 end
    local dispatchers = platform.surface.find_entities_filtered{name = CFG.DISPATCHER_NAME}
    local total = 0
    for _, d in ipairs(dispatchers) do
        local inv = d.get_inventory(defines.inventory.assembling_machine_output)
        if inv then total = total + inv.get_item_count(CFG.CHEST_ITEM) end
    end
    return total
end

-- Списание одного ящика
function Logic.consume_one_chest(platform)
    local dispatchers = platform.surface.find_entities_filtered{name = CFG.DISPATCHER_NAME}
    for _, d in ipairs(dispatchers) do
        local inv = d.get_inventory(defines.inventory.assembling_machine_output)
        if inv and inv.get_item_count(CFG.CHEST_ITEM) > 0 then
            inv.remove({name = CFG.CHEST_ITEM, count = 1})
            return true
        end
    end
    return false
end

-- Сброс груза с реальным подсчетом количества
function Logic.start_drop(player, platform, item_name, amount)
    if not Logic.consume_one_chest(platform) then
        player.print("♂️DROP REJECTED: NO DISPATCH CRATES♂️", {1,0,0})
        return 0 
    end

    local hub_inv = platform.hub.get_inventory(defines.inventory.hub_main)
    local available = hub_inv.get_item_count(item_name)
    local to_drop = math.min(available, amount)
    
    if to_drop <= 0 then return 0 end
    hub_inv.remove({name = item_name, count = to_drop})

    -- Координаты цели
    local offset_x = math.random(-CFG.DROP_RADIUS, CFG.DROP_RADIUS)
    local offset_y = math.random(-CFG.DROP_RADIUS, CFG.DROP_RADIUS)
    local target_pos = {x = player.position.x + offset_x, y = player.position.y + offset_y}
    local final_pos = player.surface.find_non_colliding_position(CFG.CHEST_ENTITY, target_pos, 15, 1) or target_pos
    
    -- РАНДОМИЗАЦИЯ УГЛА ПАДЕНИЯ
    local var_x = math.random(-15, 15) 
    local var_h = math.random(-20, 20)
    local start_pos = {
        x = final_pos.x + CFG.DROP_OFFSET_X + var_x, 
        y = final_pos.y - (CFG.DROP_HEIGHT + var_h)
    }
    
    local render_obj = rendering.draw_sprite{
        sprite = "entity/" .. CFG.CHEST_ENTITY, target = start_pos, surface = player.surface,
        x_scale = 0.5, y_scale = 0.5, render_layer = "higher-object-above"
    }

    storage.active_drops = storage.active_drops or {}
    table.insert(storage.active_drops, {
        render_obj = render_obj, current_pos = start_pos, target_pos = final_pos,
        surface = player.surface, item = item_name, count = to_drop, force = player.force
    })
    
    return to_drop -- Возвращаем реальное число для отчета
end

-- Обработка полета
function Logic.process_drops(tick)
    if not storage.active_drops or #storage.active_drops == 0 then return end
    for i = #storage.active_drops, 1, -1 do
        local drop = storage.active_drops[i]
        if drop.surface and drop.surface.valid then
            local dx, dy = drop.target_pos.x - drop.current_pos.x, drop.target_pos.y - drop.current_pos.y
            local dist = math.sqrt(dx*dx + dy*dy)
            if dist > CFG.DROP_SPEED then
                local r = CFG.DROP_SPEED / dist
                drop.current_pos.x, drop.current_pos.y = drop.current_pos.x + (dx * r), drop.current_pos.y + (dy * r)
                if drop.render_obj and drop.render_obj.valid then drop.render_obj.target = drop.current_pos end
                if tick % 2 == 0 then drop.surface.create_trivial_smoke{name = CFG.SMOKE_NAME, position = drop.current_pos} end
            else
                if drop.render_obj and drop.render_obj.valid then drop.render_obj.destroy() end
                local targets = drop.surface.find_entities_filtered{position = drop.target_pos, radius = CFG.IMPACT_RADIUS}
                for _, e in pairs(targets) do if e.valid and e.health then e.damage(CFG.IMPACT_DAMAGE, drop.force, "physical") end end
                local chest = drop.surface.create_entity{name = CFG.CHEST_ENTITY, position = drop.target_pos, force = drop.force}
                if chest then
                    chest.insert({name = drop.item, count = drop.count})
                    drop.surface.create_entity{name = "explosion", position = drop.target_pos}
                    drop.surface.create_entity{name = "medium-scorchmark", position = {x = drop.target_pos.x, y = drop.target_pos.y + CFG.DECAL_OFFSET_Y}}
                    drop.surface.play_sound{path = "utility/armor_insert", position = drop.target_pos}
                end
                table.remove(storage.active_drops, i)
            end
        else table.remove(storage.active_drops, i) end
    end
end

return Logic
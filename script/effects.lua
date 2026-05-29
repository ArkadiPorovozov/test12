local config = require("script.config")
local Effects = {}

-- ВНУТРЕННИЕ ФУНКЦИИ ЭФФЕКТОВ
local Handlers = {}

Handlers.stable = function(player, p_data)
    player.print("♂️TRANSFER STABLE♂️", {0, 1, 0})
end

Handlers.slow = function(player, p_data)
    player.print("♂️WARNING: BIOLOGICAL REJECTION DETECTED♂️", {1, 0.5, 0})
    p_data.slow_death_ticks = (config.SLOW_DEATH_DURATION + config.AGONY_DURATION) * 60
end

Handlers.rupture = function(player, p_data)
    player.print("♂️CRITICAL NEURAL RUPTURE♂️", {1, 0, 0})
    p_data.fatal_death_ticks = 180 
end

Handlers.spasm = function(player, p_data)
    player.print("♂️CRITICAL ERROR: NEURAL SPASM♂️", {1, 0, 0})
    p_data.spasm_stage = 1
    p_data.spasm_timer = 60
end

-- ВЫБОР СЛУЧАЙНОГО ЭФФЕКТА ПО ВЕСАМ
function Effects.apply_reincarnation_side_effects(player)
    local p_data = storage.players[player.index]
    
    -- Считаем общий вес всех шансов из конфига
    local total_weight = 0
    for _, weight in pairs(config.CHANCES) do
        total_weight = total_weight + weight
    end

    local roll = math.random(1, total_weight)
    local current = 0

    for id, weight in pairs(config.CHANCES) do
        current = current + weight
        if roll <= current then
            -- Вызываем функцию, имя которой совпало с ID в конфиге
            if Handlers[id] then
                Handlers[id](player, p_data)
            else
                Handlers.stable(player, p_data) -- Фолбэк
            end
            return
        end
    end
end

-- ОБРАБОТКА ТИКОВ (Без изменений, просто логика боли)
function Effects.process_tick(player, data, tick)
    local char = player.character
    if not char then return end

    if data.spasm_stage and data.spasm_timer then
        data.spasm_timer = data.spasm_timer - 1
        if data.spasm_timer <= 0 then
            if data.spasm_stage == 1 then
                char.surface.create_entity{name = "small-wriggler-die", position = char.position}
                data.spasm_stage = 2
                data.spasm_timer = 120
            elseif data.spasm_stage == 2 then
                char.surface.create_entity{name = "small-wriggler-die", position = char.position}
                char.damage(char.max_health * 0.5, "neutral", "poison")
                data.spasm_stage = 3
                data.spasm_timer = 120
            elseif data.spasm_stage == 3 then
                char.die("neutral")
                data.spasm_stage = nil
            end
        end
    end

    if data.fatal_death_ticks and data.fatal_death_ticks > 0 then
        if tick % 20 == 0 then char.surface.create_entity{name = "blood-explosion-small", position = char.position} end
        data.fatal_death_ticks = data.fatal_death_ticks - 1
        if data.fatal_death_ticks <= 0 then
            char.surface.create_entity{name = "blood-fountain", position = char.position}
            char.die("neutral")
        end
    end

    if data.slow_death_ticks and data.slow_death_ticks > 0 then
        local agony_ticks = config.AGONY_DURATION * 60
        if data.slow_death_ticks <= agony_ticks then
            if tick % 15 == 0 then char.surface.create_entity{name = "blood-explosion-small", position = char.position} end
            if tick % 60 == 0 then char.damage(config.AGONY_DAMAGE, "neutral", "poison") end
        else
            if tick % 90 == 0 then char.surface.create_entity{name = "blood-explosion-small", position = char.position} end
            if tick % 60 == 0 then char.damage(config.SLOW_DEATH_DAMAGE, "neutral", "poison") end
        end
        data.slow_death_ticks = data.slow_death_ticks - 1
        if data.slow_death_ticks <= 0 then
            char.surface.create_entity{name = "blood-fountain", position = char.position}
            char.die("neutral")
        end
    end
end

return Effects
local config = require("script.config")
local Effects = {}

local Handlers = {}
Handlers.stable = function(player) player.print({"big-niga.transfer-success"}, {0, 1, 0}) end
Handlers.slow = function(player, data)
    player.print({"big-niga.rejection-detected"}, {1, 0.5, 0})
    data.slow_death_ticks = (config.SLOW_DEATH_DURATION + config.AGONY_DURATION) * 60
end
Handlers.rupture = function(player, data)
    player.print({"big-niga.critical-rupture"}, {1, 0, 0})
    data.fatal_death_ticks = 180 
end
Handlers.spasm = function(player, data)
    player.print({"big-niga.critical-spasm"}, {1, 0, 0})
    data.spasm_stage, data.spasm_timer = 1, 60
end

function Effects.apply_reincarnation_side_effects(player)
    local p_data = storage.players[player.index]
    local total_weight = 0
    for _, w in pairs(config.CHANCES) do total_weight = total_weight + w end
    local roll, current = math.random(1, total_weight), 0
    for id, w in pairs(config.CHANCES) do
        current = current + w
        if roll <= current then Handlers[id](player, p_data) return end
    end
end

function Effects.process_tick(player, data, tick)
    local char = player.character
    if not char then return end
    if data.spasm_stage and data.spasm_timer then
        data.spasm_timer = data.spasm_timer - 1
        if data.spasm_timer <= 0 then
            if data.spasm_stage < 3 then char.surface.create_entity{name = "small-wriggler-die", position = char.position} end
            if data.spasm_stage == 1 then data.spasm_stage, data.spasm_timer = 2, 120
            elseif data.spasm_stage == 2 then 
                char.damage(char.max_health * 0.5, "neutral", "poison")
                data.spasm_stage, data.spasm_timer = 3, 120
            elseif data.spasm_stage == 3 then char.die(); data.spasm_stage = nil end
        end
    end
    if data.fatal_death_ticks and data.fatal_death_ticks > 0 then
        if tick % 20 == 0 then char.surface.create_entity{name = "blood-explosion-small", position = char.position} end
        data.fatal_death_ticks = data.fatal_death_ticks - 1
        if data.fatal_death_ticks <= 0 then char.surface.create_entity{name = "blood-fountain", position = char.position}; char.die() end
    end
    if data.slow_death_ticks and data.slow_death_ticks > 0 then
        local agony = config.AGONY_DURATION * 60
        if data.slow_death_ticks <= agony then
            if tick % 15 == 0 then char.surface.create_entity{name = "blood-explosion-small", position = char.position} end
            if tick % 60 == 0 then char.damage(config.AGONY_DAMAGE, "neutral", "poison") end
        else
            if tick % 90 == 0 then char.surface.create_entity{name = "blood-explosion-small", position = char.position} end
            if tick % 60 == 0 then char.damage(config.SLOW_DEATH_DAMAGE, "neutral", "poison") end
        end
        data.slow_death_ticks = data.slow_death_ticks - 1
        if data.slow_death_ticks <= 0 then char.die() end
    end
end
return Effects
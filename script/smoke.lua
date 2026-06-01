local config = require("script.config")
local Smoke = {}

function Smoke.register_radiator(entity)
    if not entity or not entity.valid then return end
    storage.radiators = storage.radiators or {}
    -- Проверяем, нет ли его уже в списке
    for _, r in ipairs(storage.radiators) do
        if r == entity then return end
    end
    table.insert(storage.radiators, entity)
end

function Smoke.update(tick)
    if tick % config.SMOKE_TICK_RATE ~= 0 then return end
    if not storage.radiators then return end

    for i = #storage.radiators, 1, -1 do
        local radiator = storage.radiators[i]
        if radiator and radiator.valid then
            -- Проверяем статус: работает ли машина (Working)
            if radiator.status == defines.entity_status.working then
                local pos = radiator.position
                -- ИСПОЛЬЗУЕМ СПЕЦИАЛЬНУЮ КОМАНДУ ДЛЯ ДЫМА
                radiator.surface.create_trivial_smoke{
                    name = config.SMOKE_NAME,
                    position = {
                        x = pos.x + config.SMOKE_OFFSET.x,
                        y = pos.y + config.SMOKE_OFFSET.y
                    }
                }
            end
        else
            table.remove(storage.radiators, i)
        end
    end
end

-- Функция для поиска уже построенных радиаторов
function Smoke.rescan_all()
    storage.radiators = {}
    for _, surface in pairs(game.surfaces) do
        local found = surface.find_entities_filtered{name = config.RADIATOR_NAME}
        for _, ent in ipairs(found) do
            Smoke.register_radiator(ent)
        end
    end
    game.print("♂️GYM RESCAN COMPLETE: " .. #storage.radiators .. " RADIATORS FOUND♂️")
end

return Smoke
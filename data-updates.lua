-- ============================================================================
-- ♂️DUNGEON MASTER'S PRECISE COLORING (NORMAL COLORS VERSION)♂️
-- ============================================================================

-- [[ ♂️COLOR DEFINITIONS♂️ ]]
local oo = "o.name"  -- Коричневый
local s  = "s.name"  -- Темно-синий (Железо)
local e  = "e.name"  -- Темно-красный
local pp = "p.name"  -- Пурпурный
local bb = "b.name"  -- Синий
local r  = "r.name"  -- Ярко-красный
local wb = "wb.name" -- Сине-голубой (Вода/Лёд)
local g  = "g.name"  -- Зеленый

-- [[ ♂️COLORED ROSTER♂️ ]]
local colored = {
    -- Железо / Сталь / Астероиды
    ["iron-bacteria"]  = s, ["iron-ore"]  = s, ["iron-plate"]   = s, ["steel-plate"]  = s,
    ["iron-stick"]  = s, ["iron-gear-wheel"]  = s, ["molten-iron"]  = s,
    ["thruster-oxidizer"]  = s, ["metallic-asteroid-chunk"]  = s,

    -- Вода / Аммиак / Лёд / Глеба-органика
    ["ammoniacal-solution"] = wb, ["ammonia"] = wb, ["ice"] = wb, ["ice-platform"] = wb,
    ["jellynut"] = wb, ["jellynut-seed"] = wb, ["oxide-asteroid-chunk"] = wb,

    -- Медь / Провода
    ["copper-ore"] = oo, ["copper-plate"] = oo, ["molten-copper"] = oo,
    ["copper-cable"] = oo, ["copper-bacteria"] = oo,

    -- Вольфрам / Электроника
    ["tungsten-ore"] = bb, ["tungsten-plate"] = bb, ["tungsten-carbide"] = bb,
    ["processing-unit"] = bb,

    -- Холмий / Скрап / Электролит
    ["scrap"] = pp, ["electrolyte"] = pp, ["holmium-plate"] = pp, ["holmium-solution"] = pp,

    -- Топливо / Масла / Кислота
    ["light-oil"] = oo, ["rocket-fuel"] = oo, ["sulfuric-acid"] = oo,
    ["low-density-structure"] = oo, ["yumako-mash"] = oo, ["thruster-fuel"] = oo,

    -- Юмако / Лава / Биофлакс
    ["yumako"] = r, ["bioflux"] = r, ["yumako-seed"] = r, ["lava"] = r,

    -- Схемы
    ["electronic-circuit"] = g, ["advanced-circuit"] = r,

    -- Уран / Органика (Green)
    ["uranium"] = g, ["jelly"] = g, ["pentapod-egg"] = g, ["biolubricant"] = g,
    ["uranium-ore"] = g, ["nuclear-fuel"] = g, ["uranium-238"] = g, ["uranium-235"] = g,
    ["uranium-fuel-cell"] = g, ["depleted-uranium-fuel-cell"] = g, ["lubricant"] = g,
}

local recipe_suffixes = {"", "-reprocessing", "-crushing", "-casting", "-smelting", "-cultivation", "-processing"}

-- [[ ♂️SURGICAL PAINT FUNCTION♂️ ]]
local function workout_paint(proto, name, template)
    if not proto then return end
    -- Используем оператор "?" для предотвращения крашей локализации
    local base_name = proto.localised_name or {
        "?", 
        {"item-name." .. name}, 
        {"entity-name." .. name}, 
        {"fluid-name." .. name},
        {"recipe-name." .. name},
        name
    }
    proto.localised_name = { template, base_name }
end

-- [[ ♂️WORKOUT START♂️ ]]

local item_types = {"item", "fluid", "capsule", "ammo", "gun", "tool", "armor", "module", "item-with-entity-data"}

for name, template in pairs(colored) do
    -- 1. Красим Предметы, Жидкости и прочих Slaves
    for _, type in ipairs(item_types) do
        if data.raw[type] and data.raw[type][name] then
            workout_paint(data.raw[type][name], name, template)
        end
    end

    -- 2. Красим Рецепты с учетом твоих суффиксов
    if data.raw.recipe then
        for _, suffix in ipairs(recipe_suffixes) do
            local rname = name .. suffix
            if data.raw.recipe[rname] then
                workout_paint(data.raw.recipe[rname], rname, template)
            end
        end
    end
end

-- Дополнительная проверка на рецепты (Catch-all по результату)
if data.raw.recipe then
    for r_name, recipe in pairs(data.raw.recipe) do
        local res = recipe.result
        if not res and recipe.results then
            local f = recipe.results[1]
            if f then res = f.name or f[1] end
        end
        
        if res and colored[res] then
            workout_paint(recipe, r_name, colored[res])
        end
    end
end
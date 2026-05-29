local Config = {
    TRANSFER_DURATION = 5,
    TRANSFER_COOLDOWN = 15,
    
    MAX_HUBS_PER_PLANET = 1,
    SERVER_BUILDING_NAME = "neural-server",

    -- ВИЗУАЛЬНЫЙ ЭФФЕКТ НА СЕРВЕРЕ
    -- Можно использовать: "utility/status_working", "utility/recharge_icon", "entity/character"
    SERVER_GHOST_SPRITE = "recharge_icon",
    SPRITE_SCALE = 1.5,
    SPRITE_OFFSET = {0, -2.5}, -- Немного поднял выше

    CHANCES = { stable = 70, slow = 20, rupture = 5, spasm = 5 },
    SLOW_DEATH_DAMAGE = 2,
    SLOW_DEATH_DURATION = 120,
    AGONY_DURATION = 10,
    AGONY_DAMAGE = 15,

    SOUND_START = "bn-transfer-start",
    SOUND_FINISH = "bn-transfer-success",
    SOUND_RUPTURE = "bn-rupture"
}
return Config
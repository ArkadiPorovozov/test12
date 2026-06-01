local Config = {
    TRANSFER_DURATION = 5,
    TRANSFER_COOLDOWN = 15,


    MAX_HUBS_PER_PLANET = 1,
    BODIES_PER_RADIATOR = 3,
    RADIATOR_RADIUS = 4.5,
    SERVER_BUILDING_NAME = "neural-server",
    RADIATOR_NAME = "neural-radiator",


    SMOKE_NAME = "turbine-smoke",
    SMOKE_OFFSET = {x = -0.5, y = -2.3},
    SMOKE_TICK_RATE = 10,

    CHANCES = { 
        stable = 70,
        slow = 10,
        rupture = 5,
        spasm = 5
    },

    SLOW_DEATH_DAMAGE = 2,
    SLOW_DEATH_DURATION = 120,
    AGONY_DURATION = 10,
    AGONY_DAMAGE = 15,

    SOUND_START = "bn-transfer-start",
    SOUND_FINISH = "bn-transfer-success",
    SOUND_RUPTURE = "bn-rupture"
}
return Config
-- src/core/Config.lua
local Config = {
    -- Aimbot
    SilentEnabled = false,
    SilentTeamCheck = true,
    SilentVisibleOnly = true,
    SilentTargetPart = "Head",
    SilentPriority = "Crosshair",
    SilentMaxDistance = 1200,
    SilentHitChance = 100,
    SilentFOV = 150,
    
    -- Trigger
    TriggerEnabled = false,
    TriggerMode = "Crosshair or FOV",
    TriggerDelay = 75,
    TriggerInterval = 0,
    TriggerMaxDistance = 1200,
    TriggerScopedOnly = false,
    
    -- Weapon Mods
    WeaponModsEnabled = false,
    WeaponSpreadEnabled = true,
    WeaponSpreadScale = 0,
    WeaponRecoilEnabled = true,
    WeaponRecoilScale = 0,
    WeaponKickEnabled = true,
    WeaponKickScale = 0,
    WeaponWallbang = false,
    WeaponPenetration = 50,
    WeaponAutomatic = false,
    
    -- Movement
    BunnyHopEnabled = false,
    BunnyHopMode = "Hold jump",
    BunnyHopMovingOnly = true,
    AntiAimEnabled = false,
    AntiAimMode = "Static",
    AntiAimYaw = 180,
    AntiAimJitter = 60,
    
    -- Visuals (Базовые, для примера)
    ESPEnabled = true,
    ESPBoxes = true,
    ESPNames = true,
    
    -- Misc
    MenuKey = "RightShift"
}

return Config

-- init.lua
local BASE_URL = "https://raw.githubusercontent.com/kiberp07-cmyk/hvh-bloxstrike-pasta/main/"
local REG = getgenv and getgenv() or _G

if REG.BloxStrike and REG.BloxStrike.State and REG.BloxStrike.State.Running then
    REG.BloxStrike.State:DisconnectAll()
end

-- Передаем Core внутрь модуля через ...
local function Load(name, path, Core)
    local success, code = pcall(function() return game:HttpGet(BASE_URL .. path) end)
    if not success then 
        warn("[BloxStrike] 404: " .. path)
        return nil 
    end
    local func, err = loadstring(code, "=" .. name)
    if not func then 
        warn("[BloxStrike] Error " .. name .. ": " .. err) 
        return nil 
    end
    return func(Core) -- Передаем таблицу как аргумент (...)
end

-- 1. Ядро
local Config = Load("Config", "src/core/Config.lua")
local State = Load("State", "src/core/State.lua")
local Utils = Load("Utils", "src/core/Utils.lua")

if not Config or not State or not Utils then
    warn("[BloxStrike] Core failed to load. Aborting.")
    return
end

local Core = { Config = Config, State = State, Utils = Utils }
REG.BloxStrike = Core

-- 2. Фичи
Core.Aim = Load("Aim", "src/features/Aim.lua", Core)
Core.Trigger = Load("Trigger", "src/features/Trigger.lua", Core)

print("[BloxStrike] Core, Aim & Trigger loaded!")

-- init.lua
local BASE_URL = "https://raw.githubusercontent.com/kiberp07-cmyk/hvh-bloxstrike-pasta/main/"
local REG = getgenv and getgenv() or _G

-- Очистка старой версии
if REG.BloxStrike and REG.BloxStrike.State and REG.BloxStrike.State.Running then
    REG.BloxStrike.State:DisconnectAll()
end

local function Load(name, path)
    local success, code = pcall(function() return game:HttpGet(BASE_URL .. path) end)
    if not success then return nil end
    local func, err = loadstring(code, "=" .. name)
    if not func then warn("[BloxStrike] Error " .. name .. ": " .. err) return nil end
    return func()
end

-- 1. Ядро
local Config = Load("Config", "src/core/Config.lua")
local State = Load("State", "src/core/State.lua")
local Utils = Load("Utils", "src/core/Utils.lua")

REG.BloxStrike = { Config = Config, State = State, Utils = Utils }

-- 2. Фичи
REG.BloxStrike.Aim = Load("Aim", "src/features/Aim.lua")

print("[BloxStrike] Core & Aim loaded!")

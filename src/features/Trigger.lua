-- src/features/Trigger.lua
local BloxStrike = _G.BloxStrike
local Config = BloxStrike.Config
local State = BloxStrike.State
local Utils = BloxStrike.Utils
local Aim = BloxStrike.Aim
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Trigger = { Ready = false, Pending = nil, NextShot = 0 }
local GetWeapon = nil

local function installTrigger()
    local ok = pcall(function()
        local storage = game:GetService("ReplicatedStorage")
        local module = require(storage.Components.Weapon)
        
        -- Получаем функцию текущего оружия
        GetWeapon = require(storage.Controllers.InventoryController).peekCurrentEquippedForMovement

        -- Хук на выстрел (чтобы триггербот мог подменить выстрел, если нужно)
        local originalShoot = module.shoot
        module.shoot = function(weapon, ...)
            if Trigger.Pending and Trigger.Pending.Weapon == weapon then
                local target = Aim.SelectTarget(workspace.CurrentCamera, workspace.CurrentCamera.CFrame.Position, 1000, true, true)
                if target then Trigger.ShotTarget = target end
            end
            local result = originalShoot(weapon, ...)
            Trigger.ShotTarget = nil
            return result
        end
        Trigger.Ready = true

        -- Главный цикл Триггербота
        State:Connect(RunService.Heartbeat, function()
            if not Config.TriggerEnabled then return end
            local now = os.clock()
            local weapon = GetWeapon()

            -- Проверяем, что оружие в руках, не перезаряжается и есть патроны
            if weapon and weapon.IsEquipped and not weapon.IsReloading and weapon.Rounds > 0 then
                
                -- Ищем врага через Aim.lua (true = только враги, true = рандомная часть тела)
                local target = Aim.SelectTarget(workspace.CurrentCamera, workspace.CurrentCamera.CFrame.Position, 1000, true, true)
                
                -- Если цель найдена и прошла задержка — стреляем
                if target and now >= Trigger.NextShot then
                    Trigger.NextShot = now + math.max(Config.TriggerInterval / 1000, 1/60)
                    Trigger.Pending = { Weapon = weapon, Character = target.Character }
                    
                    pcall(function() weapon:shoot() end)
                    
                    Trigger.Pending = nil
                end
            end
        end)
        print("[BloxStrike] Trigger Bot initialized.")
    end)
    if not ok then warn("[BloxStrike] Failed to hook Trigger Bot.") end
end

installTrigger()

return Trigger

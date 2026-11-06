-- src/features/Aim.lua
local BloxStrike = _G.BloxStrike
local Config = BloxStrike.Config
local State = BloxStrike.State
local Utils = BloxStrike.Utils
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Aim = { Ready = false, Target = nil, NextSelect = 0, Raycast = nil, GetRayIgnore = nil }
local AimParts = { "Head", "UpperTorso", "LowerTorso" }
local AimRandom = Random.new()

local function aimAllowed()
    return Aim.Ready and Config.SilentEnabled and Utils.MatchCharacter(LocalPlayer) ~= nil
end

local function selectAimTarget(camera, origin, maximumRange, randomizePart, enemiesOnly)
    if not aimAllowed() then return nil end
    local center = camera.ViewportSize * 0.5
    local limit = math.min(Config.SilentMaxDistance, maximumRange or math.huge)
    local candidates = {}
    local myTeam = Utils.TeamOf(LocalPlayer)
    local randomPart = Config.SilentTargetPart == "Random"

    for _, player in ipairs(Players:GetPlayers()) do
        local character = Utils.MatchCharacter(player)
        if character and player ~= LocalPlayer and (not (Config.SilentTeamCheck or enemiesOnly) or Utils.TeamOf(player) ~= myTeam) then
            local names = (Config.SilentTargetPart == "Closest" or randomPart) and AimParts or { Config.SilentTargetPart == "Chest" and "UpperTorso" or "Head" }
            for _, name in ipairs(names) do
                local part = character:FindFirstChild(name)
                if part and part:IsA("BasePart") then
                    local point, onScreen = camera:WorldToViewportPoint(part.Position)
                    local screen = Vector2.new(point.X, point.Y)
                    local radius = (screen - center).Magnitude
                    local distance = (part.Position - origin).Magnitude
                    if onScreen and point.Z > 0 and radius <= Config.SilentFOV and distance > 0.05 and distance <= limit then
                        local score = Config.SilentPriority == "Distance" and distance or radius
                        table.insert(candidates, { Player = player, Character = character, Part = part, Position = part.Position, Radius = radius, Score = score })
                    end
                end
            end
        end
    end
    table.sort(candidates, function(a, b) return a.Score < b.Score end)
    if #candidates > 0 then
        if randomizePart then return candidates[AimRandom:NextInteger(1, #candidates)] end
        return candidates[1]
    end
    return nil
end

local function installSilent()
    local ok = pcall(function()
        local storage = game:GetService("ReplicatedStorage")
        local bullet = require(storage.Components.Weapon.Classes.Bullet)
        Aim.Raycast = require(storage.Shared.Raycast)
        Aim.GetRayIgnore = require(storage.Components.Common.GetRayIgnore)
        
        Aim.Wrapper = function(self, spread, ...)
            local localShot = self.IsActive and not self.IsDestroyed and self.Weapon and self.Weapon.Player == LocalPlayer
            local shot = bullet._performRaycast(self, spread, ...)
            if not localShot or type(shot) ~= "table" then return shot end
            
            local target = selectAimTarget(workspace.CurrentCamera, shot.Origin, self.Properties.Range or 500, true, false)
            if target then
                local offset = target.Position - shot.Origin
                if offset.Magnitude > 0.05 then
                    local result = Aim.Raycast.cast(shot.Origin, offset.Unit * (self.Properties.Range or 500), nil, Aim.GetRayIgnore())
                    if result and result.instance then
                        shot.Direction = offset.Unit
                        shot.Hits = { { Position = result.position, Instance = result.instance, Normal = result.normal } }
                    end
                end
            end
            return shot
        end
        bullet._performRaycast = Aim.Wrapper
        Aim.Ready = true
        print("[BloxStrike] Silent Aim initialized.")
    end)
    if not ok then warn("[BloxStrike] Failed to hook Silent Aim.") end
end

installSilent()

-- Экспортируем функцию поиска цели для триггербота
Aim.SelectTarget = selectAimTarget

return Aim

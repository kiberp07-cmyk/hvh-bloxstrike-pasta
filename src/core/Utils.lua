-- src/core/Utils.lua
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local Utils = {}

function Utils.TeamOf(player)
    local name = player:GetAttribute("Team")
    if name == "Counter-Terrorists" or name == "Terrorists" then return name end
    return nil
end

function Utils.MatchCharacter(player)
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
        if char:GetAttribute("Dead") ~= true then return char end
    end
    return nil
end

function Utils.DecodeObject(value)
    if type(value) ~= "string" or value == "" then return nil end
    local ok, data = pcall(HttpService.JSONDecode, HttpService, value)
    if ok and type(data) == "table" then return data end
    return nil
end

return Utils

--=============================================================
--  Neverlose UI | Patched Wrapper
--  Adds: Keybind, Resize, Unload
--=============================================================

local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- 1. Загружаем библиотеку
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ImInsane-1337/neverlose-ui/refs/heads/main/source/library.lua"))()

-- 2. Создаем окно
local Window = Library:Window({ 
    Name = "BloxStrike", 
    SubName = "Patched Edition" 
})

-- =========================================================================
-- [ ФИКС 1: АНЛОАД ]
-- =========================================================================
local function UnloadScript()
    -- Ищем ScreenGui библиотеки и уничтожаем
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui:IsA("ScreenGui") and (gui.Name == "Neverlose" or gui.Name:find("Neverlose") or gui.Name:find("Library")) then
            gui:Destroy()
        end
    end
    -- Отключаем все хуки (если ты используешь State.Connections)
    if _G.BloxStrikeState and _G.BloxStrikeState.Connections then
        for _, c in ipairs(_G.BloxStrikeState.Connections) do
            pcall(function() c:Disconnect() end)
        end
    end
    print("[Neverlose UI] Unloaded.")
end

-- Пытаемся найти API для кнопки, если есть. Если нет — вешаем на клавишу End.
local successTab, MenuTab = pcall(function() return Window:Tab({ Name = "Settings" }) end)
if successTab and MenuTab then
    local successSec, MenuSec = pcall(function() return MenuTab:Section({ Name = "Menu" }) end)
    if successSec and MenuSec then
        pcall(function()
            MenuSec:Button({
                Name = "Unload Cheat",
                Callback = UnloadScript
            })
        end)
    end
end

-- Дополнительно вешаем бинд на клавишу End для выгрузки
UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.End then
        UnloadScript()
    end
end)

-- =========================================================================
-- [ ФИКС 2: БИНД МЕНЮ (ПОКАЗ/СКРЫТИЕ) ]
-- =========================================================================
local MenuOpen = true
local ToggleKey = Enum.KeyCode.RightShift

-- Пытаемся получить главный фрейм
local MainFrame = Window.Holder or Window.Frame or Window.MainFrame
if not MainFrame then
    -- Если библиотека не отдает фрейм напрямую, ищем его в CoreGui
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, child in pairs(gui:GetChildren()) do
                if child:IsA("Frame") and child.Name == "Main" then
                    MainFrame = child
                    break
                end
            end
        end
    end
end

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == ToggleKey then
        if MainFrame then
            MenuOpen = not MenuOpen
            MainFrame.Visible = MenuOpen
        else
            warn("[Neverlose UI] Main frame not found for toggle!")
        end
    end
end)

-- =========================================================================
-- [ ФИКС 3: РЕСАЙЗ ОКНА ]
-- =========================================================================
if MainFrame then
    -- Создаем невидимый хэндл в правом нижнем углу
    local resizeHandle = Instance.new("TextButton")
    resizeHandle.Name = "ResizeHandle"
    resizeHandle.Size = UDim2.new(0, 20, 0, 20)
    resizeHandle.Position = UDim2.new(1, -20, 1, -20)
    resizeHandle.BackgroundTransparency = 1
    resizeHandle.Text = ""
    resizeHandle.ZIndex = 10
    resizeHandle.Parent = MainFrame

    local dragging = false
    local startSize = nil
    local startMouse = nil

    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startSize = MainFrame.Size
            startMouse = input.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startMouse
            local newSizeX = math.max(300, startSize.X.Offset + delta.X) -- Минимальная ширина 300
            local newSizeY = math.max(200, startSize.Y.Offset + delta.Y) -- Минимальная высота 200
            
            MainFrame.Size = UDim2.new(startSize.X.Scale, newSizeX, startSize.Y.Scale, newSizeY)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

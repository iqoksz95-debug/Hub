-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyGui"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Создаем главное окно
local mainWindow = Instance.new("Frame")
mainWindow.Name = "MainWindow"
mainWindow.Size = UDim2.new(0, 350, 0, 300) -- Уменьшено
mainWindow.Position = UDim2.new(0.4, 0, 0.35, 0)
mainWindow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainWindow.BackgroundTransparency = 0.4
mainWindow.Active = true
mainWindow.Draggable = true
mainWindow.Parent = screenGui

-- Создаем заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "IqokczHub - Player"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.Parent = mainWindow

-- Закругление окна
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = mainWindow

-- Функция безопасного выполнения внешних скриптов
local function loadExternalScript(url)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if success then
        print("Script loaded successfully: " .. url)
    else
        warn("Failed to load script: " .. url .. " Error: " .. result)
    end
end

-- Создание кнопок
local function createButton(name, position, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.8, 0, 0, 40) -- Уменьшено
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = text
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 20 -- Уменьшено
    button.Parent = mainWindow
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

-- Добавляем кнопки обратно
createButton("EspButton", UDim2.new(0.1, 0, 0.2, 0), "Esp", function() loadExternalScript("https://raw.githubusercontent.com/iqoksz95-debug/Hub/refs/heads/main/MainEsp.lua") end)
createButton("FlyButton", UDim2.new(0.1, 0, 0.35, 0), "Fly", function() loadExternalScript("https://raw.githubusercontent.com/iqoksz95-debug/Hub/refs/heads/main/MainFly.lua") end)
createButton("SpeedButton", UDim2.new(0.1, 0, 0.5, 0), "Speed", function() loadExternalScript("https://raw.githubusercontent.com/iqoksz95-debug/Hub/refs/heads/main/MainSpeed.lua") end)
createButton("NoclipButton", UDim2.new(0.1, 0, 0.65, 0), "Noclip", function() loadExternalScript("https://raw.githubusercontent.com/iqoksz95-debug/Hub/refs/heads/main/MainNoclip.lua") end)
createButton("TeleportButton", UDim2.new(0.1, 0, 0.8, 0), "Teleport", function() loadExternalScript("https://raw.githubusercontent.com/iqoksz95-debug/Hub/refs/heads/main/MainTeleport.lua") end)

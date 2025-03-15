-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Создаем главное окно
local mainWindow = Instance.new("Frame")
mainWindow.Name = "MainWindow"
mainWindow.Size = UDim2.new(0, 250, 0, 250) -- Увеличена высота окна для размещения кнопок ниже
mainWindow.Position = UDim2.new(0.4, 0, 0.35, 0)
mainWindow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainWindow.BackgroundTransparency = 0.4
mainWindow.Active = true
mainWindow.Draggable = true
mainWindow.Parent = screenGui

-- Добавляем обводку к главному окну
local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 1
uiStroke.Color = Color3.fromRGB(255, 255, 255)
uiStroke.Parent = mainWindow

-- Создаем заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "IqokczHub - Player"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 18
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.Parent = mainWindow

-- Создаем линию
local line = Instance.new("Frame")
line.Name = "Line"
line.Size = UDim2.new(0.8, 0, 0, 1)
line.Position = UDim2.new(0.1, 0, 0.15, 0) 
line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
line.BorderSizePixel = 0
line.Parent = mainWindow

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
        print("Script loaded successfully")
    else
        warn("Failed to load script: Error")
    end
end

-- Создание кнопок
local function createButton(name, position, text, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0.8, 0, 0, 30) 
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = text
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    button.Parent = mainWindow
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = button
    
    -- Обработчик нажатия на кнопку
    button.MouseButton1Click:Connect(callback)
    
    -- Дополнительный скрипт: эффект изменения цвета при наведении и уходе курсора
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(0, 0, 255) 
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(40, 40, 40) 
    end)
    
    return button
end

-- Добавляем кнопки с промежутком в 2.5 см (0.1 по оси Y)
createButton("EspButton", UDim2.new(0.1, 0, 0.2, 0), "Esp", function() 
    loadExternalScript("https://raw.githubusercontent.com/iqoksz95-debug/Hub/refs/heads/main/MainEsp.lua") 
end)

createButton("FlyButton", UDim2.new(0.1, 0, 0.35, 0), "Fly", function() 
    loadExternalScript("https://raw.githubusercontent.com/iqoksz95-debug/Hub/refs/heads/main/MainFly.lua") 
end)

createButton("SpeedButton", UDim2.new(0.1, 0, 0.5, 0), "Speed", function() 
    loadExternalScript("https://raw.githubusercontent.com/iqoksz95-debug/Hub/refs/heads/main/MainSpeed.lua") 
end)

createButton("NoclipButton", UDim2.new(0.1, 0, 0.65, 0), "Noclip", function() 
    loadExternalScript("https://raw.githubusercontent.com/iqoksz95-debug/Hub/refs/heads/main/MainNoclip.lua") 
end)

createButton("TeleportButton", UDim2.new(0.1, 0, 0.8, 0), "Teleport", function() 
    loadExternalScript("https://raw.githubusercontent.com/iqoksz95-debug/Hub/refs/heads/main/MainTeleport.lua") 
end)

-- Бинд на скрытие и показ окна с анимацией
local userInputService = game:GetService("UserInputService")
local guiVisible = true
local tweenService = game:GetService("TweenService")

local function toggleMenu()
    guiVisible = not guiVisible
    local targetSize = guiVisible and UDim2.new(0, 250, 0, 250) or UDim2.new(0, 250, 0, 0)
    local targetPosition = guiVisible and UDim2.new(0.4, 0, 0.35, 0) or UDim2.new(0.4, 0, 0.35, -125)
    
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local tween = tweenService:Create(mainWindow, tweenInfo, {Size = targetSize, Position = targetPosition})
    tween:Play()
    
    mainWindow.Visible = true
    if not guiVisible then
        tween.Completed:Wait()
        mainWindow.Visible = false
    end
end

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.H then 
        toggleMenu()
    end
end)




-- Создаем ScreenGui
local MiniScreenGui = Instance.new("ScreenGui")
MiniScreenGui.Name = "MiniMenuGui"
MiniScreenGui.ResetOnSpawn = false
MiniScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Создаем маленькое меню
local miniMenu = Instance.new("Frame")
miniMenu.Name = "MiniMenu"
miniMenu.Size = UDim2.new(0, 100, 0, 50)
miniMenu.Position = UDim2.new(0, 20, 0.5, -75)
miniMenu.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
miniMenu.BackgroundTransparency = 0.4
miniMenu.Active = true
miniMenu.Draggable = true
miniMenu.Parent = MiniScreenGui

local MiniCorner = Instance.new("UICorner")
MiniCorner.CornerRadius = UDim.new(0, 4)
MiniCorner.Parent = miniMenu

-- Добавляем обводку к маленькому меню
local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 1 
uiStroke.Color = Color3.fromRGB(255, 255, 255)
uiStroke.Parent = miniMenu

-- Водяной знак "IqokczHub"
local watermark = Instance.new("TextLabel")
watermark.Name = "Watermark"
watermark.Size = UDim2.new(1, 0, 0, 20)
watermark.Position = UDim2.new(0, 0, 0, 5)
watermark.BackgroundTransparency = 1
watermark.Text = "IqokczHub"
watermark.TextColor3 = Color3.fromRGB(255, 255, 255)
watermark.Font = Enum.Font.SourceSansBold
watermark.TextSize = 18
watermark.TextXAlignment = Enum.TextXAlignment.Center
watermark.Parent = miniMenu

-- Белая линия 1 см
local miniline = Instance.new("Frame")
miniline.Name = "Line"
miniline.Size = UDim2.new(0.8, 0, 0, 1) 
miniline.Position = UDim2.new(0.1, 0, 0.5, 0) 
miniline.BackgroundColor3 = Color3.fromRGB(255, 255, 255) 
miniline.BorderSizePixel = 0
miniline.Parent = miniMenu

-- Кнопка "+"
local plusButton = Instance.new("TextButton")
plusButton.Name = "PlusButton"
plusButton.Size = UDim2.new(0.5, 0, 0, 20) 
plusButton.Position = UDim2.new(0.25, 0, 0.55, 0) 
plusButton.BackgroundTransparency = 1 
plusButton.TextColor3 = Color3.fromRGB(255, 255, 255)
plusButton.Text = "+"
plusButton.Font = Enum.Font.SourceSansBold
plusButton.TextSize = 20
plusButton.Parent = miniMenu

-- Функция для переключения видимости главного меню
local function toggleMainMenu()
    mainWindow.Visible = not mainWindow.Visible
end

-- Обработчик нажатия на кнопку "+"
plusButton.MouseButton1Click:Connect(toggleMainMenu)

-- Изначально маленькое меню видимо, главное меню скрыто
miniMenu.Visible = true
mainWindow.Visible = false

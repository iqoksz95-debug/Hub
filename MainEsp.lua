-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ESPGui"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Создаем главное окно
local mainWindow = Instance.new("Frame")
mainWindow.Name = "MainWindow"
mainWindow.Size = UDim2.new(0, 450, 0, 300)
mainWindow.Position = UDim2.new(0.35, 0, 0.3, 0)
mainWindow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainWindow.BackgroundTransparency = 0.4
mainWindow.Active = true
mainWindow.Draggable = true
mainWindow.Parent = screenGui

-- Закругление окна
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = mainWindow

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 10, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "IqokczHub - ESP"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainWindow

-- Кнопка закрытия окна "X"
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "X"
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 20
closeButton.Parent = mainWindow

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 4)
closeCorner.Parent = closeButton

closeButton.MouseEnter:Connect(function()
    closeButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
end)
closeButton.MouseLeave:Connect(function()
    closeButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
end)

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Поле для отображения статуса
local statusLabel = Instance.new("TextBox")
statusLabel.Size = UDim2.new(0.8, 0, 0, 50)
statusLabel.Position = UDim2.new(0.1, 0, 0.25, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.PlaceholderText = "ESP: Выключен"
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextSize = 24
statusLabel.Parent = mainWindow
statusLabel.TextEditable = false

-- Кнопка включения ESP
local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0.8, 0, 0, 50)
startButton.Position = UDim2.new(0.1, 0, 0.45, 0)
startButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startButton.Text = "Включить ESP"
startButton.Font = Enum.Font.SourceSansBold
startButton.TextSize = 20
startButton.Parent = mainWindow

startButton.MouseEnter:Connect(function()
    startButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
end)
startButton.MouseLeave:Connect(function()
    startButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
end)

-- Кнопка выключения ESP
local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0.8, 0, 0, 50)
stopButton.Position = UDim2.new(0.1, 0, 0.65, 0)
stopButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Text = "Выключить ESP"
stopButton.Font = Enum.Font.SourceSansBold
stopButton.TextSize = 20
stopButton.Parent = mainWindow

stopButton.MouseEnter:Connect(function()
    stopButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
end)
stopButton.MouseLeave:Connect(function()
    stopButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
end)


local espEnabled = false
local espColor = Color3.fromRGB(255, 0, 0) -- Красная обводка по умолчанию

local function applyESP(character)
    for _, part in ipairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            local highlight = Instance.new("Highlight")
            highlight.Parent = part
            highlight.FillTransparency = 1
            highlight.OutlineColor = espColor
            highlight.Name = "ESP"
        end
    end
end

local function createESP(player)
    if player ~= game.Players.LocalPlayer then
        if player.Character then
            applyESP(player.Character)
        end
        player.CharacterAdded:Connect(function(character)
            wait(0.5)
            applyESP(character)
        end)
    end
end

local function toggleESP(state)
    espEnabled = state
    if espEnabled then
        statusLabel.Text = "ESP: Включен"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        for _, player in ipairs(game.Players:GetPlayers()) do
            createESP(player)
        end
    else
        statusLabel.Text = "ESP: Выключен"
        statusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player.Character then
                for _, part in ipairs(player.Character:GetChildren()) do
                    if part:FindFirstChild("ESP") then
                        part.ESP:Destroy()
                    end
                end
            end
        end
    end
end

game.Players.PlayerAdded:Connect(createESP)
for _, player in ipairs(game.Players:GetPlayers()) do
    createESP(player)
end

startButton.MouseButton1Click:Connect(function()
    toggleESP(true)
end)

stopButton.MouseButton1Click:Connect(function()
    toggleESP(false)
end)

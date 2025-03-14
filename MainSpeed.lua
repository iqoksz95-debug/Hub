-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedGui"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Создаем главное окно
local mainWindow = Instance.new("Frame")
mainWindow.Name = "MainWindow"
mainWindow.Size = UDim2.new(0, 300, 0, 200)
mainWindow.Position = UDim2.new(0.5, -150, 0.5, -100)
mainWindow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainWindow.BackgroundTransparency = 0.4
mainWindow.Active = true
mainWindow.Draggable = true
mainWindow.Parent = screenGui

-- Закругление окна
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = mainWindow

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

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 10, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "IqokczHub - Speed"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainWindow

-- Поле для ввода скорости
local speedInput = Instance.new("TextBox")
speedInput.Size = UDim2.new(0.8, 0, 0, 30)
speedInput.Position = UDim2.new(0.1, 0, 0.25, 0)
speedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
speedInput.TextColor3 = Color3.fromRGB(255, 255, 255)
speedInput.PlaceholderText = "Введите скорость (16 - 300)"
speedInput.Font = Enum.Font.SourceSansBold
speedInput.TextSize = 18
speedInput.Parent = mainWindow

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 4)
inputCorner.Parent = speedInput

speedInput.MouseEnter:Connect(function()
    speedInput.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
end)
speedInput.MouseLeave:Connect(function()
    speedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
end)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

speedInput.FocusLost:Connect(function()
    local newSpeed = tonumber(speedInput.Text)
    if newSpeed and newSpeed >= 16 and newSpeed <= 300 then
        humanoid.WalkSpeed = newSpeed
    else
        speedInput.Text = "16 - 300"
    end
end)

-- Кнопка старта
local startButton = Instance.new("TextButton")
startButton.Size = UDim2.new(0.8, 0, 0, 30)
startButton.Position = UDim2.new(0.1, 0, 0.45, 0)
startButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startButton.Text = "Запустить скорость"
startButton.Font = Enum.Font.SourceSansBold
startButton.TextSize = 18
startButton.Parent = mainWindow

startButton.MouseEnter:Connect(function()
    startButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
end)
startButton.MouseLeave:Connect(function()
    startButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
end)

local startCorner = Instance.new("UICorner")
startCorner.CornerRadius = UDim.new(0, 4)
startCorner.Parent = startButton

startButton.MouseButton1Click:Connect(function()
    local newSpeed = tonumber(speedInput.Text)
    if newSpeed and newSpeed >= 16 and newSpeed <= 300 then
        humanoid.WalkSpeed = newSpeed
    else
        speedInput.Text = "16 - 300"
    end
end)

-- Кнопка остановки
local stopButton = Instance.new("TextButton")
stopButton.Size = UDim2.new(0.8, 0, 0, 30)
stopButton.Position = UDim2.new(0.1, 0, 0.65, 0)
stopButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Text = "Выключить скорость"
stopButton.Font = Enum.Font.SourceSansBold
stopButton.TextSize = 18
stopButton.Parent = mainWindow

stopButton.MouseEnter:Connect(function()
    stopButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
end)
stopButton.MouseLeave:Connect(function()
    stopButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
end)

stopButton.MouseButton1Click:Connect(function()
    humanoid.WalkSpeed = 16 -- стандартная скорость
end)

local stopCorner = Instance.new("UICorner")
stopCorner.CornerRadius = UDim.new(0, 4)
stopCorner.Parent = stopButton

-- Обработчик смерти игрока
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    humanoid.WalkSpeed = 16 -- Сбрасываем скорость при возрождении
end)

-- Меню сохраняется после смерти
screenGui.ResetOnSpawn = false
screenGui.Parent = game.CoreGui

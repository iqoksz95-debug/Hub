-- Создаем ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SpeedGui"
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Создаем главное окно
local mainWindow = Instance.new("Frame")
mainWindow.Name = "MainWindow"
mainWindow.Size = UDim2.new(0, 450, 0, 280)
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
titleLabel.Text = "IqokczHub - Teleport"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 20
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = mainWindow

-- Поле выбора игрока
local dropdown = Instance.new("Frame")
dropdown.Size = UDim2.new(0.8, 0, 0, 50)
dropdown.Position = UDim2.new(0.1, 0, 0.25, 0)
dropdown.BackgroundColor3 = Color3.fromRGB(128, 128, 128)
dropdown.BackgroundTransparency = 0.3
dropdown.Parent = mainWindow

dropdown.MouseEnter:Connect(function()
    dropdown.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
end)
dropdown.MouseLeave:Connect(function()
    dropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
end)

local selectedPlayer = Instance.new("TextButton")
selectedPlayer.Size = UDim2.new(1, 0, 1, 0)
selectedPlayer.BackgroundTransparency = 1
selectedPlayer.Text = "Выберите игрока"
selectedPlayer.TextColor3 = Color3.fromRGB(255, 255, 255)
selectedPlayer.Font = Enum.Font.SourceSansBold
selectedPlayer.TextSize = 24
selectedPlayer.Parent = dropdown

local playerList = Instance.new("ScrollingFrame")
playerList.Size = UDim2.new(1, 0, 1, 0.5)
playerList.Position = UDim2.new(0, 0, 1, 0)
playerList.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
playerList.BackgroundTransparency = 0.3
playerList.Visible = false
playerList.ZIndex = 10
playerList.Parent = dropdown
playerList.ScrollBarThickness = 6

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = playerList
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

selectedPlayer.MouseButton1Click:Connect(function()
    playerList.Visible = not playerList.Visible
end)

local function updatePlayerList()
    for _, child in ipairs(playerList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    local players = game.Players:GetPlayers()
    local playerCount = 0

    for _, player in ipairs(players) do
        if player ~= game.Players.LocalPlayer then
            playerCount = playerCount + 1
            local playerButton = Instance.new("TextButton")
            playerButton.Size = UDim2.new(1, 0, 0, 25)
            playerButton.Text = player.Name
            playerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            playerButton.Parent = playerList
            playerButton.ZIndex = 11

            playerButton.MouseButton1Click:Connect(function()
                selectedPlayer.Text = player.Name
                playerList.Visible = false
            end)
        end
    end
    
    playerList.CanvasSize = UDim2.new(0, 0, 0, playerCount * 30)
end

updatePlayerList()
game.Players.PlayerAdded:Connect(updatePlayerList)
game.Players.PlayerRemoving:Connect(updatePlayerList)

-- Кнопка телепортации
local teleportButton = Instance.new("TextButton")
teleportButton.Size = UDim2.new(0.8, 0, 0, 50)
teleportButton.Position = UDim2.new(0.1, 0, 0.45, 0)
teleportButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
teleportButton.Text = "Телепортироваться"
teleportButton.Font = Enum.Font.SourceSansBold
teleportButton.TextSize = 20
teleportButton.Parent = mainWindow

teleportButton.MouseEnter:Connect(function()
    teleportButton.BackgroundColor3 = Color3.fromRGB(0, 0, 255)
end)
teleportButton.MouseLeave:Connect(function()
    teleportButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
end)

teleportButton.MouseButton1Click:Connect(function()
    local targetPlayer = game.Players:FindFirstChild(selectedPlayer.Text)
    if targetPlayer and targetPlayer.Character and game.Players.LocalPlayer.Character then
        game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(targetPlayer.Character:GetPrimaryPartCFrame())
    end
end)

while true do
    updatePlayerList()
    wait(10)
end

-- Меню сохраняется после смерти
screenGui.ResetOnSpawn = false
screenGui.Parent = game.CoreGui

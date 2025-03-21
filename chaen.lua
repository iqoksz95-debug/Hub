local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()

Library:SetWatermarkVisibility(true)

local FrameTimer = tick()
local FrameCounter = 0
local FPS = 60

local WatermarkConnection = game:GetService('RunService').RenderStepped:Connect(function()
    FrameCounter += 1
    if (tick() - FrameTimer) >= 1 then
        FPS = FrameCounter
        FrameTimer = tick()
        FrameCounter = 0
    end
    Library:SetWatermark(('Chain Private | %s fps | %s ms'):format(
        math.floor(FPS),
        math.floor(game:GetService('Stats').Network.ServerStatsItem['Data Ping']:GetValue())
    ))
end)

local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({

    Title = 'Chain Private by Hellrey',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Main = Window:AddTab('Main'),
	Visual = Window:AddTab('Visual'),
	Misc = Window:AddTab('Misc'),
	Teleport = Window:AddTab('Teleport'),
	Items = Window:AddTab('Items'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

local LeftMain = Tabs.Main:AddLeftGroupbox('Main')
local RightMain = Tabs.Main:AddRightGroupbox('Player')
local LeftTeleport = Tabs.Teleport:AddLeftGroupbox('Teleports')
local LeftMisc = Tabs.Misc:AddLeftGroupbox('Misc')
local LeftVisual = Tabs.Visual:AddLeftGroupbox('Visuals')
local LeftItem = Tabs.Items:AddLeftGroupbox('Items')
local RightItem = Tabs.Items:AddRightGroupbox('Auto Give')



local infStaminaEnabled = false  -- Флаг включения функции
local staminaListener = nil  -- Переменная для обработчика событий

local function monitorStamina(character)
    if not character or not infStaminaEnabled then return end

    local stats = character:FindFirstChild("Stats")
    if not stats then
        stats = character:WaitForChild("Stats", 5) -- Ждем появления "Stats"
        if not stats then return end
    end

    local stamina = stats:FindFirstChild("Stamina")
    if not stamina then
        stamina = stats:WaitForChild("Stamina", 5) -- Ждем "Stamina"
        if not stamina then return end
    end

    -- Если раньше был обработчик, отключаем его перед созданием нового
    if staminaListener then
        staminaListener:Disconnect()
        staminaListener = nil
    end

    -- Следим за изменением выносливости и поддерживаем её на 100
    staminaListener = stamina.Changed:Connect(function()
        if infStaminaEnabled and stamina.Value ~= 100 then
            stamina.Value = 100
        end
    end)

    -- Устанавливаем значение сразу при респавне
    stamina.Value = 100
end

LeftMain:AddToggle('InfStamina', {
    Text = 'Inf Stamina',
    Default = false,
    Tooltip = 'Unlimited Stamina',
}):OnChanged(function(enabled)
    infStaminaEnabled = enabled -- Устанавливаем глобальный флаг

    local player = game.Players.LocalPlayer
    if not player then return end

    if enabled then
        -- Запускаем для текущего персонажа, если он есть
        if player.Character then
            monitorStamina(player.Character)
        end

        -- Следим за респавном персонажа
        player.CharacterAdded:Connect(monitorStamina)
    else
        -- Выключаем слежку
        if staminaListener then
            staminaListener:Disconnect()
            staminaListener = nil
        end
    end
end)


local combatStaminaEnabled = false  -- Флаг включения функции
local combatStaminaListener = nil  -- Переменная для обработчика событий

local function monitorCombatStamina(character)
    if not character or not combatStaminaEnabled then return end

    local stats = character:FindFirstChild("Stats")
    if not stats then
        stats = character:WaitForChild("Stats", 5) -- Ждем появления "Stats"
        if not stats then return end
    end

    local combatStamina = stats:FindFirstChild("CombatStamina")
    if not combatStamina then
        combatStamina = stats:WaitForChild("CombatStamina", 5) -- Ждем "CombatStamina"
        if not combatStamina then return end
    end

    -- Если раньше был обработчик, отключаем его перед созданием нового
    if combatStaminaListener then
        combatStaminaListener:Disconnect()
        combatStaminaListener = nil
    end

    -- Следим за изменением боевой выносливости и поддерживаем её на 100
    combatStaminaListener = combatStamina.Changed:Connect(function()
        if combatStaminaEnabled and combatStamina.Value ~= 100 then
            combatStamina.Value = 100
        end
    end)

    -- Устанавливаем значение сразу при респавне
    combatStamina.Value = 100
end

LeftMain:AddToggle('CombatStaminaToggle', {
    Text = 'Inf Combat Stamina',
    Default = false,
    Tooltip = 'Unlimited Combat Stamina',
}):OnChanged(function(enabled)
    combatStaminaEnabled = enabled -- Устанавливаем глобальный флаг

    local player = game.Players.LocalPlayer
    if not player then return end

    if enabled then
        -- Запускаем для текущего персонажа, если он есть
        if player.Character then
            monitorCombatStamina(player.Character)
        end

        -- Следим за респавном персонажа
        player.CharacterAdded:Connect(monitorCombatStamina)
    else
        -- Выключаем слежку
        if combatStaminaListener then
            combatStaminaListener:Disconnect()
            combatStaminaListener = nil
        end
    end
end)

local scrapContainer = game.Workspace.Misc.Zones.LootingItems.Scrap
local players = game:GetService("Players")

local function isPlayerInRange(scrap)
    if scrap.PrimaryPart then
        for _, player in ipairs(players:GetPlayers()) do
            if player.Character and player.Character.PrimaryPart then
                local distance = (player.Character.PrimaryPart.Position - scrap.PrimaryPart.Position).Magnitude
                if distance <= 9 then
                    return true
                end
            end
        end
    end
    return false
end

local function updateProximityPrompts()
    local children = scrapContainer:GetChildren()
    for i = 1, #children do
        local scrap = children[i]
        if scrap:IsA("Model") and scrap:FindFirstChild("Prompt") then
            local prompt = scrap.Prompt:FindFirstChildOfClass("ProximityPrompt")
            if prompt then
                prompt.MaxActivationDistance = 9

                if isPlayerInRange(scrap) then
                    if prompt.Enabled then
                        fireproximityprompt(prompt, 0)
                    end
                end
            else
                print("ProximityPrompt not found in " .. scrap.Name)
            end
        end
    end
end

local infClashEnabled = false  -- Флаг включения функции
local clashStrengthListener = nil  -- Переменная для обработчика событий

local function monitorClashStrength(character)
    if not character or not infClashEnabled then return end

    local stats = character:FindFirstChild("Stats")
    if not stats then
        stats = character:WaitForChild("Stats", 5) -- Ждем появления "Stats"
        if not stats then return end
    end

    local clashStrength = stats:FindFirstChild("ClashStrength")
    if not clashStrength then
        clashStrength = stats:WaitForChild("ClashStrength", 5) -- Ждем "ClashStrength"
        if not clashStrength then return end
    end

    -- Если раньше был обработчик, отключаем его перед созданием нового
    if clashStrengthListener then
        clashStrengthListener:Disconnect()
        clashStrengthListener = nil
    end

    -- Следим за изменением ClashStrength и поддерживаем его на 100
    clashStrengthListener = clashStrength.Changed:Connect(function()
        if infClashEnabled and clashStrength.Value ~= 100 then
            clashStrength.Value = 100
        end
    end)

    -- Устанавливаем значение сразу при респавне
    clashStrength.Value = 100
end

LeftMain:AddToggle('InfClash', {
    Text = 'Inf Clash',
    Default = false,
    Tooltip = 'Unlimited Clash Strength',
}):OnChanged(function(enabled)
    infClashEnabled = enabled -- Устанавливаем глобальный флаг

    local player = game.Players.LocalPlayer
    if not player then return end

    if enabled then
        -- Запускаем для текущего персонажа, если он есть
        if player.Character then
            monitorClashStrength(player.Character)
        end

        -- Следим за респавном персонажа
        player.CharacterAdded:Connect(monitorClashStrength)
    else
        -- Выключаем слежку
        if clashStrengthListener then
            clashStrengthListener:Disconnect()
            clashStrengthListener = nil
        end
    end
end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")

-- Создаем ScreenGui для меню
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScrapCounterGUI"
screenGui.ResetOnSpawn = false -- Отключаем сброс GUI при респауне
screenGui.Parent = PlayerGui
screenGui.Enabled = false -- Изначально отключаем меню

-- Создаем Frame для размещения меток
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 310) -- Размер фрейма с учетом заголовка
frame.Position = UDim2.new(1, -230, 0.5, -135) -- Позиция справа по центру экрана
frame.BackgroundTransparency = 0.5 -- Прозрачность фона
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Цвет фона
frame.Parent = screenGui

-- Функция для создания текстовых лейблов
local function createLabel(text, position, size, fontSize)
    local label = Instance.new("TextLabel")
    label.Size = size
    label.Position = position
    label.BackgroundTransparency = 0.5
    label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = fontSize
    label.Text = text
    label.Parent = frame
    return label
end

-- Создаем заголовок TextLabel для "Game Stats"
local titleLabel = createLabel("Game Stats:", UDim2.new(0, 10, 0, 10), UDim2.new(0, 200, 0, 50), 24)

-- Создаем остальные текстовые лейблы для отображения данных
local scrapLabel = createLabel("Scrap: 0", UDim2.new(0, 10, 0, 70), UDim2.new(0, 200, 0, 50), 20)
local powerLabel = createLabel("Power: 0%", UDim2.new(0, 10, 0, 130), UDim2.new(0, 200, 0, 50), 20)
local roundTimeLabel = createLabel("Round Time: 0:00", UDim2.new(0, 10, 0, 190), UDim2.new(0, 200, 0, 50), 20)
local pointsLabel = createLabel("Points: 0", UDim2.new(0, 10, 0, 250), UDim2.new(0, 200, 0, 50), 20)

-- Функция для обновления текста с количеством Scrap
local function updateScrapCount()
    local character = Workspace:FindFirstChild(LocalPlayer.Name)
    if character and character:FindFirstChild("Items") then
        local items = character.Items
        -- Проверяем атрибут Scrap
        if items:GetAttribute("Scrap") then
            local scrapAmount = items:GetAttribute("Scrap")
            -- Обновляем текст на лейбле
            scrapLabel.Text = "Scraps: " .. scrapAmount
        else
            scrapLabel.Text = "Scraps: 0"
        end
    end
end

-- Функция для обновления текста Power
local function updatePower()
    local gameValues = Workspace:FindFirstChild("GameStuff") and Workspace.GameStuff:FindFirstChild("Values")
    if gameValues and gameValues:GetAttribute("Power") then
        local powerAmount = gameValues:GetAttribute("Power") or 0
        -- Отображаем в процентах с одним знаком после запятой
        powerLabel.Text = "Power: " .. string.format("%.1f%%", powerAmount) 
    else
        powerLabel.Text = "Power: 0%"
    end
end

-- Функция для обновления текста RoundTime и IntermissionTime
local function updateRoundTime()
    local gameValues = Workspace:FindFirstChild("GameStuff") and Workspace.GameStuff:FindFirstChild("Values")
    if gameValues then
        local roundTimeAmount = gameValues:GetAttribute("RoundTime") or 0
        local intermissionTimeAmount = gameValues:GetAttribute("IntermissionTime") or 0
        
        -- Проверяем, какой атрибут активен
        if roundTimeAmount > 0 then
            -- Преобразуем RoundTime в минуты и секунды
            local minutes = math.floor(roundTimeAmount / 60)
            local seconds = roundTimeAmount % 60
            roundTimeLabel.Text = string.format("Round Time: %d:%02d", minutes, seconds) -- Формат MM:SS
        else
            -- Если RoundTime ноль или меньше, показываем IntermissionTime
            roundTimeLabel.Text = string.format("Round Time: %d:%02d", math.floor(intermissionTimeAmount / 60), intermissionTimeAmount % 60)
        end
    else
        roundTimeLabel.Text = "Round Time: 0:00"
    end
end

-- Функция для обновления текста Points
local function updatePoints()
    local playerStats = LocalPlayer:FindFirstChild("PlayerStats")
    if playerStats then
        -- Проверяем атрибут Points
        if playerStats:GetAttribute("Points") then
            local pointsAmount = playerStats:GetAttribute("Points")
            -- Обновляем текст на лейбле
            pointsLabel.Text = "Points: " .. pointsAmount
        else
            pointsLabel.Text = "Points: 0"
        end
    end
end

-- Подключаем обработчик изменений атрибута Scrap и Points
if Workspace:FindFirstChild(LocalPlayer.Name) then
    local items = Workspace[LocalPlayer.Name]:FindFirstChild("Items")
    if items then
        items:GetAttributeChangedSignal("Scrap"):Connect(updateScrapCount)
    end
    local stats = LocalPlayer:FindFirstChild("PlayerStats")
    if stats then
        stats:GetAttributeChangedSignal("Points"):Connect(updatePoints)
    end
end

-- Функция для обработки респауна персонажа
local function onCharacterRespawned()
    -- Повторно подписываемся на изменения атрибутов после респауна
    local character = Workspace:FindFirstChild(LocalPlayer.Name)
    if character then
        local items = character:FindFirstChild("Items")
        if items then
            items:GetAttributeChangedSignal("Scrap"):Connect(updateScrapCount)
        end
        local stats = character:FindFirstChild("Stats")
        if stats then
            stats:GetAttributeChangedSignal("Points"):Connect(updatePoints)
        end
    end
end

-- Слушаем событие респауна персонажа
LocalPlayer.CharacterAdded:Connect(function()
    -- Ждем, пока персонаж полностью загрузится
    repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Items")
    
    -- После респауна обновляем данные о скрапа и очках
    updateScrapCount()
    updatePoints()

    -- Подключаем обработчик изменений атрибутов
    local character = Workspace[LocalPlayer.Name]
    if character then
        local items = character:FindFirstChild("Items")
        if items then
            items:GetAttributeChangedSignal("Scrap"):Connect(updateScrapCount)
        end
        local stats = character:FindFirstChild("Stats")
        if stats then
            stats:GetAttributeChangedSignal("Points"):Connect(updatePoints)
        end
    end
end)

-- Обновляем Power и RoundTime при изменении атрибутов
local gameValues = Workspace:FindFirstChild("GameStuff") and Workspace.GameStuff:FindFirstChild("Values")
if gameValues then
    gameValues:GetAttributeChangedSignal("Power"):Connect(updatePower)
    gameValues:GetAttributeChangedSignal("RoundTime"):Connect(updateRoundTime)
    gameValues:GetAttributeChangedSignal("IntermissionTime"):Connect(updateRoundTime) -- Подключаем сигнал изменения для IntermissionTime
end

-- Первичная установка текста при запуске
updateScrapCount()
updatePower()
updateRoundTime()
updatePoints()

-- Добавляем переключатель для Scrap
LeftMain:AddToggle('GameStatsToggle', {
    Text = 'Status GUI',  -- Текст на переключателе
    Default = false,  -- Начальное состояние: скрыто
    Tooltip = 'You can toggle the visibility of the game stats UI.',  -- Подсказка

    Callback = function(Value)
        screenGui.Enabled = Value  -- Управление видимостью интерфейса
    end
})


local autoLootEnabled = false
local lootingCoroutine = nil

LeftMain:AddToggle('AutoLootScrap', {
    Text = 'Auto Collect Scrap',
    Default = false,
    Tooltip = 'Automatically collects scrap when in range.',
}):OnChanged(function(v)
    autoLootEnabled = v
    
    if autoLootEnabled then
        -- Запускаем цикл только если он не запущен
        if not lootingCoroutine then
            lootingCoroutine = task.spawn(function()
                while autoLootEnabled do
                    updateProximityPrompts()
                    task.wait(0.1)
                end
            end)
        end
    else
        -- Останавливаем цикл при отключении
        if lootingCoroutine then
            autoLootEnabled = false
            lootingCoroutine = nil
        end
    end
end)

local powerStation = game.Workspace.GameStuff.GameSections.POWERSTATION

local function getHitboxSafely()
    -- Попробуем найти Hitbox и игнорировать ошибку, если он не найден
    local hitbox = powerStation:FindFirstChild("Hitbox")
    if hitbox then
        return hitbox
    else
        return nil
    end
end

local function getAlertUISafely()
    -- Попробуем найти AlertUI и игнорировать ошибку, если он не найден
    local alertUI = powerStation:FindFirstChild("AlertUI")
    if alertUI then
        return alertUI:FindFirstChild("GUI")
    else
        return nil
    end
end

local hitbox = getHitboxSafely()
local alertUI = getAlertUISafely()

if not hitbox then
    -- Если Hitbox нет в зоне видимости, продолжаем работать, просто ждем
    print("Hitbox not found, waiting for it to load...")
end

if not alertUI then
    -- Если AlertUI нет в зоне видимости, продолжаем работать, просто ждем
    print("AlertUI not found, waiting for it to load...")
end

local prox = hitbox and hitbox:WaitForChild("ProximityPrompt", 5) -- Пытаемся найти ProximityPrompt
local gui = alertUI

if prox then
    local autoRepairEnabled = false
    local repairCoroutine = nil

    local function isPlayerInRange()
        for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
            if player.Character and player.Character.PrimaryPart then
                local distance = (player.Character.PrimaryPart.Position - hitbox.Position).Magnitude
                if distance <= 15 then  -- Если игрок в радиусе 15
                    return true
                end
            end
        end
        return false
    end

    local function activatePrompt()
        while autoRepairEnabled and prox.Enabled and not gui.Enabled and isPlayerInRange() do
            if prox.Parent then -- Игнорируем ошибку, если объект не существует
                fireproximityprompt(prox, 0)
            end
            task.wait(0.3)
        end
    end

    prox:GetPropertyChangedSignal("Enabled"):Connect(function()
        if prox.Enabled and not gui.Enabled and autoRepairEnabled and isPlayerInRange() then
            activatePrompt()
        end
    end)

    gui:GetPropertyChangedSignal("Enabled"):Connect(function()
        if not gui.Enabled and prox.Enabled and autoRepairEnabled and isPlayerInRange() then
            activatePrompt()
        end
    end)

    LeftMain:AddToggle('AutoRepairPower', {
        Text = 'Auto Repair Power',
        Default = false,
        Tooltip = 'Automatically repairs the power when the prompt is available.',
    }):OnChanged(function(v)
        autoRepairEnabled = v

        if autoRepairEnabled then
            -- Запускаем цикл, если он не запущен
            if not repairCoroutine then
                repairCoroutine = task.spawn(function()
                    if prox.Enabled and not gui.Enabled and isPlayerInRange() then
                        activatePrompt()
                    end
                end)
            end
        else
            -- Останавливаем цикл при отключении
            if repairCoroutine then
                autoRepairEnabled = false
                repairCoroutine = nil
            end
        end
    end)

    if prox.Enabled and not gui.Enabled and isPlayerInRange() then
        activatePrompt()
    end
else
    print("ProximityPrompt not found, waiting for it to load...")
end

local TextChatService = game:GetService("TextChatService")

-- Добавим Toggle для управления окном чата
LeftMain:AddToggle('ChatToggle', {
    Text = 'Toggle Chat Window',  -- Текст для переключателя
    Default = TextChatService.ChatWindowConfiguration.Enabled,  -- Устанавливаем начальное состояние на текущее состояние чата
    Tooltip = 'Enable or disable the chat window',  -- Подсказка при наведении
    Callback = function(Value)
        -- Включаем или отключаем окно чата в зависимости от состояния переключателя
        TextChatService.ChatWindowConfiguration.Enabled = Value
        print('[cb] Chat window toggled to:', Value)
    end
})


local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local espActive = false
local currentTarget = nil  -- Текущая модель CHAIN

-- Функция для добавления Highlight и текстовой информации над головой
local function addHighlightWithTextOnHead(targetInstance)
    if targetInstance:FindFirstChild("esplight") then
        return
    end

    local head = targetInstance:FindFirstChild("Head")
    if not head then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "esplight"
    highlight.FillColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineColor = Color3.fromRGB(0, 85, 255)
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.Parent = targetInstance

    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ChainText"
    billboardGui.Size = UDim2.new(0, 200, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.Adornee = head
    billboardGui.Parent = head

    billboardGui.AlwaysOnTop = true
    billboardGui.MaxDistance = 10000

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 28)
    container.BackgroundTransparency = 1

    local listlayout = Instance.new("UIListLayout")
    listlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listlayout.SortOrder = Enum.SortOrder.LayoutOrder

    local name = Instance.new("TextLabel")
    name.BackgroundTransparency = 1
    name.Font = Enum.Font.Nunito
    name.Size = UDim2.new(1, 0, 0, 14)
    name.Text = targetInstance.Name
    name.TextSize = 14
    name.TextStrokeTransparency = 0.5
    name.TextColor3 = Color3.fromRGB(255, 0, 0)
    name.Parent = container

    local data = Instance.new("TextLabel")
    data.BackgroundTransparency = 1
    data.Font = Enum.Font.Nunito
    data.Size = UDim2.new(1, 0, 0, 14)
    data.Text = "[0] [Anger: 0%] [Burst: 0%] [Choke: 100%]"
    data.TextSize = 12
    data.TextStrokeTransparency = 0.5
    data.TextColor3 = Color3.fromRGB(255, 255, 255)
    data.Parent = container

    listlayout.Parent = container
    container.Parent = billboardGui

    local function updateTextWithAttributes()
        local attributes = targetInstance:GetAttributes()
        local anger = attributes.Anger or 0
        local choke = attributes.ChokeMeter or 100
        local burst = attributes.Burst or 0
        data.Text = string.format("[Anger: %.1f%%] [Burst: %.1f%%] [Choke: %.1f%%]", anger, burst, choke)
    end

    updateTextWithAttributes()

    targetInstance:GetAttributeChangedSignal("Anger"):Connect(updateTextWithAttributes)
    targetInstance:GetAttributeChangedSignal("ChokeMeter"):Connect(updateTextWithAttributes)
    targetInstance:GetAttributeChangedSignal("Burst"):Connect(updateTextWithAttributes)
end

-- Функция для удаления ESP
local function removeESP(targetInstance)
    if not targetInstance then return end

    local highlight = targetInstance:FindFirstChild("esplight")
    if highlight then
        highlight:Destroy()
    end

    local head = targetInstance:FindFirstChild("Head")
    if head then
        local billboardGui = head:FindFirstChild("ChainText")
        if billboardGui then
            billboardGui:Destroy()
        end
    end
end

-- Функция для отслеживания модели CHAIN
local function trackChainModel()
    RunService.Heartbeat:Connect(function()
        local target = Workspace.Misc.AI:FindFirstChild("CHAIN")

        if target ~= currentTarget then
            if currentTarget then
                removeESP(currentTarget)
            end
            currentTarget = target
        end

        if espActive and currentTarget and not currentTarget:FindFirstChild("esplight") then
            addHighlightWithTextOnHead(currentTarget)
            -- Показываем уведомление, когда появляется новый CHAIN
            if currentTarget then
                Library:Notify("CHAIN model detected!", 2)
            end
        end
    end)
end

-- Добавление Toggle
LeftVisual:AddToggle("EspChainToggle", {
    Text = "Chain ESP",
    Default = false,
    Tooltip = "Toggle ESP for the CHAIN monster",
    Callback = function(Value)
        espActive = Value

        local target = Workspace.Misc.AI:FindFirstChild("CHAIN")
        if target then
            if espActive then
                addHighlightWithTextOnHead(target)
                -- Показываем уведомление при активации ESP
                Library:Notify("ESP for CHAIN activated!", 2)
            else
                removeESP(target)
                -- Уведомление при отключении ESP
                Library:Notify("ESP for CHAIN deactivated!", 2)
            end
        end
    end
})

-- Запуск отслеживания модели CHAIN
task.spawn(trackChainModel)

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local espActive = false

-- Функция для добавления ESP
local function addESP(player)
    if player == LocalPlayer or not player.Character then return end
    local character = player.Character
    local head = character:FindFirstChild("Head")
    if not head then return end

    -- Если ESP уже есть, не создаем дубликаты
    if head:FindFirstChild("PlayerESP") then return end

    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerESP"
    highlight.FillColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineColor = Color3.fromRGB(0, 255, 0)
    highlight.FillTransparency = 1
    highlight.OutlineTransparency = 0
    highlight.Parent = character

    -- BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PlayerESP"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Adornee = head
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 10000
    billboard.Parent = head

    -- Контейнер
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 28)
    frame.BackgroundTransparency = 1
    frame.Parent = billboard

-- Имя игрока
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 14)
    nameLabel.Position = UDim2.new(0, 0, 0, 0) -- Переместили вверх
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.Nunito
    nameLabel.TextSize = 14
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.Text = player.DisplayName -- Или player.Name
    nameLabel.Parent = frame

-- HP и расстояние
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, 0, 0, 14)
    infoLabel.Position = UDim2.new(0, 0, 0, 14) -- Сдвинули вниз, чтобы не накладывалось
    infoLabel.BackgroundTransparency = 1
    infoLabel.Font = Enum.Font.Nunito
    infoLabel.TextSize = 12
    infoLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    infoLabel.TextStrokeTransparency = 0.5
    infoLabel.Parent = frame


    -- Обновление текста
    local function updateInfo()
        if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
            local humanoid = character.Humanoid
            local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
                and (LocalPlayer.Character.HumanoidRootPart.Position - character.HumanoidRootPart.Position).Magnitude or 0
            infoLabel.Text = string.format("HP: %d | Distance: %.1f", humanoid.Health, distance)
        end
    end

    updateInfo()
    RunService.RenderStepped:Connect(updateInfo)
end

-- Удаление ESP
local function removeESP(player)
    if player.Character then
        local head = player.Character:FindFirstChild("Head")
        if head then
            local espGui = head:FindFirstChild("PlayerESP")
            if espGui then espGui:Destroy() end
        end
        
        local highlight = player.Character:FindFirstChild("PlayerESP")
        if highlight then highlight:Destroy() end
    end
end

-- Обновление ESP для всех игроков
local function updateESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if espActive then
            addESP(player)
        else
            removeESP(player)
        end
    end
end

-- Обработчик респавна игрока
local function onCharacterAdded(character)
    task.wait(1) -- Подождем, чтобы убедиться, что модель загрузилась
    if espActive then
        addESP(Players:GetPlayerFromCharacter(character))
    end
end

-- Подключение событий респавна
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(onCharacterAdded)
end)

for _, player in ipairs(Players:GetPlayers()) do
    player.CharacterAdded:Connect(onCharacterAdded)
end

-- Toggle ESP
LeftVisual:AddToggle("EspPlayerToggle", {
    Text = "Players ESP",
    Default = false,
    Tooltip = "Toggle ESP for all players",
    Callback = function(Value)
        espActive = Value
        updateESP()
    end
})

local players = game:GetService("Players")
local runService = game:GetService("RunService")
local localPlayer = players.LocalPlayer
local scrapFolder = workspace:FindFirstChild("Misc") 
    and workspace.Misc:FindFirstChild("Zones") 
    and workspace.Misc.Zones:FindFirstChild("LootingItems") 
    and workspace.Misc.Zones.LootingItems:FindFirstChild("Scrap")

if scrapFolder then
    local scrapList = {} -- Храним BillboardGui и Highlight, чтобы обновлять их в RenderStepped
    local espEnabled = false -- Переменная для отслеживания состояния toggle

    -- Создаём toggle с помощью LinoriaLib
    LeftVisual:AddToggle('ScrapToggle', { 
        Text = 'Scrap ESP',  -- Название кнопки
        Default = false,            -- Значение по умолчанию (выключено)
        Tooltip = 'Toggle the visibility of Scrap ESP',  -- Подсказка
        Callback = function(Value)
            espEnabled = Value
            if espEnabled then
                -- Создаем Highlight и BillboardGui только когда toggle включен
                for _, scrapModel in ipairs(scrapFolder:GetChildren()) do
                    if scrapModel:IsA("Model") then
                        local values = scrapModel:FindFirstChild("Values")
                        
                        -- Если Highlight ещё не был добавлен
                        if not scrapModel:FindFirstChild("Highlight") then
                            local highlight = Instance.new("Highlight")
                            highlight.Adornee = scrapModel
                            highlight.Parent = scrapModel
                            highlight.FillTransparency = 1
                            highlight.OutlineColor = Color3.fromRGB(0, 85, 255)
                        end

                        -- Если BillboardGui ещё не был добавлен
                        local billboard = scrapModel:FindFirstChild("ScrapBillboard")
                        if not billboard then
                            billboard = Instance.new("BillboardGui")
                            billboard.Name = "ScrapBillboard"
                            billboard.Size = UDim2.new(4, 0, 1, 0)
                            billboard.AlwaysOnTop = true
                            billboard.Enabled = false  -- Изначально скрываем BillboardGui
                            billboard.Parent = scrapModel
							billboard.StudsOffset = Vector3.new(0, 1, 0)  -- Поднимаем на 2 единицы по оси Y


                            local textLabel = Instance.new("TextLabel")
                            textLabel.Name = "ScrapText"
                            textLabel.Size = UDim2.new(1, 0, 1, 0)
                            textLabel.BackgroundTransparency = 1
                            textLabel.Font = Enum.Font.Nunito
                            textLabel.TextSize = 16
                            textLabel.TextColor3 = Color3.new(1, 1, 1)
                            textLabel.Text = "Scrap"  -- Добавим текст по умолчанию
                            textLabel.Parent = billboard
                        end

                        -- Проверяем атрибут Available и следим за ним
                        local function updateVisibility()
                            if values and values:GetAttribute("Available") ~= nil then
                                local isAvailable = values:GetAttribute("Available")
                                billboard.Enabled = isAvailable and espEnabled
                                scrapModel:FindFirstChild("Highlight").Enabled = isAvailable and espEnabled
                            else
                                billboard.Enabled = false -- Если Values нет, выключаем биллборд
                                scrapModel:FindFirstChild("Highlight").Enabled = false -- Отключаем Highlight
                            end
                        end

                        if values then
                            values:GetAttributeChangedSignal("Available"):Connect(updateVisibility)
                            updateVisibility() -- Устанавливаем правильную видимость при старте
                        end

                        -- Добавляем в список обновления
                        table.insert(scrapList, {model = scrapModel, label = billboard.ScrapText, highlight = scrapModel:FindFirstChild("Highlight")})
                    end
                end
            else
                -- Если toggle выключен, скрываем все BillboardGui и Highlight
                for _, scrapData in ipairs(scrapList) do
                    local billboard = scrapData.model:FindFirstChild("ScrapBillboard")
                    local highlight = scrapData.highlight
                    if billboard then
                        billboard.Enabled = false
                    end
                    if highlight then
                        highlight.Enabled = false
                    end
                end
            end
        end
    })

    -- Обновляем дистанцию в каждом кадре
    runService.RenderStepped:Connect(function()
        local character = localPlayer.Character
        if character then
            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if humanoidRootPart then
                for _, scrapData in ipairs(scrapList) do
                    local model = scrapData.model
                    local label = scrapData.label
                    local distance = math.floor((humanoidRootPart.Position - model:GetPivot().Position).Magnitude)
                    label.Text = string.format("Scrap\n%d m", distance)
                end
            end
        end
    end)
else
    warn("Папка Scrap не найдена")
end


local targets = {
    workspace.Misc.Zones.LootingItems.Artifacts:GetChildren()[4],
    workspace.Misc.Zones.LootingItems.Artifacts.Artifact,
    workspace.Misc.Zones.LootingItems.Artifacts:GetChildren()[2],
    workspace.Misc.Zones.LootingItems.Artifacts:GetChildren()[3]
}

-- Создаем переменную для хранения состояния ESP
local artifactEspEnabled = false

-- Функция для обновления текста на BillboardGui
local function updateText(targetInstance, statusLabel)
    local active = targetInstance:GetAttribute("Active")
    local canCollect = targetInstance:GetAttribute("CanCollect")

    -- Обновляем текст статуса и цвет
    if active and canCollect then
        statusLabel.Text = "Status: Active"
        statusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)  -- Зеленый цвет для активного
    else
        statusLabel.Text = "Status: Not Active"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)  -- Красный цвет для неактивного
    end
end

-- Функция для включения/отключения отображения BillboardGui
local function updateArtifactEsp()
    for _, targetInstance in ipairs(targets) do
        -- Найдем BillboardGui
        local billboardGui = targetInstance:FindFirstChild("ArtifactText")
        if billboardGui then
            -- Включаем/выключаем видимость BillboardGui
            billboardGui.Enabled = artifactEspEnabled
        end
    end
end

-- Функция для отправки уведомлений
local function sendArtifactNotification(targetInstance)
    local active = targetInstance:GetAttribute("Active")
    local canCollect = targetInstance:GetAttribute("CanCollect")

    if active and canCollect then
        Library:Notify("Artifact appeared!", 2)  -- Уведомление о появлении артефакта
    elseif not active and not canCollect then
        Library:Notify("Artifact collected!", 2)  -- Уведомление о том, что артефакт собран
    end
end

-- Создаем BillboardGui и TextLabel для каждого артефакта
for _, targetInstance in ipairs(targets) do
    -- Создаем BillboardGui
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ArtifactText"
    billboardGui.Size = UDim2.new(0, 200, 0, 50)  -- Устанавливаем размер для одного лейбла
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.AlwaysOnTop = true  -- Включаем AlwaysOnTop
    billboardGui.Parent = targetInstance
    billboardGui.Enabled = false

    -- Создаем первый TextLabel для имени артефакта (просто текст Artifact)
    local name = Instance.new("TextLabel")
    name.BackgroundTransparency = 1
    name.Font = Enum.Font.Nunito
    name.Size = UDim2.new(1, 0, 0, 14)
    name.TextSize = 14
    name.TextStrokeTransparency = 0.5
    name.TextColor3 = Color3.fromRGB(0, 85, 255)  -- По умолчанию красный
    name.Text = "Artifact"  -- Просто "Artifact", без изменений
    name.Parent = billboardGui

    -- Создаем второй TextLabel для статуса
    local statusLabel = Instance.new("TextLabel")
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.Nunito
    statusLabel.Size = UDim2.new(1, 0, 0, 14)
    statusLabel.Position = UDim2.new(0, 0, 0, 16)  -- Сдвигаем второй лейбл вниз
    statusLabel.TextSize = 14
    statusLabel.TextStrokeTransparency = 0.5
    statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)  -- По умолчанию красный
    statusLabel.Parent = billboardGui

    -- Изначальная установка текста статуса
    updateText(targetInstance, statusLabel)

    -- Обработчик события изменения атрибутов
    targetInstance:GetAttributeChangedSignal("Active"):Connect(function()
        updateText(targetInstance, statusLabel)
        sendArtifactNotification(targetInstance)
    end)
    targetInstance:GetAttributeChangedSignal("CanCollect"):Connect(function()
        updateText(targetInstance, statusLabel)
        sendArtifactNotification(targetInstance)
    end)
end

-- Добавляем Toggle для управления отображением
LeftVisual:AddToggle('Esp_Artifacts', {
    Text = 'Artifacts ESP', 
    Default = false,  -- По умолчанию выключен
    Tooltip = 'This toggles the ESP for artifacts.', 
    Callback = function(value)
        -- Обновляем состояние ESP
        artifactEspEnabled = value
        -- Обновляем отображение BillboardGui
        updateArtifactEsp()
    end
})


local MyButton1 = LeftTeleport:AddButton({
    Text = 'End map', 
    Func = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        humanoidRootPart.CFrame = CFrame.new(-391.510376, 3.94040155, -561.560974, -0.335028976, 0.0178718679, -0.942038298, -8.53516191e-09, 0.999820113, 0.0189680774, 0.942207813, 0.00635486376, -0.334968686)
    end,
    DoubleClick = false,
    Tooltip = 'Teleport to End map'
})

local MyButton2 = LeftTeleport:AddButton({
    Text = 'Radio station', 
    Func = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        humanoidRootPart.CFrame = CFrame.new(-381.520599, -113.735931, 42.9471855, -0.0306593683, -0.0237039384, -0.999248803, 2.74181366e-06, 0.999718785, -0.0237151701, 0.999529898, -0.000729829073, -0.030650679)
    end,
    DoubleClick = false,
    Tooltip = 'Teleport to Radio station'
})

local MyButton3 = LeftTeleport:AddButton({
    Text = 'Shop', 
    Func = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        humanoidRootPart.CFrame = CFrame.new(-113.171844, -85.9600906, 209.123428, -0.00369261508, -0.12829496, -0.9917292, -7.23150917e-09, 0.991735935, -0.128295839, 0.999993205, -0.000473739958, -0.00366209983)
    end,
    DoubleClick = false,
    Tooltip = 'Teleport to Shop'
})

local MyButton4 = LeftTeleport:AddButton({
    Text = 'House 1', 
    Func = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        humanoidRootPart.CFrame = CFrame.new(164.408112, -93.5687103, 228.658173, 0.99991262, 0.000353183481, -0.0132142855, 8.33566993e-09, 0.999642968, 0.0267184861, 0.0132190045, -0.0267161522, 0.999555647)
    end,
    DoubleClick = false,
    Tooltip = 'Teleport to House 1'
})

local MyButton5 = LeftTeleport:AddButton({
    Text = 'House 2', 
    Func = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        humanoidRootPart.CFrame = CFrame.new(-352.15683, -86.4282227, 281.471954, -0.344819665, 0.0217136368, -0.938417792, -4.52628512e-09, 0.999732435, 0.0231323708, 0.938668966, 0.00797650032, -0.344727397)
    end,
    DoubleClick = false,
    Tooltip = 'Teleport to House 2'
})

local MyButton6 = LeftTeleport:AddButton({
    Text = 'Power Station', 
    Func = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        humanoidRootPart.CFrame = CFrame.new(-207.976364, -109.483444, -86.5617981, 0.999895096, -0.000663155632, 0.014468275, 3.69048212e-06, 0.99896282, 0.045532573, -0.014483464, -0.0455277413, 0.998858094)
    end,
    DoubleClick = false,
    Tooltip = 'Teleport to Power Station'
})

local MyButton7 = LeftTeleport:AddButton({
    Text = 'Warehouse', 
    Func = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        humanoidRootPart.CFrame = CFrame.new(315.716339, -112.372467, -258.560028, -0.999726713, 5.74405785e-05, 0.0233771317, 8.75708484e-09, 0.99999696, -0.0024567449, -0.0233772025, -0.00245607318, -0.999723673)
    end,
    DoubleClick = false,
    Tooltip = 'Teleport to Warehouse'
})

local MyButton8 = LeftTeleport:AddButton({
    Text = 'Ritual', 
    Func = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        humanoidRootPart.CFrame = CFrame.new(-25.7088108, -106.319954, -199.117996, 0.970376134, -0.00883071404, -0.241437614, 3.57253812e-05, 0.999337018, -0.0364077166, 0.241599053, 0.0353205539, 0.969733119)
    end,
    DoubleClick = false,
    Tooltip = 'Teleport to Ritual'
})

local MyButton9 = LeftTeleport:AddButton({
    Text = 'Workshop', 
    Func = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        humanoidRootPart.CFrame = CFrame.new(171.005341, -101.835281, -30.2862396, 0.258823305, -0.00847451296, -0.965887487, -1.02627325e-06, 0.999961495, -0.0087737469, 0.96592468, 0.00227184128, 0.258813351)
    end,
    DoubleClick = false,
    Tooltip = 'Teleport to Workshop'
})

local MyButton = LeftMisc:AddButton({
    Text = 'Open Shop',
    Func = function()
        game.Players.LocalPlayer.PlayerGui.Ingame.Shop.Visible = true
    end,
    DoubleClick = false,
    Tooltip = 'Open the shop menu'
})

local MyButton2 = LeftMisc:AddButton({
    Text = 'Unlimited Ammo for All Guns',
    Func = function()
        local player = game.Players.LocalPlayer
        local char = workspace:FindFirstChild(player.Name)

        if char and char:FindFirstChild("Items") then
            local items = {"XSaw", "AK47", "Deagle", "DoubleBarrel", "M1911"}

            for _, itemName in ipairs(items) do
                local item = char.Items:FindFirstChild(itemName)
                if item then
                    if itemName == "XSaw" then
                        item:SetAttribute("Gas", 100)
                    else
                        item:SetAttribute("Ammo", 9999)
                    end
                end
            end
        end
    end,
    DoubleClick = false,
    Tooltip = 'Give unlimited ammo for all guns'
})

local MyButton3 = LeftMisc:AddButton({
    Text = 'Unlock All Shop Items',
    Func = function()
        local buyFrame = game:GetService("Players").LocalPlayer.PlayerGui.Ingame.Shop.MainFrame.SubSections.BuyFrame

        for _, item in ipairs({
            buyFrame.AK47, buyFrame.AKAmmo, buyFrame.BearTrap, buyFrame.BlueprintCombatKnife,
            buyFrame.BlueprintDoubleBarrel, buyFrame.BlueprintM1911, buyFrame.BlueprintMachete,
            buyFrame.BodyFlashLight, buyFrame.CombatKnife, buyFrame.Crucifix, buyFrame.Deagle,
            buyFrame.DoubleBarrel, buyFrame.EMF, buyFrame.EnergyDrink, buyFrame.FlareStick,
            buyFrame.Gas, buyFrame.Grenade, buyFrame.JackOMine, buyFrame.M1911, buyFrame.Machete,
            buyFrame.Medkit, buyFrame.Present, buyFrame.Radio, buyFrame.Scrap, buyFrame.StunGrenade,
            buyFrame.Tablet, buyFrame.Vest, buyFrame.Watch, buyFrame.XSaw
        }) do
            if item then item.Visible = true end
        end
    end,
    DoubleClick = false,
    Tooltip = 'Unlock all items in the shop'
})

local MyButton4 = LeftMisc:AddButton({
    Text = 'Open Server Teleport Menu',
    Func = function()
        local Players = game:GetService("Players")
        local TeleportService = game:GetService("TeleportService")
        local player = Players.LocalPlayer

        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Parent = player:WaitForChild("PlayerGui")

        local Frame = Instance.new("Frame")
        Frame.Size = UDim2.new(0, 300, 0, 150)
        Frame.Position = UDim2.new(0.5, -150, 0.5, -75)
        Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Frame.BackgroundTransparency = 0.5
        Frame.Parent = ScreenGui

        local Title = Instance.new("TextLabel")
        Title.Text = "Chain Server Joiner"
        Title.Size = UDim2.new(1, 0, 0, 30)
        Title.BackgroundTransparency = 1
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.Font = Enum.Font.SourceSansBold
        Title.TextSize = 20
        Title.Parent = Frame

        local CloseButton = Instance.new("TextButton")
        CloseButton.Text = "X"
        CloseButton.Size = UDim2.new(0, 30, 0, 30)
        CloseButton.Position = UDim2.new(1, -30, 0, 0)
        CloseButton.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        CloseButton.Parent = Frame

        local JobIdBox = Instance.new("TextBox")
        JobIdBox.Size = UDim2.new(0.8, 0, 0, 30)
        JobIdBox.Text = "Job id here"
        JobIdBox.Position = UDim2.new(0.1, 0, 0.4, 0)
        JobIdBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        JobIdBox.TextColor3 = Color3.fromRGB(255, 255, 255)
        JobIdBox.ClearTextOnFocus = false
        JobIdBox.Parent = Frame

        local JoinButton = Instance.new("TextButton")
        JoinButton.Text = "Join"
        JoinButton.Size = UDim2.new(0.5, 0, 0, 30)
        JoinButton.Position = UDim2.new(0.25, 0, 0.7, 0)
        JoinButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        JoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        JoinButton.Parent = Frame

        JoinButton.MouseButton1Click:Connect(function()
            local jobId = JobIdBox.Text
            if jobId ~= "" then
                TeleportService:TeleportToPlaceInstance(13977939077, jobId, player)
            end
        end)

        CloseButton.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
        end)
    end,
    DoubleClick = false,
    Tooltip = 'Open the server teleport menu to join another server'
})

local MyButton5 = LeftMisc:AddButton({
    Text = 'Teleport to Developer Test Server',
    Func = function()
        game:GetService("TeleportService"):Teleport(14695890495, game.Players.LocalPlayer)
    end,
    DoubleClick = false,
    Tooltip = 'Teleport to the developer test server'
})

local MyButton6 = LeftMisc:AddButton({
    Text = 'Get Quest for the Book',
    Func = function()
        local player = game.Players.LocalPlayer
        local workspace = game:GetService("Workspace")
        local camera = workspace.CurrentCamera
        local questNPC = workspace.Misc.NPCS.QuestNPC
        local serverStats = player:WaitForChild("PlayerStats"):WaitForChild("ServerStats")

        local targetPosition1 = Vector3.new(286.989136, -97.8781891, 159.619736)
        local targetRotation1 = CFrame.Angles(math.rad(180), math.rad(-78.71900177001953), math.rad(180))

        local function teleportAndActivatePrompt(targetPosition, targetRotation)
            local returnPosition = player.Character.HumanoidRootPart.Position
            local returnCFrame = player.Character.HumanoidRootPart.CFrame

            local invisiblePart = Instance.new("Part")
            invisiblePart.Size = Vector3.new(5, 1, 5)
            invisiblePart.Position = returnPosition
            invisiblePart.Anchored = true
            invisiblePart.CanCollide = true
            invisiblePart.Transparency = 1
            invisiblePart.Parent = workspace

            player.Character:SetPrimaryPartCFrame(CFrame.new(targetPosition) * targetRotation)

            wait(1)

            local hitbox = questNPC:FindFirstChild("Hitbox")
            if not hitbox then
                invisiblePart:Destroy()
                return
            end

            local prox = hitbox:FindFirstChild("ProximityPrompt")
            if not prox then
                invisiblePart:Destroy()
                return
            end

            if not prox.Enabled then
                prox.Enabled = true
            end

            camera.CFrame = CFrame.new(camera.CFrame.Position, hitbox.Position)

            local function setSurvivals(value)
                serverStats:SetAttribute("Survivals", value)
            end

            setSurvivals(5)

            wait(0.3)
            fireproximityprompt(prox, 0)
            wait(0.5)
            prox.Enabled = false

            wait(1)

            player.Character:SetPrimaryPartCFrame(returnCFrame)

            wait(3)
            invisiblePart:Destroy()
        end

        teleportAndActivatePrompt(targetPosition1, targetRotation1)
    end,
    DoubleClick = false,
    Tooltip = 'Get Quest for the Book'
})

local MyButton7 = LeftMisc:AddButton({
    Text = 'Aimbot [Press H]',
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/usumat300/Chain/refs/heads/main/aimbot.lua", true))()
    end,
    DoubleClick = false,
    Tooltip = 'Press H to toggle aimbot'
})

local MyButton9 = LeftMisc:AddButton({
    Text = 'Autofarm scrap',
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/usumat300/Chain/refs/heads/main/autofarm.lua", true))()
    end,
    DoubleClick = false,
    Tooltip = 'Base Farm'
})

local MyButton8 = LeftMisc:AddButton({
    Text = 'Unlock All Blueprints',
    Func = function()
        local player = game.Players.LocalPlayer
        local playerStats = player:WaitForChild("PlayerStats")
        local blueprints = playerStats:WaitForChild("Blueprints")
        
        -- Разблокировка всех чертежей
        blueprints:SetAttribute("45ACP", true)
        blueprints:SetAttribute("CombatKnife", true)
        blueprints:SetAttribute("Deagle", true)
        blueprints:SetAttribute("DoubleBarrel", true)
        blueprints:SetAttribute("M1911", true)
        blueprints:SetAttribute("Machete", true)
        blueprints:SetAttribute("Shells", true)
    end,
    DoubleClick = false,
    Tooltip = 'Unlock all blueprints for the player'
})


local MyButton10 = LeftMisc:AddButton({
    Text = 'Infinite Yield',
    Func = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end,
    DoubleClick = false,
    Tooltip = 'Load Infinite Yield script'
})

local MyButton = LeftMisc:AddButton({
    Text = 'No Fog / FullBright',
    Func = function()
        local Lighting = game:GetService("Lighting")
        
        -- Функция для удаления тумана
        local function removeFog()
            Lighting.FogEnd = 100000 -- Устанавливаем дальность тумана
            for i, v in pairs(Lighting:GetDescendants()) do
                if v:IsA("Atmosphere") then
                    v:Destroy() -- Удаляем все объекты типа Atmosphere
                end
            end
        end
        
        -- Функция для применения настроек освещения
        local function applyLightingSettings()
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
        
        -- Применяем настройки при нажатии
        removeFog()
        applyLightingSettings()
        
        -- Цикл, который будет каждые 8 секунд восстанавливать настройки освещения
        spawn(function()
            while true do
                applyLightingSettings()
                wait(8)
            end
        end)
    end,
    DoubleClick = false,
    Tooltip = 'No Fog and FullBright lighting'
})

local MyButton = RightMain:AddButton({
    Text = 'Reset',
    Func = function()
        local player = game.Players.LocalPlayer
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Health = 0 -- Force respawn by setting health to 0
        end
    end,
    DoubleClick = false,
    Tooltip = 'Click to reset your character (respawn)'
})


local MyButton1 = LeftItem:AddButton({
    Text = 'Give Crucifix',
    Func = function()
        local Player = game:GetService("Players").LocalPlayer
        local Inventory = Player.PlayerGui.Ingame.Inventory
        local slotNumbers = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }

        -- Check if there are any items in the inventory
        local hasItems = false
        for _, slot in ipairs(slotNumbers) do
            if Inventory:FindFirstChild(slot) then
                hasItems = true
                break
            end
        end

        if not hasItems then
            Library:Notify("You need at least one item first!", 3)
            return
        end

        -- Check if Crucifix already exists in the inventory
        for _, slot in ipairs(slotNumbers) do
            local item = Inventory:FindFirstChild(slot)
            if item and item:FindFirstChild("Values") and item.Values:FindFirstChild("ItemName") then
                if item.Values.ItemName.Value == "Crucifix" then
                    Library:Notify("Crucifix is already in your inventory!", 3)
                    return
                end
            end
        end

        -- Find an empty slot
        local freeSlot = nil
        for _, slot in ipairs(slotNumbers) do
            if not Inventory:FindFirstChild(slot) then
                freeSlot = slot
                break
            end
        end

        if not freeSlot then
            Library:Notify("No free slots in inventory!", 3)
            return
        end

        -- Clone a random item
        local itemToGive = nil
        for _, slot in ipairs(slotNumbers) do
            local item = Inventory:FindFirstChild(slot)
            if item then
                itemToGive = item:Clone()
                break
            end
        end

        if not itemToGive then
            Library:Notify("Item issuance failed!", 3)
            return
        end

        -- Add the item to inventory
        itemToGive.Parent = Inventory
        itemToGive.Name = freeSlot

        -- Set item name
        itemToGive.Values.ItemName.Value = "Crucifix"

        -- Change item icon
        itemToGive.Icon.Image = "rbxassetid://15903361925"

        -- Update slot number
        itemToGive.Number.Text = freeSlot

        Library:Notify("Item added to your inventory!", 3)
    end,
    DoubleClick = false,
    Tooltip = 'Gives a Crucifix in your inventory'
})

local MyButton2 = LeftItem:AddButton({
    Text = 'Give Double Barrel',
    Func = function()
        local Player = game:GetService("Players").LocalPlayer
        local Inventory = Player.PlayerGui.Ingame.Inventory
        local slotNumbers = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }

        -- Check if there are any items in the inventory
        local hasItems = false
        for _, slot in ipairs(slotNumbers) do
            if Inventory:FindFirstChild(slot) then
                hasItems = true
                break
            end
        end

        if not hasItems then
            Library:Notify("You need at least one item first!", 3)
            return
        end

        -- Check if Crucifix already exists in the inventory
        for _, slot in ipairs(slotNumbers) do
            local item = Inventory:FindFirstChild(slot)
            if item and item:FindFirstChild("Values") and item.Values:FindFirstChild("ItemName") then
                if item.Values.ItemName.Value == "DoubleBarrel" then
                    Library:Notify("Double Barrel is already in your inventory!", 3)
                    return
                end
            end
        end

        -- Find an empty slot
        local freeSlot = nil
        for _, slot in ipairs(slotNumbers) do
            if not Inventory:FindFirstChild(slot) then
                freeSlot = slot
                break
            end
        end

        if not freeSlot then
            Library:Notify("No free slots in inventory!", 3)
            return
        end

        -- Clone a random item
        local itemToGive = nil
        for _, slot in ipairs(slotNumbers) do
            local item = Inventory:FindFirstChild(slot)
            if item then
                itemToGive = item:Clone()
                break
            end
        end

        if not itemToGive then
            Library:Notify("Item issuance failed!", 3)
            return
        end

        -- Add the item to inventory
        itemToGive.Parent = Inventory
        itemToGive.Name = freeSlot

        -- Set item name
        itemToGive.Values.ItemName.Value = "DoubleBarrel"

        -- Change item icon
        itemToGive.Icon.Image = "rbxassetid://16190395023"

        -- Update slot number
        itemToGive.Number.Text = freeSlot

        Library:Notify("Item added to your inventory!", 3)
    end,
    DoubleClick = false,
    Tooltip = 'Gives a Double Barrel in your inventory'
})

local MyButton3 = LeftItem:AddButton({
    Text = 'Give Spell Book [He works]',
    Func = function()
        local Player = game:GetService("Players").LocalPlayer
        local Inventory = Player.PlayerGui.Ingame.Inventory
        local slotNumbers = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }

        -- Check if there are any items in the inventory
        local hasItems = false
        for _, slot in ipairs(slotNumbers) do
            if Inventory:FindFirstChild(slot) then
                hasItems = true
                break
            end
        end

        if not hasItems then
            Library:Notify("You need at least one item first!", 3)
            return
        end

        -- Check if Crucifix already exists in the inventory
        for _, slot in ipairs(slotNumbers) do
            local item = Inventory:FindFirstChild(slot)
            if item and item:FindFirstChild("Values") and item.Values:FindFirstChild("ItemName") then
                if item.Values.ItemName.Value == "SpellBook" then
                    Library:Notify("Spell Book is already in your inventory!", 3)
                    return
                end
            end
        end

        -- Find an empty slot
        local freeSlot = nil
        for _, slot in ipairs(slotNumbers) do
            if not Inventory:FindFirstChild(slot) then
                freeSlot = slot
                break
            end
        end

        if not freeSlot then
            Library:Notify("No free slots in inventory!", 3)
            return
        end

        -- Clone a random item
        local itemToGive = nil
        for _, slot in ipairs(slotNumbers) do
            local item = Inventory:FindFirstChild(slot)
            if item then
                itemToGive = item:Clone()
                break
            end
        end

        if not itemToGive then
            Library:Notify("Item issuance failed!", 3)
            return
        end

        -- Add the item to inventory
        itemToGive.Parent = Inventory
        itemToGive.Name = freeSlot

        -- Set item name
        itemToGive.Values.ItemName.Value = "SpellBook"

        -- Change item icon
        itemToGive.Icon.Image = "rbxassetid://15410543290"

        -- Update slot number
        itemToGive.Number.Text = freeSlot

        Library:Notify("Item added to your inventory!", 3)
    end,
    DoubleClick = false,
    Tooltip = 'The book itself works but the chain will run as usual since there is no model of the book lol'
})

local MyButton4 = LeftItem:AddButton({
    Text = 'Give Deagle',
    Func = function()
        local Player = game:GetService("Players").LocalPlayer
        local Inventory = Player.PlayerGui.Ingame.Inventory
        local slotNumbers = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }

        -- Check if there are any items in the inventory
        local hasItems = false
        for _, slot in ipairs(slotNumbers) do
            if Inventory:FindFirstChild(slot) then
                hasItems = true
                break
            end
        end

        if not hasItems then
            Library:Notify("You need at least one item first!", 3)
            return
        end

        -- Check if Crucifix already exists in the inventory
        for _, slot in ipairs(slotNumbers) do
            local item = Inventory:FindFirstChild(slot)
            if item and item:FindFirstChild("Values") and item.Values:FindFirstChild("ItemName") then
                if item.Values.ItemName.Value == "Deagle" then
                    Library:Notify("Deagle is already in your inventory!", 3)
                    return
                end
            end
        end

        -- Find an empty slot
        local freeSlot = nil
        for _, slot in ipairs(slotNumbers) do
            if not Inventory:FindFirstChild(slot) then
                freeSlot = slot
                break
            end
        end

        if not freeSlot then
            Library:Notify("No free slots in inventory!", 3)
            return
        end

        -- Clone a random item
        local itemToGive = nil
        for _, slot in ipairs(slotNumbers) do
            local item = Inventory:FindFirstChild(slot)
            if item then
                itemToGive = item:Clone()
                break
            end
        end

        if not itemToGive then
            Library:Notify("Item issuance failed!", 3)
            return
        end

        -- Add the item to inventory
        itemToGive.Parent = Inventory
        itemToGive.Name = freeSlot

        -- Set item name
        itemToGive.Values.ItemName.Value = "Deagle"

        -- Change item icon
        itemToGive.Icon.Image = "rbxassetid://15410404828"

        -- Update slot number
        itemToGive.Number.Text = freeSlot

        Library:Notify("Item added to your inventory!", 3)
    end,
    DoubleClick = false,
    Tooltip = 'Gives a Deagle in your inventory'
})

local MyButton5 = LeftItem:AddButton({
    Text = 'Give AK-47',
    Func = function()
        local Player = game:GetService("Players").LocalPlayer
        local Inventory = Player.PlayerGui.Ingame.Inventory
        local slotNumbers = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }

        -- Check if there are any items in the inventory
        local hasItems = false
        for _, slot in ipairs(slotNumbers) do
            if Inventory:FindFirstChild(slot) then
                hasItems = true
                break
            end
        end

        if not hasItems then
            Library:Notify("You need at least one item first!", 3)
            return
        end

        -- Check if Crucifix already exists in the inventory
        for _, slot in ipairs(slotNumbers) do
            local item = Inventory:FindFirstChild(slot)
            if item and item:FindFirstChild("Values") and item.Values:FindFirstChild("ItemName") then
                if item.Values.ItemName.Value == "AK47" then
                    Library:Notify("AK is already in your inventory!", 3)
                    return
                end
            end
        end

        -- Find an empty slot
        local freeSlot = nil
        for _, slot in ipairs(slotNumbers) do
            if not Inventory:FindFirstChild(slot) then
                freeSlot = slot
                break
            end
        end

        if not freeSlot then
            Library:Notify("No free slots in inventory!", 3)
            return
        end

        -- Clone a random item
        local itemToGive = nil
        for _, slot in ipairs(slotNumbers) do
            local item = Inventory:FindFirstChild(slot)
            if item then
                itemToGive = item:Clone()
                break
            end
        end

        if not itemToGive then
            Library:Notify("Item issuance failed!", 3)
            return
        end

        -- Add the item to inventory
        itemToGive.Parent = Inventory
        itemToGive.Name = freeSlot

        -- Set item name
        itemToGive.Values.ItemName.Value = "AK47"

        -- Change item icon
        itemToGive.Icon.Image = "rbxassetid://17812936812"

        -- Update slot number
        itemToGive.Number.Text = freeSlot

        Library:Notify("Item added to your inventory!", 3)
    end,
    DoubleClick = false,
    Tooltip = 'Gives a AK in your inventory'
})

local autoGiveEnabled = false

RightItem:AddToggle('AutoGiveCrucifix', { 
    Text = 'Auto Give Crucifix', 
    Default = false, 
    Tooltip = 'Automatically gives Crucifix while enabled.',

    Callback = function(Value)
        autoGiveEnabled = Value

        if autoGiveEnabled then
            task.spawn(function()
                while autoGiveEnabled do
                    -- Call the function to give Crucifix
                    GiveCrucifix()

                    -- Wait before giving another one (adjust as needed)
                    task.wait(5) -- Adjust the delay if necessary
                end
            end)
        end
    end
})

function GiveCrucifix()
    local Player = game:GetService("Players").LocalPlayer
    local Inventory = Player.PlayerGui.Ingame.Inventory
    local slotNumbers = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }

    -- Check if Crucifix is already in inventory
    for _, slot in ipairs(slotNumbers) do
        local item = Inventory:FindFirstChild(slot)
        if item and item:FindFirstChild("Values") and item.Values:FindFirstChild("ItemName") then
            if item.Values.ItemName.Value == "Crucifix" then
                return -- Stop here, no notification, no duplicate
            end
        end
    end

    -- Find an empty slot
    local freeSlot = nil
    for _, slot in ipairs(slotNumbers) do
        if not Inventory:FindFirstChild(slot) then
            freeSlot = slot
            break
        end
    end

    if not freeSlot then
        Library:Notify("No free slots in inventory!", 3)
        return
    end

    -- Clone a random item
    local itemToGive = nil
    for _, slot in ipairs(slotNumbers) do
        local item = Inventory:FindFirstChild(slot)
        if item then
            itemToGive = item:Clone()
            break
        end
    end

    if not itemToGive then
        Library:Notify("Item issuance failed!", 3)
        return
    end

    -- Add the item to inventory
    itemToGive.Parent = Inventory
    itemToGive.Name = freeSlot

    -- Set item name
    itemToGive.Values.ItemName.Value = "Crucifix"

    -- Change item icon
    itemToGive.Icon.Image = "rbxassetid://15903361925"

    -- Update slot number
    itemToGive.Number.Text = freeSlot

    Library:Notify("Item added to your inventory!", 3)
end

-- Функция для изменения скорости анимации
local function adjustAnimationSpeed(speed)
    local function speedUpAnimations(folder, speed)
        for _, item in ipairs(folder:GetChildren()) do
            if item:IsA("Animation") then
                local animator = item:FindFirstChildOfClass("Animator")
                if animator then
                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                        track:AdjustSpeed(speed)
                    end
                end
            elseif item:IsA("Folder") then
                speedUpAnimations(item, speed)
            end
        end
    end

    local folders = {
        game:GetService("ReplicatedStorage").PlayerAnims,
        game:GetService("ReplicatedStorage").SituationalAnims,
        game:GetService("ReplicatedStorage").GameStuff.Animations,
        game:GetService("ReplicatedStorage").GameStuff.ItemAnimations,
    }

    for _, folder in ipairs(folders) do
        speedUpAnimations(folder, speed)
    end

    local player = game.Players.LocalPlayer
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid")

        -- Функция для изменения скорости анимации
        local function speedUpCharacterAnimations()
            for _, animationTrack in ipairs(humanoid:GetPlayingAnimationTracks()) do
                animationTrack:AdjustSpeed(speed)
            end
        end

        -- Первоначальная настройка скорости анимаций
        speedUpCharacterAnimations()

        -- Когда анимация начинается, корректируем её скорость
        humanoid.AnimationPlayed:Connect(function(animationTrack)
            animationTrack:AdjustSpeed(speed)
        end)

        -- Когда персонаж умирает, восстанавливаем скорость анимаций
        humanoid.Died:Connect(function()
            character:WaitForChild("HumanoidRootPart")
            speedUpCharacterAnimations()
        end)

        -- Добавим отслеживание движения персонажа для изменения скорости
        humanoid.Running:Connect(function(speed)
            -- Обновление скорости анимаций, если персонаж двигается
            if _G.isToggleEnabled then
                for _, animationTrack in ipairs(humanoid:GetPlayingAnimationTracks()) do
                    animationTrack:AdjustSpeed(_G.speedValue)
                end
            end
        end)
    end

    -- Подключение функции к событию добавления персонажа
    player.CharacterAdded:Connect(onCharacterAdded)

    -- Если персонаж уже существует, применяем настройки
    if player.Character then
        onCharacterAdded(player.Character)
    end
end

-- Изначальная скорость анимаций
_G.speedValue = 70
_G.isToggleEnabled = false

-- Добавляем Toggle
RightMain:AddToggle('SpeedToggle', {
    Text = 'Enable Speed Up Animations',
    Default = false, -- Значение по умолчанию установлено в false (отключено)
    Tooltip = 'Toggle to enable/disable animation speed up', -- Подсказка при наведении на переключатель

    Callback = function(Value)
        _G.isToggleEnabled = Value
        if Value then
            -- Если toggle включен, увеличиваем скорость анимации
            adjustAnimationSpeed(_G.speedValue)
        else
            -- Если toggle выключен, сбрасываем скорость на 1
            adjustAnimationSpeed(1)
        end
    end
})

-- Добавляем слайдер для регулировки скорости
RightMain:AddSlider('SpeedSlider', {
    Text = "Adjust Speed",  -- Текст слайдера
    Default = 70,           -- Значение по умолчанию
    Min = 1,                -- Минимальное значение
    Max = 100,              -- Максимальное значение
    Suffix = "x",           -- Суффикс (например, "x" для умножения)
    Rounding = 1,           -- Округление до 1 знака
    Compact = false,        -- Сделать слайдер компактным (необходимо ли? false = нет)
    HideMax = false,        -- Скрывать ли максимальное значение
    Callback = function(value)
        _G.speedValue = value
        if _G.isToggleEnabled then
            adjustAnimationSpeed(value)
        end
    end
})

-- Устанавливаем начальную скорость анимации
adjustAnimationSpeed(1)  -- Изначально скорость 1, если toggle выключен


-- Ui Settings
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)

MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)

SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

ThemeManager:SetFolder('ReyWave')
SaveManager:SetFolder('ReyWave/specific-game')

SaveManager:BuildConfigSection(Tabs['UI Settings'])

ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()

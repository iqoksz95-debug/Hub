local Decimals = 4
local Clock = os.clock()
local ValueText = "Value Is Now :"

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/usumat300/Chain/refs/heads/main/lib"))({
    cheatname = "ReyWare", -- watermark text
    gamename = "Chain", -- watermark text
})

library:init()

local Window1 = library.NewWindow({
    title = "ReyWare | Chain", -- Mainwindow Text
    size = UDim2.new(0, 510, 0.6, 6)
})

local Tab1 = Window1:AddTab("  Main  ")
local Tab2 = Window1:AddTab("  Esp  ")
local Tab3 = Window1:AddTab("  Teleport  ")
local SettingsTab = library:CreateSettingsTab(Window1)

local Section1 = Tab1:AddSection("Main", 1)
local Section2 = Tab1:AddSection("Misc", 2)
local Section3 = Tab2:AddSection("Esp", 1)
local Section4 = Tab3:AddSection("Locations", 1)

-- Переменная для управления состоянием цикла "Inf Stamina"
local infStaminaEnabled = false
-- Переменная для управления состоянием цикла "Combat Stamina"
local combatStaminaEnabled = false
local espEnabled = false

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

local autoLootEnabled = false
local lootingCoroutine = nil

Section1:AddToggle({
    text = "Auto Collect Scrap",
    state = false,
    risky = false,
    tooltip = "tooltip1",
    flag = "Toggle_AutoLootScrap",
    callback = function(v)
        autoLootEnabled = v
        
        if autoLootEnabled then
            -- Запускаем цикл только если он не запущен
            if not lootingCoroutine then
                lootingCoroutine = coroutine.create(function()
                    while autoLootEnabled do
                        updateProximityPrompts()
                        task.wait(0.1)
                    end
                end)
                coroutine.resume(lootingCoroutine)
            end
        else
            -- Останавливаем цикл при отключении
            if lootingCoroutine then
                autoLootEnabled = false
                lootingCoroutine = nil
            end
        end
    end
})

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

    Section1:AddToggle({
        text = "Auto Repair Power",
        state = false,
        risky = false,
        tooltip = "Automatically repairs the power when the prompt is available.",
        flag = "Toggle_AutoRepairPower",
        callback = function(v)
            autoRepairEnabled = v

            if autoRepairEnabled then
                -- Запускаем цикл, если он не запущен
                if not repairCoroutine then
                    repairCoroutine = coroutine.create(function()
                        if prox.Enabled and not gui.Enabled and isPlayerInRange() then
                            activatePrompt()
                        end
                    end)
                    coroutine.resume(repairCoroutine)
                end
            else
                -- Останавливаем цикл при отключении
                if repairCoroutine then
                    autoRepairEnabled = false
                    repairCoroutine = nil
                end
            end
        end
    })

    if prox.Enabled and not gui.Enabled and isPlayerInRange() then
        activatePrompt()
    end
else
    print("ProximityPrompt not found, waiting for it to load...")
end


-- Toggle для Inf Stamina
Section1:AddToggle({
    text = "Inf Stamina",
    state = false,
    tooltip = "Toggle Infinite Stamina",
    flag = "Inf_Stamina_Toggle",
    callback = function(enabled)
        infStaminaEnabled = enabled -- Устанавливаем глобальный флаг для работы цикла
        if enabled then
            infStaminaThread = coroutine.create(function()
                local player = game.Players.LocalPlayer -- Получаем текущего игрока
                while infStaminaEnabled do -- Проверяем состояние переменной
                    if player and player.Character and player.Character:FindFirstChild("Stats") and player.Character.Stats:FindFirstChild("Stamina") then
                        player.Character.Stats.Stamina.Value = 100
                    end
                    wait(3.5) -- Пауза между обновлениями
                end
            end)
            coroutine.resume(infStaminaThread)
        end
    end
})

local bearTrapCycleActive = false  -- Для управления циклом BearTrapPlaced
local jackOCycleActive = false     -- Для управления циклом JackOPlaced

-- Toggle для BearTrapPlaced
Section1:AddToggle({
    text = "No CD BearTrap",
    state = false,
    risky = false,
    tooltip = "you can bet as much as you want lol",
    flag = "Toggle_BearTrapPlaced",
    callback = function(v)
        bearTrapCycleActive = v
        print("Цикл BearTrapPlaced включён:", v)
        
        if bearTrapCycleActive then
            spawn(function()
                while bearTrapCycleActive do
                    game.Players.LocalPlayer.PlayerStats:SetAttribute("BearTrapPlaced", false)
                    wait(4)
                end
            end)
        end
    end
})

Section1:AddToggle({
    text = "Toggle Chat Window",  -- Название переключателя
    state = false,                -- Начальное состояние (выключено)
    risky = false,                -- Устанавливаем рискованность
    tooltip = "Toggle chat window on or off", -- Подсказка для переключателя
    flag = "Toggle_Chat_Window",  -- Флаг для хранения состояния
    callback = function(v)         -- Функция, вызываемая при изменении состояния
        print(ValueText, v)        -- Выводим текущее состояние
        local TextChatService = game:GetService("TextChatService")
        
        -- Включаем или отключаем окно чата в зависимости от состояния переключателя
        TextChatService.ChatWindowConfiguration.Enabled = v
    end
})

-- Toggle для JackOPlaced
Section1:AddToggle({
    text = "No CD Jack",
    state = false,
    risky = false,
    tooltip = "you can bet as much as you want lol",
    flag = "Toggle_JackOPlaced",
    callback = function(v)
        jackOCycleActive = v
        print("Цикл JackOPlaced включён:", v)
        
        if jackOCycleActive then
            spawn(function()
                while jackOCycleActive do
                    game.Players.LocalPlayer.PlayerStats:SetAttribute("JackOPlaced", false)
                    wait(4)
                end
            end)
        end
    end
})

-- Toggle для Combat Stamina
Section1:AddToggle({
    text = "Inf Combat Stamina",
    state = false,
    tooltip = "Toggle Infinity Combat Stamina",
    flag = "Combat_Stamina_Toggle",
    callback = function(enabled)
        combatStaminaEnabled = enabled -- Устанавливаем глобальный флаг для работы цикла
        if enabled then
            combatStaminaThread = coroutine.create(function()
                local player = game.Players.LocalPlayer -- Получаем текущего игрока
                while combatStaminaEnabled do -- Проверяем состояние переменной
                    if player and player.Character and player.Character:FindFirstChild("Stats") and player.Character.Stats:FindFirstChild("CombatStamina") then
                        player.Character.Stats.CombatStamina.Value = 100
                    end
                    wait(3.5) -- Пауза между обновлениями
                end
            end)
            coroutine.resume(combatStaminaThread)
        end
    end
})

--[ Ваш существующий код здесь ]

Section4:AddButton({
    enabled = true,
    text = "End map",
    tooltip = "Teleport",
    confirm = false,
    risky = false,
    callback = function()
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

humanoidRootPart.CFrame = CFrame.new(-391.510376, 3.94040155, -561.560974, -0.335028976, 0.0178718679, -0.942038298, -8.53516191e-09, 0.999820113, 0.0189680774, 0.942207813, 0.00635486376, -0.334968686)
    end
})

Section4:AddButton({
    enabled = true,
    text = "Radio station",
    tooltip = "Teleport",
    confirm = false,
    risky = false,
    callback = function()
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

humanoidRootPart.CFrame = CFrame.new(-381.520599, -113.735931, 42.9471855, -0.0306593683, -0.0237039384, -0.999248803, 2.74181366e-06, 0.999718785, -0.0237151701, 0.999529898, -0.000729829073, -0.030650679)
    end
})

Section4:AddButton({
    enabled = true,
    text = "Shop",
    tooltip = "Teleport",
    confirm = false,
    risky = false,
    callback = function()
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

humanoidRootPart.CFrame = CFrame.new(-113.171844, -85.9600906, 209.123428, -0.00369261508, -0.12829496, -0.9917292, -7.23150917e-09, 0.991735935, -0.128295839, 0.999993205, -0.000473739958, -0.00366209983)
    end
})

Section4:AddButton({
    enabled = true,
    text = "House 1",
    tooltip = "Teleport",
    confirm = false,
    risky = false,
    callback = function()
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

humanoidRootPart.CFrame = CFrame.new(164.408112, -93.5687103, 228.658173, 0.99991262, 0.000353183481, -0.0132142855, 8.33566993e-09, 0.999642968, 0.0267184861, 0.0132190045, -0.0267161522, 0.999555647)
    end
})

Section4:AddButton({
    enabled = true,
    text = "House 2",
    tooltip = "Teleport",
    confirm = false,
    risky = false,
    callback = function()
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

humanoidRootPart.CFrame = CFrame.new(-352.15683, -86.4282227, 281.471954, -0.344819665, 0.0217136368, -0.938417792, -4.52628512e-09, 0.999732435, 0.0231323708, 0.938668966, 0.00797650032, -0.344727397)
    end
})

Section4:AddButton({
    enabled = true,
    text = "Power Station",
    tooltip = "Teleport",
    confirm = false,
    risky = false,
    callback = function()
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

humanoidRootPart.CFrame = CFrame.new(-207.976364, -109.483444, -86.5617981, 0.999895096, -0.000663155632, 0.014468275, 3.69048212e-06, 0.99896282, 0.045532573, -0.014483464, -0.0455277413, 0.998858094)
    end
})

Section4:AddButton({
    enabled = true,
    text = "Warehouse",
    tooltip = "Teleport",
    confirm = false,
    risky = false,
    callback = function()
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

humanoidRootPart.CFrame = CFrame.new(315.716339, -112.372467, -258.560028, -0.999726713, 5.74405785e-05, 0.0233771317, 8.75708484e-09, 0.99999696, -0.0024567449, -0.0233772025, -0.00245607318, -0.999723673)
    end
})

Section4:AddButton({
    enabled = true,
    text = "Ritual",
    tooltip = "Teleport",
    confirm = false,
    risky = false,
    callback = function()
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

humanoidRootPart.CFrame = CFrame.new(-25.7088108, -106.319954, -199.117996, 0.970376134, -0.00883071404, -0.241437614, 3.57253812e-05, 0.999337018, -0.0364077166, 0.241599053, 0.0353205539, 0.969733119)
    end
})

Section4:AddButton({
    enabled = true,
    text = "Workshop",
    tooltip = "Teleport",
    confirm = false,
    risky = false,
    callback = function()
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

humanoidRootPart.CFrame = CFrame.new(171.005341, -101.835281, -30.2862396, 0.258823305, -0.00847451296, -0.965887487, -1.02627325e-06, 0.999961495, -0.0087737469, 0.96592468, 0.00227184128, 0.258813351)
    end
})
--[ Остальной ваш код здесь ]

-- Кнопка "No Fog"
Section2:AddButton({
    enabled = true,
    text = "No Fog", -- Название кнопки
    tooltip = "Disable Fog", -- Подсказка
    confirm = false,
    risky = false,
    callback = function()
        local Lighting = game:GetService("Lighting")
        Lighting.FogEnd = 100000 -- Устанавливаем дальность тумана
        for i, v in pairs(Lighting:GetDescendants()) do
            if v:IsA("Atmosphere") then
                v:Destroy() -- Удаляем все объекты типа Atmosphere
            end
        end
        print("Fog Disabled!") -- Сообщение в консоль
    end
})

Section2:AddButton({
    enabled = true,
    text = "Unlock All Blueprints",
    tooltip = "unlocks all blueprints you can craft something (i think)",
    confirm = true,
    risky = false,
    callback = function()
game.Players.LocalPlayer.PlayerStats.Blueprints:SetAttribute("45ACP", true)
game.Players.LocalPlayer.PlayerStats.Blueprints:SetAttribute("CombatKnife", true)
game.Players.LocalPlayer.PlayerStats.Blueprints:SetAttribute("Deagle", true)
game.Players.LocalPlayer.PlayerStats.Blueprints:SetAttribute("DoubleBarrel", true)
game.Players.LocalPlayer.PlayerStats.Blueprints:SetAttribute("M1911", true)
game.Players.LocalPlayer.PlayerStats.Blueprints:SetAttribute("Machete", true)
game.Players.LocalPlayer.PlayerStats.Blueprints:SetAttribute("Shells", true) 
    end
})

Section2:AddButton({
    enabled = true,
    text = "Bypass Anticheat [THIS IS MANDATORY]",
    tooltip = "Make Bypass Anticheat adonis ye",
    confirm = false,
    risky = false,
    callback = function()
    local getinfo = getinfo or debug.getinfo
local DEBUG = false
local Hooked = {}

local Detected, Kill

setthreadidentity(2)

for i, v in getgc(true) do
    if typeof(v) == "table" then
        local DetectFunc = rawget(v, "Detected")
        local KillFunc = rawget(v, "Kill")
    
        if typeof(DetectFunc) == "function" and not Detected then
            Detected = DetectFunc
            
            local Old; Old = hookfunction(Detected, function(Action, Info, NoCrash)
                if Action ~= "_" then
                    if DEBUG then
                        warn(`Adonis AntiCheat flagged\nMethod: {Action}\nInfo: {Info}`)
                    end
                end
                
                return true
            end)

            table.insert(Hooked, Detected)
        end

        if rawget(v, "Variables") and rawget(v, "Process") and typeof(KillFunc) == "function" and not Kill then
            Kill = KillFunc
            local Old; Old = hookfunction(Kill, function(Info)
                if DEBUG then
                    warn(`Adonis AntiCheat tried to kill (fallback): {Info}`)
                end
            end)

            table.insert(Hooked, Kill)
        end
    end
end

local Old; Old = hookfunction(getrenv().debug.info, newcclosure(function(...)
    local LevelOrFunc, Info = ...

    if Detected and LevelOrFunc == Detected then
        if DEBUG then
            warn(`zins | adonis bypassed`)
        end

        return coroutine.yield(coroutine.running())
    end
    
    return Old(...)
end))
-- setthreadidentity(9)
setthreadidentity(7)
    end
})

-- Кнопка "FullBright"
Section2:AddButton({
    enabled = true,
    text = "FullBright", -- Название кнопки
    tooltip = "Enable FullBright", -- Подсказка
    confirm = false,
    risky = false,
    callback = function()
        local Lighting = game:GetService("Lighting")
        
        -- Функция для установки освещения
        local function applyLightingSettings()
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
        
        -- Применяем настройки при нажатии
        applyLightingSettings()
        
        -- Цикл, который будет каждые 8 секунд восстанавливать настройки освещения
        spawn(function()
            while true do
                applyLightingSettings()
                wait(8)
            end
        end)
        
        print("FullBright Activated!") -- Сообщение в консоль
    end
})

Section2:AddButton({
    enabled = true,
    text = "Infinite Yield",
    tooltip = "Yes thats good",
    confirm = false,
    risky = false,
    callback = function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

Section2:AddButton({
    enabled = true,
    text = "AutoFarm Scrap",
    tooltip = "Yes Farm ezzzzz",
    confirm = false,
    risky = false,
    callback = function()
    -- Compiled with roblox-ts v2.3.0
local Workspace = cloneref(game:GetService("Workspace"))
local Players = cloneref(game:GetService("Players"))
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local MiscFolder = Workspace:WaitForChild("Misc")
local ZonesFolder = MiscFolder:WaitForChild("Zones")
local LootFolders = ZonesFolder:WaitForChild("LootingItems"):WaitForChild("Scrap")
local ScrapCollectorController = {}
do
	local _container = ScrapCollectorController
	local scrapCounter = 0
	local lookAt = function(cframe)
		local lookAtPos = CFrame.new(Camera.CFrame.Position, cframe.Position)
		Camera.CFrame = lookAtPos
	end
	local bringPlr = function(cframe)
		local _result = LocalPlayer.Character
		if _result ~= nil then
			_result:PivotTo(cframe)
		end
	end
	local collect = function(scrap)
		scrapCounter += 1
		--print(`Processing scrap: {scrapCounter}`)
		local pivotCFrame = scrap:GetPivot()
		local proximityPrompt = scrap:FindFirstChildWhichIsA("ProximityPrompt", true)
		if proximityPrompt ~= nil then
			task.wait(0.4)
			--print("Looking at scrap...")
			lookAt(pivotCFrame)
			task.wait(0.2)
			--print("Fired the scraps prompt")
			fireproximityprompt(proximityPrompt)
		else
			print(`Skipped scrap: {scrapCounter}`)
		end
	end
	local function __init()
		for _, scraps in LootFolders:GetChildren() do
			local values = scraps:WaitForChild("Values")
			if scraps:GetAttribute("Scrap") ~= nil and scraps:IsA("Model") and values:GetAttribute("Available") == true then
				bringPlr(scraps:GetPivot())
				--print(`Brought {LocalPlayer.Name} to scrap`)
				collect(scraps)
			end
			task.wait(0.2)
		end
		scrapCounter = 0
	end
	_container.__init = __init
end
ScrapCollectorController.__init()
return 0

    end
})

Section2:AddButton({
    enabled = true,
    text = "Open Shop",
    tooltip = "you can buy if it's night lol press z to unlock the cursor",
    confirm = false,
    risky = false,
    callback = function()

game.Players.LocalPlayer.PlayerGui.Ingame.Shop.Visible = true

    end
})

-- Функция для добавления Highlight и текстовой информации над головой
local function addHighlightWithTextOnHead(targetInstance)
    -- Проверяем, существует ли уже Highlight с именем 'esplight' у объекта
    if targetInstance:FindFirstChild("esplight") then
        warn(targetInstance.Name .. " уже имеет esplight!")
        return
    end

    -- Убедимся, что у объекта есть голова (Head)
    local head = targetInstance:FindFirstChild("Head")
    if not head then
        warn(targetInstance.Name .. " не имеет части Head!")
        return
    end

    -- Создаем новый объект Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "esplight"
    highlight.FillColor = Color3.fromRGB(255, 255, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = targetInstance

    -- Создаем BillboardGui для отображения текста над головой
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ChainText"
    billboardGui.Size = UDim2.new(0, 200, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.Adornee = head
    billboardGui.Parent = head
    
    -- Настройка рендера
    billboardGui.AlwaysOnTop = true
    billboardGui.MaxDistance = 10000

    -- Создаем контейнер для текстов
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 28)
    container.BackgroundTransparency = 1

    -- Создаем список для выравнивания текста
    local listlayout = Instance.new("UIListLayout")
    listlayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listlayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Создаем текстовый элемент для отображения имени
    local name = Instance.new("TextLabel")
    name.BackgroundTransparency = 1
    name.Font = Enum.Font.Nunito
    name.Size = UDim2.new(1, 0, 0, 14)
    name.Text = targetInstance.Name
    name.TextSize = 14
    name.TextStrokeTransparency = 0.5
    name.TextColor3 = Color3.fromRGB(0, 255, 0)
    name.Parent = container

    -- Создаем текстовый элемент для отображения атрибутов
    local data = Instance.new("TextLabel")
    data.BackgroundTransparency = 1
    data.Font = Enum.Font.Nunito
    data.Size = UDim2.new(1, 0, 0, 14)
    data.Text = "[0] [Anger: 0%] [Burst: 0%] [Choke: 100%]"
    data.TextSize = 12
    data.TextStrokeTransparency = 0.5
    data.TextColor3 = Color3.fromRGB(0, 255, 0)
    data.Parent = container

    -- Присоединяем элементы к контейнеру
    listlayout.Parent = container
    container.Parent = billboardGui

    -- Обновление текста с атрибутами
    local function updateTextWithAttributes()
        local attributes = targetInstance:GetAttributes()
        local anger = attributes.Anger or 0
        local choke = attributes.ChokeMeter or 100
        local burst = attributes.Burst or 0
        data.Text = string.format("[Anger: %.1f%%] [Burst: %.1f%%] [Choke: %.1f%%]", anger, burst, choke)
    end

    -- Установка атрибутов при добавлении
    updateTextWithAttributes()

    -- Обновление текста при изменении атрибутов
    targetInstance:GetAttributeChangedSignal("Anger"):Connect(updateTextWithAttributes)
    targetInstance:GetAttributeChangedSignal("ChokeMeter"):Connect(updateTextWithAttributes)
    targetInstance:GetAttributeChangedSignal("Burst"):Connect(updateTextWithAttributes)
end

-- Функция для отключения ESP
local function removeESP(targetInstance)
    local highlight = targetInstance:FindFirstChild("esplight")
    if highlight then
        highlight:Destroy() -- Удаляем Highlight
    end

    local head = targetInstance:FindFirstChild("Head")
    if head then
        local billboardGui = head:FindFirstChild("ChainText")
        if billboardGui then
            billboardGui:Destroy() -- Удаляем BillboardGui
        end
    end
end

-- Пример использования Toggle для включения/выключения функции



-- Переменная для хранения состояния ESP
local espEnabled = false

-- Функция для добавления Highlight
local function addHighlight(item)
    if not item:FindFirstChild("Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "Highlight"
        highlight.FillColor = Color3.fromRGB(170, 85, 0) -- Цвет заполнения
        highlight.OutlineColor = Color3.fromRGB(255, 0, 0) -- Цвет контура
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = item
    end
end

-- Функция для удаления Highlight
local function removeHighlight(item)
    local highlight = item:FindFirstChild("Highlight")
    if highlight then
        highlight:Destroy()
    end
end

-- Функция для обработки добавления новых ScrapNormal
local function onChildAdded(child)
    if child:IsA("Model") and child.Name == "ScrapNormal" then
        if espEnabled then
            addHighlight(child)
        end
    end
end

-- Функция для обработки удаления ScrapNormal
local function onChildRemoved(child)
    if child:IsA("Model") and child.Name == "ScrapNormal" then
        removeHighlight(child)
    end
end

-- Основная функция для установки слушателей
local function setupScrapHighlights()
    local scrapFolder = Workspace:FindFirstChild("Misc"):FindFirstChild("Zones"):FindFirstChild("LootingItems"):FindFirstChild("Scrap")
    if scrapFolder then
        -- Добавляем Highlight ко всем существующим ScrapNormal, если ESP включен
        for _, item in ipairs(scrapFolder:GetChildren()) do
            if item:IsA("Model") and item.Name == "ScrapNormal" then
                if espEnabled then
                    addHighlight(item)
                end
            end
        end
        
        -- Подписываемся на события добавления и удаления
        scrapFolder.ChildAdded:Connect(onChildAdded)
        scrapFolder.ChildRemoved:Connect(onChildRemoved)
    else
        warn("Папка Scrap не найдена!")
    end
end

-- Функция для переключения ESP
local function toggleEsp(value)
    espEnabled = value
    local scrapFolder = Workspace:FindFirstChild("Misc"):FindFirstChild("Zones"):FindFirstChild("LootingItems"):FindFirstChild("Scrap")
    if scrapFolder then
        for _, item in ipairs(scrapFolder:GetChildren()) do
            if item:IsA("Model") and item.Name == "ScrapNormal" then
                if espEnabled then
                    addHighlight(item)
                else
                    removeHighlight(item)
                end
            end
        end
    end
end

-- Создаем переключатель в интерфейсе
Section3:AddToggle({
    text = "Esp Scrap", 
    state = false,
    risky = false, 
    tooltip = "Enable Esp Scrap",
    flag = "Toggle_1",
    callback = toggleEsp
})

local locationEsps = {} -- Таблица для хранения созданных ESP объектов

-- Функция для добавления ESP локации
local function addLocationEsp(locationName, position)
    -- Проверяем, если уже существует ESP для данной локации
    if locationEsps[locationName] then
        warn(locationName .. " уже существует!")
        return
    end

    -- Создаем новую часть для ESP
    local locationPart = Instance.new("Part")
    locationPart.Name = locationName
    locationPart.Size = Vector3.new(4, 1, 4)
    locationPart.Position = position
    locationPart.Anchored = true
    locationPart.CanCollide = false
    locationPart.Transparency = 1
    locationPart.Parent = workspace

    -- Создаем Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "LocationHighlight"
    highlight.FillColor = Color3.fromRGB(0, 0, 255)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = locationPart

    -- Создаем BillboardGui
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(0, 200, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.AlwaysOnTop = true
    billboardGui.MaxDistance = 10000
    billboardGui.Parent = locationPart

    -- Создаем текстовый элемент
    local textLabel = Instance.new("TextLabel")
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.Nunito
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.Text = locationName
    textLabel.TextSize = 20
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Parent = billboardGui

    -- Сохраняем созданный объект в таблице
    locationEsps[locationName] = {part = locationPart, highlight = highlight}
end

-- Функция для удаления ESP локации
local function removeLocationEsp(locationName)
    local esp = locationEsps[locationName]
    if esp then
        esp.part:Destroy() -- Удаляем часть
        esp.highlight:Destroy() -- Удаляем Highlight
        locationEsps[locationName] = nil -- Удаляем из таблицы
    end
end

-- Переключатель для включения/отключения ESP
Section3:AddToggle({
    text = "Esp Locations",
    state = false,
    risky = false,
    tooltip = "tooltip1",
    flag = "Toggle_1",
    callback = function(v)
        if v then
            -- Включаем ESP для всех локаций
            addLocationEsp("Ritual", Vector3.new(-25.9808769, -107.020752, -207.884506))
            addLocationEsp("Warehouse", Vector3.new(316.073914, -116.502617, -219.959656))
            addLocationEsp("Workshop", Vector3.new(152.051819, -104.892662, -0.232060552))
            addLocationEsp("Safe House", Vector3.new(158.723038, -95.3076324, 212.529221))
            addLocationEsp("Shop", Vector3.new(-112.314552, -86.3646088, 211.099518))
            addLocationEsp("Power", Vector3.new(-207.306793, -110.89064, -85.123909))
            addLocationEsp("House 2", Vector3.new(-314.230896, -89.6283798, 276.398376))
        else
            -- Отключаем ESP для всех локаций
            for locationName in pairs(locationEsps) do
                removeLocationEsp(locationName)
            end
        end
    end
})

local Workspace = game:GetService("Workspace")

-- Функция для добавления Highlight и текстовой информации над головой
local function addHighlightWithTextOnHead(targetInstance)
    if targetInstance:FindFirstChild("esplight") then
        warn(targetInstance.Name .. " уже имеет esplight!")
        return
    end

    local head = targetInstance:FindFirstChild("Head")
    if not head then
        warn(targetInstance.Name .. " не имеет части Head!")
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "esplight"
    highlight.FillColor = Color3.fromRGB(255, 255, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
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
    name.TextColor3 = Color3.fromRGB(0, 255, 0)
    name.Parent = container

    local data = Instance.new("TextLabel")
    data.BackgroundTransparency = 1
    data.Font = Enum.Font.Nunito
    data.Size = UDim2.new(1, 0, 0, 14)
    data.Text = "[0] [Anger: 0%] [Burst: 0%] [Choke: 100%]"
    data.TextSize = 12
    data.TextStrokeTransparency = 0.5
    data.TextColor3 = Color3.fromRGB(0, 255, 0)
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

-- Отслеживание появления и исчезновения модели CHAIN
local currentChainInstance = nil

local function trackChainModel()
    while true do
        local target = Workspace.Misc.AI:FindFirstChild("CHAIN")

        if target ~= currentChainInstance then
            if target then
                -- Если модель появилась
                if library.flags["Toggle_ESP"] then  -- Используем флаг вместо GetToggle
                    addHighlightWithTextOnHead(target)
                end
                currentChainInstance = target
            elseif currentChainInstance then
                -- Если модель исчезла
                removeESP(currentChainInstance)
                currentChainInstance = nil
            end
        end

        wait(1) -- Добавляем паузу для предотвращения перегрузки процессора
    end
end


-- Добавление Toggle для включения/выключения ESP для CHAIN
Section3:AddToggle({
    text = "Esp Chain",
    state = false,
    risky = false,
    tooltip = "Toggle ESP for the CHAIN monster",
    flag = "Toggle_ESP",
    callback = function(isEnabled)
        if isEnabled and currentChainInstance then
            addHighlightWithTextOnHead(currentChainInstance)
        elseif currentChainInstance then
            removeESP(currentChainInstance)
        end
    end
})

-- Запуск функции отслеживания модели CHAIN
spawn(trackChainModel)

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
Section1:AddToggle({
    text = "Status GUI",
    state = false, -- Начальное состояние: отключено
    risky = false,
    tooltip = "You will be able to find out the status of Power, Round Time, and how much scrap you have",
    flag = "Toggle_Scrap_Display",
    callback = function(v)
        screenGui.Enabled = v -- Показываем или скрываем меню в зависимости от состояния переключателя
    end
})

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Создаем ScreenGui
local screenGuiChain = Instance.new("ScreenGui")
screenGuiChain.Name = "ChainStats"
screenGuiChain.Parent = playerGui
screenGuiChain.Enabled = false
screenGuiChain.ResetOnSpawn = false

-- Создаем Frame с черным фоном и прозрачностью 0.5
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 210, 0, 250)  -- Увеличиваем ширину фрейма
frame.Position = UDim2.new(0, 10, 0.5, -100) -- Позиция слева по центру
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Черный цвет фона
frame.BackgroundTransparency = 0.5 -- Прозрачность фона
frame.BorderSizePixel = 1 -- Убираем границу
frame.Parent = screenGuiChain

-- Создаем TextLabel для титула
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(0, 200, 0, 50) -- Размер титула
titleLabel.Position = UDim2.new(0.5, -100, 0, 10) -- Позиция по центру по горизонтали
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Белый цвет текста
titleLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Черный фон
titleLabel.BackgroundTransparency = 0.5 -- Прозрачность фона
titleLabel.TextSize = 14 -- Размер текста для титула
titleLabel.Text = "Chain Stats:" -- Текст титула
titleLabel.TextXAlignment = Enum.TextXAlignment.Center -- Центрирование текста по горизонтали
titleLabel.Parent = frame

-- Функция для создания и настройки TextLabel
local function createTextLabel(name, positionY, defaultText)
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(0, 200, 0, 50) -- Размер TextLabel
    textLabel.Position = UDim2.new(0.5, -100, 0, positionY) -- Позиция по центру по горизонтали
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Белый цвет текста
    textLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Черный фон
    textLabel.BackgroundTransparency = 0.5 -- Прозрачность фона
    textLabel.TextSize = 12 -- Размер текста
    textLabel.Text = defaultText -- Начальный текст
    textLabel.Name = name
    textLabel.TextXAlignment = Enum.TextXAlignment.Center -- Центрирование текста по горизонтали
    textLabel.Parent = frame
    return textLabel
end

-- Создаем TextLabel для ChokeMeter
local chokeTextLabel = createTextLabel("ChokeLabel", 70, "Choke: 0%")
-- Создаем TextLabel для Burst
local burstTextLabel = createTextLabel("BurstLabel", 130, "Burst: 0%")
-- Создаем TextLabel для Bloodmoon
local bloodmoonTextLabel = createTextLabel("BloodmoonLabel", 190, "Bloodmoon: 0%")

-- Функция для обновления значений атрибутов
local function updateAttributeText(label, attributeValue)
    -- Обновляем текст для каждого атрибута с пробелами после двоеточия
    label.Text = label.Text:match("^(%a+):") .. ": " .. math.floor(attributeValue) .. "%" 
end

-- Функция для мониторинга атрибутов модели CHAIN
local function monitorAttributes(chain)
    -- Получаем и обновляем значение атрибута ChokeMeter
    local chokeMeter = chain:GetAttribute("ChokeMeter")
    if chokeMeter then
        updateAttributeText(chokeTextLabel, chokeMeter)
        
        -- Подключаемся к изменению атрибута ChokeMeter
        chain:GetAttributeChangedSignal("ChokeMeter"):Connect(function()
            updateAttributeText(chokeTextLabel, chain:GetAttribute("ChokeMeter"))
        end)
    end

    -- Получаем и обновляем значение атрибута Burst
    local burst = chain:GetAttribute("Burst")
    if burst then
        updateAttributeText(burstTextLabel, burst)

        -- Подключаемся к изменению атрибута Burst
        chain:GetAttributeChangedSignal("Burst"):Connect(function()
            updateAttributeText(burstTextLabel, chain:GetAttribute("Burst"))
        end)
    end

    -- Получаем и обновляем значение атрибута Anger (Bloodmoon)
    local anger = chain:GetAttribute("Anger")
    if anger then
        updateAttributeText(bloodmoonTextLabel, anger)

        -- Подключаемся к изменению атрибута Anger
        chain:GetAttributeChangedSignal("Anger"):Connect(function()
            updateAttributeText(bloodmoonTextLabel, chain:GetAttribute("Anger"))
        end)
    end
end

-- Функция для проверки и мониторинга появления CHAIN
local function checkForChain()
    -- Пытаемся найти объект CHAIN в Workspace
    local chain = game.Workspace:FindFirstChild("Misc") and game.Workspace.Misc:FindFirstChild("AI") and game.Workspace.Misc.AI:FindFirstChild("CHAIN")
    
    if chain then
        -- Если объект уже существует, начинаем мониторинг
        monitorAttributes(chain)
    else
        -- Если объект не найден, ждем его появления
        game.Workspace.Misc.AI.ChildAdded:Connect(function(child)
            if child.Name == "CHAIN" then
                -- Когда объект CHAIN появляется, начинаем мониторинг
                monitorAttributes(child)
            end
        end)
    end
end

-- Начинаем проверку наличия объекта CHAIN
checkForChain()

Section1:AddToggle({
    text = "Chain Status GUI",
    state = false, -- Начальное состояние: отключено
    risky = false,
    tooltip = "You will be able to find out the status of Power, Round Time, and how much scrap you have",
    flag = "Toggle_Scrap_Display",
    callback = function(v)
        screenGuiChain.Enabled = v -- Показываем или скрываем меню в зависимости от состояния переключателя
    end
})

Section2:AddButton({
    enabled = true,
    text = "Inf Ammo All Guns",
    tooltip = "Dang thats crazy",
    confirm = false,
    risky = false,
    callback = function()
local player = game.Players.LocalPlayer
local char = workspace:FindFirstChild(player.Name)

if char and char:FindFirstChild("Items") then
    local items = {"XSaw", "AK47", "Deagle", "DoubleBarrel", "M1911"}

    for _, itemName in ipairs(items) do
        local item = char.Items:FindFirstChild(itemName)
        if item then
            item:SetAttribute("Ammo", 9999)
        end
    end
end
    end
})

Section2:AddButton({
    enabled = true,
    text = "Aimbot [Press H]",
    tooltip = "Aimbot for chain lol",
    confirm = true,
    risky = false,
    callback = function()
-- Compiled with roblox-ts v2.3.0
local Workspace = cloneref(game:GetService("Workspace"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local MiscFolder = Workspace:WaitForChild("Misc")
local AIFolder = MiscFolder:WaitForChild("AI")
local Camera = Workspace.CurrentCamera
local RangedController = {}
do
    local _container = RangedController
    local CHAIN
    local aimbot_toggle
    local lookAt = function(cframe)
        local lookAtPos = CFrame.new(Camera.CFrame.Position, cframe.Position)
        Camera.CFrame = lookAtPos
    end
    local getChain = function()
        if CHAIN then
            return CHAIN
        end
        local chosen
        for _, child in AIFolder:GetChildren() do
            local chainModel = child
            local rootPart = chainModel:FindFirstChild("HumanoidRootPart")
            if rootPart then
                chosen = chainModel
            end
        end
        return chosen
    end
    local onRender = function()
        CHAIN = getChain()
        if CHAIN ~= nil then
            if aimbot_toggle then
                lookAt(CHAIN:GetPivot())
            end
        end
    end
    local function __init()
        aimbot_toggle = false
        UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.H then
                CHAIN = nil
                aimbot_toggle = not aimbot_toggle -- Переключение состояния
            end
        end)
        RunService.RenderStepped:Connect(function()
            return onRender()
        end)
    end
    _container.__init = __init
end
RangedController.__init()
return 0
    end
})

Section2:AddButton({
    enabled = true,
    text = "Unlock all Shop Secret Items",
    tooltip = "bro...",
    confirm = false,
    risky = false,
    callback = function()
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
    end
})

local Time = (string.format("%."..tostring(Decimals).."f", os.clock() - Clock))
library:SendNotification(("Loaded In "..tostring(Time)), 6)

--[[
    ESP Menu por yato
    Ative/desative ESPs de LootingItems, Zonas e CHAIN
    Menu persiste após respawn/morte
--]]

-- Cores
local cores = {
    Artifact = Color3.fromRGB(0, 170, 255),
    ScrapNormal = Color3.fromRGB(255, 140, 0),
}
local corZona = Color3.fromRGB(0, 255, 100)
local corChain = Color3.fromRGB(170, 0, 255)

-- Estados dos ESPs
local ativoLoot, ativoZona, ativoChain = true, true, true

-- Função universal para encontrar o melhor BasePart para ESP
local function encontrarBasePart(model, prioridade)
    if not model:IsA("Model") then return nil end
    if prioridade then
        local part = model:FindFirstChild(prioridade)
        if part and part:IsA("BasePart") then return part end
    end
    local gear = model:FindFirstChild("Gear")
    if gear and gear:IsA("BasePart") then return gear end
    local root = model:FindFirstChild("HumanoidRootPart")
    if root and root:IsA("BasePart") then return root end
    local base = model:FindFirstChildWhichIsA("BasePart")
    if base then return base end
    local espPart = Instance.new("Part")
    espPart.Name = "ESPPart"
    espPart.Size = Vector3.new(1,1,1)
    espPart.Transparency = 1
    espPart.Anchored = true
    espPart.CanCollide = false
    espPart.CanQuery = false
    espPart.CanTouch = false
    espPart.Parent = model
    if model.PrimaryPart then
        espPart.CFrame = model.PrimaryPart.CFrame
    else
        espPart.CFrame = model:GetBoundingBox()
    end
    return espPart
end

-- Cria ESP
local function criarESP(obj, texto, cor)
    if not obj then return end
    if obj:IsA("Model") then
        obj = encontrarBasePart(obj)
        if not obj then return end
    end
    if obj:FindFirstChild("ESP") then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Adornee = obj
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = obj
    local label = Instance.new("TextLabel", billboard)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = texto
    label.TextColor3 = cor
    label.TextStrokeTransparency = 0.5
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
end

-- Remove ESP
local function removerESP(obj)
    if not obj then return end
    if obj:IsA("Model") then
        for _, part in ipairs(obj:GetChildren()) do
            if part:IsA("BasePart") and part:FindFirstChild("ESP") then
                part.ESP:Destroy()
            end
        end
    elseif obj:IsA("BasePart") and obj:FindFirstChild("ESP") then
        obj.ESP:Destroy()
    end
end

-- Atualiza ESP dos itens
local function atualizarLoot()
    local lootFolder = workspace:FindFirstChild("LootingItems")
    if not lootFolder then return end
    for _, categoria in ipairs(lootFolder:GetChildren()) do
        for _, item in ipairs(categoria:GetChildren()) do
            if cores[item.Name] then
                if ativoLoot then
                    criarESP(item, item.Name, cores[item.Name])
                else
                    removerESP(item)
                end
            end
        end
    end
end

-- Atualiza ESP das zonas principais
local function atualizarZonas()
    local zonasFolder = workspace:FindFirstChild("ExtraDetails")
    if not zonasFolder then return end
    for _, zona in ipairs(zonasFolder:GetChildren()) do
        if ativoZona then
            criarESP(zona, zona.Name, corZona)
        else
            removerESP(zona)
        end
    end
end

-- Atualiza ESP do CHAIN
local function atualizarChain()
    local aiFolder = workspace:FindFirstChild("AI")
    if not aiFolder then return end
    local chain = aiFolder:FindFirstChild("CHAIN")
    if chain then
        local adornee = encontrarBasePart(chain, "HumanoidRootPart")
        if ativoChain then
            criarESP(adornee, "CHAIN", corChain)
        else
            removerESP(adornee)
        end
    end
end

-- Conexão de eventos
local function conectarEventosLootingItems()
    local lootFolder = workspace:FindFirstChild("LootingItems")
    if lootFolder then
        lootFolder.ChildAdded:Connect(atualizarLoot)
        for _, categoria in ipairs(lootFolder:GetChildren()) do
            categoria.ChildAdded:Connect(atualizarLoot)
        end
    end
end

local function conectarEventosZonas()
    local zonasFolder = workspace:FindFirstChild("ExtraDetails")
    if zonasFolder then
        zonasFolder.ChildAdded:Connect(atualizarZonas)
    end
end

workspace.ChildAdded:Connect(function(obj)
    if obj.Name == "LootingItems" then
        conectarEventosLootingItems()
        atualizarLoot()
    elseif obj.Name == "ExtraDetails" then
        conectarEventosZonas()
        atualizarZonas()
    elseif obj.Name == "AI" then
        atualizarChain()
    end
end)

-- Função para criar o menu (imgui)
local lootBtn, zonaBtn, chainBtn
local frame -- tornar frame acessível globalmente para controle de visibilidade
local function criarMenu()
    local player = game:GetService("Players").LocalPlayer
    local guiParent = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")
    -- Remove menu antigo se existir
    local antigo = guiParent:FindFirstChild("YatoESPMenu")
    if antigo then antigo:Destroy() end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "YatoESPMenu"
    ScreenGui.Parent = guiParent
    frame = Instance.new("Frame", ScreenGui)
    frame.Size = UDim2.new(0, 220, 0, 180)
    frame.Position = UDim2.new(0, 20, 0, 100)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    local titulo = Instance.new("TextLabel", frame)
    titulo.Size = UDim2.new(1, 0, 0, 30)
    titulo.Position = UDim2.new(0, 0, 0, 0)
    titulo.BackgroundTransparency = 1
    titulo.Text = "ESP Menu - by yato"
    titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
    titulo.Font = Enum.Font.SourceSansBold
    titulo.TextSize = 18
    local function atualizarBotoes()
        lootBtn.Text = "ESP LootingItems: " .. (ativoLoot and "ON" or "OFF")
        zonaBtn.Text = "ESP Zonas: " .. (ativoZona and "ON" or "OFF")
        chainBtn.Text = "ESP CHAIN: " .. (ativoChain and "ON" or "OFF")
    end
    local function criarBotao(texto, ordem, callback)
        local btn = Instance.new("TextButton", frame)
        btn.Size = UDim2.new(1, -20, 0, 32)
        btn.Position = UDim2.new(0, 10, 0, 35 + (ordem-1)*38)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 16
        btn.Text = texto
        btn.AutoButtonColor = true
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    lootBtn = criarBotao("ESP LootingItems: ON", 1, function()
        ativoLoot = not ativoLoot
        atualizarLoot()
        atualizarBotoes()
    end)
    zonaBtn = criarBotao("ESP Zonas: ON", 2, function()
        ativoZona = not ativoZona
        atualizarZonas()
        atualizarBotoes()
    end)
    chainBtn = criarBotao("ESP CHAIN: ON", 3, function()
        ativoChain = not ativoChain
        atualizarChain()
        atualizarBotoes()
    end)
    local creditos = Instance.new("TextLabel", frame)
    creditos.Size = UDim2.new(1, 0, 0, 30)
    creditos.Position = UDim2.new(0, 0, 1, -30)
    creditos.BackgroundTransparency = 1
    creditos.Text = "Créditos: yato"
    creditos.TextColor3 = Color3.fromRGB(120, 200, 255)
    creditos.Font = Enum.Font.SourceSansItalic
    creditos.TextSize = 16
    atualizarBotoes()
end

-- Inicialização
atualizarLoot()
conectarEventosLootingItems()
atualizarZonas()
conectarEventosZonas()
atualizarChain()
criarMenu()

-- Atalho para mostrar/ocultar o menu com a tecla 'L'
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.L then
        if frame then
            frame.Visible = not frame.Visible
        end
    end
end)

-- Garante que o menu está sempre presente
local player = game:GetService("Players").LocalPlayer
local function garantirMenu()
    local guiParent = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")
    if not guiParent:FindFirstChild("YatoESPMenu") then
        criarMenu()
    end
end

-- Recria menu e ESPs após respawn
player.CharacterAdded:Connect(function()
    wait(1)
    garantirMenu()
    atualizarLoot()
    atualizarZonas()
    atualizarChain()
end)

-- Recria menu se for removido do PlayerGui
local guiParent = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")
guiParent.ChildRemoved:Connect(function(child)
    if child.Name == "YatoESPMenu" then
        wait(0.5)
        garantirMenu()
    end
end) 
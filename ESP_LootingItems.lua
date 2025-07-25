--[[
    Name ESP Menu por yato
    Ative/desative Name ESPs de LootingItems, Zonas e CHAIN
    Menu persiste após respawn/morte
    Pressione 'L' para mostrar/ocultar o menu
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

-- Função universal para colocar nome acima do melhor BasePart
local function colocarNome(obj, texto, cor)
    if not obj then return end
    local adornee = obj
    if obj:IsA("Model") then
        adornee = obj:FindFirstChild("GearMain")
            or obj:FindFirstChild("HumanoidRootPart")
            or obj:FindFirstChild("Head")
            or obj:FindFirstChild("Gear")
            or obj:FindFirstChildWhichIsA("BasePart")
        -- Se GearMain existe mas não é BasePart, tenta pegar um BasePart dentro dele
        if adornee and adornee.Name == "GearMain" and not adornee:IsA("BasePart") and adornee:IsA("Model") then
            local base = adornee:FindFirstChildWhichIsA("BasePart")
            if base then
                print("[DEBUG] GearMain não é BasePart, usando BasePart interno:", base.Name)
                adornee = base
            else
                print("[DEBUG] GearMain não tem BasePart interno!")
            end
        end
        print("[DEBUG] Tentando criar ESP para:", obj.Name, "->", adornee and adornee.Name or "NENHUM", "Tipo:", adornee and adornee.ClassName or "N/A")
        if not adornee or not adornee:IsA("BasePart") then return end
    end
    if adornee:FindFirstChild("NameESP") then return end
    local esp = Instance.new("BillboardGui")
    esp.Name = "NameESP"
    esp.Adornee = adornee
    esp.Size = UDim2.new(0, 100, 0, 30)
    esp.StudsOffset = Vector3.new(0, 2, 0)
    esp.AlwaysOnTop = true
    esp.Parent = adornee
    local label = Instance.new("TextLabel", esp)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = texto or obj.Name
    label.TextColor3 = cor or Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0.5
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
end

-- Remove Name ESP
local function removerNomeESP(obj)
    if not obj then return end
    if obj:IsA("Model") then
        local adornee = obj:FindFirstChild("GearMain")
            or obj:FindFirstChild("HumanoidRootPart")
            or obj:FindFirstChild("Head")
            or obj:FindFirstChild("Gear")
            or obj:FindFirstChildWhichIsA("BasePart")
        if adornee and adornee.Name == "GearMain" and not adornee:IsA("BasePart") and adornee:IsA("Model") then
            adornee = adornee:FindFirstChildWhichIsA("BasePart")
        end
        if adornee and adornee:FindFirstChild("NameESP") then adornee.NameESP:Destroy() end
    elseif obj:IsA("BasePart") and obj:FindFirstChild("NameESP") then
        obj.NameESP:Destroy()
    end
end

-- Atualiza Name ESP dos itens
local function atualizarLoot()
    local lootFolder = workspace:FindFirstChild("LootingItems")
    if not lootFolder then return end
    for _, categoria in ipairs(lootFolder:GetChildren()) do
        for _, item in ipairs(categoria:GetChildren()) do
            if cores[item.Name] then
                if ativoLoot then
                    colocarNome(item, item.Name, cores[item.Name])
                else
                    removerNomeESP(item)
                end
            end
        end
    end
end

-- Atualiza Name ESP das zonas principais
local function atualizarZonas()
    local zonasFolder = workspace:FindFirstChild("ExtraDetails")
    if not zonasFolder then return end
    for _, zona in ipairs(zonasFolder:GetChildren()) do
        if ativoZona then
            colocarNome(zona, zona.Name, corZona)
        else
            removerNomeESP(zona)
        end
    end
end

-- Atualiza Name ESP do CHAIN
local function atualizarChain()
    local aiFolder = workspace:FindFirstChild("AI")
    if not aiFolder then return end
    local chain = aiFolder:FindFirstChild("CHAIN")
    if chain then
        if ativoChain then
            colocarNome(chain, "CHAIN", corChain)
        else
            removerNomeESP(chain)
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
local frame
local function criarMenu()
    local player = game:GetService("Players").LocalPlayer
    local guiParent = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")
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
    titulo.Text = "Name ESP Menu - by yato"
    titulo.TextColor3 = Color3.fromRGB(255, 255, 255)
    titulo.Font = Enum.Font.SourceSansBold
    titulo.TextSize = 18
    local function atualizarBotoes()
        lootBtn.Text = "Name ESP LootingItems: " .. (ativoLoot and "ON" or "OFF")
        zonaBtn.Text = "Name ESP Zonas: " .. (ativoZona and "ON" or "OFF")
        chainBtn.Text = "Name ESP CHAIN: " .. (ativoChain and "ON" or "OFF")
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
    lootBtn = criarBotao("Name ESP LootingItems: ON", 1, function()
        ativoLoot = not ativoLoot
        atualizarLoot()
        atualizarBotoes()
    end)
    zonaBtn = criarBotao("Name ESP Zonas: ON", 2, function()
        ativoZona = not ativoZona
        atualizarZonas()
        atualizarBotoes()
    end)
    chainBtn = criarBotao("Name ESP CHAIN: ON", 3, function()
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

player.CharacterAdded:Connect(function()
    wait(1)
    garantirMenu()
    atualizarLoot()
    atualizarZonas()
    atualizarChain()
end)

local guiParent = player:FindFirstChild("PlayerGui") or player:WaitForChild("PlayerGui")
guiParent.ChildRemoved:Connect(function(child)
    if child.Name == "YatoESPMenu" then
        wait(0.5)
        garantirMenu()
    end
end) 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local AnimalsFolder = workspace:FindFirstChild("Animals")

if not AnimalsFolder then
    return
end

local function getBestPart(animal)
    if animal.PrimaryPart then
        return animal.PrimaryPart
    else
        local rootPart = animal:FindFirstChild("HumanoidRootPart")
        if rootPart then
            return rootPart
        end
        for _, part in pairs(animal:GetChildren()) do
            if part:IsA("BasePart") then
                return part
            end
        end
        return nil
    end
end

local function getHealth(animal)
    local humanoid = animal:FindFirstChildOfClass("Humanoid")
    if humanoid then
        return math.floor(humanoid.Health)
    end
    return "N/A"
end

local function createESP(animal)
    if animal:FindFirstChild("ESP_Box") or animal:FindFirstChild("ESP_Label") then return end

    local primaryPart = getBestPart(animal)
    if not primaryPart then
        return
    end

    local espBox = Instance.new("SelectionBox")
    espBox.Name = "ESP_Box"
    espBox.Adornee = primaryPart
    espBox.LineThickness = 0.05
    espBox.SurfaceColor3 = Color3.fromRGB(0, 255, 255)
    espBox.SurfaceTransparency = 0.5
    espBox.Parent = animal

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Label"
    billboard.Adornee = primaryPart
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextStrokeTransparency = 0
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard
    billboard.Parent = animal

    local function updateESP()
        if not animal or not animal.Parent then
            billboard:Destroy()
            espBox:Destroy()
            return
        end

        local localPlayer = Players.LocalPlayer
        if localPlayer and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local playerPos = localPlayer.Character.HumanoidRootPart.Position
            local animalPos = primaryPart.Position
            local distance = math.floor((playerPos - animalPos).Magnitude)

            textLabel.Text = string.format("%s | Health: %s | Studs: %d", 
                animal.Name, getHealth(animal), distance)
        end
    end

    local updateConnection
    updateConnection = RunService.RenderStepped:Connect(function()
        if not billboard.Parent then
            updateConnection:Disconnect()
        else
            updateESP()
        end
    end)
end

local function updateAllESP()
    for _, animal in pairs(AnimalsFolder:GetChildren()) do
        if animal:IsA("Model") then
            createESP(animal)
        end
    end
end

updateAllESP()

AnimalsFolder.ChildAdded:Connect(function(animal)
    if animal:IsA("Model") then
        task.wait(1)
        createESP(animal)
    end
end)

while true do
    task.wait(5)
    updateAllESP()
end

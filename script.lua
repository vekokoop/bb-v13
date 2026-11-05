-- Blockspin Master Hub V33.0 (Perfect Loot Tracking + Combat)
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local GUI_Parent = gethui and gethui() or CoreGui
if GUI_Parent:FindFirstChild("BlockspinMasterHub") then GUI_Parent.BlockspinMasterHub:Destroy() end

local Settings = {
    AimbotEnabled = false, 
    SilentAimEnabled = false, 
    ESPEnabled = false,
    AutoLootEnabled = false,
    SilentFOVSize = 150, 
    AimbotFOVSize = 150, 
    Smoothness = 5,
    LootRadius = 5 -- 5 متر بالضبط مثل ما طلبت
}

-- ==========================================
-- 1. رسومات الـ FOV ومؤشرات الرؤية
-- ==========================================
local SilentFOVCircle = Drawing.new("Circle")
SilentFOVCircle.Visible = false; SilentFOVCircle.Transparency = 0.6; SilentFOVCircle.Thickness = 1.5
SilentFOVCircle.Color = Color3.fromRGB(0, 255, 0); SilentFOVCircle.Filled = false; SilentFOVCircle.Radius = Settings.SilentFOVSize

local AimbotFOVCircle = Drawing.new("Circle")
AimbotFOVCircle.Visible = false; AimbotFOVCircle.Transparency = 0.6; AimbotFOVCircle.Thickness = 1.5
AimbotFOVCircle.Color = Color3.fromRGB(255, 0, 0); AimbotFOVCircle.Filled = false; AimbotFOVCircle.Radius = Settings.AimbotFOVSize

local TargetIndicator = Drawing.new("Square")
TargetIndicator.Visible = false; TargetIndicator.Color = Color3.fromRGB(255, 0, 0); TargetIndicator.Thickness = 2; TargetIndicator.Filled = false

-- ==========================================
-- 2. بناء الواجهة
-- ==========================================
local ScreenGui = Instance.new("ScreenGui"); ScreenGui.Name = "BlockspinMasterHub"; ScreenGui.Parent = GUI_Parent; ScreenGui.ResetOnSpawn = false
local FloatingIcon = Instance.new("TextButton"); FloatingIcon.Parent = ScreenGui; FloatingIcon.BackgroundColor3 = Color3.fromRGB(20, 20, 25); FloatingIcon.Position = UDim2.new(0, 35, 0, 150); FloatingIcon.Size = UDim2.new(0, 55, 0, 55); FloatingIcon.Font = Enum.Font.SourceSansBold; FloatingIcon.Text = "🔥"; FloatingIcon.TextColor3 = Color3.fromRGB(255, 165, 0); FloatingIcon.TextSize = 28
local IconCorner = Instance.new("UICorner"); IconCorner.CornerRadius = UDim.new(1, 0); IconCorner.Parent = FloatingIcon
local IconStroke = Instance.new("UIStroke"); IconStroke.Color = Color3.fromRGB(255, 165, 0); IconStroke.Thickness = 2.5; IconStroke.Parent = FloatingIcon

local MainFrame = Instance.new("Frame"); MainFrame.Name = "MainFrame"; MainFrame.Parent = ScreenGui; MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20); MainFrame.Position = UDim2.new(0.5, -210, 0.5, -230); MainFrame.Size = UDim2.new(0, 420, 0, 460); MainFrame.Visible = false
local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 16); MainCorner.Parent = MainFrame
local MainStroke = Instance.new("UIStroke"); MainStroke.Color = Color3.fromRGB(255, 165, 0); MainStroke.Thickness = 2; MainStroke.Parent = MainFrame

local TopBar = Instance.new("Frame"); TopBar.Parent = MainFrame; TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30); TopBar.Size = UDim2.new(1, 0, 0, 50)
local TopCorner = Instance.new("UICorner"); TopCorner.CornerRadius = UDim.new(0, 16); TopCorner.Parent = TopBar
local Title = Instance.new("TextLabel"); Title.Parent = TopBar; Title.BackgroundTransparency = 1; Title.Position = UDim2.new(0, 20, 0, 0); Title.Size = UDim2.new(0.7, 0, 1, 0); Title.Font = Enum.Font.SourceSansBold; Title.Text = "BLOCKSPIN | God Mode V33"; Title.TextColor3 = Color3.fromRGB(255, 165, 0); Title.TextSize = 16; Title.TextXAlignment = Enum.TextXAlignment.Left
local CloseXBtn = Instance.new("TextButton"); CloseXBtn.Parent = TopBar; CloseXBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50); CloseXBtn.Position = UDim2.new(1, -40, 0.5, -14); CloseXBtn.Size = UDim2.new(0, 28, 0, 28); CloseXBtn.Font = Enum.Font.SourceSansBold; CloseXBtn.Text = "X"; CloseXBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CloseXBtn.TextSize = 14; CloseXBtn.AutoButtonColor = false
local XCorner = Instance.new("UICorner"); XCorner.CornerRadius = UDim.new(1, 0); XCorner.Parent = CloseXBtn

local TabsBar = Instance.new("Frame"); TabsBar.Parent = MainFrame; TabsBar.BackgroundTransparency = 1; TabsBar.Position = UDim2.new(0, 10, 0, 60); TabsBar.Size = UDim2.new(1, -20, 0, 35)
local TabsLayout = Instance.new("UIListLayout"); TabsLayout.Parent = TabsBar; TabsLayout.FillDirection = Enum.FillDirection.Horizontal; TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder; TabsLayout.Padding = UDim.new(0, 5)
local ContentContainer = Instance.new("Frame"); ContentContainer.Parent = MainFrame; ContentContainer.BackgroundTransparency = 1; ContentContainer.Position = UDim2.new(0, 10, 0, 100); ContentContainer.Size = UDim2.new(1, -20, 1, -110)

local tabs = {}
local function createTabContent(name)
    local scrolling = Instance.new("ScrollingFrame"); scrolling.Name = name .. "Content"; scrolling.Parent = ContentContainer; scrolling.BackgroundTransparency = 1; scrolling.Size = UDim2.new(1, 0, 1, 0); scrolling.CanvasSize = UDim2.new(0, 0, 0, 0); scrolling.ScrollBarThickness = 4; scrolling.Visible = false
    local list = Instance.new("UIListLayout"); list.Parent = scrolling; list.HorizontalAlignment = Enum.HorizontalAlignment.Center; list.SortOrder = Enum.SortOrder.LayoutOrder; list.Padding = UDim.new(0, 10)
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() scrolling.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 15) end)
    return scrolling
end

local function createTabButton(name, iconText)
    local btn = Instance.new("TextButton"); btn.Parent = TabsBar; btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35); btn.Size = UDim2.new(0, 90, 1, 0); btn.Font = Enum.Font.SourceSansBold; btn.Text = iconText .. " " .. name; btn.TextColor3 = Color3.fromRGB(150, 150, 150); btn.TextSize = 12; btn.AutoButtonColor = false
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 8); corner.Parent = btn
    local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(45, 45, 60); stroke.Thickness = 1; stroke.Parent = btn
    local content = createTabContent(name)
    btn.Activated:Connect(function()
        for _, t in pairs(tabs) do t.content.Visible = false; t.btn.BackgroundColor3 = Color3.fromRGB(25, 25, 35); t.btn.TextColor3 = Color3.fromRGB(150, 150, 150); t.stroke.Color = Color3.fromRGB(45, 45, 60) end
        content.Visible = true; btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50); btn.TextColor3 = Color3.fromRGB(255, 165, 0); stroke.Color = Color3.fromRGB(255, 165, 0)
    end)
    tabs[name] = {btn = btn, content = content, stroke = stroke}
    return content
end

local combatTab = createTabButton("Combat", "🎯")
local visualsTab = createTabButton("Visuals", "👁️")
local utilityTab = createTabButton("Utility", "📦")
tabs["Combat"].content.Visible = true; tabs["Combat"].btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50); tabs["Combat"].btn.TextColor3 = Color3.fromRGB(255, 165, 0); tabs["Combat"].stroke.Color = Color3.fromRGB(255, 165, 0)

local function createFeatureToggle(parentTab, name, desc, callback)
    local btn = Instance.new("TextButton"); btn.Parent = parentTab; btn.BackgroundColor3 = Color3.fromRGB(22, 22, 30); btn.Size = UDim2.new(0.95, 0, 0, 50); btn.Text = ""; btn.AutoButtonColor = false
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0, 10); corner.Parent = btn
    local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(45, 45, 60); stroke.Thickness = 1.2; stroke.Parent = btn
    local nameLabel = Instance.new("TextLabel"); nameLabel.Parent = btn; nameLabel.BackgroundTransparency = 1; nameLabel.Position = UDim2.new(0, 15, 0, 8); nameLabel.Size = UDim2.new(0.7, 0, 0, 16); nameLabel.Font = Enum.Font.SourceSansBold; nameLabel.Text = name; nameLabel.TextColor3 = Color3.fromRGB(240, 240, 240); nameLabel.TextSize = 14; nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    local descLabel = Instance.new("TextLabel"); descLabel.Parent = btn; descLabel.BackgroundTransparency = 1; descLabel.Position = UDim2.new(0, 15, 0, 26); descLabel.Size = UDim2.new(0.7, 0, 0, 16); descLabel.Font = Enum.Font.SourceSans; descLabel.Text = desc; descLabel.TextColor3 = Color3.fromRGB(120, 120, 120); descLabel.TextSize = 11; descLabel.TextXAlignment = Enum.TextXAlignment.Left
    local statusBox = Instance.new("Frame"); statusBox.Parent = btn; statusBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65); statusBox.Position = UDim2.new(1, -40, 0.5, -12); statusBox.Size = UDim2.new(0, 24, 0, 24)
    local boxCorner = Instance.new("UICorner"); boxCorner.CornerRadius = UDim.new(0, 6); boxCorner.Parent = statusBox
    local state = false
    btn.Activated:Connect(function()
        state = not state
        if state then statusBox.BackgroundColor3 = Color3.fromRGB(255, 165, 0); stroke.Color = Color3.fromRGB(255, 165, 0) else statusBox.BackgroundColor3 = Color3.fromRGB(50, 50, 65); stroke.Color = Color3.fromRGB(45, 45, 60) end
        callback(state)
    end)
    return btn
end

createFeatureToggle(combatTab, "Silent Aim", "تصويب صامت", function(enabled) Settings.SilentAimEnabled = enabled; SilentFOVCircle.Visible = enabled; if enabled then setupSilentAim() end end)
createFeatureToggle(combatTab, "Aimbot", "قفل الكاميرا", function(enabled) Settings.AimbotEnabled = enabled; AimbotFOVCircle.Visible = enabled end)
createFeatureToggle(visualsTab, "ESP", "رؤية اللاعبين", function(enabled) Settings.ESPEnabled = enabled end)
createFeatureToggle(utilityTab, "Auto Loot (Perfect)", "تتبع والتقاط أي غرض يطيح (5 متر)", function(enabled) Settings.AutoLootEnabled = enabled end)

-- ==========================================
-- 3. السايلنت أيم
-- ==========================================
local lockedTarget = nil
local oldNamecall = nil

local function setupSilentAim()
    if oldNamecall then return end
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if Settings.SilentAimEnabled and not checkcaller() and (method == "Raycast" or method == "FindPartOnRay") and self == Workspace then
            if lockedTarget and lockedTarget.Parent then
                local args = {...}
                pcall(function()
                    if method == "Raycast" and typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
                        args[2] = (lockedTarget.Position - args[1]).Unit * args[2].Magnitude
                    elseif method == "FindPartOnRay" and typeof(args[1]) == "Ray" then
                        args[1] = Ray.new(args[1].Origin, (lockedTarget.Position - args[1].Origin).Unit * args[1].Direction.Magnitude)
                    end
                end)
                return oldNamecall(self, unpack(args))
            end
        end
        return oldNamecall(self, ...)
    end)
end

local function updateSilentTarget()
    local camCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local shortest = Settings.SilentFOVSize
    
    if lockedTarget and lockedTarget.Parent then
        local hum = lockedTarget.Parent:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(lockedTarget.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - camCenter).Magnitude
                if dist <= shortest then return end
            end
        end
    end

    local closest = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
            local targetPart = math.random(1, 100) <= 40 and p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - camCenter).Magnitude
                    if dist < shortest then shortest = dist; closest = targetPart end
                end
            end
        end
    end
    lockedTarget = closest
end

RunService.RenderStepped:Connect(function()
    local camCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    SilentFOVCircle.Position = camCenter
    AimbotFOVCircle.Position = camCenter

    if Settings.SilentAimEnabled then 
        updateSilentTarget() 
        if lockedTarget and lockedTarget.Parent then
            local pos, onScreen = Camera:WorldToViewportPoint(lockedTarget.Position)
            if onScreen then
                TargetIndicator.Position = Vector2.new(pos.X - 15, pos.Y - 15)
                TargetIndicator.Size = Vector2.new(30, 30)
                TargetIndicator.Visible = true
            else TargetIndicator.Visible = false end
        else TargetIndicator.Visible = false end
    else 
        lockedTarget = nil 
        TargetIndicator.Visible = false
    end

    if Settings.AimbotEnabled then
        if lockedTarget and lockedTarget.Parent then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, lockedTarget.Position), 1 / Settings.Smoothness)
        end
    end
end)

-- ==========================================
-- 4. الـ ESP
-- ==========================================
local espCache = {}
local function CreateESP(player)
    if player == LocalPlayer then return end
    local box = Drawing.new("Square"); box.Visible = false; box.Color = Color3.fromRGB(255, 50, 50); box.Thickness = 1; box.Filled = false
    local nameTag = Drawing.new("Text"); nameTag.Visible = false; nameTag.Color = Color3.fromRGB(255, 255, 255); nameTag.Size = 12; nameTag.Center = true; nameTag.Outline = true
    espCache[player] = {Box = box, Name = nameTag}
    player.CharacterRemoving:Connect(function() box.Visible = false; nameTag.Visible = false end)
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(function(p) if espCache[p] then espCache[p].Box:Remove(); espCache[p].Name:Remove(); espCache[p] = nil end end)

RunService.RenderStepped:Connect(function()
    if not Settings.ESPEnabled then for _, data in pairs(espCache) do data.Box.Visible = false; data.Name.Visible = false end; return end
    for player, data in pairs(espCache) do
        local char = player.Character
        if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
            local hrp = char.HumanoidRootPart
            local vector, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local headPos = Camera:WorldToViewportPoint(char.Head.Position + Vector3.new(0, 0.5, 0))
                local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                local height = math.abs(headPos.Y - legPos.Y); local width = height / 2
                data.Box.Size = Vector2.new(width, height); data.Box.Position = Vector2.new(vector.X - width / 2, headPos.Y); data.Box.Visible = true
                data.Name.Text = player.Name; data.Name.Position = Vector2.new(vector.X, headPos.Y - 16); data.Name.Visible = true
            else data.Box.Visible = false; data.Name.Visible = false end
        else data.Box.Visible = false; data.Name.Visible = false end
    end
end)

-- ==========================================
-- 5. الأوتو لوت البيرفكت (Tracking System)
-- ==========================================
local activeLoot = {} -- جدول لتخزين اللوت اللي طاح
local collectedLoot = {}
local LootESP = Drawing.new("Square")
LootESP.Visible = false; LootESP.Color = Color3.fromRGB(0, 255, 255); LootESP.Thickness = 2; LootESP.Filled = false

-- 1. مراقبة الأشياء اللي تطيح بالـ Workspace
Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("Tool") or (obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart", true)) then
        task.wait(0.1) -- ننتظر جزء من الثانية عشان يتحمل باللعبة
        if obj.Parent then
            activeLoot[obj] = true
        end
    end
end)

-- إذا كان في أشياء طايحة أصلاً، نسجلها
for _, obj in ipairs(Workspace:GetDescendants()) do
    if obj:IsA("Tool") or (obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart", true)) then
        activeLoot[obj] = true
    end
end

Workspace.DescendantRemoving:Connect(function(obj)
    if activeLoot[obj] then activeLoot[obj] = nil end
    if collectedLoot[obj] then collectedLoot[obj] = nil end
end)

-- 2. حلقة الالتقاط
task.spawn(function()
    while task.wait(0.1) do 
        if Settings.AutoLootEnabled then
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
            local hrp = char.HumanoidRootPart
            
            local foundAny = false
            
            for obj, _ in pairs(activeLoot) do
                if obj and obj.Parent then
                    -- تجاهل اللاعبين (عشان ما نلمس أجسامهم)
                    if obj:IsA("Model") and Players:GetPlayerFromCharacter(obj) then
                        activeLoot[obj] = nil
                        continue
                    end

                    local targetPos = obj:IsA("BasePart") and obj.Position or obj:GetPivot().Position
                    local distance = (hrp.Position - targetPos).Magnitude

                    -- إذا قربنا منه (5 متر أو أقل)
                    if distance <= Settings.LootRadius then
                        foundAny = true
                        
                        -- رسم المربع الأزرق على اللوت نفسه
                        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
                        if onScreen then
                            LootESP.Position = Vector2.new(screenPos.X - 15, screenPos.Y - 15)
                            LootESP.Size = Vector2.new(30, 30)
                            LootESP.Visible = true
                        end

                        -- محاولة الالتقاط (مع وقت تبريد عشان ما نسبب لاق)
                        if not collectedLoot[obj] or tick() - collectedLoot[obj] > 0.1 then
                            collectedLoot[obj] = tick()
                            
                            local partToTouch = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                            if partToTouch then
                                pcall(function()
                                    -- اللمس العكسي والمباشر عشان كسر الشادو بان
                                    firetouchinterest(hrp, partToTouch, 0)
                                    firetouchinterest(partToTouch, hrp, 0)
                                    task.wait(0.01)
                                    firetouchinterest(hrp, partToTouch, 1)
                                    firetouchinterest(partToTouch, hrp, 1)
                                end)
                            end
                            
                            -- إذا كان أداة (Tool)، نجرب نمسك الـ Handle
                            if obj:IsA("Tool") then
                                local handle = obj:FindFirstChild("Handle")
                                if handle then
                                    pcall(function()
                                        firetouchinterest(hrp, handle, 0)
                                        task.wait(0.01)
                                        firetouchinterest(hrp, handle, 1)
                                    end)
                                end
                            end
                        end
                    end
                else
                    activeLoot[obj] = nil
                end
            end
            
            if not foundAny then LootESP.Visible = false end
        else
            LootESP.Visible = false
        end
    end
end)

-- ==========================================
-- 6. تحريك الواجهة
-- ==========================================
local dragging, dragStart, startPos
FloatingIcon.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = FloatingIcon.Position end end)
UserInputService.InputChanged:Connect(function(input) if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; FloatingIcon.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
local function toggleMenu() MainFrame.Visible = not MainFrame.Visible end
FloatingIcon.Activated:Connect(toggleMenu)
CloseXBtn.Activated:Connect(toggleMenu)

print("Blockspin God Mode V33.0 (Perfect Tracking Loot) Loaded Successfully!")

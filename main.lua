--[[
    ██╗   ██╗ ██████╗ ██████╗  █████╗    ██████╗  ██████╗
    ██║   ██║██╔═══██╗██╔══██╗██╔══██╗  ██╔════╝ ██╔════╝
    ██║   ██║██║   ██║██████╔╝███████║  ██║  ███╗██║  ███╗
    ╚██╗ ██╔╝██║   ██║██╔══██╗██╔══██║  ██║   ██║██║   ██║
     ╚████╔╝ ╚██████╔╝██║  ██║██║  ██║  ╚██████╔╝╚██████╔╝
      ╚═══╝   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═════╝  ╚═════╝
    Vora.gg  —  Rivals  |  PC
--]]

-- ══════════════════════════════════════════════════════════════
--  SERVICES
-- ══════════════════════════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")

local lp  = Players.LocalPlayer
local cam = workspace.CurrentCamera

-- ══════════════════════════════════════════════════════════════
--  CONFIG
-- ══════════════════════════════════════════════════════════════
local cfg = {
    -- ESP / Chams
    espEnabled    = true,
    espTeamCheck  = false,
    chamsEnabled  = true,     -- Highlight-based chams (through wall fill)
    rainbowChams  = false,    -- Rainbow cycling fill color
    chamsColor    = Color3.fromRGB(255, 50, 50),
    chamsOutline  = Color3.fromRGB(255, 255, 255),
    chamsFillTrans= 0.45,

    -- Tracers
    tracerEnabled = false,
    tracerOrigin  = "Bottom",  -- "Bottom" or "Center"
    tracerThick   = 1,
    tracerColor   = Color3.fromRGB(255, 50, 50),
    tracerRainbow = false,

    -- ESP Boxes (Drawing)
    boxEnabled    = true,
    boxThick      = 1,
    boxColor      = Color3.fromRGB(255, 255, 255),
    boxFill       = true,
    boxFillAlpha  = 0.04,

    -- Name tags
    nameEnabled   = true,
    nameSize      = 13,

    -- Health bars
    healthEnabled = true,

    -- Aimbot
    aimbotEnabled = false,
    aimbotKey     = Enum.KeyCode.LeftAlt,
    aimbotFOV     = 150,
    aimbotSmooth  = 0.55,
    aimbotBone    = "Head",
    aimbotVelPred = true,
    aimbotFOVvis  = true,

    -- Auto Win (teleport + attack)
    autoWin       = false,
    autoWinFOV    = 400,
}

-- ══════════════════════════════════════════════════════════════
--  GUI ROOT
-- ══════════════════════════════════════════════════════════════
pcall(function() CoreGui:FindFirstChild("VoraGG"):Destroy() end)
pcall(function() lp.PlayerGui:FindFirstChild("VoraGG"):Destroy() end)

local gui = Instance.new("ScreenGui")
gui.Name = "VoraGG"; gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling; gui.IgnoreGuiInset = true
if not pcall(function() gui.Parent = CoreGui end) then gui.Parent = lp.PlayerGui end

local function tw(o,p,t) pcall(function() TweenService:Create(o,TweenInfo.new(t or .18,Enum.EasingStyle.Quad),p):Play() end) end

-- ══════════════════════════════════════════════════════════════
--  PANEL
-- ══════════════════════════════════════════════════════════════
local panel = Instance.new("Frame", gui)
panel.Name = "Panel"; panel.Size = UDim2.new(0,340,0,520)
panel.Position = UDim2.new(0.5,-170,1,20)
panel.BackgroundColor3 = Color3.fromRGB(6,6,16)
panel.BorderSizePixel = 0; panel.ClipsDescendants = true
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,14)
local ps = Instance.new("UIStroke", panel)
ps.Color = Color3.fromRGB(0,90,210); ps.Thickness = 1.5; ps.Transparency = 0.2

-- Header
local hdr = Instance.new("Frame", panel)
hdr.Size = UDim2.new(1,0,0,44); hdr.BackgroundColor3 = Color3.fromRGB(0,70,175); hdr.BorderSizePixel = 0
Instance.new("UICorner", hdr).CornerRadius = UDim.new(0,14)
local hfix = Instance.new("Frame", hdr)
hfix.Size = UDim2.new(1,0,.5,0); hfix.Position = UDim2.new(0,0,.5,0)
hfix.BackgroundColor3 = Color3.fromRGB(0,70,175); hfix.BorderSizePixel = 0

local logo = Instance.new("TextLabel", hdr)
logo.Size = UDim2.new(1,-50,1,0); logo.Position = UDim2.new(0,14,0,0)
logo.BackgroundTransparency = 1; logo.TextColor3 = Color3.fromRGB(255,255,255)
logo.Font = Enum.Font.GothamBold; logo.TextSize = 17; logo.TextXAlignment = Enum.TextXAlignment.Left
logo.Text = "⬡  VORA.GG"

local xbtn = Instance.new("TextButton", hdr)
xbtn.Size = UDim2.new(0,32,0,24); xbtn.Position = UDim2.new(1,-38,.5,-12)
xbtn.BackgroundColor3 = Color3.fromRGB(160,20,20); xbtn.Text = "✕"
xbtn.TextColor3 = Color3.fromRGB(255,255,255); xbtn.Font = Enum.Font.GothamBold; xbtn.TextSize = 11
xbtn.BorderSizePixel = 0; Instance.new("UICorner", xbtn).CornerRadius = UDim.new(0,6)

-- Tab bar
local tabBar = Instance.new("Frame", panel)
tabBar.Size = UDim2.new(1,-14,0,28); tabBar.Position = UDim2.new(0,7,0,50)
tabBar.BackgroundTransparency = 1
local tbl = Instance.new("UIListLayout", tabBar)
tbl.FillDirection = Enum.FillDirection.Horizontal; tbl.Padding = UDim.new(0,3)

-- Content scroll
local content = Instance.new("ScrollingFrame", panel)
content.Size = UDim2.new(1,-8,1,-86); content.Position = UDim2.new(0,4,0,86)
content.BackgroundTransparency = 1; content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = Color3.fromRGB(0,110,255); content.BorderSizePixel = 0
content.CanvasSize = UDim2.new(0,0,0,0); content.AutomaticCanvasSize = Enum.AutomaticSize.Y
local cl = Instance.new("UIListLayout", content); cl.Padding = UDim.new(0,5)

-- ══════════════════════════════════════════════════════════════
--  WIDGETS
-- ══════════════════════════════════════════════════════════════
local function mkSection(par, lbl)
    local f = Instance.new("Frame", par); f.Size = UDim2.new(1,-8,0,22); f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1,-12,1,0); l.Position = UDim2.new(0,10,0,0)
    l.BackgroundTransparency = 1; l.TextColor3 = Color3.fromRGB(0,150,255)
    l.Font = Enum.Font.GothamBold; l.TextSize = 10; l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = "▸ "..lbl:upper()
end

local function mkToggle(par, lbl, state, cb)
    local row = Instance.new("Frame", par)
    row.Size = UDim2.new(1,-8,0,40); row.BackgroundColor3 = Color3.fromRGB(12,12,24); row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,9)
    local l = Instance.new("TextLabel", row)
    l.Size = UDim2.new(1,-62,1,0); l.Position = UDim2.new(0,13,0,0)
    l.BackgroundTransparency = 1; l.TextColor3 = Color3.fromRGB(215,215,235)
    l.Font = Enum.Font.Gotham; l.TextSize = 13; l.TextXAlignment = Enum.TextXAlignment.Left; l.Text = lbl
    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(0,44,0,24); track.Position = UDim2.new(1,-56,.5,-12)
    track.BackgroundColor3 = state and Color3.fromRGB(0,110,230) or Color3.fromRGB(40,40,60)
    track.BorderSizePixel = 0; Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0,18,0,18)
    knob.Position = state and UDim2.new(1,-21,.5,-9) or UDim2.new(0,3,.5,-9)
    knob.BackgroundColor3 = Color3.fromRGB(255,255,255); knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""
    local val = state
    btn.MouseButton1Click:Connect(function()
        val = not val
        tw(track, {BackgroundColor3 = val and Color3.fromRGB(0,110,230) or Color3.fromRGB(40,40,60)}, .15)
        tw(knob,  {Position = val and UDim2.new(1,-21,.5,-9) or UDim2.new(0,3,.5,-9)}, .15)
        pcall(cb, val)
    end)
    return {track=track, knob=knob, get=function() return val end}
end

local function mkSlider(par, lbl, mn, mx, val, fmt, cb)
    local row = Instance.new("Frame", par)
    row.Size = UDim2.new(1,-8,0,54); row.BackgroundColor3 = Color3.fromRGB(12,12,24); row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,9)
    local l = Instance.new("TextLabel", row)
    l.Size = UDim2.new(.65,0,0,26); l.Position = UDim2.new(0,13,0,4)
    l.BackgroundTransparency = 1; l.TextColor3 = Color3.fromRGB(215,215,235)
    l.Font = Enum.Font.Gotham; l.TextSize = 12; l.TextXAlignment = Enum.TextXAlignment.Left; l.Text = lbl
    local vl = Instance.new("TextLabel", row)
    vl.Size = UDim2.new(.35,-13,0,26); vl.Position = UDim2.new(.65,0,0,4)
    vl.BackgroundTransparency = 1; vl.TextColor3 = Color3.fromRGB(0,150,255)
    vl.Font = Enum.Font.GothamBold; vl.TextSize = 12; vl.TextXAlignment = Enum.TextXAlignment.Right
    vl.Text = fmt and fmt(val) or tostring(val)
    local trk = Instance.new("Frame", row)
    trk.Size = UDim2.new(1,-26,0,6); trk.Position = UDim2.new(0,13,0,36)
    trk.BackgroundColor3 = Color3.fromRGB(30,30,50); trk.BorderSizePixel = 0
    Instance.new("UICorner", trk).CornerRadius = UDim.new(1,0)
    local fill = Instance.new("Frame", trk)
    fill.Size = UDim2.new((val-mn)/(mx-mn),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(0,110,230); fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    local drag = Instance.new("TextButton", row)
    drag.Size = UDim2.new(1,0,0,28); drag.Position = UDim2.new(0,0,0,26)
    drag.BackgroundTransparency = 1; drag.Text = ""
    local dragging, tid = false, nil
    drag.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; tid = i end
    end)
    UserInputService.InputEnded:Connect(function(i) if i == tid then dragging = false; tid = nil end end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local rel = math.clamp((i.Position.X - trk.AbsolutePosition.X) / trk.AbsoluteSize.X, 0, 1)
        local nv = math.floor(mn + rel*(mx-mn) + .5)
        vl.Text = fmt and fmt(nv) or tostring(nv)
        fill.Size = UDim2.new(rel,0,1,0); pcall(cb, nv)
    end)
end

-- ══════════════════════════════════════════════════════════════
--  TAB SYSTEM
-- ══════════════════════════════════════════════════════════════
local function clearContent()
    for _,c in ipairs(content:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end
    local l2 = Instance.new("UIListLayout", content); l2.Padding = UDim.new(0,5)
end

local function pageESP()
    clearContent()
    mkSection(content, "Chams")
    mkToggle(content, "Chams Enabled",    cfg.chamsEnabled,  function(v) cfg.chamsEnabled=v; refreshChams() end)
    mkToggle(content, "Rainbow Chams",    cfg.rainbowChams,  function(v) cfg.rainbowChams=v end)
    mkSlider(content, "Fill Opacity %",   0, 100, math.floor((1-cfg.chamsFillTrans)*100), nil, function(v)
        cfg.chamsFillTrans = 1-(v/100); refreshChams()
    end)
    mkSection(content, "ESP Boxes")
    mkToggle(content, "Boxes",            cfg.boxEnabled,    function(v) cfg.boxEnabled=v end)
    mkToggle(content, "Box Fill",         cfg.boxFill,       function(v) cfg.boxFill=v end)
    mkSection(content, "Tracers")
    mkToggle(content, "Tracers",          cfg.tracerEnabled, function(v) cfg.tracerEnabled=v end)
    mkToggle(content, "Rainbow Tracers",  cfg.tracerRainbow, function(v) cfg.tracerRainbow=v end)
    mkSlider(content, "Thickness",        1, 5, cfg.tracerThick, nil, function(v) cfg.tracerThick=v end)
    mkSection(content, "Labels")
    mkToggle(content, "Names",            cfg.nameEnabled,   function(v) cfg.nameEnabled=v end)
    mkToggle(content, "Health Bars",      cfg.healthEnabled, function(v) cfg.healthEnabled=v end)
    mkToggle(content, "Team Check",       cfg.espTeamCheck,  function(v) cfg.espTeamCheck=v; refreshChams() end)
end

local function pageAimbot()
    clearContent()
    mkSection(content, "Aimbot")
    mkToggle(content, "Enabled  [LAlt]",  cfg.aimbotEnabled, function(v) cfg.aimbotEnabled=v; updateFovCircle() end)
    mkSlider(content, "FOV Radius",        30, 500, cfg.aimbotFOV,  nil, function(v) cfg.aimbotFOV=v; updateFovCircle() end)
    mkSlider(content, "Snap Speed",        1, 100, math.floor(cfg.aimbotSmooth*100), nil, function(v) cfg.aimbotSmooth=v/100 end)
    mkToggle(content, "FOV Circle",       cfg.aimbotFOVvis,  function(v) cfg.aimbotFOVvis=v; updateFovCircle() end)
    mkToggle(content, "Velocity Predict", cfg.aimbotVelPred, function(v) cfg.aimbotVelPred=v end)
    mkSection(content, "Auto Win")
    mkToggle(content, "Auto Win",         cfg.autoWin,       function(v) cfg.autoWin=v end)
    mkSlider(content, "Auto Win FOV",      30, 800, cfg.autoWinFOV, nil, function(v) cfg.autoWinFOV=v end)
end

local TABS = {{"ESP", pageESP}, {"AIM", pageAimbot}}
local tabBtns = {}
for i, t in ipairs(TABS) do
    local b = Instance.new("TextButton", tabBar)
    b.Size = UDim2.new(0,80,1,0); b.BackgroundColor3 = Color3.fromRGB(16,16,32)
    b.Text = t[1]; b.TextColor3 = Color3.fromRGB(120,120,155)
    b.Font = Enum.Font.GothamBold; b.TextSize = 10; b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    tabBtns[i] = b
    local idx = i
    b.MouseButton1Click:Connect(function()
        for _,tb in ipairs(tabBtns) do
            tw(tb, {BackgroundColor3=Color3.fromRGB(16,16,32), TextColor3=Color3.fromRGB(120,120,155)}, .12)
        end
        tw(b, {BackgroundColor3=Color3.fromRGB(0,80,190), TextColor3=Color3.fromRGB(255,255,255)}, .12)
        TABS[idx][2]()
    end)
end
tw(tabBtns[1], {BackgroundColor3=Color3.fromRGB(0,80,190), TextColor3=Color3.fromRGB(255,255,255)}, 0)

-- ══════════════════════════════════════════════════════════════
--  PANEL OPEN / DRAG
-- ══════════════════════════════════════════════════════════════
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0,50,0,50); openBtn.Position = UDim2.new(0,10,0,10)
openBtn.BackgroundColor3 = Color3.fromRGB(0,80,190); openBtn.Text = "⬡"
openBtn.TextColor3 = Color3.fromRGB(255,255,255); openBtn.Font = Enum.Font.GothamBold; openBtn.TextSize = 24
openBtn.BorderSizePixel = 0; openBtn.ZIndex = 10
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", openBtn).Color = Color3.fromRGB(0,150,255)

local panelOpen = false
local function togglePanel()
    panelOpen = not panelOpen
    tw(panel, {Position = panelOpen and UDim2.new(0.5,-170,0.5,-260) or UDim2.new(0.5,-170,1,20)}, .22)
end
openBtn.MouseButton1Click:Connect(togglePanel)
xbtn.MouseButton1Click:Connect(function() if panelOpen then togglePanel() end end)

-- Drag panel
local dragging, dragStart, startPos = false, nil, nil
hdr.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = i.Position; startPos = panel.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if not dragging then return end
    if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    local delta = i.Position - dragStart
    panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- Keybind: Insert to toggle
UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.Insert then togglePanel() end
end)

-- ══════════════════════════════════════════════════════════════
--  FOV CIRCLE (Drawing)
-- ══════════════════════════════════════════════════════════════
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false; fovCircle.Thickness = 1.5
fovCircle.Color = Color3.fromRGB(255,255,255); fovCircle.Transparency = 0.6
fovCircle.Filled = false; fovCircle.NumSides = 64

local function updateFovCircle()
    local show = cfg.aimbotEnabled and cfg.aimbotFOVvis
    fovCircle.Visible = show
    if show then
        fovCircle.Radius = cfg.aimbotFOV
        fovCircle.Position = Vector2.new(cam.ViewportSize.X*.5, cam.ViewportSize.Y*.5)
    end
end
updateFovCircle()

-- ══════════════════════════════════════════════════════════════
--  RAINBOW HELPER
-- ══════════════════════════════════════════════════════════════
local rainbowHue = 0
local function getRainbow() return Color3.fromHSV(rainbowHue, 1, 1) end

-- ══════════════════════════════════════════════════════════════
--  CHAMS — Highlight instances (through-wall, fill = chams look)
-- ══════════════════════════════════════════════════════════════
local chamsHL = {}

local function removeChams(p)
    if chamsHL[p] then pcall(function() chamsHL[p]:Destroy() end); chamsHL[p] = nil end
end

local function makeChams(p)
    removeChams(p)
    if p == lp then return end
    if cfg.espTeamCheck and p.Team == lp.Team then return end
    local char = p.Character; if not char then return end
    local hl = Instance.new("Highlight")
    hl.FillColor = cfg.chamsColor
    hl.OutlineColor = cfg.chamsOutline
    hl.FillTransparency = cfg.chamsEnabled and cfg.chamsFillTrans or 1
    hl.OutlineTransparency = cfg.chamsEnabled and 0 or 1
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = char; hl.Parent = char
    chamsHL[p] = hl
end

function refreshChams()
    for p, hl in pairs(chamsHL) do
        pcall(function()
            local hide = (not cfg.chamsEnabled) or (cfg.espTeamCheck and p.Team == lp.Team)
            hl.FillTransparency    = hide and 1 or cfg.chamsFillTrans
            hl.OutlineTransparency = hide and 1 or 0
            if not cfg.rainbowChams then hl.FillColor = cfg.chamsColor end
        end)
    end
end

local function onPlayerAdded(p)
    if p == lp then return end
    task.wait(0.5); makeChams(p)
    p.CharacterAdded:Connect(function() task.wait(0.5); makeChams(p) end)
end
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(function(p) removeChams(p) end)
for _, p in ipairs(Players:GetPlayers()) do task.spawn(onPlayerAdded, p) end

-- ══════════════════════════════════════════════════════════════
--  TARGET FINDING (sticky lock)
-- ══════════════════════════════════════════════════════════════
local function w2s(pos)
    local v, on = cam:WorldToViewportPoint(pos)
    return Vector2.new(v.X, v.Y), on, v.Z
end

local lockedTarget = nil

local function bestTarget(fov)
    local center = Vector2.new(cam.ViewportSize.X*.5, cam.ViewportSize.Y*.5)

    if lockedTarget then
        local char = lockedTarget.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            local bone = char:FindFirstChild(cfg.aimbotBone) or char:FindFirstChild("HumanoidRootPart")
            if bone then
                local pos = bone.Position
                pcall(function() if cfg.aimbotVelPred then pos = pos + bone.AssemblyLinearVelocity*0.065 end end)
                local s, on = w2s(pos)
                if on then
                    local lockDist = (s-center).Magnitude
                    local bp2, bpos2, bd2 = nil, nil, math.huge
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p == lp or p == lockedTarget then continue end
                        if cfg.espTeamCheck and p.Team == lp.Team then continue end
                        local c2 = p.Character; if not c2 then continue end
                        local h2 = c2:FindFirstChildOfClass("Humanoid")
                        if not h2 or h2.Health <= 0 then continue end
                        local b2 = c2:FindFirstChild(cfg.aimbotBone) or c2:FindFirstChild("HumanoidRootPart"); if not b2 then continue end
                        local p2 = b2.Position
                        pcall(function() if cfg.aimbotVelPred then p2 = p2 + b2.AssemblyLinearVelocity*0.065 end end)
                        local s2, on2 = w2s(p2); if not on2 then continue end
                        local d2 = (s2-center).Magnitude
                        if d2 < bd2 and d2 < fov then bd2=d2; bp2=p; bpos2=p2 end
                    end
                    if bp2 and bd2 < lockDist*0.5 then lockedTarget=bp2; return bp2,bpos2 end
                    return lockedTarget, pos
                end
            end
        end
        lockedTarget = nil
    end

    local bp, bpos, bd = nil, nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p == lp then continue end
        if cfg.espTeamCheck and p.Team == lp.Team then continue end
        local char = p.Character; if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local bone = char:FindFirstChild(cfg.aimbotBone) or char:FindFirstChild("HumanoidRootPart"); if not bone then continue end
        local pos = bone.Position
        pcall(function() if cfg.aimbotVelPred then pos = pos + bone.AssemblyLinearVelocity*0.065 end end)
        local s, on = w2s(pos); if not on then continue end
        local d = (s-center).Magnitude
        if d < bd and d < fov then bd=d; bp=p; bpos=pos end
    end
    if bp then lockedTarget = bp end
    return bp, bpos
end

-- ══════════════════════════════════════════════════════════════
--  ESP DRAWING OBJECTS (boxes, tracers, names, health)
-- ══════════════════════════════════════════════════════════════
local espObjs = {}  -- [player] = {box, boxFill, tracer, name, hpBar, hpBarBg}

local function newDrawing(type, props)
    local d = Drawing.new(type)
    for k,v in pairs(props) do pcall(function() d[k]=v end) end
    return d
end

local function getESPObjs(p)
    if not espObjs[p] then
        espObjs[p] = {
            box      = newDrawing("Square",    {Visible=false, Thickness=1, Filled=false, Color=Color3.fromRGB(255,255,255)}),
            boxFill  = newDrawing("Square",    {Visible=false, Thickness=0, Filled=true,  Color=Color3.fromRGB(255,255,255), Transparency=cfg.boxFillAlpha}),
            tracer   = newDrawing("Line",      {Visible=false, Thickness=1, Color=Color3.fromRGB(255,50,50)}),
            name     = newDrawing("Text",      {Visible=false, Size=cfg.nameSize, Center=true, Outline=true, Color=Color3.fromRGB(255,255,255), OutlineColor=Color3.fromRGB(0,0,0)}),
            hpBg     = newDrawing("Square",    {Visible=false, Thickness=0, Filled=true,  Color=Color3.fromRGB(0,0,0), Transparency=0.5}),
            hpBar    = newDrawing("Square",    {Visible=false, Thickness=0, Filled=true,  Color=Color3.fromRGB(50,255,50)}),
        }
    end
    return espObjs[p]
end

local function removeESPObjs(p)
    if espObjs[p] then
        for _, d in pairs(espObjs[p]) do pcall(function() d:Remove() end) end
        espObjs[p] = nil
    end
end

Players.PlayerRemoving:Connect(removeESPObjs)

-- ══════════════════════════════════════════════════════════════
--  AUTO WIN REMOTES SCAN
-- ══════════════════════════════════════════════════════════════
local attackRemotes = {}
local function scanRemotes()
    attackRemotes = {}
    local function scan(obj)
        for _, v in ipairs(obj:GetChildren()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                local n = v.Name:lower()
                if n:find("attack") or n:find("hit") or n:find("damage") or n:find("swing")
                or n:find("strike") or n:find("punch") or n:find("slash") or n:find("combat") then
                    table.insert(attackRemotes, v)
                end
            end
            scan(v)
        end
    end
    pcall(scan, game:GetService("ReplicatedStorage"))
    pcall(scan, workspace)
end
task.spawn(scanRemotes)
task.spawn(function() while task.wait(8) do scanRemotes() end end)

-- ══════════════════════════════════════════════════════════════
--  RENDER LOOP
-- ══════════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function(dt)
    -- Rainbow hue tick
    rainbowHue = (rainbowHue + dt*0.4) % 1
    local rbCol = getRainbow()

    -- FOV circle
    updateFovCircle()

    -- Aimbot (hold LAlt)
    if cfg.aimbotEnabled and UserInputService:IsKeyDown(cfg.aimbotKey) then
        local _, pos = bestTarget(cfg.aimbotFOV)
        if pos then
            pcall(function()
                cam.CFrame = cam.CFrame:Lerp(CFrame.new(cam.CFrame.Position, pos), cfg.aimbotSmooth)
            end)
        end
    end

    -- ESP + Chams per player
    for _, p in ipairs(Players:GetPlayers()) do
        if p == lp then continue end
        if cfg.espTeamCheck and p.Team == lp.Team then
            removeESPObjs(p); continue
        end

        local char = p.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")

        if not char or not hum or not root or not head or hum.Health <= 0 then
            local o = espObjs[p]
            if o then for _,d in pairs(o) do pcall(function() d.Visible=false end) end end
            continue
        end

        local o = getESPObjs(p)

        -- Rainbow chams
        if cfg.rainbowChams and chamsHL[p] then
            pcall(function() chamsHL[p].FillColor = rbCol end)
        end

        -- World corners for bounding box
        local rootPos = root.Position
        local headPos = head.Position

        local topScreen,    topOn    = w2s(headPos + Vector3.new(0, 0.7, 0))
        local bottomScreen, bottomOn = w2s(rootPos  - Vector3.new(0, 2.8, 0))

        if not topOn or not bottomOn then
            for _, d in pairs(o) do pcall(function() d.Visible=false end) end
            continue
        end

        local h = math.abs(bottomScreen.Y - topScreen.Y)
        local w = h * 0.55
        local cx = topScreen.X
        local ty = topScreen.Y

        local espColor = cfg.rainbowChams and rbCol or Color3.fromRGB(255,255,255)

        -- Box
        if cfg.boxEnabled then
            o.box.Visible   = true
            o.box.Size      = Vector2.new(w, h)
            o.box.Position  = Vector2.new(cx - w*.5, ty)
            o.box.Color     = espColor
            o.box.Thickness = cfg.boxThick
            if cfg.boxFill then
                o.boxFill.Visible      = true
                o.boxFill.Size         = Vector2.new(w, h)
                o.boxFill.Position     = Vector2.new(cx - w*.5, ty)
                o.boxFill.Color        = espColor
                o.boxFill.Transparency = cfg.boxFillAlpha
            else
                o.boxFill.Visible = false
            end
        else
            o.box.Visible = false; o.boxFill.Visible = false
        end

        -- Tracer
        if cfg.tracerEnabled then
            local tracerCol = cfg.tracerRainbow and rbCol or cfg.tracerColor
            local origin
            if cfg.tracerOrigin == "Bottom" then
                origin = Vector2.new(cam.ViewportSize.X*.5, cam.ViewportSize.Y)
            else
                origin = Vector2.new(cam.ViewportSize.X*.5, cam.ViewportSize.Y*.5)
            end
            o.tracer.Visible   = true
            o.tracer.From      = origin
            o.tracer.To        = Vector2.new(cx, bottomScreen.Y)
            o.tracer.Color     = tracerCol
            o.tracer.Thickness = cfg.tracerThick
        else
            o.tracer.Visible = false
        end

        -- Name
        if cfg.nameEnabled then
            o.name.Visible   = true
            o.name.Text      = p.Name
            o.name.Position  = Vector2.new(cx, ty - 14)
            o.name.Color     = espColor
            o.name.Size      = cfg.nameSize
        else
            o.name.Visible = false
        end

        -- Health bar (left side of box)
        if cfg.healthEnabled then
            local hp    = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local bx    = cx - w*.5 - 6
            local barH  = h * hp
            local g     = math.floor(hp * 255)
            local r     = math.floor((1-hp) * 255)
            o.hpBg.Visible   = true
            o.hpBg.Size      = Vector2.new(3, h)
            o.hpBg.Position  = Vector2.new(bx, ty)
            o.hpBar.Visible  = true
            o.hpBar.Size     = Vector2.new(3, barH)
            o.hpBar.Position = Vector2.new(bx, ty + h - barH)
            o.hpBar.Color    = Color3.fromRGB(r, g, 0)
        else
            o.hpBg.Visible = false; o.hpBar.Visible = false
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  AUTO WIN HEARTBEAT
-- ══════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    if not cfg.autoWin then return end
    local bp = bestTarget(cfg.autoWinFOV)
    if not bp then return end
    local char = lp.Character; if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart"); if not root then return end
    local tc = bp.Character; if not tc then return end
    local tr = tc:FindFirstChild("HumanoidRootPart"); if not tr then return end
    local thead = tc:FindFirstChild("Head") or tr

    -- Teleport onto target
    pcall(function()
        root.CFrame = CFrame.new(tr.Position, tr.Position + tr.CFrame.LookVector)
    end)

    -- Activate all tools
    pcall(function()
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Tool") then
                pcall(function() obj:Activate() end)
                for _, v in ipairs(obj:GetDescendants()) do
                    if v:IsA("RemoteEvent") then
                        pcall(function() v:FireServer(thead.CFrame.Position) end)
                    end
                end
            end
        end
    end)

    -- Fire known attack remotes
    for _, remote in ipairs(attackRemotes) do
        if remote:IsA("RemoteEvent") then
            pcall(function() remote:FireServer(thead.CFrame.Position, thead) end)
        end
    end
end)

-- ══════════════════════════════════════════════════════════════
--  CLEANUP
-- ══════════════════════════════════════════════════════════════
game:BindToClose(function()
    for p in pairs(chamsHL) do removeChams(p) end
    for p in pairs(espObjs)  do removeESPObjs(p) end
    pcall(function() fovCircle:Remove() end)
end)

-- Build first tab
pageESP()

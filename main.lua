--[[
    ██╗   ██╗ ██████╗ ██████╗  █████╗    ██████╗  ██████╗
    ██║   ██║██╔═══██╗██╔══██╗██╔══██╗  ██╔════╝ ██╔════╝
    ██║   ██║██║   ██║██████╔╝███████║  ██║  ███╗██║  ███╗
    ╚██╗ ██╔╝██║   ██║██╔══██╗██╔══██║  ██║   ██║██║   ██║
     ╚████╔╝ ╚██████╔╝██║  ██║██║  ██║  ╚██████╔╝╚██████╔╝
      ╚═══╝   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═════╝  ╚═════╝
    Vora.gg  —  Rivals  |  PC  v2
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
    chamsEnabled  = true,
    rainbowChams  = false,
    chamsColor    = Color3.fromRGB(220, 55, 55),
    chamsOutline  = Color3.fromRGB(255, 255, 255),
    chamsFillTrans= 0.45,

    -- Tracers
    tracerEnabled = false,
    tracerOrigin  = "Bottom",
    tracerThick   = 1.5,
    tracerColor   = Color3.fromRGB(220, 55, 55),
    tracerRainbow = false,

    -- ESP Boxes
    boxEnabled    = true,
    boxThick      = 1,
    boxColor      = Color3.fromRGB(255, 255, 255),
    boxFill       = true,
    boxFillAlpha  = 0.05,

    -- Labels
    nameEnabled   = true,
    nameSize      = 13,
    healthEnabled = true,

    -- Aimbot  (Right Mouse Button)
    aimbotEnabled  = false,
    aimbotFOV      = 150,
    aimbotSmooth   = 12,    -- speed multiplier, dt-based (higher = snappier)
    aimbotSnapDist = 8,     -- px: snap instantly when this close to target
    aimbotBone     = "Head",
    aimbotVelPred  = true,
    aimbotFOVvis   = true,

    -- Auto Win
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

local function tw(o, p, t)
    pcall(function() TweenService:Create(o, TweenInfo.new(t or 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), p):Play() end)
end

-- ══════════════════════════════════════════════════════════════
--  PANEL — sleek dark glass design
-- ══════════════════════════════════════════════════════════════
local PANEL_W, PANEL_H = 360, 540

local panel = Instance.new("Frame", gui)
panel.Name = "Panel"
panel.Size = UDim2.new(0, PANEL_W, 0, PANEL_H)
panel.Position = UDim2.new(0.5, -PANEL_W/2, 1, 20)
panel.BackgroundColor3 = Color3.fromRGB(8, 8, 18)
panel.BorderSizePixel = 0
panel.ClipsDescendants = true
local panelCorner = Instance.new("UICorner", panel)
panelCorner.CornerRadius = UDim.new(0, 16)
local panelStroke = Instance.new("UIStroke", panel)
panelStroke.Color = Color3.fromRGB(40, 40, 80)
panelStroke.Thickness = 1
panelStroke.Transparency = 0.0

-- Subtle top glow bar
local glowBar = Instance.new("Frame", panel)
glowBar.Size = UDim2.new(1, 0, 0, 2)
glowBar.Position = UDim2.new(0, 0, 0, 0)
glowBar.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
glowBar.BorderSizePixel = 0
glowBar.ZIndex = 5

-- Header
local hdr = Instance.new("Frame", panel)
hdr.Size = UDim2.new(1, 0, 0, 52)
hdr.Position = UDim2.new(0, 0, 0, 0)
hdr.BackgroundColor3 = Color3.fromRGB(12, 12, 26)
hdr.BorderSizePixel = 0
hdr.ZIndex = 2

local hdrSep = Instance.new("Frame", panel)
hdrSep.Size = UDim2.new(1, -24, 0, 1)
hdrSep.Position = UDim2.new(0, 12, 0, 52)
hdrSep.BackgroundColor3 = Color3.fromRGB(35, 35, 70)
hdrSep.BorderSizePixel = 0
hdrSep.ZIndex = 2

-- Logo mark (hex icon)
local logoIcon = Instance.new("TextLabel", hdr)
logoIcon.Size = UDim2.new(0, 36, 0, 36)
logoIcon.Position = UDim2.new(0, 12, 0.5, -18)
logoIcon.BackgroundColor3 = Color3.fromRGB(60, 100, 255)
logoIcon.BackgroundTransparency = 0
logoIcon.BorderSizePixel = 0
logoIcon.Text = "V"
logoIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
logoIcon.Font = Enum.Font.GothamBlack
logoIcon.TextSize = 18
Instance.new("UICorner", logoIcon).CornerRadius = UDim.new(0, 8)

local logoTitle = Instance.new("TextLabel", hdr)
logoTitle.Size = UDim2.new(0, 120, 0, 20)
logoTitle.Position = UDim2.new(0, 56, 0.5, -18)
logoTitle.BackgroundTransparency = 1
logoTitle.Text = "VORA.GG"
logoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
logoTitle.Font = Enum.Font.GothamBlack
logoTitle.TextSize = 15
logoTitle.TextXAlignment = Enum.TextXAlignment.Left

local logoSub = Instance.new("TextLabel", hdr)
logoSub.Size = UDim2.new(0, 120, 0, 14)
logoSub.Position = UDim2.new(0, 56, 0.5, 4)
logoSub.BackgroundTransparency = 1
logoSub.Text = "RIVALS  •  PC"
logoSub.TextColor3 = Color3.fromRGB(80, 90, 140)
logoSub.Font = Enum.Font.GothamBold
logoSub.TextSize = 9
logoSub.TextXAlignment = Enum.TextXAlignment.Left

-- Status pill (shows active features count)
local statusPill = Instance.new("Frame", hdr)
statusPill.Size = UDim2.new(0, 70, 0, 22)
statusPill.Position = UDim2.new(1, -110, 0.5, -11)
statusPill.BackgroundColor3 = Color3.fromRGB(20, 60, 20)
statusPill.BorderSizePixel = 0
Instance.new("UICorner", statusPill).CornerRadius = UDim.new(1, 0)
local statusLabel = Instance.new("TextLabel", statusPill)
statusLabel.Size = UDim2.new(1, 0, 1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "● LIVE"
statusLabel.TextColor3 = Color3.fromRGB(80, 220, 80)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 9

local xbtn = Instance.new("TextButton", hdr)
xbtn.Size = UDim2.new(0, 28, 0, 28)
xbtn.Position = UDim2.new(1, -42, 0.5, -14)
xbtn.BackgroundColor3 = Color3.fromRGB(50, 20, 20)
xbtn.Text = "✕"
xbtn.TextColor3 = Color3.fromRGB(200, 80, 80)
xbtn.Font = Enum.Font.GothamBold
xbtn.TextSize = 12
xbtn.BorderSizePixel = 0
Instance.new("UICorner", xbtn).CornerRadius = UDim.new(0, 7)

-- ══════════════════════════════════════════════════════════════
--  TAB BAR
-- ══════════════════════════════════════════════════════════════
local tabBar = Instance.new("Frame", panel)
tabBar.Size = UDim2.new(1, -16, 0, 34)
tabBar.Position = UDim2.new(0, 8, 0, 60)
tabBar.BackgroundColor3 = Color3.fromRGB(14, 14, 28)
tabBar.BorderSizePixel = 0
Instance.new("UICorner", tabBar).CornerRadius = UDim.new(0, 10)
local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 2)
local tabPad = Instance.new("UIPadding", tabBar)
tabPad.PaddingLeft = UDim.new(0, 3); tabPad.PaddingRight = UDim.new(0, 3)
tabPad.PaddingTop = UDim.new(0, 3); tabPad.PaddingBottom = UDim.new(0, 3)

-- ══════════════════════════════════════════════════════════════
--  CONTENT SCROLL
-- ══════════════════════════════════════════════════════════════
local content = Instance.new("ScrollingFrame", panel)
content.Size = UDim2.new(1, -8, 1, -104)
content.Position = UDim2.new(0, 4, 0, 100)
content.BackgroundTransparency = 1
content.ScrollBarThickness = 2
content.ScrollBarImageColor3 = Color3.fromRGB(60, 90, 200)
content.BorderSizePixel = 0
content.CanvasSize = UDim2.new(0, 0, 0, 0)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
local contentLayout = Instance.new("UIListLayout", content)
contentLayout.Padding = UDim.new(0, 4)
local contentPad = Instance.new("UIPadding", content)
contentPad.PaddingLeft = UDim.new(0, 4)
contentPad.PaddingRight = UDim.new(0, 4)
contentPad.PaddingTop = UDim.new(0, 6)
contentPad.PaddingBottom = UDim.new(0, 8)

-- ══════════════════════════════════════════════════════════════
--  WIDGET FACTORY
-- ══════════════════════════════════════════════════════════════

-- Section header
local function mkSection(par, lbl, icon)
    local row = Instance.new("Frame", par)
    row.Size = UDim2.new(1, 0, 0, 28)
    row.BackgroundTransparency = 1

    local line = Instance.new("Frame", row)
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = Color3.fromRGB(28, 28, 55)
    line.BorderSizePixel = 0

    local bg = Instance.new("Frame", row)
    bg.Size = UDim2.new(0, 0, 1, 0)
    bg.AutomaticSize = Enum.AutomaticSize.X
    bg.Position = UDim2.new(0, 0, 0, 0)
    bg.BackgroundColor3 = Color3.fromRGB(8, 8, 18)
    bg.BorderSizePixel = 0

    local txt = Instance.new("TextLabel", bg)
    txt.Size = UDim2.new(0, 0, 1, 0)
    txt.AutomaticSize = Enum.AutomaticSize.X
    txt.BackgroundTransparency = 1
    txt.Text = (icon and icon.." " or "") .. lbl:upper()
    txt.TextColor3 = Color3.fromRGB(60, 100, 220)
    txt.Font = Enum.Font.GothamBlack
    txt.TextSize = 9
    txt.TextXAlignment = Enum.TextXAlignment.Left
    local tp = Instance.new("UIPadding", txt)
    tp.PaddingRight = UDim.new(0, 10)
end

-- Toggle row
local function mkToggle(par, lbl, desc, state, cb)
    local row = Instance.new("Frame", par)
    row.Size = UDim2.new(1, 0, 0, desc and 52 or 42)
    row.BackgroundColor3 = Color3.fromRGB(13, 13, 26)
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
    local rowStroke = Instance.new("UIStroke", row)
    rowStroke.Color = Color3.fromRGB(28, 28, 55)
    rowStroke.Thickness = 1

    local labelTxt = Instance.new("TextLabel", row)
    labelTxt.Size = UDim2.new(1, -72, 0, 20)
    labelTxt.Position = UDim2.new(0, 14, 0, desc and 8 or 11)
    labelTxt.BackgroundTransparency = 1
    labelTxt.TextColor3 = Color3.fromRGB(220, 220, 240)
    labelTxt.Font = Enum.Font.GothamBold
    labelTxt.TextSize = 13
    labelTxt.TextXAlignment = Enum.TextXAlignment.Left
    labelTxt.Text = lbl

    if desc then
        local descTxt = Instance.new("TextLabel", row)
        descTxt.Size = UDim2.new(1, -72, 0, 14)
        descTxt.Position = UDim2.new(0, 14, 0, 28)
        descTxt.BackgroundTransparency = 1
        descTxt.TextColor3 = Color3.fromRGB(70, 75, 110)
        descTxt.Font = Enum.Font.Gotham
        descTxt.TextSize = 10
        descTxt.TextXAlignment = Enum.TextXAlignment.Left
        descTxt.Text = desc
    end

    -- Toggle track
    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(0, 46, 0, 26)
    track.Position = UDim2.new(1, -58, 0.5, -13)
    track.BackgroundColor3 = state and Color3.fromRGB(50, 110, 255) or Color3.fromRGB(32, 32, 55)
    track.BorderSizePixel = 0
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local trackStroke = Instance.new("UIStroke", track)
    trackStroke.Color = state and Color3.fromRGB(80, 140, 255) or Color3.fromRGB(50, 50, 80)
    trackStroke.Thickness = 1

    local knob = Instance.new("Frame", track)
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    local knobShadow = Instance.new("UIStroke", knob)
    knobShadow.Color = Color3.fromRGB(0, 0, 0)
    knobShadow.Transparency = 0.7
    knobShadow.Thickness = 1

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    local val = state
    btn.MouseButton1Click:Connect(function()
        val = not val
        tw(track, {BackgroundColor3 = val and Color3.fromRGB(50, 110, 255) or Color3.fromRGB(32, 32, 55)}, 0.15)
        tw(trackStroke, {Color = val and Color3.fromRGB(80, 140, 255) or Color3.fromRGB(50, 50, 80)}, 0.15)
        tw(knob, {Position = val and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)}, 0.15)
        pcall(cb, val)
    end)
    return {track=track, knob=knob, get=function() return val end}
end

-- Slider row
local function mkSlider(par, lbl, mn, mx, val, fmt, cb)
    local row = Instance.new("Frame", par)
    row.Size = UDim2.new(1, 0, 0, 60)
    row.BackgroundColor3 = Color3.fromRGB(13, 13, 26)
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
    local rowStroke = Instance.new("UIStroke", row)
    rowStroke.Color = Color3.fromRGB(28, 28, 55)
    rowStroke.Thickness = 1

    local labelTxt = Instance.new("TextLabel", row)
    labelTxt.Size = UDim2.new(0.6, 0, 0, 18)
    labelTxt.Position = UDim2.new(0, 14, 0, 10)
    labelTxt.BackgroundTransparency = 1
    labelTxt.TextColor3 = Color3.fromRGB(200, 200, 220)
    labelTxt.Font = Enum.Font.GothamBold
    labelTxt.TextSize = 12
    labelTxt.TextXAlignment = Enum.TextXAlignment.Left
    labelTxt.Text = lbl

    local valLabel = Instance.new("TextLabel", row)
    valLabel.Size = UDim2.new(0.4, -14, 0, 18)
    valLabel.Position = UDim2.new(0.6, 0, 0, 10)
    valLabel.BackgroundTransparency = 1
    valLabel.TextColor3 = Color3.fromRGB(70, 120, 255)
    valLabel.Font = Enum.Font.GothamBlack
    valLabel.TextSize = 13
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Text = fmt and fmt(val) or tostring(val)

    -- Track
    local trk = Instance.new("Frame", row)
    trk.Size = UDim2.new(1, -28, 0, 4)
    trk.Position = UDim2.new(0, 14, 0, 42)
    trk.BackgroundColor3 = Color3.fromRGB(25, 25, 50)
    trk.BorderSizePixel = 0
    Instance.new("UICorner", trk).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", trk)
    fill.Size = UDim2.new((val - mn) / (mx - mn), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(60, 110, 255)
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    -- Thumb
    local thumb = Instance.new("Frame", trk)
    thumb.Size = UDim2.new(0, 14, 0, 14)
    thumb.Position = UDim2.new((val - mn) / (mx - mn), -7, 0.5, -7)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
    local thumbStroke = Instance.new("UIStroke", thumb)
    thumbStroke.Color = Color3.fromRGB(60, 110, 255)
    thumbStroke.Thickness = 2

    local drag = Instance.new("TextButton", row)
    drag.Size = UDim2.new(1, 0, 0, 30)
    drag.Position = UDim2.new(0, 0, 0, 30)
    drag.BackgroundTransparency = 1
    drag.Text = ""
    local dragging, tid = false, nil
    drag.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; tid = i end
    end)
    UserInputService.InputEnded:Connect(function(i) if i == tid then dragging = false; tid = nil end end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
        local rel = math.clamp((i.Position.X - trk.AbsolutePosition.X) / trk.AbsoluteSize.X, 0, 1)
        local nv = math.floor(mn + rel * (mx - mn) + 0.5)
        valLabel.Text = fmt and fmt(nv) or tostring(nv)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        thumb.Position = UDim2.new(rel, -7, 0.5, -7)
        pcall(cb, nv)
    end)
end

-- Info row (key bind display etc)
local function mkInfo(par, lbl, val)
    local row = Instance.new("Frame", par)
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    row.BorderSizePixel = 0
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
    local rowStroke = Instance.new("UIStroke", row)
    rowStroke.Color = Color3.fromRGB(25, 25, 50)
    rowStroke.Thickness = 1

    local l = Instance.new("TextLabel", row)
    l.Size = UDim2.new(0.55, 0, 1, 0)
    l.Position = UDim2.new(0, 14, 0, 0)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.fromRGB(130, 135, 175)
    l.Font = Enum.Font.Gotham
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = lbl

    local badge = Instance.new("Frame", row)
    badge.Size = UDim2.new(0, 0, 0, 20)
    badge.AutomaticSize = Enum.AutomaticSize.X
    badge.Position = UDim2.new(1, -14, 0.5, -10)
    badge.AnchorPoint = Vector2.new(1, 0)
    badge.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
    badge.BorderSizePixel = 0
    Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 5)
    local badgeStroke = Instance.new("UIStroke", badge)
    badgeStroke.Color = Color3.fromRGB(50, 55, 100)
    badgeStroke.Thickness = 1

    local vl = Instance.new("TextLabel", badge)
    vl.Size = UDim2.new(0, 0, 1, 0)
    vl.AutomaticSize = Enum.AutomaticSize.X
    vl.BackgroundTransparency = 1
    vl.TextColor3 = Color3.fromRGB(160, 175, 255)
    vl.Font = Enum.Font.GothamBold
    vl.TextSize = 10
    vl.Text = val
    local vp = Instance.new("UIPadding", vl)
    vp.PaddingLeft = UDim.new(0, 8); vp.PaddingRight = UDim.new(0, 8)
end

-- ══════════════════════════════════════════════════════════════
--  TAB PAGES
-- ══════════════════════════════════════════════════════════════
local function clearContent()
    for _, c in ipairs(content:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end
    local l2 = Instance.new("UIListLayout", content)
    l2.Padding = UDim.new(0, 4)
    local p2 = Instance.new("UIPadding", content)
    p2.PaddingLeft = UDim.new(0, 4)
    p2.PaddingRight = UDim.new(0, 4)
    p2.PaddingTop = UDim.new(0, 6)
    p2.PaddingBottom = UDim.new(0, 8)
end

local function pageESP()
    clearContent()
    mkSection(content, "Chams", "◈")
    mkToggle(content, "Chams", "Through-wall highlight", cfg.chamsEnabled, function(v) cfg.chamsEnabled=v; refreshChams() end)
    mkToggle(content, "Rainbow Chams", "HSV color cycle", cfg.rainbowChams, function(v) cfg.rainbowChams=v end)
    mkSlider(content, "Fill Opacity", 0, 100, math.floor((1-cfg.chamsFillTrans)*100), function(v) return v.."%" end, function(v)
        cfg.chamsFillTrans = 1 - (v/100); refreshChams()
    end)

    mkSection(content, "ESP Boxes", "□")
    mkToggle(content, "Boxes", "2D bounding box", cfg.boxEnabled, function(v) cfg.boxEnabled=v end)
    mkToggle(content, "Box Fill", "Transparent inner fill", cfg.boxFill, function(v) cfg.boxFill=v end)

    mkSection(content, "Tracers", "╱")
    mkToggle(content, "Tracers", "Line from screen edge", cfg.tracerEnabled, function(v) cfg.tracerEnabled=v end)
    mkToggle(content, "Rainbow Tracers", "HSV color cycle", cfg.tracerRainbow, function(v) cfg.tracerRainbow=v end)
    mkSlider(content, "Thickness", 1, 5, cfg.tracerThick, function(v) return v.."px" end, function(v) cfg.tracerThick=v end)

    mkSection(content, "Labels", "≡")
    mkToggle(content, "Player Names", nil, cfg.nameEnabled, function(v) cfg.nameEnabled=v end)
    mkToggle(content, "Health Bars", nil, cfg.healthEnabled, function(v) cfg.healthEnabled=v end)
    mkToggle(content, "Team Check", "Skip teammates", cfg.espTeamCheck, function(v) cfg.espTeamCheck=v; refreshChams() end)
end

local function pageAimbot()
    clearContent()
    mkSection(content, "Aimbot", "⊕")
    mkToggle(content, "Aimbot", "Hold Right Mouse Button", cfg.aimbotEnabled, function(v) cfg.aimbotEnabled=v; updateFovCircle() end)
    mkInfo(content, "Activation key", "RMB (Hold)")
    mkSlider(content, "FOV Radius", 30, 500, cfg.aimbotFOV, function(v) return v.."px" end, function(v) cfg.aimbotFOV=v; updateFovCircle() end)
    mkSlider(content, "Smoothness", 1, 30, cfg.aimbotSmooth, function(v)
        if v <= 5 then return "Smooth"
        elseif v <= 15 then return "Balanced ("..v..")"
        else return "Snap ("..v..")" end
    end, function(v) cfg.aimbotSmooth=v end)
    mkToggle(content, "FOV Circle", "Show FOV ring on screen", cfg.aimbotFOVvis, function(v) cfg.aimbotFOVvis=v; updateFovCircle() end)
    mkToggle(content, "Velocity Prediction", "Lead moving targets", cfg.aimbotVelPred, function(v) cfg.aimbotVelPred=v end)

    mkSection(content, "Auto Win", "⚡")
    mkToggle(content, "Auto Win", "Teleport + attack spam", cfg.autoWin, function(v) cfg.autoWin=v end)
    mkSlider(content, "Auto Win FOV", 30, 800, cfg.autoWinFOV, function(v) return v.."px" end, function(v) cfg.autoWinFOV=v end)
end

-- ══════════════════════════════════════════════════════════════
--  TAB BUTTONS
-- ══════════════════════════════════════════════════════════════
local TABS = {
    {"ESP",  "◈", pageESP},
    {"AIM",  "⊕", pageAimbot},
}
local tabBtns = {}
for i, t in ipairs(TABS) do
    local b = Instance.new("TextButton", tabBar)
    b.Size = UDim2.new(1/#TABS, -2, 1, 0)
    b.BackgroundColor3 = Color3.fromRGB(14, 14, 28)
    b.Text = t[2].."  "..t[1]
    b.TextColor3 = Color3.fromRGB(80, 85, 130)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.BorderSizePixel = 0
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    tabBtns[i] = b
    local idx = i
    b.MouseButton1Click:Connect(function()
        for _, tb in ipairs(tabBtns) do
            tw(tb, {BackgroundColor3=Color3.fromRGB(14,14,28), TextColor3=Color3.fromRGB(80,85,130)}, 0.12)
        end
        tw(b, {BackgroundColor3=Color3.fromRGB(35,60,180), TextColor3=Color3.fromRGB(200,215,255)}, 0.12)
        TABS[idx][3]()
    end)
end
tw(tabBtns[1], {BackgroundColor3=Color3.fromRGB(35,60,180), TextColor3=Color3.fromRGB(200,215,255)}, 0)

-- ══════════════════════════════════════════════════════════════
--  FLOATING TOGGLE BUTTON
-- ══════════════════════════════════════════════════════════════
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.new(0, 44, 0, 44)
openBtn.Position = UDim2.new(0, 12, 0, 12)
openBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 38)
openBtn.Text = "V"
openBtn.TextColor3 = Color3.fromRGB(100, 140, 255)
openBtn.Font = Enum.Font.GothamBlack
openBtn.TextSize = 18
openBtn.BorderSizePixel = 0
openBtn.ZIndex = 10
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(0, 10)
local openStroke = Instance.new("UIStroke", openBtn)
openStroke.Color = Color3.fromRGB(50, 80, 200)
openStroke.Thickness = 1.5

local panelOpen = false
local function togglePanel()
    panelOpen = not panelOpen
    tw(panel, {
        Position = panelOpen
            and UDim2.new(0.5, -PANEL_W/2, 0.5, -PANEL_H/2)
            or  UDim2.new(0.5, -PANEL_W/2, 1, 20)
    }, 0.24)
    tw(openBtn, {
        BackgroundColor3 = panelOpen and Color3.fromRGB(35, 60, 180) or Color3.fromRGB(18, 18, 38)
    }, 0.15)
end

openBtn.MouseButton1Click:Connect(togglePanel)
xbtn.MouseButton1Click:Connect(function() if panelOpen then togglePanel() end end)

-- Panel drag
local dragActive, dragStart, startPos = false, nil, nil
hdr.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragActive = true; dragStart = i.Position; startPos = panel.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if not dragActive then return end
    if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    local delta = i.Position - dragStart
    panel.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragActive = false end
end)

-- Insert key toggle
UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.Insert then togglePanel() end
end)

-- ══════════════════════════════════════════════════════════════
--  FOV CIRCLE
-- ══════════════════════════════════════════════════════════════
local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Thickness = 1
fovCircle.Color = Color3.fromRGB(100, 140, 255)
fovCircle.Transparency = 0.5
fovCircle.Filled = false
fovCircle.NumSides = 64

function updateFovCircle()
    local show = cfg.aimbotEnabled and cfg.aimbotFOVvis
    fovCircle.Visible = show
    if show then
        fovCircle.Radius = cfg.aimbotFOV
        fovCircle.Position = Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y * 0.5)
    end
end
updateFovCircle()

-- ══════════════════════════════════════════════════════════════
--  RAINBOW
-- ══════════════════════════════════════════════════════════════
local rainbowHue = 0
local function getRainbow() return Color3.fromHSV(rainbowHue, 1, 1) end

-- ══════════════════════════════════════════════════════════════
--  CHAMS
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

local lockedTarget    = nil
local lockLostTime    = 0   -- tick() when target last went off screen
local LOCK_GRACE      = 0.8 -- seconds to hold lock after target off-screen

-- Predict position with velocity lead
local function predictPos(bone)
    local pos = bone.Position
    if cfg.aimbotVelPred then
        pcall(function() pos = pos + bone.AssemblyLinearVelocity * 0.075 end)
    end
    return pos
end

local function bestTarget(fov)
    local center = Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y * 0.5)
    local now    = tick()

    -- ── Maintain existing lock ──────────────────────────────────
    if lockedTarget then
        local char = lockedTarget.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")

        -- Target dead or left game → drop lock immediately
        if not hum or hum.Health <= 0 then
            lockedTarget = nil; lockLostTime = 0
            goto fresh_scan
        end

        local bone = char:FindFirstChild(cfg.aimbotBone) or char:FindFirstChild("HumanoidRootPart")
        if not bone then lockedTarget = nil; goto fresh_scan end

        local pos = predictPos(bone)
        local s, on = w2s(pos)

        if on then
            lockLostTime = 0  -- reset grace timer, target visible

            -- Check if a drastically closer target appeared (within 30% of lock dist)
            local lockDist = (s - center).Magnitude
            for _, p in ipairs(Players:GetPlayers()) do
                if p == lp or p == lockedTarget then continue end
                if cfg.espTeamCheck and p.Team == lp.Team then continue end
                local c2 = p.Character; if not c2 then continue end
                local h2 = c2:FindFirstChildOfClass("Humanoid")
                if not h2 or h2.Health <= 0 then continue end
                local b2 = c2:FindFirstChild(cfg.aimbotBone) or c2:FindFirstChild("HumanoidRootPart")
                if not b2 then continue end
                local s2, on2 = w2s(predictPos(b2))
                if on2 and (s2 - center).Magnitude < lockDist * 0.3 and (s2 - center).Magnitude < fov then
                    lockedTarget = p; return p, predictPos(b2)
                end
            end

            return lockedTarget, pos

        else
            -- Target off screen — hold for grace period
            if lockLostTime == 0 then lockLostTime = now end
            if now - lockLostTime < LOCK_GRACE then
                return lockedTarget, pos  -- keep tracking even off-screen briefly
            end
            -- Grace expired → drop and re-scan
            lockedTarget = nil; lockLostTime = 0
        end
    end

    ::fresh_scan::
    -- ── Pick closest target within FOV ─────────────────────────
    local bp, bpos, bd = nil, nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p == lp then continue end
        if cfg.espTeamCheck and p.Team == lp.Team then continue end
        local char = p.Character; if not char then continue end
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local bone = char:FindFirstChild(cfg.aimbotBone) or char:FindFirstChild("HumanoidRootPart")
        if not bone then continue end
        local pos = predictPos(bone)
        local s, on = w2s(pos)
        if not on then continue end
        local d = (s - center).Magnitude
        if d < bd and d < fov then bd = d; bp = p; bpos = pos end
    end
    if bp then lockedTarget = bp end
    return bp, bpos
end

-- ══════════════════════════════════════════════════════════════
--  ESP DRAWING
-- ══════════════════════════════════════════════════════════════
local espObjs = {}

local function newDrawing(type, props)
    local d = Drawing.new(type)
    for k, v in pairs(props) do pcall(function() d[k] = v end) end
    return d
end

local function getESPObjs(p)
    if not espObjs[p] then
        espObjs[p] = {
            box     = newDrawing("Square", {Visible=false, Thickness=1, Filled=false, Color=Color3.fromRGB(255,255,255)}),
            boxFill = newDrawing("Square", {Visible=false, Thickness=0, Filled=true,  Color=Color3.fromRGB(255,255,255), Transparency=cfg.boxFillAlpha}),
            tracer  = newDrawing("Line",   {Visible=false, Thickness=1.5, Color=Color3.fromRGB(220,55,55)}),
            name    = newDrawing("Text",   {Visible=false, Size=cfg.nameSize, Center=true, Outline=true, Color=Color3.fromRGB(255,255,255), OutlineColor=Color3.fromRGB(0,0,0)}),
            hpBg    = newDrawing("Square", {Visible=false, Thickness=0, Filled=true,  Color=Color3.fromRGB(0,0,0), Transparency=0.5}),
            hpBar   = newDrawing("Square", {Visible=false, Thickness=0, Filled=true,  Color=Color3.fromRGB(50,255,50)}),
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
--  ATTACK REMOTES SCAN
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
    rainbowHue = (rainbowHue + dt * 0.4) % 1
    local rbCol = getRainbow()

    updateFovCircle()

    -- Aimbot — Right Mouse Button
    if cfg.aimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local _, pos = bestTarget(cfg.aimbotFOV)
        if pos then
            pcall(function()
                local camPos  = cam.CFrame.Position
                local current = cam.CFrame.LookVector
                local desired = (pos - camPos).Unit

                -- angle between current aim and target (radians)
                local dot   = math.clamp(current:Dot(desired), -1, 1)
                local angle = math.acos(dot)

                -- dt-scaled alpha: speed * dt gives consistent feel at any fps
                -- clamp to 1 so we never overshoot
                local alpha = math.clamp(cfg.aimbotSmooth * dt, 0, 1)

                -- snap instantly when very close to target
                if angle < math.rad(cfg.aimbotSnapDist * 0.15) then
                    alpha = 1
                end

                local newLook = current:Lerp(desired, alpha).Unit
                cam.CFrame = CFrame.new(camPos, camPos + newLook)
            end)
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p == lp then continue end
        if cfg.espTeamCheck and p.Team == lp.Team then removeESPObjs(p); continue end

        local char = p.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")

        if not char or not hum or not root or not head or hum.Health <= 0 then
            local o = espObjs[p]
            if o then for _, d in pairs(o) do pcall(function() d.Visible = false end) end end
            continue
        end

        local o = getESPObjs(p)

        if cfg.rainbowChams and chamsHL[p] then
            pcall(function() chamsHL[p].FillColor = rbCol end)
        end

        local topScreen,    topOn    = w2s(head.Position + Vector3.new(0, 0.7, 0))
        local bottomScreen, bottomOn = w2s(root.Position  - Vector3.new(0, 2.8, 0))

        if not topOn or not bottomOn then
            for _, d in pairs(o) do pcall(function() d.Visible = false end) end
            continue
        end

        local h  = math.abs(bottomScreen.Y - topScreen.Y)
        local w  = h * 0.55
        local cx = topScreen.X
        local ty = topScreen.Y
        local espCol = cfg.rainbowChams and rbCol or cfg.boxColor

        -- Box
        if cfg.boxEnabled then
            o.box.Visible   = true
            o.box.Size      = Vector2.new(w, h)
            o.box.Position  = Vector2.new(cx - w*0.5, ty)
            o.box.Color     = espCol
            o.box.Thickness = cfg.boxThick
            if cfg.boxFill then
                o.boxFill.Visible      = true
                o.boxFill.Size         = Vector2.new(w, h)
                o.boxFill.Position     = Vector2.new(cx - w*0.5, ty)
                o.boxFill.Color        = espCol
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
            local origin = cfg.tracerOrigin == "Bottom"
                and Vector2.new(cam.ViewportSize.X*0.5, cam.ViewportSize.Y)
                or  Vector2.new(cam.ViewportSize.X*0.5, cam.ViewportSize.Y*0.5)
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
            o.name.Visible  = true
            o.name.Text     = p.Name
            o.name.Position = Vector2.new(cx, ty - 14)
            o.name.Color    = espCol
            o.name.Size     = cfg.nameSize
        else
            o.name.Visible = false
        end

        -- Health bar
        if cfg.healthEnabled then
            local hp   = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local bx   = cx - w*0.5 - 6
            local barH = h * hp
            o.hpBg.Visible   = true
            o.hpBg.Size      = Vector2.new(3, h)
            o.hpBg.Position  = Vector2.new(bx, ty)
            o.hpBar.Visible  = true
            o.hpBar.Size     = Vector2.new(3, barH)
            o.hpBar.Position = Vector2.new(bx, ty + h - barH)
            o.hpBar.Color    = Color3.fromRGB(math.floor((1-hp)*255), math.floor(hp*255), 0)
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

    pcall(function()
        root.CFrame = CFrame.new(tr.Position, tr.Position + tr.CFrame.LookVector)
    end)
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

-- Boot
pageESP()

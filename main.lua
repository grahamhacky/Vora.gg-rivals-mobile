--[[
    ██╗   ██╗ ██████╗ ██████╗  █████╗    ██████╗  ██████╗
    ██║   ██║██╔═══██╗██╔══██╗██╔══██╗  ██╔════╝ ██╔════╝
    ██║   ██║██║   ██║██████╔╝███████║  ██║  ███╗██║  ███╗
    ╚██╗ ██╔╝██║   ██║██╔══██╗██╔══██║  ██║   ██║██║   ██║
     ╚████╔╝ ╚██████╔╝██║  ██║██║  ██║  ╚██████╔╝╚██████╔╝
      ╚═══╝   ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═════╝  ╚═════╝
    Vora.gg  —  Rivals Mobile  |  Delta iOS
--]]

-- ══════════════════════════════════════════════════════════════
--  DELTA iOS COMPAT
-- ══════════════════════════════════════════════════════════════
if not bit32 then
    bit32={}
    bit32.bxor=function(a,b) local r,m=0,1 while a>0 or b>0 do local ra,rb=a%2,b%2 if ra~=rb then r=r+m end a,b,m=(a-ra)/2,(b-rb)/2,m*2 end return r end
    bit32.band=function(a,b) local r,m=0,1 while a>0 and b>0 do local ra,rb=a%2,b%2 if ra==1 and rb==1 then r=r+m end a,b,m=(a-ra)/2,(b-rb)/2,m*2 end return r end
    bit32.rshift=function(a,b) return math.floor(a/2^b) end
    bit32.lshift=function(a,b) return a*2^b end
end
if not setreadonly      then setreadonly      =function()end end
if not getrawmetatable  then getrawmetatable  =function(o)return getmetatable(o)or{}end end
if not newcclosure      then newcclosure      =function(f)return f end end
if not identifyexecutor then identifyexecutor =function()return"Delta"end end

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
    -- ESP
    espEnabled   = true,
    espTeamCheck = false,
    espFillTrans = 0.65,
    espOutline   = true,

    -- Silent Aim
    silentEnabled = false,
    silentFOV     = 250,
    velPred       = true,
}

-- ══════════════════════════════════════════════════════════════
--  GUI ROOT
-- ══════════════════════════════════════════════════════════════
pcall(function() local o=CoreGui:FindFirstChild("VoraGG") if o then o:Destroy() end end)
pcall(function() local o=lp.PlayerGui:FindFirstChild("VoraGG") if o then o:Destroy() end end)

local gui=Instance.new("ScreenGui")
gui.Name="VoraGG"; gui.ResetOnSpawn=false
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.IgnoreGuiInset=true
if not pcall(function() gui.Parent=CoreGui end) then gui.Parent=lp.PlayerGui end

local function tw(o,p,t) pcall(function() TweenService:Create(o,TweenInfo.new(t or .18,Enum.EasingStyle.Quad),p):Play() end) end

-- ══════════════════════════════════════════════════════════════
--  PANEL
-- ══════════════════════════════════════════════════════════════
local panel=Instance.new("Frame",gui)
panel.Name="Panel"; panel.Size=UDim2.new(0,318,0,360)
panel.Position=UDim2.new(0.5,-159,1,20)
panel.BackgroundColor3=Color3.fromRGB(6,6,16)
panel.BorderSizePixel=0; panel.ClipsDescendants=true
Instance.new("UICorner",panel).CornerRadius=UDim.new(0,14)
local ps=Instance.new("UIStroke",panel)
ps.Color=Color3.fromRGB(0,90,210); ps.Thickness=1.5; ps.Transparency=0.2

local hdr=Instance.new("Frame",panel)
hdr.Size=UDim2.new(1,0,0,44); hdr.BackgroundColor3=Color3.fromRGB(0,70,175); hdr.BorderSizePixel=0
Instance.new("UICorner",hdr).CornerRadius=UDim.new(0,14)
local hfix=Instance.new("Frame",hdr); hfix.Size=UDim2.new(1,0,.5,0); hfix.Position=UDim2.new(0,0,.5,0)
hfix.BackgroundColor3=Color3.fromRGB(0,70,175); hfix.BorderSizePixel=0

local logo=Instance.new("TextLabel",hdr)
logo.Size=UDim2.new(1,-50,1,0); logo.Position=UDim2.new(0,14,0,0)
logo.BackgroundTransparency=1; logo.TextColor3=Color3.fromRGB(255,255,255)
logo.Font=Enum.Font.GothamBold; logo.TextSize=17; logo.TextXAlignment=Enum.TextXAlignment.Left
logo.Text="⬡  VORA.GG"

local xbtn=Instance.new("TextButton",hdr)
xbtn.Size=UDim2.new(0,32,0,24); xbtn.Position=UDim2.new(1,-38,.5,-12)
xbtn.BackgroundColor3=Color3.fromRGB(160,20,20); xbtn.Text="✕"
xbtn.TextColor3=Color3.fromRGB(255,255,255); xbtn.Font=Enum.Font.GothamBold; xbtn.TextSize=11
xbtn.BorderSizePixel=0; Instance.new("UICorner",xbtn).CornerRadius=UDim.new(0,6)

local content=Instance.new("ScrollingFrame",panel)
content.Size=UDim2.new(1,-8,1,-52); content.Position=UDim2.new(0,4,0,52)
content.BackgroundTransparency=1; content.ScrollBarThickness=3
content.ScrollBarImageColor3=Color3.fromRGB(0,110,255); content.BorderSizePixel=0
content.CanvasSize=UDim2.new(0,0,0,0); content.AutomaticCanvasSize=Enum.AutomaticSize.Y
local cl=Instance.new("UIListLayout",content); cl.Padding=UDim.new(0,5)

-- ══════════════════════════════════════════════════════════════
--  WIDGETS
-- ══════════════════════════════════════════════════════════════
local function mkSection(par,lbl)
    local f=Instance.new("Frame",par); f.Size=UDim2.new(1,-8,0,22); f.BackgroundTransparency=1
    local l=Instance.new("TextLabel",f)
    l.Size=UDim2.new(1,-12,1,0); l.Position=UDim2.new(0,10,0,0)
    l.BackgroundTransparency=1; l.TextColor3=Color3.fromRGB(0,150,255)
    l.Font=Enum.Font.GothamBold; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left
    l.Text="▸ "..lbl:upper()
end

local function mkToggle(par,lbl,state,cb)
    local row=Instance.new("Frame",par)
    row.Size=UDim2.new(1,-8,0,40); row.BackgroundColor3=Color3.fromRGB(12,12,24); row.BorderSizePixel=0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,9)
    local l=Instance.new("TextLabel",row)
    l.Size=UDim2.new(1,-62,1,0); l.Position=UDim2.new(0,13,0,0)
    l.BackgroundTransparency=1; l.TextColor3=Color3.fromRGB(215,215,235)
    l.Font=Enum.Font.Gotham; l.TextSize=13; l.TextXAlignment=Enum.TextXAlignment.Left; l.Text=lbl
    local track=Instance.new("Frame",row)
    track.Size=UDim2.new(0,44,0,24); track.Position=UDim2.new(1,-56,.5,-12)
    track.BackgroundColor3=state and Color3.fromRGB(0,110,230) or Color3.fromRGB(40,40,60)
    track.BorderSizePixel=0; Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",track)
    knob.Size=UDim2.new(0,18,0,18)
    knob.Position=state and UDim2.new(1,-21,.5,-9) or UDim2.new(0,3,.5,-9)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local btn=Instance.new("TextButton",row)
    btn.Size=UDim2.new(1,0,1,0); btn.BackgroundTransparency=1; btn.Text=""
    local val=state
    btn.MouseButton1Click:Connect(function()
        val=not val
        tw(track,{BackgroundColor3=val and Color3.fromRGB(0,110,230) or Color3.fromRGB(40,40,60)},.15)
        tw(knob,{Position=val and UDim2.new(1,-21,.5,-9) or UDim2.new(0,3,.5,-9)},.15)
        pcall(cb,val)
    end)
end

local function mkSlider(par,lbl,mn,mx,val,cb)
    local row=Instance.new("Frame",par)
    row.Size=UDim2.new(1,-8,0,54); row.BackgroundColor3=Color3.fromRGB(12,12,24); row.BorderSizePixel=0
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,9)
    local l=Instance.new("TextLabel",row)
    l.Size=UDim2.new(.7,0,0,26); l.Position=UDim2.new(0,13,0,4)
    l.BackgroundTransparency=1; l.TextColor3=Color3.fromRGB(215,215,235)
    l.Font=Enum.Font.Gotham; l.TextSize=12; l.TextXAlignment=Enum.TextXAlignment.Left; l.Text=lbl
    local vl=Instance.new("TextLabel",row)
    vl.Size=UDim2.new(.3,-13,0,26); vl.Position=UDim2.new(.7,0,0,4)
    vl.BackgroundTransparency=1; vl.TextColor3=Color3.fromRGB(0,150,255)
    vl.Font=Enum.Font.GothamBold; vl.TextSize=12; vl.TextXAlignment=Enum.TextXAlignment.Right
    vl.Text=tostring(val)
    local trk=Instance.new("Frame",row)
    trk.Size=UDim2.new(1,-26,0,6); trk.Position=UDim2.new(0,13,0,36)
    trk.BackgroundColor3=Color3.fromRGB(30,30,50); trk.BorderSizePixel=0
    Instance.new("UICorner",trk).CornerRadius=UDim.new(1,0)
    local fill=Instance.new("Frame",trk)
    fill.Size=UDim2.new((val-mn)/(mx-mn),0,1,0)
    fill.BackgroundColor3=Color3.fromRGB(0,110,230); fill.BorderSizePixel=0
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local drag=Instance.new("TextButton",row)
    drag.Size=UDim2.new(1,0,0,28); drag.Position=UDim2.new(0,0,0,26)
    drag.BackgroundTransparency=1; drag.Text=""
    local dragging,tid=false,nil
    drag.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true;tid=i end
    end)
    UserInputService.InputEnded:Connect(function(i) if i==tid then dragging=false;tid=nil end end)
    UserInputService.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType~=Enum.UserInputType.Touch and i.UserInputType~=Enum.UserInputType.MouseMove then return end
        local rel=math.clamp((i.Position.X-trk.AbsolutePosition.X)/trk.AbsoluteSize.X,0,1)
        local nv=math.floor(mn+rel*(mx-mn)+.5)
        vl.Text=tostring(nv); fill.Size=UDim2.new(rel,0,1,0); pcall(cb,nv)
    end)
end

-- ══════════════════════════════════════════════════════════════
--  FOV CIRCLE (UICorner + UIStroke, no image asset)
-- ══════════════════════════════════════════════════════════════
local fovFrame=Instance.new("Frame",gui)
fovFrame.BackgroundTransparency=1; fovFrame.BorderSizePixel=0
fovFrame.AnchorPoint=Vector2.new(.5,.5); fovFrame.ZIndex=2

local fovCircle=Instance.new("Frame",fovFrame)
fovCircle.Size=UDim2.new(1,0,1,0)
fovCircle.BackgroundTransparency=1; fovCircle.BorderSizePixel=0
local _fc=Instance.new("UICorner",fovCircle); _fc.CornerRadius=UDim.new(1,0)
local _fs=Instance.new("UIStroke",fovCircle)
_fs.Color=Color3.fromRGB(255,255,255); _fs.Thickness=2; _fs.Transparency=0.15

local function updateFovCircle()
    local show=cfg.silentEnabled
    fovFrame.Visible=show
    if show then
        local r=cfg.silentFOV
        fovFrame.Position=UDim2.new(0,cam.ViewportSize.X*.5,0,cam.ViewportSize.Y*.5)
        fovFrame.Size=UDim2.new(0,r*2,0,r*2)
    end
end
fovFrame.Visible=false

-- ══════════════════════════════════════════════════════════════
--  PANEL CONTENT
-- ══════════════════════════════════════════════════════════════
mkSection(content,"ESP")
mkToggle(content,"ESP Enabled",   cfg.espEnabled,   function(v) cfg.espEnabled=v; refreshESP() end)
mkToggle(content,"Team Check",    cfg.espTeamCheck, function(v) cfg.espTeamCheck=v; refreshESP() end)
mkToggle(content,"Outline",       cfg.espOutline,   function(v) cfg.espOutline=v; refreshESP() end)
mkSlider(content,"Fill Opacity %",0,100,math.floor((1-cfg.espFillTrans)*100),function(v)
    cfg.espFillTrans=1-(v/100); refreshESP()
end)

mkSection(content,"Auto Win")
mkToggle(content,"Auto Win",      cfg.silentEnabled,function(v) cfg.silentEnabled=v; updateFovCircle() end)
mkSlider(content,"FOV Radius",    30,500,cfg.silentFOV,function(v) cfg.silentFOV=v; updateFovCircle() end)
mkToggle(content,"Velocity Predict",cfg.velPred,    function(v) cfg.velPred=v end)

-- ══════════════════════════════════════════════════════════════
--  OPEN BUTTON + TOGGLE
-- ══════════════════════════════════════════════════════════════
local openBtn=Instance.new("TextButton",gui)
openBtn.Size=UDim2.new(0,50,0,50); openBtn.Position=UDim2.new(1,-60,0,60)
openBtn.BackgroundColor3=Color3.fromRGB(0,80,190); openBtn.Text="⬡"
openBtn.TextColor3=Color3.fromRGB(255,255,255); openBtn.Font=Enum.Font.GothamBold; openBtn.TextSize=24
openBtn.BorderSizePixel=0; openBtn.ZIndex=10
Instance.new("UICorner",openBtn).CornerRadius=UDim.new(1,0)
Instance.new("UIStroke",openBtn).Color=Color3.fromRGB(0,150,255)

local panelOpen=false
local function togglePanel()
    panelOpen=not panelOpen
    tw(panel,{Position=panelOpen and UDim2.new(.5,-159,1,-368) or UDim2.new(.5,-159,1,20)},.22)
end
openBtn.MouseButton1Click:Connect(togglePanel)
xbtn.MouseButton1Click:Connect(function() if panelOpen then togglePanel() end end)

-- ══════════════════════════════════════════════════════════════
--  HUD — ESP + SLT only
-- ══════════════════════════════════════════════════════════════
local hudF=Instance.new("Frame",gui)
hudF.Size=UDim2.new(0,50,0,84); hudF.Position=UDim2.new(0,8,.5,-42); hudF.BackgroundTransparency=1
local hudL=Instance.new("UIListLayout",hudF); hudL.Padding=UDim.new(0,5)

local function mkHud(lbl,initOn,onTap)
    local b=Instance.new("TextButton",hudF)
    b.Size=UDim2.new(1,0,0,38)
    b.BackgroundColor3=initOn and Color3.fromRGB(0,80,190) or Color3.fromRGB(10,10,22)
    b.Text=lbl; b.TextColor3=Color3.fromRGB(200,200,220)
    b.Font=Enum.Font.GothamBold; b.TextSize=9; b.BorderSizePixel=0
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,9)
    Instance.new("UIStroke",b).Color=Color3.fromRGB(0,55,130)
    b.MouseButton1Click:Connect(function() onTap(b) end)
    return b
end

mkHud("ESP",cfg.espEnabled,function(b)
    cfg.espEnabled=not cfg.espEnabled
    b.BackgroundColor3=cfg.espEnabled and Color3.fromRGB(0,80,190) or Color3.fromRGB(10,10,22)
    refreshESP()
end)
mkHud("SLT",cfg.silentEnabled,function(b)
    cfg.silentEnabled=not cfg.silentEnabled
    b.BackgroundColor3=cfg.silentEnabled and Color3.fromRGB(0,80,190) or Color3.fromRGB(10,10,22)
    updateFovCircle()
end)

-- ══════════════════════════════════════════════════════════════
--  ESP — HIGHLIGHT
-- ══════════════════════════════════════════════════════════════
local espHL={}

local function removeESP(p)
    if espHL[p] then pcall(function() espHL[p]:Destroy() end); espHL[p]=nil end
end

local function makeESP(p)
    removeESP(p)
    if p==lp then return end
    if cfg.espTeamCheck and p.Team==lp.Team then return end
    local char=p.Character; if not char then return end
    local hl=Instance.new("Highlight")
    hl.FillColor=Color3.fromRGB(255,50,50)
    hl.OutlineColor=Color3.fromRGB(255,255,255)
    hl.FillTransparency=cfg.espEnabled and cfg.espFillTrans or 1
    hl.OutlineTransparency=cfg.espEnabled and (cfg.espOutline and 0 or 1) or 1
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee=char; hl.Parent=char
    espHL[p]=hl
end

function refreshESP()
    for p,hl in pairs(espHL) do
        pcall(function()
            local hide=(not cfg.espEnabled) or (cfg.espTeamCheck and p.Team==lp.Team)
            hl.FillTransparency    = hide and 1 or cfg.espFillTrans
            hl.OutlineTransparency = hide and 1 or (cfg.espOutline and 0 or 1)
        end)
    end
end

local function onPlayerAdded(p)
    if p==lp then return end
    task.wait(0.5); makeESP(p)
    p.CharacterAdded:Connect(function() task.wait(0.5); makeESP(p) end)
end
Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(removeESP)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(onPlayerAdded,p) end

-- ══════════════════════════════════════════════════════════════
--  TARGET FINDING (sticky lock)
-- ══════════════════════════════════════════════════════════════
local function w2s(pos)
    local v,on=cam:WorldToViewportPoint(pos)
    return Vector2.new(v.X,v.Y),on
end

local lockedTarget=nil

local function bestTarget(fov)
    local center=Vector2.new(cam.ViewportSize.X*.5,cam.ViewportSize.Y*.5)

    if lockedTarget then
        local char=lockedTarget.Character
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health>0 then
            local bone=char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
            if bone then
                local pos=bone.Position
                pcall(function() if cfg.velPred then pos=pos+bone.AssemblyLinearVelocity*0.065 end end)
                local s,on=w2s(pos)
                if on then
                    local lockDist=(s-center).Magnitude
                    -- check if someone else is >50% closer inside FOV
                    local bp2,bpos2,bd2=nil,nil,math.huge
                    for _,p in ipairs(Players:GetPlayers()) do
                        if p==lp or p==lockedTarget then continue end
                        if cfg.espTeamCheck and p.Team==lp.Team then continue end
                        local c2=p.Character; if not c2 then continue end
                        local h2=c2:FindFirstChildOfClass("Humanoid")
                        if not h2 or h2.Health<=0 then continue end
                        local b2=c2:FindFirstChild("Head") or c2:FindFirstChild("HumanoidRootPart"); if not b2 then continue end
                        local p2=b2.Position
                        pcall(function() if cfg.velPred then p2=p2+b2.AssemblyLinearVelocity*0.065 end end)
                        local s2,on2=w2s(p2); if not on2 then continue end
                        local d2=(s2-center).Magnitude
                        if d2<bd2 and d2<fov then bd2=d2;bp2=p;bpos2=p2 end
                    end
                    if bp2 and bd2<lockDist*0.5 then lockedTarget=bp2; return bp2,bpos2 end
                    return lockedTarget,pos
                end
            end
        end
        lockedTarget=nil
    end

    local bp,bpos,bd=nil,nil,math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p==lp then continue end
        if cfg.espTeamCheck and p.Team==lp.Team then continue end
        local char=p.Character; if not char then continue end
        local hum=char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then continue end
        local bone=char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"); if not bone then continue end
        local pos=bone.Position
        pcall(function() if cfg.velPred then pos=pos+bone.AssemblyLinearVelocity*0.065 end end)
        local s,on=w2s(pos); if not on then continue end
        local d=(s-center).Magnitude
        if d<bd and d<fov then bd=d;bp=p;bpos=pos end
    end
    if bp then lockedTarget=bp end
    return bp,bpos
end

-- ══════════════════════════════════════════════════════════════
--  AUTO WIN
--  Every frame: teleport directly onto target + spam every attack
--  remote/tool found in character. Locks onto nearest enemy in FOV.
-- ══════════════════════════════════════════════════════════════

-- Scan for all RemoteEvents/RemoteFunctions in game that look like
-- attack/damage remotes — cache them so we're not searching every frame
local attackRemotes={}
local function scanRemotes()
    attackRemotes={}
    local function scan(obj)
        for _,v in ipairs(obj:GetChildren()) do
            if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
                local n=v.Name:lower()
                if n:find("attack") or n:find("hit") or n:find("damage")
                or n:find("swing") or n:find("strike") or n:find("punch")
                or n:find("slash") or n:find("fire") or n:find("shoot")
                or n:find("action") or n:find("combat") or n:find("kill") then
                    table.insert(attackRemotes,v)
                end
            end
            scan(v)
        end
    end
    pcall(scan, game:GetService("ReplicatedStorage"))
    pcall(scan, workspace)
end
task.spawn(scanRemotes)
-- Rescan every 8 seconds in case remotes load late
task.spawn(function()
    while task.wait(8) do scanRemotes() end
end)

RunService.RenderStepped:Connect(function()
    updateFovCircle()
    if not cfg.silentEnabled then return end
    local _,pos=bestTarget(cfg.silentFOV)
    if not pos then return end
    -- Snap camera to target head
    pcall(function() cam.CFrame=CFrame.new(cam.CFrame.Position,pos) end)
end)

RunService.Heartbeat:Connect(function()
    if not cfg.silentEnabled then return end
    local bp=bestTarget(cfg.silentFOV)
    if not bp then return end
    local char=lp.Character; if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart"); if not root then return end
    local tc=bp.Character; if not tc then return end
    local tr=tc:FindFirstChild("HumanoidRootPart"); if not tr then return end
    local thead=tc:FindFirstChild("Head") or tr

    -- 1) Teleport directly onto target (inside their hitbox)
    pcall(function()
        root.CFrame=CFrame.new(tr.Position,tr.Position+tr.CFrame.LookVector)
    end)

    -- 2) Activate every Tool in our character (sword, gun, ability, etc.)
    pcall(function()
        for _,obj in ipairs(char:GetChildren()) do
            if obj:IsA("Tool") then
                pcall(function() obj:Activate() end)
                -- also fire the tool's remote if it has one
                local handle=obj:FindFirstChild("Handle")
                for _,v in ipairs(obj:GetDescendants()) do
                    if v:IsA("RemoteEvent") then
                        pcall(function() v:FireServer(thead.CFrame.Position) end)
                    end
                end
            end
        end
    end)

    -- 3) Fire all known attack remotes with target position
    pcall(function()
        for _,remote in ipairs(attackRemotes) do
            if remote:IsA("RemoteEvent") then
                pcall(function() remote:FireServer(thead.CFrame.Position,thead) end)
            end
        end
    end)
end)

-- ══════════════════════════════════════════════════════════════
--  CLEANUP
-- ══════════════════════════════════════════════════════════════
game:BindToClose(function()
    for p in pairs(espHL) do removeESP(p) end
end)

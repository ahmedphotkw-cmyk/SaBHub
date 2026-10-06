-- ═════════════════════════════════════════════════════════════
-- MODARK HUB · v1.0 — Premium Script Framework
-- language: Lua, file: modark_hub.lua, runtime: Delta Mobile
-- ═════════════════════════════════════════════════════════════

if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.6)

local Players  = game:GetService("Players")
local RS       = game:GetService("ReplicatedStorage")
local Run      = game:GetService("RunService")
local UIS      = game:GetService("UserInputService")
local TS       = game:GetService("TweenService")
local WS       = game:GetService("Workspace")
local CoreGui  = game:GetService("CoreGui")
local VIM      = game:GetService("VirtualInputManager")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui", 10)
local Cam = WS.CurrentCamera

-- تنظيف
for _, n in ipairs({"ModarkHub","CombatESP","ModarkV19","ModarkV18","ModarkV17","ModarkV16","ModarkV15"}) do
    local o = PG:FindFirstChild(n); if o then o:Destroy() end
end

-- ═════════════════════════════════════════════════════════════
-- THEME
-- ═════════════════════════════════════════════════════════════
local Theme = {
    Bg          = Color3.fromRGB(12, 14, 20),
    Bg2         = Color3.fromRGB(18, 21, 28),
    Card        = Color3.fromRGB(24, 28, 36),
    CardHover   = Color3.fromRGB(30, 34, 44),
    Stroke      = Color3.fromRGB(40, 46, 58),
    StrokeLight = Color3.fromRGB(55, 62, 76),
    Text        = Color3.fromRGB(230, 235, 245),
    TextDim     = Color3.fromRGB(150, 160, 180),
    TextMuted   = Color3.fromRGB(95, 105, 125),
    Accent      = Color3.fromRGB(0, 220, 140),
    AccentDark  = Color3.fromRGB(0, 160, 100),
    Blue        = Color3.fromRGB(80, 150, 255),
    Purple      = Color3.fromRGB(180, 130, 255),
    Yellow      = Color3.fromRGB(255, 190, 60),
    Red         = Color3.fromRGB(255, 80, 100),
    Green       = Color3.fromRGB(90, 220, 130),
    Font        = Enum.Font.Gotham,
    FontBold    = Enum.Font.GothamBold,
    FontMono    = Enum.Font.Code,
}

-- ═════════════════════════════════════════════════════════════
-- CONFIG
-- ═════════════════════════════════════════════════════════════
local Config = {
    -- Combat
    Aimbot = {
        Enabled = false, TargetPart = "Head", FOV = 120, Smoothing = 0.35,
        MaxDist = 500, WallCheck = false, TeamCheck = false, HoldKey = true,
        Visible = true,
    },
    Triggerbot = { Enabled = false, Delay = 0.08, FOV = 15 },
    SilentAim = { Enabled = false },

    -- Visuals
    ESP = {
        Enabled = true, Players = true, NPCs = true,
        Box = true, Name = true, Distance = true, Health = true, Tracer = false,
        MaxDist = 800, Chams = false, ChamsFill = 0.6,
    },
    Fullbright = false,
    NoFog = false,

    -- Movement
    Speed = { Enabled = false, Value = 32 },
    Jump = { Enabled = false, Value = 75 },
    Fly = { Enabled = false, Speed = 60 },
    Noclip = false,
    InfJump = false,

    -- Misc
    AntiAFK = true,
    Stats = true,
}

-- ═════════════════════════════════════════════════════════════
-- UI HELPERS
-- ═════════════════════════════════════════════════════════════
local Hub = {}
Hub.Flags = {}
Hub.Connections = {}

local function corner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 8)
    return c
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or Theme.Stroke
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function padding(parent, t, r, b, l)
    local p = Instance.new("UIPadding", parent)
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft = UDim.new(0, l or 0)
    return p
end

local function tween(obj, time, props)
    local t = TS:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- ═════════════════════════════════════════════════════════════
-- MAIN WINDOW
-- ═════════════════════════════════════════════════════════════
local screen = Instance.new("ScreenGui", PG)
screen.Name = "ModarkHub"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local W, H = 560, 420
local main = Instance.new("Frame", screen)
main.Size = UDim2.new(0, W, 0, H)
main.Position = UDim2.new(0.5, -W/2, 0.5, -H/2)
main.BackgroundColor3 = Theme.Bg
main.BorderSizePixel = 0
corner(main, 16)
local mainStroke = stroke(main, Theme.Stroke, 1)

-- Shadow (fake)
local shadow = Instance.new("ImageLabel", main)
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5028857084"
shadow.ImageColor3 = Color3.new(0, 0, 0)
shadow.ImageTransparency = 0.5
shadow.ZIndex = -1
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(24, 24, 276, 276)

-- ═══ HEADER ═══
local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Theme.Bg2
header.BorderSizePixel = 0
corner(header, 16)
-- إخفاء الحافة السفلية
local hideCorner = Instance.new("Frame", header)
hideCorner.Size = UDim2.new(1, 0, 0, 16)
hideCorner.Position = UDim2.new(0, 0, 1, -16)
hideCorner.BackgroundColor3 = Theme.Bg2
hideCorner.BorderSizePixel = 0

local logo = Instance.new("Frame", header)
logo.Size = UDim2.new(0, 26, 0, 26)
logo.Position = UDim2.new(0, 16, 0.5, -13)
logo.BackgroundColor3 = Theme.Accent
logo.BorderSizePixel = 0
corner(logo, 8)

local logoInner = Instance.new("Frame", logo)
logoInner.Size = UDim2.new(0, 10, 0, 10)
logoInner.Position = UDim2.new(0.5, -5, 0.5, -5)
logoInner.BackgroundColor3 = Theme.Bg2
logoInner.BorderSizePixel = 0
corner(logoInner, 3)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(0, 200, 1, 0)
title.Position = UDim2.new(0, 54, 0, 0)
title.BackgroundTransparency = 1
title.Text = "MODARK"
title.TextColor3 = Theme.Text
title.Font = Theme.FontBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left

local titleSub = Instance.new("TextLabel", header)
titleSub.Size = UDim2.new(0, 200, 1, 0)
titleSub.Position = UDim2.new(0, 132, 0, 0)
titleSub.BackgroundTransparency = 1
titleSub.Text = "·  HUB v1.0"
titleSub.TextColor3 = Theme.TextDim
titleSub.Font = Theme.Font
titleSub.TextSize = 12
titleSub.TextXAlignment = Enum.TextXAlignment.Left

-- Header buttons
local function hdrBtn(text, x, color)
    local b = Instance.new("TextButton", header)
    b.Size = UDim2.new(0, 28, 0, 28)
    b.Position = UDim2.new(1, x, 0.5, -14)
    b.BackgroundColor3 = Theme.Card
    b.Text = text
    b.TextColor3 = Theme.TextDim
    b.Font = Theme.FontBold
    b.TextSize = 14
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    corner(b, 8)
    b.MouseEnter:Connect(function() tween(b, 0.15, {BackgroundColor3 = Theme.CardHover}) end)
    b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundColor3 = Theme.Card}) end)
    return b
end

local minimizeBtn = hdrBtn("−", -74, Theme.Yellow)
local closeBtn    = hdrBtn("×", -40, Theme.Red)

closeBtn.MouseButton1Click:Connect(function() screen:Destroy() end)

-- Minimize
local minimized = false
local fullH = H
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        tween(main, 0.3, {Size = UDim2.new(0, W, 0, 48)})
        for _, c in ipairs(main:GetChildren()) do
            if c ~= header and c:IsA("GuiObject") then c.Visible = false end
        end
    else
        tween(main, 0.3, {Size = UDim2.new(0, W, 0, fullH)})
        for _, c in ipairs(main:GetChildren()) do
            if c ~= header and c:IsA("GuiObject") then c.Visible = true end
        end
    end
end)

-- Drag
do
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- ═══ SIDEBAR ═══
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 140, 1, -60)
sidebar.Position = UDim2.new(0, 8, 0, 52)
sidebar.BackgroundColor3 = Theme.Bg2
sidebar.BorderSizePixel = 0
corner(sidebar, 12)

local sbPad = padding(sidebar, 8, 8, 8, 8)

local tabsList = Instance.new("Frame", sidebar)
tabsList.Size = UDim2.new(1, -16, 1, -90)
tabsList.Position = UDim2.new(0, 8, 0, 8)
tabsList.BackgroundTransparency = 1

local sbLayout = Instance.new("UIListLayout", tabsList)
sbLayout.Padding = UDim.new(0, 4)
sbLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- User card at bottom
local userCard = Instance.new("Frame", sidebar)
userCard.Size = UDim2.new(1, -16, 0, 70)
userCard.Position = UDim2.new(0, 8, 1, -78)
userCard.BackgroundColor3 = Theme.Card
userCard.BorderSizePixel = 0
corner(userCard, 10)

local avatar = Instance.new("ImageLabel", userCard)
avatar.Size = UDim2.new(0, 34, 0, 34)
avatar.Position = UDim2.new(0, 8, 0, 8)
avatar.BackgroundColor3 = Theme.CardHover
avatar.BorderSizePixel = 0
corner(avatar, 17)
avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=48&h=48"

local userN = Instance.new("TextLabel", userCard)
userN.Size = UDim2.new(1, -50, 0, 14)
userN.Position = UDim2.new(0, 48, 0, 8)
userN.BackgroundTransparency = 1
userN.Text = LP.DisplayName
userN.TextColor3 = Theme.Text
userN.Font = Theme.FontBold
userN.TextSize = 11
userN.TextXAlignment = Enum.TextXAlignment.Left
userN.TextTruncate = Enum.TextTruncate.AtEnd

local userU = Instance.new("TextLabel", userCard)
userU.Size = UDim2.new(1, -50, 0, 12)
userU.Position = UDim2.new(0, 48, 0, 22)
userU.BackgroundTransparency = 1
userU.Text = "@" .. LP.Name
userU.TextColor3 = Theme.TextDim
userU.Font = Theme.Font
userU.TextSize = 9
userU.TextXAlignment = Enum.TextXAlignment.Left
userU.TextTruncate = Enum.TextTruncate.AtEnd

local uptime = Instance.new("TextLabel", userCard)
uptime.Size = UDim2.new(1, -16, 0, 16)
uptime.Position = UDim2.new(0, 8, 0, 46)
uptime.BackgroundTransparency = 1
uptime.Text = "● ONLINE"
uptime.TextColor3 = Theme.Accent
uptime.Font = Theme.FontBold
uptime.TextSize = 9
uptime.TextXAlignment = Enum.TextXAlignment.Left

-- ═══ CONTENT AREA ═══
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -160, 1, -60)
content.Position = UDim2.new(0, 152, 0, 52)
content.BackgroundTransparency = 1

local pages = {}
local currentPage = nil

local function showPage(name)
    for n, p in pairs(pages) do
        p.Visible = (n == name)
    end
    currentPage = name
end

-- ═════════════════════════════════════════════════════════════
-- TAB SYSTEM
-- ═════════════════════════════════════════════════════════════
local tabButtons = {}

local function createTab(name, icon, color)
    -- Button
    local btn = Instance.new("TextButton", tabsList)
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Theme.Card
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    corner(btn, 8)

    local accent = Instance.new("Frame", btn)
    accent.Size = UDim2.new(0, 3, 0, 16)
    accent.Position = UDim2.new(0, 0, 0.5, -8)
    accent.BackgroundColor3 = color
    accent.BorderSizePixel = 0
    accent.BackgroundTransparency = 1
    corner(accent, 2)

    local ico = Instance.new("TextLabel", btn)
    ico.Size = UDim2.new(0, 24, 1, 0)
    ico.Position = UDim2.new(0, 10, 0, 0)
    ico.BackgroundTransparency = 1
    ico.Text = icon
    ico.TextColor3 = Theme.TextDim
    ico.Font = Theme.FontBold
    ico.TextSize = 14

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -40, 1, 0)
    lbl.Position = UDim2.new(0, 34, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = name
    lbl.TextColor3 = Theme.TextDim
    lbl.Font = Theme.Font
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Page
    local page = Instance.new("ScrollingFrame", content)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Theme.Stroke
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    pages[name] = page

    local pLayout = Instance.new("UIListLayout", page)
    pLayout.Padding = UDim.new(0, 8)
    pLayout.SortOrder = Enum.SortOrder.LayoutOrder

    btn.MouseEnter:Connect(function()
        if currentPage ~= name then
            tween(btn, 0.15, {BackgroundTransparency = 0.6})
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentPage ~= name then
            tween(btn, 0.15, {BackgroundTransparency = 1})
        end
    end)

    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(tabButtons) do
            tween(b.btn, 0.15, {BackgroundTransparency = 1})
            tween(b.accent, 0.15, {BackgroundTransparency = 1})
            b.lbl.TextColor3 = Theme.TextDim
            b.ico.TextColor3 = Theme.TextDim
        end
        tween(btn, 0.15, {BackgroundTransparency = 0, BackgroundColor3 = Theme.Card})
        tween(accent, 0.15, {BackgroundTransparency = 0})
        lbl.TextColor3 = Theme.Text
        ico.TextColor3 = color
        showPage(name)
    end)

    table.insert(tabButtons, {btn = btn, accent = accent, lbl = lbl, ico = ico, name = name, color = color})
    return page
end

-- ═════════════════════════════════════════════════════════════
-- SECTION (Header inside page)
-- ═════════════════════════════════════════════════════════════
local function section(page, title)
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.new(1, 0, 0, 26)
    frame.BackgroundTransparency = 1

    local line = Instance.new("Frame", frame)
    line.Size = UDim2.new(0, 3, 0, 14)
    line.Position = UDim2.new(0, 0, 0.5, -7)
    line.BackgroundColor3 = Theme.Accent
    line.BorderSizePixel = 0
    corner(line, 2)

    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -16, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(title)
    lbl.TextColor3 = Theme.TextDim
    lbl.Font = Theme.FontBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    return frame
end

-- ═════════════════════════════════════════════════════════════
-- CARD (container)
-- ═════════════════════════════════════════════════════════════
local function card(page)
    local c = Instance.new("Frame", page)
    c.Size = UDim2.new(1, 0, 0, 0)
    c.AutomaticSize = Enum.AutomaticSize.Y
    c.BackgroundColor3 = Theme.Bg2
    c.BorderSizePixel = 0
    corner(c, 10)
    stroke(c, Theme.Stroke, 1)
    local p = padding(c, 8, 8, 8, 8)
    local layout = Instance.new("UIListLayout", c)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    return c
end

-- ═════════════════════════════════════════════════════════════
-- TOGGLE SWITCH (Premium)
-- ═════════════════════════════════════════════════════════════
local function toggle(parent, label, default, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 4, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Theme.Text
    lbl.Font = Theme.Font
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Switch container
    local sw = Instance.new("Frame", row)
    sw.Size = UDim2.new(0, 42, 0, 22)
    sw.Position = UDim2.new(1, -46, 0.5, -11)
    sw.BackgroundColor3 = default and Theme.Accent or Theme.Stroke
    sw.BorderSizePixel = 0
    corner(sw, 11)

    local thumb = Instance.new("Frame", sw)
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    thumb.BackgroundColor3 = Color3.new(1, 1, 1)
    thumb.BorderSizePixel = 0
    corner(thumb, 8)

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.ZIndex = 2

    local state = default
    local function apply(v, animate)
        state = v
        if animate then
            tween(sw, 0.18, {BackgroundColor3 = v and Theme.Accent or Theme.Stroke})
            tween(thumb, 0.18, {Position = v and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)})
        else
            sw.BackgroundColor3 = v and Theme.Accent or Theme.Stroke
            thumb.Position = v and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        end
        if callback then callback(v) end
    end

    btn.MouseButton1Click:Connect(function()
        apply(not state, true)
    end)

    return { frame = row, set = apply, get = function() return state end }
end

-- ═════════════════════════════════════════════════════════════
-- SLIDER (Premium)
-- ═════════════════════════════════════════════════════════════
local function slider(parent, label, default, min, max, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 44)
    row.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -80, 0, 16)
    lbl.Position = UDim2.new(0, 4, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Theme.Text
    lbl.Font = Theme.Font
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextLabel", row)
    valLbl.Size = UDim2.new(0, 70, 0, 16)
    valLbl.Position = UDim2.new(1, -74, 0, 0)
    valLbl.BackgroundColor3 = Theme.Card
    valLbl.BorderSizePixel = 0
    valLbl.Text = tostring(default)
    valLbl.TextColor3 = Theme.Accent
    valLbl.Font = Theme.FontBold
    valLbl.TextSize = 11
    corner(valLbl, 4)

    -- Slider track
    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(1, -8, 0, 6)
    track.Position = UDim2.new(0, 4, 0, 24)
    track.BackgroundColor3 = Theme.Stroke
    track.BorderSizePixel = 0
    corner(track, 3)

    local fill = Instance.new("Frame", track)
    local initPct = (default - min) / (max - min)
    fill.Size = UDim2.new(initPct, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    corner(fill, 3)

    local thumb = Instance.new("Frame", track)
    thumb.Size = UDim2.new(0, 14, 0, 14)
    thumb.Position = UDim2.new(initPct, -7, 0.5, -7)
    thumb.BackgroundColor3 = Color3.new(1, 1, 1)
    thumb.BorderSizePixel = 0
    corner(thumb, 7)
    stroke(thumb, Theme.Accent, 2)

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.Position = UDim2.new(0, 0, 0, 12)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    local dragging = false
    local state = default

    local function update(input)
        local pos = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
        pos = math.clamp(pos, 0, 1)
        local value = math.floor(min + (max - min) * pos + 0.5)
        state = value
        valLbl.Text = tostring(value)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        thumb.Position = UDim2.new(pos, -7, 0.5, -7)
        if callback then callback(value) end
    end

    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return { set = function(v) state = v; local pct = (v - min) / (max - min); fill.Size = UDim2.new(pct, 0, 1, 0); thumb.Position = UDim2.new(pct, -7, 0.5, -7); valLbl.Text = tostring(v); if callback then callback(v) end end, get = function() return state end }
end

-- ═════════════════════════════════════════════════════════════
-- DROPDOWN (Premium)
-- ═════════════════════════════════════════════════════════════
local function dropdown(parent, label, options, default, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundTransparency = 1
    row.ClipsDescendants = false

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -100, 1, 0)
    lbl.Position = UDim2.new(0, 4, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Theme.Text
    lbl.Font = Theme.Font
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local selected = default
    local selBtn = Instance.new("TextButton", row)
    selBtn.Size = UDim2.new(0, 90, 0, 24)
    selBtn.Position = UDim2.new(1, -94, 0.5, -12)
    selBtn.BackgroundColor3 = Theme.Card
    selBtn.BorderSizePixel = 0
    selBtn.Text = default
    selBtn.TextColor3 = Theme.Text
    selBtn.Font = Theme.FontBold
    selBtn.TextSize = 11
    corner(selBtn, 6)

    local arrow = Instance.new("TextLabel", selBtn)
    arrow.Size = UDim2.new(0, 14, 1, 0)
    arrow.Position = UDim2.new(1, -18, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▾"
    arrow.TextColor3 = Theme.TextDim
    arrow.Font = Theme.FontBold
    arrow.TextSize = 10

    local open = false
    local menu = Instance.new("Frame", row)
    menu.Size = UDim2.new(0, 90, 0, #options * 24 + 8)
    menu.Position = UDim2.new(1, -94, 1, 4)
    menu.BackgroundColor3 = Theme.Bg2
    menu.BorderSizePixel = 0
    corner(menu, 8)
    stroke(menu, Theme.Stroke, 1)
    menu.Visible = false
    menu.ZIndex = 10

    local mLayout = Instance.new("UIListLayout", menu)
    mLayout.Padding = UDim.new(0, 2)
    padding(menu, 4, 4, 4, 4)

    for _, opt in ipairs(options) do
        local ob = Instance.new("TextButton", menu)
        ob.Size = UDim2.new(1, 0, 0, 22)
        ob.BackgroundColor3 = Theme.Card
        ob.BackgroundTransparency = 1
        ob.Text = opt
        ob.TextColor3 = Theme.Text
        ob.Font = Theme.Font
        ob.TextSize = 11
        ob.AutoButtonColor = false
        corner(ob, 6)
        ob.MouseEnter:Connect(function() tween(ob, 0.1, {BackgroundTransparency = 0}) end)
        ob.MouseLeave:Connect(function() tween(ob, 0.1, {BackgroundTransparency = 1}) end)
        ob.MouseButton1Click:Connect(function()
            selected = opt
            selBtn.Text = opt
            menu.Visible = false
            open = false
            if callback then callback(opt) end
        end)
    end

    selBtn.MouseButton1Click:Connect(function()
        open = not open
        menu.Visible = open
        arrow.Text = open and "▴" or "▾"
    end)

    return { get = function() return selected end }
end

-- ═════════════════════════════════════════════════════════════
-- BUTTON (Premium)
-- ═════════════════════════════════════════════════════════════
local function button(parent, text, color, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = color or Theme.Accent
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Color3.fromRGB(10, 12, 18)
    b.Font = Theme.FontBold
    b.TextSize = 12
    b.AutoButtonColor = false
    corner(b, 8)

    b.MouseEnter:Connect(function() tween(b, 0.15, {BackgroundColor3 = color and Theme.AccentDark or Theme.StrokeLight}) end)
    b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundColor3 = color or Theme.Accent}) end)
    b.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return b
end

-- ═════════════════════════════════════════════════════════════
-- NOTIFICATION
-- ═════════════════════════════════════════════════════════════
local notifContainer = Instance.new("Frame", screen)
notifContainer.Size = UDim2.new(0, 260, 1, 0)
notifContainer.Position = UDim2.new(1, -270, 0, 0)
notifContainer.BackgroundTransparency = 1

local nLayout = Instance.new("UIListLayout", notifContainer)
nLayout.Padding = UDim.new(0, 8)
nLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
nLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
nLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function notify(title, msg, color)
    color = color or Theme.Accent
    local n = Instance.new("Frame", notifContainer)
    n.Size = UDim2.new(1, 0, 0, 56)
    n.BackgroundColor3 = Theme.Bg2
    n.BorderSizePixel = 0
    corner(n, 10)
    stroke(n, color, 1.5)
    n.BackgroundTransparency = 1

    local accent = Instance.new("Frame", n)
    accent.Size = UDim2.new(0, 3, 1, -16)
    accent.Position = UDim2.new(0, 0, 0, 8)
    accent.BackgroundColor3 = color
    accent.BorderSizePixel = 0
    corner(accent, 2)

    local t = Instance.new("TextLabel", n)
    t.Size = UDim2.new(1, -20, 0, 20)
    t.Position = UDim2.new(0, 14, 0, 8)
    t.BackgroundTransparency = 1
    t.Text = title
    t.TextColor3 = color
    t.Font = Theme.FontBold
    t.TextSize = 12
    t.TextXAlignment = Enum.TextXAlignment.Left

    local m = Instance.new("TextLabel", n)
    m.Size = UDim2.new(1, -20, 0, 18)
    m.Position = UDim2.new(0, 14, 0, 28)
    m.BackgroundTransparency = 1
    m.Text = msg
    m.TextColor3 = Theme.TextDim
    m.Font = Theme.Font
    m.TextSize = 10
    m.TextXAlignment = Enum.TextXAlignment.Left
    m.TextTruncate = Enum.TextTruncate.AtEnd

    -- fade in
    tween(n, 0.25, {BackgroundTransparency = 0})
    task.delay(3, function()
        tween(n, 0.3, {BackgroundTransparency = 1})
        tween(accent, 0.3, {BackgroundTransparency = 1})
        task.wait(0.35)
        n:Destroy()
    end)
end

-- ═════════════════════════════════════════════════════════════
-- BUILD TABS
-- ═════════════════════════════════════════════════════════════
local combatPage  = createTab("Combat",   "⚔", Theme.Red)
local visualPage  = createTab("Visuals",  "◉", Theme.Blue)
local movePage    = createTab("Movement", "→", Theme.Green)
local miscPage    = createTab("Misc",     "⚙", Theme.Yellow)
local cfgPage     = createTab("Config",   "◈", Theme.Purple)

-- تفعيل Combat افتراضياً
tabButtons[1].btn.BackgroundTransparency = 0
tabButtons[1].btn.BackgroundColor3 = Theme.Card
tabButtons[1].accent.BackgroundTransparency = 0
tabButtons[1].lbl.TextColor3 = Theme.Text
tabButtons[1].ico.TextColor3 = Theme.Red
showPage("Combat")

-- ═════════════════════════════════════════════════════════════
-- ═══ COMBAT PAGE ═══
-- ═════════════════════════════════════════════════════════════
section(combatPage, "Aimbot")
local aimCard = card(combatPage)

toggle(aimCard, "Enable Aimbot", Config.Aimbot.Enabled, function(v)
    Config.Aimbot.Enabled = v
    notify("Aimbot", v and "Enabled" or "Disabled", v and Theme.Accent or Theme.Red)
end)
toggle(aimCard, "Hold Key (RMB)", Config.Aimbot.HoldKey, function(v) Config.Aimbot.HoldKey = v end)
toggle(aimCard, "Wall Check", Config.Aimbot.WallCheck, function(v) Config.Aimbot.WallCheck = v end)
toggle(aimCard, "Team Check", Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end)
dropdown(aimCard, "Target Part", {"Head","HumanoidRootPart","UpperTorso"}, Config.Aimbot.TargetPart, function(v)
    Config.Aimbot.TargetPart = v
end)
slider(aimCard, "FOV", Config.Aimbot.FOV, 30, 400, function(v) Config.Aimbot.FOV = v end)
slider(aimCard, "Smoothing", Config.Aimbot.Smoothing * 100, 5, 100, function(v) Config.Aimbot.Smoothing = v / 100 end)
slider(aimCard, "Max Distance", Config.Aimbot.MaxDist, 50, 2000, function(v) Config.Aimbot.MaxDist = v end)

section(combatPage, "Triggerbot")
local trigCard = card(combatPage)
toggle(trigCard, "Enable Triggerbot", Config.Triggerbot.Enabled, function(v) Config.Triggerbot.Enabled = v end)
slider(trigCard, "Trigger FOV", Config.Triggerbot.FOV, 1, 60, function(v) Config.Triggerbot.FOV = v end)
slider(trigCard, "Delay (ms)", Config.Triggerbot.Delay * 1000, 0, 500, function(v) Config.Triggerbot.Delay = v / 1000 end)

-- ═════════════════════════════════════════════════════════════
-- ═══ VISUALS PAGE ═══
-- ═════════════════════════════════════════════════════════════
section(visualPage, "ESP")
local espCard = card(visualPage)
toggle(espCard, "Enable ESP", Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end)
toggle(espCard, "Players", Config.ESP.Players, function(v) Config.ESP.Players = v end)
toggle(espCard, "NPCs / Mobs", Config.ESP.NPCs, function(v) Config.ESP.NPCs = v end)
toggle(espCard, "Box", Config.ESP.Box, function(v) Config.ESP.Box = v end)
toggle(espCard, "Name", Config.ESP.Name, function(v) Config.ESP.Name = v end)
toggle(espCard, "Distance", Config.ESP.Distance, function(v) Config.ESP.Distance = v end)
toggle(espCard, "Health", Config.ESP.Health, function(v) Config.ESP.Health = v end)
toggle(espCard, "Tracer", Config.ESP.Tracer, function(v) Config.ESP.Tracer = v end)
toggle(espCard, "Chams (Highlight)", Config.ESP.Chams, function(v) Config.ESP.Chams = v end)
slider(espCard, "ESP Max Distance", Config.ESP.MaxDist, 100, 3000, function(v) Config.ESP.MaxDist = v end)

section(visualPage, "World")
local worldCard = card(visualPage)
toggle(worldCard, "Fullbright", Config.Fullbright, function(v)
    Config.Fullbright = v
    if v then
        Lighting.Brightness = 3
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    end
end)
toggle(worldCard, "No Fog", Config.NoFog, function(v)
    Config.NoFog = v
    Lighting.FogEnd = v and 100000 or 1000
end)

-- ═════════════════════════════════════════════════════════════
-- ═══ MOVEMENT PAGE ═══
-- ═════════════════════════════════════════════════════════════
section(movePage, "Speed & Jump")
local moveCard = card(movePage)
toggle(moveCard, "Speed Hack", Config.Speed.Enabled, function(v) Config.Speed.Enabled = v end)
slider(moveCard, "WalkSpeed", Config.Speed.Value, 16, 250, function(v) Config.Speed.Value = v end)
toggle(moveCard, "Jump Hack", Config.Jump.Enabled, function(v) Config.Jump.Enabled = v end)
slider(moveCard, "JumpPower", Config.Jump.Value, 50, 500, function(v) Config.Jump.Value = v end)
toggle(moveCard, "Infinite Jump", Config.InfJump, function(v) Config.InfJump = v end)

section(movePage, "Fly & Noclip")
local flyCard = card(movePage)
toggle(flyCard, "Enable Fly", Config.Fly.Enabled, function(v)
    Config.Fly.Enabled = v
    notify("Fly", v and "Enabled — استخدم الأزرار" or "Disabled", v and Theme.Green or Theme.Red)
end)
slider(flyCard, "Fly Speed", Config.Fly.Speed, 20, 300, function(v) Config.Fly.Speed = v end)
toggle(flyCard, "Noclip", Config.Noclip, function(v) Config.Noclip = v end)

-- ═════════════════════════════════════════════════════════════
-- ═══ MISC PAGE ═══
-- ═════════════════════════════════════════════════════════════
section(miscPage, "Utility")
local miscCard = card(miscPage)
toggle(miscCard, "Anti-AFK", Config.AntiAFK, function(v)
    Config.AntiAFK = v
end)
toggle(miscCard, "Show Stats", Config.Stats, function(v) Config.Stats = v end)

button(miscCard, "Rejoin Server", Theme.Blue, function()
    notify("Rejoin", "جاري الاتصال...", Theme.Blue)
    task.wait(0.5)
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)

button(miscCard, "Server Hop", Theme.Purple, function()
    notify("ServerHop", "جاري البحث...", Theme.Purple)
    task.spawn(function()
        local HttpService = game:GetService("HttpService")
        local ok, res = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if ok and res and res.data then
            for _, srv in ipairs(res.data) do
                if srv.playing < srv.maxPlayers and srv.id ~= game.JobId then
                    pcall(function()
                        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, srv.id, LP)
                    end)
                    return
                end
            end
        end
        notify("ServerHop", "لم يُوجد سيرفر", Theme.Red)
    end)
end)

-- Stats display
local statsCard = card(miscPage)
local statsLabel = Instance.new("TextLabel", statsCard)
statsLabel.Size = UDim2.new(1, 0, 0, 60)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "FPS: -- | Ping: -- ms\nUptime: --"
statsLabel.TextColor3 = Theme.Text
statsLabel.Font = Theme.FontMono
statsLabel.TextSize = 11
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.TextYAlignment = Enum.TextYAlignment.Top

-- ═════════════════════════════════════════════════════════════
-- ═══ CONFIG PAGE ═══
-- ═════════════════════════════════════════════════════════════
section(cfgPage, "Configuration")
local cfgCard = card(cfgPage)

button(cfgCard, "Save Config", Theme.Accent, function()
    local ok = pcall(function()
        if writefile then
            writefile("modark_config.json", game:GetService("HttpService"):JSONEncode(Config))
        end
    end)
    notify("Config", ok and "Saved successfully" or "Save failed (no filesystem)", ok and Theme.Accent or Theme.Red)
end)

button(cfgCard, "Load Config", Theme.Blue, function()
    local ok, data = pcall(function()
        if readfile and isfile and isfile("modark_config.json") then
            return game:GetService("HttpService"):JSONDecode(readfile("modark_config.json"))
        end
    end)
    if ok and data then
        for k, v in pairs(data) do
            if type(v) == "table" and type(Config[k]) == "table" then
                for k2, v2 in pairs(v) do Config[k][k2] = v2 end
            else
                Config[k] = v
            end
        end
        notify("Config", "Loaded", Theme.Blue)
    else
        notify("Config", "No config found", Theme.Yellow)
    end
end)

button(cfgCard, "Reset to Default", Theme.Yellow, function()
    notify("Config", "Restart the script to reset", Theme.Yellow)
end)

section(cfgPage, "About")
local aboutCard = card(cfgPage)
local aboutLbl = Instance.new("TextLabel", aboutCard)
aboutLbl.Size = UDim2.new(1, 0, 0, 80)
aboutLbl.BackgroundTransparency = 1
aboutLbl.Text = "MODARK HUB v1.0\nPremium Script Framework\n\nMade with ❤ for Delta Mobile"
aboutLbl.TextColor3 = Theme.TextDim
aboutLbl.Font = Theme.Font
aboutLbl.TextSize = 11
aboutLbl.TextXAlignment = Enum.TextXAlignment.Left
aboutLbl.TextYAlignment = Enum.TextYAlignment.Top
aboutLbl.TextWrapped = true

-- ═════════════════════════════════════════════════════════════
-- ═══ FEATURE IMPLEMENTATIONS ═══
-- ═════════════════════════════════════════════════════════════

-- ───── ESP Engine (Highlight-based, always works) ─────
local ESPHighlights = {}
local ESPBillboards = {}

local function getHighlight(model)
    if ESPHighlights[model] then return ESPHighlights[model] end
    local h = Instance.new("Highlight", model)
    h.FillTransparency = Config.ESP.Chams and Config.ESP.ChamsFill or 1
    h.OutlineTransparency = 0
    h.FillColor = Theme.Red
    h.OutlineColor = Theme.Red
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    ESPHighlights[model] = h
    return h
end

local function getBillboard(model)
    if ESPBillboards[model] then return ESPBillboards[model] end
    local head = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
    if not head then return nil end

    local bb = Instance.new("BillboardGui", head)
    bb.Name = "ModarkBB"
    bb.Size = UDim2.new(0, 200, 0, 60)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = Config.ESP.MaxDist

    local nameL = Instance.new("TextLabel", bb)
    nameL.Name = "NameL"
    nameL.Size = UDim2.new(1, 0, 0, 14)
    nameL.Position = UDim2.new(0, 0, 0, 0)
    nameL.BackgroundTransparency = 1
    nameL.Text = model.Name
    nameL.TextColor3 = Theme.Red
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 13
    nameL.TextStrokeTransparency = 0
    nameL.TextStrokeColor3 = Color3.new(0, 0, 0)

    local distL = Instance.new("TextLabel", bb)
    distL.Name = "DistL"
    distL.Size = UDim2.new(1, 0, 0, 12)
    distL.Position = UDim2.new(0, 0, 0, 14)
    distL.BackgroundTransparency = 1
    distL.Text = "0 studs"
    distL.TextColor3 = Theme.Red
    distL.Font = Enum.Font.Gotham
    distL.TextSize = 10
    distL.TextStrokeTransparency = 0
    distL.TextStrokeColor3 = Color3.new(0, 0, 0)

    local hpL = Instance.new("TextLabel", bb)
    hpL.Name = "HpL"
    hpL.Size = UDim2.new(1, 0, 0, 12)
    hpL.Position = UDim2.new(0, 0, 0, 26)
    hpL.BackgroundTransparency = 1
    hpL.Text = "100/100"
    hpL.TextColor3 = Theme.Green
    hpL.Font = Enum.Font.Gotham
    hpL.TextSize = 10
    hpL.TextStrokeTransparency = 0
    hpL.TextStrokeColor3 = Color3.new(0, 0, 0)

    ESPBillboards[model] = bb
    return bb
end

local function removeESPFor(model)
    if ESPHighlights[model] then ESPHighlights[model]:Destroy(); ESPHighlights[model] = nil end
    if ESPBillboards[model] then ESPBillboards[model]:Destroy(); ESPBillboards[model] = nil end
end

local function updateESP()
    -- Players
    if Config.ESP.Enabled and Config.ESP.Players then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local char = plr.Character
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local hl = getHighlight(char)
                    hl.Enabled = true
                    hl.OutlineColor = Theme.Red
                    hl.FillColor = Theme.Red
                    hl.FillTransparency = Config.ESP.Chams and Config.ESP.ChamsFill or 1

                    if Config.ESP.Name or Config.ESP.Distance or Config.ESP.Health then
                        local bb = getBillboard(char)
                        if bb then
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            local dist = hrp and (Cam.CFrame.Position - hrp.Position).Magnitude or 0
                            bb.Enabled = dist <= Config.ESP.MaxDist
                            if bb:FindFirstChild("NameL") then
                                bb.NameL.Visible = Config.ESP.Name
                                bb.NameL.Text = plr.DisplayName
                            end
                            if bb:FindFirstChild("DistL") then
                                bb.DistL.Visible = Config.ESP.Distance
                                bb.DistL.Text = string.format("%d studs", dist)
                            end
                            if bb:FindFirstChild("HpL") then
                                bb.HpL.Visible = Config.ESP.Health
                                bb.HpL.Text = string.format("%d/%d", hum.Health, hum.MaxHealth)
                            end
                        end
                    end
                else
                    removeESPFor(char)
                end
            end
        end
    else
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then removeESPFor(plr.Character) end
        end
    end

    -- NPCs
    if Config.ESP.Enabled and Config.ESP.NPCs then
        for _, obj in ipairs(WS:GetDescendants()) do
            if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local hl = getHighlight(obj)
                    hl.Enabled = true
                    hl.OutlineColor = Theme.Yellow
                    hl.FillColor = Theme.Yellow
                    hl.FillTransparency = Config.ESP.Chams and Config.ESP.ChamsFill or 1

                    if Config.ESP.Name or Config.ESP.Distance or Config.ESP.Health then
                        local bb = getBillboard(obj)
                        if bb then
                            local hrp = obj:FindFirstChild("HumanoidRootPart")
                            local dist = hrp and (Cam.CFrame.Position - hrp.Position).Magnitude or 0
                            bb.Enabled = dist <= Config.ESP.MaxDist
                            if bb:FindFirstChild("NameL") then
                                bb.NameL.Visible = Config.ESP.Name
                                bb.NameL.Text = obj.Name
                                bb.NameL.TextColor3 = Theme.Yellow
                            end
                            if bb:FindFirstChild("DistL") then
                                bb.DistL.Visible = Config.ESP.Distance
                                bb.DistL.Text = string.format("%d studs", dist)
                                bb.DistL.TextColor3 = Theme.Yellow
                            end
                            if bb:FindFirstChild("HpL") then
                                bb.HpL.Visible = Config.ESP.Health
                                bb.HpL.Text = string.format("%d/%d", hum.Health, hum.MaxHealth)
                            end
                        end
                    end
                end
            end
        end
    else
        for _, obj in ipairs(WS:GetDescendants()) do
            if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) then
                removeESPFor(obj)
            end
        end
    end
end

Run.RenderStepped:Connect(function()
    pcall(updateESP)
end)

-- ───── Aimbot ─────
local aimHeld = false
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
        aimHeld = true
    end
end)
UIS.InputEnded:Connect(function(input, gp)
    if input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
        aimHeld = false
    end
end)

local function getAimTarget()
    local mouse = UIS:GetMouseLocation()
    local best, bestScore = nil, math.huge

    local function check(char)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return end
        local part = char:FindFirstChild(Config.Aimbot.TargetPart) or char:FindFirstChild("Head")
        if not part then return end
        local sp, on = Cam:WorldToViewportPoint(part.Position)
        if not on then return end
        local dist = (Vector2.new(sp.X, sp.Y) - mouse).Magnitude
        local wdist = (Cam.CFrame.Position - part.Position).Magnitude
        if dist < Config.Aimbot.FOV and wdist < Config.Aimbot.MaxDist then
            if Config.Aimbot.WallCheck then
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = {LP.Character, Cam}
                local hit = WS:Raycast(Cam.CFrame.Position, part.Position - Cam.CFrame.Position, params)
                if hit and not hit.Instance:IsDescendantOf(char) then return end
            end
            local score = dist + wdist * 0.1
            if score < bestScore then bestScore = score; best = part end
        end
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then check(plr.Character) end
    end
    for _, obj in ipairs(WS:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
            check(obj)
        end
    end
    return best
end

Run.RenderStepped:Connect(function()
    if not Config.Aimbot.Enabled then return end
    if Config.Aimbot.HoldKey and not aimHeld then return end
    local target = getAimTarget()
    if target then
        local look = CFrame.new(Cam.CFrame.Position, target.Position)
        Cam.CFrame = Cam.CFrame:Lerp(look, Config.Aimbot.Smoothing)
    end
end)

-- ───── Triggerbot ─────
task.spawn(function()
    while screen.Parent do
        task.wait(Config.Triggerbot.Delay)
        if Config.Triggerbot.Enabled then
            local mouse = UIS:GetMouseLocation()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local sp, on = Cam:WorldToViewportPoint(hrp.Position)
                            if on and (Vector2.new(sp.X, sp.Y) - mouse).Magnitude < Config.Triggerbot.FOV then
                                pcall(function()
                                    if mouse1click then mouse1click() end
                                end)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ───── Speed / Jump ─────
Run.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    if Config.Speed.Enabled then
        hum.WalkSpeed = Config.Speed.Value
    end
    if Config.Jump.Enabled then
        hum.UseJumpPower = true
        hum.JumpPower = Config.Jump.Value
    end
end)

-- ───── Infinite Jump ─────
UIS.JumpRequest:Connect(function()
    if Config.InfJump then
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ───── Noclip ─────
Run.Stepped:Connect(function()
    if Config.Noclip then
        local char = LP.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

-- ───── Fly ─────
local flyBV, flyBG
local function startFly()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    flyBV = Instance.new("BodyVelocity", hrp)
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBV.Velocity = Vector3.zero
    flyBG = Instance.new("BodyGyro", hrp)
    flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBG.P = 1000
end

local function stopFly()
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
end

Run.RenderStepped:Connect(function()
    if Config.Fly.Enabled and not flyBV then
        startFly()
    elseif not Config.Fly.Enabled and flyBV then
        stopFly()
    end
    if flyBV and flyBG then
        local char = LP.Character
        if not char then stopFly(); return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then stopFly(); return end
        flyBG.CFrame = Cam.CFrame
        local dir = Vector3.zero
        local speed = Config.Fly.Speed
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - Cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + Cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
        flyBV.Velocity = dir * speed
    end
end)

-- ───── Anti-AFK ─────
task.spawn(function()
    while screen.Parent do
        task.wait(30)
        if Config.AntiAFK then
            local vu = game:GetService("VirtualUser")
            pcall(function()
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end
    end
end)

-- ───── Stats ─────
task.spawn(function()
    local startTime = tick()
    while screen.Parent do
        task.wait(1)
        if Config.Stats then
            local ping = pcall(function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() end)
            local fps = math.floor(1 / Run.RenderStepped:Wait())
            local uptime = tick() - startTime
            statsLabel.Text = string.format(
                "FPS: %d  |  Ping: %d ms\nUptime: %02d:%02d:%02d",
                fps,
                math.floor(ping or 0),
                math.floor(uptime / 3600),
                math.floor(uptime / 60) % 60,
                math.floor(uptime) % 60
            )
        end
    end
end)

-- ═════════════════════════════════════════════════════════════
-- NOTIFICATION
-- ═════════════════════════════════════════════════════════════
task.wait(0.4)
notify("MODARK HUB", "مرحباً " .. LP.DisplayName .. " — جاهز للعمل", Theme.Accent)
task.wait(0.6)
notify("الوحدات", "Combat · Visuals · Movement · Misc", Theme.Blue)

print("[M] ═══════════════════════════════════")
print("[M] MODARK HUB v1.0 — LOADED")
print("[M] User:", LP.Name)
print("[M] Place:", game.PlaceId)
print("[M] ═══════════════════════════════════")

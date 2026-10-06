-- ═════════════════════════════════════════════════════════════
-- MODARK HUB · v1.1 — Premium Script Framework
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
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui", 10)
local Cam = WS.CurrentCamera

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
        Enabled         = false,
        TargetPart      = "Head",
        FOV             = 120,
        Smoothing       = 0.35,     -- 0.05 = فوري | 1.0 = بطيء
        MaxDist         = 500,
        WallCheck       = false,
        TeamCheck       = false,
        HoldKey         = true,
        Prediction      = false,    -- يتوقع مكان العدو
        ProjectileSpeed = 1500,     -- studs/sec (0 = hitscan)
        Instant         = false,    -- بدون تنعيم
        ShowFOV         = true,     -- دائرة FOV مرئية
        StickyMultiplier = 1.4,     -- الهدف يبقى ملتصقاً حتى يخرج من 1.4×FOV
        DistBias        = 0.15,     -- 0 = يفضل القريب من الشاشة | 1 = يفضل القريب مسافةً
    },
    Triggerbot = { Enabled = false, Delay = 0.08, FOV = 15 },

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
stroke(main, Theme.Stroke, 1)

local header = Instance.new("Frame", main)
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundColor3 = Theme.Bg2
header.BorderSizePixel = 0
corner(header, 16)
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
title.Size = UDim2.new(0, 200, 1, 0); title.Position = UDim2.new(0, 54, 0, 0)
title.BackgroundTransparency = 1; title.Text = "MODARK"
title.TextColor3 = Theme.Text; title.Font = Theme.FontBold
title.TextSize = 15; title.TextXAlignment = Enum.TextXAlignment.Left

local titleSub = Instance.new("TextLabel", header)
titleSub.Size = UDim2.new(0, 200, 1, 0); titleSub.Position = UDim2.new(0, 132, 0, 0)
titleSub.BackgroundTransparency = 1; titleSub.Text = "·  HUB v1.1"
titleSub.TextColor3 = Theme.TextDim; titleSub.Font = Theme.Font
titleSub.TextSize = 12; titleSub.TextXAlignment = Enum.TextXAlignment.Left

local function hdrBtn(text, x)
    local b = Instance.new("TextButton", header)
    b.Size = UDim2.new(0, 28, 0, 28); b.Position = UDim2.new(1, x, 0.5, -14)
    b.BackgroundColor3 = Theme.Card; b.Text = text
    b.TextColor3 = Theme.TextDim; b.Font = Theme.FontBold
    b.TextSize = 14; b.BorderSizePixel = 0; b.AutoButtonColor = false
    corner(b, 8)
    b.MouseEnter:Connect(function() tween(b, 0.15, {BackgroundColor3 = Theme.CardHover}) end)
    b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundColor3 = Theme.Card}) end)
    return b
end

local minimizeBtn = hdrBtn("−", -74)
local closeBtn    = hdrBtn("×", -40)
closeBtn.MouseButton1Click:Connect(function() screen:Destroy() end)

local minimized = false
local fullH = H
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    tween(main, 0.3, {Size = UDim2.new(0, W, 0, minimized and 48 or fullH)})
    for _, c in ipairs(main:GetChildren()) do
        if c ~= header and c:IsA("GuiObject") then c.Visible = not minimized end
    end
end)

do
    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = main.Position
        end
    end)
    header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- Sidebar
local sidebar = Instance.new("Frame", main)
sidebar.Size = UDim2.new(0, 140, 1, -60); sidebar.Position = UDim2.new(0, 8, 0, 52)
sidebar.BackgroundColor3 = Theme.Bg2; sidebar.BorderSizePixel = 0
corner(sidebar, 12)

local tabsList = Instance.new("Frame", sidebar)
tabsList.Size = UDim2.new(1, -16, 1, -90); tabsList.Position = UDim2.new(0, 8, 0, 8)
tabsList.BackgroundTransparency = 1
local sbLayout = Instance.new("UIListLayout", tabsList)
sbLayout.Padding = UDim.new(0, 4); sbLayout.SortOrder = Enum.SortOrder.LayoutOrder

local userCard = Instance.new("Frame", sidebar)
userCard.Size = UDim2.new(1, -16, 0, 70); userCard.Position = UDim2.new(0, 8, 1, -78)
userCard.BackgroundColor3 = Theme.Card; userCard.BorderSizePixel = 0
corner(userCard, 10)

local avatar = Instance.new("ImageLabel", userCard)
avatar.Size = UDim2.new(0, 34, 0, 34); avatar.Position = UDim2.new(0, 8, 0, 8)
avatar.BackgroundColor3 = Theme.CardHover; avatar.BorderSizePixel = 0
corner(avatar, 17)
avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=48&h=48"

local userN = Instance.new("TextLabel", userCard)
userN.Size = UDim2.new(1, -50, 0, 14); userN.Position = UDim2.new(0, 48, 0, 8)
userN.BackgroundTransparency = 1; userN.Text = LP.DisplayName
userN.TextColor3 = Theme.Text; userN.Font = Theme.FontBold
userN.TextSize = 11; userN.TextXAlignment = Enum.TextXAlignment.Left
userN.TextTruncate = Enum.TextTruncate.AtEnd

local userU = Instance.new("TextLabel", userCard)
userU.Size = UDim2.new(1, -50, 0, 12); userU.Position = UDim2.new(0, 48, 0, 22)
userU.BackgroundTransparency = 1; userU.Text = "@" .. LP.Name
userU.TextColor3 = Theme.TextDim; userU.Font = Theme.Font
userU.TextSize = 9; userU.TextXAlignment = Enum.TextXAlignment.Left
userU.TextTruncate = Enum.TextTruncate.AtEnd

local uptime = Instance.new("TextLabel", userCard)
uptime.Size = UDim2.new(1, -16, 0, 16); uptime.Position = UDim2.new(0, 8, 0, 46)
uptime.BackgroundTransparency = 1; uptime.Text = "● ONLINE"
uptime.TextColor3 = Theme.Accent; uptime.Font = Theme.FontBold
uptime.TextSize = 9; uptime.TextXAlignment = Enum.TextXAlignment.Left

-- Content
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -160, 1, -60); content.Position = UDim2.new(0, 152, 0, 52)
content.BackgroundTransparency = 1

local pages = {}
local currentPage = nil

local function showPage(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    currentPage = name
end

-- Tabs
local tabButtons = {}
local function createTab(name, icon, color)
    local btn = Instance.new("TextButton", tabsList)
    btn.Size = UDim2.new(1, 0, 0, 34); btn.BackgroundColor3 = Theme.Card
    btn.BackgroundTransparency = 1; btn.Text = ""
    btn.AutoButtonColor = false; btn.BorderSizePixel = 0
    corner(btn, 8)

    local accent = Instance.new("Frame", btn)
    accent.Size = UDim2.new(0, 3, 0, 16); accent.Position = UDim2.new(0, 0, 0.5, -8)
    accent.BackgroundColor3 = color; accent.BorderSizePixel = 0
    accent.BackgroundTransparency = 1; corner(accent, 2)

    local ico = Instance.new("TextLabel", btn)
    ico.Size = UDim2.new(0, 24, 1, 0); ico.Position = UDim2.new(0, 10, 0, 0)
    ico.BackgroundTransparency = 1; ico.Text = icon
    ico.TextColor3 = Theme.TextDim; ico.Font = Theme.FontBold; ico.TextSize = 14

    local lbl = Instance.new("TextLabel", btn)
    lbl.Size = UDim2.new(1, -40, 1, 0); lbl.Position = UDim2.new(0, 34, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = name
    lbl.TextColor3 = Theme.TextDim; lbl.Font = Theme.Font
    lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left

    local page = Instance.new("ScrollingFrame", content)
    page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1
    page.BorderSizePixel = 0; page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Theme.Stroke
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    pages[name] = page

    local pLayout = Instance.new("UIListLayout", page)
    pLayout.Padding = UDim.new(0, 8); pLayout.SortOrder = Enum.SortOrder.LayoutOrder

    btn.MouseEnter:Connect(function() if currentPage ~= name then tween(btn, 0.15, {BackgroundTransparency = 0.6}) end end)
    btn.MouseLeave:Connect(function() if currentPage ~= name then tween(btn, 0.15, {BackgroundTransparency = 1}) end end)
    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(tabButtons) do
            tween(b.btn, 0.15, {BackgroundTransparency = 1})
            tween(b.accent, 0.15, {BackgroundTransparency = 1})
            b.lbl.TextColor3 = Theme.TextDim; b.ico.TextColor3 = Theme.TextDim
        end
        tween(btn, 0.15, {BackgroundTransparency = 0, BackgroundColor3 = Theme.Card})
        tween(accent, 0.15, {BackgroundTransparency = 0})
        lbl.TextColor3 = Theme.Text; ico.TextColor3 = color
        showPage(name)
    end)
    table.insert(tabButtons, {btn=btn, accent=accent, lbl=lbl, ico=ico, name=name, color=color})
    return page
end

local function section(page, title)
    local frame = Instance.new("Frame", page)
    frame.Size = UDim2.new(1, 0, 0, 26); frame.BackgroundTransparency = 1
    local line = Instance.new("Frame", frame)
    line.Size = UDim2.new(0, 3, 0, 14); line.Position = UDim2.new(0, 0, 0.5, -7)
    line.BackgroundColor3 = Theme.Accent; line.BorderSizePixel = 0
    corner(line, 2)
    local lbl = Instance.new("TextLabel", frame)
    lbl.Size = UDim2.new(1, -16, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = string.upper(title)
    lbl.TextColor3 = Theme.TextDim; lbl.Font = Theme.FontBold
    lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left
    return frame
end

local function card(page)
    local c = Instance.new("Frame", page)
    c.Size = UDim2.new(1, 0, 0, 0); c.AutomaticSize = Enum.AutomaticSize.Y
    c.BackgroundColor3 = Theme.Bg2; c.BorderSizePixel = 0
    corner(c, 10); stroke(c, Theme.Stroke, 1)
    padding(c, 8, 8, 8, 8)
    local layout = Instance.new("UIListLayout", c)
    layout.Padding = UDim.new(0, 6); layout.SortOrder = Enum.SortOrder.LayoutOrder
    return c
end

local function toggle(parent, label, default, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 30); row.BackgroundTransparency = 1
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -60, 1, 0); lbl.Position = UDim2.new(0, 4, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = label
    lbl.TextColor3 = Theme.Text; lbl.Font = Theme.Font
    lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left
    local sw = Instance.new("Frame", row)
    sw.Size = UDim2.new(0, 42, 0, 22); sw.Position = UDim2.new(1, -46, 0.5, -11)
    sw.BackgroundColor3 = default and Theme.Accent or Theme.Stroke
    sw.BorderSizePixel = 0; corner(sw, 11)
    local thumb = Instance.new("Frame", sw)
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    thumb.BackgroundColor3 = Color3.new(1,1,1); thumb.BorderSizePixel = 0
    corner(thumb, 8)
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1
    btn.Text = ""; btn.ZIndex = 2
    local state = default
    local function apply(v, anim)
        state = v
        if anim then
            tween(sw, 0.18, {BackgroundColor3 = v and Theme.Accent or Theme.Stroke})
            tween(thumb, 0.18, {Position = v and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)})
        else
            sw.BackgroundColor3 = v and Theme.Accent or Theme.Stroke
            thumb.Position = v and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        end
        if callback then callback(v) end
    end
    btn.MouseButton1Click:Connect(function() apply(not state, true) end)
    return { frame=row, set=apply, get=function() return state end }
end

local function slider(parent, label, default, min, max, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 44); row.BackgroundTransparency = 1
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -80, 0, 16); lbl.Position = UDim2.new(0, 4, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = label
    lbl.TextColor3 = Theme.Text; lbl.Font = Theme.Font
    lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left
    local valLbl = Instance.new("TextLabel", row)
    valLbl.Size = UDim2.new(0, 70, 0, 16); valLbl.Position = UDim2.new(1, -74, 0, 0)
    valLbl.BackgroundColor3 = Theme.Card; valLbl.BorderSizePixel = 0
    valLbl.Text = tostring(default); valLbl.TextColor3 = Theme.Accent
    valLbl.Font = Theme.FontBold; valLbl.TextSize = 11
    corner(valLbl, 4)
    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(1, -8, 0, 6); track.Position = UDim2.new(0, 4, 0, 24)
    track.BackgroundColor3 = Theme.Stroke; track.BorderSizePixel = 0
    corner(track, 3)
    local initPct = (default - min) / (max - min)
    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new(initPct, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent; fill.BorderSizePixel = 0
    corner(fill, 3)
    local thumb = Instance.new("Frame", track)
    thumb.Size = UDim2.new(0, 14, 0, 14); thumb.Position = UDim2.new(initPct, -7, 0.5, -7)
    thumb.BackgroundColor3 = Color3.new(1,1,1); thumb.BorderSizePixel = 0
    corner(thumb, 7); stroke(thumb, Theme.Accent, 2)
    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(1, 0, 0, 30); btn.Position = UDim2.new(0, 0, 0, 12)
    btn.BackgroundTransparency = 1; btn.Text = ""
    local dragging, state = false, default
    local function update(input)
        local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos + 0.5)
        state = value; valLbl.Text = tostring(value)
        fill.Size = UDim2.new(pos, 0, 1, 0)
        thumb.Position = UDim2.new(pos, -7, 0.5, -7)
        if callback then callback(value) end
    end
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; update(i)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            update(i)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return { set=function(v)
        state = v
        local pct = (v - min) / (max - min)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        thumb.Position = UDim2.new(pct, -7, 0.5, -7)
        valLbl.Text = tostring(v)
        if callback then callback(v) end
    end, get=function() return state end }
end

local function dropdown(parent, label, options, default, callback)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 30); row.BackgroundTransparency = 1
    row.ClipsDescendants = false
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -100, 1, 0); lbl.Position = UDim2.new(0, 4, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = label
    lbl.TextColor3 = Theme.Text; lbl.Font = Theme.Font
    lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left
    local selected = default
    local selBtn = Instance.new("TextButton", row)
    selBtn.Size = UDim2.new(0, 90, 0, 24); selBtn.Position = UDim2.new(1, -94, 0.5, -12)
    selBtn.BackgroundColor3 = Theme.Card; selBtn.BorderSizePixel = 0
    selBtn.Text = default; selBtn.TextColor3 = Theme.Text
    selBtn.Font = Theme.FontBold; selBtn.TextSize = 11
    corner(selBtn, 6)
    local arrow = Instance.new("TextLabel", selBtn)
    arrow.Size = UDim2.new(0, 14, 1, 0); arrow.Position = UDim2.new(1, -18, 0, 0)
    arrow.BackgroundTransparency = 1; arrow.Text = "▾"
    arrow.TextColor3 = Theme.TextDim; arrow.Font = Theme.FontBold; arrow.TextSize = 10
    local open = false
    local menu = Instance.new("Frame", row)
    menu.Size = UDim2.new(0, 90, 0, #options * 24 + 8); menu.Position = UDim2.new(1, -94, 1, 4)
    menu.BackgroundColor3 = Theme.Bg2; menu.BorderSizePixel = 0
    corner(menu, 8); stroke(menu, Theme.Stroke, 1)
    menu.Visible = false; menu.ZIndex = 10
    local mLayout = Instance.new("UIListLayout", menu)
    mLayout.Padding = UDim.new(0, 2)
    padding(menu, 4, 4, 4, 4)
    for _, opt in ipairs(options) do
        local ob = Instance.new("TextButton", menu)
        ob.Size = UDim2.new(1, 0, 0, 22); ob.BackgroundColor3 = Theme.Card
        ob.BackgroundTransparency = 1; ob.Text = opt
        ob.TextColor3 = Theme.Text; ob.Font = Theme.Font
        ob.TextSize = 11; ob.AutoButtonColor = false
        corner(ob, 6)
        ob.MouseEnter:Connect(function() tween(ob, 0.1, {BackgroundTransparency = 0}) end)
        ob.MouseLeave:Connect(function() tween(ob, 0.1, {BackgroundTransparency = 1}) end)
        ob.MouseButton1Click:Connect(function()
            selected = opt; selBtn.Text = opt
            menu.Visible = false; open = false
            if callback then callback(opt) end
        end)
    end
    selBtn.MouseButton1Click:Connect(function()
        open = not open; menu.Visible = open
        arrow.Text = open and "▴" or "▾"
    end)
    return { get=function() return selected end }
end

local function button(parent, text, color, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = color or Theme.Accent; b.BorderSizePixel = 0
    b.Text = text; b.TextColor3 = Color3.fromRGB(10, 12, 18)
    b.Font = Theme.FontBold; b.TextSize = 12; b.AutoButtonColor = false
    corner(b, 8)
    b.MouseEnter:Connect(function() tween(b, 0.15, {BackgroundColor3 = Theme.AccentDark}) end)
    b.MouseLeave:Connect(function() tween(b, 0.15, {BackgroundColor3 = color or Theme.Accent}) end)
    b.MouseButton1Click:Connect(function() if callback then callback() end end)
    return b
end

-- Notifications
local notifContainer = Instance.new("Frame", screen)
notifContainer.Size = UDim2.new(0, 260, 1, 0); notifContainer.Position = UDim2.new(1, -270, 0, 0)
notifContainer.BackgroundTransparency = 1
local nLayout = Instance.new("UIListLayout", notifContainer)
nLayout.Padding = UDim.new(0, 8)
nLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
nLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom

local function notify(titleT, msg, color)
    color = color or Theme.Accent
    local n = Instance.new("Frame", notifContainer)
    n.Size = UDim2.new(1, 0, 0, 56)
    n.BackgroundColor3 = Theme.Bg2; n.BorderSizePixel = 0
    corner(n, 10); stroke(n, color, 1.5)
    n.BackgroundTransparency = 1
    local accent = Instance.new("Frame", n)
    accent.Size = UDim2.new(0, 3, 1, -16); accent.Position = UDim2.new(0, 0, 0, 8)
    accent.BackgroundColor3 = color; accent.BorderSizePixel = 0
    corner(accent, 2)
    local t = Instance.new("TextLabel", n)
    t.Size = UDim2.new(1, -20, 0, 20); t.Position = UDim2.new(0, 14, 0, 8)
    t.BackgroundTransparency = 1; t.Text = titleT
    t.TextColor3 = color; t.Font = Theme.FontBold
    t.TextSize = 12; t.TextXAlignment = Enum.TextXAlignment.Left
    local m = Instance.new("TextLabel", n)
    m.Size = UDim2.new(1, -20, 0, 18); m.Position = UDim2.new(0, 14, 0, 28)
    m.BackgroundTransparency = 1; m.Text = msg
    m.TextColor3 = Theme.TextDim; m.Font = Theme.Font
    m.TextSize = 10; m.TextXAlignment = Enum.TextXAlignment.Left
    m.TextTruncate = Enum.TextTruncate.AtEnd
    tween(n, 0.25, {BackgroundTransparency = 0})
    task.delay(3, function()
        tween(n, 0.3, {BackgroundTransparency = 1})
        tween(accent, 0.3, {BackgroundTransparency = 1})
        task.wait(0.35); n:Destroy()
    end)
end

-- ═════════════════════════════════════════════════════════════
-- BUILD TABS
-- ═════════════════════════════════════════════════════════════
local combatPage = createTab("Combat",   "⚔", Theme.Red)
local visualPage = createTab("Visuals",  "◉", Theme.Blue)
local movePage   = createTab("Movement", "→", Theme.Green)
local miscPage   = createTab("Misc",     "⚙", Theme.Yellow)
local cfgPage    = createTab("Config",   "◈", Theme.Purple)

tabButtons[1].btn.BackgroundTransparency = 0
tabButtons[1].btn.BackgroundColor3 = Theme.Card
tabButtons[1].accent.BackgroundTransparency = 0
tabButtons[1].lbl.TextColor3 = Theme.Text
tabButtons[1].ico.TextColor3 = Theme.Red
showPage("Combat")

-- ═════════════════════════════════════════════════════════════
-- COMBAT PAGE (AIMBOT PREMIUM)
-- ═════════════════════════════════════════════════════════════
section(combatPage, "Aimbot")
local aimCard = card(combatPage)

toggle(aimCard, "Enable Aimbot", Config.Aimbot.Enabled, function(v)
    Config.Aimbot.Enabled = v
    notify("Aimbot", v and "Enabled" or "Disabled", v and Theme.Accent or Theme.Red)
end)
toggle(aimCard, "Hold Key (RMB / Touch)", Config.Aimbot.HoldKey, function(v) Config.Aimbot.HoldKey = v end)
toggle(aimCard, "Instant (بدون تنعيم)", Config.Aimbot.Instant, function(v) Config.Aimbot.Instant = v end)
toggle(aimCard, "Prediction (توقع الحركة)", Config.Aimbot.Prediction, function(v) Config.Aimbot.Prediction = v end)
toggle(aimCard, "Wall Check (جدار)", Config.Aimbot.WallCheck, function(v) Config.Aimbot.WallCheck = v end)
toggle(aimCard, "Team Check", Config.Aimbot.TeamCheck, function(v) Config.Aimbot.TeamCheck = v end)
toggle(aimCard, "Show FOV Circle", Config.Aimbot.ShowFOV, function(v) Config.Aimbot.ShowFOV = v end)

dropdown(aimCard, "Target Part", {"Head","HumanoidRootPart","UpperTorso","LowerTorso"}, Config.Aimbot.TargetPart, function(v)
    Config.Aimbot.TargetPart = v
end)

slider(aimCard, "FOV", Config.Aimbot.FOV, 20, 500, function(v) Config.Aimbot.FOV = v end)
slider(aimCard, "Smoothing ×100", Config.Aimbot.Smoothing * 100, 5, 100, function(v) Config.Aimbot.Smoothing = v / 100 end)
slider(aimCard, "Max Distance", Config.Aimbot.MaxDist, 50, 3000, function(v) Config.Aimbot.MaxDist = v end)
slider(aimCard, "Projectile Speed", Config.Aimbot.ProjectileSpeed, 100, 5000, function(v) Config.Aimbot.ProjectileSpeed = v end)
slider(aimCard, "Sticky Multiplier ×10", Config.Aimbot.StickyMultiplier * 10, 10, 30, function(v) Config.Aimbot.StickyMultiplier = v / 10 end)
slider(aimCard, "Distance Bias %", Config.Aimbot.DistBias * 100, 0, 100, function(v) Config.Aimbot.DistBias = v / 100 end)

section(combatPage, "Triggerbot")
local trigCard = card(combatPage)
toggle(trigCard, "Enable Triggerbot", Config.Triggerbot.Enabled, function(v) Config.Triggerbot.Enabled = v end)
slider(trigCard, "Trigger FOV", Config.Triggerbot.FOV, 1, 60, function(v) Config.Triggerbot.FOV = v end)
slider(trigCard, "Delay (ms)", Config.Triggerbot.Delay * 1000, 0, 500, function(v) Config.Triggerbot.Delay = v / 1000 end)

-- ═════════════════════════════════════════════════════════════
-- VISUALS PAGE
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
        Lighting.Brightness = 3; Lighting.ClockTime = 14
        Lighting.FogEnd = 100000; Lighting.GlobalShadows = false
    else
        Lighting.Brightness = 1; Lighting.GlobalShadows = true
    end
end)
toggle(worldCard, "No Fog", Config.NoFog, function(v)
    Config.NoFog = v
    Lighting.FogEnd = v and 100000 or 1000
end)

-- ═════════════════════════════════════════════════════════════
-- MOVEMENT PAGE
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
    notify("Fly", v and "Enabled — WASD + Space/Shift" or "Disabled", v and Theme.Green or Theme.Red)
end)
slider(flyCard, "Fly Speed", Config.Fly.Speed, 20, 300, function(v) Config.Fly.Speed = v end)
toggle(flyCard, "Noclip", Config.Noclip, function(v) Config.Noclip = v end)

-- ═════════════════════════════════════════════════════════════
-- MISC PAGE
-- ═════════════════════════════════════════════════════════════
section(miscPage, "Utility")
local miscCard = card(miscPage)
toggle(miscCard, "Anti-AFK", Config.AntiAFK, function(v) Config.AntiAFK = v end)
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
                    pcall(function() game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, srv.id, LP) end)
                    return
                end
            end
        end
        notify("ServerHop", "لم يُوجد سيرفر", Theme.Red)
    end)
end)

local statsCard = card(miscPage)
local statsLabel = Instance.new("TextLabel", statsCard)
statsLabel.Size = UDim2.new(1, 0, 0, 60)
statsLabel.BackgroundTransparency = 1
statsLabel.Text = "FPS: -- | Ping: -- ms\nUptime: --"
statsLabel.TextColor3 = Theme.Text
statsLabel.Font = Theme.FontMono; statsLabel.TextSize = 11
statsLabel.TextXAlignment = Enum.TextXAlignment.Left
statsLabel.TextYAlignment = Enum.TextYAlignment.Top

-- ═════════════════════════════════════════════════════════════
-- CONFIG PAGE
-- ═════════════════════════════════════════════════════════════
section(cfgPage, "Configuration")
local cfgCard = card(cfgPage)
button(cfgCard, "Save Config", Theme.Accent, function()
    local ok = pcall(function()
        if writefile then writefile("modark_config.json", game:GetService("HttpService"):JSONEncode(Config)) end
    end)
    notify("Config", ok and "Saved successfully" or "Save failed", ok and Theme.Accent or Theme.Red)
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
            else Config[k] = v end
        end
        notify("Config", "Loaded", Theme.Blue)
    else notify("Config", "No config found", Theme.Yellow) end
end)

section(cfgPage, "About")
local aboutCard = card(cfgPage)
local aboutLbl = Instance.new("TextLabel", aboutCard)
aboutLbl.Size = UDim2.new(1, 0, 0, 80)
aboutLbl.BackgroundTransparency = 1
aboutLbl.Text = "MODARK HUB v1.1\nPremium Script Framework\n\nMade with ❤ for Delta Mobile"
aboutLbl.TextColor3 = Theme.TextDim; aboutLbl.Font = Theme.Font
aboutLbl.TextSize = 11; aboutLbl.TextXAlignment = Enum.TextXAlignment.Left
aboutLbl.TextYAlignment = Enum.TextYAlignment.Top
aboutLbl.TextWrapped = true

-- ═════════════════════════════════════════════════════════════
-- ═══════════════ AIMBOT — PREMIUM IMPLEMENTATION ═════════════
-- ═════════════════════════════════════════════════════════════
local AimbotState = {
    target = nil,
    targetPart = nil,
    targetModel = nil,
    aimHeld = false,
    fovCircle = nil,
    lastFire = 0,
}

-- ═══ FOV Circle ═══
local function createFOVCircle()
    if AimbotState.fovCircle then AimbotState.fovCircle:Destroy() end
    local f = Instance.new("Frame", screen)
    f.Name = "ModarkFOVCircle"
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Position = UDim2.new(0.5, 0, 0.5, 0)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.ZIndex = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(1, 0)
    local s = Instance.new("UIStroke", f)
    s.Color = Theme.Accent
    s.Thickness = 1.5
    s.Transparency = 0.35
    AimbotState.fovCircle = f
    return f
end

local function updateFOVCircle()
    if not AimbotState.fovCircle then createFOVCircle() end
    local f = AimbotState.fovCircle
    f.Size = UDim2.new(0, Config.Aimbot.FOV * 2, 0, Config.Aimbot.FOV * 2)
    f.Visible = Config.Aimbot.Enabled and Config.Aimbot.ShowFOV
end

-- ═══ Input ═══
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2
       or input.UserInputType == Enum.UserInputType.Touch then
        AimbotState.aimHeld = true
    end
end)
UIS.InputEnded:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2
       or input.UserInputType == Enum.UserInputType.Touch then
        AimbotState.aimHeld = false
    end
end)

-- ═══ Target Fetching ═══
local function getTargetPosition(model)
    if not model or not model.Parent then return nil, nil end
    local part = model:FindFirstChild(Config.Aimbot.TargetPart)
        or model:FindFirstChild("Head")
        or model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("UpperTorso")
    if not part then return nil, nil end
    return part.Position, part
end

local function predictPosition(part)
    if not Config.Aimbot.Prediction then return part.Position end
    local speed = Config.Aimbot.ProjectileSpeed
    if not speed or speed <= 0 then return part.Position end
    local vel = part.AssemblyLinearVelocity or Vector3.zero
    local dist = (part.Position - Cam.CFrame.Position).Magnitude
    local travel = dist / speed
    return part.Position + vel * travel
end

local function isTeamMate(model)
    if not Config.Aimbot.TeamCheck then return false end
    local plr = Players:GetPlayerFromCharacter(model)
    if plr and LP.Team and plr.Team == LP.Team then return true end
    return false
end

local function isVisible(targetPos, model)
    if not Config.Aimbot.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LP.Character, Cam, screen}
    params.IgnoreWater = true
    local dir = targetPos - Cam.CFrame.Position
    local hit = WS:Raycast(Cam.CFrame.Position, dir, params)
    if not hit then return true end
    if hit.Instance:IsDescendantOf(model) then return true end
    return false
end

local function evaluateTarget(model)
    if not model or not model.Parent then return nil end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil end
    if isTeamMate(model) then return nil end

    local rawPos, part = getTargetPosition(model)
    if not rawPos or not part then return nil end

    local pos = predictPosition(part)

    -- Distance check
    local wdist = (Cam.CFrame.Position - pos).Magnitude
    if wdist > Config.Aimbot.MaxDist then return nil end

    -- Screen position
    local sp, on = Cam:WorldToViewportPoint(pos)
    if not on then return nil end

    -- FOV check (based on screen center)
    local center = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    local screenDist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
    if screenDist > Config.Aimbot.FOV then return nil end

    -- Visibility
    if not isVisible(pos, model) then return nil end

    -- Weighted score
    local bias = Config.Aimbot.DistBias or 0
    local score = screenDist * (1 - bias) + (wdist * 0.15) * bias

    return {
        model = model,
        part = part,
        pos = pos,
        screenDist = screenDist,
        worldDist = wdist,
        score = score,
    }
end

local function getAllTargets()
    local out = {}
    -- Players
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            table.insert(out, plr.Character)
        end
    end
    -- NPCs
    for _, obj in ipairs(WS:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
            table.insert(out, obj)
        end
    end
    return out
end

local function findBestTarget()
    local best = nil
    local bestScore = math.huge
    for _, model in ipairs(getAllTargets()) do
        local ev = evaluateTarget(model)
        if ev and ev.score < bestScore then
            bestScore = ev.score
            best = ev
        end
    end
    return best
end

-- ═══ Sticky Target Re-check ═══
local function revalidateTarget()
    local t = AimbotState.target
    if not t or not t.model or not t.model.Parent then return false end
    local hum = t.model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    local pos, part = getTargetPosition(t.model)
    if not pos then return false end

    -- Still within sticky FOV?
    local sp, on = Cam:WorldToViewportPoint(pos)
    if not on then return false end
    local center = Vector2.new(Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2)
    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
    local maxD = Config.Aimbot.FOV * Config.Aimbot.StickyMultiplier
    if d > maxD then return false end

    local wdist = (Cam.CFrame.Position - pos).Magnitude
    if wdist > Config.Aimbot.MaxDist * 1.15 then return false end
    if not isVisible(pos, t.model) then return false end

    -- Refresh position with prediction
    t.pos = predictPosition(part)
    t.part = part
    t.screenDist = d
    t.worldDist = wdist
    return true
end

-- ═══ Aim Math ═══
local function aimAt(targetPos, alpha)
    local cur = Cam.CFrame
    local camPos = cur.Position
    local target = CFrame.new(camPos, targetPos)

    -- Preserve roll to avoid weird camera tilt
    local _, _, roll = cur:ToOrientation()
    target = target * CFrame.Angles(0, 0, roll)

    if alpha >= 1 then
        Cam.CFrame = target
    else
        Cam.CFrame = cur:Lerp(target, alpha)
    end
end

-- ═══ Main Aim Loop — runs AFTER Roblox's camera update ═══
Run:BindToRenderStep("ModarkAimbot", Enum.RenderPriority.Camera.Value + 1, function(dt)
    updateFOVCircle()

    if not Config.Aimbot.Enabled then
        AimbotState.target = nil
        return
    end
    if Config.Aimbot.HoldKey and not AimbotState.aimHeld then
        AimbotState.target = nil
        return
    end
    if not LP.Character then return end

    -- Try sticky target
    if not revalidateTarget() then
        AimbotState.target = findBestTarget()
    end

    if AimbotState.target and AimbotState.target.pos then
        local alpha = Config.Aimbot.Instant and 1 or Config.Aimbot.Smoothing
        aimAt(AimbotState.target.pos, alpha)
    end
end)

-- ═════════════════════════════════════════════════════════════
-- ESP ENGINE
-- ═════════════════════════════════════════════════════════════
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
    nameL.Size = UDim2.new(1, 0, 0, 14); nameL.Position = UDim2.new(0, 0, 0, 0)
    nameL.BackgroundTransparency = 1; nameL.Text = model.Name
    nameL.TextColor3 = Theme.Red; nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 13; nameL.TextStrokeTransparency = 0
    nameL.TextStrokeColor3 = Color3.new(0,0,0)

    local distL = Instance.new("TextLabel", bb)
    distL.Name = "DistL"
    distL.Size = UDim2.new(1, 0, 0, 12); distL.Position = UDim2.new(0, 0, 0, 14)
    distL.BackgroundTransparency = 1; distL.Text = "0 studs"
    distL.TextColor3 = Theme.Red; distL.Font = Enum.Font.Gotham
    distL.TextSize = 10; distL.TextStrokeTransparency = 0
    distL.TextStrokeColor3 = Color3.new(0,0,0)

    local hpL = Instance.new("TextLabel", bb)
    hpL.Name = "HpL"
    hpL.Size = UDim2.new(1, 0, 0, 12); hpL.Position = UDim2.new(0, 0, 0, 26)
    hpL.BackgroundTransparency = 1; hpL.Text = "100/100"
    hpL.TextColor3 = Theme.Green; hpL.Font = Enum.Font.Gotham
    hpL.TextSize = 10; hpL.TextStrokeTransparency = 0
    hpL.TextStrokeColor3 = Color3.new(0,0,0)

    ESPBillboards[model] = bb
    return bb
end

local function removeESPFor(model)
    if ESPHighlights[model] then ESPHighlights[model]:Destroy(); ESPHighlights[model] = nil end
    if ESPBillboards[model] then ESPBillboards[model]:Destroy(); ESPBillboards[model] = nil end
end

local function applyESPToModel(model, isNPC)
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then removeESPFor(model); return end
    local hl = getHighlight(model)
    hl.Enabled = true
    local col = isNPC and Theme.Yellow or Theme.Red
    hl.OutlineColor = col
    hl.FillColor = col
    hl.FillTransparency = Config.ESP.Chams and Config.ESP.ChamsFill or 1

    if Config.ESP.Name or Config.ESP.Distance or Config.ESP.Health then
        local bb = getBillboard(model)
        if bb then
            local hrp = model:FindFirstChild("HumanoidRootPart")
            local dist = hrp and (Cam.CFrame.Position - hrp.Position).Magnitude or 0
            bb.Enabled = dist <= Config.ESP.MaxDist
            local nameL = bb:FindFirstChild("NameL")
            local distL = bb:FindFirstChild("DistL")
            local hpL = bb:FindFirstChild("HpL")
            if nameL then
                nameL.Visible = Config.ESP.Name
                local plr = Players:GetPlayerFromCharacter(model)
                nameL.Text = plr and plr.DisplayName or model.Name
                nameL.TextColor3 = col
            end
            if distL then
                distL.Visible = Config.ESP.Distance
                distL.Text = string.format("%d studs", dist)
                distL.TextColor3 = col
            end
            if hpL then
                hpL.Visible = Config.ESP.Health
                hpL.Text = string.format("%d/%d", hum.Health, hum.MaxHealth)
            end
        end
    end
end

Run.RenderStepped:Connect(function()
    if not Config.ESP.Enabled then
        for m in pairs(ESPHighlights) do removeESPFor(m) end
        return
    end
    -- Players
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            if Config.ESP.Players then applyESPToModel(plr.Character, false)
            else removeESPFor(plr.Character) end
        end
    end
    -- NPCs
    for _, obj in ipairs(WS:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
            if Config.ESP.NPCs then applyESPToModel(obj, true)
            else removeESPFor(obj) end
        end
    end
end)

-- ═════════════════════════════════════════════════════════════
-- TRIGGERBOT
-- ═════════════════════════════════════════════════════════════
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
                                pcall(function() if mouse1click then mouse1click() end end)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ═════════════════════════════════════════════════════════════
-- MOVEMENT / MISC (unchanged)
-- ═════════════════════════════════════════════════════════════
Run.Heartbeat:Connect(function()
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if Config.Speed.Enabled then hum.WalkSpeed = Config.Speed.Value end
    if Config.Jump.Enabled then
        hum.UseJumpPower = true
        hum.JumpPower = Config.Jump.Value
    end
end)

UIS.JumpRequest:Connect(function()
    if Config.InfJump then
        local char = LP.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

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
    if Config.Fly.Enabled and not flyBV then startFly()
    elseif not Config.Fly.Enabled and flyBV then stopFly() end
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
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        flyBV.Velocity = dir * speed
    end
end)

task.spawn(function()
    while screen.Parent do
        task.wait(30)
        if Config.AntiAFK then
            pcall(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end
    end
end)

task.spawn(function()
    local startTime = tick()
    while screen.Parent do
        task.wait(1)
        if Config.Stats then
            local ping = pcall(function() return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() end)
            local uptimeS = tick() - startTime
            statsLabel.Text = string.format(
                "FPS: %d  |  Ping: %d ms\nUptime: %02d:%02d:%02d",
                math.floor(1 / Run.RenderStepped:Wait()),
                math.floor(ping or 0),
                math.floor(uptimeS / 3600), math.floor(uptimeS / 60) % 60, math.floor(uptimeS) % 60
            )
        end
    end
end)

-- ═════════════════════════════════════════════════════════════
-- START
-- ═════════════════════════════════════════════════════════════
task.wait(0.4)
notify("MODARK HUB v1.1", "Aimbot الجديد جاهز", Theme.Accent)
task.wait(0.6)
notify("Aimbot", "RMB للتفعيل · Target Sticking · Prediction", Theme.Blue)

print("[M] ═══════════════════════════════════")
print("[M] MODARK HUB v1.1 — LOADED")
print("[M] Aimbot: Premium Edition")
print("[M] User:", LP.Name, "| Place:", game.PlaceId)
print("[M] ═══════════════════════════════════")

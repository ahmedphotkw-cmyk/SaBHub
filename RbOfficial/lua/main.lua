Enter--[[
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║      🥚  E G G   F I N D E R  ·  G O   E D I T I O N                          ║
║                                                                              ║
║                       v10.3 — Go + Floating Go + Value Rank                   ║
║                                                                              ║
║   • Value parser (309K / 1.5M / 2.3B / $1,234K+)                             ║
║   • Tier system by VALUE                                                     ║
║   • Sort by value (keyword fallback)                                          ║
║   • All v10.2 features intact + ROBUST RENDER                                 ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
]]

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🥚 EGG FINDER v10.3 — GO + VALUE RANK")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

local function safe_service(name)
    local ok, s = pcall(function() return game:GetService(name) end)
    return ok and s or nil
end

local Players       = safe_service("Players")
local TweenService  = safe_service("TweenService")
local UIS           = safe_service("UserInputService")
local CollectionSvc = safe_service("CollectionService")

local LocalPlayer = Players and Players.LocalPlayer
if not LocalPlayer then
    for _ = 1, 30 do
        task.wait(0.1)
        LocalPlayer = Players and Players.LocalPlayer
        if LocalPlayer then break end
    end
end

print("[BOOT]", LocalPlayer and LocalPlayer.Name or "❌")

-- ═════════════════════════════════════════════════════════════════════════════
--   PALETTE
-- ═════════════════════════════════════════════════════════════════════════════

local P = {
    GOLD        = Color3.fromRGB(255, 215, 0),
    GOLD_DARK   = Color3.fromRGB(180, 140, 0),
    GOLD_LIGHT  = Color3.fromRGB(255, 235, 120),
    BG_DARK     = Color3.fromRGB(8, 8, 14),
    BG_MAIN     = Color3.fromRGB(18, 18, 28),
    BG_PANEL    = Color3.fromRGB(26, 26, 40),
    BG_ROW      = Color3.fromRGB(34, 34, 50),
    BG_SUB      = Color3.fromRGB(22, 22, 34),
    TEXT        = Color3.fromRGB(245, 245, 250),
    TEXT_DIM    = Color3.fromRGB(150, 150, 175),
    TEXT_MUTED  = Color3.fromRGB(100, 100, 125),
    GREEN       = Color3.fromRGB(80, 220, 120),
    GREEN_DARK  = Color3.fromRGB(40, 140, 80),
    RED         = Color3.fromRGB(230, 70, 90),
    RED_DARK    = Color3.fromRGB(150, 40, 55),
    BLUE        = Color3.fromRGB(80, 140, 230),
    PURPLE      = Color3.fromRGB(150, 90, 220),
    PINK        = Color3.fromRGB(230, 100, 180),
    CYAN        = Color3.fromRGB(80, 220, 220),
    ORANGE      = Color3.fromRGB(255, 140, 50),
    COMMON      = Color3.fromRGB(180, 180, 180),
    UNCOMMON    = Color3.fromRGB(100, 220, 100),
    RARE        = Color3.fromRGB(80, 140, 230),
    EPIC        = Color3.fromRGB(180, 100, 220),
    LEGENDARY   = Color3.fromRGB(255, 180, 50),
    MYTHICAL    = Color3.fromRGB(255, 80, 120),
    UNKNOWN     = Color3.fromRGB(90, 90, 90),
}

-- ═════════════════════════════════════════════════════════════════════════════
--   CONFIG
-- ═════════════════════════════════════════════════════════════════════════════

local CFG = {
    FLY_HEIGHT      = 4,
    TARGET_FOLDER   = "RenderedEggs",
    AUTO_REFRESH    = 8,
    FLY_TIME        = 0.18,
    RETURN_TIME     = 0.15,
    COLLECT_DELAY   = 0.25,
    AUTO_COLLECT_WAIT = 0.35,

    VALUE_TIERS = {
        { name = "MYTHICAL",  color = P.MYTHICAL,  min = 1e9 },
        { name = "LEGENDARY", color = P.LEGENDARY, min = 1e8 },
        { name = "EPIC",      color = P.EPIC,      min = 1e7 },
        { name = "RARE",      color = P.RARE,      min = 1e6 },
        { name = "UNCOMMON",  color = P.UNCOMMON,  min = 1e5 },
        { name = "COMMON",    color = P.COMMON,    min = 0   },
    },
}

-- ═════════════════════════════════════════════════════════════════════════════
--   STATE
-- ═════════════════════════════════════════════════════════════════════════════

local STATE = {
    eggs = {},
    total = 0,
    expanded = {},
    saved_position = nil,
    auto_collect_running = false,
    ui = nil,
    running = true,
    last_error = "لا يوجد",
    egg_values = {},
}

-- ═════════════════════════════════════════════════════════════════════════════
--   RARITY (keyword fallback)
-- ═════════════════════════════════════════════════════════════════════════════

local RARITY_LIST = {
    { rar = "MYTHICAL",  color = P.MYTHICAL,  kw = {"mythical", "myth", "eternal", "divine", "god", "supreme"} },
    { rar = "LEGENDARY", color = P.LEGENDARY, kw = {"legendary", "galaxy", "blackhole", "black hole", "dragon", "cosmic", "superstar", "rainbow"} },
    { rar = "EPIC",      color = P.EPIC,      kw = {"epic", "golden", "galactic", "phantom", "shadow"} },
    { rar = "RARE",      color = P.RARE,      kw = {"rare", "crystal", "diamond", "frozen", "ice", "sapphire", "emerald"} },
    { rar = "UNCOMMON",  color = P.UNCOMMON,  kw = {"uncommon", "silver", "jade", "ruby"} },
    { rar = "COMMON",    color = P.COMMON,    kw = {"common", "white", "brown", "blue", "red", "pink", "yellow", "black", "grey", "gray", "green"} },
}

local function get_rarity(name)
    if type(name) ~= "string" then return "COMMON", P.COMMON end
    local lower = name:lower()
    for _, r in ipairs(RARITY_LIST) do
        for _, kw in ipairs(r.kw) do
            if lower:find(kw, 1, true) then
                return r.rar, r.color
            end
        end
    end
    return "COMMON", P.COMMON
end

-- ═════════════════════════════════════════════════════════════════════════════
--   VALUE PARSER
-- ═════════════════════════════════════════════════════════════════════════════

local function parse_value_string(s)
    if not s or type(s) ~= "string" then return nil end
    local clean = s:gsub("[%$,%s%+%%]", "")
    if clean == "" then return nil end
    local num_str, suffix = clean:match("^(%d+%.?%d*)([KkMmBbTtGg]?)")
    if not num_str then return nil end
    local n = tonumber(num_str)
    if not n or n <= 0 then return nil end
    suffix = (suffix or ""):upper()
    if     suffix == "K" then n = n * 1e3
    elseif suffix == "M" then n = n * 1e6
    elseif suffix == "B" then n = n * 1e9
    elseif suffix == "T" then n = n * 1e12
    elseif suffix == "G" then n = n * 1e9
    end
    return n
end

local VALUE_KEYWORDS = {
    "value","worth","price","cost","score","money","coins","cash",
    "قيمة","سعر","نقاط","قيمت"
}

local function name_has_kw(name)
    if not name or type(name) ~= "string" then return false end
    local nl = name:lower()
    for _, kw in ipairs(VALUE_KEYWORDS) do
        if nl:find(kw, 1, true) then return true end
    end
    return false
end

local function extract_value(egg)
    if not egg then return nil end
    local targets = { egg }
    if egg.Parent then table.insert(targets, egg.Parent) end
    for _, t in ipairs(targets) do
        local ok, attrs = pcall(function() return t:GetAttributes() end)
        if ok and attrs then
            for k, v in pairs(attrs) do
                if name_has_kw(k) then
                    if type(v) == "number" and v > 0 then return v end
                    if type(v) == "string" then
                        local p = parse_value_string(v)
                        if p then return p end
                    end
                end
            end
        end
    end

    local ok, descs = pcall(function() return egg:GetDescendants() end)
    if ok and descs then
        for _, d in ipairs(descs) do
            if (d:IsA("NumberValue") or d:IsA("IntValue")) and name_has_kw(d.Name) then
                if d.Value > 0 then return d.Value end
            end
            if d:IsA("StringValue") and name_has_kw(d.Name) then
                local p = parse_value_string(d.Value)
                if p then return p end
            end
        end
    end

    if ok and descs then
        for _, d in ipairs(descs) do
            if d:IsA("TextLabel") or d:IsA("TextButton") then
                local par = d.Parent
                if par and (par:IsA("BillboardGui") or par:IsA("SurfaceGui") or par:IsA("ScreenGui")) then
                    local p = parse_value_string(d.Text)
                    if p then return p end
                end
            end
        end
    end

    return parse_value_string(egg.Name)
end

local function tier_of_value(value)
    if not value then return "UNKNOWN", P.UNKNOWN end
    for _, t in ipairs(CFG.VALUE_TIERS) do
        if value >= t.min then return t.name, t.color end
    end
    return "COMMON", P.COMMON
end

local function fmt_value(v)
    if not v then return "—" end
    if v >= 1e12 then return string.format("%.2fT", v/1e12) end
    if v >= 1e9  then return string.format("%.2fB", v/1e9)  end
    if v >= 1e6  then return string.format("%.2fM", v/1e6)  end
    if v >= 1e3  then return string.format("%.1fK", v/1e3)  end
    return tostring(math.floor(v))
end

local function group_best_value(insts)
    if not insts then return nil end
    local best = nil
    for _, inst in ipairs(insts) do
        local v = STATE.egg_values[inst]
        if v and (not best or v > best) then best = v end
    end
    return best
end

-- ═════════════════════════════════════════════════════════════════════════════
--   HELPERS
-- ═════════════════════════════════════════════════════════════════════════════

local function get_pos(inst)
    if not inst then return nil end
    if inst:IsA("Model") then
        if inst.PrimaryPart then return inst.PrimaryPart.Position end
        for _, d in ipairs(inst:GetDescendants()) do
            if d:IsA("BasePart") then return d.Position end
        end
    end
    if inst:IsA("BasePart") then return inst.Position end
    for _, c in ipairs(inst:GetChildren()) do
        if c:IsA("BasePart") then return c.Position end
        if c:IsA("Model") and c.PrimaryPart then return c.PrimaryPart.Position end
    end
    return nil
end

local function get_main_part(inst)
    if not inst then return nil end
    if inst:IsA("Model") then
        if inst.PrimaryPart then return inst.PrimaryPart end
        for _, d in ipairs(inst:GetDescendants()) do
            if d:IsA("BasePart") then return d end
        end
    end
    if inst:IsA("BasePart") then return inst end
    for _, c in ipairs(inst:GetChildren()) do
        if c:IsA("BasePart") then return c end
    end
    return nil
end

local function clean_name(name)
    local c = name:gsub("%s*%(%d+%)%s*$", "")
    c = c:gsub("%s+$", "")
    if c == "" then c = name end
    return c
end

-- ═════════════════════════════════════════════════════════════════════════════
--   SCAN  (v10.2 + value extraction)
-- ═════════════════════════════════════════════════════════════════════════════

local function scan()
    local groups = {}
    local total = 0

    local ws = workspace or game:GetService("Workspace")
    if not ws then
        STATE.last_error = "لا يوجد workspace"
        return groups, 0
    end

    local source_list = {}
    local target = nil
    pcall(function() target = ws:FindFirstChild(CFG.TARGET_FOLDER) end)

    if target then
        pcall(function()
            for _, c in ipairs(target:GetChildren()) do
                table.insert(source_list, c)
            end
        end)
    end

    if #source_list == 0 then
        local ok, all = pcall(function() return ws:GetDescendants() end)
        if ok and all then
            for _, inst in ipairs(all) do
                local ok2, name = pcall(function() return inst.Name end)
                if ok2 and name then
                    local n = name:lower()
                    if n:find("egg", 1, true) or n:find("بيضة", 1, true) then
                        local is_child = false
                        local p = inst.Parent
                        local d = 0
                        while p and d < 3 do
                            if p ~= ws then
                                local ok3, pname = pcall(function() return p.Name end)
                                if ok3 and pname and pname:lower():find("egg", 1, true) and p ~= inst then
                                    is_child = true; break
                                end
                            end
                            p = p.Parent
                            d = d + 1
                        end
                        if not is_child then table.insert(source_list, inst) end
                    end
                end
            end
        end
    end

    -- ⚡ reset value store
    STATE.egg_values = {}

    for _, inst in ipairs(source_list) do
        local ok, name = pcall(function() return inst.Name end)
        if ok and name then
            local base = clean_name(name)
            if not groups[base] then groups[base] = {} end
            table.insert(groups[base], inst)
            total = total + 1

            -- ✨ extract value safely — never let this kill scan
            local ok_v, val = pcall(extract_value, inst)
            if ok_v and val then
                STATE.egg_values[inst] = val
            end
        end
    end

    STATE.last_error = total == 0 and "لم يُعثر على بيض" or "OK"
    return groups, total
end

-- ═════════════════════════════════════════════════════════════════════════════
--   ACTIONS
-- ═════════════════════════════════════════════════════════════════════════════

local function fly_to(egg)
    local char = LocalPlayer and LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local pos = get_pos(egg)
    if not pos then return false end
    TweenService:Create(hrp,
        TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {CFrame = CFrame.new(pos + Vector3.new(0, CFG.FLY_HEIGHT, 0))}):Play()
    return true
end

local function find_prompts_near(egg)
    local prompts = {}
    pcall(function()
        for _, d in ipairs(egg:GetDescendants()) do
            if d:IsA("ProximityPrompt") or d:IsA("ClickDetector") then
                table.insert(prompts, d)
            end
        end
    end)
    if #prompts == 0 then
        local pos = get_pos(egg)
        if pos then
            pcall(function()
                for _, d in ipairs(workspace:GetDescendants()) do
                    if d:IsA("ProximityPrompt") then
                        local parent = d.Parent
                        if parent and parent:IsA("BasePart") then
                            if (parent.Position - pos).Magnitude < 20 then
                                table.insert(prompts, d)
                            end
                        end
                    end
                end
            end)
        end
    end
    return prompts
end

local function fire_all_prompts(egg)
    local prompts = find_prompts_near(egg)
    if #prompts == 0 then return false end
    for _, p in ipairs(prompts) do
        pcall(function()
            if p:IsA("ProximityPrompt") and fireproximityprompt then
                fireproximityprompt(p)
            elseif p:IsA("ClickDetector") and fireclickdetector then
                fireclickdetector(p)
            end
        end)
        task.wait(0.05)
    end
    return true
end

local function auto_collect(egg, on_done)
    if STATE.auto_collect_running then
        if on_done then on_done(false) end
        return
    end
    if not STATE.saved_position then
        if on_done then on_done(false) end
        return
    end

    local char = LocalPlayer and LocalPlayer.Character
    if not char then if on_done then on_done(false) end return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then if on_done then on_done(false) end return end
    local egg_pos = get_pos(egg)
    if not egg_pos then if on_done then on_done(false) end return end

    STATE.auto_collect_running = true
    task.spawn(function()
        local saved = STATE.saved_position

        local t1 = TweenService:Create(hrp,
            TweenInfo.new(CFG.FLY_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
            {CFrame = CFrame.new(egg_pos + Vector3.new(0, CFG.FLY_HEIGHT, 0))})
        t1:Play(); t1.Completed:Wait()

        task.wait(CFG.COLLECT_DELAY)
        fire_all_prompts(egg)
        task.wait(CFG.AUTO_COLLECT_WAIT)
        fire_all_prompts(egg)

        local t2 = TweenService:Create(hrp,
            TweenInfo.new(CFG.RETURN_TIME, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
            {CFrame = CFrame.new(saved)})
        t2:Play(); t2.Completed:Wait()

        STATE.auto_collect_running = false
        if on_done then on_done(true) end
    end)
end

local function save_position()
    local char = LocalPlayer and LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    STATE.saved_position = hrp.Position
    return true
end

local function go_to_saved(on_done)
    if not STATE.saved_position then
        if on_done then on_done(false) end
        return false
    end
    local char = LocalPlayer and LocalPlayer.Character
    if not char then if on_done then on_done(false) end return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then if on_done then on_done(false) end return false end

    TweenService:Create(hrp,
        TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        {CFrame = CFrame.new(STATE.saved_position)}):Play()

    if on_done then on_done(true) end
    return true
end

-- ═════════════════════════════════════════════════════════════════════════════
--   DEEP INTEL
-- ═════════════════════════════════════════════════════════════════════════════

local function count_children_by_class(inst, class_name)
    local count = 0
    for _, d in ipairs(inst:GetDescendants()) do
        if d:IsA(class_name) then count = count + 1 end
    end
    return count
end

local function try_read(obj, prop)
    local ok, val = pcall(function() return obj[prop] end)
    if ok then return val end
    return nil
end

local function fmt_num(n, digits)
    if type(n) ~= "number" then return tostring(n) end
    return string.format("%." .. (digits or 2) .. "f", n)
end

local function get_network_owner(part)
    if not part then return "—" end
    local ok, owner = pcall(function() return part:GetNetworkOwner() end)
    if ok and owner then return owner.Name end
    if ok then return "Server" end
    return "—"
end

local function gather_egg_intel(egg)
    local data = {
        identity = {}, position = {}, physics = {}, appearance = {},
        structure = {}, attributes = {}, interactions = {}, effects = {},
        network = {}, tags = {}, value_info = {},
    }

    data.identity["Name"] = egg.Name
    data.identity["ClassName"] = egg.ClassName
    data.identity["FullName"] = egg:GetFullName()
    data.identity["Archivable"] = tostring(try_read(egg, "Archivable") or "—")

    -- ✨ value info
    local v = STATE.egg_values[egg]
    if not v then
        local ok_v, val = pcall(extract_value, egg)
        if ok_v then v = val end
    end
    if v then
        local tname = tier_of_value(v)
        data.value_info["Raw Value"] = fmt_num(v, 0)
        data.value_info["Display"] = fmt_value(v)
        data.value_info["Tier"] = tname
    else
        data.value_info["Raw Value"] = "—"
        data.value_info["Display"] = "—"
        data.value_info["Tier"] = "UNKNOWN"
    end

    local mp = get_main_part(egg)
    if mp then
        local p = mp.Position
        data.position["X"] = fmt_num(p.X)
        data.position["Y"] = fmt_num(p.Y)
        data.position["Z"] = fmt_num(p.Z)

        local size = mp.Size
        data.position["Size X"] = fmt_num(size.X)
        data.position["Size Y"] = fmt_num(size.Y)
        data.position["Size Z"] = fmt_num(size.Z)
        data.position["Volume"] = fmt_num(size.X * size.Y * size.Z, 3)

        local o1, o2, o3 = mp.CFrame:ToOrientation()
        data.position["Rotation X"] = fmt_num(math.deg(o1))
        data.position["Rotation Y"] = fmt_num(math.deg(o2))
        data.position["Rotation Z"] = fmt_num(math.deg(o3))
    end

    if mp then
        data.physics["Anchored"]     = tostring(try_read(mp, "Anchored"))
        data.physics["Massless"]     = tostring(try_read(mp, "Massless"))
        data.physics["CanCollide"]   = tostring(try_read(mp, "CanCollide"))
        data.physics["CanTouch"]     = tostring(try_read(mp, "CanTouch"))
        data.physics["CanQuery"]     = tostring(try_read(mp, "CanQuery"))
        data.physics["Locked"]       = tostring(try_read(mp, "Locked"))
        data.physics["RootPriority"] = tostring(try_read(mp, "RootPriority"))

        local vel = try_read(mp, "AssemblyLinearVelocity")
        if typeof(vel) == "Vector3" then
            data.physics["Vel X"] = fmt_num(vel.X)
            data.physics["Vel Y"] = fmt_num(vel.Y)
            data.physics["Vel Z"] = fmt_num(vel.Z)
        end
    end

    if mp then
        data.appearance["Transparency"] = fmt_num(try_read(mp, "Transparency"))
        data.appearance["Reflectance"]  = fmt_num(try_read(mp, "Reflectance"))
        data.appearance["Material"]     = tostring(try_read(mp, "Material"))
        local col = try_read(mp, "Color")
        if typeof(col) == "Color3" then
            data.appearance["Color RGB"] = string.format("(%d,%d,%d)",
                col.R * 255, col.G * 255, col.B * 255)
        end
        data.appearance["CastShadow"] = tostring(try_read(mp, "CastShadow"))
        data.appearance["Shape"]      = tostring(try_read(mp, "Shape"))
        data.appearance["TopSurface"] = tostring(try_read(mp, "TopSurface"))
        data.appearance["BottomSurface"] = tostring(try_read(mp, "BottomSurface"))
    end

    data.structure["Children"] = tostring(#egg:GetChildren())
    data.structure["Descendants"] = tostring(#egg:GetDescendants())
    data.structure["Parent"] = egg.Parent and egg.Parent.Name or "—"

    if egg:IsA("Model") then
        data.structure["PrimaryPart"] = egg.PrimaryPart and egg.PrimaryPart.Name or "لا يوجد"
    end

    local attrs = egg:GetAttributes()
    for k, v2 in pairs(attrs) do
        data.attributes[k] = tostring(v2)
    end

    local prompts = find_prompts_near(egg)
    data.interactions["Total Prompts"] = tostring(#prompts)

    data.interactions["ProximityPrompt"] = tostring(count_children_by_class(egg, "ProximityPrompt"))
    data.interactions["ClickDetector"] = tostring(count_children_by_class(egg, "ClickDetector"))

    if #prompts > 0 then
        local first = prompts[1]
        if first:IsA("ProximityPrompt") then
            data.interactions["Prompt.ActionText"] = tostring(try_read(first, "ActionText") or "—")
            data.interactions["Prompt.ObjectText"] = tostring(try_read(first, "ObjectText") or "—")
            data.interactions["Prompt.HoldDuration"] = fmt_num(try_read(first, "HoldDuration"))
            data.interactions["Prompt.MaxDistance"] = fmt_num(try_read(first, "MaxActivationDistance"))
            data.interactions["Prompt.Enabled"] = tostring(try_read(first, "Enabled"))
        end
    end

    data.effects["ParticleEmitters"] = tostring(count_children_by_class(egg, "ParticleEmitter"))
    data.effects["Sounds"]           = tostring(count_children_by_class(egg, "Sound"))
    data.effects["Attachments"]      = tostring(count_children_by_class(egg, "Attachment"))
    data.effects["PointLights"]      = tostring(count_children_by_class(egg, "PointLight"))
    data.effects["SpotLights"]       = tostring(count_children_by_class(egg, "SpotLight"))
    data.effects["SurfaceLights"]    = tostring(count_children_by_class(egg, "SurfaceLight"))
    data.effects["Trails"]           = tostring(count_children_by_class(egg, "Trail"))
    data.effects["Beams"]            = tostring(count_children_by_class(egg, "Beam"))
    data.effects["BillboardGuis"]    = tostring(count_children_by_class(egg, "BillboardGui"))

    if mp then
        data.network["Network Owner"] = get_network_owner(mp)
        data.network["Root Part"] = (function()
            local ok, rp = pcall(function() return mp:GetRootPart() end)
            return ok and rp and rp.Name or "—"
        end)()
    end

    if CollectionSvc then
        local tags = CollectionSvc:GetTags(egg)
        for i, t in ipairs(tags) do
            data.tags["Tag " .. i] = t
        end
    end

    return data
end

-- ═════════════════════════════════════════════════════════════════════════════
--   UI HELPERS
-- ═════════════════════════════════════════════════════════════════════════════

local function mk(class, props, parent)
    local ok, obj = pcall(Instance.new, class)
    if not ok or not obj then return nil end
    for k, v in pairs(props or {}) do
        pcall(function() obj[k] = v end)
    end
    if parent then pcall(function() obj.Parent = parent end) end
    return obj
end

local function corner(parent, radius)
    return mk("UICorner", {CornerRadius = UDim.new(0, radius)}, parent)
end

local function gradient(parent, c1, c2, rot)
    return mk("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, c1),
            ColorSequenceKeypoint.new(1, c2),
        }),
        Rotation = rot or 45,
    }, parent)
end

local function stroke(parent, color, thickness, transparency)
    return mk("UIStroke", {
        Color = color or Color3.fromRGB(0, 0, 0),
        Thickness = thickness or 1,
        Transparency = transparency or 0,
    }, parent)
end

local function make_draggable(frame)
    local dragging, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = frame.Position
        end
    end)
    frame.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch
                         or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
           or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

local function find_parent()
    if LocalPlayer then
        local ok, pg = pcall(function() return LocalPlayer:FindFirstChildOfClass("PlayerGui") end)
        if ok and pg then return pg end
    end
    if type(gethui) == "function" then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    local ok3, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok3 and cg and pcall(function() cg:GetChildren() end) then return cg end
    return nil
end

-- ═════════════════════════════════════════════════════════════════════════════
--   UI BUILDER
-- ═════════════════════════════════════════════════════════════════════════════

local UI = {}

function UI.build()
    print("[UI] build start")
    local parent = find_parent()
    if not parent then
        warn("[UI] no parent found")
        return nil
    end

    pcall(function()
        for _, c in ipairs(parent:GetChildren()) do
            if c.Name == "EggFinderV10" then c:Destroy() end
        end
    end)

    local screen = mk("ScreenGui", {
        Name = "EggFinderV10",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
    }, parent)
    if not screen then warn("[UI] ScreenGui failed"); return nil end

    if type(syn) == "table" and syn.protect_gui then
        pcall(function() syn.protect_gui(screen) end)
    end

    -- FLOATING #1
    local floating = mk("TextButton", {
        Name = "FloatEgg",
        Size = UDim2.new(0, 75, 0, 75),
        Position = UDim2.new(0, 15, 0.35, 0),
        BackgroundColor3 = P.GOLD,
        Text = "🥚",
        TextColor3 = Color3.fromRGB(0, 0, 0),
        Font = Enum.Font.GothamBlack,
        TextSize = 34,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Active = true,
        ZIndex = 10,
    }, screen)
    if floating then
        corner(floating, 40)
        gradient(floating, P.GOLD_LIGHT, P.GOLD_DARK, 45)
        stroke(floating, P.GOLD_LIGHT, 3, 0.2)
        make_draggable(floating)
    end

    -- FLOATING #2
    local floatingGo = mk("TextButton", {
        Name = "FloatGo",
        Size = UDim2.new(0, 75, 0, 75),
        Position = UDim2.new(0, 15, 0.35, 90),
        BackgroundColor3 = P.GREEN,
        Text = "🎯",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBlack,
        TextSize = 32,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Active = true,
        ZIndex = 10,
    }, screen)
    if floatingGo then
        corner(floatingGo, 40)
        gradient(floatingGo, P.CYAN, P.GREEN, 45)
        stroke(floatingGo, P.GREEN, 3, 0.2)
        make_draggable(floatingGo)

        floatingGo.MouseButton1Click:Connect(function()
            if STATE.saved_position then
                go_to_saved(function(ok)
                    if ok then
                        floatingGo.Text = "✓"
                        task.wait(0.5)
                        floatingGo.Text = "🎯"
                    else
                        floatingGo.Text = "✗"
                        task.wait(0.5)
                        floatingGo.Text = "🎯"
                    end
                end)
            else
                floatingGo.Text = "✗"
                task.wait(0.5)
                floatingGo.Text = "🎯"
            end
        end)
    end

    -- MAIN
    local main = mk("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 540, 0, 640),
        Position = UDim2.new(0, 100, 0.5, -320),
        BackgroundColor3 = P.BG_MAIN,
        BorderSizePixel = 0,
        Active = true,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 5,
    }, screen)
    if not main then warn("[UI] Main failed"); return nil end
    corner(main, 16)
    gradient(main, P.BG_MAIN, P.BG_DARK, 90)
    stroke(main, P.GOLD, 2, 0.1)
    make_draggable(main)

    if floating then
        floating.MouseButton1Click:Connect(function()
            main.Visible = not main.Visible
            floating.Text = main.Visible and "✕" or "🥚"
            gradient(floating,
                main.Visible and P.RED or P.GOLD_LIGHT,
                main.Visible and P.RED_DARK or P.GOLD_DARK, 45)
        end)
    end

    -- HEADER
    local header = mk("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 68),
        BackgroundColor3 = P.BG_PANEL,
        BorderSizePixel = 0,
    }, main)
    if header then
        corner(header, 16)
        gradient(header, P.BG_PANEL, P.BG_DARK, 90)
        mk("Frame", {
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = P.GOLD,
            BorderSizePixel = 0,
        }, header)

        mk("TextLabel", {
            Size = UDim2.new(0, 50, 1, 0),
            Position = UDim2.new(0, 12, 0, 0),
            BackgroundTransparency = 1,
            Text = "🥚",
            TextColor3 = P.GOLD,
            Font = Enum.Font.GothamBlack,
            TextSize = 32,
        }, header)

        mk("TextLabel", {
            Size = UDim2.new(1, -170, 0, 30),
            Position = UDim2.new(0, 68, 0, 12),
            BackgroundTransparency = 1,
            Text = "EGG FINDER",
            TextColor3 = P.GOLD,
            Font = Enum.Font.GothamBlack,
            TextSize = 20,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, header)

        mk("TextLabel", {
            Name = "DebugLabel",
            Size = UDim2.new(1, -170, 0, 20),
            Position = UDim2.new(0, 68, 0, 38),
            BackgroundTransparency = 1,
            Text = "GO · v10.3",
            TextColor3 = P.TEXT_DIM,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, header)

        local rBtn = mk("TextButton", {
            Name = "RefreshBtn",
            Size = UDim2.new(0, 44, 0, 44),
            Position = UDim2.new(1, -106, 0, 12),
            BackgroundColor3 = P.BLUE,
            Text = "🔄",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 20,
            BorderSizePixel = 0,
            AutoButtonColor = false,
        }, header)
        if rBtn then corner(rBtn, 10); gradient(rBtn, P.CYAN, P.BLUE, 45) end

        local cBtn = mk("TextButton", {
            Name = "CloseBtn",
            Size = UDim2.new(0, 44, 0, 44),
            Position = UDim2.new(1, -56, 0, 12),
            BackgroundColor3 = P.RED,
            Text = "✕",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 20,
            BorderSizePixel = 0,
            AutoButtonColor = false,
        }, header)
        if cBtn then
            corner(cBtn, 10)
            gradient(cBtn, P.RED, P.RED_DARK, 45)
            cBtn.MouseButton1Click:Connect(function()
                main.Visible = false
                if floating then
                    floating.Text = "🥚"
                    gradient(floating, P.GOLD_LIGHT, P.GOLD_DARK, 45)
                end
            end)
        end
    end

    -- STATS
    local stats = mk("Frame", {
        Name = "Stats",
        Size = UDim2.new(1, -20, 0, 50),
        Position = UDim2.new(0, 10, 0, 78),
        BackgroundColor3 = P.BG_PANEL,
        BorderSizePixel = 0,
    }, main)
    if stats then
        corner(stats, 12)
        gradient(stats, P.BG_PANEL, P.BG_DARK, 90)
        stroke(stats, P.GOLD_DARK, 1, 0.5)

        mk("TextLabel", {
            Name = "EggCount",
            Size = UDim2.new(0.5, -20, 0, 25),
            Position = UDim2.new(0, 15, 0, 5),
            BackgroundTransparency = 1,
            Text = "🥚 0 EGGS",
            TextColor3 = P.TEXT,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, stats)

        mk("TextLabel", {
            Name = "GroupCount",
            Size = UDim2.new(0.5, -20, 0, 25),
            Position = UDim2.new(0, 15, 0, 24),
            BackgroundTransparency = 1,
            Text = "📊 0 GROUPS",
            TextColor3 = P.TEXT_DIM,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, stats)

        mk("TextLabel", {
            Name = "TopValue",
            Size = UDim2.new(0.5, -20, 0, 25),
            Position = UDim2.new(0.5, 0, 0, 5),
            BackgroundTransparency = 1,
            Text = "🏆 TOP: —",
            TextColor3 = P.GOLD,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, stats)

        mk("TextLabel", {
            Name = "ValueCount",
            Size = UDim2.new(0.5, -20, 0, 25),
            Position = UDim2.new(0.5, 0, 0, 24),
            BackgroundTransparency = 1,
            Text = "💰 0 RANKED",
            TextColor3 = P.GREEN,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, stats)

        local dot = mk("Frame", {
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(1, -30, 0, 19),
            BackgroundColor3 = P.GREEN,
            BorderSizePixel = 0,
        }, stats)
        if dot then corner(dot, 6) end
    end

    -- LOCATION PANEL
    local locPanel = mk("Frame", {
        Name = "LocationPanel",
        Size = UDim2.new(1, -20, 0, 90),
        Position = UDim2.new(0, 10, 0, 138),
        BackgroundColor3 = P.BG_PANEL,
        BorderSizePixel = 0,
    }, main)
    if locPanel then
        corner(locPanel, 12)
        gradient(locPanel, P.BG_PANEL, P.BG_DARK, 90)
        stroke(locPanel, P.GOLD, 1.5, 0.3)

        mk("TextLabel", {
            Size = UDim2.new(1, -20, 0, 22),
            Position = UDim2.new(0, 12, 0, 6),
            BackgroundTransparency = 1,
            Text = "📍  تحديد المكان (نقطة العودة)",
            TextColor3 = P.GOLD,
            Font = Enum.Font.GothamBlack,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, locPanel)

        local coordLabel = mk("TextLabel", {
            Name = "Coords",
            Size = UDim2.new(1, -20, 0, 18),
            Position = UDim2.new(0, 12, 0, 28),
            BackgroundTransparency = 1,
            Text = "لم يتم حفظ مكان بعد",
            TextColor3 = P.TEXT_MUTED,
            Font = Enum.Font.Code,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
        }, locPanel)

        local saveBtn = mk("TextButton", {
            Name = "SaveBtn",
            Size = UDim2.new(0, 240, 0, 34),
            Position = UDim2.new(0, 12, 1, -42),
            BackgroundColor3 = P.GREEN,
            Text = "💾 حفظ المكان الحالي",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            BorderSizePixel = 0,
            AutoButtonColor = false,
        }, locPanel)
        if saveBtn then corner(saveBtn, 8); gradient(saveBtn, P.GREEN, P.GREEN_DARK, 45) end

        local clearBtn = mk("TextButton", {
            Name = "ClearBtn",
            Size = UDim2.new(0, 240, 0, 34),
            Position = UDim2.new(0, 260, 1, -42),
            BackgroundColor3 = P.RED,
            Text = "🗑 مسح المكان",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            BorderSizePixel = 0,
            AutoButtonColor = false,
        }, locPanel)
        if clearBtn then corner(clearBtn, 8); gradient(clearBtn, P.RED, P.RED_DARK, 45) end

        if saveBtn then
            saveBtn.MouseButton1Click:Connect(function()
                if save_position() then
                    local pos = STATE.saved_position
                    coordLabel.Text = string.format("✅ X: %.1f  Y: %.1f  Z: %.1f", pos.X, pos.Y, pos.Z)
                    coordLabel.TextColor3 = P.GREEN
                end
            end)
        end

        if clearBtn then
            clearBtn.MouseButton1Click:Connect(function()
                STATE.saved_position = nil
                coordLabel.Text = "لم يتم حفظ مكان بعد"
                coordLabel.TextColor3 = P.TEXT_MUTED
            end)
        end
    end

    -- SEARCH
    local searchFrame = mk("Frame", {
        Size = UDim2.new(1, -20, 0, 42),
        Position = UDim2.new(0, 10, 0, 238),
        BackgroundColor3 = P.BG_PANEL,
        BorderSizePixel = 0,
    }, main)
    if searchFrame then
        corner(searchFrame, 10)
        stroke(searchFrame, P.GOLD, 1, 0.6)

        mk("TextLabel", {
            Size = UDim2.new(0, 40, 1, 0),
            BackgroundTransparency = 1,
            Text = "🔍",
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextColor3 = P.GOLD,
        }, searchFrame)

        mk("TextBox", {
            Name = "Search",
            Size = UDim2.new(1, -50, 1, 0),
            Position = UDim2.new(0, 45, 0, 0),
            BackgroundTransparency = 1,
            Text = "",
            PlaceholderText = "Search eggs...",
            TextColor3 = P.TEXT,
            PlaceholderColor3 = P.TEXT_MUTED,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            ClearTextOnFocus = false,
        }, searchFrame)
    end

    -- LIST
    local list = mk("ScrollingFrame", {
        Name = "List",
        Size = UDim2.new(1, -20, 1, -330),
        Position = UDim2.new(0, 10, 0, 288),
        BackgroundColor3 = P.BG_DARK,
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        ScrollBarImageColor3 = P.GOLD,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, main)
    if list then
        corner(list, 12)
        stroke(list, P.GOLD_DARK, 1, 0.7)
        mk("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, list)
        mk("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, list)
    end

    -- INFO OVERLAY
    local infoOverlay = mk("TextButton", {
        Name = "InfoOverlay",
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        Text = "",
        AutoButtonColor = false,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 18,
    }, screen)

    -- INFO PANEL
    local infoPanel = mk("Frame", {
        Name = "InfoPanel",
        Size = UDim2.new(0.92, 0, 0.88, 0),
        Position = UDim2.new(0.04, 0, 0.06, 0),
        BackgroundColor3 = P.BG_MAIN,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 20,
    }, screen)

    local function closeInfo()
        if infoPanel then infoPanel.Visible = false end
        if infoOverlay then infoOverlay.Visible = false end
    end

    if infoPanel then
        corner(infoPanel, 16)
        gradient(infoPanel, P.BG_MAIN, P.BG_DARK, 90)
        stroke(infoPanel, P.GOLD, 2, 0.1)

        local ih = mk("Frame", {
            Name = "InfoHeader",
            Size = UDim2.new(1, 0, 0, 60),
            BackgroundColor3 = P.BG_PANEL,
            BorderSizePixel = 0,
        }, infoPanel)
        if ih then
            corner(ih, 16)
            gradient(ih, P.BG_PANEL, P.BG_DARK, 90)

            mk("TextLabel", {
                Name = "InfoTitle",
                Size = UDim2.new(1, -80, 1, 0),
                Position = UDim2.new(0, 15, 0, 0),
                BackgroundTransparency = 1,
                Text = "🥚 Egg Intel",
                TextColor3 = P.GOLD,
                Font = Enum.Font.GothamBlack,
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
            }, ih)

            local icB = mk("TextButton", {
                Name = "InfoCloseBtn",
                Size = UDim2.new(0, 50, 0, 50),
                Position = UDim2.new(1, -58, 0, 5),
                BackgroundColor3 = P.RED,
                Text = "✕",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamBlack,
                TextSize = 22,
                BorderSizePixel = 0,
                AutoButtonColor = false,
                ZIndex = 22,
            }, ih)
            if icB then
                corner(icB, 12)
                gradient(icB, P.RED, P.RED_DARK, 45)
                icB.MouseButton1Click:Connect(closeInfo)
            end
        end

        mk("ScrollingFrame", {
            Name = "Content",
            Size = UDim2.new(1, -20, 1, -130),
            Position = UDim2.new(0, 10, 0, 70),
            BackgroundColor3 = P.BG_DARK,
            BorderSizePixel = 0,
            ScrollBarThickness = 6,
            ScrollBarImageColor3 = P.GOLD,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
        }, infoPanel)

        local bottomClose = mk("TextButton", {
            Name = "InfoBottomClose",
            Size = UDim2.new(1, -20, 0, 40),
            Position = UDim2.new(0, 10, 1, -50),
            BackgroundColor3 = P.RED,
            Text = "✕  إغلاق",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamBlack,
            TextSize = 15,
            BorderSizePixel = 0,
            AutoButtonColor = false,
            ZIndex = 22,
        }, infoPanel)
        if bottomClose then
            corner(bottomClose, 10)
            gradient(bottomClose, P.RED, P.RED_DARK, 45)
            bottomClose.MouseButton1Click:Connect(closeInfo)
        end
    end

    if infoOverlay then
        infoOverlay.MouseButton1Click:Connect(closeInfo)
    end

    local content = infoPanel and infoPanel:FindFirstChild("Content")
    if content then
        corner(content, 10)
        mk("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)}, content)
        mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, content)
    end

    print("[UI] build complete")

    return {
        screen = screen,
        floating = floating,
        floatingGo = floatingGo,
        main = main,
        list = list,
        stats = stats,
        search = searchFrame and searchFrame:FindFirstChild("Search") or nil,
        refreshBtn = header and header:FindFirstChild("RefreshBtn") or nil,
        eggCount = stats and stats:FindFirstChild("EggCount") or nil,
        groupCount = stats and stats:FindFirstChild("GroupCount") or nil,
        topValue = stats and stats:FindFirstChild("TopValue") or nil,
        valueCount = stats and stats:FindFirstChild("ValueCount") or nil,
        debugLabel = header and header:FindFirstChild("DebugLabel") or nil,
        infoPanel = infoPanel,
        infoOverlay = infoOverlay,
        infoContent = content,
        infoTitle = infoPanel and infoPanel:FindFirstChild("InfoHeader") and infoPanel.InfoHeader:FindFirstChild("InfoTitle") or nil,
        closeInfo = closeInfo,
    }
end

-- ═════════════════════════════════════════════════════════════════════════════
--   INFO PANEL RENDER
-- ═════════════════════════════════════════════════════════════════════════════

local order_counter = 0
local function no() order_counter = order_counter + 1; return order_counter end

local function add_section(parent, title, emoji, color)
    local header = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        LayoutOrder = no(),
    }, parent)
    corner(header, 6)
    stroke(header, color, 1, 0.4)

    mk("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = emoji .. "  " .. title,
        TextColor3 = color,
        Font = Enum.Font.GothamBlack,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)
end

local function add_row(parent, label, value, color)
    local row = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = P.BG_PANEL,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        LayoutOrder = no(),
    }, parent)
    corner(row, 5)

    mk("TextLabel", {
        Size = UDim2.new(0.42, -10, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = P.TEXT_DIM,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)

    local valText = tostring(value)
    if #valText > 40 then valText = valText:sub(1, 37) .. "..." end

    mk("TextLabel", {
        Size = UDim2.new(0.58, -10, 1, 0),
        Position = UDim2.new(0.42, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = valText,
        TextColor3 = color or P.TEXT,
        Font = Enum.Font.Code,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, row)
end

local function show_egg_info(egg)
    local ui = STATE.ui
    if not ui or not ui.infoContent or not ui.infoPanel then return end

    order_counter = 0
    for _, c in ipairs(ui.infoContent:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end

    if ui.infoTitle then
        ui.infoTitle.Text = "🥚 " .. egg.Name
    end

    local intel = gather_egg_intel(egg)

    add_section(ui.infoContent, "القيمة والتصنيف", "🏆", P.GOLD)
    for k, v in pairs(intel.value_info) do
        add_row(ui.infoContent, k, v, P.GOLD)
    end

    add_section(ui.infoContent, "الهوية", "🆔", P.GOLD)
    for k, v in pairs(intel.identity) do
        add_row(ui.infoContent, k, v, P.TEXT)
    end

    add_section(ui.infoContent, "الموقع والأبعاد", "📍", P.GREEN)
    for k, v in pairs(intel.position) do
        add_row(ui.infoContent, k, v, P.GREEN)
    end

    add_section(ui.infoContent, "الفيزياء", "⚙️", P.BLUE)
    for k, v in pairs(intel.physics) do
        add_row(ui.infoContent, k, v, P.BLUE)
    end

    add_section(ui.infoContent, "المظهر", "🎨", P.PINK)
    for k, v in pairs(intel.appearance) do
        add_row(ui.infoContent, k, v, P.PINK)
    end

    add_section(ui.infoContent, "البنية", "🌳", P.CYAN)
    for k, v in pairs(intel.structure) do
        add_row(ui.infoContent, k, v, P.CYAN)
    end

    add_section(ui.infoContent, "الخصائص (Attributes)", "📋", P.ORANGE)
    local has_attrs = false
    for k, v in pairs(intel.attributes) do
        add_row(ui.infoContent, k, v, P.ORANGE)
        has_attrs = true
    end
    if not has_attrs then
        add_row(ui.infoContent, "—", "لا يوجد", P.TEXT_MUTED)
    end

    add_section(ui.infoContent, "التفاعلات", "🎯", P.PURPLE)
    for k, v in pairs(intel.interactions) do
        add_row(ui.infoContent, k, v, P.PURPLE)
    end

    add_section(ui.infoContent, "المؤثرات", "💫", P.GOLD_LIGHT)
    for k, v in pairs(intel.effects) do
        add_row(ui.infoContent, k, v, P.GOLD_LIGHT)
    end

    add_section(ui.infoContent, "الشبكة", "🌐", P.RED)
    for k, v in pairs(intel.network) do
        add_row(ui.infoContent, k, v, P.RED)
    end

    add_section(ui.infoContent, "العلامات (Tags)", "🏷️", P.GREEN)
    local has_tags = false
    for k, v in pairs(intel.tags) do
        add_row(ui.infoContent, k, v, P.GREEN)
        has_tags = true
    end
    if not has_tags then
        add_row(ui.infoContent, "—", "لا يوجد", P.TEXT_MUTED)
    end

    if ui.infoOverlay then ui.infoOverlay.Visible = true end
    ui.infoPanel.Visible = true
end

-- ═════════════════════════════════════════════════════════════════════════════
--   RENDER (ROBUST — no continue, all wrapped)
-- ═════════════════════════════════════════════════════════════════════════════

local ord = 0
local function next_ord() ord = ord + 1; return ord end

local function render(filter)
    if not STATE.ui or not STATE.ui.list then
        warn("[render] no list")
        return
    end

    for _, c in ipairs(STATE.ui.list:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end

    ord = 0
    filter = (filter or ""):lower()

    -- collect matching group names
    local names = {}
    for n, _ in pairs(STATE.eggs) do
        local ok, match = pcall(function() return n:lower():find(filter, 1, true) end)
        if ok and match then table.insert(names, n) end
    end

    -- sort: value desc → keyword rarity → count
    table.sort(names, function(a, b)
        local va = group_best_value(STATE.eggs[a])
        local vb = group_best_value(STATE.eggs[b])

        if va and vb then
            if va ~= vb then return va > vb end
        elseif va and not vb then
            return true
        elseif vb and not va then
            return false
        end

        local ra = select(1, get_rarity(a))
        local rb = select(1, get_rarity(b))
        if ra ~= rb then
            local o = { MYTHICAL=1, LEGENDARY=2, EPIC=3, RARE=4, UNCOMMON=5, COMMON=6 }
            return (o[ra] or 99) < (o[rb] or 99)
        end
        return #STATE.eggs[a] > #STATE.eggs[b]
    end)

    if #names == 0 then
        mk("TextLabel", {
            Size = UDim2.new(1, -10, 0, 80),
            BackgroundTransparency = 1,
            Text = "🥚\nلا يوجد بيض\n\n" .. STATE.last_error,
            TextColor3 = P.TEXT_DIM,
            Font = Enum.Font.Gotham,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Center,
            LayoutOrder = next_ord(),
        }, STATE.ui.list)
        return
    end

    local count = 0
    for _, name in ipairs(names) do
        count = count + 1
        local eggs = STATE.eggs[name]
        local expanded = STATE.expanded[name] or false
        local rar = select(1, get_rarity(name))
        local rarColor = select(2, get_rarity(name))

        -- value of the group (best of instances)
        local gval = group_best_value(eggs)
        local vTier = select(1, tier_of_value(gval))
        local vColor = select(2, tier_of_value(gval))
        local displayColor = gval and vColor or rarColor
        local displayTier  = gval and vTier  or rar
        local valueText    = gval and fmt_value(gval) or "—"

        -- ROW
        local row = mk("TextButton", {
            Size = UDim2.new(1, 0, 0, 70),
            BackgroundColor3 = P.BG_ROW,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = next_ord(),
        }, STATE.ui.list)

        if row then
            corner(row, 12)
            gradient(row, P.BG_ROW, P.BG_SUB, 90)
            stroke(row, displayColor, 1.5, 0.4)

            mk("Frame", {
                Size = UDim2.new(0, 4, 0.7, 0),
                Position = UDim2.new(0, 0, 0.15, 0),
                BackgroundColor3 = displayColor,
                BorderSizePixel = 0,
            }, row)
            local rb = row:FindFirstChildOfClass("Frame")
            if rb then corner(rb, 2) end

            local arrow = mk("TextButton", {
                Size = UDim2.new(0, 42, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = expanded and "▼" or "▶",
                TextColor3 = displayColor,
                Font = Enum.Font.GothamBlack,
                TextSize = 22,
                BorderSizePixel = 0,
                AutoButtonColor = false,
            }, row)

            mk("TextLabel", {
                Size = UDim2.new(0, 140, 0, 22),
                Position = UDim2.new(0, 55, 0, 12),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = P.TEXT,
                Font = Enum.Font.GothamBlack,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
            }, row)

            -- Tier chip (with count in text to save space)
            local tierText = displayTier
            if #eggs > 1 then tierText = tierText .. " ×" .. #eggs end

            local rt = mk("TextLabel", {
                Size = UDim2.new(0, 140, 0, 20),
                Position = UDim2.new(0, 55, 0, 38),
                BackgroundColor3 = displayColor,
                BackgroundTransparency = 0.85,
                Text = "  " .. tierText,
                TextColor3 = displayColor,
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
            }, row)
            if rt then corner(rt, 4) end

            -- Value box (in place of old count bubble)
            local vBox = mk("Frame", {
                Size = UDim2.new(0, 105, 0, 46),
                Position = UDim2.new(0, 205, 0, 12),
                BackgroundColor3 = displayColor,
                BackgroundTransparency = 0.78,
                BorderSizePixel = 0,
            }, row)
            if vBox then
                corner(vBox, 8)
                stroke(vBox, displayColor, 1, 0.5)

                mk("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 14),
                    Position = UDim2.new(0, 0, 0, 2),
                    BackgroundTransparency = 1,
                    Text = "VALUE",
                    TextColor3 = P.TEXT_DIM,
                    Font = Enum.Font.GothamBold,
                    TextSize = 9,
                }, vBox)

                mk("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 22),
                    Position = UDim2.new(0, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = valueText,
                    TextColor3 = displayColor,
                    Font = Enum.Font.GothamBlack,
                    TextSize = 15,
                }, vBox)
            end

            -- ℹ Info button
            local infoBtn = mk("TextButton", {
                Size = UDim2.new(0, 45, 0, 45),
                Position = UDim2.new(1, -153, 0, 12),
                BackgroundColor3 = P.PURPLE,
                Text = "ℹ",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamBlack,
                TextSize = 20,
                BorderSizePixel = 0,
                AutoButtonColor = false,
            }, row)
            if infoBtn then
                corner(infoBtn, 10)
                gradient(infoBtn, P.PINK, P.PURPLE, 45)
                infoBtn.MouseButton1Click:Connect(function()
                    if #eggs > 0 then show_egg_info(eggs[1]) end
                end)
            end

            -- ➡ Go
            local goBtn = mk("TextButton", {
                Size = UDim2.new(0, 45, 0, 45),
                Position = UDim2.new(1, -103, 0, 12),
                BackgroundColor3 = P.GREEN,
                Text = "➡",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamBlack,
                TextSize = 20,
                BorderSizePixel = 0,
                AutoButtonColor = false,
            }, row)
            if goBtn then
                corner(goBtn, 10)
                gradient(goBtn, P.CYAN, P.GREEN, 45)
                stroke(goBtn, P.GREEN, 1.5, 0.3)
                goBtn.MouseButton1Click:Connect(function()
                    if #eggs > 0 then
                        if fly_to(eggs[1]) then
                            goBtn.Text = "✓"
                            task.wait(0.5)
                            goBtn.Text = "➡"
                        else
                            goBtn.Text = "✗"
                            task.wait(0.5)
                            goBtn.Text = "➡"
                        end
                    end
                end)
            end

            -- 🚀 Auto
            local autoBtn = mk("TextButton", {
                Size = UDim2.new(0, 45, 0, 45),
                Position = UDim2.new(1, -53, 0, 12),
                BackgroundColor3 = P.CYAN,
                Text = "🚀",
                TextColor3 = Color3.fromRGB(0, 0, 0),
                Font = Enum.Font.GothamBlack,
                TextSize = 20,
                BorderSizePixel = 0,
                AutoButtonColor = false,
            }, row)
            if autoBtn then
                corner(autoBtn, 10)
                gradient(autoBtn, P.CYAN, P.BLUE, 45)
                autoBtn.MouseButton1Click:Connect(function()
                    if #eggs > 0 and not STATE.auto_collect_running then
                        autoBtn.Text = "⏳"
                        auto_collect(eggs[1], function(ok)
                            autoBtn.Text = ok and "✓" or "✗"
                            task.wait(0.8)
                            autoBtn.Text = "🚀"
                        end)
                    end
                end)
            end

            if arrow then
                arrow.MouseButton1Click:Connect(function()
                    STATE.expanded[name] = not STATE.expanded[name]
                    if STATE.ui and STATE.ui.search then
                        render(STATE.ui.search.Text)
                    end
                end)
            end
        end

        -- CHILDREN
        if expanded and eggs then
            for i, egg in ipairs(eggs) do
                local cval = STATE.egg_values[egg]
                local ctier = select(1, tier_of_value(cval))
                local ccolor = select(2, tier_of_value(cval))
                local subColor = cval and ccolor or rarColor

                local sub = mk("Frame", {
                    Size = UDim2.new(1, -30, 0, 60),
                    Position = UDim2.new(0, 25, 0, 0),
                    BackgroundColor3 = P.BG_SUB,
                    BorderSizePixel = 0,
                    LayoutOrder = next_ord(),
                }, STATE.ui.list)
                if sub then
                    corner(sub, 10)
                    stroke(sub, subColor, 1, 0.7)

                    -- parent + value in one line
                    local parentName = egg.Parent and egg.Parent.Name or "?"
                    local subText = "#" .. i .. "  " .. parentName
                    if cval then subText = subText .. "  ·  " .. fmt_value(cval) end

                    mk("TextLabel", {
                        Size = UDim2.new(1, -215, 1, 0),
                        Position = UDim2.new(0, 46, 0, 0),
                        BackgroundTransparency = 1,
                        Text = subText,
                        TextColor3 = cval and subColor or P.TEXT_DIM,
                        Font = Enum.Font.Code,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                    }, sub)

                    -- ℹ
                    local si = mk("TextButton", {
                        Size = UDim2.new(0, 42, 0, 42),
                        Position = UDim2.new(1, -140, 0.5, -21),
                        BackgroundColor3 = P.PURPLE,
                        Text = "ℹ",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Font = Enum.Font.GothamBlack,
                        TextSize = 18,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                    }, sub)
                    if si then
                        corner(si, 10)
                        si.MouseButton1Click:Connect(function() show_egg_info(egg) end)
                    end

                    -- ➡
                    local sg = mk("TextButton", {
                        Size = UDim2.new(0, 42, 0, 42),
                        Position = UDim2.new(1, -92, 0.5, -21),
                        BackgroundColor3 = P.GREEN,
                        Text = "➡",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        Font = Enum.Font.GothamBlack,
                        TextSize = 18,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                    }, sub)
                    if sg then
                        corner(sg, 10)
                        gradient(sg, P.CYAN, P.GREEN, 45)
                        sg.MouseButton1Click:Connect(function()
                            if fly_to(egg) then
                                sg.Text = "✓"
                                task.wait(0.5)
                                sg.Text = "➡"
                            end
                        end)
                    end

                    -- 🚀
                    local sa = mk("TextButton", {
                        Size = UDim2.new(0, 42, 0, 42),
                        Position = UDim2.new(1, -42, 0.5, -21),
                        BackgroundColor3 = P.CYAN,
                        Text = "🚀",
                        TextColor3 = Color3.fromRGB(0, 0, 0),
                        Font = Enum.Font.GothamBlack,
                        TextSize = 18,
                        BorderSizePixel = 0,
                        AutoButtonColor = false,
                    }, sub)
                    if sa then
                        corner(sa, 10)
                        gradient(sa, P.CYAN, P.BLUE, 45)
                        sa.MouseButton1Click:Connect(function()
                            if not STATE.auto_collect_running then
                                sa.Text = "⏳"
                                auto_collect(egg, function(ok)
                                    sa.Text = ok and "✓" or "✗"
                                    task.wait(0.8)
                                    sa.Text = "🚀"
                                end)
                            end
                        end)
                    end
                end
            end
        end
    end
end

-- ═════════════════════════════════════════════════════════════════════════════
--   UPDATE
-- ═════════════════════════════════════════════════════════════════════════════

local function update_stats()
    if not STATE.ui then return end
    local names = 0
    for _ in pairs(STATE.eggs) do names = names + 1 end

    local topValue = nil
    local valueCount = 0
    for _, v in pairs(STATE.egg_values) do
        if v then
            valueCount = valueCount + 1
            if not topValue or v > topValue then topValue = v end
        end
    end

    if STATE.ui.eggCount then
        STATE.ui.eggCount.Text = "🥚 " .. STATE.total .. " EGGS"
    end
    if STATE.ui.groupCount then
        STATE.ui.groupCount.Text = "📊 " .. names .. " GROUPS"
    end
    if STATE.ui.topValue then
        STATE.ui.topValue.Text = topValue and ("🏆 TOP: " .. fmt_value(topValue)) or "🏆 TOP: —"
    end
    if STATE.ui.valueCount then
        STATE.ui.valueCount.Text = "💰 " .. valueCount .. " RANKED"
    end
    if STATE.ui.debugLabel then
        STATE.ui.debugLabel.Text = STATE.total > 0
            and ("✅ " .. STATE.total .. " · GO+VALUE v10.3")
            or ("⚠ " .. STATE.last_error)
    end
end

local function refresh_all()
    print("[refresh] scan start")
    local groups, total = scan()
    STATE.eggs = groups
    STATE.total = total
    for n, _ in pairs(groups) do
        if STATE.expanded[n] == nil then STATE.expanded[n] = false end
    end
    update_stats()
    if STATE.ui and STATE.ui.search then
        render(STATE.ui.search.Text)
    end
    print("[refresh] done", total)
end

-- ═════════════════════════════════════════════════════════════════════════════
--   MAIN
-- ═════════════════════════════════════════════════════════════════════════════

local function main()
    print("[main] start")
    STATE.ui = UI.build()
    if not STATE.ui then warn("[MAIN] ❌ UI failed"); return end
    print("[main] UI ready")

    if STATE.ui.refreshBtn then
        STATE.ui.refreshBtn.MouseButton1Click:Connect(function()
            pcall(refresh_all)
        end)
    end

    if STATE.ui.search then
        STATE.ui.search:GetPropertyChangedSignal("Text"):Connect(function()
            if STATE.ui and STATE.ui.search then
                pcall(render, STATE.ui.search.Text)
            end
        end)
    end

    if UIS then
        UIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.KeyCode == Enum.KeyCode.F1 then
                if STATE.ui.main then
                    STATE.ui.main.Visible = not STATE.ui.main.Visible
                    if STATE.ui.floating then
                        STATE.ui.floating.Text = STATE.ui.main.Visible and "✕" or "🥚"
                    end
                end
            elseif input.KeyCode == Enum.KeyCode.F2 then
                if STATE.ui.closeInfo then STATE.ui.closeInfo() end
            elseif input.KeyCode == Enum.KeyCode.F3 then
                if STATE.saved_position then
                    go_to_saved()
                end
            end
        end)
    end

    task.spawn(function()
        while STATE.running do
            task.wait(CFG.AUTO_REFRESH)
            pcall(refresh_all)
        end
    end)

    -- initial refresh (safe)
    local ok, err = pcall(refresh_all)
    if not ok then warn("[main] refresh error:", err) end

    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("👑 EGG FINDER v10.3 — GO + VALUE RANK READY")
    print("   🥚 = فتح/إغلاق الواجهة")
    print("   🎯 = الانتقال للمكان المحفوظ")
    print("   ℹ  = معلومات تفصيلية (+ القيمة)")
    print("   ➡  = الانتقال إلى البيضة")
    print("   🚀 = طيران + ضغط + عودة تلقائية")
    print("   F1 = إخفاء · F2 = إغلاق المعلومات · F3 = العودة السريعة")
    print("   💰 الترتيب حسب القيمة تلقائياً")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
end

task.spawn(function()
    local ok, err = pcall(main)
    if not ok then warn("[MAIN] ❌ FATAL:", err) end
end)

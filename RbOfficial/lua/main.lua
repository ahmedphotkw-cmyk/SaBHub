-- EGG FINDER v10.2+VALUE (compact · fixed)
print("🥚 EGG FINDER — GO + VALUE")

local Players=game:GetService("Players")
local TweenService=game:GetService("TweenService")
local UIS=game:GetService("UserInputService")
local CS=game:GetService("CollectionService")
local LP=Players.LocalPlayer
for i=1,30 do if LP then break end; task.wait(0.1); LP=Players.LocalPlayer end
print("[BOOT]", LP and LP.Name or "?")

local P={
 GOLD=Color3.fromRGB(255,215,0),GOLD_DARK=Color3.fromRGB(180,140,0),GOLD_LIGHT=Color3.fromRGB(255,235,120),
 BG_DARK=Color3.fromRGB(8,8,14),BG_MAIN=Color3.fromRGB(18,18,28),BG_PANEL=Color3.fromRGB(26,26,40),
 BG_ROW=Color3.fromRGB(34,34,50),BG_SUB=Color3.fromRGB(22,22,34),
 TEXT=Color3.fromRGB(245,245,250),TEXT_DIM=Color3.fromRGB(150,150,175),TEXT_MUTED=Color3.fromRGB(100,100,125),
 GREEN=Color3.fromRGB(80,220,120),GREEN_DARK=Color3.fromRGB(40,140,80),RED=Color3.fromRGB(230,70,90),
 RED_DARK=Color3.fromRGB(150,40,55),BLUE=Color3.fromRGB(80,140,230),PURPLE=Color3.fromRGB(150,90,220),
 PINK=Color3.fromRGB(230,100,180),CYAN=Color3.fromRGB(80,220,220),
 COMMON=Color3.fromRGB(180,180,180),UNCOMMON=Color3.fromRGB(100,220,100),RARE=Color3.fromRGB(80,140,230),
 EPIC=Color3.fromRGB(180,100,220),LEGENDARY=Color3.fromRGB(255,180,50),MYTHICAL=Color3.fromRGB(255,80,120),
}

local CFG={FLY_HEIGHT=4,TARGET_FOLDER="RenderedEggs",AUTO_REFRESH=8,FLY_TIME=0.18,RETURN_TIME=0.15,COLLECT_DELAY=0.25,AUTO_COLLECT_WAIT=0.35}
local STATE={eggs={},total=0,expanded={},saved_position=nil,auto_collect_running=false,ui=nil,running=true,last_error="لا يوجد",egg_values={}}

local RLIST={
 {r="MYTHICAL",c=P.MYTHICAL,kw={"mythical","myth","eternal","divine","god","supreme"}},
 {r="LEGENDARY",c=P.LEGENDARY,kw={"legendary","galaxy","blackhole","black hole","dragon","cosmic","superstar","rainbow"}},
 {r="EPIC",c=P.EPIC,kw={"epic","golden","galactic","phantom","shadow"}},
 {r="RARE",c=P.RARE,kw={"rare","crystal","diamond","frozen","ice","sapphire","emerald"}},
 {r="UNCOMMON",c=P.UNCOMMON,kw={"uncommon","silver","jade","ruby"}},
 {r="COMMON",c=P.COMMON,kw={"common","white","brown","blue","red","pink","yellow","black","grey","gray","green"}},
}
local function get_rarity(n)
 if type(n)~="string" then return "COMMON",P.COMMON end
 local ln=n:lower()
 for _,r in ipairs(RLIST) do for _,kw in ipairs(r.kw) do if ln:find(kw,1,true) then return r.r,r.c end end end
 return "COMMON",P.COMMON
end

-- ═ VALUE — FIXED ═
local function parse_v(s)
 if type(s)~="string" then return nil end
 local c=s:gsub("[%$,%s%+%%]","")
 if c=="" then return nil end
 local ns,suf=c:match("^(%d+%.?%d*)([KkMmBbTtGg]?)")
 if not ns then return nil end
 local n=tonumber(ns); if not n or n<=0 then return nil end
 suf=(suf or ""):upper()
 if suf=="K" then n=n*1e3 elseif suf=="M" then n=n*1e6 elseif suf=="B" then n=n*1e9 elseif suf=="T" then n=n*1e12 end
 return n
end

local function extract_v(egg)
 if not egg then return nil end
 -- 1) Attributes
 local ok,attrs=pcall(function() return egg:GetAttributes() end)
 if ok and attrs then
  for k,v in pairs(attrs) do
   local kl=k:lower()
   if kl:find("value") or kl:find("worth") or kl:find("price") or kl:find("luck") or kl:find("قيمة") then
    if type(v)=="number" and v>0 then return v end
    if type(v)=="string" then local p=parse_v(v); if p then return p end end
   end
  end
 end
 -- 2) TextLabel descendants — الاسم فيه luck/value/worth/price، أو أي نص رقمي
 local ok2,desc=pcall(function() return egg:GetDescendants() end)
 if ok2 and desc then
  for _,d in ipairs(desc) do
   if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
    local nl=d.Name:lower()
    if nl:find("luck") or nl:find("value") or nl:find("worth") or nl:find("price") or nl:find("score") or nl:find("قيمة") then
     local p=parse_v(d.Text); if p then return p end
    end
   end
  end
  -- 2b) fallback: أي TextLabel فيه رقم
  for _,d in ipairs(desc) do
   if d:IsA("TextLabel") or d:IsA("TextButton") then
    local p=parse_v(d.Text); if p then return p end
   end
  end
  -- 3) ValueObjects
  for _,d in ipairs(desc) do
   if d:IsA("NumberValue") or d:IsA("IntValue") then
    local nl=d.Name:lower()
    if nl:find("luck") or nl:find("value") or nl:find("worth") or nl:find("price") then
     if d.Value>0 then return d.Value end
    end
   end
  end
 end
 return nil
end

local function tier_v(v)
 if not v then return "UNKNOWN",P.COMMON end
 if v>=1e9 then return "MYTHICAL",P.MYTHICAL end
 if v>=1e8 then return "LEGENDARY",P.LEGENDARY end
 if v>=1e7 then return "EPIC",P.EPIC end
 if v>=1e6 then return "RARE",P.RARE end
 if v>=1e5 then return "UNCOMMON",P.UNCOMMON end
 return "COMMON",P.COMMON
end
local function fmt_v(v)
 if not v then return "—" end
 if v>=1e12 then return string.format("%.2fT",v/1e12) end
 if v>=1e9 then return string.format("%.2fB",v/1e9) end
 if v>=1e6 then return string.format("%.2fM",v/1e6) end
 if v>=1e3 then return string.format("%.1fK",v/1e3) end
 return tostring(math.floor(v))
end
local function group_val(insts)
 if not insts then return nil end
 local best=nil
 for _,i in ipairs(insts) do
  local v=STATE.egg_values[i]
  if v and (not best or v>best) then best=v end
 end
 return best
end

local function get_pos(inst)
 if not inst then return nil end
 if inst:IsA("Model") then
  if inst.PrimaryPart then return inst.PrimaryPart.Position end
  for _,d in ipairs(inst:GetDescendants()) do if d:IsA("BasePart") then return d.Position end end
 end
 if inst:IsA("BasePart") then return inst.Position end
 for _,c in ipairs(inst:GetChildren()) do
  if c:IsA("BasePart") then return c.Position end
  if c:IsA("Model") and c.PrimaryPart then return c.PrimaryPart.Position end
 end
 return nil
end
local function get_mp(inst)
 if not inst then return nil end
 if inst:IsA("Model") then
  if inst.PrimaryPart then return inst.PrimaryPart end
  for _,d in ipairs(inst:GetDescendants()) do if d:IsA("BasePart") then return d end end
 end
 if inst:IsA("BasePart") then return inst end
 for _,c in ipairs(inst:GetChildren()) do if c:IsA("BasePart") then return c end end
 return nil
end
local function clean_name(n)
 local c=n:gsub("%s*%(%d+%)%s*$",""):gsub("%s+$","")
 if c=="" then c=n end
 return c
end

local function scan()
 local groups={}; local total=0
 STATE.egg_values={}
 local ws=workspace
 local src={}
 local tgt=ws:FindFirstChild(CFG.TARGET_FOLDER)
 if tgt then for _,c in ipairs(tgt:GetChildren()) do table.insert(src,c) end end
 if #src==0 then
  local ok,all=pcall(function() return ws:GetDescendants() end)
  if ok and all then
   for _,inst in ipairs(all) do
    local ok2,n=pcall(function() return inst.Name end)
    if ok2 and n then
     local ln=n:lower()
     if ln:find("egg",1,true) or ln:find("بيضة",1,true) then
      local isch=false; local p=inst.Parent; local d=0
      while p and d<3 do
       if p~=ws then
        local ok3,pn=pcall(function() return p.Name end)
        if ok3 and pn and pn:lower():find("egg",1,true) and p~=inst then isch=true; break end
       end
       p=p.Parent; d=d+1
      end
      if not isch then table.insert(src,inst) end
     end
    end
   end
  end
 end
 for _,inst in ipairs(src) do
  local ok,n=pcall(function() return inst.Name end)
  if ok and n then
   local b=clean_name(n)
   if not groups[b] then groups[b]={} end
   table.insert(groups[b],inst); total=total+1
   local okv,val=pcall(extract_v,inst)
   if okv and val then STATE.egg_values[inst]=val end
  end
 end
 STATE.last_error=total==0 and "لم يُعثر على بيض" or "OK"
 local vc=0; for _ in pairs(STATE.egg_values) do vc=vc+1 end
 print("[SCAN]", total, "eggs,", vc, "valued")
 return groups,total
end

local function fly_to(egg)
 local ch=LP and LP.Character; if not ch then return false end
 local hrp=ch:FindFirstChild("HumanoidRootPart"); if not hrp then return false end
 local p=get_pos(egg); if not p then return false end
 TweenService:Create(hrp,TweenInfo.new(0.4,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{CFrame=CFrame.new(p+Vector3.new(0,CFG.FLY_HEIGHT,0))}):Play()
 return true
end
local function find_prompts(egg)
 local pr={}
 pcall(function()
  for _,d in ipairs(egg:GetDescendants()) do
   if d:IsA("ProximityPrompt") or d:IsA("ClickDetector") then table.insert(pr,d) end
  end
 end)
 if #pr==0 then
  local p=get_pos(egg)
  if p then
   pcall(function()
    for _,d in ipairs(workspace:GetDescendants()) do
     if d:IsA("ProximityPrompt") then
      local par=d.Parent
      if par and par:IsA("BasePart") and (par.Position-p).Magnitude<20 then table.insert(pr,d) end
     end
    end
   end)
  end
 end
 return pr
end
local function fire_prompts(egg)
 local pr=find_prompts(egg); if #pr==0 then return false end
 for _,p in ipairs(pr) do
  pcall(function()
   if p:IsA("ProximityPrompt") and fireproximityprompt then fireproximityprompt(p)
   elseif p:IsA("ClickDetector") and fireclickdetector then fireclickdetector(p) end
  end)
  task.wait(0.05)
 end
 return true
end
local function auto_collect(egg,cb)
 if STATE.auto_collect_running or not STATE.saved_position then if cb then cb(false) end; return end
 local ch=LP and LP.Character; if not ch then if cb then cb(false) end; return end
 local hrp=ch:FindFirstChild("HumanoidRootPart"); if not hrp then if cb then cb(false) end; return end
 local ep=get_pos(egg); if not ep then if cb then cb(false) end; return end
 STATE.auto_collect_running=true
 task.spawn(function()
  local sv=STATE.saved_position
  local t1=TweenService:Create(hrp,TweenInfo.new(CFG.FLY_TIME,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{CFrame=CFrame.new(ep+Vector3.new(0,CFG.FLY_HEIGHT,0))})
  t1:Play(); t1.Completed:Wait()
  task.wait(CFG.COLLECT_DELAY); fire_prompts(egg)
  task.wait(CFG.AUTO_COLLECT_WAIT); fire_prompts(egg)
  local t2=TweenService:Create(hrp,TweenInfo.new(CFG.RETURN_TIME,Enum.EasingStyle.Quint,Enum.EasingDirection.In),{CFrame=CFrame.new(sv)})
  t2:Play(); t2.Completed:Wait()
  STATE.auto_collect_running=false
  if cb then cb(true) end
 end)
end
local function save_pos()
 local ch=LP and LP.Character; if not ch then return false end
 local hrp=ch:FindFirstChild("HumanoidRootPart"); if not hrp then return false end
 STATE.saved_position=hrp.Position; return true
end
local function go_saved(cb)
 if not STATE.saved_position then if cb then cb(false) end; return false end
 local ch=LP and LP.Character; if not ch then if cb then cb(false) end; return false end
 local hrp=ch:FindFirstChild("HumanoidRootPart"); if not hrp then if cb then cb(false) end; return false end
 TweenService:Create(hrp,TweenInfo.new(0.35,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),{CFrame=CFrame.new(STATE.saved_position)}):Play()
 if cb then cb(true) end
 return true
end

local function cnt_class(inst,cls)
 local c=0
 for _,d in ipairs(inst:GetDescendants()) do if d:IsA(cls) then c=c+1 end end
 return c
end
local function tr(o,p) local ok,v=pcall(function() return o[p] end); if ok then return v end; return nil end
local function fn(n,d) if type(n)~="number" then return tostring(n) end; return string.format("%."..(d or 2).."f",n) end
local function net_owner(part)
 if not part then return "—" end
 local ok,o=pcall(function() return part:GetNetworkOwner() end)
 if ok and o then return o.Name end
 if ok then return "Server" end
 return "—"
end
local function intel(egg)
 local d={identity={},position={},physics={},appearance={},structure={},attributes={},interactions={},effects={},network={},tags={},value_info={}}
 d.identity["Name"]=egg.Name; d.identity["ClassName"]=egg.ClassName; d.identity["FullName"]=egg:GetFullName()
 d.identity["Archivable"]=tostring(tr(egg,"Archivable") or "—")
 local v=STATE.egg_values[egg]
 if not v then local okv,val=pcall(extract_v,egg); if okv then v=val end end
 if v then d.value_info["Raw"]=fn(v,0); d.value_info["Display"]=fmt_v(v); d.value_info["Tier"]=select(1,tier_v(v))
 else d.value_info["Raw"]="—"; d.value_info["Display"]="—"; d.value_info["Tier"]="UNKNOWN" end
 local mp=get_mp(egg)
 if mp then
  local p=mp.Position
  d.position["X"]=fn(p.X); d.position["Y"]=fn(p.Y); d.position["Z"]=fn(p.Z)
  local s=mp.Size
  d.position["Size X"]=fn(s.X); d.position["Size Y"]=fn(s.Y); d.position["Size Z"]=fn(s.Z)
  d.position["Volume"]=fn(s.X*s.Y*s.Z,3)
  local o1,o2,o3=mp.CFrame:ToOrientation()
  d.position["Rot X"]=fn(math.deg(o1)); d.position["Rot Y"]=fn(math.deg(o2)); d.position["Rot Z"]=fn(math.deg(o3))
  d.physics["Anchored"]=tostring(tr(mp,"Anchored")); d.physics["Massless"]=tostring(tr(mp,"Massless"))
  d.physics["CanCollide"]=tostring(tr(mp,"CanCollide")); d.physics["CanTouch"]=tostring(tr(mp,"CanTouch"))
  d.physics["CanQuery"]=tostring(tr(mp,"CanQuery")); d.physics["Locked"]=tostring(tr(mp,"Locked"))
  d.physics["RootPriority"]=tostring(tr(mp,"RootPriority"))
  d.appearance["Transparency"]=fn(tr(mp,"Transparency")); d.appearance["Reflectance"]=fn(tr(mp,"Reflectance"))
  d.appearance["Material"]=tostring(tr(mp,"Material"))
  local col=tr(mp,"Color")
  if typeof(col)=="Color3" then d.appearance["Color"]=string.format("(%d,%d,%d)",col.R*255,col.G*255,col.B*255) end
  d.appearance["CastShadow"]=tostring(tr(mp,"CastShadow")); d.appearance["Shape"]=tostring(tr(mp,"Shape"))
 end
 d.structure["Children"]=tostring(#egg:GetChildren()); d.structure["Descendants"]=tostring(#egg:GetDescendants())
 d.structure["Parent"]=egg.Parent and egg.Parent.Name or "—"
 if egg:IsA("Model") then d.structure["PrimaryPart"]=egg.PrimaryPart and egg.PrimaryPart.Name or "لا يوجد" end
 local attrs=egg:GetAttributes()
 for k,v2 in pairs(attrs) do d.attributes[k]=tostring(v2) end
 local pr=find_prompts(egg)
 d.interactions["Total Prompts"]=tostring(#pr)
 d.interactions["ProximityPrompt"]=tostring(cnt_class(egg,"ProximityPrompt"))
 d.interactions["ClickDetector"]=tostring(cnt_class(egg,"ClickDetector"))
 if #pr>0 and pr[1]:IsA("ProximityPrompt") then
  local f=pr[1]
  d.interactions["ActionText"]=tostring(tr(f,"ActionText") or "—")
  d.interactions["ObjectText"]=tostring(tr(f,"ObjectText") or "—")
  d.interactions["HoldDuration"]=fn(tr(f,"HoldDuration"))
  d.interactions["MaxDistance"]=fn(tr(f,"MaxActivationDistance"))
  d.interactions["Enabled"]=tostring(tr(f,"Enabled"))
 end
 d.effects["ParticleEmitters"]=tostring(cnt_class(egg,"ParticleEmitter"))
 d.effects["Sounds"]=tostring(cnt_class(egg,"Sound"))
 d.effects["Attachments"]=tostring(cnt_class(egg,"Attachment"))
 d.effects["PointLights"]=tostring(cnt_class(egg,"PointLight"))
 d.effects["SpotLights"]=tostring(cnt_class(egg,"SpotLight"))
 d.effects["SurfaceLights"]=tostring(cnt_class(egg,"SurfaceLight"))
 d.effects["Trails"]=tostring(cnt_class(egg,"Trail"))
 d.effects["Beams"]=tostring(cnt_class(egg,"Beam"))
 d.effects["BillboardGuis"]=tostring(cnt_class(egg,"BillboardGui"))
 if mp then
  d.network["Network Owner"]=net_owner(mp)
  local okrp,rp=pcall(function() return mp:GetRootPart() end)
  d.network["Root Part"]=okrp and rp and rp.Name or "—"
 end
 if CS then
  local tags=CS:GetTags(egg)
  for i,t in ipairs(tags) do d.tags["Tag "..i]=t end
 end
 return d
end

local function mk(cls,props,par)
 local ok,o=pcall(Instance.new,cls)
 if not ok or not o then return nil end
 for k,v in pairs(props or {}) do pcall(function() o[k]=v end) end
 if par then pcall(function() o.Parent=par end) end
 return o
end
local function corner(p,r) return mk("UICorner",{CornerRadius=UDim.new(0,r)},p) end
local function grad(p,c1,c2,rot) return mk("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,c1),ColorSequenceKeypoint.new(1,c2)}),Rotation=rot or 45},p) end
local function stk(p,c,t,tr_) return mk("UIStroke",{Color=c or Color3.fromRGB(0,0,0),Thickness=t or 1,Transparency=tr_ or 0},p) end
local function mk_drag(f)
 local dr,ds,sp
 f.InputBegan:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
   dr=true; ds=i.Position; sp=f.Position
  end
 end)
 f.InputChanged:Connect(function(i)
  if dr and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
   local d=i.Position-ds
   f.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
  end
 end)
 f.InputEnded:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then dr=false end
 end)
end
local function find_par()
 if LP then
  local ok,pg=pcall(function() return LP:FindFirstChildOfClass("PlayerGui") end)
  if ok and pg then return pg end
 end
 if type(gethui)=="function" then local ok,h=pcall(gethui); if ok and h then return h end end
 local ok3,cg=pcall(function() return game:GetService("CoreGui") end)
 if ok3 and cg then return cg end
 return nil
end

local UI={}
function UI.build()
 local par=find_par(); if not par then return nil end
 pcall(function() for _,c in ipairs(par:GetChildren()) do if c.Name=="EggFinderV10" then c:Destroy() end end end)
 local sc=mk("ScreenGui",{Name="EggFinderV10",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=999},par)
 if not sc then return nil end
 if type(syn)=="table" and syn.protect_gui then pcall(function() syn.protect_gui(sc) end) end

 local fl=mk("TextButton",{Name="FloatEgg",Size=UDim2.new(0,75,0,75),Position=UDim2.new(0,15,0.35,0),BackgroundColor3=P.GOLD,Text="🥚",TextColor3=Color3.fromRGB(0,0,0),Font=Enum.Font.GothamBlack,TextSize=34,BorderSizePixel=0,AutoButtonColor=false},sc)
 if fl then corner(fl,40); grad(fl,P.GOLD_LIGHT,P.GOLD_DARK,45); stk(fl,P.GOLD_LIGHT,3,0.2); mk_drag(fl) end

 local fg=mk("TextButton",{Name="FloatGo",Size=UDim2.new(0,75,0,75),Position=UDim2.new(0,15,0.35,90),BackgroundColor3=P.GREEN,Text="🎯",TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBlack,TextSize=32,BorderSizePixel=0,AutoButtonColor=false},sc)
 if fg then
  corner(fg,40); grad(fg,P.CYAN,P.GREEN,45); stk(fg,P.GREEN,3,0.2); mk_drag(fg)
  fg.MouseButton1Click:Connect(function()
   if STATE.saved_position then
    go_saved(function(ok)
     if ok then fg.Text="✓"; task.wait(0.5); fg.Text="🎯"
     else fg.Text="✗"; task.wait(0.5); fg.Text="🎯" end
    end)
   else fg.Text="✗"; task.wait(0.5); fg.Text="🎯" end
  end)
 end

 local mn=mk("Frame",{Name="Main",Size=UDim2.new(0,540,0,640),Position=UDim2.new(0,100,0.5,-320),BackgroundColor3=P.BG_MAIN,BorderSizePixel=0,Active=true,Visible=false,ClipsDescendants=true},sc)
 if not mn then return nil end
 corner(mn,16); grad(mn,P.BG_MAIN,P.BG_DARK,90); stk(mn,P.GOLD,2,0.1); mk_drag(mn)
 if fl then
  fl.MouseButton1Click:Connect(function()
   mn.Visible=not mn.Visible
   fl.Text=mn.Visible and "✕" or "🥚"
   grad(fl,mn.Visible and P.RED or P.GOLD_LIGHT,mn.Visible and P.RED_DARK or P.GOLD_DARK,45)
  end)
 end

 local hd=mk("Frame",{Name="Header",Size=UDim2.new(1,0,0,68),BackgroundColor3=P.BG_PANEL,BorderSizePixel=0},mn)
 if hd then
  corner(hd,16); grad(hd,P.BG_PANEL,P.BG_DARK,90)
  mk("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=P.GOLD,BorderSizePixel=0},hd)
  mk("TextLabel",{Size=UDim2.new(0,50,1,0),Position=UDim2.new(0,12,0,0),BackgroundTransparency=1,Text="🥚",TextColor3=P.GOLD,Font=Enum.Font.GothamBlack,TextSize=32},hd)
  mk("TextLabel",{Size=UDim2.new(1,-170,0,30),Position=UDim2.new(0,68,0,12),BackgroundTransparency=1,Text="EGG FINDER",TextColor3=P.GOLD,Font=Enum.Font.GothamBlack,TextSize=20,TextXAlignment=Enum.TextXAlignment.Left},hd)
  mk("TextLabel",{Name="DebugLabel",Size=UDim2.new(1,-170,0,20),Position=UDim2.new(0,68,0,38),BackgroundTransparency=1,Text="GO·v10.2+VAL",TextColor3=P.TEXT_DIM,Font=Enum.Font.GothamBold,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left},hd)
  local rB=mk("TextButton",{Name="RefreshBtn",Size=UDim2.new(0,44,0,44),Position=UDim2.new(1,-106,0,12),BackgroundColor3=P.BLUE,Text="🔄",TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBold,TextSize=20,BorderSizePixel=0,AutoButtonColor=false},hd)
  if rB then corner(rB,10); grad(rB,P.CYAN,P.BLUE,45) end
  local cB=mk("TextButton",{Name="CloseBtn",Size=UDim2.new(0,44,0,44),Position=UDim2.new(1,-56,0,12),BackgroundColor3=P.RED,Text="✕",TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBold,TextSize=20,BorderSizePixel=0,AutoButtonColor=false},hd)
  if cB then
   corner(cB,10); grad(cB,P.RED,P.RED_DARK,45)
   cB.MouseButton1Click:Connect(function()
    mn.Visible=false
    if fl then fl.Text="🥚"; grad(fl,P.GOLD_LIGHT,P.GOLD_DARK,45) end
   end)
  end
 end

 local st=mk("Frame",{Name="Stats",Size=UDim2.new(1,-20,0,50),Position=UDim2.new(0,10,0,78),BackgroundColor3=P.BG_PANEL,BorderSizePixel=0},mn)
 if st then
  corner(st,12); grad(st,P.BG_PANEL,P.BG_DARK,90); stk(st,P.GOLD_DARK,1,0.5)
  mk("TextLabel",{Name="EggCount",Size=UDim2.new(0.5,-20,0,25),Position=UDim2.new(0,15,0,5),BackgroundTransparency=1,Text="🥚 0 EGGS",TextColor3=P.TEXT,Font=Enum.Font.GothamBold,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left},st)
  mk("TextLabel",{Name="GroupCount",Size=UDim2.new(0.5,-20,0,25),Position=UDim2.new(0,15,0,24),BackgroundTransparency=1,Text="📊 0 GROUPS",TextColor3=P.TEXT_DIM,Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},st)
  mk("TextLabel",{Name="TopValue",Size=UDim2.new(0.5,-50,0,25),Position=UDim2.new(0.5,0,0,5),BackgroundTransparency=1,Text="🏆 TOP: —",TextColor3=P.GOLD,Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Right},st)
  mk("TextLabel",{Name="ValueCount",Size=UDim2.new(0.5,-50,0,25),Position=UDim2.new(0.5,0,0,24),BackgroundTransparency=1,Text="💰 0 RANKED",TextColor3=P.GREEN,Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right},st)
  local dot=mk("Frame",{Size=UDim2.new(0,12,0,12),Position=UDim2.new(1,-30,0,19),BackgroundColor3=P.GREEN,BorderSizePixel=0},st)
  if dot then corner(dot,6) end
 end

 local lp=mk("Frame",{Name="LocationPanel",Size=UDim2.new(1,-20,0,90),Position=UDim2.new(0,10,0,138),BackgroundColor3=P.BG_PANEL,BorderSizePixel=0},mn)
 if lp then
  corner(lp,12); grad(lp,P.BG_PANEL,P.BG_DARK,90); stk(lp,P.GOLD,1.5,0.3)
  mk("TextLabel",{Size=UDim2.new(1,-20,0,22),Position=UDim2.new(0,12,0,6),BackgroundTransparency=1,Text="📍  تحديد المكان (نقطة العودة)",TextColor3=P.GOLD,Font=Enum.Font.GothamBlack,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left},lp)
  local cl=mk("TextLabel",{Name="Coords",Size=UDim2.new(1,-20,0,18),Position=UDim2.new(0,12,0,28),BackgroundTransparency=1,Text="لم يتم حفظ مكان بعد",TextColor3=P.TEXT_MUTED,Font=Enum.Font.Code,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},lp)
  local sB=mk("TextButton",{Name="SaveBtn",Size=UDim2.new(0,240,0,34),Position=UDim2.new(0,12,1,-42),BackgroundColor3=P.GREEN,Text="💾 حفظ المكان الحالي",TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0,AutoButtonColor=false},lp)
  if sB then corner(sB,8); grad(sB,P.GREEN,P.GREEN_DARK,45) end
  local clB=mk("TextButton",{Name="ClearBtn",Size=UDim2.new(0,240,0,34),Position=UDim2.new(0,260,1,-42),BackgroundColor3=P.RED,Text="🗑 مسح المكان",TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBold,TextSize=12,BorderSizePixel=0,AutoButtonColor=false},lp)
  if clB then corner(clB,8); grad(clB,P.RED,P.RED_DARK,45) end
  if sB then sB.MouseButton1Click:Connect(function()
   if save_pos() then
    local p=STATE.saved_position
    cl.Text=string.format("✅ X: %.1f  Y: %.1f  Z: %.1f",p.X,p.Y,p.Z)
    cl.TextColor3=P.GREEN
   end
  end) end
  if clB then clB.MouseButton1Click:Connect(function()
   STATE.saved_position=nil
   cl.Text="لم يتم حفظ مكان بعد"; cl.TextColor3=P.TEXT_MUTED
  end) end
 end

 local sf=mk("Frame",{Size=UDim2.new(1,-20,0,42),Position=UDim2.new(0,10,0,238),BackgroundColor3=P.BG_PANEL,BorderSizePixel=0},mn)
 if sf then
  corner(sf,10); stk(sf,P.GOLD,1,0.6)
  mk("TextLabel",{Size=UDim2.new(0,40,1,0),BackgroundTransparency=1,Text="🔍",Font=Enum.Font.GothamBold,TextSize=18,TextColor3=P.GOLD},sf)
  mk("TextBox",{Name="Search",Size=UDim2.new(1,-50,1,0),Position=UDim2.new(0,45,0,0),BackgroundTransparency=1,Text="",PlaceholderText="Search eggs...",TextColor3=P.TEXT,PlaceholderColor3=P.TEXT_MUTED,Font=Enum.Font.Gotham,TextSize=14,ClearTextOnFocus=false},sf)
 end

 local ls=mk("ScrollingFrame",{Name="List",Size=UDim2.new(1,-20,1,-330),Position=UDim2.new(0,10,0,288),BackgroundColor3=P.BG_DARK,BorderSizePixel=0,ScrollBarThickness=6,ScrollBarImageColor3=P.GOLD,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y},mn)
 if ls then
  corner(ls,12); stk(ls,P.GOLD_DARK,1,0.7)
  mk("UIPadding",{PaddingTop=UDim.new(0,8),PaddingBottom=UDim.new(0,8),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)},ls)
  mk("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder},ls)
 end

 local ov=mk("TextButton",{Name="InfoOverlay",Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=0.5,Text="",AutoButtonColor=false,BorderSizePixel=0,Visible=false,ZIndex=18},sc)
 local ip=mk("Frame",{Name="InfoPanel",Size=UDim2.new(0.92,0,0.88,0),Position=UDim2.new(0.04,0,0.06,0),BackgroundColor3=P.BG_MAIN,BorderSizePixel=0,Visible=false,ZIndex=20},sc)
 local function closeInfo() if ip then ip.Visible=false end; if ov then ov.Visible=false end end
 if ip then
  corner(ip,16); grad(ip,P.BG_MAIN,P.BG_DARK,90); stk(ip,P.GOLD,2,0.1)
  local ih=mk("Frame",{Name="InfoHeader",Size=UDim2.new(1,0,0,60),BackgroundColor3=P.BG_PANEL,BorderSizePixel=0},ip)
  if ih then
   corner(ih,16); grad(ih,P.BG_PANEL,P.BG_DARK,90)
   mk("TextLabel",{Name="InfoTitle",Size=UDim2.new(1,-80,1,0),Position=UDim2.new(0,15,0,0),BackgroundTransparency=1,Text="🥚 Egg Intel",TextColor3=P.GOLD,Font=Enum.Font.GothamBlack,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left},ih)
   local icB=mk("TextButton",{Size=UDim2.new(0,50,0,50),Position=UDim2.new(1,-58,0,5),BackgroundColor3=P.RED,Text="✕",TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBlack,TextSize=22,BorderSizePixel=0,AutoButtonColor=false,ZIndex=22},ih)
   if icB then corner(icB,12); grad(icB,P.RED,P.RED_DARK,45); icB.MouseButton1Click:Connect(closeInfo) end
  end
  mk("ScrollingFrame",{Name="Content",Size=UDim2.new(1,-20,1,-130),Position=UDim2.new(0,10,0,70),BackgroundColor3=P.BG_DARK,BorderSizePixel=0,ScrollBarThickness=6,ScrollBarImageColor3=P.GOLD,CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y},ip)
  local bc=mk("TextButton",{Size=UDim2.new(1,-20,0,40),Position=UDim2.new(0,10,1,-50),BackgroundColor3=P.RED,Text="✕  إغلاق",TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBlack,TextSize=15,BorderSizePixel=0,AutoButtonColor=false,ZIndex=22},ip)
  if bc then corner(bc,10); grad(bc,P.RED,P.RED_DARK,45); bc.MouseButton1Click:Connect(closeInfo) end
 end
 if ov then ov.MouseButton1Click:Connect(closeInfo) end
 local ct=ip and ip:FindFirstChild("Content")
 if ct then
  corner(ct,10)
  mk("UIPadding",{PaddingTop=UDim.new(0,10),PaddingBottom=UDim.new(0,10),PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)},ct)
  mk("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},ct)
 end

 return {screen=sc,floating=fl,floatingGo=fg,main=mn,list=ls,stats=st,
  search=sf and sf:FindFirstChild("Search") or nil,
  refreshBtn=hd and hd:FindFirstChild("RefreshBtn") or nil,
  eggCount=st and st:FindFirstChild("EggCount") or nil,
  groupCount=st and st:FindFirstChild("GroupCount") or nil,
  topValue=st and st:FindFirstChild("TopValue") or nil,
  valueCount=st and st:FindFirstChild("ValueCount") or nil,
  debugLabel=hd and hd:FindFirstChild("DebugLabel") or nil,
  infoPanel=ip,infoOverlay=ov,infoContent=ct,
  infoTitle=ip and ip:FindFirstChild("InfoHeader") and ip.InfoHeader:FindFirstChild("InfoTitle") or nil,
  closeInfo=closeInfo}
end

local oc=0
local function no() oc=oc+1; return oc end
local function sec(par,t,em,col)
 local h=mk("Frame",{Size=UDim2.new(1,0,0,30),BackgroundColor3=col,BackgroundTransparency=0.85,BorderSizePixel=0,LayoutOrder=no()},par)
 corner(h,6); stk(h,col,1,0.4)
 mk("TextLabel",{Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=em.."  "..t,TextColor3=col,Font=Enum.Font.GothamBlack,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left},h)
end
local function row(par,lb,val,col)
 local r=mk("Frame",{Size=UDim2.new(1,0,0,28),BackgroundColor3=P.BG_PANEL,BackgroundTransparency=0.4,BorderSizePixel=0,LayoutOrder=no()},par)
 corner(r,5)
 mk("TextLabel",{Size=UDim2.new(0.42,-10,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=lb,TextColor3=P.TEXT_DIM,Font=Enum.Font.Gotham,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},r)
 local vt=tostring(val); if #vt>40 then vt=vt:sub(1,37).."..." end
 mk("TextLabel",{Size=UDim2.new(0.58,-10,1,0),Position=UDim2.new(0.42,0,0,0),BackgroundTransparency=1,Text=vt,TextColor3=col or P.TEXT,Font=Enum.Font.Code,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},r)
end
local function show_info(egg)
 local u=STATE.ui; if not u or not u.infoContent or not u.infoPanel then return end
 oc=0
 for _,c in ipairs(u.infoContent:GetChildren()) do
  if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
 end
 if u.infoTitle then u.infoTitle.Text="🥚 "..egg.Name end
 local d=intel(egg)
 sec(u.infoContent,"القيمة والتصنيف","🏆",P.GOLD)
 for k,v in pairs(d.value_info) do row(u.infoContent,k,v,P.GOLD) end
 sec(u.infoContent,"الهوية","🆔",P.GOLD); for k,v in pairs(d.identity) do row(u.infoContent,k,v,P.TEXT) end
 sec(u.infoContent,"الموقع","📍",P.GREEN); for k,v in pairs(d.position) do row(u.infoContent,k,v,P.GREEN) end
 sec(u.infoContent,"الفيزياء","⚙️",P.BLUE); for k,v in pairs(d.physics) do row(u.infoContent,k,v,P.BLUE) end
 sec(u.infoContent,"المظهر","🎨",P.PINK); for k,v in pairs(d.appearance) do row(u.infoContent,k,v,P.PINK) end
 sec(u.infoContent,"البنية","🌳",P.CYAN); for k,v in pairs(d.structure) do row(u.infoContent,k,v,P.CYAN) end
 sec(u.infoContent,"الخصائص","📋",P.GOLD)
 local ha=false
 for k,v in pairs(d.attributes) do row(u.infoContent,k,v,P.GOLD); ha=true end
 if not ha then row(u.infoContent,"—","لا يوجد",P.TEXT_MUTED) end
 sec(u.infoContent,"التفاعلات","🎯",P.PURPLE); for k,v in pairs(d.interactions) do row(u.infoContent,k,v,P.PURPLE) end
 sec(u.infoContent,"المؤثرات","💫",P.GOLD_LIGHT); for k,v in pairs(d.effects) do row(u.infoContent,k,v,P.GOLD_LIGHT) end
 sec(u.infoContent,"الشبكة","🌐",P.RED); for k,v in pairs(d.network) do row(u.infoContent,k,v,P.RED) end
 sec(u.infoContent,"العلامات","🏷️",P.GREEN)
 local ht=false
 for k,v in pairs(d.tags) do row(u.infoContent,k,v,P.GREEN); ht=true end
 if not ht then row(u.infoContent,"—","لا يوجد",P.TEXT_MUTED) end
 if u.infoOverlay then u.infoOverlay.Visible=true end
 u.infoPanel.Visible=true
end

local or_=0
local function nord() or_=or_+1; return or_ end
local function render(filter)
 if not STATE.ui or not STATE.ui.list then return end
 for _,c in ipairs(STATE.ui.list:GetChildren()) do
  if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
 end
 or_=0
 filter=(filter or ""):lower()
 local names={}
 for n,_ in pairs(STATE.eggs) do
  if filter=="" or n:lower():find(filter,1,true) then table.insert(names,n) end
 end
 table.sort(names,function(a,b)
  local va=group_val(STATE.eggs[a])
  local vb=group_val(STATE.eggs[b])
  if va and vb then if va~=vb then return va>vb end
  elseif va and not vb then return true
  elseif vb and not va then return false end
  local ra=get_rarity(a); local rb=get_rarity(b)
  if ra~=rb then
   local o={MYTHICAL=1,LEGENDARY=2,EPIC=3,RARE=4,UNCOMMON=5,COMMON=6}
   return (o[ra] or 99)<(o[rb] or 99)
  end
  return #STATE.eggs[a]>#STATE.eggs[b]
 end)
 if #names==0 then
  mk("TextLabel",{Size=UDim2.new(1,-10,0,80),BackgroundTransparency=1,Text="🥚\nلا يوجد بيض\n\n"..STATE.last_error,TextColor3=P.TEXT_DIM,Font=Enum.Font.Gotham,TextSize=13,TextXAlignment=Enum.TextXAlignment.Center,LayoutOrder=nord()},STATE.ui.list)
  return
 end
 for _,name in ipairs(names) do
  local eggs=STATE.eggs[name]
  local expanded=STATE.expanded[name] or false
  local rar,rarC=get_rarity(name)
  local gv=group_val(eggs)
  local vt,vc=tier_v(gv)
  local dC=gv and vc or rarC
  local dT=gv and vt or rar
  local r=mk("TextButton",{Size=UDim2.new(1,0,0,70),BackgroundColor3=P.BG_ROW,BorderSizePixel=0,Text="",AutoButtonColor=false,LayoutOrder=nord()},STATE.ui.list)
  if r then
   corner(r,12); grad(r,P.BG_ROW,P.BG_SUB,90); stk(r,dC,1.5,0.4)
   local rb=mk("Frame",{Size=UDim2.new(0,4,0.7,0),Position=UDim2.new(0,0,0.15,0),BackgroundColor3=dC,BorderSizePixel=0},r)
   if rb then corner(rb,2) end
   local ar=mk("TextButton",{Size=UDim2.new(0,42,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,Text=expanded and "▼" or "▶",TextColor3=dC,Font=Enum.Font.GothamBlack,TextSize=22,BorderSizePixel=0,AutoButtonColor=false},r)
   mk("TextLabel",{Size=UDim2.new(0.35,0,0,22),Position=UDim2.new(0,55,0,12),BackgroundTransparency=1,Text=name,TextColor3=P.TEXT,Font=Enum.Font.GothamBlack,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left},r)
   local chip="  "..dT
   if gv then chip=chip.."  ·  "..fmt_v(gv) end
   local rt=mk("TextLabel",{Size=UDim2.new(0,140,0,18),Position=UDim2.new(0,55,0,40),BackgroundColor3=dC,BackgroundTransparency=0.85,Text=chip,TextColor3=dC,Font=Enum.Font.GothamBold,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0},r)
   if rt then corner(rt,4) end
   local cf=mk("Frame",{Size=UDim2.new(0,45,0,30),Position=UDim2.new(0.5,0,0,20),BackgroundColor3=dC,BackgroundTransparency=0.75,BorderSizePixel=0},r)
   if cf then corner(cf,15)
    mk("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="× "..#eggs,TextColor3=dC,Font=Enum.Font.GothamBlack,TextSize=13},cf)
   end
   local ib=mk("TextButton",{Size=UDim2.new(0,45,0,45),Position=UDim2.new(1,-153,0,12),BackgroundColor3=P.PURPLE,Text="ℹ",TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBlack,TextSize=20,BorderSizePixel=0,AutoButtonColor=false},r)
   if ib then corner(ib,10); grad(ib,P.PINK,P.PURPLE,45); ib.MouseButton1Click:Connect(function() if #eggs>0 then show_info(eggs[1]) end end) end
   local gb=mk("TextButton",{Size=UDim2.new(0,45,0,45),Position=UDim2.new(1,-103,0,12),BackgroundColor3=P.GREEN,Text="➡",TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBlack,TextSize=20,BorderSizePixel=0,AutoButtonColor=false},r)
   if gb then
    corner(gb,10); grad(gb,P.CYAN,P.GREEN,45); stk(gb,P.GREEN,1.5,0.3)
    gb.MouseButton1Click:Connect(function()
     if #eggs>0 then
      if fly_to(eggs[1]) then gb.Text="✓"; task.wait(0.5); gb.Text="➡"
      else gb.Text="✗"; task.wait(0.5); gb.Text="➡" end
     end
    end)
   end
   local ab=mk("TextButton",{Size=UDim2.new(0,45,0,45),Position=UDim2.new(1,-53,0,12),BackgroundColor3=P.CYAN,Text="🚀",TextColor3=Color3.fromRGB(0,0,0),Font=Enum.Font.GothamBlack,TextSize=20,BorderSizePixel=0,AutoButtonColor=false},r)
   if ab then
    corner(ab,10); grad(ab,P.CYAN,P.BLUE,45)
    ab.MouseButton1Click:Connect(function()
     if #eggs>0 and not STATE.auto_collect_running then
      ab.Text="⏳"
      auto_collect(eggs[1],function(ok) ab.Text=ok and "✓" or "✗"; task.wait(0.8); ab.Text="🚀" end)
     end
    end)
   end
   if ar then ar.MouseButton1Click:Connect(function()
    STATE.expanded[name]=not expanded
    if STATE.ui and STATE.ui.search then render(STATE.ui.search.Text) end
   end) end
  end
  if expanded then
   for i,egg in ipairs(eggs) do
    local cv=STATE.egg_values[egg]
    local cc=select(2,tier_v(cv))
    local sC=cv and cc or rarC
    local sV=cv and fmt_v(cv) or ""
    local sb=mk("Frame",{Size=UDim2.new(1,-30,0,60),Position=UDim2.new(0,25,0,0),BackgroundColor3=P.BG_SUB,BorderSizePixel=0,LayoutOrder=nord()},STATE.ui.list)
    if sb then
     corner(sb,10); stk(sb,sC,1,0.7)
     local txt="# "..i.."  "..(egg.Parent and egg.Parent.Name or "?")
     if sV~="" then txt=txt.."  ·  "..sV end
     mk("TextLabel",{Size=UDim2.new(1,-180,1,0),Position=UDim2.new(0,46,0,0),BackgroundTransparency=1,Text=txt,TextColor3=cv and sC or P.TEXT_DIM,Font=Enum.Font.Code,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},sb)
     local si=mk("TextButton",{Size=UDim2.new(0,42,0,42),Position=UDim2.new(1,-140,0.5,-21),BackgroundColor3=P.PURPLE,Text="ℹ",TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBlack,TextSize=18,BorderSizePixel=0,AutoButtonColor=false},sb)
     if si then corner(si,10); si.MouseButton1Click:Connect(function() show_info(egg) end) end
     local sg=mk("TextButton",{Size=UDim2.new(0,42,0,42),Position=UDim2.new(1,-92,0.5,-21),BackgroundColor3=P.GREEN,Text="➡",TextColor3=Color3.fromRGB(255,255,255),Font=Enum.Font.GothamBlack,TextSize=18,BorderSizePixel=0,AutoButtonColor=false},sb)
     if sg then corner(sg,10); grad(sg,P.CYAN,P.GREEN,45); sg.MouseButton1Click:Connect(function() if fly_to(egg) then sg.Text="✓"; task.wait(0.5); sg.Text="➡" end end) end
     local sa=mk("TextButton",{Size=UDim2.new(0,42,0,42),Position=UDim2.new(1,-42,0.5,-21),BackgroundColor3=P.CYAN,Text="🚀",TextColor3=Color3.fromRGB(0,0,0),Font=Enum.Font.GothamBlack,TextSize=18,BorderSizePixel=0,AutoButtonColor=false},sb)
     if sa then corner(sa,10); grad(sa,P.CYAN,P.BLUE,45); sa.MouseButton1Click:Connect(function() if not STATE.auto_collect_running then sa.Text="⏳"; auto_collect(egg,function(ok) sa.Text=ok and "✓" or "✗"; task.wait(0.8); sa.Text="🚀" end) end end) end
    end
   end
  end
 end
end

local function update_stats()
 if not STATE.ui then return end
 local n=0; for _ in pairs(STATE.eggs) do n=n+1 end
 if STATE.ui.eggCount then STATE.ui.eggCount.Text="🥚 "..STATE.total.." EGGS" end
 if STATE.ui.groupCount then STATE.ui.groupCount.Text="📊 "..n.." GROUPS" end
 local top=nil; local c=0
 for _,v in pairs(STATE.egg_values) do if v then c=c+1; if not top or v>top then top=v end end end
 if STATE.ui.topValue then STATE.ui.topValue.Text=top and ("🏆 TOP: "..fmt_v(top)) or "🏆 TOP: —" end
 if STATE.ui.valueCount then STATE.ui.valueCount.Text="💰 "..c.." RANKED" end
 if STATE.ui.debugLabel then
  STATE.ui.debugLabel.Text=STATE.total>0 and ("✅ "..STATE.total.."  💰"..c.."  TOP "..(top and fmt_v(top) or "—")) or ("⚠ "..STATE.last_error)
 end
end
local function refresh()
 local ok,g,t=pcall(scan)
 if not ok or not g then return end
 STATE.eggs=g; STATE.total=t
 for n,_ in pairs(g) do if STATE.expanded[n]==nil then STATE.expanded[n]=false end end
 update_stats()
 if STATE.ui and STATE.ui.search then pcall(render,STATE.ui.search.Text) end
end

local ok0,ui0=pcall(UI.build)
if ok0 and ui0 then STATE.ui=ui0 else warn("[BOOT] UI build failed"); return end
print("[MAIN] UI built")
if STATE.ui.refreshBtn then STATE.ui.refreshBtn.MouseButton1Click:Connect(function() pcall(refresh) end) end
if STATE.ui.search then
 STATE.ui.search:GetPropertyChangedSignal("Text"):Connect(function()
  if STATE.ui and STATE.ui.search then pcall(render,STATE.ui.search.Text) end
 end)
end
if UIS then
 UIS.InputBegan:Connect(function(inp,gp)
  if gp then return end
  if inp.KeyCode==Enum.KeyCode.F1 then
   if STATE.ui.main then
    STATE.ui.main.Visible=not STATE.ui.main.Visible
    if STATE.ui.floating then STATE.ui.floating.Text=STATE.ui.main.Visible and "✕" or "🥚" end
   end
  elseif inp.KeyCode==Enum.KeyCode.F2 then
   if STATE.ui.closeInfo then STATE.ui.closeInfo() end
  elseif inp.KeyCode==Enum.KeyCode.F3 then
   if STATE.saved_position then go_saved() end
  end
 end)
end
task.spawn(function()
 while STATE.running do
  task.wait(CFG.AUTO_REFRESH)
  pcall(refresh)
 end
end)
pcall(refresh)
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("👑 READY — v10.2 + VALUE FIXED")
print("   🥚 = فتح · 🎯 = رجوع · ℹ = معلومات")
print("   F1=hide F2=info F3=save-go")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

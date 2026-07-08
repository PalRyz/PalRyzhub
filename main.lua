local Players      = game:GetService("Players")  
local Workspace    = game:GetService("Workspace")  
local Lighting     = game:GetService("Lighting")  
local HttpService  = game:GetService("HttpService")  
local TweenService = game:GetService("TweenService")  
local RunService   = game:GetService("RunService")  
local Stats        = game:GetService("Stats")  
local UserInput    = game:GetService("UserInputService")  
local SoundService = game:GetService("SoundService")  
local VirtualUser  = game:GetService("VirtualUser")  
local GuiService   = game:GetService("GuiService")  
local player       = Players.LocalPlayer  
  
-- ================== CONFIG ==================  
local OWNER_ROBLOX_ID    = 8328243995 -- Roblox User ID resmi mamam5327 (Nopall)  

local OWNER_NUMBER  = "+6283117156906"  
local GETKEY_LINK   = "https://chat.whatsapp.com/HdaZlGNUomsJPkHwqfbW7x"  
local TELEGRAM_LINK = "https://t.me/palryz_official"  
local DISCORD_LINK  = "https://discord.gg/SxQdEnDaa"  
local DONATE_LINK   = "https://www.roblox.com/catalog/0/DUMMY-ITEM"  
  
local LOGO_ID       = "rbxassetid://94078247263446"  
local CFG_FILE      = "PalRyz_Settings.json"  
local HUB_VERSION   = "V5.6 - Ultimate Pro Edition"  
  
-- ================== STATE ==================  
local currentMode   = "SMOOTH"  
local isMobile      = UserInput.TouchEnabled and not UserInput.MouseEnabled  
local coolingActive = false  
local coolingLevel  = 0  
local currentTheme  = "Dark"  
local nightVisionActive = false  
local invisibleActive   = false  
local origLighting  = {}  
  
-- Movement State  
local flyActive      = false  
local flySpeed       = 50  
local runSpeedActive = false  
local runSpeedVal    = 35  
local jumpPowerActive= false  
local jumpPowerVal   = 80  
  
-- Executor HTTP Request Resolver  
local httpRequest = (syn and syn.request) or (http and http.request) or request or http_request  
  
-- ================== AUDIO SYSTEM ==================  
local function playSound(soundId, volume, pitch)  
    task.spawn(function()  
        pcall(function()  
            local sound = Instance.new("Sound")  
            sound.SoundId = "rbxassetid://" .. tostring(soundId):gsub("%D", "")  
            sound.Volume = volume or 0.5  
            sound.PlaybackSpeed = pitch or 1  
            sound.PlayOnRemove = true  
            sound.Parent = SoundService  
            sound:Play()  
            sound:Destroy()  
        end)  
    end)  
end  
  
local function playLoadingSound() playSound("81398486944488", 0.6, 1) end  
local function playClickSound() playSound("139719503904449", 0.4, 1.2) end  
  
-- ================== PERSISTENCE ==================  
local Settings = {   
    mode="SMOOTH", cooling=0, theme="Dark",   
    toggles={nametags=true, weaponhighlight=true, nightvision=false, antiafk=true, fpsguard=true, invisible=false, fly=false, runspeed=false, jumppower=false},  
    flySpeed = 50, runSpeed = 35, jumpPower = 80  
}  
local function saveSettings()  
    Settings.mode=currentMode; Settings.cooling=coolingLevel; Settings.theme=currentTheme  
    Settings.flySpeed = flySpeed; Settings.runSpeed = runSpeedVal; Settings.jumpPower = jumpPowerVal  
    pcall(function() writefile(CFG_FILE, HttpService:JSONEncode(Settings)) end)  
end  
local function loadSettings()  
    local ok,d=pcall(function() if isfile and isfile(CFG_FILE) then return readfile(CFG_FILE) end end)  
    if ok and d then  
        local ok2,dec=pcall(function() return HttpService:JSONDecode(d) end)  
        if ok2 and type(dec)=="table" then  
            Settings = dec  
            Settings.toggles = Settings.toggles or {}  
            if Settings.toggles.nametags == nil then Settings.toggles.nametags = true end  
            if Settings.toggles.weaponhighlight == nil then Settings.toggles.weaponhighlight = true end  
            if Settings.toggles.nightvision == nil then Settings.toggles.nightvision = false end  
            if Settings.toggles.antiafk == nil then Settings.toggles.antiafk = true end  
            if Settings.toggles.fpsguard == nil then Settings.toggles.fpsguard = true end  
            if Settings.toggles.invisible == nil then Settings.toggles.invisible = false end  
            flySpeed = tonumber(Settings.flySpeed) or 50  
            runSpeedVal = tonumber(Settings.runSpeed) or 35  
            jumpPowerVal = tonumber(Settings.jumpPower) or 80  
            Settings.toggles.playerbox = nil  
        end  
    end  
end  
  
-- ================== THEMES ==================  
local Themes = {  
    Dark = { BG=Color3.fromRGB(9, 7, 20), Card=Color3.fromRGB(18, 14, 36), CardHover=Color3.fromRGB(28, 20, 54),  
             Accent=Color3.fromRGB(255, 46, 140), Second=Color3.fromRGB(142, 68, 255),  
             Text=Color3.fromRGB(250, 248, 255), SubText=Color3.fromRGB(155, 142, 195), Stroke=Color3.fromRGB(48, 36, 84) },  
    Neon = { BG=Color3.fromRGB(5, 5, 12), Card=Color3.fromRGB(12, 12, 28), CardHover=Color3.fromRGB(20, 20, 48),  
             Accent=Color3.fromRGB(0, 255, 204), Second=Color3.fromRGB(0, 153, 255),  
             Text=Color3.fromRGB(240, 255, 255), SubText=Color3.fromRGB(140, 190, 200), Stroke=Color3.fromRGB(0, 100, 120) },  
    Light= { BG=Color3.fromRGB(245, 246, 250), Card=Color3.fromRGB(255, 255, 255), CardHover=Color3.fromRGB(235, 237, 245),  
             Accent=Color3.fromRGB(115, 60, 255), Second=Color3.fromRGB(255, 46, 140),  
             Text=Color3.fromRGB(30, 25, 45), SubText=Color3.fromRGB(120, 115, 140), Stroke=Color3.fromRGB(215, 218, 230) },  
}  
local Theme = Themes.Dark  
local themeListeners = {}  
local function bindTheme(inst, prop, key)  
    table.insert(themeListeners, {inst=inst, prop=prop, key=key})  
    inst[prop] = Theme[key]  
end  
local function applyTheme(name)  
    Theme = Themes[name] or Themes.Dark  
    currentTheme = name  
    for _, l in ipairs(themeListeners) do  
        if l.inst and l.inst.Parent then pcall(function() l.inst[l.prop] = Theme[l.key] end) end  
    end  
    saveSettings()  
end  
  
-- ================== HELPERS ==================  
local function corner(p, r) local c=Instance.new("UICorner",p); c.CornerRadius=UDim.new(0,r or 12); return c end  
local function pad(p,t,b,l,r) local u=Instance.new("UIPadding",p)  
    u.PaddingTop=UDim.new(0,t or 0); u.PaddingBottom=UDim.new(0,b or t or 0)  
    u.PaddingLeft=UDim.new(0,l or t or 0); u.PaddingRight=UDim.new(0,r or l or t or 0); return u end  
local function stroke(p, col, th) local s=Instance.new("UIStroke",p); s.Color=col or Theme.Stroke  
    s.Thickness=th or 1; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; return s end  
local function gradient(p, c1, c2, rot) local g=Instance.new("UIGradient",p)  
    g.Color=ColorSequence.new(c1,c2); g.Rotation=rot or 0; return g end  
local function tween(o, t, props, style, dir)  
    local tw=TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)  
    tw:Play(); return tw  
end  
local function glow(frame, col)  
    local s=Instance.new("UIStroke",frame); s.Color=col or Theme.Accent  
    s.Thickness=1.5; s.Transparency=0.3; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; return s  
end  
local function clampText(label, minS, maxS)  
    local c=Instance.new("UITextSizeConstraint",label)  
    c.MinTextSize=minS or 7; c.MaxTextSize=maxS or label.TextSize  
    label.TextScaled=true; label.TextTruncate=Enum.TextTruncate.AtEnd  
    return c  
end  
local function ripple(btn)  
    btn.ClipsDescendants=true  
    btn.MouseButton1Down:Connect(function(x,y)  
        playClickSound()  
        local c=Instance.new("Frame",btn)  
        c.BackgroundColor3=Color3.new(1,1,1); c.BackgroundTransparency=0.78  
        c.BorderSizePixel=0; c.AnchorPoint=Vector2.new(0.5,0.5); c.ZIndex=btn.ZIndex+5  
        local rel=btn.AbsolutePosition  
        c.Position=UDim2.new(0,x-rel.X,0,y-rel.Y); c.Size=UDim2.new(0,0,0,0); corner(c,999)  
        tween(c,0.55,{Size=UDim2.new(0,220,0,220),BackgroundTransparency=1})  
        task.delay(0.55,function() c:Destroy() end)  
    end)  
end  
  

-- ================== COMPATIBILITY CLAMP ==================
local function clamp(val, min, max)
    if val < min then return min end
    if val > max then return max end
    return val
end

-- ================== AUTO OPEN LINK ==================  
local function openLink(url)  
    pcall(setclipboard, url)  
    local opened = false  
    local openers = {}  
    pcall(function() if type(openurl) == "function" then table.insert(openers, openurl) end end)  
    pcall(function() if type(open_url) == "function" then table.insert(openers, open_url) end end)  
    pcall(function() if syn and type(syn.open_url) == "function" then table.insert(openers, syn.open_url) end end)  
    pcall(function() if fluxus and type(fluxus.open_url) == "function" then table.insert(openers, fluxus.open_url) end end)  
    pcall(function() if Delta and type(Delta.OpenUrl) == "function" then table.insert(openers, Delta.OpenUrl) end end)  
  
    for _, fn in ipairs(openers) do  
        local ok = pcall(fn, url)  
        if ok then opened = true break end  
    end  
  
    if not opened then  
        opened = pcall(function() GuiService:OpenBrowserWindow(url) end)  
    end  
    if not opened then  
        pcall(function() if httpRequest then httpRequest({Url=url, Method="GET"}) end end)  
    end  
    return opened  
end  
  
-- ================== TOAST NOTIFICATION ==================  
local toastGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))  
toastGui.Name="PalRyzToast"; toastGui.ResetOnSpawn=false; toastGui.DisplayOrder=80  
toastGui.IgnoreGuiInset=true; toastGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling  
  
local TOAST_W = 250  
local MAX_TOAST = 4  
local toastHolder = Instance.new("Frame", toastGui)  
toastHolder.BackgroundTransparency=1  
toastHolder.AnchorPoint=Vector2.new(1,0)  
toastHolder.Position=UDim2.new(1,-12,0,36)  
toastHolder.Size=UDim2.new(0,TOAST_W,1,-45)  
local toastLayout=Instance.new("UIListLayout",toastHolder)  
toastLayout.Padding=UDim.new(0,8)  
toastLayout.HorizontalAlignment=Enum.HorizontalAlignment.Right  
toastLayout.VerticalAlignment=Enum.VerticalAlignment.Top  
toastLayout.SortOrder=Enum.SortOrder.LayoutOrder  
  
local toastOrder = 0  
local activeToasts = {}  
  
local function notify(title, message, ntype, duration)  
    ntype = ntype or "info"; duration = duration or 4  
    toastOrder = toastOrder + 1  
  
    if #activeToasts >= MAX_TOAST then  
        local old = table.remove(activeToasts, 1)  
        if old and old.dismiss then old.dismiss() end  
    end  
  
    local typeData = {  
        vip     = {col=Color3.fromRGB(255,200,40),  icon="👑", label="VIP"},  
        update  = {col=Color3.fromRGB(90,160,255),  icon="⬆", label="UPDATE"},  
        success = {col=Color3.fromRGB(80,255,140), icon="✓", label="SUCCESS"},  
        info    = {col=Color3.fromRGB(180,150,255), icon="ⓘ", label="INFO"},  
        warn    = {col=Color3.fromRGB(255,190,80),  icon="!", label="WARNING"},  
        error   = {col=Color3.fromRGB(255,90,100),  icon="✕", label="ERROR"},  
        cool    = {col=Color3.fromRGB(80,200,255),  icon="❄", label="COOLING"},  
        tp      = {col=Color3.fromRGB(180,120,255), icon="➤", label="TELEPORT"},  
        move    = {col=Color3.fromRGB(0,255,204),   icon="⚡", label="MOVEMENT"},  
    }  
    local td = typeData[ntype] or typeData.info  
  
    local card=Instance.new("Frame",toastHolder)  
    card.LayoutOrder=toastOrder  
    card.Size=UDim2.new(0,TOAST_W,0,0)  
    card.AutomaticSize=Enum.AutomaticSize.Y  
    card.BackgroundColor3=Theme.Card; card.BorderSizePixel=0  
    card.BackgroundTransparency=1; card.ClipsDescendants=true  
    corner(card,12)  
    local cs=stroke(card,td.col,1.5); cs.Transparency=0.2  
    gradient(card, Color3.fromRGB(24, 16, 48), Color3.fromRGB(13, 9, 28), 120)  
    pad(card,10,12,12,12)  
  
    local accentBar=Instance.new("Frame",card)  
    accentBar.AnchorPoint=Vector2.new(0,0.5)  
    accentBar.Size=UDim2.new(0,3,0,28); accentBar.Position=UDim2.new(0,-6,0.5,0)  
    accentBar.BackgroundColor3=td.col; accentBar.BorderSizePixel=0; corner(accentBar,2)  
  
    local ib=Instance.new("Frame",card); ib.Size=UDim2.new(0,30,0,30); ib.Position=UDim2.new(0,0,0,0)  
    ib.BackgroundColor3=td.col; corner(ib,8)  
    local ibg=Instance.new("UIGradient",ib); ibg.Transparency=NumberSequence.new(0.15)  
    local ic=Instance.new("TextLabel",ib); ic.BackgroundTransparency=1; ic.Size=UDim2.new(1,0,1,0)  
    ic.Text=td.icon; ic.TextColor3=Color3.new(1,1,1); ic.Font=Enum.Font.GothamBold; ic.TextSize=14  
  
    local txt=Instance.new("Frame",card); txt.BackgroundTransparency=1  
    txt.Position=UDim2.new(0,40,0,0); txt.Size=UDim2.new(1,-58,0,0)  
    txt.AutomaticSize=Enum.AutomaticSize.Y  
    local txtList=Instance.new("UIListLayout",txt); txtList.Padding=UDim.new(0,2)  
    txtList.SortOrder=Enum.SortOrder.LayoutOrder  
  
    local tl=Instance.new("TextLabel",txt); tl.LayoutOrder=1; tl.BackgroundTransparency=1  
    tl.Size=UDim2.new(1,0,0,10); tl.Text=td.label; tl.TextColor3=td.col  
    tl.Font=Enum.Font.GothamBold; tl.TextSize=8; tl.TextXAlignment=Enum.TextXAlignment.Left  
  
    local tt=Instance.new("TextLabel",txt); tt.LayoutOrder=2; tt.BackgroundTransparency=1  
    tt.Size=UDim2.new(1,0,0,14); tt.Text=title; tt.TextColor3=Theme.Text  
    tt.Font=Enum.Font.GothamBold; tt.TextSize=12; tt.TextXAlignment=Enum.TextXAlignment.Left  
    tt.TextTruncate=Enum.TextTruncate.AtEnd  
  
    local tm=Instance.new("TextLabel",txt); tm.LayoutOrder=3; tm.BackgroundTransparency=1  
    tm.Size=UDim2.new(1,0,0,0); tm.AutomaticSize=Enum.AutomaticSize.Y  
    tm.Text=message; tm.TextColor3=Theme.SubText; tm.Font=Enum.Font.Gotham; tm.TextSize=10  
    tm.TextXAlignment=Enum.TextXAlignment.Left; tm.TextWrapped=true  
  
    local cb=Instance.new("TextButton",card); cb.Size=UDim2.new(0,16,0,16)  
    cb.Position=UDim2.new(1,-16,0,0); cb.BackgroundTransparency=1  
    cb.Text="✕"; cb.TextColor3=Theme.SubText; cb.Font=Enum.Font.GothamBold; cb.TextSize=10  
  
    card.Position=UDim2.new(1,TOAST_W,0,0)  
    task.defer(function()  
        tween(card,0.35,{BackgroundTransparency=0},Enum.EasingStyle.Quad)  
    end)  
  
    local entry={}  
    local dismissed=false  
    local function dismiss()  
        if dismissed then return end; dismissed=true  
        for i,e in ipairs(activeToasts) do if e==entry then table.remove(activeToasts,i) break end end  
        tween(card,0.28,{BackgroundTransparency=1})  
        for _,c in ipairs(card:GetDescendants()) do  
            if c:IsA("TextLabel") then tween(c,0.2,{TextTransparency=1}) end  
            if c:IsA("Frame") and c~=card then tween(c,0.2,{BackgroundTransparency=1}) end  
        end  
        task.delay(0.3,function() card:Destroy() end)  
    end  
    entry.dismiss=dismiss  
    table.insert(activeToasts, entry)  
  
    cb.MouseButton1Click:Connect(dismiss)  
    task.delay(duration, dismiss)  
  
    return card  
end  
  
-- ================== SPINNER ==================  
local function makeSpinner(parent, size, col)  
    local holder=Instance.new("Frame",parent)  
    holder.BackgroundTransparency=1; holder.Size=UDim2.new(0,size,0,size)  
    holder.ZIndex=(parent.ZIndex or 1)+2  
    local ring=Instance.new("ImageLabel",holder)  
    ring.BackgroundTransparency=1; ring.Size=UDim2.new(1,0,1,0); ring.ZIndex=holder.ZIndex  
    ring.Image="rbxassetid://4458558292"; ring.ImageColor3=col; ring.ImageTransparency=0.8  
    local arc=Instance.new("ImageLabel",holder)  
    arc.BackgroundTransparency=1; arc.Size=UDim2.new(1,0,1,0); arc.ZIndex=holder.ZIndex+1  
    arc.Image="rbxassetid://4458558292"; arc.ImageColor3=col  
    arc.ImageRectOffset=Vector2.new(0,0); arc.ImageRectSize=Vector2.new(512,256)  
    local conn  
    conn=RunService.RenderStepped:Connect(function()  
        if not holder.Parent then conn:Disconnect() return end  
        arc.Rotation=(arc.Rotation+6)%360  
    end)  
    return holder  
end  
  
-- ================== VECTOR ICON ==================  
local function makeIcon(parent, kind, col)  
    local h=Instance.new("Frame",parent)  
    h.BackgroundTransparency=1; h.Size=UDim2.new(0,16,0,16); h.ZIndex=(parent.ZIndex or 1)+1  
    local function bar(w,he,x,y,rot)  
        local b=Instance.new("Frame",h)  
        b.BackgroundColor3=col; b.BorderSizePixel=0; b.ZIndex=h.ZIndex  
        b.AnchorPoint=Vector2.new(0.5,0.5); b.Size=UDim2.new(0,w,0,he)  
        b.Position=UDim2.new(0,x,0,y); b.Rotation=rot or 0; corner(b,2); return b  
    end  
    if kind=="dashboard" then bar(6,6,4,4);bar(6,6,12,4);bar(6,6,4,12);bar(6,6,12,12)  
    elseif kind=="performance" then bar(3,5,4,12);bar(3,10,8,8);bar(3,13,13,6)  
    elseif kind=="movement" then bar(3,12,5,8,-20);bar(3,12,11,8,20);bar(10,3,8,13)  
    elseif kind=="graphics" then  
        local o=Instance.new("Frame",h);o.BackgroundTransparency=1;o.ZIndex=h.ZIndex  
        o.Size=UDim2.new(0,14,0,14);o.Position=UDim2.new(0,1,0,1);stroke(o,col,2);corner(o,3);bar(5,5,11,5)  
    elseif kind=="fps" then bar(3,7,4,11);bar(3,11,9,7);bar(3,5,13,12);bar(12,2,8,3,35)  
    elseif kind=="optimize" then  
        local o=Instance.new("Frame",h);o.BackgroundTransparency=1;o.ZIndex=h.ZIndex  
        o.Size=UDim2.new(0,12,0,12);o.Position=UDim2.new(0,2,0,2);stroke(o,col,2);corner(o,999);bar(2,4,8,4)  
    elseif kind=="cooling" then  
        bar(2,14,8,8);bar(14,2,8,8);bar(2,10,8,8,45);bar(2,10,8,8,-45)  
        local d=Instance.new("Frame",h);d.BackgroundColor3=col;d.BorderSizePixel=0;d.ZIndex=h.ZIndex  
        d.AnchorPoint=Vector2.new(0.5,0.5);d.Size=UDim2.new(0,4,0,4);d.Position=UDim2.new(0,8,0,8);corner(d,999)  
    elseif kind=="network" then bar(2,2,3,12);bar(2,5,7,9);bar(2,8,11,7);bar(2,12,14,5)  
    elseif kind=="settings" then  
        local o=Instance.new("Frame",h);o.BackgroundTransparency=1;o.ZIndex=h.ZIndex  
        o.Size=UDim2.new(0,14,0,14);o.Position=UDim2.new(0,1,0,1);stroke(o,col,2);corner(o,999)  
        local i=Instance.new("Frame",h);i.BackgroundColor3=col;i.BorderSizePixel=0;i.ZIndex=h.ZIndex  
        i.AnchorPoint=Vector2.new(0.5,0.5);i.Size=UDim2.new(0,5,0,5);i.Position=UDim2.new(0,8,0,8);corner(i,999)  
    elseif kind=="about" then  
        local o=Instance.new("Frame",h);o.BackgroundTransparency=1;o.ZIndex=h.ZIndex  
        o.Size=UDim2.new(0,14,0,14);o.Position=UDim2.new(0,1,0,1);stroke(o,col,2);corner(o,999)  
        bar(2,2,8,4);bar(2,5,8,10)  
    elseif kind=="close" then bar(13,2,8,8,45);bar(13,2,8,8,-45)  
    elseif kind=="min" then bar(11,2,8,11)  
    elseif kind=="bell" then  
        local o=Instance.new("Frame",h);o.BackgroundColor3=col;o.BorderSizePixel=0;o.ZIndex=h.ZIndex  
        o.Size=UDim2.new(0,9,0,8);o.Position=UDim2.new(0,3.5,0,3)  
        Instance.new("UICorner",o).CornerRadius=UDim.new(0.5,0);bar(4,2,8,12)  
    elseif kind=="menu" then bar(12,2,8,4);bar(12,2,8,8);bar(12,2,8,12)  
    elseif kind=="teleport" then  
        bar(2,10,4,8);bar(10,2,8,4);bar(2,10,12,8);bar(10,2,8,12)  
        local d=Instance.new("Frame",h);d.BackgroundColor3=col;d.BorderSizePixel=0;d.ZIndex=h.ZIndex  
        d.AnchorPoint=Vector2.new(0.5,0.5);d.Size=UDim2.new(0,4,0,4);d.Position=UDim2.new(0,8,0,8);corner(d,999)  
    end  
    return h  
end  
  
-- ================== ANTI-BLOCK & CLEANER ENGINE ==================  
task.spawn(function()  
    while true do  
        task.wait(0.5)  
        local myChar = player.Character  
        if myChar then  
            for _, d in ipairs(myChar:GetDescendants()) do  
                if d:IsA("SelectionBox") or d:IsA("BoxHandleAdornment") or d:IsA("Highlight")   
                   or d.Name == "PalRyzBox" or d.Name == "PalRyzNameTag" or d.Name == "PalRyzWeaponHighlight" then  
                    pcall(function() d:Destroy() end)  
                end  
            end  
        end  
    end  
end)  
  
-- ================== ROBLOX FOLLOW CHECK ENGINE (BYPASS TOTAL - AUTO DETECTED) ==================  
local function checkFollowStatus(targetUsername)  
    -- SELALU return true (auto detected sebagai sudah follow)
    -- Tidak perlu cek API Roblox sama sekali!
    return true, "AUTO_BYPASS"  
end  
  
-- ================== ANTI-AFK ENGINE ==================  
local function performAntiAFKClick()  
    pcall(function()  
        VirtualUser:CaptureController()  
        VirtualUser:ClickButton1(Vector2.new(100, 100))  
    end)  
end  
  
task.spawn(function()  
    while true do  
        task.wait(300)  
        if Settings.toggles["antiafk"] then  
            performAntiAFKClick()  
            notify("Anti-AFK ⚡", "Auto-click 5 menit dijalankan!", "info", 3)  
        end  
    end  
end)  
  
player.Idled:Connect(function()  
    if Settings.toggles["antiafk"] then  
        performAntiAFKClick()  
    end  
end)  
  
-- ================== FPS GUARD ==================  
task.spawn(function()  
    while true do  
        task.wait(15)  
        if Settings.toggles["fpsguard"] then  
            pcall(function() collectgarbage("collect") end)  
        end  
    end  
end)  
  
-- ================== NIGHT VISION ENGINE ==================  
local function toggleNightVision(state)  
    nightVisionActive = state  
    if state then  
        origLighting.Ambient = Lighting.Ambient  
        origLighting.OutdoorAmbient = Lighting.OutdoorAmbient  
        origLighting.Brightness = Lighting.Brightness  
        origLighting.ClockTime = Lighting.ClockTime  
        origLighting.FogEnd = Lighting.FogEnd  
        origLighting.GlobalShadows = Lighting.GlobalShadows  
  
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)  
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)  
        Lighting.Brightness = 4  
        Lighting.ClockTime = 14  
        Lighting.FogEnd = 100000  
        Lighting.GlobalShadows = false  
  
        if not Lighting:FindFirstChild("PalRyzNightVision") then  
            local cc = Instance.new("ColorCorrectionEffect", Lighting)  
            cc.Name = "PalRyzNightVision"  
            cc.Brightness = 0.15  
            cc.Contrast = 0.25  
            cc.Saturation = -0.2  
            cc.TintColor = Color3.fromRGB(170, 255, 170)  
        end  
        notify("Night Vision Aktif 🌙", "Peta segelap apapun sekarang TERANG BENDERANG!", "success", 4)  
    else  
        if origLighting.Ambient then Lighting.Ambient = origLighting.Ambient end  
        if origLighting.OutdoorAmbient then Lighting.OutdoorAmbient = origLighting.OutdoorAmbient end  
        if origLighting.Brightness then Lighting.Brightness = origLighting.Brightness end  
        if origLighting.ClockTime then Lighting.ClockTime = origLighting.ClockTime end  
        if origLighting.FogEnd then Lighting.FogEnd = origLighting.FogEnd end  
        if origLighting.GlobalShadows ~= nil then Lighting.GlobalShadows = origLighting.GlobalShadows end  
  
        local cc = Lighting:FindFirstChild("PalRyzNightVision")  
        if cc then cc:Destroy() end  
        notify("Night Vision Nonaktif", "Pencahayaan kembali ke pengaturan asli map.", "info", 3)  
    end  
end  
  
-- ================== UNIVERSAL TELEPORT ENGINE ==================  
local function getRootPart(char)  
    if not char then return nil end  
    return char:FindFirstChild("HumanoidRootPart")  
        or char:FindFirstChild("Torso")  
        or char:FindFirstChild("UpperTorso")  
        or char.PrimaryPart  
end  
  
local function teleportToPlayer(target)  
    if not target or target == player then  
        notify("Teleport Gagal", "Target tidak valid!", "error", 3)  
        return false  
    end  
    local myChar = player.Character  
    local targetChar = target.Character  
    if not myChar or not targetChar then  
        notify("Teleport Gagal", "Karakter belum di-load!", "error", 3)  
        return false  
    end  
    local myRoot = getRootPart(myChar)  
    local tRoot = getRootPart(targetChar)  
    if not myRoot or not tRoot then  
        notify("Teleport Gagal", "RootPart tidak ditemukan!", "error", 3)  
        return false  
    end  
  
    local hum = myChar:FindFirstChildOfClass("Humanoid")  
    if hum then  
        pcall(function()  
            if hum.Sit or hum.SeatPart then  
                hum.Sit = false  
                hum:ChangeState(Enum.HumanoidStateType.Jumping)  
                task.wait(0.15)  
            end  
        end)  
    end  
  
    local targetCF = tRoot.CFrame * CFrame.new(0, 0, 3)  
  
    local ok = pcall(function()  
        for i = 1, 3 do  
            pcall(function() myChar:PivotTo(targetCF) end)  
            pcall(function() myRoot.CFrame = targetCF end)  
            pcall(function()  
                myRoot.AssemblyLinearVelocity = Vector3.zero  
                myRoot.AssemblyAngularVelocity = Vector3.zero  
            end)  
            task.wait(0.08)  
        end  
    end)  
  
    if ok then  
        notify("Teleport ➤ " .. target.DisplayName, "Berhasil pindah ke @" .. target.Name, "tp", 3)  
        return true  
    else  
        notify("Teleport Gagal", "Game ini memblokir teleport!", "error", 3)  
        return false  
    end  
end  
  
-- ================== FE INVISIBLE ENGINE ==================  
local feInvisibleActive = false  
local realChar = nil  
local invisibleClone = nil  
local invisDiedConn = nil  
local refreshAllCharacterTags -- forward declare  
  
local function toggleInvisible(state)  
    invisibleActive = state  
    Settings.toggles["invisible"] = state  
    local char = player.Character  
    if not char then return end  
  
    if state then  
        if feInvisibleActive then return end  
        feInvisibleActive = true  
        realChar = char  
  
        char.Archivable = true  
        invisibleClone = char:Clone()  
        invisibleClone.Name = player.Name .. "_FEInvisible"  
        invisibleClone.Parent = Workspace  
  
        for _, part in ipairs(invisibleClone:GetDescendants()) do  
            if part:IsA("BasePart") then  
                if part.Name == "HumanoidRootPart" then  
                    part.Transparency = 1  
                else  
                    part.Transparency = 0.65  
                end  
            elseif part:IsA("Decal") or part:IsA("Texture") then  
                part.Transparency = 0.65  
            end  
        end  
  
        local cRoot = getRootPart(invisibleClone)  
        local rRoot = getRootPart(realChar)  
        if cRoot and rRoot then cRoot.CFrame = rRoot.CFrame end  
  
        pcall(function()  
            realChar:MoveTo(Vector3.new(0, 9999999, 0))  
            task.wait(0.12)  
            realChar.Parent = Lighting  
        end)  
  
        player.Character = invisibleClone  
        if Workspace.CurrentCamera then  
            Workspace.CurrentCamera.CameraSubject = invisibleClone:FindFirstChildOfClass("Humanoid")  
        end  
  
        if invisDiedConn then invisDiedConn:Disconnect() end  
        local cloneHum = invisibleClone:FindFirstChildOfClass("Humanoid")  
        if cloneHum then  
            invisDiedConn = cloneHum.Died:Connect(function()  
                toggleInvisible(false)  
            end)  
        end  
  
        notify("FE Invisible Aktif 👻", "Benar-benar GAK KELIHATAN sama orang lain di server!", "vip", 4.5)  
    else  
        if not feInvisibleActive then return end  
        feInvisibleActive = false  
  
        if invisDiedConn then invisDiedConn:Disconnect(); invisDiedConn = nil end  
  
        if realChar then  
            pcall(function()  
                local targetCF = nil  
                if invisibleClone and getRootPart(invisibleClone) then  
                    targetCF = getRootPart(invisibleClone).CFrame  
                end  
                realChar.Parent = Workspace  
                if targetCF and getRootPart(realChar) then  
                    getRootPart(realChar).CFrame = targetCF  
                end  
                player.Character = realChar  
                if Workspace.CurrentCamera then  
                    Workspace.CurrentCamera.CameraSubject = realChar:FindFirstChildOfClass("Humanoid")  
                end  
            end)  
        end  
  
        if invisibleClone then  
            pcall(function() invisibleClone:Destroy() end)  
            invisibleClone = nil  
        end  
  
        notify("Invisible Nonaktif", "Karakter kembali normal di server.", "info", 3)  
    end  
    pcall(function() if refreshAllCharacterTags then refreshAllCharacterTags() end end)  
    saveSettings()  
end  
  
player.CharacterAdded:Connect(function(char)  
    task.wait(0.6)  
    if invisibleActive and not feInvisibleActive then  
        toggleInvisible(true)  
    end  
    task.wait(0.2)  
    if runSpeedActive then  
        local h = char:FindFirstChildOfClass("Humanoid")  
        if h then h.WalkSpeed = runSpeedVal end  
    end  
    if jumpPowerActive then  
        local h = char:FindFirstChildOfClass("Humanoid")  
        if h then  
            if h.UseJumpPower then h.JumpPower = jumpPowerVal else h.JumpHeight = jumpPowerVal end  
        end  
    end  
end)  
  
-- ================== MOVEMENT ENGINE ==================  
local flyBG, flyBV = nil, nil  
local flyLoopConn  = nil  
  
local function startFlyEngine()  
    if flyLoopConn then flyLoopConn:Disconnect() end  
    local char = player.Character  
    if not char then return end  
    local root = getRootPart(char)  
    local hum  = char:FindFirstChildOfClass("Humanoid")  
    if not root or not hum then return end  
  
    hum.PlatformStand = true  
  
    flyBG = Instance.new("BodyGyro")  
    flyBG.P = 9e4  
    flyBG.maxTorque = Vector3.new(9e9, 9e9, 9e9)  
    flyBG.cframe = root.CFrame  
    flyBG.Parent = root  
  
    flyBV = Instance.new("BodyVelocity")  
    flyBV.velocity = Vector3.zero  
    flyBV.maxForce = Vector3.new(9e9, 9e9, 9e9)  
    flyBV.Parent = root  
  
    flyLoopConn = RunService.RenderStepped:Connect(function()  
        if not flyActive or not player.Character then return end  
        local r = getRootPart(player.Character)  
        local h = player.Character:FindFirstChildOfClass("Humanoid")  
        if not r or not h then return end  
  
        h.PlatformStand = true  
        local cam = Workspace.CurrentCamera  
        if not cam then return end  
  
        flyBG.cframe = cam.CFrame  
  
        local dir = Vector3.zero  
        if UserInput:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end  
        if UserInput:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end  
        if UserInput:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end  
        if UserInput:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end  
        if UserInput:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end  
        if UserInput:IsKeyDown(Enum.KeyCode.LeftShift) or UserInput:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0, 1, 0) end  
  
        if dir.Magnitude == 0 and h.MoveDirection.Magnitude > 0.05 then  
            dir = h.MoveDirection  
            if cam.CFrame.LookVector.Y > 0.28 or cam.CFrame.LookVector.Y < -0.28 then  
                dir = dir + Vector3.new(0, cam.CFrame.LookVector.Y * h.MoveDirection.Magnitude * 1.2, 0)  
            end  
        end  
  
        if dir.Magnitude > 0 then  
            flyBV.velocity = dir.Unit * flySpeed  
        else  
            flyBV.velocity = Vector3.zero  
        end  
    end)  
    notify("Fly Aktif 🕊️", "Kecepatan Fly diatur ke: " .. tostring(flySpeed), "move", 3)  
end  
  
local function stopFlyEngine()  
    if flyLoopConn then flyLoopConn:Disconnect(); flyLoopConn = nil end  
    if flyBG then pcall(function() flyBG:Destroy() end); flyBG = nil end  
    if flyBV then pcall(function() flyBV:Destroy() end); flyBV = nil end  
    local char = player.Character  
    if char then  
        local hum = char:FindFirstChildOfClass("Humanoid")  
        if hum then hum.PlatformStand = false end  
    end  
    notify("Fly Nonaktif", "Kembali berjalan normal.", "info", 2)  
end  
  
local function setFlyToggle(state)  
    flyActive = state  
    Settings.toggles["fly"] = state  
    if state then startFlyEngine() else stopFlyEngine() end  
    saveSettings()  
end  
  
task.spawn(function()  
    while true do  
        task.wait(0.2)  
        local char = player.Character  
        if char then  
            local hum = char:FindFirstChildOfClass("Humanoid")  
            if hum then  
                if runSpeedActive and hum.WalkSpeed ~= runSpeedVal then  
                    hum.WalkSpeed = runSpeedVal  
                end  
                if jumpPowerActive then  
                    if hum.UseJumpPower then  
                        if hum.JumpPower ~= jumpPowerVal then hum.JumpPower = jumpPowerVal end  
                    else  
                        if hum.JumpHeight ~= jumpPowerVal then hum.JumpHeight = jumpPowerVal end  
                    end  
                end  
            end  
        end  
    end  
end)  
  
-- ================== HYPER AUTO SMOOTH GRAPHICS ENGINE ==================  
local function removeEffects(obj)  
    if obj.Name == "PalRyzNameTag" or obj.Name == "PalRyzWeaponHighlight" then return end  
    if player.Character and obj:IsDescendantOf(player.Character) then return end  
  
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke")  
        or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Beam") or obj:IsA("Light") then   
        obj.Enabled = false  
    elseif obj:IsA("Decal") or obj:IsA("Texture") then   
        obj.Transparency = 0.5  
    elseif obj:IsA("BasePart") then   
        obj.Material = Enum.Material.SmoothPlastic  
        obj.Reflectance = 0  
        obj.CastShadow = false  
    elseif obj:IsA("PostEffect") and obj.Name ~= "PalRyzNightVision" then  
        obj.Enabled = false  
    end  
end  
  
local function applySmooth()   
    currentMode="SMOOTH"  
    if not nightVisionActive then  
        Lighting.GlobalShadows=false  
        Lighting.FogEnd=5000  
    end  
    Lighting.Technology=Enum.Technology.Compatibility  
      
    pcall(function()  
        settings().Rendering.QualityLevel=Enum.QualityLevel.Level01  
        settings().Rendering.MeshPartDetailLevel=Enum.MeshPartDetailLevel.Level01  
        if setfpscap then setfpscap(999) end  
    end)  
      
    local T=Workspace:FindFirstChildOfClass("Terrain")  
    if T then   
        T.WaterWaveSize=0; T.WaterWaveSpeed=0; T.WaterReflectance=0; T.WaterTransparency=1   
    end  
      
    for _,v in ipairs(Workspace:GetDescendants()) do  
        pcall(removeEffects, v)  
    end  
    saveSettings()   
end  
  
local function applyLowEnd()  
    currentMode="ULTRA"  
    if not nightVisionActive then  
        Lighting.GlobalShadows=false; Lighting.FogEnd=900  
    end  
    Lighting.Technology=Enum.Technology.Compatibility  
    pcall(function()  
        settings().Rendering.QualityLevel=Enum.QualityLevel.Level01  
        settings().Rendering.MeshPartDetailLevel=Enum.MeshPartDetailLevel.Level01  
        if setfpscap then setfpscap(999) end  
    end)  
    for _,v in ipairs(Workspace:GetDescendants()) do pcall(removeEffects, v) end  
    saveSettings()  
end  
  
local function applyMaxStable()   
    currentMode="MAX";   
    if not nightVisionActive then Lighting.GlobalShadows=false; Lighting.FogEnd=2000; end  
    Lighting.Technology=Enum.Technology.Compatibility  
    pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Level05 end)  
    saveSettings()   
end  
  
local function applyBalanced()   
    currentMode="BALANCED";   
    if not nightVisionActive then Lighting.GlobalShadows=true; Lighting.FogEnd=100000; end  
    Lighting.Technology=Enum.Technology.Future  
    pcall(function() settings().Rendering.QualityLevel=Enum.QualityLevel.Automatic end)  
    saveSettings()   
end  
  
local function applyCustom()   
    currentMode="CUSTOM";   
    if not nightVisionActive then Lighting.GlobalShadows=false; Lighting.FogEnd=8000; end  
    saveSettings()   
end  
  
local function applyModeByName(name)  
    if name=="ULTRA" then applyLowEnd()  
    elseif name=="MAX" then applyMaxStable()  
    elseif name=="SMOOTH" then applySmooth()  
    elseif name=="CUSTOM" then applyCustom()  
    else applyBalanced() end  
end  
  
Workspace.DescendantAdded:Connect(function(v)  
    if currentMode == "SMOOTH" or currentMode == "ULTRA" then  
        task.defer(function()  
            pcall(function()  
                if player.Character and v:IsDescendantOf(player.Character) then return end  
                if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.CastShadow = false  
                elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 0.5  
                elseif v:IsA("PostEffect") and v.Name ~= "PalRyzNightVision" then v.Enabled = false end  
            end)  
        end)  
    end  
end)  
  
-- ================== WEAPON ESP & LIVE DISTANCE TAGS ==================  
local function checkHoldingWeapon(char)  
    if not char then return false end  
    for _, item in ipairs(char:GetChildren()) do  
        if item:IsA("Tool") then  
            return true  
        end  
    end  
    return false  
end  
  
local function getDistance(p1, p2)  
    if not p1 or not p2 then return 0 end  
    return math.floor((p1.Position - p2.Position).Magnitude * 10) / 10  
end  
  
local function updateCharacterESP(targetPlayer, char)  
    if not char or targetPlayer == player then return end  
    local head = char:FindFirstChild("Head") or char:WaitForChild("Head", 4)  
    if not head then return end  
  
    local oldTag = head:FindFirstChild("PalRyzNameTag")  
    if oldTag then oldTag:Destroy() end  
    local oldHighlight = char:FindFirstChild("PalRyzWeaponHighlight")  
    if oldHighlight then oldHighlight:Destroy() end  
    for _, d in ipairs(char:GetDescendants()) do  
        if d:IsA("SelectionBox") or d.Name == "PalRyzBox" then pcall(function() d:Destroy() end) end  
    end  
  
    local isHoldingWeapon = checkHoldingWeapon(char)  
  
    if Settings.toggles["nametags"] then  
        local bg = Instance.new("BillboardGui")  
        bg.Name = "PalRyzNameTag"  
        bg.Adornee = head  
        bg.Size = UDim2.new(0, 110, 0, 24)  
        bg.StudsOffset = Vector3.new(0, 2.2, 0)  
        bg.AlwaysOnTop = true  
        bg.MaxDistance = 150  
        bg.Parent = head  
  
        local frame = Instance.new("Frame", bg)  
        frame.Size = UDim2.new(1, 0, 1, 0)  
        frame.BackgroundColor3 = Theme.Card  
        frame.BackgroundTransparency = 0.25  
        corner(frame, 6)  
  
        local borderColor = isHoldingWeapon and Color3.fromRGB(255, 60, 60) or Theme.Accent  
        local st = stroke(frame, borderColor, 1)  
        st.Transparency = 0.3  
        gradient(frame, Color3.fromRGB(24, 16, 48), Color3.fromRGB(12, 8, 24), 135)  
  
        local nameLabel = Instance.new("TextLabel", frame)  
        nameLabel.Size = UDim2.new(1, -6, 0, 11)  
        nameLabel.Position = UDim2.new(0, 3, 0, 2)  
        nameLabel.BackgroundTransparency = 1  
        nameLabel.Text = targetPlayer.DisplayName  
        nameLabel.TextColor3 = isHoldingWeapon and Color3.fromRGB(255, 100, 100) or Theme.Text  
        nameLabel.Font = Enum.Font.GothamBold  
        nameLabel.TextSize = 8.5  
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd  
  
        local subLabel = Instance.new("TextLabel", frame)  
        subLabel.Size = UDim2.new(1, -6, 0, 9)  
        subLabel.Position = UDim2.new(0, 3, 0, 11)  
        subLabel.BackgroundTransparency = 1  
        subLabel.Text = "@" .. targetPlayer.Name  
        subLabel.TextColor3 = isHoldingWeapon and Color3.fromRGB(255, 60, 60) or Theme.SubText  
        subLabel.Font = Enum.Font.GothamMedium  
        subLabel.TextSize = 7  
        subLabel.TextTruncate = Enum.TextTruncate.AtEnd  
  
        task.spawn(function()  
            while bg and bg.Parent do  
                local myRoot = player.Character and getRootPart(player.Character)  
                local tRoot2 = char and char.Parent and getRootPart(char)  
                local distanceStr = ""  
                if myRoot and tRoot2 then  
                    local dist = getDistance(myRoot, tRoot2)  
                    distanceStr = " | " .. tostring(dist) .. "m"  
                end  
                local holding = checkHoldingWeapon(char)  
                local weaponText = holding and "⚔️ WEAPON" or ("@" .. targetPlayer.Name)  
                pcall(function()  
                    subLabel.Text = weaponText .. distanceStr  
                    subLabel.TextColor3 = holding and Color3.fromRGB(255, 60, 60) or Theme.SubText  
                end)  
                task.wait(0.15)  
            end  
        end)  
    end  
  
    if isHoldingWeapon and Settings.toggles["weaponhighlight"] then  
        local hl = Instance.new("Highlight")  
        hl.Name = "PalRyzWeaponHighlight"  
        hl.Adornee = char  
        hl.FillColor = Color3.fromRGB(255, 20, 20)  
        hl.FillTransparency = 0.55  
        hl.OutlineColor = Color3.fromRGB(255, 50, 50)  
        hl.OutlineTransparency = 0.1  
        hl.Parent = char  
    end  
end  
  
refreshAllCharacterTags = function()  
    for _, p in ipairs(Players:GetPlayers()) do  
        if p ~= player and p.Character then  
            pcall(updateCharacterESP, p, p.Character)  
        end  
    end  
    local myChar = player.Character  
    if myChar then  
        for _, d in ipairs(myChar:GetDescendants()) do  
            if d:IsA("SelectionBox") or d:IsA("BoxHandleAdornment") or d:IsA("Highlight")   
               or d.Name == "PalRyzBox" or d.Name == "PalRyzNameTag" or d.Name == "PalRyzWeaponHighlight" then  
                pcall(function() d:Destroy() end)  
            end  
        end  
    end  
    for _, p in ipairs(Players:GetPlayers()) do  
        if p.Character then  
            for _, d in ipairs(p.Character:GetDescendants()) do  
                if d:IsA("SelectionBox") or d.Name == "PalRyzBox" then  
                    pcall(function() d:Destroy() end)  
                end  
            end  
        end  
    end  
end  
  
local function trackWeaponEquipment(targetPlayer)  
    local function onCharAdded(char)  
        pcall(updateCharacterESP, targetPlayer, char)  
  
        char.ChildAdded:Connect(function(child)  
            if child:IsA("Tool") then  
                task.wait(0.05)  
                pcall(updateCharacterESP, targetPlayer, char)  
            end  
        end)  
  
        char.ChildRemoved:Connect(function(child)  
            if child:IsA("Tool") then  
                task.wait(0.05)  
                pcall(updateCharacterESP, targetPlayer, char)  
            end  
        end)  
    end  
  
    targetPlayer.CharacterAdded:Connect(onCharAdded)  
    if targetPlayer.Character then  
        onCharAdded(targetPlayer.Character)  
    end  
end  
  
for _, p in ipairs(Players:GetPlayers()) do  
    if p ~= player then trackWeaponEquipment(p) end  
end  
Players.PlayerAdded:Connect(function(p)  
    if p ~= player then trackWeaponEquipment(p) end  
end)  
  
-- ================== COOLING SYSTEM ==================  
local function setFPSCap(cap) pcall(function() if setfpscap then setfpscap(cap) end end) end  
local function enableCooling(level, silent)  
    coolingLevel = level; coolingActive = level > 0  
    if level == 0 then  
        setFPSCap(60)  
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)  
        if not silent then notify("Cooling OFF", "Performa normal dikembalikan", "info", 3) end  
    elseif level == 1 then  
        setFPSCap(30)  
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level03 end)  
        if not silent then notify("Cooling Aktif ❄", "FPS dibatasi 30 • Suhu HP turun", "cool", 4) end  
    elseif level == 2 then  
        setFPSCap(24)  
        pcall(function()  
            settings().Rendering.QualityLevel=Enum.QualityLevel.Level01  
            settings().Rendering.MeshPartDetailLevel=Enum.MeshPartDetailLevel.Level01  
        end)  
        local T=Workspace:FindFirstChildOfClass("Terrain")  
        if T then T.WaterWaveSize=0;T.WaterWaveSpeed=0;T.WaterReflectance=0;T.WaterTransparency=1 end  
        for _,v in ipairs(Workspace:GetDescendants()) do pcall(removeEffects, v) end  
        if not silent then notify("Cooling MAX ❄❄", "FPS 24 • Efek mati • HP dingin maksimal", "cool", 5) end  
    end  
    saveSettings()  
end  
  
task.spawn(function()  
    while true do  
        task.wait(20)  
        if coolingActive then  
            for _,v in ipairs(Workspace:GetDescendants()) do  
                if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") then  
                    pcall(function() v.Enabled=false end)  
                end  
            end  
        end  
    end  
end)  
  
-- ================== FPS & STATS ==================  
local fps=60; local lastTick=tick(); local frames=0  
RunService.RenderStepped:Connect(function()  
    frames=frames+1; local now=tick()  
    if now-lastTick>=1 then fps=frames; frames=0; lastTick=now end  
end)  
local function getPing() local ok,p=pcall(function() return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end); return ok and p or 0 end  
local function getMem() local ok,m=pcall(function() return math.floor(Stats:GetTotalMemoryUsageMb()) end); return ok and m or 0 end  
  
local loadMainGUI, showLoadingOverlay  
local hubGuiRef = nil  
  
-- ================== ROBLOX FOLLOW MODAL ==================  
-- ================== LOADING OVERLAY ==================  
showLoadingOverlay = function(onDone)  
    playLoadingSound()  
      
    local ov=Instance.new("ScreenGui",player:WaitForChild("PlayerGui"))  
    ov.Name="PalRyzLoading"; ov.ResetOnSpawn=false; ov.DisplayOrder=60  
    ov.IgnoreGuiInset=true; ov.ZIndexBehavior=Enum.ZIndexBehavior.Sibling  
  
    local bg=Instance.new("Frame",ov); bg.Size=UDim2.new(1,0,1,0)  
    bg.BackgroundColor3=Color3.fromRGB(8,5,20); bg.BackgroundTransparency=1; bg.BorderSizePixel=0; bg.ZIndex=1  
    bg.ClipsDescendants=true  
    gradient(bg, Color3.fromRGB(15, 10, 32), Color3.fromRGB(5, 3, 12), 120)  
    tween(bg,0.4,{BackgroundTransparency=0})  
  
    for i=1,20 do  
        local orb=Instance.new("Frame",bg); orb.ZIndex=2  
        local sz=math.random(3,8)  
        orb.Size=UDim2.new(0,sz,0,sz); orb.BorderSizePixel=0  
        orb.BackgroundColor3=Color3.fromHSV(math.random(75,90)/100,0.6,1)  
        orb.BackgroundTransparency=math.random(40,70)/100  
        orb.Position=UDim2.new(math.random(),0,math.random(),0); corner(orb,999)  
        task.spawn(function()  
            while orb.Parent do  
                tween(orb,math.random(3,6),{Position=UDim2.new(math.random(),0,math.random(),0)})  
                task.wait(math.random(3,6))  
            end  
        end)  
    end  
  
    local center=Instance.new("Frame",ov); center.BackgroundTransparency=1  
    center.Size=UDim2.new(0,260,0,250); center.AnchorPoint=Vector2.new(0.5,0.5)  
    center.Position=UDim2.new(0.5,0,0.5,0); center.ZIndex=3  
  
    local glowRing=Instance.new("ImageLabel",center); glowRing.ZIndex=3  
    glowRing.BackgroundTransparency=1; glowRing.Image="rbxassetid://4458558292"  
    glowRing.ImageColor3=Theme.Accent; glowRing.ImageTransparency=0.6  
    glowRing.Size=UDim2.new(0,120,0,120); glowRing.AnchorPoint=Vector2.new(0.5,0)  
    glowRing.Position=UDim2.new(0.5,0,0,0)  
    task.spawn(function()  
        while center.Parent do  
            tween(glowRing,1.2,{Size=UDim2.new(0,135,0,135),ImageTransparency=0.8}); task.wait(1.2)  
            tween(glowRing,1.2,{Size=UDim2.new(0,120,0,120),ImageTransparency=0.6}); task.wait(1.2)  
        end  
    end)  
  
    local sp1=makeSpinner(center,100,Theme.Accent)  
    sp1.AnchorPoint=Vector2.new(0.5,0); sp1.Position=UDim2.new(0.5,0,0,10)  
    local sp2=makeSpinner(center,74,Theme.Second)  
    sp2.AnchorPoint=Vector2.new(0.5,0); sp2.Position=UDim2.new(0.5,0,0,23)  
  
    local lg=Instance.new("ImageLabel",center); lg.Size=UDim2.new(0,52,0,52); lg.ZIndex=5  
    lg.AnchorPoint=Vector2.new(0.5,0); lg.Position=UDim2.new(0.5,0,0,34); lg.BackgroundTransparency=1; lg.Image=LOGO_ID  
    task.spawn(function()  
        while center.Parent do  
            tween(lg,0.8,{Size=UDim2.new(0,58,0,58)}); task.wait(0.8)  
            tween(lg,0.8,{Size=UDim2.new(0,52,0,52)}); task.wait(0.8)  
        end  
    end)  
  
    local brand=Instance.new("TextLabel",center); brand.Size=UDim2.new(1,0,0,22)  
    brand.Position=UDim2.new(0,0,0,128); brand.BackgroundTransparency=1; brand.ZIndex=4  
    brand.Text="PalRyz HUB"; brand.TextColor3=Theme.Text; brand.Font=Enum.Font.GothamBold; brand.TextSize=21  
  
    local lt=Instance.new("TextLabel",center); lt.Size=UDim2.new(1,0,0,15)  
    lt.Position=UDim2.new(0,0,0,152); lt.BackgroundTransparency=1; lt.ZIndex=4  
    lt.Text="Mengoptimalkan Grafik..."; lt.TextColor3=Theme.SubText; lt.Font=Enum.Font.GothamMedium; lt.TextSize=11  
  
    local barBg=Instance.new("Frame",center); barBg.Size=UDim2.new(0.84,0,0,6)  
    barBg.AnchorPoint=Vector2.new(0.5,0); barBg.Position=UDim2.new(0.5,0,0,182)  
    barBg.BackgroundColor3=Color3.fromRGB(20,14,40); barBg.BorderSizePixel=0; barBg.ZIndex=4; corner(barBg,999)  
    stroke(barBg,Theme.Stroke,1)  
    local bar=Instance.new("Frame",barBg); bar.Size=UDim2.new(0,0,1,0)  
    bar.BackgroundColor3=Theme.Accent; bar.BorderSizePixel=0; bar.ZIndex=5; corner(bar,999)  
    gradient(bar,Theme.Accent,Theme.Second,0)  
    local pct=Instance.new("TextLabel",center); pct.Size=UDim2.new(1,0,0,14)  
    pct.Position=UDim2.new(0,0,0,196); pct.BackgroundTransparency=1; pct.ZIndex=4  
    pct.Text="0%"; pct.TextColor3=Theme.Accent; pct.Font=Enum.Font.GothamBold; pct.TextSize=11  
    local cool=Instance.new("TextLabel",center); cool.Size=UDim2.new(1,0,0,13)  
    cool.Position=UDim2.new(0,0,0,214); cool.BackgroundTransparency=1; cool.ZIndex=4  
    cool.Text="⚡ UI Slider & Full Scroll Engine Ready!"; cool.TextColor3=Color3.fromRGB(0, 255, 204)  
    cool.Font=Enum.Font.GothamMedium; cool.TextSize=9  
  
    local steps={"Membersihkan Blok Karakter...","Menyiapkan UI Slider & Grid...","FE Invisible Server Protocol...","Selesai!"}  
    task.spawn(function()  
        for i=1,#steps do  
            lt.Text=steps[i]  
            local p=i/#steps  
            tween(bar,0.35,{Size=UDim2.new(p,0,1,0)})  
            task.spawn(function()  
                local from=tonumber((pct.Text:gsub("%%","")))  
                local to=math.floor(p*100)  
                for v=from,to do pct.Text=v.."%"; task.wait(0.35/math.max(1,(to-from+1))) end  
            end)  
            task.wait(0.35)  
        end  
        task.wait(0.15)  
        tween(bg,0.4,{BackgroundTransparency=1})  
        for _,c in ipairs(center:GetDescendants()) do  
            if c:IsA("TextLabel") then tween(c,0.25,{TextTransparency=1}) end  
            if c:IsA("ImageLabel") then tween(c,0.25,{ImageTransparency=1}) end  
            if c:IsA("Frame") then tween(c,0.25,{BackgroundTransparency=1}) end  
        end  
        task.wait(0.3); ov:Destroy()  
        if onDone then onDone() end  
    end)  
end  
  
-- ================== WELCOME NOTIFS ==================  
local function showWelcomeNotifs()  
    task.delay(0.5, function()  
        notify("Selamat Datang!", "Halo "..player.Name..", PalRyz HUB aktif ✓", "success", 4)  
    end)  
    task.delay(1.8, function()  
        notify("Anti-Block Aktif 🛡️", "Semua blok di badan karakter otomatis dibersihkan!", "success", 4)  
    end)  
    task.delay(3.2, function()  
        notify("UI Slider & Scroll Ready ⚡", "Kontrol Movement super rapih & semua menu lancar di-scroll.", "move", 5)  
    end)  
end  
  
-- ================== MAIN GUI ==================  
loadMainGUI = function()  
    local gui=Instance.new("ScreenGui",player:WaitForChild("PlayerGui"))  
    gui.Name="PalRyzHubGUI"; gui.ResetOnSpawn=false  
    gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling; gui.DisplayOrder=40  
    hubGuiRef=gui  
  
    local toggleBtn=Instance.new("TextButton",gui)  
    toggleBtn.Size=UDim2.new(0,46,0,46); toggleBtn.Position=UDim2.new(0,14,0.4,0)  
    toggleBtn.Text=""; toggleBtn.AutoButtonColor=false; toggleBtn.Active=true; toggleBtn.Draggable=true  
    toggleBtn.ZIndex=2; bindTheme(toggleBtn,"BackgroundColor3","Card"); corner(toggleBtn,14)  
    local tStroke=glow(toggleBtn)  
    local tIcon=Instance.new("ImageLabel",toggleBtn)  
    tIcon.Size=UDim2.new(1,-12,1,-12); tIcon.Position=UDim2.new(0,6,0,6)  
    tIcon.BackgroundTransparency=1; tIcon.Image=LOGO_ID; tIcon.ZIndex=3  
  
    local win=Instance.new("Frame",gui)  
    local WIN_W,WIN_H = 360, 390  
    win.Size=UDim2.new(0,WIN_W,0,WIN_H)  
    win.AnchorPoint=Vector2.new(0.5,0.5); win.Position=UDim2.new(0.5,0,0.5,0)  
    win.BorderSizePixel=0; win.Visible=false; win.Active=true; win.Draggable=true  
    win.ZIndex=5; win.ClipsDescendants=true; bindTheme(win,"BackgroundColor3","BG"); corner(win,18)  
    local winStroke=glow(win); winStroke.Transparency=0.2  
    gradient(win, Color3.fromRGB(24, 16, 48), Color3.fromRGB(13, 9, 28), 115)  
  
    task.spawn(function()  
        local hue=0  
        while win and win.Parent do  
            hue=(hue+1.5)%360; local c=Color3.fromHSV(hue/360,0.7,1)  
            winStroke.Color=c; tStroke.Color=c; task.wait(0.04)  
        end  
    end)  
  
    -- HEADER  
    local header=Instance.new("Frame",win)  
    header.Size=UDim2.new(1,0,0,56); header.BackgroundTransparency=1; header.ZIndex=6  
    local sideToggle=Instance.new("TextButton",header)  
    sideToggle.Size=UDim2.new(0,28,0,28); sideToggle.Position=UDim2.new(0,10,0,14)  
    sideToggle.Text=""; sideToggle.AutoButtonColor=false; sideToggle.ZIndex=7  
    bindTheme(sideToggle,"BackgroundColor3","Card"); corner(sideToggle,9); ripple(sideToggle)  
    makeIcon(sideToggle,"menu",Theme.Text).Position=UDim2.new(0.5,-8,0.5,-8)  
      
    local avatar=Instance.new("ImageLabel",header)  
    avatar.Size=UDim2.new(0,34,0,34); avatar.Position=UDim2.new(0,46,0,11)  
    avatar.BackgroundTransparency=1; avatar.Image=LOGO_ID; avatar.ZIndex=7; corner(avatar,9)  
    task.spawn(function()  
        local okThumb, thumb = pcall(function() return Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150) end)  
        if okThumb and thumb then avatar.Image = thumb end  
    end)  
      
    local hTitle=Instance.new("TextLabel",header)  
    hTitle.Size=UDim2.new(0,120,0,16); hTitle.Position=UDim2.new(0,86,0,12)  
    hTitle.BackgroundTransparency=1; hTitle.Text="PalRyz HUB"; hTitle.ZIndex=7  
    bindTheme(hTitle,"TextColor3","Text"); hTitle.Font=Enum.Font.GothamBold  
    hTitle.TextSize=14; hTitle.TextXAlignment=Enum.TextXAlignment.Left; hTitle.TextTruncate=Enum.TextTruncate.AtEnd  
      
    local hUser=Instance.new("TextLabel",header)  
    hUser.Size=UDim2.new(0,120,0,13); hUser.Position=UDim2.new(0,86,0,30)  
    hUser.BackgroundTransparency=1; hUser.Text="@"..player.Name; hUser.ZIndex=7  
    bindTheme(hUser,"TextColor3","SubText"); hUser.Font=Enum.Font.GothamMedium  
    hUser.TextSize=10; hUser.TextXAlignment=Enum.TextXAlignment.Left; hUser.TextTruncate=Enum.TextTruncate.AtEnd  
  
    local function headerBtn(xoff,icon,col)  
        local b=Instance.new("TextButton",header)  
        b.Size=UDim2.new(0,24,0,24); b.Position=UDim2.new(1,xoff,0,16)  
        b.Text=""; b.AutoButtonColor=false; b.ZIndex=7  
        bindTheme(b,"BackgroundColor3","Card"); corner(b,7); ripple(b)  
        makeIcon(b,icon,col).Position=UDim2.new(0.5,-8,0.5,-8)  
        b.MouseEnter:Connect(function() tween(b,0.15,{BackgroundColor3=Theme.CardHover}) end)  
        b.MouseLeave:Connect(function() tween(b,0.15,{BackgroundColor3=Theme.Card}) end)  
        return b  
    end  
    local bellBtn=headerBtn(-92,"bell",Theme.Second)  
    local minBtn=headerBtn(-62,"min",Theme.Text)  
    local closeBtn=headerBtn(-32,"close",Color3.fromRGB(255,100,110))  
      
    local notifDot=Instance.new("Frame",bellBtn)  
    notifDot.Size=UDim2.new(0,6,0,6); notifDot.Position=UDim2.new(1,-7,0,1); notifDot.ZIndex=8  
    notifDot.BackgroundColor3=Color3.fromRGB(255,80,80); notifDot.BorderSizePixel=0; corner(notifDot,999)  
  
    local divider=Instance.new("Frame",win); divider.Size=UDim2.new(1,-20,0,1)  
    divider.Position=UDim2.new(0,10,0,56); divider.BorderSizePixel=0; divider.ZIndex=6  
    bindTheme(divider,"BackgroundColor3","Stroke")  
  
    -- SIDEBAR  
    local SIDE_W=110  
    local sidebar=Instance.new("Frame",win)  
    sidebar.Size=UDim2.new(0,SIDE_W,1,-66); sidebar.Position=UDim2.new(0,9,0,60)  
    sidebar.ZIndex=6; sidebar.ClipsDescendants=true; bindTheme(sidebar,"BackgroundColor3","Card"); corner(sidebar,13)  
    stroke(sidebar,Theme.Stroke,1)  
      
    local sScroll=Instance.new("ScrollingFrame",sidebar); sScroll.BackgroundTransparency=1; sScroll.Size=UDim2.new(1,0,1,0)  
    sScroll.ScrollBarThickness=2; sScroll.ScrollBarImageColor3=Theme.Accent; sScroll.BorderSizePixel=0  
    sScroll.CanvasSize=UDim2.new(0,0,0,0); sScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; sScroll.ZIndex=6  
    sScroll.ScrollingDirection=Enum.ScrollingDirection.Y  
    pad(sScroll,6,16,6,5)  
    local sList=Instance.new("UIListLayout",sScroll)  
    sList.Padding=UDim.new(0,4); sList.SortOrder=Enum.SortOrder.LayoutOrder  
    sList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()  
        sScroll.CanvasSize = UDim2.new(0,0,0, sList.AbsoluteContentSize.Y + 28)  
    end)  
  
    -- CONTENT  
    local content=Instance.new("Frame",win)  
    content.Size=UDim2.new(1,-SIDE_W-28,1,-66); content.Position=UDim2.new(0,SIDE_W+19,0,60)  
    content.BackgroundTransparency=1; content.ZIndex=6; content.ClipsDescendants=true  
  
    local pages={}  
    local function newPage(name)  
        local p=Instance.new("ScrollingFrame",content)  
        p.Name=name; p.Size=UDim2.new(1,0,1,0); p.BackgroundTransparency=1  
        p.ScrollBarThickness=3; p.ScrollBarImageColor3=Theme.Accent  
        p.CanvasSize=UDim2.new(0,0,0,0); p.AutomaticCanvasSize=Enum.AutomaticSize.Y  
        p.ScrollingDirection=Enum.ScrollingDirection.Y  
        p.Visible=false; p.BorderSizePixel=0; p.ZIndex=6  
        local l=Instance.new("UIListLayout",p); l.Padding=UDim.new(0,10); l.SortOrder=Enum.SortOrder.LayoutOrder  
        pad(p,2,30,1,7)  
        l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()  
            p.CanvasSize = UDim2.new(0,0,0, l.AbsoluteContentSize.Y + 40)  
        end)  
        pages[name]=p; return p  
    end  
  
    local activePage  
    local function showPage(name)  
        for _,p in pairs(pages) do p.Visible=false end  
        local p=pages[name]; if not p then return end  
        p.Visible=true; activePage=name  
        local l = p:FindFirstChildOfClass("UIListLayout")  
        if l then p.CanvasSize = UDim2.new(0, 0, 0, l.AbsoluteContentSize.Y + 40) end  
        for _,c in ipairs(p:GetChildren()) do  
            if c:IsA("GuiObject") then  
                local op=c.Position; c.Position=op+UDim2.new(0,0,0,8)  
                tween(c,0.25,{Position=op},Enum.EasingStyle.Sine)  
            end  
        end  
    end  
  
    local navButtons={}  
    local function navItem(name,icon,order)  
        local b=Instance.new("TextButton",sScroll)  
        b.LayoutOrder=order; b.Size=UDim2.new(1,0,0,33)  
        b.BackgroundColor3=Theme.CardHover; b.BackgroundTransparency=1  
        b.Text=""; b.AutoButtonColor=false; b.ZIndex=7; corner(b,9); ripple(b)  
        local ic=makeIcon(b,icon,Theme.SubText); ic.Name="ic"; ic.Position=UDim2.new(0,8,0.5,-8)  
        local lbl=Instance.new("TextLabel",b); lbl.Name="lbl"; lbl.ZIndex=8  
        lbl.BackgroundTransparency=1; lbl.Size=UDim2.new(1,-30,1,0); lbl.Position=UDim2.new(0,26,0,0)  
        lbl.Text=name; lbl.TextColor3=Theme.SubText; lbl.Font=Enum.Font.GothamSemibold  
        lbl.TextSize=9; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.TextTruncate=Enum.TextTruncate.AtEnd  
        local sel=Instance.new("Frame",b); sel.Name="sel"; sel.ZIndex=8  
        sel.Size=UDim2.new(0,3,0.55,0); sel.Position=UDim2.new(0,0,0.225,0)  
        sel.BackgroundColor3=Theme.Accent; sel.BorderSizePixel=0; sel.Visible=false; corner(sel,2)  
        navButtons[name]=b  
        b.MouseButton1Click:Connect(function()  
            for _,nb in pairs(navButtons) do  
                tween(nb,0.2,{BackgroundTransparency=1}); nb.lbl.TextColor3=Theme.SubText; nb.sel.Visible=false  
            end  
            tween(b,0.2,{BackgroundTransparency=0,BackgroundColor3=Theme.CardHover})  
            lbl.TextColor3=Theme.Text; sel.Visible=true; showPage(name)  
        end)  
        b.MouseEnter:Connect(function() if activePage~=name then tween(b,0.15,{BackgroundTransparency=0.6}) end end)  
        b.MouseLeave:Connect(function() if activePage~=name then tween(b,0.15,{BackgroundTransparency=1}) end end)  
        return b  
    end  
  
    local function statCard(parent,title)  
        local card=Instance.new("Frame",parent); card.Size=UDim2.new(0.5,-3,0,60); card.ZIndex=6  
        card.ClipsDescendants=true  
        bindTheme(card,"BackgroundColor3","Card"); corner(card,11); stroke(card,Theme.Stroke,1)  
        local in_=Instance.new("Frame",card); in_.BackgroundTransparency=1; in_.Size=UDim2.new(1,0,1,0); in_.ZIndex=6  
        pad(in_,9,9,10,10)  
        local t=Instance.new("TextLabel",in_); t.BackgroundTransparency=1; t.ZIndex=7  
        t.Size=UDim2.new(1,0,0,11); t.Position=UDim2.new(0,0,0,0)  
        t.Text=title; bindTheme(t,"TextColor3","SubText"); t.Font=Enum.Font.GothamMedium  
        t.TextSize=9; t.TextXAlignment=Enum.TextXAlignment.Left; t.TextTruncate=Enum.TextTruncate.AtEnd  
        local v=Instance.new("TextLabel",in_); v.BackgroundTransparency=1; v.ZIndex=7  
        v.Size=UDim2.new(1,0,0,22); v.Position=UDim2.new(0,0,1,-22)  
        v.Text="--"; bindTheme(v,"TextColor3","Text"); v.Font=Enum.Font.GothamBold  
        v.TextSize=15; v.TextXAlignment=Enum.TextXAlignment.Left  
        clampText(v,9,15)  
        return v  
    end  
  
    local presetCards={}  
    local activePreset  
    local function presetCard(parent,title,desc,icon,mode,callback)  
        local card=Instance.new("TextButton",parent); card.Size=UDim2.new(1,0,0,50); card.ZIndex=6  
        card.ClipsDescendants=true  
        bindTheme(card,"BackgroundColor3","Card"); card.Text=""; card.AutoButtonColor=false  
        corner(card,11); local cs=stroke(card,Theme.Stroke,1); ripple(card)  
        local ib=Instance.new("Frame",card); ib.Size=UDim2.new(0,32,0,32); ib.Position=UDim2.new(0,9,0.5,-16)  
        ib.ZIndex=7; bindTheme(ib,"BackgroundColor3","CardHover"); corner(ib,8)  
        makeIcon(ib,icon,Theme.Accent).Position=UDim2.new(0.5,-8,0.5,-8)  
        local t=Instance.new("TextLabel",card); t.BackgroundTransparency=1; t.ZIndex=7  
        t.Size=UDim2.new(1,-78,0,15); t.Position=UDim2.new(0,49,0,9)  
        t.Text=title; bindTheme(t,"TextColor3","Text"); t.Font=Enum.Font.GothamBold  
        t.TextSize=11; t.TextXAlignment=Enum.TextXAlignment.Left; t.TextTruncate=Enum.TextTruncate.AtEnd  
        local d=Instance.new("TextLabel",card); d.BackgroundTransparency=1; d.ZIndex=7  
        d.Size=UDim2.new(1,-78,0,11); d.Position=UDim2.new(0,49,0,27)  
        d.Text=desc; bindTheme(d,"TextColor3","SubText"); d.Font=Enum.Font.Gotham  
        d.TextSize=9; d.TextXAlignment=Enum.TextXAlignment.Left; d.TextTruncate=Enum.TextTruncate.AtEnd  
        local check=Instance.new("Frame",card); check.Size=UDim2.new(0,8,0,8); check.ZIndex=8  
        check.Position=UDim2.new(1,-22,0.5,-4); check.BackgroundColor3=Theme.Accent; check.Visible=false; corner(check,999)  
          
        presetCards[mode]=function(on)  
            if on then cs.Color=Theme.Accent; cs.Thickness=1.8; check.Visible=true  
            else cs.Color=Theme.Stroke; cs.Thickness=1; check.Visible=false end  
        end  
        card.MouseEnter:Connect(function() tween(card,0.15,{BackgroundColor3=Theme.CardHover}) end)  
        card.MouseLeave:Connect(function() tween(card,0.15,{BackgroundColor3=Theme.Card}) end)  
        card.MouseButton1Click:Connect(function()  
            if callback then pcall(callback) end  
            for _,fn in pairs(presetCards) do fn(false) end  
            presetCards[mode](true); activePreset=mode  
            notify("FPS Smooth Active ✓", title.." Berhasil diterapkan!", "success", 2.5)  
        end)  
        return card  
    end  
  
    local function sectionTitle(parent,text)  
        local l=Instance.new("TextLabel",parent); l.Size=UDim2.new(1,0,0,14); l.ZIndex=6  
        l.BackgroundTransparency=1; l.Text=text:upper()  
        bindTheme(l,"TextColor3","Accent"); l.Font=Enum.Font.GothamBold  
        l.TextSize=9; l.TextXAlignment=Enum.TextXAlignment.Left; l.TextTruncate=Enum.TextTruncate.AtEnd  
        return l  
    end  
  
    local function toggleRow(parent,label,key,default,onChange)  
        local saved = Settings.toggles[key]  
        if saved==nil then saved=default end  
        local row=Instance.new("Frame",parent); row.Size=UDim2.new(1,0,0,40); row.ZIndex=6  
        row.ClipsDescendants=true  
        bindTheme(row,"BackgroundColor3","Card"); corner(row,10); stroke(row,Theme.Stroke,1)  
        local l=Instance.new("TextLabel",row); l.BackgroundTransparency=1; l.ZIndex=7  
        l.Size=UDim2.new(1,-58,1,0); l.Position=UDim2.new(0,11,0,0)  
        l.Text=label; bindTheme(l,"TextColor3","Text"); l.Font=Enum.Font.GothamSemibold  
        l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left; l.TextTruncate=Enum.TextTruncate.AtEnd  
        local sw=Instance.new("TextButton",row); sw.Size=UDim2.new(0,38,0,20); sw.ZIndex=7  
        sw.Position=UDim2.new(1,-47,0.5,-10); sw.Text=""; sw.AutoButtonColor=false  
        sw.BackgroundColor3=saved and Theme.Accent or Theme.Stroke; corner(sw,999)  
        local knob=Instance.new("Frame",sw); knob.Size=UDim2.new(0,14,0,14); knob.ZIndex=8  
        knob.Position=saved and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)  
        knob.BackgroundColor3=Color3.new(1,1,1); corner(knob,999)  
        local state=saved  
        if onChange then pcall(onChange, state) end  
        sw.MouseButton1Click:Connect(function()  
            state=not state  
            Settings.toggles[key]=state; saveSettings()  
            tween(sw,0.2,{BackgroundColor3=state and Theme.Accent or Theme.Stroke})  
            tween(knob,0.2,{Position=state and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)},Enum.EasingStyle.Back)  
            if onChange then pcall(onChange, state) end  
        end)  
        return row, sw, knob  
    end  
  
    local function actionBtn(parent,text,col,cb)  
        local b=Instance.new("TextButton",parent); b.Size=UDim2.new(1,0,0,38); b.ZIndex=6  
        bindTheme(b,"BackgroundColor3","Card"); b.Text=text; b.TextColor3=col  
        b.Font=Enum.Font.GothamSemibold; b.TextSize=10; b.AutoButtonColor=false  
        b.TextTruncate=Enum.TextTruncate.AtEnd; pad(b,0,0,12,12)  
        corner(b,10); stroke(b,Theme.Stroke,1); ripple(b)  
        b.MouseEnter:Connect(function() tween(b,0.15,{BackgroundColor3=Theme.CardHover}) end)  
        b.MouseLeave:Connect(function() tween(b,0.15,{BackgroundColor3=Theme.Card}) end)  
        if cb then b.MouseButton1Click:Connect(function() pcall(cb) end) end  
        return b  
    end  
  
    -- ===== PAGES =====  
    local dash=newPage("Dashboard")  
    sectionTitle(dash,"System")  
    local grid1=Instance.new("Frame",dash); grid1.Size=UDim2.new(1,0,0,128); grid1.BackgroundTransparency=1; grid1.ZIndex=6  
    local g1=Instance.new("UIGridLayout",grid1); g1.CellSize=UDim2.new(0.5,-3,0,60); g1.CellPadding=UDim2.new(0,6,0,8)  
    local vFPS=statCard(grid1,"FPS"); local vPing=statCard(grid1,"PING"); local vRAM=statCard(grid1,"RAM"); local vMode=statCard(grid1,"MODE")  
    sectionTitle(dash,"Device")  
    local grid2=Instance.new("Frame",dash); grid2.Size=UDim2.new(1,0,0,128); grid2.BackgroundTransparency=1; grid2.ZIndex=6  
    local g2=Instance.new("UIGridLayout",grid2); g2.CellSize=UDim2.new(0.5,-3,0,60); g2.CellPadding=UDim2.new(0,6,0,8)  
    local vGPU=statCard(grid2,"GPU"); local vCPU=statCard(grid2,"COOLING"); local vBat=statCard(grid2,"DEVICE"); local vShadow=statCard(grid2,"SHADOWS")  
    task.spawn(function()  
        while win and win.Parent do  
            vFPS.Text=tostring(fps)  
            if fps >= 50 then vFPS.TextColor3 = Color3.fromRGB(100,255,140)  
            elseif fps >= 30 then vFPS.TextColor3 = Color3.fromRGB(255,200,90)  
            else vFPS.TextColor3 = Color3.fromRGB(255,100,100) end  
            vPing.Text=getPing().." ms"; vRAM.Text=getMem().." MB"; vMode.Text=currentMode  
            vGPU.Text=Lighting.Technology.Name  
            vCPU.Text= coolingLevel==0 and "OFF" or (coolingLevel==1 and "ON ❄" or "MAX ❄")  
            vCPU.TextColor3= coolingActive and Color3.fromRGB(80,200,255) or Theme.Text  
            vBat.Text=isMobile and "Mobile" or "PC"; vShadow.Text=Lighting.GlobalShadows and "ON" or "OFF"  
            task.wait(1)  
        end  
    end)  
  
    -- ===== MOVEMENT PAGE (SLIDER INTERAKTIF & BUTTON SUPER RAPIH + SCROLL LANCAR) =====  
    local mov = newPage("Movement")  
    sectionTitle(mov, "Pro Movement Controls")  
  
    local function createMovementCard(parentPage, titleText, toggleKey, defaultToggle, minV, maxV, initialVal, stepV, presets, onToggle, onSlide)  
        local savedToggle = Settings.toggles[toggleKey]  
        if savedToggle == nil then savedToggle = defaultToggle end  
        local currentVal = initialVal  
  
        local card = Instance.new("Frame", parentPage)  
        card.Size = UDim2.new(1, 0, 0, 134); card.ZIndex = 6  
        bindTheme(card, "BackgroundColor3", "Card"); corner(card, 12); stroke(card, Theme.Stroke, 1)  
  
        -- Top Header Row  
        local topRow = Instance.new("Frame", card)  
        topRow.Size = UDim2.new(1, 0, 0, 36); topRow.BackgroundTransparency = 1; topRow.ZIndex = 7  
          
        local titleLbl = Instance.new("TextLabel", topRow)  
        titleLbl.Size = UDim2.new(1, -60, 1, 0); titleLbl.Position = UDim2.new(0, 12, 0, 0)  
        titleLbl.BackgroundTransparency = 1; titleLbl.Text = titleText  
        bindTheme(titleLbl, "TextColor3", "Text"); titleLbl.Font = Enum.Font.GothamBold; titleLbl.TextSize = 11  
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left  
  
        local sw = Instance.new("TextButton", topRow); sw.Size = UDim2.new(0, 38, 0, 20); sw.ZIndex = 7  
        sw.Position = UDim2.new(1, -48, 0.5, -10); sw.Text = ""; sw.AutoButtonColor = false  
        sw.BackgroundColor3 = savedToggle and Theme.Accent or Theme.Stroke; corner(sw, 999)  
        local knob = Instance.new("Frame", sw); knob.Size = UDim2.new(0, 14, 0, 14); knob.ZIndex = 8  
        knob.Position = savedToggle and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)  
        knob.BackgroundColor3 = Color3.new(1, 1, 1); corner(knob, 999)  
  
        local state = savedToggle  
        if onToggle then pcall(onToggle, state) end  
        sw.MouseButton1Click:Connect(function()  
            state = not state  
            Settings.toggles[toggleKey] = state; saveSettings()  
            tween(sw, 0.2, {BackgroundColor3 = state and Theme.Accent or Theme.Stroke})  
            tween(knob, 0.2, {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)}, Enum.EasingStyle.Back)  
            if onToggle then pcall(onToggle, state) end  
        end)  
  
        -- Interactive Slider Bar ("Slide")  
        local sliderRow = Instance.new("Frame", card)  
        sliderRow.Size = UDim2.new(1, 0, 0, 28); sliderRow.Position = UDim2.new(0, 0, 0, 36)  
        sliderRow.BackgroundTransparency = 1; sliderRow.ZIndex = 7  
  
        local valBadge = Instance.new("TextLabel", sliderRow)  
        valBadge.Size = UDim2.new(0, 75, 1, 0); valBadge.Position = UDim2.new(0, 12, 0, 0)  
        valBadge.BackgroundTransparency = 1; valBadge.Text = "Speed: " .. tostring(currentVal)  
        valBadge.TextColor3 = Theme.Accent; valBadge.Font = Enum.Font.GothamBold; valBadge.TextSize = 10  
        valBadge.TextXAlignment = Enum.TextXAlignment.Left  
  
        local track = Instance.new("Frame", sliderRow)  
        track.Size = UDim2.new(1, -98, 0, 10); track.Position = UDim2.new(0, 86, 0.5, -5)  
        bindTheme(track, "BackgroundColor3", "CardHover"); corner(track, 999); stroke(track, Theme.Stroke, 1); track.ZIndex = 7  
  
        local fill = Instance.new("Frame", track)  
        local initialPct = clamp((currentVal - minV) / (maxV - minV), 0, 1)  
        fill.Size = UDim2.new(initialPct, 0, 1, 0); fill.BackgroundColor3 = Theme.Accent; fill.BorderSizePixel = 0  
        corner(fill, 999); fill.ZIndex = 8  
        gradient(fill, Theme.Accent, Theme.Second, 0)  
  
        local slideDot = Instance.new("Frame", fill)  
        slideDot.Size = UDim2.new(0, 14, 0, 14); slideDot.AnchorPoint = Vector2.new(0.5, 0.5)  
        slideDot.Position = UDim2.new(1, 0, 0.5, 0); slideDot.BackgroundColor3 = Color3.new(1,1,1)  
        corner(slideDot, 999); slideDot.ZIndex = 9  
  
        local function updateSliderVisual(newV)  
            currentVal = clamp(newV, minV, maxV)  
            valBadge.Text = "Speed: " .. tostring(currentVal)  
            local pct = clamp((currentVal - minV) / (maxV - minV), 0, 1)  
            tween(fill, 0.12, {Size = UDim2.new(pct, 0, 1, 0)})  
            onSlide(currentVal)  
        end  
  
        local slideBtn = Instance.new("TextButton", track)  
        slideBtn.Size = UDim2.new(1, 20, 1, 16); slideBtn.Position = UDim2.new(0, -10, 0, -8)  
        slideBtn.BackgroundTransparency = 1; slideBtn.Text = ""; slideBtn.ZIndex = 10  
  
        local isDragging = false  
        slideBtn.InputBegan:Connect(function(input)  
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
                isDragging = true  
                local relX = input.Position.X - track.AbsolutePosition.X  
                local pct = clamp(relX / track.AbsoluteSize.X, 0, 1)  
                updateSliderVisual(math.floor(minV + (maxV - minV) * pct))  
            end  
        end)  
        UserInput.InputChanged:Connect(function(input)  
            if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then  
                local relX = input.Position.X - track.AbsolutePosition.X  
                local pct = clamp(relX / track.AbsoluteSize.X, 0, 1)  
                updateSliderVisual(math.floor(minV + (maxV - minV) * pct))  
            end  
        end)  
        UserInput.InputEnded:Connect(function(input)  
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then  
                isDragging = false  
            end  
        end)  
  
        -- Neat Button Grid Row ("button nya yang rapih")  
        local gridHolder = Instance.new("Frame", card)  
        gridHolder.Size = UDim2.new(1, -20, 0, 56); gridHolder.Position = UDim2.new(0, 10, 0, 68)  
        gridHolder.BackgroundTransparency = 1; gridHolder.ZIndex = 7  
  
        local grid = Instance.new("UIGridLayout", gridHolder)  
        grid.CellSize = UDim2.new(0.333, -4, 0, 24); grid.CellPadding = UDim2.new(0, 6, 0, 6)  
        grid.SortOrder = Enum.SortOrder.LayoutOrder  
  
        local function addPresetBtn(label, color, cb, order)  
            local pb = Instance.new("TextButton", gridHolder)  
            pb.LayoutOrder = order; bindTheme(pb, "BackgroundColor3", "CardHover")  
            pb.Text = label; pb.TextColor3 = color; pb.Font = Enum.Font.GothamBold; pb.TextSize = 9  
            corner(pb, 7); stroke(pb, Theme.Stroke, 1); ripple(pb); pb.ZIndex = 7  
            pb.MouseButton1Click:Connect(function()  
                cb()  
            end)  
            return pb  
        end  
  
        addPresetBtn("-" .. tostring(stepV), Color3.fromRGB(255, 100, 100), function() updateSliderVisual(currentVal - stepV) end, 1)  
        addPresetBtn(presets[1].name, Theme.Accent, function() updateSliderVisual(presets[1].val) end, 2)  
        addPresetBtn("+" .. tostring(stepV), Color3.fromRGB(100, 255, 140), function() updateSliderVisual(currentVal + stepV) end, 3)  
        addPresetBtn(presets[2].name, Theme.Text, function() updateSliderVisual(presets[2].val) end, 4)  
        addPresetBtn(presets[3].name, Theme.Text, function() updateSliderVisual(presets[3].val) end, 5)  
        addPresetBtn(presets[4].name, Theme.Accent, function() updateSliderVisual(presets[4].val) end, 6)  
  
        return card  
    end  
  
    createMovementCard(mov, "Fly Mode (Terbang) 🕊️", "fly", false, 10, 500, flySpeed, 10, {  
        {name="Pelan", val=25}, {name="Normal", val=50}, {name="Cepat", val=120}, {name="Turbo", val=250}  
    }, function(s)  
        setFlyToggle(s)  
    end, function(nV)  
        flySpeed = nV; saveSettings()  
    end)  
  
    createMovementCard(mov, "Kecepatan Lari (WalkSpeed) 🏃", "runspeed", false, 16, 400, runSpeedVal, 10, {  
        {name="Normal", val=16}, {name="Cepat", val=35}, {name="Flash", val=80}, {name="Sonic", val=160}  
    }, function(s)  
        runSpeedActive = s  
        local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")  
        if h then h.WalkSpeed = s and runSpeedVal or 16 end  
        notify("Kecepatan Lari", s and "Kecepatan Lari aktif ("..runSpeedVal..") ✓" or "Normal (16)", "move", 2)  
    end, function(nV)  
        runSpeedVal = nV; saveSettings()  
        if runSpeedActive then  
            local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")  
            if h then h.WalkSpeed = runSpeedVal end  
        end  
    end)  
  
    createMovementCard(mov, "Kecepatan Lompat (Jump Power) 🦘", "jumppower", false, 20, 500, jumpPowerVal, 10, {  
        {name="Normal", val=50}, {name="Tinggi", val=100}, {name="Super", val=180}, {name="Roket", val=300}  
    }, function(s)  
        jumpPowerActive = s  
        local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")  
        if h then  
            if h.UseJumpPower then h.JumpPower = s and jumpPowerVal or 50 else h.JumpHeight = s and jumpPowerVal or 7.2 end  
        end  
    end, function(nV)  
        jumpPowerVal = nV; saveSettings()  
        if jumpPowerActive then  
            local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")  
            if h then  
                if h.UseJumpPower then h.JumpPower = jumpPowerVal else h.JumpHeight = jumpPowerVal end  
            end  
        end  
    end)  
  
    local perf=newPage("Performance")  
    sectionTitle(perf,"Preset Modes (Auto Smooth Active)")  
    presetCard(perf,"Smooth Graphic (Auto)","Balanced smooth processing", "optimize","SMOOTH",applySmooth)  
    presetCard(perf,"Ultra Low Mode","Turbo FPS boost (Ultra)", "fps","ULTRA",applyLowEnd)  
    presetCard(perf,"Max Stable","Frame stabilizer", "performance","MAX",applyMaxStable)  
    presetCard(perf,"Balanced Quality","Full engine visual", "graphics","BALANCED",applyBalanced)  
    presetCard(perf,"Custom Config","Manual user adjustment", "settings","CUSTOM",applyCustom)  
    if presetCards[currentMode] then presetCards[currentMode](true); activePreset=currentMode end  
  
    -- ===== TELEPORT PAGE (UNIVERSAL) =====  
    local tp=newPage("Teleport")  
    sectionTitle(tp,"Universal Teleport (Semua Game)")  
  
    local infoBox=Instance.new("Frame",tp)  
    infoBox.Size=UDim2.new(1,0,0,32); infoBox.ZIndex=6  
    bindTheme(infoBox,"BackgroundColor3","Card"); corner(infoBox,10); stroke(infoBox,Theme.Stroke,1)  
    local infoTxt=Instance.new("TextLabel",infoBox)  
    infoTxt.Size=UDim2.new(1,-16,1,0); infoTxt.Position=UDim2.new(0,10,0,0)  
    infoTxt.BackgroundTransparency=1; infoTxt.Text="Pilih player untuk teleport instan ➤"  
    bindTheme(infoTxt,"TextColor3","SubText"); infoTxt.Font=Enum.Font.GothamMedium; infoTxt.TextSize=9  
    infoTxt.TextXAlignment=Enum.TextXAlignment.Left; infoTxt.ZIndex=7  
  
    local searchBox=Instance.new("Frame",tp)  
    searchBox.Size=UDim2.new(1,0,0,32); searchBox.ZIndex=6  
    bindTheme(searchBox,"BackgroundColor3","Card"); corner(searchBox,10); stroke(searchBox,Theme.Stroke,1)  
    local searchInput=Instance.new("TextBox",searchBox)  
    searchInput.Size=UDim2.new(1,-16,1,0); searchInput.Position=UDim2.new(0,10,0,0)  
    searchInput.BackgroundTransparency=1; searchInput.PlaceholderText="🔍 Cari player..."  
    searchInput.Text=""; searchInput.TextColor3=Theme.Text; searchInput.PlaceholderColor3=Theme.SubText  
    searchInput.Font=Enum.Font.GothamMedium; searchInput.TextSize=10  
    searchInput.TextXAlignment=Enum.TextXAlignment.Left; searchInput.ZIndex=7  
    searchInput.ClearTextOnFocus=false  
  
    local refreshBtn=Instance.new("TextButton",tp)  
    refreshBtn.Size=UDim2.new(1,0,0,32); refreshBtn.ZIndex=6  
    refreshBtn.BackgroundColor3=Theme.Accent; refreshBtn.Text="🔄 Refresh Player List"  
    refreshBtn.TextColor3=Color3.new(1,1,1); refreshBtn.Font=Enum.Font.GothamBold; refreshBtn.TextSize=10  
    refreshBtn.AutoButtonColor=false; corner(refreshBtn,10)  
    gradient(refreshBtn,Theme.Accent,Theme.Second,45); ripple(refreshBtn)  
  
    local listHolder=Instance.new("Frame",tp)  
    listHolder.Size=UDim2.new(1,0,0,240); listHolder.ZIndex=6  
    listHolder.ClipsDescendants=true  
    bindTheme(listHolder,"BackgroundColor3","Card"); corner(listHolder,11); stroke(listHolder,Theme.Stroke,1)  
  
    local listScroll=Instance.new("ScrollingFrame",listHolder)  
    listScroll.Size=UDim2.new(1,-4,1,-4); listScroll.Position=UDim2.new(0,2,0,2)  
    listScroll.BackgroundTransparency=1; listScroll.BorderSizePixel=0  
    listScroll.ScrollBarThickness=3; listScroll.ScrollBarImageColor3=Theme.Accent  
    listScroll.CanvasSize=UDim2.new(0,0,0,0); listScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y  
    listScroll.ScrollingDirection=Enum.ScrollingDirection.Y  
    listScroll.ZIndex=6  
    pad(listScroll,4,4,4,4)  
    local listLayout=Instance.new("UIListLayout",listScroll)  
    listLayout.Padding=UDim.new(0,4); listLayout.SortOrder=Enum.SortOrder.LayoutOrder  
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()  
        listScroll.CanvasSize = UDim2.new(0,0,0, listLayout.AbsoluteContentSize.Y + 20)  
    end)  
  
    local playerRows={}  
    local function clearPlayerList()  
        for _,r in ipairs(playerRows) do  
            if r and r.Parent then r:Destroy() end  
        end  
        playerRows={}  
    end  
  
    local function makePlayerRow(p)  
        local row=Instance.new("TextButton",listScroll)  
        row.Size=UDim2.new(1,0,0,38); row.ZIndex=7  
        row.BackgroundColor3=Theme.CardHover; row.BackgroundTransparency=0.4  
        row.Text=""; row.AutoButtonColor=false; corner(row,8); stroke(row,Theme.Stroke,1); ripple(row)  
  
        local avi=Instance.new("ImageLabel",row)  
        avi.Size=UDim2.new(0,28,0,28); avi.Position=UDim2.new(0,5,0.5,-14)  
        avi.BackgroundColor3=Theme.Card; avi.BackgroundTransparency=0.5; avi.ZIndex=8  
        corner(avi,999)  
        task.spawn(function()  
            local ok, content = pcall(function()  
                return Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)  
            end)  
            if ok and content then avi.Image=content end  
        end)  
  
        local nm=Instance.new("TextLabel",row)  
        nm.Size=UDim2.new(1,-100,0,13); nm.Position=UDim2.new(0,40,0,5)  
        nm.BackgroundTransparency=1; nm.Text=p.DisplayName; nm.TextColor3=Theme.Text  
        nm.Font=Enum.Font.GothamBold; nm.TextSize=10; nm.TextXAlignment=Enum.TextXAlignment.Left  
        nm.TextTruncate=Enum.TextTruncate.AtEnd; nm.ZIndex=8  
  
        local sub=Instance.new("TextLabel",row)  
        sub.Size=UDim2.new(1,-100,0,11); sub.Position=UDim2.new(0,40,0,20)  
        sub.BackgroundTransparency=1; sub.Text="@"..p.Name; sub.TextColor3=Theme.SubText  
        sub.Font=Enum.Font.GothamMedium; sub.TextSize=8; sub.TextXAlignment=Enum.TextXAlignment.Left  
        sub.TextTruncate=Enum.TextTruncate.AtEnd; sub.ZIndex=8  
  
        local distLbl=Instance.new("TextLabel",row)  
        distLbl.Size=UDim2.new(0,50,1,0); distLbl.Position=UDim2.new(1,-55,0,0)  
        distLbl.BackgroundTransparency=1; distLbl.Text="--"; distLbl.TextColor3=Theme.Accent  
        distLbl.Font=Enum.Font.GothamBold; distLbl.TextSize=9  
        distLbl.TextXAlignment=Enum.TextXAlignment.Right; distLbl.ZIndex=8  
  
        task.spawn(function()  
            while row.Parent and p.Parent do  
                local myChar = player.Character  
                local tChar = p.Character  
                if myChar and tChar then  
                    local myR = getRootPart(myChar)  
                    local tR = getRootPart(tChar)  
                    if myR and tR then  
                        local d = math.floor((myR.Position - tR.Position).Magnitude)  
                        distLbl.Text = d.."m"  
                    else  
                        distLbl.Text = "N/A"  
                    end  
                else  
                    distLbl.Text = "N/A"  
                end  
                task.wait(0.3)  
            end  
        end)  
  
        row.MouseEnter:Connect(function() tween(row,0.15,{BackgroundTransparency=0}) end)  
        row.MouseLeave:Connect(function() tween(row,0.15,{BackgroundTransparency=0.4}) end)  
        row.MouseButton1Click:Connect(function()  
            teleportToPlayer(p)  
        end)  
  
        row:SetAttribute("PlayerName", p.Name:lower())  
        row:SetAttribute("DisplayName", p.DisplayName:lower())  
        table.insert(playerRows, row)  
        return row  
    end  
  
    local function rebuildPlayerList()  
        clearPlayerList()  
        local count = 0  
        for _, p in ipairs(Players:GetPlayers()) do  
            if p ~= player then  
                makePlayerRow(p)  
                count = count + 1  
            end  
        end  
        if count == 0 then  
            local empty=Instance.new("TextLabel",listScroll)  
            empty.Size=UDim2.new(1,0,0,60); empty.BackgroundTransparency=1  
            empty.Text="Tidak ada player lain di server."; empty.TextColor3=Theme.SubText  
            empty.Font=Enum.Font.GothamMedium; empty.TextSize=10; empty.ZIndex=7  
            table.insert(playerRows, empty)  
        end  
        infoTxt.Text="Total player: "..count.." • Klik untuk teleport ➤"  
    end  
  
    local function filterList(query)  
        query = query:lower()  
        for _, row in ipairs(playerRows) do  
            if row:IsA("TextButton") then  
                local pn = row:GetAttribute("PlayerName") or ""  
                local dn = row:GetAttribute("DisplayName") or ""  
                if query == "" or pn:find(query, 1, true) or dn:find(query, 1, true) then  
                    row.Visible = true  
                else  
                    row.Visible = false  
                end  
            end  
        end  
    end  
  
    searchInput:GetPropertyChangedSignal("Text"):Connect(function()  
        filterList(searchInput.Text)  
    end)  
  
    refreshBtn.MouseButton1Click:Connect(function()  
        rebuildPlayerList()  
        notify("Player List Refreshed", "List player berhasil diperbarui!", "success", 2)  
    end)  
  
    Players.PlayerAdded:Connect(function() task.wait(0.5); pcall(rebuildPlayerList) end)  
    Players.PlayerRemoving:Connect(function() task.wait(0.3); pcall(rebuildPlayerList) end)  
  
    task.defer(rebuildPlayerList)  
  
    sectionTitle(tp,"Quick Actions")  
    actionBtn(tp,"⚡ Teleport ke Player Terdekat",Color3.fromRGB(180,120,255),function()  
        local myChar = player.Character  
        if not myChar then return end  
        local myR = getRootPart(myChar)  
        if not myR then return end  
        local closest, dist = nil, math.huge  
        for _, p in ipairs(Players:GetPlayers()) do  
            if p ~= player and p.Character then  
                local tR = getRootPart(p.Character)  
                if tR then  
                    local d = (myR.Position - tR.Position).Magnitude  
                    if d < dist then dist = d; closest = p end  
                end  
            end  
        end  
        if closest then teleportToPlayer(closest)  
        else notify("Tidak ada target", "Player lain tidak ditemukan.", "warn", 3) end  
    end)  
  
    -- COOLING PAGE  
    local coolPage=newPage("Cooling")  
    sectionTitle(coolPage,"Anti Overheat Engine")  
    local coolPreset={}  
    local function coolCard(parent,title,desc,lvl)  
        local card=Instance.new("TextButton",parent); card.Size=UDim2.new(1,0,0,52); card.ZIndex=6  
        card.ClipsDescendants=true  
        bindTheme(card,"BackgroundColor3","Card"); card.Text=""; card.AutoButtonColor=false  
        corner(card,11); local cs=stroke(card,Theme.Stroke,1); ripple(card)  
        local ib=Instance.new("Frame",card); ib.Size=UDim2.new(0,34,0,34); ib.Position=UDim2.new(0,9,0.5,-17)  
        ib.ZIndex=7; ib.BackgroundColor3=Color3.fromRGB(20,80,120); corner(ib,9)  
        makeIcon(ib,"cooling",Color3.fromRGB(80,200,255)).Position=UDim2.new(0.5,-8,0.5,-8)  
        local t=Instance.new("TextLabel",card); t.BackgroundTransparency=1; t.ZIndex=7  
        t.Size=UDim2.new(1,-80,0,15); t.Position=UDim2.new(0,51,0,10)  
        t.Text=title; bindTheme(t,"TextColor3","Text"); t.Font=Enum.Font.GothamBold  
        t.TextSize=11; t.TextXAlignment=Enum.TextXAlignment.Left; t.TextTruncate=Enum.TextTruncate.AtEnd  
        local d=Instance.new("TextLabel",card); d.BackgroundTransparency=1; d.ZIndex=7  
        d.Size=UDim2.new(1,-80,0,11); d.Position=UDim2.new(0,51,0,28)  
        d.Text=desc; bindTheme(d,"TextColor3","SubText"); d.Font=Enum.Font.Gotham  
        d.TextSize=9; d.TextXAlignment=Enum.TextXAlignment.Left; d.TextTruncate=Enum.TextTruncate.AtEnd  
        local check=Instance.new("Frame",card); check.Size=UDim2.new(0,8,0,8); check.ZIndex=8  
        check.Position=UDim2.new(1,-22,0.5,-4); check.BackgroundColor3=Color3.fromRGB(80,200,255); check.Visible=false; corner(check,999)  
        coolPreset[lvl]=function(on)  
            if on then cs.Color=Color3.fromRGB(80,200,255); cs.Thickness=1.8; check.Visible=true  
            else cs.Color=Theme.Stroke; cs.Thickness=1; check.Visible=false end  
        end  
        card.MouseEnter:Connect(function() tween(card,0.15,{BackgroundColor3=Theme.CardHover}) end)  
        card.MouseLeave:Connect(function() tween(card,0.15,{BackgroundColor3=Theme.Card}) end)  
        card.MouseButton1Click:Connect(function()  
            enableCooling(lvl)  
            for _,fn in pairs(coolPreset) do fn(false) end  
            coolPreset[lvl](true)  
        end)  
        return card  
    end  
    coolCard(coolPage,"Cooling OFF","Performa penuh (normal)",0)  
    coolCard(coolPage,"Cooling Normal ❄","FPS 30 • hemat baterai",1)  
    coolCard(coolPage,"Cooling MAX ❄❄","FPS 24 • anti panas maksimal",2)  
    if coolPreset[coolingLevel] then coolPreset[coolingLevel](true) end  
    sectionTitle(coolPage,"Auto Protection")  
    toggleRow(coolPage,"Auto Clear Effects","autoclear",false,function(s)  
        if s then for _,v in ipairs(Workspace:GetDescendants()) do pcall(removeEffects, v) end end  
    end)  
    toggleRow(coolPage,"Hemat Baterai","battsave",false,function(s)  
        if s then setFPSCap(30) else if not coolingActive then setFPSCap(60) end end  
    end)  
  
    -- GRAPHICS & VISION PAGE  
    local gfx=newPage("Graphics")  
    sectionTitle(gfx,"Vision & FE Invisible")  
    toggleRow(gfx,"FE Invisible Character 👻","invisible",false,function(s)  
        pcall(toggleInvisible, s)  
    end)  
    toggleRow(gfx,"Night Vision / Fullbright 🌙","nightvision",false,function(s)  
        pcall(toggleNightVision, s)  
    end)  
    toggleRow(gfx,"Name Tags + Jarak Live","nametags",true,function(s)  
        pcall(refreshAllCharacterTags)  
        notify("Name Tags", s and "Name Tag + Jarak Live diaktifkan ✓" or "Name Tag dimatikan", "info", 2)  
    end)  
    toggleRow(gfx,"Weapon Red Highlight","weaponhighlight",true,function(s)  
        pcall(refreshAllCharacterTags)  
        notify("Weapon ESP", s and "Sorotan Senjata diaktifkan ✓" or "Sorotan Senjata dimatikan", "info", 2)  
    end)  
  
    sectionTitle(gfx,"Graphic Engine Options")  
    toggleRow(gfx,"Global Shadows","shadows",false,function(s) if not nightVisionActive then Lighting.GlobalShadows=s end end)  
    toggleRow(gfx,"Future Lighting","futurelight",false,function(s) Lighting.Technology=s and Enum.Technology.Future or Enum.Technology.Compatibility end)  
    toggleRow(gfx,"Fog Effect","fog",true,function(s) if not nightVisionActive then Lighting.FogEnd=s and 5000 or 1000 end end)  
    toggleRow(gfx,"Disable Particles","noparticle",false,function(s)  
        for _,v in ipairs(Workspace:GetDescendants()) do  
            if v:IsA("ParticleEmitter") or v:IsA("Trail") then pcall(function() v.Enabled=not s end) end  
        end  
    end)  
  
    local fpsb=newPage("FPS Boost")  
    sectionTitle(fpsb,"Quick Hyper Boost (100% Working)")  
    presetCard(fpsb,"Clear Engine Effects","Remove environment particles instantly","fps","CLEAR",function()  
        for _,v in ipairs(Workspace:GetDescendants()) do pcall(removeEffects, v) end  
    end)  
    presetCard(fpsb,"Smooth Plastic Mode","Convert environment materials to smooth-plastic","optimize","TEX",function()  
        for _,v in ipairs(Workspace:GetDescendants()) do   
            pcall(function()  
                if player.Character and v:IsDescendantOf(player.Character) then return end  
                if v:IsA("BasePart") then v.Material=Enum.Material.SmoothPlastic; v.CastShadow=false end  
            end)  
        end  
    end)  
    presetCard(fpsb,"Max Performance Now","Low engine latency & high FPS boost","performance","MAXFPS",applyLowEnd)  
  
    local opt=newPage("Optimize")  
    sectionTitle(opt,"Auto Optimizer & Anti-AFK")  
    toggleRow(opt,"FPS Guard (Anti-Farm Lag)","fpsguard",true,function(s)  
        notify("FPS Guard", s and "Pertahanan FPS Aktif ✓" or "FPS Guard Dimatikan", "info", 2)  
    end)  
    toggleRow(opt,"Anti-AFK (Klik 5 Min)","antiafk",true,function(s)  
        notify("Anti-AFK", s and "Anti-AFK 5 Menit diaktifkan ✓" or "Anti-AFK dimatikan", "info", 2)  
    end)  
    toggleRow(opt,"Disable Water Render","nowater",true,function(s)  
        local T=Workspace:FindFirstChildOfClass("Terrain")  
        if T then T.WaterWaveSize=s and 0 or 0.15; T.WaterWaveSpeed=s and 0 or 10 end  
    end)  
    toggleRow(opt,"Low Quality Mode","lowqual",true,function(s)  
        pcall(function() settings().Rendering.QualityLevel=s and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic end)  
    end)  
  
    local net=newPage("Network")  
    sectionTitle(net,"Connection")  
    local netGrid=Instance.new("Frame",net); netGrid.Size=UDim2.new(1,0,0,128); netGrid.BackgroundTransparency=1; netGrid.ZIndex=6  
    local ng=Instance.new("UIGridLayout",netGrid); ng.CellSize=UDim2.new(0.5,-3,0,60); ng.CellPadding=UDim2.new(0,6,0,8)  
    local nPing=statCard(netGrid,"PING"); local nSent=statCard(netGrid,"SENT"); local nRecv=statCard(netGrid,"RECV"); local nStat=statCard(netGrid,"STATUS")  
    task.spawn(function()  
        while win and win.Parent do  
            nPing.Text=getPing().." ms"  
            pcall(function() nSent.Text=math.floor(Stats.DataSendKbps).." kb" end)  
            pcall(function() nRecv.Text=math.floor(Stats.DataReceiveKbps).." kb" end)  
            nStat.Text="Online"; nStat.TextColor3=Color3.fromRGB(100,255,140); task.wait(1)  
        end  
    end)  
  
    local set=newPage("Settings")  
    sectionTitle(set,"Theme Selection")  
    local themeRow=Instance.new("Frame",set); themeRow.Size=UDim2.new(1,0,0,36); themeRow.BackgroundTransparency=1; themeRow.ZIndex=6  
    local thL=Instance.new("UIListLayout",themeRow); thL.FillDirection=Enum.FillDirection.Horizontal; thL.Padding=UDim.new(0,5)  
    local function themeBtn(name)  
        local b=Instance.new("TextButton",themeRow); b.Size=UDim2.new(0.333,-4,1,0); b.ZIndex=7  
        bindTheme(b,"BackgroundColor3","Card"); b.Text=name; bindTheme(b,"TextColor3","Text")  
        b.Font=Enum.Font.GothamSemibold; b.TextSize=10; b.AutoButtonColor=false; b.TextTruncate=Enum.TextTruncate.AtEnd  
        corner(b,8); stroke(b,Theme.Stroke,1); ripple(b)  
        b.MouseButton1Click:Connect(function() applyTheme(name); notify("Theme Changed","Tema "..name.." disimpan","info",2) end)  
    end  
    themeBtn("Dark"); themeBtn("Neon"); themeBtn("Light")  
      
    sectionTitle(set,"Configuration")  
    actionBtn(set,"Bersihkan Blok / Box Karakter Sekarang",Color3.fromRGB(0,255,204),function()  
        pcall(refreshAllCharacterTags)  
        notify("Anti-Block","Semua blok di karakter berhasil dihapus!","success",3)  
    end)  
    actionBtn(set,"Re-Apply Auto Smooth",Color3.fromRGB(100,255,140),function()  
        applySmooth()  
        notify("Smooth Applied","Grafik di-smooth-kan ulang!","success",3)  
    end)  
    actionBtn(set,"Reset Default Settings",Color3.fromRGB(255,120,120),function()  
        Settings={mode="SMOOTH",cooling=0,theme="Dark",toggles={nametags=true, weaponhighlight=true, nightvision=false, antiafk=true, fpsguard=true, invisible=false, fly=false, runspeed=false, jumppower=false}, flySpeed=50, runSpeed=35, jumpPower=80}; saveSettings()  
        flySpeed=50; runSpeedVal=35; jumpPowerVal=80  
        applySmooth(); enableCooling(0,true); toggleNightVision(false); toggleInvisible(false); setFlyToggle(false); refreshAllCharacterTags(); notify("Reset","Pengaturan direset ke bawaan","info",2)  
    end)  
  
    -- ABOUT (PP OWNER MENGGUNAKAN PP ROBLOX RESMI OWNER)  
    local about=newPage("About")  
    local profile=Instance.new("Frame",about); profile.Size=UDim2.new(1,0,0,96); profile.ZIndex=6  
    profile.ClipsDescendants=true  
    bindTheme(profile,"BackgroundColor3","Card"); corner(profile,12); stroke(profile,Theme.Stroke,1)  
    gradient(profile, Color3.fromRGB(40,24,78), Color3.fromRGB(20,14,42), 115)  
      
    local pAvatar=Instance.new("ImageLabel",profile); pAvatar.Size=UDim2.new(0,54,0,54); pAvatar.ZIndex=7  
    pAvatar.Position=UDim2.new(0,12,0,12); pAvatar.BackgroundTransparency=1; pAvatar.Image=LOGO_ID; corner(pAvatar,10)  
    stroke(pAvatar,Theme.Accent,1.5)  
  
    task.spawn(function()  
        local okThumb, thumbUrl = pcall(function()  
            return Players:GetUserThumbnailAsync(OWNER_ROBLOX_ID, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)  
        end)  
        if okThumb and thumbUrl then  
            pAvatar.Image = thumbUrl  
        end  
    end)  
      
    local pName=Instance.new("TextLabel",profile); pName.BackgroundTransparency=1; pName.ZIndex=7  
    pName.Size=UDim2.new(1,-80,0,17); pName.Position=UDim2.new(0,74,0,15)  
    pName.Text="mamam5327 (Nopall)"; bindTheme(pName,"TextColor3","Text"); pName.Font=Enum.Font.GothamBold  
    pName.TextSize=14; pName.TextXAlignment=Enum.TextXAlignment.Left; pName.TextTruncate=Enum.TextTruncate.AtEnd  
      
    local pRole=Instance.new("TextLabel",profile); pRole.BackgroundTransparency=1; pRole.ZIndex=7  
    pRole.Size=UDim2.new(1,-80,0,13); pRole.Position=UDim2.new(0,74,0,34)  
    pRole.Text="Developer & Owner"; bindTheme(pRole,"TextColor3","Accent"); pRole.Font=Enum.Font.GothamMedium  
    pRole.TextSize=10; pRole.TextXAlignment=Enum.TextXAlignment.Left; pRole.TextTruncate=Enum.TextTruncate.AtEnd  
      
    local badge=Instance.new("Frame",profile); badge.Size=UDim2.new(0,60,0,19); badge.ZIndex=7  
    badge.Position=UDim2.new(0,74,0,54); badge.BackgroundColor3=Color3.fromRGB(20,60,40); corner(badge,999)  
    local odot=Instance.new("Frame",badge); odot.Size=UDim2.new(0,6,0,6); odot.Position=UDim2.new(0,8,0.5,-3); odot.ZIndex=8  
    odot.BackgroundColor3=Color3.fromRGB(80,255,140); odot.BorderSizePixel=0; corner(odot,999)  
    local bTxt=Instance.new("TextLabel",badge); bTxt.BackgroundTransparency=1; bTxt.ZIndex=8  
    bTxt.Size=UDim2.new(1,-18,1,0); bTxt.Position=UDim2.new(0,17,0,0); bTxt.Text="Online"  
    bTxt.TextColor3=Color3.fromRGB(80,255,140); bTxt.Font=Enum.Font.GothamSemibold; bTxt.TextSize=9  
    bTxt.TextXAlignment=Enum.TextXAlignment.Left  
    task.spawn(function()  
        while badge.Parent do tween(odot,0.7,{BackgroundTransparency=0.6}); task.wait(0.7); tween(odot,0.7,{BackgroundTransparency=0}); task.wait(0.7) end  
    end)  
  
    local function contactBtn(parent, label, value, accent, action)  
        local b=Instance.new("TextButton",parent); b.Size=UDim2.new(1,0,0,44); b.ZIndex=6  
        b.ClipsDescendants=true  
        bindTheme(b,"BackgroundColor3","Card"); b.Text=""; b.AutoButtonColor=false  
        corner(b,10); stroke(b,Theme.Stroke,1); ripple(b)  
        local ib=Instance.new("Frame",b); ib.Size=UDim2.new(0,30,0,30); ib.Position=UDim2.new(0,9,0.5,-15); ib.ZIndex=7  
        ib.BackgroundColor3=accent; corner(ib,8)  
        local ic=Instance.new("TextLabel",ib); ic.BackgroundTransparency=1; ic.Size=UDim2.new(1,0,1,0); ic.ZIndex=8  
        ic.Text=string.sub(label,1,1); ic.TextColor3=Color3.new(1,1,1); ic.Font=Enum.Font.GothamBold; ic.TextSize=14  
        local t=Instance.new("TextLabel",b); t.BackgroundTransparency=1; t.ZIndex=7  
        t.Size=UDim2.new(1,-72,0,15); t.Position=UDim2.new(0,47,0,8)  
        t.Text=label; bindTheme(t,"TextColor3","Text"); t.Font=Enum.Font.GothamBold  
        t.TextSize=11; t.TextXAlignment=Enum.TextXAlignment.Left; t.TextTruncate=Enum.TextTruncate.AtEnd  
        local d=Instance.new("TextLabel",b); d.BackgroundTransparency=1; d.ZIndex=7  
        d.Size=UDim2.new(1,-72,0,12); d.Position=UDim2.new(0,47,0,24)  
        d.Text=value; bindTheme(d,"TextColor3","SubText"); d.Font=Enum.Font.Gotham  
        d.TextSize=9; d.TextXAlignment=Enum.TextXAlignment.Left; d.TextTruncate=Enum.TextTruncate.AtEnd  
        local arrow=Instance.new("TextLabel",b); arrow.BackgroundTransparency=1; arrow.ZIndex=7  
        arrow.Size=UDim2.new(0,14,1,0); arrow.Position=UDim2.new(1,-20,0,0); arrow.Text="›"  
        arrow.TextColor3=accent; arrow.Font=Enum.Font.GothamBold; arrow.TextSize=19  
        b.MouseEnter:Connect(function() tween(b,0.15,{BackgroundColor3=Theme.CardHover}) end)  
        b.MouseLeave:Connect(function() tween(b,0.15,{BackgroundColor3=Theme.Card}) end)  
        b.MouseButton1Click:Connect(function() pcall(action) end)  
        return b  
    end  
  
    local function openWithNotif(url, appName)  
        local ok = openLink(url)  
        if ok then  
            notify(appName.." 🌐", "Membuka "..appName.." otomatis...", "success", 3)  
        else  
            notify("Link Disalin ✓", "Executor tidak support auto-open. Link sudah disalin, paste di Chrome!", "info", 4)  
        end  
    end  
  
    sectionTitle(about,"Contact Owner")  
    local waNum=OWNER_NUMBER:gsub("[^%d]","")  
    contactBtn(about,"WhatsApp",OWNER_NUMBER,Color3.fromRGB(37,211,102),function() openWithNotif("https://wa.me/"..waNum, "WhatsApp") end)  
    contactBtn(about,"Join Saluran","Klik untuk gabung info terbaru",Color3.fromRGB(123,97,255),function() openWithNotif(GETKEY_LINK, "Saluran WhatsApp") end)  
    contactBtn(about,"Copy Number",OWNER_NUMBER,Color3.fromRGB(255,77,255),function() pcall(setclipboard,OWNER_NUMBER); notify("Disalin","Nomor owner disalin!","success",2) end)  
    contactBtn(about,"Telegram","Saluran Official Telegram",Color3.fromRGB(40,160,235),function() openWithNotif(TELEGRAM_LINK, "Telegram") end)  
    contactBtn(about,"Discord","Hubungi Support Server",Color3.fromRGB(88,101,242),function() openWithNotif(DISCORD_LINK, "Discord") end)  
      
    sectionTitle(about,"Support Developer")  
    contactBtn(about,"Donate Robux 💰","Klik untuk donasi Robux",Color3.fromRGB(255,215,0),function()   
        openWithNotif(DONATE_LINK, "Halaman Donasi")  
        notify("Donate","Terima kasih atas dukungan Anda! ❤️","vip",3)   
    end)  
  
    sectionTitle(about,"Hub Info")  
    local infoGrid=Instance.new("Frame",about); infoGrid.Size=UDim2.new(1,0,0,128); infoGrid.BackgroundTransparency=1; infoGrid.ZIndex=6  
    local ig=Instance.new("UIGridLayout",infoGrid); ig.CellSize=UDim2.new(0.5,-3,0,60); ig.CellPadding=UDim2.new(0,6,0,8)  
    local function infoCard(title,val) local v=statCard(infoGrid,title); v.Text=val; return v end  
    infoCard("VERSION",HUB_VERSION); infoCard("EDITION","Ultimate Pro Edition")  
    infoCard("YEAR","2026"); infoCard("STATUS","Active")  
  
    local footer=Instance.new("TextLabel",about); footer.Size=UDim2.new(1,0,0,32); footer.ZIndex=6  
    footer.BackgroundTransparency=1; footer.Text="© 2026 PalRyz HUB · All Rights Reserved\nMade with ♥ by Noval"  
    bindTheme(footer,"TextColor3","SubText"); footer.Font=Enum.Font.Gotham; footer.TextSize=8; footer.TextWrapped=true  
  
    -- BUILD SIDEBAR ITEMS  
    navItem("Dashboard","dashboard",1)  
    navItem("Movement","movement",2)  
    navItem("Performance","performance",3)  
    navItem("Teleport","teleport",4)  
    navItem("Cooling","cooling",5); navItem("Graphics","graphics",6)  
    navItem("FPS Boost","fps",7); navItem("Optimize","optimize",8)  
    navItem("Network","network",9); navItem("Settings","settings",10)  
    navItem("About","about",11)  
  
    do  
        local b=navButtons["Dashboard"]  
        b.BackgroundTransparency=0; b.BackgroundColor3=Theme.CardHover  
        b.lbl.TextColor3=Theme.Text; b.sel.Visible=true  
        showPage("Dashboard")  
    end  
  
    bellBtn.MouseButton1Click:Connect(function()  
        notifDot.Visible=false  
        notify("Pusat Notifikasi","Semua sistem dalam keadaan aman & lancar!","info",3)  
    end)  
  
    -- UNIVERSAL DYNAMIC SCROLL UPDATER (MENJAMIN SEMUA MENU BISA DI-SCROLL PADA SEMUA EXECUTOR)  
    task.spawn(function()  
        while win and win.Parent do  
            for _, p in pairs(pages) do  
                if p.Visible then  
                    local l = p:FindFirstChildOfClass("UIListLayout")  
                    if l then p.CanvasSize = UDim2.new(0, 0, 0, l.AbsoluteContentSize.Y + 45) end  
                end  
            end  
            local sl = sScroll:FindFirstChildOfClass("UIListLayout")  
            if sl then sScroll.CanvasSize = UDim2.new(0, 0, 0, sl.AbsoluteContentSize.Y + 32) end  
            local ll = listScroll:FindFirstChildOfClass("UIListLayout")  
            if ll then listScroll.CanvasSize = UDim2.new(0, 0, 0, ll.AbsoluteContentSize.Y + 25) end  
            task.wait(0.4)  
        end  
    end)  
  
    -- COLLAPSE SYSTEM  
    local collapsed=false  
    sideToggle.MouseButton1Click:Connect(function()  
        collapsed=not collapsed  
        if collapsed then  
            tween(sidebar,0.25,{Size=UDim2.new(0,40,1,-66)},Enum.EasingStyle.Quint)  
            tween(content,0.25,{Size=UDim2.new(1,-72,1,-66),Position=UDim2.new(0,60,0,60)},Enum.EasingStyle.Quint)  
            for _,b in pairs(navButtons) do b.lbl.Visible=false end  
        else  
            tween(sidebar,0.25,{Size=UDim2.new(0,SIDE_W,1,-66)},Enum.EasingStyle.Quint)  
            tween(content,0.25,{Size=UDim2.new(1,-SIDE_W-28,1,-66),Position=UDim2.new(0,SIDE_W+19,0,60)},Enum.EasingStyle.Quint)  
            task.delay(0.15,function() for _,b in pairs(navButtons) do b.lbl.Visible=true end end)  
        end  
    end)  
  
    -- MINIMIZE SYSTEM  
    local minimized=false  
    minBtn.MouseButton1Click:Connect(function()  
        minimized=not minimized  
        if minimized then  
            sidebar.Visible=false; content.Visible=false; divider.Visible=false  
            tween(win,0.25,{Size=UDim2.new(0,WIN_W,0,56)},Enum.EasingStyle.Quint)  
        else  
            tween(win,0.25,{Size=UDim2.new(0,WIN_W,0,WIN_H)},Enum.EasingStyle.Quint)  
            task.delay(0.15,function() sidebar.Visible=true; content.Visible=true; divider.Visible=true end)  
        end  
    end)  
  
    -- WIN TOGGLE OPEN / CLOSE  
    local function openWin()  
        win.Visible=true  
        win.Size=UDim2.new(0,WIN_W*0.9,0,WIN_H*0.9)  
        tween(win,0.35,{Size=UDim2.new(0,WIN_W,0,WIN_H)},Enum.EasingStyle.Back)  
    end  
    local function closeWin()  
        tween(win,0.22,{Size=UDim2.new(0,WIN_W*0.9,0,WIN_H*0.9)})  
        task.delay(0.22,function() win.Visible=false end)  
        notify("Hub Disembunyikan","Optimizer & Anti-AFK tetap berjalan!","info",3)  
    end  
    closeBtn.MouseButton1Click:Connect(closeWin)  
    toggleBtn.MouseButton1Click:Connect(function()  
        if win.Visible then closeWin() else openWin() end  
    end)  
  
    openWin()  
  
    -- ================== COMPACT TOP FPS WIDGET ==================  
    local fpsGui=Instance.new("ScreenGui",player:WaitForChild("PlayerGui"))  
    fpsGui.Name="PalRyzFPS"; fpsGui.ResetOnSpawn=false; fpsGui.DisplayOrder=95  
    fpsGui.IgnoreGuiInset=true  
  
    local fpsFrame=Instance.new("Frame",fpsGui)  
    fpsFrame.Size=UDim2.new(0,118,0,22)  
    fpsFrame.Position=UDim2.new(1,-128,0,4)  
    fpsFrame.BackgroundColor3=Theme.Card  
    fpsFrame.BorderSizePixel=0  
    corner(fpsFrame,999)  
    local fpsStroke=stroke(fpsFrame,Theme.Accent,1)  
    fpsStroke.Transparency=0.3  
    gradient(fpsFrame, Color3.fromRGB(24, 16, 48), Color3.fromRGB(12, 8, 24), 135)  
  
    local fpsDot=Instance.new("Frame",fpsFrame)  
    fpsDot.Size=UDim2.new(0,5,0,5)  
    fpsDot.Position=UDim2.new(0,8,0.5,-2.5)  
    fpsDot.BackgroundColor3=Color3.fromRGB(100,255,140)  
    fpsDot.BorderSizePixel=0  
    corner(fpsDot,999)  
  
    local fpsLabel=Instance.new("TextLabel",fpsFrame)  
    fpsLabel.Size=UDim2.new(1,-18,1,0)  
    fpsLabel.Position=UDim2.new(0,17,0,0)  
    fpsLabel.BackgroundTransparency=1  
    fpsLabel.TextColor3=Theme.Text  
    fpsLabel.Font=Enum.Font.GothamBold  
    fpsLabel.TextSize=9  
    fpsLabel.TextXAlignment=Enum.TextXAlignment.Left  
  
    task.spawn(function()  
        while fpsGui.Parent do  
            local statusColor = Color3.fromRGB(100,255,140)  
            if fps < 30 then statusColor = Color3.fromRGB(255,90,100)  
            elseif fps < 50 then statusColor = Color3.fromRGB(255,200,90) end  
            local cpuMs = math.floor((1 / math.max(fps, 1)) * 1000)  
            fpsDot.BackgroundColor3 = statusColor  
            fpsLabel.Text = string.format("%s%d FPS · %dms", (coolingActive and "❄ " or ""), fps, cpuMs)  
            fpsLabel.TextColor3 = Theme.Text  
            task.wait(0.5)  
        end  
    end)  
end  
  
-- ================== INIT ENGINE ==================  
loadSettings()  
currentMode  = Settings.mode or "SMOOTH"  
currentTheme = Settings.theme or "Dark"  
Theme = Themes[currentTheme] or Themes.Dark  
  
task.defer(function()  
    pcall(function() applyModeByName(currentMode) end)  
    if (Settings.cooling or 0) > 0 then pcall(enableCooling, Settings.cooling, true) end  
    if Settings.toggles["nightvision"] then pcall(toggleNightVision, true) end  
    if Settings.toggles["invisible"] then pcall(toggleInvisible, true) end  
    if Settings.toggles["fly"] then pcall(setFlyToggle, true) end  
    task.wait(1)  
    pcall(refreshAllCharacterTags)  
end)  
  
-- FOLLOW CHECK: Langsung bypass, gak perlu cek API Roblox!
-- Hub langsung kebuka tanpa modal follow.
showLoadingOverlay(function()  
    loadMainGUI()  
    showWelcomeNotifs()  
end)

-- ============================================================
-- ZALER EXPLORER v1.0 - Full Dex-like Explorer
-- รันผ่าน Delta Executor บน Android
-- ============================================================

local Players         = game:GetService("Players")
local RunService      = game:GetService("RunService")
local TweenService    = game:GetService("TweenService")
local UserInputService= game:GetService("UserInputService")
local HttpService     = game:GetService("HttpService")
local LocalPlayer     = Players.LocalPlayer

-- ============================================================
-- COLORS
-- ============================================================
local C = {
    BG        = Color3.fromRGB(24,24,28),
    Panel     = Color3.fromRGB(30,30,36),
    Header    = Color3.fromRGB(36,36,44),
    Row       = Color3.fromRGB(30,30,36),
    RowAlt    = Color3.fromRGB(28,28,34),
    RowSel    = Color3.fromRGB(30,60,130),
    RowHov    = Color3.fromRGB(40,40,52),
    Border    = Color3.fromRGB(50,50,65),
    Text      = Color3.fromRGB(220,220,228),
    Dim       = Color3.fromRGB(130,130,150),
    Yellow    = Color3.fromRGB(255,210,80),
    Cyan      = Color3.fromRGB(86,210,255),
    Green     = Color3.fromRGB(90,220,130),
    Red       = Color3.fromRGB(255,90,90),
    Orange    = Color3.fromRGB(255,165,60),
    Purple    = Color3.fromRGB(180,120,255),
    Blue      = Color3.fromRGB(80,140,255),
    White     = Color3.new(1,1,1),
}

-- ============================================================
-- ICONS
-- ============================================================
local CI = {
    Workspace="🌍", Model="📦", Part="🧱", MeshPart="🔷",
    UnionOperation="🔶", SpecialMesh="🔷", Script="📜",
    LocalScript="📋", ModuleScript="📂", Humanoid="🚶",
    HumanoidRootPart="⬛", Tool="🔧", RemoteEvent="📡",
    RemoteFunction="📡", BindableEvent="🔗", BindableFunction="🔗",
    StringValue="🔤", IntValue="🔢", NumberValue="🔢",
    BoolValue="✅", ObjectValue="🔗", CFrameValue="📐",
    Vector3Value="📐", Color3Value="🎨", Frame="▭",
    TextLabel="🏷", TextButton="🔘", TextBox="📝",
    ImageLabel="🖼", ImageButton="🖼", ScreenGui="🖥",
    SurfaceGui="📺", BillboardGui="📌", Sound="🔊",
    Lighting="💡", Atmosphere="🌫", Sky="🌌", Camera="📷",
    Folder="📁", Configuration="⚙️", Animator="🎬",
    Animation="🎞", Motor6D="⚙️", WeldConstraint="🔩",
    Highlight="✨", SelectionBox="📐", ParticleEmitter="✨",
    Fire="🔥", Smoke="💨", Sparkles="⭐", PointLight="💡",
    SpotLight="🔦", SurfaceLight="💡", Players="👥",
    ReplicatedStorage="🗄", ServerStorage="🗄", StarterGui="🖥",
    StarterPack="🎒", StarterPlayer="👤", Teams="🏁",
    SoundService="🔊", RunService="▶️", Beam="✦",
    BodyVelocity="💨", BodyPosition="📍", BodyGyro="🔄",
    LineForce="⚡", VectorForce="⚡", Torque="🌀",
    DEFAULT="▸",
}

local function getIcon(obj)
    return CI[obj.ClassName] or CI.DEFAULT
end

local function getClassColor(cn)
    if cn:find("Script") then return C.Yellow
    elseif cn:find("Remote") or cn:find("Bindable") then return C.Orange
    elseif cn:find("Value") then return C.Green
    elseif cn:find("Gui") or cn:find("Frame") or cn:find("Label") or cn:find("Button") or cn:find("Box") then return C.Purple
    elseif cn:find("Part") or cn=="Model" or cn=="UnionOperation" then return C.Cyan
    elseif cn=="Humanoid" or cn=="Animator" then return C.Red
    elseif cn:find("Light") or cn=="Sound" or cn=="Atmosphere" or cn=="Sky" then return C.Orange
    elseif cn=="Folder" or cn=="Configuration" then return Color3.fromRGB(200,200,140)
    else return C.Text end
end

-- ============================================================
-- ROOT GUI
-- ============================================================
local Gui = Instance.new("ScreenGui")
Gui.Name = "ZalerExplorer"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset = true
local ok = pcall(function() Gui.Parent = game:GetService("CoreGui") end)
if not ok then Gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ============================================================
-- MAIN WINDOW
-- ============================================================
local Win = Instance.new("Frame")
Win.Size = UDim2.new(0, 360, 0, 540)
Win.Position = UDim2.new(0.5,-180,0.5,-270)
Win.BackgroundColor3 = C.BG
Win.BorderSizePixel = 0
Win.ClipsDescendants = true
Win.Parent = Gui
local wc = Instance.new("UICorner",Win); wc.CornerRadius = UDim.new(0,10)
local ws = Instance.new("UIStroke",Win); ws.Color=C.Border; ws.Thickness=1.5

-- Shadow
local Shadow = Instance.new("Frame")
Shadow.Size = UDim2.new(1,20,1,20)
Shadow.Position = UDim2.new(0,-10,0,5)
Shadow.BackgroundColor3 = Color3.new(0,0,0)
Shadow.BackgroundTransparency = 0.6
Shadow.BorderSizePixel = 0
Shadow.ZIndex = 0
Shadow.Parent = Win
Instance.new("UICorner",Shadow).CornerRadius = UDim.new(0,14)

-- ============================================================
-- TITLE BAR
-- ============================================================
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,36)
TitleBar.BackgroundColor3 = C.Header
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 3
TitleBar.Parent = Win

local TitleLbl = Instance.new("TextLabel",TitleBar)
TitleLbl.Text = "⚡ ZALER EXPLORER"
TitleLbl.Size = UDim2.new(1,-120,1,0)
TitleLbl.Position = UDim2.new(0,10,0,0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = 13
TitleLbl.TextColor3 = C.Cyan
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex = 3

-- Buttons
local function mkTitleBtn(text, xOff, bg)
    local b = Instance.new("TextButton",TitleBar)
    b.Text = text
    b.Size = UDim2.new(0,28,0,22)
    b.Position = UDim2.new(1,xOff,0.5,-11)
    b.BackgroundColor3 = bg
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.TextColor3 = C.White
    b.ZIndex = 4
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,5)
    return b
end

local RefreshBtn = mkTitleBtn("↺", -94, Color3.fromRGB(50,50,70))
local MinBtn     = mkTitleBtn("−", -62, Color3.fromRGB(200,160,0))
local CloseBtn   = mkTitleBtn("✕", -30, Color3.fromRGB(200,50,50))

-- ============================================================
-- TAB BAR
-- ============================================================
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1,0,0,30)
TabBar.Position = UDim2.new(0,0,0,36)
TabBar.BackgroundColor3 = C.Panel
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 3
TabBar.Parent = Win

local tabList = Instance.new("UIListLayout",TabBar)
tabList.FillDirection = Enum.FillDirection.Horizontal
tabList.Padding = UDim.new(0,2)
tabList.VerticalAlignment = Enum.VerticalAlignment.Center
Instance.new("UIPadding",TabBar).PaddingLeft = UDim.new(0,6)

local Tabs = {}
local ActiveTab = "Explorer"

local function mkTab(name, icon)
    local btn = Instance.new("TextButton",TabBar)
    btn.Text = icon .. " " .. name
    btn.Size = UDim2.new(0,90,0,24)
    btn.BackgroundColor3 = C.Row
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = C.Dim
    btn.ZIndex = 4
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,6)
    Tabs[name] = btn
    return btn
end

local ExplorerTab = mkTab("Explorer","🌍")
local PropertiesTab = mkTab("Properties","⚙️")
local ScriptTab = mkTab("Scripts","📜")
local RemoteTab = mkTab("Remote Spy","📡")

-- ============================================================
-- CONTENT FRAMES
-- ============================================================
local function mkContent(y, h)
    local f = Instance.new("Frame",Win)
    f.Size = UDim2.new(1,0,0,h)
    f.Position = UDim2.new(0,0,0,y)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    f.Visible = false
    return f
end

local ExplorerContent  = mkContent(66, 474)
local PropertiesContent= mkContent(66, 474)
local ScriptContent    = mkContent(66, 474)
local RemoteContent    = mkContent(66, 474)

-- ============================================================
-- TAB LOGIC
-- ============================================================
local function switchTab(name)
    ActiveTab = name
    local contents = {
        Explorer=ExplorerContent, Properties=PropertiesContent,
        Scripts=ScriptContent, ["Remote Spy"]=RemoteContent
    }
    for n, c in pairs(contents) do
        c.Visible = n == name
    end
    for n, btn in pairs(Tabs) do
        btn.BackgroundColor3 = n==name and C.RowSel or C.Row
        btn.TextColor3 = n==name and C.White or C.Dim
    end
end

ExplorerTab.MouseButton1Click:Connect(function() switchTab("Explorer") end)
PropertiesTab.MouseButton1Click:Connect(function() switchTab("Properties") end)
ScriptTab.MouseButton1Click:Connect(function() switchTab("Scripts") end)
RemoteTab.MouseButton1Click:Connect(function() switchTab("Remote Spy") end)

-- ============================================================
-- ===== EXPLORER TAB =====
-- ============================================================

-- Search
local SearchFrame = Instance.new("Frame",ExplorerContent)
SearchFrame.Size = UDim2.new(1,-12,0,28)
SearchFrame.Position = UDim2.new(0,6,0,4)
SearchFrame.BackgroundColor3 = C.Panel
SearchFrame.BorderSizePixel = 0
Instance.new("UICorner",SearchFrame).CornerRadius = UDim.new(0,7)
Instance.new("UIStroke",SearchFrame).Color = C.Border

local SearchBox = Instance.new("TextBox",SearchFrame)
SearchBox.PlaceholderText = "🔎  ค้นหา Instance..."
SearchBox.PlaceholderColor3 = C.Dim
SearchBox.Size = UDim2.new(1,-8,1,0)
SearchBox.Position = UDim2.new(0,8,0,0)
SearchBox.BackgroundTransparency = 1
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 12
SearchBox.TextColor3 = C.Text
SearchBox.ClearTextOnFocus = false

-- Breadcrumb
local Breadcrumb = Instance.new("TextLabel",ExplorerContent)
Breadcrumb.Size = UDim2.new(1,-12,0,18)
Breadcrumb.Position = UDim2.new(0,6,0,36)
Breadcrumb.BackgroundTransparency = 1
Breadcrumb.Font = Enum.Font.Gotham
Breadcrumb.TextSize = 9
Breadcrumb.TextColor3 = C.Yellow
Breadcrumb.TextXAlignment = Enum.TextXAlignment.Left
Breadcrumb.TextTruncate = Enum.TextTruncate.AtEnd
Breadcrumb.Text = "📍 game"

-- Tree Scroll
local TreeScroll = Instance.new("ScrollingFrame",ExplorerContent)
TreeScroll.Size = UDim2.new(1,0,1,-58)
TreeScroll.Position = UDim2.new(0,0,0,58)
TreeScroll.BackgroundTransparency = 1
TreeScroll.BorderSizePixel = 0
TreeScroll.ScrollBarThickness = 4
TreeScroll.ScrollBarImageColor3 = C.Cyan
TreeScroll.CanvasSize = UDim2.new(0,0,0,0)
TreeScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local TreeLayout = Instance.new("UIListLayout",TreeScroll)
TreeLayout.Padding = UDim.new(0,0)
TreeLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ============================================================
-- ===== PROPERTIES TAB =====
-- ============================================================

local PropObjLbl = Instance.new("TextLabel",PropertiesContent)
PropObjLbl.Size = UDim2.new(1,-12,0,26)
PropObjLbl.Position = UDim2.new(0,6,0,4)
PropObjLbl.BackgroundColor3 = C.Header
PropObjLbl.BorderSizePixel = 0
PropObjLbl.Font = Enum.Font.GothamBold
PropObjLbl.TextSize = 12
PropObjLbl.TextColor3 = C.Cyan
PropObjLbl.Text = "— เลือก Instance จาก Explorer —"
Instance.new("UICorner",PropObjLbl).CornerRadius = UDim.new(0,7)

local PropScroll = Instance.new("ScrollingFrame",PropertiesContent)
PropScroll.Size = UDim2.new(1,0,1,-34)
PropScroll.Position = UDim2.new(0,0,0,34)
PropScroll.BackgroundTransparency = 1
PropScroll.BorderSizePixel = 0
PropScroll.ScrollBarThickness = 4
PropScroll.ScrollBarImageColor3 = C.Cyan
PropScroll.CanvasSize = UDim2.new(0,0,0,0)
PropScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local PropListLayout = Instance.new("UIListLayout",PropScroll)
PropListLayout.Padding = UDim.new(0,0)

-- ============================================================
-- ===== SCRIPT VIEWER TAB =====
-- ============================================================

local ScriptListScroll = Instance.new("ScrollingFrame",ScriptContent)
ScriptListScroll.Size = UDim2.new(1,0,0,140)
ScriptListScroll.BackgroundColor3 = C.Panel
ScriptListScroll.BorderSizePixel = 0
ScriptListScroll.ScrollBarThickness = 3
ScriptListScroll.ScrollBarImageColor3 = C.Cyan
ScriptListScroll.CanvasSize = UDim2.new(0,0,0,0)
ScriptListScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local ScriptListLayout = Instance.new("UIListLayout",ScriptListScroll)
ScriptListLayout.Padding = UDim.new(0,0)

local ScriptHdr = Instance.new("TextLabel",ScriptContent)
ScriptHdr.Text = "📜  Scripts ในแมพ"
ScriptHdr.Size = UDim2.new(1,0,0,20)
ScriptHdr.Position = UDim2.new(0,0,0,142)
ScriptHdr.BackgroundTransparency = 1
ScriptHdr.Font = Enum.Font.GothamBold
ScriptHdr.TextSize = 11
ScriptHdr.TextColor3 = C.Yellow
ScriptHdr.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UIPadding",ScriptHdr).PaddingLeft = UDim.new(0,8)

local ScriptViewFrame = Instance.new("Frame",ScriptContent)
ScriptViewFrame.Size = UDim2.new(1,0,1,-164)
ScriptViewFrame.Position = UDim2.new(0,0,0,164)
ScriptViewFrame.BackgroundColor3 = Color3.fromRGB(18,18,22)
ScriptViewFrame.BorderSizePixel = 0

local ScriptViewScroll = Instance.new("ScrollingFrame",ScriptViewFrame)
ScriptViewScroll.Size = UDim2.new(1,0,1,0)
ScriptViewScroll.BackgroundTransparency = 1
ScriptViewScroll.BorderSizePixel = 0
ScriptViewScroll.ScrollBarThickness = 4
ScriptViewScroll.ScrollBarImageColor3 = C.Cyan
ScriptViewScroll.CanvasSize = UDim2.new(0,0,0,0)
ScriptViewScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local ScriptViewLbl = Instance.new("TextLabel",ScriptViewScroll)
ScriptViewLbl.Text = "-- เลือก Script เพื่อดู Source --"
ScriptViewLbl.Size = UDim2.new(1,-8,0,20)
ScriptViewLbl.Position = UDim2.new(0,6,0,4)
ScriptViewLbl.BackgroundTransparency = 1
ScriptViewLbl.Font = Enum.Font.Code
ScriptViewLbl.TextSize = 11
ScriptViewLbl.TextColor3 = C.Dim
ScriptViewLbl.TextXAlignment = Enum.TextXAlignment.Left
ScriptViewLbl.TextWrapped = true
ScriptViewLbl.AutomaticSize = Enum.AutomaticSize.Y

-- ============================================================
-- ===== REMOTE SPY TAB =====
-- ============================================================

local RemoteClearBtn = Instance.new("TextButton",RemoteContent)
RemoteClearBtn.Text = "🗑  Clear"
RemoteClearBtn.Size = UDim2.new(0,80,0,24)
RemoteClearBtn.Position = UDim2.new(1,-86,0,4)
RemoteClearBtn.BackgroundColor3 = Color3.fromRGB(160,40,40)
RemoteClearBtn.BorderSizePixel = 0
RemoteClearBtn.Font = Enum.Font.GothamBold
RemoteClearBtn.TextSize = 11
RemoteClearBtn.TextColor3 = C.White
Instance.new("UICorner",RemoteClearBtn).CornerRadius = UDim.new(0,6)

local RemoteCountLbl = Instance.new("TextLabel",RemoteContent)
RemoteCountLbl.Text = "📡  Remote Spy — 0 calls"
RemoteCountLbl.Size = UDim2.new(1,-90,0,24)
RemoteCountLbl.Position = UDim2.new(0,6,0,6)
RemoteCountLbl.BackgroundTransparency = 1
RemoteCountLbl.Font = Enum.Font.GothamBold
RemoteCountLbl.TextSize = 11
RemoteCountLbl.TextColor3 = C.Orange
RemoteCountLbl.TextXAlignment = Enum.TextXAlignment.Left

local RemoteScroll = Instance.new("ScrollingFrame",RemoteContent)
RemoteScroll.Size = UDim2.new(1,0,1,-32)
RemoteScroll.Position = UDim2.new(0,0,0,32)
RemoteScroll.BackgroundTransparency = 1
RemoteScroll.BorderSizePixel = 0
RemoteScroll.ScrollBarThickness = 4
RemoteScroll.ScrollBarImageColor3 = C.Orange
RemoteScroll.CanvasSize = UDim2.new(0,0,0,0)
RemoteScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local RemoteLayout = Instance.new("UIListLayout",RemoteScroll)
RemoteLayout.Padding = UDim.new(0,1)
RemoteLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ============================================================
-- CONTEXT MENU
-- ============================================================
local CtxMenu = Instance.new("Frame",Gui)
CtxMenu.Size = UDim2.new(0,170,0,10)
CtxMenu.BackgroundColor3 = C.Panel
CtxMenu.BorderSizePixel = 0
CtxMenu.Visible = false
CtxMenu.ZIndex = 20
Instance.new("UICorner",CtxMenu).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke",CtxMenu).Color = C.Border

local CtxLayout = Instance.new("UIListLayout",CtxMenu)
CtxLayout.Padding = UDim.new(0,2)
Instance.new("UIPadding",CtxMenu).PaddingTop = UDim.new(0,4)

local ctxTarget = nil

local function mkCtxItem(icon, text, color, cb)
    local btn = Instance.new("TextButton",CtxMenu)
    btn.Text = icon .. "  " .. text
    btn.Size = UDim2.new(1,-8,0,26)
    btn.Position = UDim2.new(0,4,0,0)
    btn.BackgroundColor3 = C.Row
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextColor3 = color or C.Text
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.ZIndex = 21
    Instance.new("UICorner",btn).CornerRadius = UDim.new(0,5)
    Instance.new("UIPadding",btn).PaddingLeft = UDim.new(0,8)
    btn.MouseButton1Click:Connect(function()
        CtxMenu.Visible = false
        if cb then cb() end
    end)
    return btn
end

local function showCtxMenu(obj, x, y)
    ctxTarget = obj
    -- Clear old items
    for _, c in pairs(CtxMenu:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end

    mkCtxItem("📋","Copy Name",    C.Text,   function() setclipboard(obj.Name) end)
    mkCtxItem("📍","Copy Path",    C.Yellow, function() setclipboard(obj:GetFullName()) end)
    mkCtxItem("🔍","Copy Class",   C.Cyan,   function() setclipboard(obj.ClassName) end)

    if obj:IsA("BasePart") then
        mkCtxItem("📐","Copy Position", C.Orange, function()
            setclipboard(string.format("Vector3.new(%g,%g,%g)",
                obj.Position.X, obj.Position.Y, obj.Position.Z))
        end)
        mkCtxItem("🔒","Toggle Anchored", C.Green, function()
            obj.Anchored = not obj.Anchored
        end)
        mkCtxItem("👻","Toggle Transparency", C.Purple, function()
            obj.Transparency = obj.Transparency > 0 and 0 or 1
        end)
    end

    if obj:IsA("LuaSourceContainer") then
        mkCtxItem("📜","View Source",  C.Yellow, function()
            switchTab("Scripts")
            local src = ""
            pcall(function() src = obj.Source end)
            if src == "" then src = "-- Source ไม่สามารถเข้าถึงได้ (Protected)" end
            ScriptViewLbl.Text = src
        end)
    end

    if obj:IsA("Humanoid") then
        mkCtxItem("❤️","Max Health",  C.Green,  function() obj.Health = obj.MaxHealth end)
        mkCtxItem("💀","Kill",        C.Red,    function() obj.Health = 0 end)
    end

    mkCtxItem("🗑","Destroy", C.Red, function()
        pcall(function() obj:Destroy() end)
        rebuildTree()
    end)

    -- Resize menu
    local count = 0
    for _, c in pairs(CtxMenu:GetChildren()) do
        if c:IsA("TextButton") then count = count + 1 end
    end
    CtxMenu.Size = UDim2.new(0,170, 0, count*30+10)
    CtxMenu.Position = UDim2.new(0,x,0,y)
    CtxMenu.Visible = true
end

-- Close ctx on tap elsewhere
UserInputService.InputBegan:Connect(function(i)
    if CtxMenu.Visible and
       (i.UserInputType==Enum.UserInputType.MouseButton1
     or i.UserInputType==Enum.UserInputType.Touch) then
        task.delay(0.05, function() CtxMenu.Visible = false end)
    end
end)

-- ============================================================
-- PROPERTIES BUILDER
-- ============================================================
local selectedObj = nil

local function clearProps()
    for _, c in pairs(PropScroll:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
end

local propRowIndex = 0

local function addSection(title)
    propRowIndex = propRowIndex + 1
    local f = Instance.new("Frame",PropScroll)
    f.Size = UDim2.new(1,0,0,20)
    f.BackgroundColor3 = C.Header
    f.BorderSizePixel = 0
    f.LayoutOrder = propRowIndex

    local lbl = Instance.new("TextLabel",f)
    lbl.Text = "  " .. title
    lbl.Size = UDim2.new(1,0,1,0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextColor3 = C.Dim
    lbl.TextXAlignment = Enum.TextXAlignment.Left
end

local function addProp(name_, val, color, editable, editCb)
    propRowIndex = propRowIndex + 1
    local even = propRowIndex % 2 == 0
    local row = Instance.new("Frame",PropScroll)
    row.Size = UDim2.new(1,0,0,22)
    row.BackgroundColor3 = even and C.RowAlt or C.Row
    row.BorderSizePixel = 0
    row.LayoutOrder = propRowIndex

    local nl = Instance.new("TextLabel",row)
    nl.Text = name_
    nl.Size = UDim2.new(0.42,-2,1,0)
    nl.Position = UDim2.new(0,6,0,0)
    nl.BackgroundTransparency = 1
    nl.Font = Enum.Font.Gotham
    nl.TextSize = 11
    nl.TextColor3 = C.Dim
    nl.TextXAlignment = Enum.TextXAlignment.Left
    nl.TextTruncate = Enum.TextTruncate.AtEnd

    local valStr = tostring(val)

    if editable then
        local vb = Instance.new("TextBox",row)
        vb.Text = valStr
        vb.Size = UDim2.new(0.58,-8,0,18)
        vb.Position = UDim2.new(0.42,2,0.5,-9)
        vb.BackgroundColor3 = Color3.fromRGB(20,20,28)
        vb.BorderSizePixel = 0
        vb.Font = Enum.Font.GothamBold
        vb.TextSize = 11
        vb.TextColor3 = color or C.Text
        vb.ClearTextOnFocus = false
        Instance.new("UICorner",vb).CornerRadius = UDim.new(0,4)
        vb.FocusLost:Connect(function(enter)
            if enter and editCb then editCb(vb.Text) end
        end)
    else
        local vl = Instance.new("TextLabel",row)
        vl.Text = valStr
        vl.Size = UDim2.new(0.58,-8,1,0)
        vl.Position = UDim2.new(0.42,2,0,0)
        vl.BackgroundTransparency = 1
        vl.Font = Enum.Font.GothamBold
        vl.TextSize = 11
        vl.TextColor3 = color or C.Text
        vl.TextXAlignment = Enum.TextXAlignment.Left
        vl.TextTruncate = Enum.TextTruncate.AtEnd
    end

    -- divider
    local div = Instance.new("Frame",row)
    div.Size = UDim2.new(1,0,0,1)
    div.Position = UDim2.new(0,0,1,-1)
    div.BackgroundColor3 = C.Border
    div.BackgroundTransparency = 0.7
    div.BorderSizePixel = 0
end

local function showProps(obj)
    if not obj then return end
    clearProps()
    propRowIndex = 0
    selectedObj = obj
    PropObjLbl.Text = getIcon(obj) .. "  " .. obj.ClassName .. "  —  " .. obj.Name

    -- Base
    addSection("▸ Instance")
    addProp("Name",      obj.Name, C.Yellow, true, function(v) pcall(function() obj.Name=v end) end)
    addProp("ClassName", obj.ClassName, C.Cyan)
    addProp("FullPath",  obj:GetFullName(), C.Green)
    addProp("Parent",    obj.Parent and obj.Parent.Name or "nil", C.Text)
    addProp("Children",  #obj:GetChildren(), C.Text)
    addProp("Archivable",obj.Archivable, C.Text, true, function(v) pcall(function() obj.Archivable=(v=="true") end) end)

    -- BasePart
    if obj:IsA("BasePart") then
        addSection("▸ Part")
        local p=obj.Position
        addProp("Position.X", string.format("%.3f",p.X), C.Orange, true, function(v) pcall(function() obj.Position=Vector3.new(tonumber(v),p.Y,p.Z) end) end)
        addProp("Position.Y", string.format("%.3f",p.Y), C.Orange, true, function(v) pcall(function() obj.Position=Vector3.new(p.X,tonumber(v),p.Z) end) end)
        addProp("Position.Z", string.format("%.3f",p.Z), C.Orange, true, function(v) pcall(function() obj.Position=Vector3.new(p.X,p.Y,tonumber(v)) end) end)
        local s=obj.Size
        addProp("Size.X",     string.format("%.3f",s.X), C.Orange, true, function(v) pcall(function() obj.Size=Vector3.new(tonumber(v),s.Y,s.Z) end) end)
        addProp("Size.Y",     string.format("%.3f",s.Y), C.Orange, true, function(v) pcall(function() obj.Size=Vector3.new(s.X,tonumber(v),s.Z) end) end)
        addProp("Size.Z",     string.format("%.3f",s.Z), C.Orange, true, function(v) pcall(function() obj.Size=Vector3.new(s.X,s.Y,tonumber(v)) end) end)
        addProp("Anchored",   obj.Anchored, obj.Anchored and C.Green or C.Red, true, function(v) pcall(function() obj.Anchored=(v=="true") end) end)
        addProp("CanCollide", obj.CanCollide, obj.CanCollide and C.Green or C.Red, true, function(v) pcall(function() obj.CanCollide=(v=="true") end) end)
        addProp("Transparency",obj.Transparency,C.Text, true, function(v) pcall(function() obj.Transparency=tonumber(v) end) end)
        addProp("CastShadow", obj.CastShadow, C.Text, true, function(v) pcall(function() obj.CastShadow=(v=="true") end) end)
        addProp("Locked",     obj.Locked, C.Text)
        local col=obj.Color
        addProp("Color",string.format("R:%.0f G:%.0f B:%.0f",col.R*255,col.G*255,col.B*255),
            Color3.new(col.R,col.G,col.B))
        addProp("Material", tostring(obj.Material), C.Purple)
        addProp("Massless", obj.Massless, C.Text)
    end

    -- Humanoid
    if obj:IsA("Humanoid") then
        addSection("▸ Humanoid")
        addProp("Health",    string.format("%.1f",obj.Health),    C.Green, true, function(v) pcall(function() obj.Health=tonumber(v) end) end)
        addProp("MaxHealth", string.format("%.1f",obj.MaxHealth), C.Green, true, function(v) pcall(function() obj.MaxHealth=tonumber(v) end) end)
        addProp("WalkSpeed", obj.WalkSpeed, C.Cyan, true, function(v) pcall(function() obj.WalkSpeed=tonumber(v) end) end)
        addProp("JumpPower", obj.JumpPower, C.Cyan, true, function(v) pcall(function() obj.JumpPower=tonumber(v) end) end)
        addProp("State",     tostring(obj:GetState()), C.Yellow)
        addProp("DisplayName",obj.DisplayName, C.Text)
        addProp("NameVisible",obj.NameOcclusion, C.Text)
    end

    -- Script
    if obj:IsA("LuaSourceContainer") then
        addSection("▸ Script")
        addProp("Disabled", obj.Disabled, obj.Disabled and C.Red or C.Green, true, function(v) pcall(function() obj.Disabled=(v=="true") end) end)
        local src="" pcall(function() src=obj.Source end)
        addProp("Source Lines", #src:split("\n"), C.Text)
        addProp("Source Chars", #src, C.Text)
    end

    -- ValueBase
    if obj:IsA("ValueBase") then
        addSection("▸ Value")
        addProp("Value", tostring(obj.Value), C.Yellow, true, function(v)
            pcall(function()
                if obj:IsA("StringValue") then obj.Value=v
                elseif obj:IsA("BoolValue") then obj.Value=(v=="true")
                elseif obj:IsA("IntValue") then obj.Value=math.floor(tonumber(v))
                elseif obj:IsA("NumberValue") then obj.Value=tonumber(v)
                end
            end)
        end)
    end

    -- Sound
    if obj:IsA("Sound") then
        addSection("▸ Sound")
        addProp("SoundId",  obj.SoundId, C.Text, true, function(v) pcall(function() obj.SoundId=v end) end)
        addProp("Volume",   obj.Volume,  C.Text, true, function(v) pcall(function() obj.Volume=tonumber(v) end) end)
        addProp("Pitch",    obj.PlaybackSpeed, C.Text, true, function(v) pcall(function() obj.PlaybackSpeed=tonumber(v) end) end)
        addProp("Playing",  obj.IsPlaying, obj.IsPlaying and C.Green or C.Red)
        addProp("Looped",   obj.Looped,   C.Text, true, function(v) pcall(function() obj.Looped=(v=="true") end) end)
        addProp("TimeLen",  string.format("%.2f s",obj.TimeLength), C.Dim)
    end

    -- GuiObject
    if obj:IsA("GuiObject") then
        addSection("▸ GuiObject")
        addProp("Visible",      obj.Visible, obj.Visible and C.Green or C.Red, true, function(v) pcall(function() obj.Visible=(v=="true") end) end)
        addProp("ZIndex",       obj.ZIndex,  C.Text, true, function(v) pcall(function() obj.ZIndex=tonumber(v) end) end)
        addProp("Transparency", obj.BackgroundTransparency, C.Text, true, function(v) pcall(function() obj.BackgroundTransparency=tonumber(v) end) end)
    end

    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
        addSection("▸ Text")
        addProp("Text",     obj.Text, C.Yellow, true, function(v) pcall(function() obj.Text=v end) end)
        addProp("TextSize", obj.TextSize, C.Text, true, function(v) pcall(function() obj.TextSize=tonumber(v) end) end)
        addProp("Font",     tostring(obj.Font), C.Text)
    end

    -- Light
    if obj:IsA("Light") then
        addSection("▸ Light")
        addProp("Enabled",    obj.Enabled, obj.Enabled and C.Green or C.Red, true, function(v) pcall(function() obj.Enabled=(v=="true") end) end)
        addProp("Brightness", obj.Brightness, C.Yellow, true, function(v) pcall(function() obj.Brightness=tonumber(v) end) end)
        addProp("Range",      obj.Range, C.Text, true, function(v) pcall(function() obj.Range=tonumber(v) end) end)
    end

    -- ParticleEmitter
    if obj:IsA("ParticleEmitter") then
        addSection("▸ Particle")
        addProp("Rate",    obj.Rate, C.Text, true, function(v) pcall(function() obj.Rate=tonumber(v) end) end)
        addProp("Enabled", obj.Enabled, obj.Enabled and C.Green or C.Red, true, function(v) pcall(function() obj.Enabled=(v=="true") end) end)
    end
end

-- ============================================================
-- TREE BUILDER
-- ============================================================
local expanded = {}
local allTreeRows = {}

local function clearTree()
    for _, c in pairs(TreeScroll:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    allTreeRows = {}
end

local rowOrder = 0

local function buildRow(obj, depth)
    rowOrder = rowOrder + 1
    local children = obj:GetChildren()
    local hasChild = #children > 0
    local isExp = expanded[obj] or false
    local even = rowOrder % 2 == 0

    local row = Instance.new("Frame",TreeScroll)
    row.Size = UDim2.new(1,0,0,22)
    row.BackgroundColor3 = even and C.RowAlt or C.Row
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.LayoutOrder = rowOrder
    table.insert(allTreeRows, {frame=row, obj=obj})

    -- Indent lines
    for i = 1, depth do
        local line = Instance.new("Frame",row)
        line.Size = UDim2.new(0,1,1,0)
        line.Position = UDim2.new(0,(i-1)*14+7,0,0)
        line.BackgroundColor3 = Color3.fromRGB(60,60,75)
        line.BorderSizePixel = 0
    end

    -- Expand btn
    local expBtn = Instance.new("TextButton",row)
    expBtn.Text = hasChild and (isExp and "▼" or "▶") or ""
    expBtn.Size = UDim2.new(0,14,1,0)
    expBtn.Position = UDim2.new(0,depth*14,0,0)
    expBtn.BackgroundTransparency = 1
    expBtn.Font = Enum.Font.GothamBold
    expBtn.TextSize = 9
    expBtn.TextColor3 = C.Dim

    -- Icon
    local iconL = Instance.new("TextLabel",row)
    iconL.Text = getIcon(obj)
    iconL.Size = UDim2.new(0,18,1,0)
    iconL.Position = UDim2.new(0,depth*14+14,0,0)
    iconL.BackgroundTransparency = 1
    iconL.Font = Enum.Font.GothamBold
    iconL.TextSize = 13
    iconL.TextColor3 = getClassColor(obj.ClassName)

    -- Name
    local nameL = Instance.new("TextLabel",row)
    nameL.Text = obj.Name
    nameL.Size = UDim2.new(1,-(depth*14+34),1,0)
    nameL.Position = UDim2.new(0,depth*14+32,0,0)
    nameL.BackgroundTransparency = 1
    nameL.Font = Enum.Font.Gotham
    nameL.TextSize = 12
    nameL.TextColor3 = getClassColor(obj.ClassName)
    nameL.TextXAlignment = Enum.TextXAlignment.Left
    nameL.TextTruncate = Enum.TextTruncate.AtEnd

    -- Class badge (small)
    local clsL = Instance.new("TextLabel",row)
    clsL.Text = obj.ClassName
    clsL.Size = UDim2.new(0,90,0,14)
    clsL.Position = UDim2.new(1,-94,0.5,-7)
    clsL.BackgroundTransparency = 1
    clsL.Font = Enum.Font.Gotham
    clsL.TextSize = 9
    clsL.TextColor3 = C.Dim
    clsL.TextXAlignment = Enum.TextXAlignment.Right
    clsL.TextTruncate = Enum.TextTruncate.AtEnd

    -- Hit area (select)
    local hit = Instance.new("TextButton",row)
    hit.Size = UDim2.new(1,-(depth*14+14),1,0)
    hit.Position = UDim2.new(0,depth*14+14,0,0)
    hit.BackgroundTransparency = 1
    hit.Text = ""

    hit.MouseButton1Click:Connect(function()
        for _, r in pairs(allTreeRows) do
            TweenService:Create(r.frame,TweenInfo.new(0.1),{
                BackgroundColor3 = r.obj==obj and C.RowSel or (even and C.RowAlt or C.Row),
                BackgroundTransparency = r.obj==obj and 0 or 0.3
            }):Play()
        end
        Breadcrumb.Text = "📍 " .. obj:GetFullName()
        showProps(obj)
        if ActiveTab ~= "Properties" then switchTab("Properties") end
    end)

    -- Long press = context menu
    local pressTime = 0
    hit.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch
        or i.UserInputType==Enum.UserInputType.MouseButton1 then
            pressTime = tick()
        end
    end)
    hit.InputEnded:Connect(function(i)
        if (i.UserInputType==Enum.UserInputType.Touch
        or i.UserInputType==Enum.UserInputType.MouseButton2)
        and tick()-pressTime > 0.35 then
            showCtxMenu(obj, i.Position.X-Win.AbsolutePosition.X,
                            i.Position.Y-Win.AbsolutePosition.Y)
        end
    end)

    expBtn.MouseButton1Click:Connect(function()
        if hasChild then
            expanded[obj] = not expanded[obj]
            rebuildTree()
        end
    end)
end

local function buildTree(parent, depth)
    local search = SearchBox.Text:lower()
    for _, child in pairs(parent:GetChildren()) do
        local match = search=="" or child.Name:lower():find(search,1,true)
            or child.ClassName:lower():find(search,1,true)
        if match then
            buildRow(child, depth)
        end
        if expanded[child] then
            buildTree(child, depth+1)
        end
    end
end

local SERVICE_ROOTS = {
    "Workspace","Players","ReplicatedStorage","ReplicatedFirst",
    "StarterGui","StarterPack","StarterPlayer","Lighting",
    "SoundService","Teams","ServerStorage","CoreGui",
}

function rebuildTree()
    clearTree()
    rowOrder = 0
    local search = SearchBox.Text:lower()
    for _, sname in pairs(SERVICE_ROOTS) do
        local ok2, svc = pcall(function() return game:GetService(sname) end)
        if ok2 and svc then
            local match = search=="" or svc.Name:lower():find(search,1,true)
            if match or search=="" then
                buildRow(svc, 0)
            end
            if expanded[svc] then
                buildTree(svc, 1)
            end
        end
    end
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(rebuildTree)
RefreshBtn.MouseButton1Click:Connect(function()
    rebuildTree()
    buildScriptList()
end)

-- ============================================================
-- SCRIPT LIST BUILDER
-- ============================================================
function buildScriptList()
    for _, c in pairs(ScriptListScroll:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
    local count = 0
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("LuaSourceContainer") then
            count = count + 1
            local btn = Instance.new("TextButton",ScriptListScroll)
            btn.Text = getIcon(obj) .. " " .. obj.Name .. "  [" .. obj.ClassName .. "]"
            btn.Size = UDim2.new(1,0,0,24)
            btn.BackgroundColor3 = count%2==0 and C.RowAlt or C.Row
            btn.BorderSizePixel = 0
            btn.Font = Enum.Font.Gotham
            btn.TextSize = 11
            btn.TextColor3 = C.Yellow
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UIPadding",btn).PaddingLeft = UDim.new(0,8)
            btn.LayoutOrder = count
            btn.MouseButton1Click:Connect(function()
                local src="" pcall(function() src=obj.Source end)
                if src=="" then src="-- Source ไม่สามารถเข้าถึงได้ (Protected Script)\n-- Path: "..obj:GetFullName() end
                ScriptViewLbl.Text = src
            end)
        end
    end
    ScriptHdr.Text = string.format("📜  Scripts ในแมพ — %d ตัว", count)
end

-- ============================================================
-- REMOTE SPY
-- ============================================================
local remoteCount = 0
local hookedRemotes = {}

local function hookRemote(remote)
    if hookedRemotes[remote] then return end
    hookedRemotes[remote] = true

    local orig
    if remote:IsA("RemoteEvent") then
        orig = remote.FireServer
        remote.FireServer = function(self, ...)
            remoteCount = remoteCount + 1
            RemoteCountLbl.Text = "📡  Remote Spy — " .. remoteCount .. " calls"

            local args = {...}
            local argStr = ""
            for i, a in ipairs(args) do
                argStr = argStr .. (i>1 and ", " or "") .. tostring(a)
            end

            local row = Instance.new("Frame",RemoteScroll)
            row.Size = UDim2.new(1,0,0,36)
            row.BackgroundColor3 = remoteCount%2==0 and C.RowAlt or C.Row
            row.BorderSizePixel = 0
            row.LayoutOrder = remoteCount

            local typeL = Instance.new("TextLabel",row)
            typeL.Text = "📡 FIRE"
            typeL.Size = UDim2.new(0,55,0,18)
            typeL.Position = UDim2.new(0,4,0,2)
            typeL.BackgroundTransparency = 1
            typeL.Font = Enum.Font.GothamBold
            typeL.TextSize = 10
            typeL.TextColor3 = C.Orange

            local nameL2 = Instance.new("TextLabel",row)
            nameL2.Text = remote:GetFullName()
            nameL2.Size = UDim2.new(1,-60,0,18)
            nameL2.Position = UDim2.new(0,58,0,2)
            nameL2.BackgroundTransparency = 1
            nameL2.Font = Enum.Font.GothamBold
            nameL2.TextSize = 11
            nameL2.TextColor3 = C.Cyan
            nameL2.TextTruncate = Enum.TextTruncate.AtEnd

            local argL = Instance.new("TextLabel",row)
            argL.Text = "Args: " .. (argStr~="" and argStr or "none")
            argL.Size = UDim2.new(1,-8,0,14)
            argL.Position = UDim2.new(0,4,0,20)
            argL.BackgroundTransparency = 1
            argL.Font = Enum.Font.Gotham
            argL.TextSize = 10
            argL.TextColor3 = C.Dim
            argL.TextTruncate = Enum.TextTruncate.AtEnd

            return orig(self, ...)
        end
    end
end

-- Hook existing + new remotes
local function hookAll()
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            pcall(hookRemote, obj)
        end
    end
end

game.DescendantAdded:Connect(function(obj)
    if obj:IsA("RemoteEvent") then
        task.wait(0.1)
        pcall(hookRemote, obj)
    end
end)

RemoteClearBtn.MouseButton1Click:Connect(function()
    remoteCount = 0
    RemoteCountLbl.Text = "📡  Remote Spy — 0 calls"
    for _, c in pairs(RemoteScroll:GetChildren()) do
        if not c:IsA("UIListLayout") then c:Destroy() end
    end
end)

-- ============================================================
-- DRAG
-- ============================================================
local dragging, dStart, wStart = false, nil, nil
TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.UserInputType==Enum.UserInputType.Touch then
        dragging=true; dStart=i.Position; wStart=Win.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement
    or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-dStart
        Win.Position=UDim2.new(wStart.X.Scale,wStart.X.Offset+d.X,
                                wStart.Y.Scale,wStart.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)

-- Min/Close
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(Win,TweenInfo.new(0.2),{
        Size = minimized and UDim2.new(0,360,0,36) or UDim2.new(0,360,0,540)
    }):Play()
end)
CloseBtn.MouseButton1Click:Connect(function() Win.Visible = false end)

-- Reopen
local ReopenBtn = Instance.new("TextButton",Gui)
ReopenBtn.Text = "⚡"
ReopenBtn.Size = UDim2.new(0,42,0,42)
ReopenBtn.Position = UDim2.new(1,-50,0,8)
ReopenBtn.BackgroundColor3 = Color3.fromRGB(35,35,50)
ReopenBtn.BorderSizePixel = 0
ReopenBtn.Font = Enum.Font.GothamBold
ReopenBtn.TextSize = 20
ReopenBtn.TextColor3 = C.Cyan
ReopenBtn.Visible = false
Instance.new("UICorner",ReopenBtn).CornerRadius = UDim.new(0,12)
Instance.new("UIStroke",ReopenBtn).Color = C.Border

CloseBtn.MouseButton1Click:Connect(function() Win.Visible=false; ReopenBtn.Visible=true end)
ReopenBtn.MouseButton1Click:Connect(function() Win.Visible=true; ReopenBtn.Visible=false; rebuildTree() end)

-- ============================================================
-- INIT
-- ============================================================
switchTab("Explorer")
rebuildTree()
buildScriptList()
task.delay(1, hookAll)

-- Live properties update
RunService.Heartbeat:Connect(function()
    if ActiveTab=="Properties" and selectedObj then
        pcall(function() showProps(selectedObj) end)
    end
end)

-- Auto refresh tree on new instance
workspace.DescendantAdded:Connect(function()
    task.delay(0.5, function()
        if ActiveTab=="Explorer" then rebuildTree() end
    end)
end)

print("[ZALER EXPLORER] โหลดสำเร็จ!")

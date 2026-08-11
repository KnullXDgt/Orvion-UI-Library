-- ==========================================
-- ORVION LIBRARY v2.0 — Source
-- Kairo + Orvion hybrid
-- ==========================================

local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local CONFIG_FONT_SECTION  = 15
local CONFIG_FONT_GENERAL  = 13
local CONFIG_FONT_DROPDOWN = 12
local CONFIG_ELEMENT_HEIGHT = 48

local COLOR_WHITE        = Color3.fromRGB(255, 255, 255)
local COLOR_DARK_GRAY    = Color3.fromRGB(170, 170, 185)
local COLOR_SIDEBAR_LOG  = Color3.fromRGB(200, 200, 215)
local COLOR_SECTION_BG   = Color3.fromRGB(35, 35, 45)
local COLOR_INTERACTIVE_BG = Color3.fromRGB(25, 25, 32)

-- ==========================================
-- THEME SYSTEM
-- ==========================================
local ThemeSystem = {
    CurrentTheme = "Default",
    ThemeColors = (function()
        local ok, themes = pcall(function() return require(script.Parent.themes) end)
        if ok and themes then return themes end
        return {
            ["Default"]  = Color3.fromRGB(255, 0, 255),
            ["Blue"]     = Color3.fromRGB(0, 120, 255),
            ["Red"]      = Color3.fromRGB(255, 50, 50),
            ["Green"]    = Color3.fromRGB(0, 200, 80),
            ["Orange"]   = Color3.fromRGB(255, 120, 0),
            ["Purple"]   = Color3.fromRGB(160, 0, 255),
            ["Cyan"]     = Color3.fromRGB(0, 200, 255),
            ["Pink"]     = Color3.fromRGB(255, 100, 200),
            ["Midnight"] = Color3.fromRGB(10, 30, 60),
            ["Ocean"]    = Color3.fromRGB(0, 150, 200),
            ["Sunset"]   = Color3.fromRGB(255, 100, 50),
            ["Gold"]     = Color3.fromRGB(255, 200, 0),
            ["Emerald"]  = Color3.fromRGB(0, 200, 150),
            ["Crimson"]  = Color3.fromRGB(200, 0, 50),
            ["Lavender"] = Color3.fromRGB(180, 130, 255),
            ["Teal"]     = Color3.fromRGB(0, 150, 150),
            ["Rose"]     = Color3.fromRGB(255, 100, 150),
            ["Sky"]      = Color3.fromRGB(100, 180, 255),
            ["Forest"]   = Color3.fromRGB(0, 120, 80),
            ["Amber"]    = Color3.fromRGB(255, 150, 0),
            ["Neon"]     = Color3.fromRGB(0, 255, 200),
            ["Royal"]    = Color3.fromRGB(100, 0, 200)
        }
    end)(),
    ThemeElements = {},
    ToggleElements = {},
    SliderElements = {},
    BadgeElements = {},
    TabElements = {}
}

function ThemeSystem:SetTheme(themeName)
    if self.ThemeColors[themeName] then
        self.CurrentTheme = themeName
        self:UpdateAll(self.ThemeColors[themeName])
        return true
    end
    return false
end

function ThemeSystem:UpdateAll(color)
    for _, el in ipairs(self.ThemeElements) do
        if el.Update then pcall(el.Update, color) end
    end
    for _, el in ipairs(self.BadgeElements) do
        if el.Update then pcall(el.Update, color) end
    end
    for _, toggle in ipairs(self.ToggleElements) do
        if toggle and toggle:IsA("Frame") then
            local fc = toggle:FindFirstChild("FeatureFrame")
            local tc = toggle:FindFirstChild("ToggleCircle")
            local fs = fc and fc:FindFirstChild("UIStroke")
            if tc and tc.Position == UDim2.new(0, 15, 0, 0) then
                tc.BackgroundColor3 = color
                if fs then fs.Color = color end
                if fc then fc.BackgroundColor3 = color end
            end
        end
    end
    for _, slider in ipairs(self.SliderElements) do
        if slider and slider:IsA("Frame") then
            local fill = slider:FindFirstChild("SliderFill")
            if fill then fill.BackgroundColor3 = color end
            local sc = slider:FindFirstChild("SliderCircle")
            if sc then sc.BackgroundColor3 = color end
        end
    end
    for _, tab in ipairs(self.TabElements) do
        if tab and tab:IsA("Frame") then
            local ind = tab:FindFirstChild("Indicator")
            if ind then ind.BackgroundColor3 = color end
        end
    end
end

-- ==========================================
-- CONFIG SYSTEM
-- ==========================================
local ConfigSystem = (function()
    local ok, cs = pcall(function() return require(script.Parent.configs) end)
    if ok and cs then return cs end
    return {Save = function() end, Load = function() end, Delete = function() end, List = function() return {} end}
end)()

-- ==========================================
-- UTILITY: CircleClick, Drag, Resize
-- ==========================================
local function CircleClick(Button, X, Y)
    task.spawn(function()
        Button.ClipsDescendants = true
        local Circle = Instance.new("ImageLabel")
        Circle.Image = "rbxassetid://266543268"
        Circle.ImageColor3 = Color3.fromRGB(80, 80, 80)
        Circle.ImageTransparency = 0.9
        Circle.BackgroundColor3 = COLOR_WHITE
        Circle.BackgroundTransparency = 1
        Circle.ZIndex = 10
        Circle.Name = "Circle"
        Circle.Parent = Button
        local NewX = X - Circle.AbsolutePosition.X
        local NewY = Y - Circle.AbsolutePosition.Y
        Circle.Position = UDim2.new(0, NewX, 0, NewY)
        local Size = 0
        if Button.AbsoluteSize.X > Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.X * 1.5
        elseif Button.AbsoluteSize.X < Button.AbsoluteSize.Y then
            Size = Button.AbsoluteSize.Y * 1.5
        else
            Size = Button.AbsoluteSize.X * 1.5
        end
        local Time = 0.5
        Circle:TweenSizeAndPosition(UDim2.new(0, Size, 0, Size), UDim2.new(0.5, -Size/2, 0.5, -Size/2), "Out", "Quad", Time, false, nil)
        for i = 1, 10 do
            Circle.ImageTransparency = Circle.ImageTransparency + 0.01
            task.wait(Time / 10)
        end
        Circle:Destroy()
    end)
end

local function MakeDraggable(topbar, object)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        object.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, dragStart, startPos = true, input.Position, object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

local function MakeResizable(handle, target, minSize, maxSize, onResize)
    minSize = minSize or Vector2.new(300, 200)
    maxSize = maxSize or Vector2.new(1000, 800)
    local resizing, startMouse, startSz
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing, startMouse, startSz = true, input.Position, target.AbsoluteSize
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then resizing = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startMouse
            local nw = math.clamp(startSz.X + delta.X, minSize.X, maxSize.X)
            local nh = math.clamp(startSz.Y + delta.Y, minSize.Y, maxSize.Y)
            target.Size = UDim2.new(0, nw, 0, nh)
            if onResize then onResize(Vector2.new(nw, nh)) end
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = false end
    end)
end

local function MakeDraggableMobileButton(button, object, screenGui)
    local dragging, dragInput, dragStart, startPos, clickStartTime, clickStartPos
    local function update(input)
        local delta = input.Position - dragStart
        local nx = math.clamp(startPos.X.Offset + delta.X, 10, screenGui.AbsoluteSize.X - object.AbsoluteSize.X - 10)
        local ny = math.clamp(startPos.Y.Offset + delta.Y, 10, screenGui.AbsoluteSize.Y - object.AbsoluteSize.Y - 10)
        object.Position = UDim2.new(0, nx, 0, ny)
    end
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false; clickStartTime = tick(); clickStartPos = input.Position
            dragStart = input.Position; startPos = object.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if not dragging and (input.Position - clickStartPos).Magnitude > 5 then dragging = true end
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
    return function() return dragging end
end

-- ==========================================
-- NOTIFICATION (Kairo-style stacked)
-- ==========================================
local OrvionLib = {}
OrvionLib.Assets = {
    Icons = {
        Minimize = "rbxassetid://9886659276",
        Close    = "rbxassetid://9886659671",
        Arrow    = "rbxassetid://16851841101",
        Max      = "rbxassetid://9886659406",
        Restore  = "rbxassetid://9886659001"
    }
}

local function MakeNotify(NotifyConfig)
    local NotifyConfig = NotifyConfig or {}
    NotifyConfig.Title = NotifyConfig.Title or "Notification"
    NotifyConfig.Description = NotifyConfig.Description or "Description"
    NotifyConfig.Content = NotifyConfig.Content or "Content"
    NotifyConfig.Color = NotifyConfig.Color or Color3.fromRGB(255, 255, 255)
    NotifyConfig.Time = NotifyConfig.Time or 0.5
    NotifyConfig.Delay = NotifyConfig.Delay or 5

    local NotifyFunction = {}
    task.spawn(function()
        if not CoreGui:FindFirstChild("NotifyGui") then
            local NotifyGui = Instance.new("ScreenGui")
            NotifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            NotifyGui.Name = "NotifyGui"
            NotifyGui.Parent = CoreGui
        end
        if not CoreGui.NotifyGui:FindFirstChild("NotifyLayout") then
            local NotifyLayout = Instance.new("Frame")
            NotifyLayout.AnchorPoint = Vector2.new(1, 1)
            NotifyLayout.BackgroundColor3 = COLOR_WHITE
            NotifyLayout.BackgroundTransparency = 0.999
            NotifyLayout.BorderColor3 = Color3.fromRGB(0, 0, 0)
            NotifyLayout.BorderSizePixel = 0
            NotifyLayout.Position = UDim2.new(1, -30, 1, -30)
            NotifyLayout.Size = UDim2.new(0, 320, 1, 0)
            NotifyLayout.Name = "NotifyLayout"
            NotifyLayout.Parent = CoreGui.NotifyGui
            local Count = 0
            CoreGui.NotifyGui.NotifyLayout.ChildRemoved:Connect(function()
                Count = 0
                for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
                    TweenService:Create(v, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Position = UDim2.new(0, 0, 1, -((v.Size.Y.Offset + 12) * Count))}):Play()
                    Count = Count + 1
                end
            end)
        end
        local NotifyPosHeigh = 0
        for i, v in CoreGui.NotifyGui.NotifyLayout:GetChildren() do
            NotifyPosHeigh = -(v.Position.Y.Offset) + v.Size.Y.Offset + 12
        end
        local NotifyFrame = Instance.new("Frame")
        local NotifyFrameReal = Instance.new("Frame")
        NotifyFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        NotifyFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        NotifyFrame.BorderSizePixel = 0
        NotifyFrame.Size = UDim2.new(1, 0, 0, 150)
        NotifyFrame.Name = "NotifyFrame"
        NotifyFrame.BackgroundTransparency = 1
        NotifyFrame.Parent = CoreGui.NotifyGui.NotifyLayout
        NotifyFrame.AnchorPoint = Vector2.new(0, 1)
        NotifyFrame.Position = UDim2.new(0, 0, 1, -(NotifyPosHeigh))
        NotifyFrameReal.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        NotifyFrameReal.BorderColor3 = Color3.fromRGB(0, 0, 0)
        NotifyFrameReal.BorderSizePixel = 0
        NotifyFrameReal.Position = UDim2.new(0, 400, 0, 0)
        NotifyFrameReal.Size = UDim2.new(1, 0, 1, 0)
        NotifyFrameReal.Name = "NotifyFrameReal"
        NotifyFrameReal.Parent = NotifyFrame
        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(0, 8)
        UICorner.Parent = NotifyFrameReal
        local DropShadowHolder = Instance.new("Frame")
        DropShadowHolder.BackgroundTransparency = 1
        DropShadowHolder.BorderSizePixel = 0
        DropShadowHolder.Size = UDim2.new(1, 0, 1, 0)
        DropShadowHolder.ZIndex = 0
        DropShadowHolder.Name = "DropShadowHolder"
        DropShadowHolder.Parent = NotifyFrameReal
        local DropShadow = Instance.new("ImageLabel")
        DropShadow.Image = "rbxassetid://6015897843"
        DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        DropShadow.ImageTransparency = 0.5
        DropShadow.ScaleType = Enum.ScaleType.Slice
        DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
        DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
        DropShadow.BackgroundTransparency = 1
        DropShadow.BorderSizePixel = 0
        DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
        DropShadow.Size = UDim2.new(1, 47, 1, 47)
        DropShadow.ZIndex = 0
        DropShadow.Name = "DropShadow"
        DropShadow.Parent = DropShadowHolder
        local Top = Instance.new("Frame")
        Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        Top.BackgroundTransparency = 0.999
        Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Top.BorderSizePixel = 0
        Top.Size = UDim2.new(1, 0, 0, 36)
        Top.Name = "Top"
        Top.Parent = NotifyFrameReal
        local TextLabel = Instance.new("TextLabel")
        TextLabel.Font = Enum.Font.GothamBold
        TextLabel.Text = NotifyConfig.Title
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.TextSize = 14
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.BackgroundTransparency = 0.999
        TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel.BorderSizePixel = 0
        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.Parent = Top
        TextLabel.Position = UDim2.new(0, 10, 0, 0)
        local UIStroke = Instance.new("UIStroke")
        UIStroke.Color = Color3.fromRGB(255, 255, 255)
        UIStroke.Thickness = 0.3
        UIStroke.Parent = TextLabel
        local UICorner1 = Instance.new("UICorner")
        UICorner1.CornerRadius = UDim.new(0, 5)
        UICorner1.Parent = Top
        local TextLabel1 = Instance.new("TextLabel")
        TextLabel1.Font = Enum.Font.GothamBold
        TextLabel1.Text = NotifyConfig.Description
        TextLabel1.TextColor3 = NotifyConfig.Color
        TextLabel1.TextSize = 14
        TextLabel1.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel1.BackgroundTransparency = 0.999
        TextLabel1.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel1.BorderSizePixel = 0
        TextLabel1.Size = UDim2.new(1, 0, 1, 0)
        TextLabel1.Position = UDim2.new(0, TextLabel.TextBounds.X + 15, 0, 0)
        TextLabel1.Parent = Top
        local UIStroke1 = Instance.new("UIStroke")
        UIStroke1.Color = NotifyConfig.Color
        UIStroke1.Thickness = 0.4
        UIStroke1.Parent = TextLabel1
        local Close = Instance.new("TextButton")
        Close.Font = Enum.Font.SourceSans
        Close.Text = ""
        Close.TextColor3 = Color3.fromRGB(0, 0, 0)
        Close.TextSize = 14
        Close.AnchorPoint = Vector2.new(1, 0.5)
        Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Close.BackgroundTransparency = 0.999
        Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Close.BorderSizePixel = 0
        Close.Position = UDim2.new(1, -5, 0.5, 0)
        Close.Size = UDim2.new(0, 25, 0, 25)
        Close.Name = "Close"
        Close.Parent = Top
        local ImageLabel = Instance.new("ImageLabel")
        ImageLabel.Image = "rbxassetid://9886659671"
        ImageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageLabel.BackgroundTransparency = 0.999
        ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        ImageLabel.BorderSizePixel = 0
        ImageLabel.Position = UDim2.new(0.49, 0, 0.5, 0)
        ImageLabel.Size = UDim2.new(1, -8, 1, -8)
        ImageLabel.Parent = Close
        local TextLabel2 = Instance.new("TextLabel")
        TextLabel2.Font = Enum.Font.GothamBold
        TextLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel2.TextSize = 13
        TextLabel2.Text = NotifyConfig.Content
        TextLabel2.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel2.TextYAlignment = Enum.TextYAlignment.Top
        TextLabel2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel2.BackgroundTransparency = 0.999
        TextLabel2.TextColor3 = Color3.fromRGB(150, 150, 150)
        TextLabel2.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel2.BorderSizePixel = 0
        TextLabel2.Position = UDim2.new(0, 10, 0, 27)
        TextLabel2.Parent = NotifyFrameReal
        TextLabel2.Size = UDim2.new(1, -20, 0, 13)
        TextLabel2.Size = UDim2.new(1, -20, 0, 13 + (13 * (TextLabel2.TextBounds.X // TextLabel2.AbsoluteSize.X)))
        TextLabel2.TextWrapped = true
        if TextLabel2.AbsoluteSize.Y < 27 then
            NotifyFrame.Size = UDim2.new(1, 0, 0, 65)
        else
            NotifyFrame.Size = UDim2.new(1, 0, 0, TextLabel2.AbsoluteSize.Y + 40)
        end
        local waitbruh = false
        function NotifyFunction:Close()
            if waitbruh then return false end
            waitbruh = true
            TweenService:Create(NotifyFrameReal, TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Position = UDim2.new(0, 400, 0, 0)}):Play()
            task.wait(tonumber(NotifyConfig.Time) / 1.2)
            NotifyFrame:Destroy()
        end
        Close.Activated:Connect(function() NotifyFunction:Close() end)
        TweenService:Create(NotifyFrameReal, TweenInfo.new(tonumber(NotifyConfig.Time), Enum.EasingStyle.Back, Enum.EasingDirection.InOut), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        task.wait(tonumber(NotifyConfig.Delay))
        NotifyFunction:Close()
    end)
    return NotifyFunction
end

function OrvionLib:Notify(title, text, duration)
    duration = duration or 3
    return MakeNotify({
        Title = title or "Notification",
        Description = "Notification",
        Content = text or "",
        Color = Color3.fromRGB(255, 255, 255),
        Delay = duration,
        Time = 0.5
    })
end

-- ==========================================
-- CREATE WINDOW
-- ==========================================
function OrvionLib:CreateWindow(config)
    config = config or {}
    local Title = config.Title or "Orvion"
    local Theme = config.Theme or "Default"
    local Size = config.Size or UDim2.fromOffset(470, 270)
    local Center = config.Center ~= false
    local Draggable = config.Draggable ~= false
    local Resizable = config.Resize or false
    local MinimizeKey = config.MinimizeKey or Enum.KeyCode.RightShift
    local MinimizeButton = config.MinimizeButton or false
    local MinimizeButtonImage = config.MinimizeButton_Image or "rbxassetid://16932740082"
    local Badges = config.Badges or {}

    if ThemeSystem.ThemeColors[Theme] then
        ThemeSystem.CurrentTheme = Theme
    end

    if CoreGui:FindFirstChild("OrvionGui") then CoreGui.OrvionGui:Destroy() end
    if CoreGui:FindFirstChild("OrvionDropdownOverlay") then CoreGui.OrvionDropdownOverlay:Destroy() end
    if CoreGui:FindFirstChild("NotifyGui") then CoreGui.NotifyGui:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Name = "OrvionGui"
    ScreenGui.Parent = CoreGui

    local DropShadowHolder = Instance.new("Frame")
    DropShadowHolder.BackgroundTransparency = 1
    DropShadowHolder.BorderSizePixel = 0
    DropShadowHolder.Size = Size
    DropShadowHolder.ZIndex = 0
    DropShadowHolder.Name = "DropShadowHolder"
    DropShadowHolder.Parent = ScreenGui
    if Center then
        DropShadowHolder.Position = UDim2.new(0.5, -Size.X.Offset/2, 0.5, -Size.Y.Offset/2)
    end

    local DropShadow = Instance.new("ImageLabel")
    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3.fromRGB(15, 15, 15)
    DropShadow.ImageTransparency = 0.5
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
    DropShadow.BackgroundTransparency = 1
    DropShadow.BorderSizePixel = 0
    DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    DropShadow.Size = UDim2.new(1, 47, 1, 47)
    DropShadow.ZIndex = 0
    DropShadow.Name = "DropShadow"
    DropShadow.Parent = DropShadowHolder

    local Main = Instance.new("Frame")
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    Main.BackgroundTransparency = 0.1
    Main.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(1, -47, 1, -47)
    Main.Name = "Main"
    Main.Parent = DropShadow

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = Main

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(80, 80, 100)
    UIStroke.Thickness = 1.5
    UIStroke.LineJoinMode = Enum.LineJoinMode.Round
    UIStroke.Parent = Main

    -- Top bar
    local Top = Instance.new("Frame")
    Top.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Top.BackgroundTransparency = 0.999
    Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Top.BorderSizePixel = 0
    Top.Size = UDim2.new(1, 0, 0, 38)
    Top.Name = "Top"
    Top.Parent = Main

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = Title
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.BackgroundTransparency = 0.999
    TitleLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TitleLabel.BorderSizePixel = 0
    TitleLabel.Size = UDim2.new(1, -150, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.Parent = Top

    -- Badges
    local BadgeContainer = Instance.new("Frame")
    BadgeContainer.Name = "BadgeContainer"
    BadgeContainer.BackgroundTransparency = 1
    BadgeContainer.Size = UDim2.new(0, 0, 1, 0)
    BadgeContainer.Position = UDim2.new(0, TitleLabel.TextBounds.X + 15, 0, 0)
    BadgeContainer.Parent = Top

    local BadgeLayout = Instance.new("UIListLayout")
    BadgeLayout.FillDirection = Enum.FillDirection.Horizontal
    BadgeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    BadgeLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    BadgeLayout.Padding = UDim.new(0, 6)
    BadgeLayout.Parent = BadgeContainer

    local function UpdateBadgePosition()
        BadgeContainer.Position = UDim2.new(0, TitleLabel.TextBounds.X + 15, 0, 0)
    end
    TitleLabel:GetPropertyChangedSignal("TextBounds"):Connect(UpdateBadgePosition)

    for _, badgeText in ipairs(Badges) do
        local Badge = Instance.new("TextLabel")
        Badge.Name = "Badge"
        Badge.Font = Enum.Font.GothamBold
        Badge.Text = badgeText
        Badge.TextColor3 = Color3.fromRGB(255, 255, 255)
        Badge.TextSize = 10
        Badge.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Badge.BackgroundTransparency = 0.8
        Badge.BorderSizePixel = 0
        Badge.Size = UDim2.new(0, TextService:GetTextSize(badgeText, 10, Enum.Font.GothamBold, Vector2.new(999, 999)).X + 10, 0, 18)
        local BadgeCorner = Instance.new("UICorner")
        BadgeCorner.CornerRadius = UDim.new(0, 4)
        BadgeCorner.Parent = Badge
        Badge.Parent = BadgeContainer
    end

    -- Close button
    local Close = Instance.new("TextButton")
    Close.Font = Enum.Font.SourceSans
    Close.Text = ""
    Close.TextColor3 = Color3.fromRGB(0, 0, 0)
    Close.TextSize = 14
    Close.AnchorPoint = Vector2.new(1, 0.5)
    Close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Close.BackgroundTransparency = 0.999
    Close.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Close.BorderSizePixel = 0
    Close.Position = UDim2.new(1, -8, 0.5, 0)
    Close.Size = UDim2.new(0, 25, 0, 25)
    Close.Name = "Close"
    Close.Parent = Top

    local CloseIcon = Instance.new("ImageLabel")
    CloseIcon.Image = OrvionLib.Assets.Icons.Close
    CloseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    CloseIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CloseIcon.BackgroundTransparency = 0.999
    CloseIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CloseIcon.BorderSizePixel = 0
    CloseIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    CloseIcon.Size = UDim2.new(1, -8, 1, -8)
    CloseIcon.Parent = Close

    -- Minimize button
    local Min = Instance.new("TextButton")
    Min.Font = Enum.Font.SourceSans
    Min.Text = ""
    Min.TextColor3 = Color3.fromRGB(0, 0, 0)
    Min.TextSize = 14
    Min.AnchorPoint = Vector2.new(1, 0.5)
    Min.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Min.BackgroundTransparency = 0.999
    Min.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Min.BorderSizePixel = 0
    Min.Position = UDim2.new(1, -42, 0.5, 0)
    Min.Size = UDim2.new(0, 25, 0, 25)
    Min.Name = "Min"
    Min.Parent = Top

    local MinIcon = Instance.new("ImageLabel")
    MinIcon.Image = OrvionLib.Assets.Icons.Minimize
    MinIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    MinIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MinIcon.BackgroundTransparency = 0.999
    MinIcon.ImageTransparency = 0.2
    MinIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MinIcon.BorderSizePixel = 0
    MinIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    MinIcon.Size = UDim2.new(1, -9, 1, -9)
    MinIcon.Parent = Min

    -- Maximize/Restore button
    local MaxRestore = Instance.new("TextButton")
    MaxRestore.Font = Enum.Font.SourceSans
    MaxRestore.Text = ""
    MaxRestore.TextColor3 = Color3.fromRGB(0, 0, 0)
    MaxRestore.TextSize = 14
    MaxRestore.AnchorPoint = Vector2.new(1, 0.5)
    MaxRestore.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MaxRestore.BackgroundTransparency = 0.999
    MaxRestore.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MaxRestore.BorderSizePixel = 0
    MaxRestore.Position = UDim2.new(1, -78, 0.5, 0)
    MaxRestore.Size = UDim2.new(0, 25, 0, 25)
    MaxRestore.Name = "MaxRestore"
    MaxRestore.Parent = Top

    local MaxIcon = Instance.new("ImageLabel")
    MaxIcon.Image = OrvionLib.Assets.Icons.Max
    MaxIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    MaxIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MaxIcon.BackgroundTransparency = 0.999
    MaxIcon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    MaxIcon.BorderSizePixel = 0
    MaxIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    MaxIcon.Size = UDim2.new(1, -8, 1, -8)
    MaxIcon.Parent = MaxRestore

    -- Resize handle
    if Resizable then
        local ResizeHandle = Instance.new("TextButton")
        ResizeHandle.Name = "ResizeHandle"
        ResizeHandle.Text = ""
        ResizeHandle.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        ResizeHandle.BackgroundTransparency = 0.5
        ResizeHandle.BorderSizePixel = 0
        ResizeHandle.Size = UDim2.new(0, 15, 0, 15)
        ResizeHandle.Position = UDim2.new(1, -15, 1, -15)
        ResizeHandle.AutoButtonColor = false
        ResizeHandle.Parent = Main
        local ResizeCorner = Instance.new("UICorner")
        ResizeCorner.CornerRadius = UDim.new(0, 3)
        ResizeCorner.Parent = ResizeHandle
        local ResizeIcon = Instance.new("ImageLabel")
        ResizeIcon.Name = "ResizeIcon"
        ResizeIcon.Image = "rbxassetid://16932740082"
        ResizeIcon.BackgroundTransparency = 1
        ResizeIcon.Size = UDim2.new(0.7, 0, 0.7, 0)
        ResizeIcon.Position = UDim2.new(0.15, 0, 0.15, 0)
        ResizeIcon.Rotation = 90
        ResizeIcon.Parent = ResizeHandle
        MakeResizable(ResizeHandle, DropShadowHolder, Vector2.new(400, 300), Vector2.new(1200, 900), function(newSize)
            Main.Size = UDim2.new(1, -47, 1, -47)
        end)
    end

    -- Sidebar
    local TabFrame = Instance.new("Frame")
    TabFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 20)
    TabFrame.BackgroundTransparency = 0.55
    TabFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TabFrame.BorderSizePixel = 0
    TabFrame.Position = UDim2.new(0, 0, 0, 38)
    TabFrame.Size = UDim2.new(0, 120, 1, -38)
    TabFrame.Name = "TabFrame"
    TabFrame.ZIndex = 1
    TabFrame.Parent = Main

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabFrame

    -- Search bar
    local SearchBarFrame = Instance.new("Frame", TabFrame)
    SearchBarFrame.Name = "SearchBarFrame"
    SearchBarFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
    SearchBarFrame.BackgroundTransparency = 0
    SearchBarFrame.Position = UDim2.new(0, 12, 0, 10)
    SearchBarFrame.Size = UDim2.new(1, -24, 0, 22)
    SearchBarFrame.BorderSizePixel = 0
    local sc = Instance.new("UICorner", SearchBarFrame) sc.CornerRadius = UDim.new(0, 4)
    local sbs = Instance.new("UIStroke", SearchBarFrame) sbs.Color = Color3.fromRGB(60, 60, 75) sbs.Thickness = 1

    local SearchIcon = Instance.new("ImageLabel", SearchBarFrame)
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.AnchorPoint = Vector2.new(0, 0.5)
    SearchIcon.Position = UDim2.new(0, 4, 0.5, 0)
    SearchIcon.Size = UDim2.new(0, 14, 0, 14)
    SearchIcon.Image = "rbxassetid://117201889911802"
    SearchIcon.ScaleType = Enum.ScaleType.Fit

    local SearchInput = Instance.new("TextBox", SearchBarFrame)
    SearchInput.BackgroundTransparency = 1
    SearchInput.Position = UDim2.new(0, 22, 0, 0)
    SearchInput.Size = UDim2.new(1, -26, 1, 0)
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.PlaceholderText = "Search..."
    SearchInput.Text = ""
    SearchInput.TextColor3 = COLOR_WHITE
    SearchInput.TextSize = 11
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left

    -- Tab scroll
    local TabScroll = Instance.new("ScrollingFrame", TabFrame)
    TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabScroll.ScrollBarThickness = 0
    TabScroll.Active = true
    TabScroll.BackgroundTransparency = 1
    TabScroll.BorderSizePixel = 0
    TabScroll.Position = UDim2.new(0, 6, 0, 38)
    TabScroll.Size = UDim2.new(1, -12, 1, -82)
    TabScroll.Name = "TabScroll"

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 2)
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabScroll

    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabScroll.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y)
    end)

    -- Player Footer
    local PlayerFooter = Instance.new("Frame", TabFrame)
    PlayerFooter.Name = "PlayerFooter"
    PlayerFooter.BackgroundTransparency = 1
    PlayerFooter.Position = UDim2.new(0, 6, 1, -42)
    PlayerFooter.Size = UDim2.new(1, -12, 0, 38)
    PlayerFooter.BorderSizePixel = 0

    local AvatarContainer = Instance.new("Frame", PlayerFooter)
    AvatarContainer.BackgroundTransparency = 1
    AvatarContainer.Position = UDim2.new(0, 6, 0.5, -2)
    AvatarContainer.AnchorPoint = Vector2.new(0, 0.5)
    AvatarContainer.Size = UDim2.new(0, 24, 0, 24)

    local AvatarImg = Instance.new("ImageLabel", AvatarContainer)
    AvatarImg.BackgroundTransparency = 1
    AvatarImg.Size = UDim2.new(1, 0, 1, 0)
    AvatarImg.Image = "rbxassetid://0"
    pcall(function()
        local content, isReady = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        if isReady then AvatarImg.Image = content end
    end)
    local aic = Instance.new("UICorner", AvatarImg) aic.CornerRadius = UDim.new(1, 0)
    local AvatarStroke = Instance.new("UIStroke", AvatarImg)
    AvatarStroke.Color = Color3.fromRGB(120, 120, 135)
    AvatarStroke.Thickness = 1.5
    AvatarStroke.Transparency = 0.2

    local WelcomeLabel = Instance.new("TextLabel", PlayerFooter)
    WelcomeLabel.BackgroundTransparency = 1
    WelcomeLabel.Position = UDim2.new(0, 36, 0.5, -2)
    WelcomeLabel.AnchorPoint = Vector2.new(0, 0.5)
    WelcomeLabel.Size = UDim2.new(1, -40, 0, 16)
    WelcomeLabel.Font = Enum.Font.Gotham
    WelcomeLabel.TextColor3 = Color3.fromRGB(155, 155, 170)
    WelcomeLabel.TextSize = 10
    WelcomeLabel.TextXAlignment = Enum.TextXAlignment.Left
    WelcomeLabel.TextWrapped = false
    WelcomeLabel.TextTruncate = Enum.TextTruncate.AtEnd
    pcall(function()
        local rawName = tostring(LocalPlayer.Name)
        local maskedName = string.sub(rawName, 1, 3) .. "***"
        WelcomeLabel.Text = "Welcome, " .. maskedName
    end)

    -- Content frame (no title label)
    local ContentFrame = Instance.new("Frame")
    ContentFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ContentFrame.BackgroundTransparency = 0.999
    ContentFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Position = UDim2.new(0, 128, 0, 42)
    ContentFrame.Size = UDim2.new(0, 330, 0, 205)
    ContentFrame.Name = "ContentFrame"
    ContentFrame.ZIndex = 1
    ContentFrame.Parent = Main

    local ContentScroll = Instance.new("ScrollingFrame")
    ContentScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80)
    ContentScroll.ScrollBarThickness = 0
    ContentScroll.Active = true
    ContentScroll.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ContentScroll.BackgroundTransparency = 0.999
    ContentScroll.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ContentScroll.BorderSizePixel = 0
    ContentScroll.ClipsDescendants = true
    ContentScroll.Position = UDim2.new(0, 0, 0, 0)
    ContentScroll.Size = UDim2.new(1, 0, 1, 0)
    ContentScroll.Name = "ContentScroll"
    ContentScroll.Parent = ContentFrame

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.Padding = UDim.new(0, 8)
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Parent = ContentScroll

    -- Button actions
    Close.Activated:Connect(function()
        CircleClick(Close, Mouse.X, Mouse.Y)
        ScreenGui:Destroy()
        if CoreGui:FindFirstChild("OrvionDropdownOverlay") then CoreGui.OrvionDropdownOverlay:Destroy() end
        if CoreGui:FindFirstChild("NotifyGui") then CoreGui.NotifyGui:Destroy() end
    end)

    local minimized = false
    Min.Activated:Connect(function()
        CircleClick(Min, Mouse.X, Mouse.Y)
        minimized = not minimized
        if minimized then
            DropShadowHolder:TweenSize(UDim2.new(0, Size.X.Offset, 0, 38), "Out", "Quart", 0.3, true)
            TabFrame.Visible = false
            ContentFrame.Visible = false
        else
            DropShadowHolder:TweenSize(UDim2.new(0, Size.X.Offset, 0, Size.Y.Offset), "Out", "Quart", 0.3, true)
            TabFrame.Visible = true
            ContentFrame.Visible = true
        end
    end)

    local OldPos = DropShadowHolder.Position
    local OldSize = DropShadowHolder.Size
    MaxRestore.Activated:Connect(function()
        CircleClick(MaxRestore, Mouse.X, Mouse.Y)
        if MaxIcon.Image == OrvionLib.Assets.Icons.Max then
            MaxIcon.Image = OrvionLib.Assets.Icons.Restore
            OldPos = DropShadowHolder.Position
            OldSize = DropShadowHolder.Size
            TweenService:Create(DropShadowHolder, TweenInfo.new(0.3), {Position = UDim2.new(0, 0, 0, 0)}):Play()
            TweenService:Create(DropShadowHolder, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        else
            MaxIcon.Image = OrvionLib.Assets.Icons.Max
            TweenService:Create(DropShadowHolder, TweenInfo.new(0.3), {Position = OldPos}):Play()
            TweenService:Create(DropShadowHolder, TweenInfo.new(0.3), {Size = OldSize}):Play()
        end
    end)

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == MinimizeKey then
            DropShadowHolder.Visible = not DropShadowHolder.Visible
        end
    end)

    if Draggable then
        MakeDraggable(Top, DropShadowHolder)
    end

    -- Mobile minimize button
    if MinimizeButton then
        local MobileMinimizeButton = Instance.new("Frame")
        MobileMinimizeButton.Name = "MobileMinimizeButton"
        MobileMinimizeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        MobileMinimizeButton.BackgroundTransparency = 0.2
        MobileMinimizeButton.BorderSizePixel = 0
        MobileMinimizeButton.Size = UDim2.new(0, 50, 0, 50)
        MobileMinimizeButton.Position = UDim2.new(0, 20, 0, 100)
        MobileMinimizeButton.ZIndex = 100
        MobileMinimizeButton.Parent = ScreenGui

        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(1, 0)
        ButtonCorner.Parent = MobileMinimizeButton

        local ButtonStroke = Instance.new("UIStroke")
        ButtonStroke.Color = Color3.fromRGB(255, 255, 255)
        ButtonStroke.Thickness = 0
        ButtonStroke.Parent = MobileMinimizeButton

        local ButtonImage = Instance.new("ImageLabel")
        ButtonImage.Name = "ButtonImage"
        ButtonImage.Image = MinimizeButtonImage
        ButtonImage.BackgroundTransparency = 1
        ButtonImage.Size = UDim2.new(0.7, 0, 0.7, 0)
        ButtonImage.Position = UDim2.new(0.15, 0, 0.15, 0)
        ButtonImage.ZIndex = 101
        ButtonImage.Parent = MobileMinimizeButton

        local ClickDetector = Instance.new("TextButton")
        ClickDetector.Name = "ClickDetector"
        ClickDetector.Text = ""
        ClickDetector.BackgroundTransparency = 1
        ClickDetector.Size = UDim2.new(1, 0, 1, 0)
        ClickDetector.ZIndex = 102
        ClickDetector.Parent = MobileMinimizeButton

        local isDragging = MakeDraggableMobileButton(ClickDetector, MobileMinimizeButton, ScreenGui)
        local lastClick = 0
        ClickDetector.Activated:Connect(function()
            local now = tick()
            if now - lastClick < 0.3 then return end
            lastClick = now
            if not isDragging() then
                DropShadowHolder.Visible = not DropShadowHolder.Visible
                TweenService:Create(MobileMinimizeButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 45, 0, 45)}):Play()
                task.wait(0.1)
                TweenService:Create(MobileMinimizeButton, TweenInfo.new(0.1), {Size = UDim2.new(0, 50, 0, 50)}):Play()
            end
        end)
    end

    -- Tab and content management
    local TabContents = {}
    local CurrentTab = nil
    local AllElements = {}

    local function UpdateTabSize()
        local OffsetY = 0
        for _, child in TabScroll:GetChildren() do
            if child:IsA("Frame") then
                OffsetY = OffsetY + 2 + child.Size.Y.Offset
            end
        end
        TabScroll.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
    end

    local function UpdateContentSize()
        if CurrentTab and TabContents[CurrentTab] then
            local OffsetY = 0
            for _, child in TabContents[CurrentTab]:GetChildren() do
                if child:IsA("Frame") then
                    OffsetY = OffsetY + 8 + child.Size.Y.Offset
                end
            end
            ContentScroll.CanvasSize = UDim2.new(0, 0, 0, OffsetY)
        end
    end

    TabScroll.ChildAdded:Connect(UpdateTabSize)
    TabScroll.ChildRemoved:Connect(UpdateTabSize)

    local Window = {}
    local tabs = {}
    local firstTab = true

    function Window:AddTab(tabName)
        local TabButton = Instance.new("TextButton", TabScroll)
        TabButton.BackgroundColor3 = COLOR_SECTION_BG
        TabButton.BackgroundTransparency = 1
        TabButton.Size = UDim2.new(1, 0, 0, 26)
        TabButton.Font = Enum.Font.GothamBold
        TabButton.Text = "     " .. tabName
        TabButton.TextColor3 = Color3.fromRGB(160, 160, 175)
        TabButton.TextSize = CONFIG_FONT_GENERAL
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.BorderSizePixel = 0
        local tabCorner = Instance.new("UICorner", TabButton)
        tabCorner.CornerRadius = UDim.new(0, 4)

        local Indicator = Instance.new("Frame", TabButton)
        Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Indicator.Size = UDim2.new(0, 5, 0.7, 0)
        Indicator.AnchorPoint = Vector2.new(0, 0.5)
        Indicator.Position = UDim2.new(0, 0, 0.5, 0)
        Indicator.BorderSizePixel = 0
        Indicator.Visible = false
        Indicator.Name = "Indicator"
        local indCorner = Instance.new("UICorner", Indicator) indCorner.CornerRadius = UDim.new(1, 0)

        local TabContent = Instance.new("ScrollingFrame", ContentScroll)
        TabContent.Name = "TabContent"
        TabContent.BackgroundTransparency = 1
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContent.ScrollBarThickness = 0
        TabContent.Visible = false

        TabContent:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
            if Main:FindFirstChild("ActiveDropdown") then Main:FindFirstChild("ActiveDropdown"):Destroy() end
            if Main:FindFirstChild("DropOutsideClick") then Main:FindFirstChild("DropOutsideClick"):Destroy() end
        end)

        local ContentLayout = Instance.new("UIListLayout", TabContent)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 5)
        ContentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        local ContentPadding = Instance.new("UIPadding", TabContent)
        ContentPadding.PaddingLeft  = UDim.new(0, 4)
        ContentPadding.PaddingRight = UDim.new(0, 4)
        ContentPadding.PaddingTop   = UDim.new(0, 4)

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
        end)

        if firstTab then
            TabContent.Visible = true
            CurrentTab = TabContent
            TabContents[TabContent] = TabContent
            TabButton.BackgroundTransparency = 0.4
            TabButton.TextColor3 = COLOR_WHITE
            Indicator.Visible = true
            firstTab = false
        end

        TabButton.MouseButton1Click:Connect(function()
            if Main:FindFirstChild("ActiveDropdown") then Main:FindFirstChild("ActiveDropdown"):Destroy() end
            if Main:FindFirstChild("DropOutsideClick") then Main:FindFirstChild("DropOutsideClick"):Destroy() end
            for _, t in pairs(tabs) do
                t.Content.Visible = false
                t.Button.BackgroundTransparency = 1
                t.Button.TextColor3 = Color3.fromRGB(160, 160, 175)
                t.Indicator.Visible = false
            end
            TabContent.Visible = true
            CurrentTab = TabContent
            TabButton.BackgroundTransparency = 0.4
            TabButton.TextColor3 = COLOR_WHITE
            Indicator.Visible = true
        end)

        table.insert(tabs, {Button = TabButton, Indicator = Indicator, Content = TabContent})

        -- Search functionality
        SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
            local query = SearchInput.Text:lower()
            for _, t in pairs(tabs) do
                if query == "" then
                    t.Button.Visible = true
                else
                    t.Button.Visible = t.Button.Text:lower():find(query) ~= nil
                end
            end
            UpdateTabSize()
        end)

        local TabAPI = {}

        local function createElementAPI(parentContainer)
            local ElementAPI = {}

            function ElementAPI:AddParagraph(cfg)
                cfg = cfg or {}
                local ParaFrame = Instance.new("Frame", parentContainer)
                ParaFrame.BackgroundColor3 = COLOR_SECTION_BG
                ParaFrame.BackgroundTransparency = 0.4
                ParaFrame.Size = UDim2.new(1, 0, 0, 0)
                ParaFrame.AutomaticSize = Enum.AutomaticSize.Y
                ParaFrame.BorderSizePixel = 0
                local paraCorner = Instance.new("UICorner", ParaFrame) paraCorner.CornerRadius = UDim.new(0, 6)
                local paraStroke = Instance.new("UIStroke", ParaFrame) paraStroke.Color = Color3.fromRGB(60, 60, 75) paraStroke.Thickness = 1 paraStroke.Transparency = 0.5

                local paraPadding = Instance.new("UIPadding", ParaFrame)
                paraPadding.PaddingTop    = UDim.new(0, 8)
                paraPadding.PaddingBottom = UDim.new(0, 8)
                paraPadding.PaddingLeft   = UDim.new(0, 10)
                paraPadding.PaddingRight  = UDim.new(0, 10)

                local paraLayout = Instance.new("UIListLayout", ParaFrame)
                paraLayout.SortOrder = Enum.SortOrder.LayoutOrder
                paraLayout.Padding = UDim.new(0, 4)
                paraLayout.FillDirection = Enum.FillDirection.Vertical

                local Title = Instance.new("TextLabel", ParaFrame)
                Title.LayoutOrder = 1
                Title.BackgroundTransparency = 1
                Title.Size = UDim2.new(1, 0, 0, 20)
                Title.Font = Enum.Font.GothamBold
                Title.Text = cfg.Title or "Title"
                Title.TextColor3 = COLOR_WHITE
                Title.TextSize = CONFIG_FONT_SECTION
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local Desc = Instance.new("TextLabel", ParaFrame)
                Desc.LayoutOrder = 2
                Desc.BackgroundTransparency = 1
                Desc.Size = UDim2.new(1, 0, 0, 0)
                Desc.AutomaticSize = Enum.AutomaticSize.Y
                Desc.Font = Enum.Font.Gotham
                Desc.Text = cfg.Content or "Content"
                Desc.TextColor3 = COLOR_SIDEBAR_LOG
                Desc.TextSize = CONFIG_FONT_GENERAL
                Desc.TextXAlignment = Enum.TextXAlignment.Left
                Desc.TextYAlignment = Enum.TextYAlignment.Top
                Desc.TextWrapped = true

                local f = {}
                function f:SetDesc(txt) Desc.Text = txt end
                UpdateContentSize()
                return f
            end

            function ElementAPI:AddButton(cfg)
                cfg = cfg or {}
                local Btn = Instance.new("TextButton", parentContainer)
                Btn.BackgroundColor3 = COLOR_SECTION_BG
                Btn.BackgroundTransparency = 0.4
                Btn.Size = UDim2.new(1, 0, 0, CONFIG_ELEMENT_HEIGHT)
                Btn.Text = ""
                Btn.AutoButtonColor = true
                Btn.BorderSizePixel = 0
                local bc = Instance.new("UICorner", Btn) bc.CornerRadius = UDim.new(0, 6)
                local bcs = Instance.new("UIStroke", Btn) bcs.Color = Color3.fromRGB(60, 60, 75) bcs.Thickness = 1 bcs.Transparency = 0.5

                local Title = Instance.new("TextLabel", Btn)
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.Size = UDim2.new(1, -40, 1, 0)
                Title.Font = Enum.Font.GothamBold
                Title.Text = cfg.Title or "Button"
                Title.TextColor3 = COLOR_WHITE
                Title.TextSize = CONFIG_FONT_GENERAL
                Title.TextXAlignment = Enum.TextXAlignment.Left

                if cfg.Icon then
                    local iconId = cfg.Icon
                    if string.match(iconId, "rbxassetid://(%d+)") then
                        iconId = "rbxthumb://type=Asset&id=" .. string.match(iconId, "rbxassetid://(%d+)") .. "&w=150&h=150"
                    elseif string.match(iconId, "^%d+$") then
                        iconId = "rbxthumb://type=Asset&id=" .. iconId .. "&w=150&h=150"
                    end
                    local BtnIcon = Instance.new("ImageLabel", Btn)
                    BtnIcon.BackgroundTransparency = 1
                    BtnIcon.AnchorPoint = Vector2.new(1, 0.5)
                    BtnIcon.Position = UDim2.new(1, -12, 0.5, 0)
                    BtnIcon.Size = UDim2.new(0, 15, 0, 15)
                    BtnIcon.Image = iconId
                    BtnIcon.ScaleType = Enum.ScaleType.Fit
                end

                Btn.MouseButton1Click:Connect(function()
                    if cfg.Callback then pcall(cfg.Callback) end
                end)
                UpdateContentSize()
            end

            function ElementAPI:AddButtonGrid(btn1Config, btn2Config)
                local GridFrame = Instance.new("Frame", parentContainer)
                GridFrame.BackgroundTransparency = 1
                GridFrame.Size = UDim2.new(1, 0, 0, CONFIG_ELEMENT_HEIGHT)
                GridFrame.BorderSizePixel = 0

                local layout = Instance.new("UIListLayout", GridFrame)
                layout.FillDirection = Enum.FillDirection.Horizontal
                layout.SortOrder = Enum.SortOrder.LayoutOrder
                layout.Padding = UDim.new(0, 6)
                layout.VerticalAlignment = Enum.VerticalAlignment.Center

                local function createHalfButton(cfg, order)
                    cfg = cfg or {}
                    local Btn = Instance.new("TextButton", GridFrame)
                    Btn.LayoutOrder = order
                    Btn.BackgroundColor3 = COLOR_SECTION_BG
                    Btn.BackgroundTransparency = 0.4
                    Btn.Size = UDim2.new(0.5, -3, 1, 0)
                    Btn.Text = ""
                    Btn.AutoButtonColor = true
                    Btn.BorderSizePixel = 0
                    local bc = Instance.new("UICorner", Btn) bc.CornerRadius = UDim.new(0, 6)
                    local bcs = Instance.new("UIStroke", Btn) bcs.Color = Color3.fromRGB(60, 60, 75) bcs.Thickness = 1 bcs.Transparency = 0.5

                    local Title = Instance.new("TextLabel", Btn)
                    Title.BackgroundTransparency = 1
                    Title.Size = UDim2.new(1, 0, 1, 0)
                    Title.Font = Enum.Font.GothamBold
                    Title.Text = cfg.Title or "Button"
                    Title.TextColor3 = COLOR_WHITE
                    Title.TextSize = CONFIG_FONT_GENERAL
                    Title.TextXAlignment = Enum.TextXAlignment.Center

                    Btn.MouseButton1Click:Connect(function()
                        if cfg.Callback then pcall(cfg.Callback) end
                    end)
                end

                createHalfButton(btn1Config, 1)
                createHalfButton(btn2Config, 2)
                UpdateContentSize()
            end

            function ElementAPI:AddToggle(cfg)
                cfg = cfg or {}
                local ToggleFrame = Instance.new("Frame", parentContainer)
                ToggleFrame.BackgroundColor3 = COLOR_SECTION_BG
                ToggleFrame.BackgroundTransparency = 0.4
                ToggleFrame.Size = UDim2.new(1, 0, 0, CONFIG_ELEMENT_HEIGHT)
                ToggleFrame.BorderSizePixel = 0
                local tfc = Instance.new("UICorner", ToggleFrame) tfc.CornerRadius = UDim.new(0, 6)
                local tfcs = Instance.new("UIStroke", ToggleFrame) tfcs.Color = Color3.fromRGB(60, 60, 75) tfcs.Thickness = 1 tfcs.Transparency = 0.5

                local Title = Instance.new("TextLabel", ToggleFrame)
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 10, 0, 0)
                Title.Size = UDim2.new(1, -55, 1, 0)
                Title.Font = Enum.Font.GothamBold
                Title.Text = cfg.Title or "Toggle"
                Title.TextColor3 = COLOR_WHITE
                Title.TextSize = CONFIG_FONT_GENERAL
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local SwitchBg = Instance.new("Frame", ToggleFrame)
                SwitchBg.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
                SwitchBg.Position = UDim2.new(1, -38, 0.5, -9)
                SwitchBg.Size = UDim2.new(0, 32, 0, 18)
                local sbc = Instance.new("UICorner", SwitchBg) sbc.CornerRadius = UDim.new(1, 0)

                local Knob = Instance.new("Frame", SwitchBg)
                Knob.BackgroundColor3 = COLOR_WHITE
                Knob.Position = UDim2.new(0, 2, 0.5, -7)
                Knob.Size = UDim2.new(0, 14, 0, 14)
                local kc = Instance.new("UICorner", Knob) kc.CornerRadius = UDim.new(1, 0)

                local state = cfg.Default == true
                local function updateVisual(anim)
                    if state then
                        SwitchBg.BackgroundColor3 = Color3.fromRGB(170, 170, 185)
                        Knob.BackgroundColor3 = COLOR_WHITE
                        if anim then TweenService:Create(Knob, TweenInfo.new(0.15), {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
                        else Knob.Position = UDim2.new(1, -16, 0.5, -7) end
                    else
                        SwitchBg.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
                        Knob.BackgroundColor3 = COLOR_WHITE
                        if anim then TweenService:Create(Knob, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
                        else Knob.Position = UDim2.new(0, 2, 0.5, -7) end
                    end
                end
                updateVisual(false)

                local btn = Instance.new("TextButton", ToggleFrame)
                btn.BackgroundTransparency = 1
                btn.Size = UDim2.new(1, 0, 1, 0)
                btn.Text = ""
                btn.MouseButton1Click:Connect(function()
                    state = not state
                    updateVisual(true)
                    if cfg.Callback then pcall(cfg.Callback, state) end
                end)

                UpdateContentSize()
                local tAPI = {}
                function tAPI:SetValue(val)
                    state = val
                    updateVisual(true)
                    if cfg.Callback then pcall(cfg.Callback, state) end
                end
                return tAPI
            end

            function ElementAPI:AddInput(cfg)
                cfg = cfg or {}
                local InputFrame = Instance.new("Frame", parentContainer)
                InputFrame.BackgroundColor3 = COLOR_SECTION_BG
                InputFrame.BackgroundTransparency = 0.4
                InputFrame.Size = UDim2.new(1, 0, 0, 64)
                InputFrame.BorderSizePixel = 0
                local ifc = Instance.new("UICorner", InputFrame) ifc.CornerRadius = UDim.new(0, 6)
                local ifcs = Instance.new("UIStroke", InputFrame) ifcs.Color = Color3.fromRGB(60, 60, 75) ifcs.Thickness = 1 ifcs.Transparency = 0.5

                local Title = Instance.new("TextLabel", InputFrame)
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 10, 0, 6)
                Title.Size = UDim2.new(1, -20, 0, 20)
                Title.Font = Enum.Font.GothamBold
                Title.Text = cfg.Title or "Input"
                Title.TextColor3 = COLOR_WHITE
                Title.TextSize = CONFIG_FONT_GENERAL
                Title.TextXAlignment = Enum.TextXAlignment.Left

                local TextBoxBg = Instance.new("Frame", InputFrame)
                TextBoxBg.BackgroundColor3 = COLOR_INTERACTIVE_BG
                TextBoxBg.BackgroundTransparency = 0.2
                TextBoxBg.Position = UDim2.new(0, 10, 0, 31)
                TextBoxBg.Size = UDim2.new(1, -20, 0, 26)
                TextBoxBg.BorderSizePixel = 0
                local tbc = Instance.new("UICorner", TextBoxBg) tbc.CornerRadius = UDim.new(0, 4)

                local TextBox = Instance.new("TextBox", TextBoxBg)
                TextBox.BackgroundTransparency = 1
                TextBox.Position = UDim2.new(0, 8, 0, 0)
                TextBox.Size = UDim2.new(1, -16, 1, 0)
                TextBox.Font = Enum.Font.GothamBold
                TextBox.Text = cfg.Default or ""
                TextBox.PlaceholderText = cfg.Placeholder or "Enter..."
                TextBox.TextColor3 = COLOR_WHITE
                TextBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 165)
                TextBox.TextSize = CONFIG_FONT_GENERAL
                TextBox.TextXAlignment = Enum.TextXAlignment.Left
                TextBox.BorderSizePixel = 0

                TextBox:GetPropertyChangedSignal("Text"):Connect(function()
                    if cfg.Callback then pcall(cfg.Callback, TextBox.Text) end
                end)

                UpdateContentSize()
                local iAPI = {}
                function iAPI:GetValue() return TextBox.Text end
                function iAPI:SetValue(val)
                    TextBox.Text = tostring(val)
                    if cfg.Callback then pcall(cfg.Callback, TextBox.Text) end
                end
                return iAPI
            end

            function ElementAPI:AddDropdown(cfg)
                cfg = cfg or {}
                local DropFrame = Instance.new("Frame", parentContainer)
                DropFrame.BackgroundColor3 = COLOR_SECTION_BG
                DropFrame.BackgroundTransparency = 0.4
                DropFrame.Size = UDim2.new(1, 0, 0, CONFIG_ELEMENT_HEIGHT)
                DropFrame.BorderSizePixel = 0
                local dfc = Instance.new("UICorner", DropFrame) dfc.CornerRadius = UDim.new(0, 6)
                local dfcs = Instance.new("UIStroke", DropFrame) dfcs.Color = Color3.fromRGB(60, 60, 75) dfcs.Thickness = 1 dfcs.Transparency = 0.5

                local Title = Instance.new("TextLabel", DropFrame)
                Title.BackgroundTransparency = 1
                Title.Position = UDim2.new(0, 10, 0, 10)
                Title.Size = UDim2.new(0.45, 0, 1, 0)
                Title.Font = Enum.Font.GothamBold
                Title.Text = cfg.Title or "Dropdown"
                Title.TextColor3 = COLOR_WHITE
                Title.TextSize = CONFIG_FONT_GENERAL
                Title.TextXAlignment = Enum.TextXAlignment.Left
                Title.TextYAlignment = Enum.TextYAlignment.Top

                local SelectBox = Instance.new("Frame", DropFrame)
                SelectBox.BackgroundColor3 = COLOR_INTERACTIVE_BG
                SelectBox.BackgroundTransparency = 0.2
                SelectBox.Size = UDim2.new(0.48, 0, 0, 26)
                SelectBox.Position = UDim2.new(1, -4, 0.5, 0)
                SelectBox.AnchorPoint = Vector2.new(1, 0.5)
                SelectBox.BorderSizePixel = 0
                local sbc2 = Instance.new("UICorner", SelectBox) sbc2.CornerRadius = UDim.new(0, 4)

                local selectedVal = cfg.DefaultValue or ""

                local SelectLabel = Instance.new("TextLabel", SelectBox)
                SelectLabel.BackgroundTransparency = 1
                SelectLabel.Size = UDim2.new(1, -26, 1, 0)
                SelectLabel.Position = UDim2.new(0, 8, 0, 0)
                SelectLabel.Font = Enum.Font.GothamBold
                SelectLabel.Text = tostring(selectedVal)
                SelectLabel.TextColor3 = COLOR_SIDEBAR_LOG
                SelectLabel.TextScaled = true
                SelectLabel.TextXAlignment = Enum.TextXAlignment.Left
                SelectLabel.BorderSizePixel = 0
                local _tsc = Instance.new("UITextSizeConstraint", SelectLabel)
                _tsc.MinTextSize = 8
                _tsc.MaxTextSize = CONFIG_FONT_DROPDOWN

                local DropArrow = Instance.new("ImageLabel", SelectBox)
                DropArrow.BackgroundTransparency = 1
                DropArrow.AnchorPoint = Vector2.new(1, 0.5)
                DropArrow.Position = UDim2.new(1, -4, 0.5, 0)
                DropArrow.Size = UDim2.new(0, 24, 0, 24)
                DropArrow.Image = OrvionLib.Assets.Icons.Arrow
                DropArrow.ImageTransparency = 0.4
                DropArrow.Rotation = 0

                local SelectBtn = Instance.new("TextButton", SelectBox)
                SelectBtn.BackgroundTransparency = 1
                SelectBtn.Size = UDim2.new(1, 0, 1, 0)
                SelectBtn.Text = ""

                local function closeDropdown()
                    local existing = Main:FindFirstChild("ActiveDropdown")
                    if existing then existing:Destroy() end
                    local oc = Main:FindFirstChild("DropOutsideClick")
                    if oc then oc:Destroy() end
                end

                SelectBtn.MouseButton1Click:Connect(function()
                    if Main:FindFirstChild("ActiveDropdown") then closeDropdown(); return end

                    local OutsideClick = Instance.new("TextButton", Main)
                    OutsideClick.Name = "DropOutsideClick"
                    OutsideClick.Size = UDim2.new(0, 296, 1, 0)
                    OutsideClick.Position = UDim2.new(0, 0, 0, 0)
                    OutsideClick.BackgroundTransparency = 1
                    OutsideClick.Text = ""
                    OutsideClick.ZIndex = 9
                    OutsideClick.MouseButton1Click:Connect(function() closeDropdown() end)

                    local popStartY = 42
                    local popHeight = Main.AbsoluteSize.Y - popStartY - 4
                    local PopFrame = Instance.new("ScrollingFrame", Main)
                    PopFrame.Name = "ActiveDropdown"
                    PopFrame.BackgroundColor3 = COLOR_INTERACTIVE_BG
                    PopFrame.BackgroundTransparency = 0.05
                    PopFrame.Position = UDim2.new(0, 296, 0, popStartY)
                    PopFrame.Size = UDim2.new(0, 162, 0, math.min(popHeight, 200))
                    PopFrame.CanvasSize = UDim2.new(0, 0, 0, #(cfg.Values or {}) * 36)
                    PopFrame.ScrollBarThickness = 2
                    PopFrame.BorderSizePixel = 0
                    PopFrame.ZIndex = 10
                    local pfc = Instance.new("UICorner", PopFrame) pfc.CornerRadius = UDim.new(0, 6)
                    local pfs = Instance.new("UIStroke", PopFrame) pfs.Color = Color3.fromRGB(70, 70, 90) pfs.Thickness = 1.2

                    local popLayout = Instance.new("UIListLayout", PopFrame)
                    popLayout.SortOrder = Enum.SortOrder.LayoutOrder

                    local optionElements = {}

                    local function refreshHighlights()
                        for val, elements in pairs(optionElements) do
                            if val == selectedVal then
                                elements.Btn.BackgroundColor3 = COLOR_SECTION_BG
                                elements.Btn.BackgroundTransparency = 0.3
                                elements.Indicator.Visible = true
                            else
                                elements.Btn.BackgroundColor3 = COLOR_INTERACTIVE_BG
                                elements.Btn.BackgroundTransparency = 1
                                elements.Indicator.Visible = false
                            end
                        end
                    end

                    for _, val in ipairs(cfg.Values or {}) do
                        local optBtn = Instance.new("TextButton", PopFrame)
                        optBtn.BackgroundColor3 = COLOR_INTERACTIVE_BG
                        optBtn.BackgroundTransparency = 1
                        optBtn.Size = UDim2.new(1, 0, 0, 36)
                        optBtn.Text = ""
                        optBtn.AutoButtonColor = false
                        optBtn.BorderSizePixel = 0
                        optBtn.ZIndex = 11
                        local optCorner = Instance.new("UICorner", optBtn) optCorner.CornerRadius = UDim.new(0, 4)

                        local ind = Instance.new("Frame", optBtn)
                        ind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        ind.Size = UDim2.new(0, 3, 0, 16)
                        ind.Position = UDim2.new(0, 2, 0.5, -8)
                        ind.BorderSizePixel = 0
                        ind.Visible = false
                        local indCorner2 = Instance.new("UICorner", ind) indCorner2.CornerRadius = UDim.new(1, 0)

                        local lbl = Instance.new("TextLabel", optBtn)
                        lbl.BackgroundTransparency = 1
                        lbl.Position = UDim2.new(0, 12, 0, 0)
                        lbl.Size = UDim2.new(1, -12, 1, 0)
                        lbl.Font = Enum.Font.GothamBold
                        lbl.Text = tostring(val)
                        lbl.TextColor3 = COLOR_SIDEBAR_LOG
                        lbl.TextSize = CONFIG_FONT_DROPDOWN
                        lbl.TextXAlignment = Enum.TextXAlignment.Left

                        optionElements[val] = {Btn = optBtn, Indicator = ind}

                        optBtn.MouseButton1Click:Connect(function()
                            selectedVal = val
                            SelectLabel.Text = tostring(val)
                            refreshHighlights()
                            if cfg.Callback then pcall(cfg.Callback, val) end
                        end)
                    end

                    refreshHighlights()
                end)

                UpdateContentSize()
                local dAPI = {}
                function dAPI:SetValue(val)
                    selectedVal = val
                    SelectLabel.Text = tostring(val)
                    if cfg.Callback then pcall(cfg.Callback, val) end
                end
                function dAPI:SetValues(newVals) cfg.Values = newVals end
                return dAPI
            end

            function ElementAPI:AddCollapsibleSection(title, defaultOpen)
                defaultOpen = defaultOpen == true

                local SectionFrame = Instance.new("Frame", parentContainer)
                SectionFrame.BackgroundTransparency = 1
                SectionFrame.Size = UDim2.new(1, 0, 0, 34)
                SectionFrame.BorderSizePixel = 0
                SectionFrame.ClipsDescendants = true

                local HeaderBtn = Instance.new("TextButton", SectionFrame)
                HeaderBtn.BackgroundTransparency = 1
                HeaderBtn.Size = UDim2.new(1, 0, 0, 34)
                HeaderBtn.Font = Enum.Font.GothamBold
                HeaderBtn.Text = "  " .. (title or "Section")
                HeaderBtn.TextColor3 = defaultOpen and COLOR_WHITE or COLOR_DARK_GRAY
                HeaderBtn.TextSize = CONFIG_FONT_SECTION
                HeaderBtn.TextXAlignment = Enum.TextXAlignment.Left

                local SectionArrow = Instance.new("ImageLabel", HeaderBtn)
                SectionArrow.BackgroundTransparency = 1
                SectionArrow.AnchorPoint = Vector2.new(1, 0.5)
                SectionArrow.Position = UDim2.new(1, -6, 0.5, 0)
                SectionArrow.Size = UDim2.new(0, 22, 0, 22)
                SectionArrow.Image = OrvionLib.Assets.Icons.Arrow
                SectionArrow.ImageTransparency = 0.4
                SectionArrow.Rotation = defaultOpen and 0 or -90

                local InnerContainer = Instance.new("Frame", SectionFrame)
                InnerContainer.BackgroundTransparency = 1
                InnerContainer.Position = UDim2.new(0, 0, 0, 34)
                InnerContainer.Size = UDim2.new(1, 0, 0, 0)

                local TheInnerLayout = Instance.new("UIListLayout", InnerContainer)
                TheInnerLayout.SortOrder = Enum.SortOrder.LayoutOrder
                TheInnerLayout.Padding = UDim.new(0, 5)
                TheInnerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
                local InnerPadding = Instance.new("UIPadding", InnerContainer)
                InnerPadding.PaddingLeft  = UDim.new(0, 0)
                InnerPadding.PaddingRight = UDim.new(0, 0)

                local isOpen = defaultOpen

                local function closeOpenDropdowns()
                    if Main:FindFirstChild("ActiveDropdown") then Main:FindFirstChild("ActiveDropdown"):Destroy() end
                    if Main:FindFirstChild("DropOutsideClick") then Main:FindFirstChild("DropOutsideClick"):Destroy() end
                end

                local function updateSize()
                    local contentHeight = TheInnerLayout.AbsoluteContentSize.Y + 8
                    if isOpen then
                        InnerContainer.Size = UDim2.new(1, 0, 0, contentHeight)
                        SectionFrame.Size = UDim2.new(1, 0, 0, 34 + contentHeight)
                        TweenService:Create(SectionArrow, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = 0}):Play()
                        TweenService:Create(HeaderBtn, TweenInfo.new(0.2), {TextColor3 = COLOR_WHITE}):Play()
                    else
                        InnerContainer.Size = UDim2.new(1, 0, 0, 0)
                        SectionFrame.Size = UDim2.new(1, 0, 0, 34)
                        TweenService:Create(SectionArrow, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Rotation = -90}):Play()
                        TweenService:Create(HeaderBtn, TweenInfo.new(0.2), {TextColor3 = COLOR_DARK_GRAY}):Play()
                    end
                end

                TheInnerLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if isOpen then updateSize() end
                end)

                HeaderBtn.MouseButton1Click:Connect(function()
                    closeOpenDropdowns()
                    isOpen = not isOpen
                    updateSize()
                end)

                updateSize()
                return createElementAPI(InnerContainer)
            end

            return ElementAPI
        end

        local mainTabAPI = createElementAPI(TabContent)
        for k, v in pairs(mainTabAPI) do TabAPI[k] = v end

        return TabAPI
    end

    -- ==========================================
    -- CONFIG TAB
    -- ==========================================
    function Window:AddConfigTab(options)
        options = options or {}
        local ROOT_FOLDER = options.Folder or "OrvionConfig"
        local SUB_FOLDER  = options.SubFolder or "Config"
        local CONFIG_DIR  = ROOT_FOLDER .. "/" .. SUB_FOLDER
        local AUTOLOAD_FILE = CONFIG_DIR .. "/_autoload.txt"
        local SETTINGS    = options.Settings or {}

        if not isfolder(ROOT_FOLDER) then makefolder(ROOT_FOLDER) end
        if not isfolder(CONFIG_DIR)  then makefolder(CONFIG_DIR)  end

        local selectedConfigName = ""
        local inputConfigName    = ""

        local ConfigTab = Window:AddTab(options.TabName or "Configuration")

        local ConfigInfoParagraph = ConfigTab:AddParagraph({
            Title   = "Config Manager",
            Content = "Current: None | Autoload: None"
        })

        ConfigTab:AddInput({
            Title       = "Config Name",
            Placeholder = "Enter config name...",
            Default     = "",
            Callback    = function(v) inputConfigName = v end
        })

        local function getExistingConfigs()
            local list = {}
            if isfolder(CONFIG_DIR) then
                for _, file in ipairs(listfiles(CONFIG_DIR)) do
                    if string.sub(file, -5) == ".json" then
                        local name = file:match("([^/\\]+)%.json$")
                        if name then table.insert(list, name) end
                    end
                end
            end
            table.sort(list)
            return list
        end

        local function getAutoloadName()
            if isfile(AUTOLOAD_FILE) then
                local c = readfile(AUTOLOAD_FILE)
                if c and c ~= "" then return c end
            end
            return "None"
        end

        local function updateConfigStatus()
            local cur = (selectedConfigName ~= "" and selectedConfigName ~= nil) and selectedConfigName or "None"
            ConfigInfoParagraph:SetDesc(string.format("Current: %s | Autoload: %s", cur, getAutoloadName()))
        end

        local function buildConfigData()
            local data = {}
            for _, s in ipairs(SETTINGS) do
                if s.Get then
                    local ok, v = pcall(s.Get)
                    if ok and v ~= nil and v ~= "" then data[s.Key] = v end
                end
            end
            return data
        end

        local function applyConfigData(decoded)
            for _, s in ipairs(SETTINGS) do
                local v = decoded[s.Key]
                if v ~= nil and s.Set then pcall(s.Set, v) end
            end
        end

        local SelectConfigDropdown = ConfigTab:AddDropdown({
            Title        = "Select Config",
            Values       = getExistingConfigs(),
            DefaultValue = "Select Option",
            Callback     = function(v)
                if v and v ~= "" and v ~= "Select Option" then
                    selectedConfigName = v
                    updateConfigStatus()
                end
            end
        })

        ConfigTab:AddButtonGrid(
            {
                Title = "Save Config",
                Callback = function()
                    local targetName = inputConfigName ~= "" and inputConfigName or selectedConfigName
                    if not targetName or targetName == "" then
                        OrvionLib:Notify("Config Error", "Enter or select a config name first!", 3)
                        return
                    end
                    local filePath = CONFIG_DIR .. "/" .. targetName .. ".json"
                    local ok, encoded = pcall(function() return HttpService:JSONEncode(buildConfigData()) end)
                    if ok then
                        writefile(filePath, encoded)
                        selectedConfigName = targetName
                        SelectConfigDropdown:SetValues(getExistingConfigs())
                        SelectConfigDropdown:SetValue(targetName)
                        updateConfigStatus()
                        OrvionLib:Notify("Config Manager", string.format("Config '%s' saved!", targetName), 3)
                    else
                        OrvionLib:Notify("Config Error", "Failed to encode config data!", 3)
                    end
                end
            },
            {
                Title = "Load Config",
                Callback = function()
                    if not selectedConfigName or selectedConfigName == "" then
                        OrvionLib:Notify("Config Error", "Please select a config first!", 3)
                        return
                    end
                    local filePath = CONFIG_DIR .. "/" .. selectedConfigName .. ".json"
                    if isfile(filePath) then
                        local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(filePath)) end)
                        if ok and type(decoded) == "table" then
                            applyConfigData(decoded)
                            updateConfigStatus()
                            if options.OnLoaded then pcall(options.OnLoaded, selectedConfigName) end
                            OrvionLib:Notify("Config Manager", string.format("Config '%s' loaded!", selectedConfigName), 3)
                        else
                            OrvionLib:Notify("Config Error", "Failed to decode config file!", 3)
                        end
                    else
                        OrvionLib:Notify("Config Error", "Config file not found!", 3)
                    end
                end
            }
        )

        ConfigTab:AddButtonGrid(
            {
                Title = "Delete Config",
                Callback = function()
                    if not selectedConfigName or selectedConfigName == "" then
                        OrvionLib:Notify("Config Error", "Please select a config first!", 3)
                        return
                    end
                    local filePath = CONFIG_DIR .. "/" .. selectedConfigName .. ".json"
                    if isfile(filePath) then
                        delfile(filePath)
                        local deletedName = selectedConfigName
                        selectedConfigName = ""
                        SelectConfigDropdown:SetValues(getExistingConfigs())
                        updateConfigStatus()
                        OrvionLib:Notify("Config Manager", string.format("Config '%s' deleted!", deletedName), 3)
                    else
                        OrvionLib:Notify("Config Error", "Config file not found!", 3)
                    end
                end
            },
            {
                Title = "Set Autoload",
                Callback = function()
                    if not selectedConfigName or selectedConfigName == "" then
                        OrvionLib:Notify("Config Error", "Please select a config first!", 3)
                        return
                    end
                    writefile(AUTOLOAD_FILE, selectedConfigName)
                    updateConfigStatus()
                    OrvionLib:Notify("Config Manager", string.format("Autoload set to '%s'!", selectedConfigName), 3)
                end
            }
        )

        ConfigTab:AddButtonGrid(
            {
                Title = "Refresh List",
                Callback = function()
                    SelectConfigDropdown:SetValues(getExistingConfigs())
                    updateConfigStatus()
                    OrvionLib:Notify("Config Manager", "Config list refreshed!", 3)
                end
            },
            {
                Title = "Clear Autoload",
                Callback = function()
                    if isfile(AUTOLOAD_FILE) then writefile(AUTOLOAD_FILE, "") end
                    updateConfigStatus()
                    OrvionLib:Notify("Config Manager", "Autoload cleared!", 3)
                end
            }
        )

        -- Autoload on startup
        task.spawn(function()
            task.wait(1)
            if isfolder(CONFIG_DIR) and isfile(AUTOLOAD_FILE) then
                local autoloadName = readfile(AUTOLOAD_FILE)
                if autoloadName and autoloadName ~= "" then
                    local filePath = CONFIG_DIR .. "/" .. autoloadName .. ".json"
                    if isfile(filePath) then
                        local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(filePath)) end)
                        if ok and type(decoded) == "table" then
                            applyConfigData(decoded)
                            selectedConfigName = autoloadName
                            SelectConfigDropdown:SetValues(getExistingConfigs())
                            SelectConfigDropdown:SetValue(autoloadName)
                            updateConfigStatus()
                            if options.OnLoaded then pcall(options.OnLoaded, autoloadName) end
                            OrvionLib:Notify("Autoload", string.format("Successfully loaded config '%s'!", autoloadName), 4)
                        end
                    end
                end
            end
        end)

        return ConfigTab
    end

    return Window
end

return OrvionLib

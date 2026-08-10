-- ==========================================
-- ORVION UI LIBRARY v2.0
-- Professional Roblox UI Framework
-- Best-in-class design, performance, and features
-- ==========================================

local Orvion = {}

-- ==========================================
-- SERVICES
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- LOAD MODULES
-- ==========================================
local ConfigSystem = require(script.Parent.orvion_config)
local Themes = require(script.Parent.orvion_themes)

-- ==========================================
-- DPI-AWARE SCALING (PC/Mobile optimization)
-- ==========================================
local function GetScaledTextSize(baseSize)
    local viewport = workspace.CurrentCamera.ViewportSize.Y
    local scale = viewport / 1080
    return math.floor(baseSize * scale)
end

local function GetScaledSize(baseSize)
    local viewport = workspace.CurrentCamera.ViewportSize.Y
    local scale = viewport / 1080
    return math.floor(baseSize * scale)
end

-- ==========================================
-- CONSTANTS (Scaled dynamically)
-- ==========================================
local FONT_SECTION = GetScaledTextSize(14)
local FONT_GENERAL = GetScaledTextSize(13)
local FONT_SMALL = GetScaledTextSize(12)
local ELEMENT_HEIGHT = GetScaledSize(48)
local SIDEBAR_WIDTH = 150
local SEARCH_ICON = "rbxassetid://117201889911802"

-- ==========================================
-- RIPPLE ANIMATION (Material Design)
-- ==========================================
local function CircleClick(button, x, y)
    task.spawn(function()
        button.ClipsDescendants = true
        
        local circle = Instance.new("ImageLabel")
        circle.Image = "rbxassetid://266543268"
        circle.ImageColor3 = Color3.fromRGB(255, 255, 255)
        circle.ImageTransparency = 0.7
        circle.BackgroundTransparency = 1
        circle.ZIndex = 10
        circle.Name = "RippleCircle"
        circle.Parent = button
        
        local newX = x - circle.AbsolutePosition.X
        local newY = y - circle.AbsolutePosition.Y
        circle.Position = UDim2.new(0, newX, 0, newY)
        
        local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.5
        
        circle:TweenSizeAndPosition(
            UDim2.new(0, size, 0, size),
            UDim2.new(0.5, -size / 2, 0.5, -size / 2),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.5,
            true
        )
        
        for i = 1, 10 do
            circle.ImageTransparency = circle.ImageTransparency + 0.03
            task.wait(0.05)
        end
        
        circle:Destroy()
    end)
end

-- ==========================================
-- DRAGGABLE WINDOW
-- ==========================================
local function MakeDraggable(topbar, object)
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        object.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
    
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = object.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

-- ==========================================
-- SMOOTH TWEEN UTILITY
-- ==========================================
local function TweenProperty(object, property, targetValue, duration, easingStyle, easingDirection)
    duration = duration or 0.3
    easingStyle = easingStyle or Enum.EasingStyle.Quart
    easingDirection = easingDirection or Enum.EasingDirection.Out
    
    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    local tween = TweenService:Create(object, tweenInfo, {[property] = targetValue})
    tween:Play()
    return tween
end

-- ==========================================
-- NOTIFICATION QUEUE SYSTEM
-- ==========================================
local NotificationQueue = {}
local NotificationContainer = nil

function Orvion:Notify(config)
    task.spawn(function()
        local title = config.Title or "Notification"
        local content = config.Content or ""
        local duration = config.Duration or 3
        
        if not NotificationContainer then
            local notifyGui = Instance.new("ScreenGui")
            notifyGui.Name = "OrvionNotifications"
            notifyGui.Parent = CoreGui
            notifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            notifyGui.DisplayOrder = 100
            
            NotificationContainer = Instance.new("Frame", notifyGui)
            NotificationContainer.Name = "Container"
            NotificationContainer.BackgroundTransparency = 1
            NotificationContainer.Size = UDim2.new(0, 320, 1, 0)
            NotificationContainer.Position = UDim2.new(1, -320, 0, 0)
            
            local listLayout = Instance.new("UIListLayout", NotificationContainer)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder
            listLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
            listLayout.Padding = UDim.new(0, 10)
            
            local padding = Instance.new("UIPadding", NotificationContainer)
            padding.PaddingBottom = UDim.new(0, 20)
            padding.PaddingRight = UDim.new(0, 20)
        end
        
        local holder = Instance.new("Frame", NotificationContainer)
        holder.BackgroundTransparency = 1
        holder.Size = UDim2.new(1, 0, 0, 70)
        
        local notifFrame = Instance.new("Frame", holder)
        notifFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        notifFrame.BackgroundTransparency = 0.1
        notifFrame.Size = UDim2.new(1, 0, 1, 0)
        notifFrame.Position = UDim2.new(1, 320, 0, 0)
        notifFrame.BorderSizePixel = 0
        
        local corner = Instance.new("UICorner", notifFrame)
        corner.CornerRadius = UDim.new(0, 6)
        
        local stroke = Instance.new("UIStroke", notifFrame)
        stroke.Color = Color3.fromRGB(80, 80, 100)
        stroke.Thickness = 1.5
        
        local titleLabel = Instance.new("TextLabel", notifFrame)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Position = UDim2.new(0, 12, 0, 8)
        titleLabel.Size = UDim2.new(1, -24, 0, 20)
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.Text = title
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextSize = FONT_SECTION
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local contentLabel = Instance.new("TextLabel", notifFrame)
        contentLabel.BackgroundTransparency = 1
        contentLabel.Position = UDim2.new(0, 12, 0, 30)
        contentLabel.Size = UDim2.new(1, -24, 1, -35)
        contentLabel.Font = Enum.Font.Gotham
        contentLabel.Text = content
        contentLabel.TextColor3 = Color3.fromRGB(170, 170, 185)
        contentLabel.TextSize = FONT_GENERAL
        contentLabel.TextXAlignment = Enum.TextXAlignment.Left
        contentLabel.TextYAlignment = Enum.TextYAlignment.Top
        contentLabel.TextWrapped = true
        
        -- Slide in animation
        TweenProperty(notifFrame, "Position", UDim2.new(0, 0, 0, 0), 0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        
        -- Auto dismiss
        task.wait(duration)
        
        -- Slide out animation
        TweenProperty(notifFrame, "Position", UDim2.new(1, 320, 0, 0), 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        task.wait(0.3)
        
        holder:Destroy()
    end)
end

-- ==========================================
-- SEARCH FILTER UTILITY
-- ==========================================
local function FilterSearch(items, searchText)
    searchText = searchText:lower()
    local results = {}
    
    for _, item in ipairs(items) do
        if item:lower():find(searchText, 1, true) then
            table.insert(results, item)
        end
    end
    
    return results
end

-- ==========================================
-- CREATE WINDOW (Main Entry Point)
-- ==========================================
function Orvion:CreateWindow(config)
    config = config or {}
    local title = config.Title or "Orvion UI"
    local theme = config.Theme or "Dark"
    local size = config.Size or UDim2.fromOffset(470, 600)
    
    local Window = {}
    Window.Theme = Themes[theme] or Themes["Dark"]
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Elements = {}
    
    -- Clean up existing UI
    if CoreGui:FindFirstChild("OrvionGui") then
        CoreGui.OrvionGui:Destroy()
    end
    
    -- ==========================================
    -- MAIN GUI CONTAINER
    -- ==========================================
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "OrvionGui"
    screenGui.Parent = CoreGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 50
    
    local mainFrame = Instance.new("Frame", screenGui)
    mainFrame.Name = "MainFrame"
    mainFrame.BackgroundColor3 = Window.Theme.Primary
    mainFrame.Size = size
    mainFrame.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    Window.MainFrame = mainFrame
    
    local mainCorner = Instance.new("UICorner", mainFrame)
    mainCorner.CornerRadius = UDim.new(0, 8)
    
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = Window.Theme.Outline
    mainStroke.Thickness = 1.5
    
    -- ==========================================
    -- HEADER
    -- ==========================================
    local header = Instance.new("Frame", mainFrame)
    header.Name = "Header"
    header.BackgroundColor3 = Window.Theme.Primary
    header.Size = UDim2.new(1, 0, 0, 38)
    header.BorderSizePixel = 0
    header.ZIndex = 3
    
    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Window.Theme.Text
    titleLabel.TextSize = FONT_SECTION
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Minimize Button
    local minimizeBtn = Instance.new("ImageButton", header)
    minimizeBtn.Name = "MinimizeBtn"
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -65, 0.5, -15)
    minimizeBtn.Image = "rbxassetid://9886659276"
    minimizeBtn.ImageColor3 = Window.Theme.Text
    minimizeBtn.BackgroundTransparency = 1
    
    -- Close Button
    local closeBtn = Instance.new("ImageButton", header)
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0.5, -15)
    closeBtn.Image = "rbxassetid://9886659671"
    closeBtn.ImageColor3 = Window.Theme.Text
    closeBtn.BackgroundTransparency = 1
    
    -- Make window draggable
    MakeDraggable(header, mainFrame)
    
    -- Minimize functionality
    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        
        if minimized then
            -- Hide all content except header
            for _, child in pairs(mainFrame:GetChildren()) do
                if child.Name ~= "Header" and child:IsA("GuiObject") then
                    child.Visible = false
                end
            end
            TweenProperty(mainFrame, "Size", UDim2.new(0, 470, 0, 38), 0.3)
        else
            -- Show all content
            for _, child in pairs(mainFrame:GetChildren()) do
                if child:IsA("GuiObject") then
                    child.Visible = true
                end
            end
            TweenProperty(mainFrame, "Size", size, 0.3)
        end
    end)
    
    -- Close functionality
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    -- ==========================================
    -- SIDEBAR
    -- ==========================================
    local sidebar = Instance.new("Frame", mainFrame)
    sidebar.Name = "Sidebar"
    sidebar.BackgroundColor3 = Window.Theme.Sidebar
    sidebar.BackgroundTransparency = 0.55
    sidebar.Position = UDim2.new(0, 0, 0, 39)
    sidebar.Size = UDim2.new(0, SIDEBAR_WIDTH, 1, -39)
    sidebar.BorderSizePixel = 0
    sidebar.ZIndex = 2
    Window.Sidebar = sidebar
    
    local sidebarCorner = Instance.new("UICorner", sidebar)
    sidebarCorner.CornerRadius = UDim.new(0, 8)
    
    -- Sidebar Search
    local searchContainer = Instance.new("Frame", sidebar)
    searchContainer.Name = "SearchContainer"
    searchContainer.BackgroundColor3 = Window.Theme.Interactive
    searchContainer.Position = UDim2.new(0, 10, 0, 10)
    searchContainer.Size = UDim2.new(1, -20, 0, 32)
    searchContainer.BorderSizePixel = 0
    
    local searchCorner = Instance.new("UICorner", searchContainer)
    searchCorner.CornerRadius = UDim.new(0, 6)
    
    local searchStroke = Instance.new("UIStroke", searchContainer)
    searchStroke.Color = Window.Theme.Outline
    searchStroke.Thickness = 1
    
    local searchIcon = Instance.new("ImageLabel", searchContainer)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Position = UDim2.new(0, 8, 0.5, -10)
    searchIcon.Size = UDim2.new(0, 20, 0, 20)
    searchIcon.Image = SEARCH_ICON
    searchIcon.ImageColor3 = Window.Theme.TextDim
    
    local searchInput = Instance.new("TextBox", searchContainer)
    searchInput.Name = "SearchInput"
    searchInput.BackgroundTransparency = 1
    searchInput.Position = UDim2.new(0, 35, 0, 0)
    searchInput.Size = UDim2.new(1, -40, 1, 0)
    searchInput.Font = Enum.Font.Gotham
    searchInput.PlaceholderText = "Search..."
    searchInput.PlaceholderColor3 = Window.Theme.TextDim
    searchInput.Text = ""
    searchInput.TextColor3 = Window.Theme.Text
    searchInput.TextSize = FONT_SMALL
    searchInput.TextXAlignment = Enum.TextXAlignment.Left
    searchInput.ClearTextOnFocus = false
    
    -- Tab List Container
    local tabList = Instance.new("ScrollingFrame", sidebar)
    tabList.Name = "TabList"
    tabList.BackgroundTransparency = 1
    tabList.Position = UDim2.new(0, 0, 0, 52)
    tabList.Size = UDim2.new(1, 0, 1, -62)
    tabList.BorderSizePixel = 0
    tabList.ScrollBarThickness = 2
    tabList.ScrollBarImageColor3 = Window.Theme.Accent
    tabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    
    local tabListLayout = Instance.new("UIListLayout", tabList)
    tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabListLayout.Padding = UDim.new(0, 4)
    
    local tabListPadding = Instance.new("UIPadding", tabList)
    tabListPadding.PaddingTop = UDim.new(0, 8)
    tabListPadding.PaddingLeft = UDim.new(0, 10)
    tabListPadding.PaddingRight = UDim.new(0, 10)
    
    -- Auto-resize canvas
    tabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabList.CanvasSize = UDim2.new(0, 0, 0, tabListLayout.AbsoluteContentSize.Y + 16)
    end)
    
    -- ==========================================
    -- CONTENT AREA
    -- ==========================================
    local contentArea = Instance.new("Frame", mainFrame)
    contentArea.Name = "ContentArea"
    contentArea.BackgroundTransparency = 1
    contentArea.Position = UDim2.new(0, SIDEBAR_WIDTH, 0, 39)
    contentArea.Size = UDim2.new(1, -SIDEBAR_WIDTH, 1, -39)
    contentArea.BorderSizePixel = 0
    contentArea.ClipsDescendants = true
    Window.ContentArea = contentArea
    
    -- ==========================================
    -- FOOTER
    -- ==========================================
    local footer = Instance.new("TextLabel", mainFrame)
    footer.Name = "Footer"
    footer.BackgroundColor3 = Window.Theme.Primary
    footer.BackgroundTransparency = 0.3
    footer.Position = UDim2.new(0, SIDEBAR_WIDTH, 1, -25)
    footer.Size = UDim2.new(1, -SIDEBAR_WIDTH, 0, 25)
    footer.BorderSizePixel = 0
    footer.Font = Enum.Font.Gotham
    footer.Text = "Orvion UI v2.0 | Made with ❤️"
    footer.TextColor3 = Window.Theme.TextDim
    footer.TextSize = FONT_SMALL
    footer.ZIndex = 5
    
    local footerCorner = Instance.new("UICorner", footer)
    footerCorner.CornerRadius = UDim.new(0, 6)
    
    
    -- ==========================================
    -- SIDEBAR SEARCH FUNCTIONALITY
    -- ==========================================
    searchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local searchText = searchInput.Text:lower()
        
        for _, tabButton in pairs(tabList:GetChildren()) do
            if tabButton:IsA("TextButton") then
                local tabName = tabButton.Name:lower()
                if searchText == "" or tabName:find(searchText, 1, true) then
                    tabButton.Visible = true
                else
                    tabButton.Visible = false
                end
            end
        end
    end)
    
    -- ==========================================
    -- ADD TAB FUNCTION
    -- ==========================================
    function Window:AddTab(tabName, icon)
        local Tab = {}
        Tab.Name = tabName
        Tab.Elements = {}
        Tab.Sections = {}
        
        -- Tab Button in Sidebar (NO ICON - per user request)
        local tabButton = Instance.new("TextButton", tabList)
        tabButton.Name = tabName
        tabButton.Size = UDim2.new(1, 0, 0, 36)
        tabButton.BackgroundColor3 = Window.Theme.Interactive
        tabButton.BackgroundTransparency = 1
        tabButton.BorderSizePixel = 0
        tabButton.Font = Enum.Font.GothamBold
        tabButton.Text = tabName
        tabButton.TextColor3 = Window.Theme.TextDim
        tabButton.TextSize = FONT_GENERAL
        tabButton.AutoButtonColor = false
        
        local tabCorner = Instance.new("UICorner", tabButton)
        tabCorner.CornerRadius = UDim.new(0, 6)
        
        -- Tab Content Container
        local tabContent = Instance.new("ScrollingFrame", contentArea)
        tabContent.Name = tabName .. "Content"
        tabContent.BackgroundTransparency = 1
        tabContent.Size = UDim2.new(1, 0, 1, -30)
        tabContent.Position = UDim2.new(0, 0, 0, 0)
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = Window.Theme.Accent
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.Visible = false
        Tab.Content = tabContent
        
        local contentLayout = Instance.new("UIListLayout", tabContent)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 8)
        
        local contentPadding = Instance.new("UIPadding", tabContent)
        contentPadding.PaddingTop = UDim.new(0, 15)
        contentPadding.PaddingLeft = UDim.new(0, 15)
        contentPadding.PaddingRight = UDim.new(0, 15)
        contentPadding.PaddingBottom = UDim.new(0, 15)
        
        -- Auto-resize canvas
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 30)
        end)
        
        -- Tab switching logic
        tabButton.MouseButton1Click:Connect(function()
            -- Ripple effect
            CircleClick(tabButton, tabButton.AbsolutePosition.X + tabButton.AbsoluteSize.X/2, 
                       tabButton.AbsolutePosition.Y + tabButton.AbsoluteSize.Y/2)
            
            -- Hide all tabs
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundTransparency = 1
                tab.Button.TextColor3 = Window.Theme.TextDim
            end
            
            -- Show selected tab
            tabContent.Visible = true
            tabButton.BackgroundTransparency = 0
            tabButton.TextColor3 = Window.Theme.Text
            Window.CurrentTab = Tab
        end)
        
        Tab.Button = tabButton
        table.insert(Window.Tabs, Tab)
        
        -- Select first tab by default
        if #Window.Tabs == 1 then
            tabButton.BackgroundTransparency = 0
            tabButton.TextColor3 = Window.Theme.Text
            tabContent.Visible = true
            Window.CurrentTab = Tab
        end
        
        return Tab
    end
    
    -- ==========================================
    -- ADD SECTION (Collapsible Header - KEEP!)
    -- ==========================================
    function Window:AddSection(tab, sectionName)
        local sectionContainer = Instance.new("Frame", tab.Content)
        sectionContainer.Name = sectionName
        sectionContainer.BackgroundTransparency = 1
        sectionContainer.Size = UDim2.new(1, 0, 0, 40)
        sectionContainer.AutomaticSize = Enum.AutomaticSize.Y
        
        local sectionHeader = Instance.new("TextButton", sectionContainer)
        sectionHeader.Name = "Header"
        sectionHeader.Size = UDim2.new(1, 0, 0, 32)
        sectionHeader.BackgroundColor3 = Window.Theme.Secondary
        sectionHeader.BorderSizePixel = 0
        sectionHeader.Font = Enum.Font.GothamBold
        sectionHeader.Text = "  " .. sectionName .. " >"
        sectionHeader.TextColor3 = Window.Theme.Text
        sectionHeader.TextSize = FONT_SECTION
        sectionHeader.TextXAlignment = Enum.TextXAlignment.Left
        sectionHeader.AutoButtonColor = false
        
        local headerCorner = Instance.new("UICorner", sectionHeader)
        headerCorner.CornerRadius = UDim.new(0, 6)
        
        local elementsContainer = Instance.new("Frame", sectionContainer)
        elementsContainer.Name = "Elements"
        elementsContainer.BackgroundTransparency = 1
        elementsContainer.Position = UDim2.new(0, 0, 0, 38)
        elementsContainer.Size = UDim2.new(1, 0, 0, 0)
        elementsContainer.AutomaticSize = Enum.AutomaticSize.Y
        elementsContainer.Visible = false
        
        local elementsLayout = Instance.new("UIListLayout", elementsContainer)
        elementsLayout.SortOrder = Enum.SortOrder.LayoutOrder
        elementsLayout.Padding = UDim.new(0, 6)
        
        -- Collapsible toggle
        local collapsed = true
        sectionHeader.MouseButton1Click:Connect(function()
            collapsed = not collapsed
            elementsContainer.Visible = not collapsed
            sectionHeader.Text = "  " .. sectionName .. (collapsed and " >" or " v")
        end)
        
        return elementsContainer
    end
    
    -- ==========================================
    -- ADD TOGGLE
    -- ==========================================
    function Window:AddToggle(tab, config)
        config = config or {}
        local title = config.Title or "Toggle"
        local default = config.Default or false
        local callback = config.Callback or function() end
        local elementId = config.ElementId
        
        local parent = tab.Content
        if config.Parent then parent = config.Parent end
        
        local toggleFrame = Instance.new("Frame", parent)
        toggleFrame.Name = title
        toggleFrame.BackgroundColor3 = Window.Theme.Interactive
        toggleFrame.Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT)
        toggleFrame.BorderSizePixel = 0
        
        local toggleCorner = Instance.new("UICorner", toggleFrame)
        toggleCorner.CornerRadius = UDim.new(0, 6)
        
        local toggleLabel = Instance.new("TextLabel", toggleFrame)
        toggleLabel.BackgroundTransparency = 1
        toggleLabel.Position = UDim2.new(0, 12, 0, 0)
        toggleLabel.Size = UDim2.new(1, -80, 1, 0)
        toggleLabel.Font = Enum.Font.GothamBold
        toggleLabel.Text = title
        toggleLabel.TextColor3 = Window.Theme.Text
        toggleLabel.TextSize = FONT_GENERAL
        toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local toggleButton = Instance.new("TextButton", toggleFrame)
        toggleButton.Size = UDim2.new(0, 48, 0, 24)
        toggleButton.Position = UDim2.new(1, -60, 0.5, -12)
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        toggleButton.Text = ""
        toggleButton.AutoButtonColor = false
        
        local toggleBtnCorner = Instance.new("UICorner", toggleButton)
        toggleBtnCorner.CornerRadius = UDim.new(1, 0)
        
        local toggleIndicator = Instance.new("Frame", toggleButton)
        toggleIndicator.Size = UDim2.new(0, 20, 0, 20)
        toggleIndicator.Position = UDim2.new(0, 2, 0.5, -10)
        toggleIndicator.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        toggleIndicator.BorderSizePixel = 0
        
        local indicatorCorner = Instance.new("UICorner", toggleIndicator)
        indicatorCorner.CornerRadius = UDim.new(1, 0)
        
        local toggled = default
        
        local function updateToggle()
            if toggled then
                TweenProperty(toggleButton, "BackgroundColor3", Window.Theme.Accent, 0.2)
                TweenProperty(toggleIndicator, "Position", UDim2.new(1, -22, 0.5, -10), 0.2)
            else
                TweenProperty(toggleButton, "BackgroundColor3", Color3.fromRGB(60, 60, 70), 0.2)
                TweenProperty(toggleIndicator, "Position", UDim2.new(0, 2, 0.5, -10), 0.2)
            end
        end
        
        updateToggle()
        
        toggleButton.MouseButton1Click:Connect(function()
            toggled = not toggled
            updateToggle()
            callback(toggled)
        end)
        
        if elementId then
            Window.Elements[elementId] = {
                Type = "Toggle",
                GetValue = function() return toggled end,
                SetValue = function(value) toggled = value updateToggle() end
            }
        end
    end
    
    -- ==========================================
    -- ADD INPUT
    -- ==========================================
    function Window:AddInput(tab, config)
        config = config or {}
        local title = config.Title or "Input"
        local default = config.Default or ""
        local callback = config.Callback or function() end
        local elementId = config.ElementId
        local validation = config.Validation or "string"
        
        local parent = tab.Content
        if config.Parent then parent = config.Parent end
        
        local inputFrame = Instance.new("Frame", parent)
        inputFrame.Name = title
        inputFrame.BackgroundColor3 = Window.Theme.Interactive
        inputFrame.Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT)
        inputFrame.BorderSizePixel = 0
        
        local inputCorner = Instance.new("UICorner", inputFrame)
        inputCorner.CornerRadius = UDim.new(0, 6)
        
        local inputLabel = Instance.new("TextLabel", inputFrame)
        inputLabel.BackgroundTransparency = 1
        inputLabel.Position = UDim2.new(0, 12, 0, 0)
        inputLabel.Size = UDim2.new(0.4, 0, 1, 0)
        inputLabel.Font = Enum.Font.GothamBold
        inputLabel.Text = title
        inputLabel.TextColor3 = Window.Theme.Text
        inputLabel.TextSize = FONT_GENERAL
        inputLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local inputBox = Instance.new("TextBox", inputFrame)
        inputBox.BackgroundColor3 = Window.Theme.Secondary
        inputBox.Position = UDim2.new(0.45, 0, 0.5, -14)
        inputBox.Size = UDim2.new(0.5, -12, 0, 28)
        inputBox.Font = Enum.Font.Gotham
        inputBox.Text = default
        inputBox.TextColor3 = Window.Theme.Text
        inputBox.TextSize = FONT_GENERAL
        inputBox.PlaceholderText = "Enter value..."
        inputBox.PlaceholderColor3 = Window.Theme.TextDim
        inputBox.ClearTextOnFocus = false
        
        local inputBoxCorner = Instance.new("UICorner", inputBox)
        inputBoxCorner.CornerRadius = UDim.new(0, 4)
        
        inputBox.FocusLost:Connect(function()
            local value = inputBox.Text
            
            if validation == "number" then
                local num = tonumber(value)
                if num then
                    if config.Min and num < config.Min then num = config.Min end
                    if config.Max and num > config.Max then num = config.Max end
                    inputBox.Text = tostring(num)
                    callback(num)
                else
                    inputBox.Text = default
                end
            else
                callback(value)
            end
        end)
        
        if elementId then
            Window.Elements[elementId] = {
                Type = "Input",
                GetValue = function() return inputBox.Text end,
                SetValue = function(value) inputBox.Text = value end
            }
        end
    end
    
    
    -- ==========================================
    -- ADD DROPDOWN (Full-height with Search!)
    -- ==========================================
    function Window:AddDropdown(tab, config)
        config = config or {}
        local title = config.Title or "Dropdown"
        local values = config.Values or {}
        local default = config.Default or values[1]
        local callback = config.Callback or function() end
        local elementId = config.ElementId
        local multi = config.Multi or false
        
        local parent = tab.Content
        if config.Parent then parent = config.Parent end
        
        local selected = multi and {} or default
        
        local dropdownFrame = Instance.new("Frame", parent)
        dropdownFrame.Name = title
        dropdownFrame.BackgroundColor3 = Window.Theme.Interactive
        dropdownFrame.Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT)
        dropdownFrame.BorderSizePixel = 0
        
        local dropCorner = Instance.new("UICorner", dropdownFrame)
        dropCorner.CornerRadius = UDim.new(0, 6)
        
        local dropLabel = Instance.new("TextLabel", dropdownFrame)
        dropLabel.BackgroundTransparency = 1
        dropLabel.Position = UDim2.new(0, 12, 0, 0)
        dropLabel.Size = UDim2.new(0.4, 0, 1, 0)
        dropLabel.Font = Enum.Font.GothamBold
        dropLabel.Text = title
        dropLabel.TextColor3 = Window.Theme.Text
        dropLabel.TextSize = FONT_GENERAL
        dropLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local dropButton = Instance.new("TextButton", dropdownFrame)
        dropButton.BackgroundColor3 = Window.Theme.Secondary
        dropButton.Position = UDim2.new(0.45, 0, 0.5, -14)
        dropButton.Size = UDim2.new(0.5, -12, 0, 28)
        dropButton.Font = Enum.Font.Gotham
        dropButton.Text = default
        dropButton.TextColor3 = Window.Theme.Text
        dropButton.TextSize = FONT_GENERAL
        dropButton.TextXAlignment = Enum.TextXAlignment.Left
        dropButton.AutoButtonColor = false
        
        local dropBtnCorner = Instance.new("UICorner", dropButton)
        dropBtnCorner.CornerRadius = UDim.new(0, 4)
        
        local dropArrow = Instance.new("TextLabel", dropButton)
        dropArrow.BackgroundTransparency = 1
        dropArrow.Position = UDim2.new(1, -20, 0, 0)
        dropArrow.Size = UDim2.new(0, 20, 1, 0)
        dropArrow.Font = Enum.Font.GothamBold
        dropArrow.Text = "▼"
        dropArrow.TextColor3 = Window.Theme.TextDim
        dropArrow.TextSize = FONT_SMALL
        
        -- Dropdown List (Full height to header!)
        local dropList = nil
        local listOpen = false
        
        local function createDropList()
            if dropList then dropList:Destroy() end
            
            dropList = Instance.new("Frame", screenGui)
            dropList.Name = "DropdownList"
            dropList.BackgroundColor3 = Window.Theme.Secondary
            dropList.BackgroundTransparency = 0.05
            dropList.BorderSizePixel = 0
            dropList.ZIndex = 100
            
            -- Full height from header to dropdown button!
            local buttonPos = dropButton.AbsolutePosition
            local headerBottom = header.AbsolutePosition.Y + header.AbsoluteSize.Y
            local fullHeight = buttonPos.Y - headerBottom
            
            dropList.Position = UDim2.new(0, buttonPos.X, 0, headerBottom)
            dropList.Size = UDim2.new(0, dropButton.AbsoluteSize.X, 0, fullHeight)
            
            local listCorner = Instance.new("UICorner", dropList)
            listCorner.CornerRadius = UDim.new(0, 6)
            
            local listStroke = Instance.new("UIStroke", dropList)
            listStroke.Color = Window.Theme.Outline
            listStroke.Thickness = 1.5
            
            -- Search box at top (center text, transparent bg)
            local searchBox = Instance.new("TextBox", dropList)
            searchBox.Name = "SearchBox"
            searchBox.BackgroundTransparency = 1
            searchBox.Position = UDim2.new(0, 0, 0, 8)
            searchBox.Size = UDim2.new(1, 0, 0, 32)
            searchBox.Font = Enum.Font.GothamBold
            searchBox.PlaceholderText = "Search"
            searchBox.PlaceholderColor3 = Window.Theme.TextDim
            searchBox.Text = ""
            searchBox.TextColor3 = Window.Theme.Text
            searchBox.TextSize = FONT_GENERAL
            searchBox.TextXAlignment = Enum.TextXAlignment.Center
            searchBox.ClearTextOnFocus = false
            
            -- Options container
            local optionsScroll = Instance.new("ScrollingFrame", dropList)
            optionsScroll.Name = "OptionsScroll"
            optionsScroll.BackgroundTransparency = 1
            optionsScroll.Position = UDim2.new(0, 0, 0, 45)
            optionsScroll.Size = UDim2.new(1, 0, 1, -50)
            optionsScroll.BorderSizePixel = 0
            optionsScroll.ScrollBarThickness = 3
            optionsScroll.ScrollBarImageColor3 = Window.Theme.Accent
            optionsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            
            local optionsLayout = Instance.new("UIListLayout", optionsScroll)
            optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            optionsLayout.Padding = UDim.new(0, 2)
            
            local optionsPadding = Instance.new("UIPadding", optionsScroll)
            optionsPadding.PaddingTop = UDim.new(0, 4)
            optionsPadding.PaddingLeft = UDim.new(0, 8)
            optionsPadding.PaddingRight = UDim.new(0, 8)
            
            optionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                optionsScroll.CanvasSize = UDim2.new(0, 0, 0, optionsLayout.AbsoluteContentSize.Y + 8)
            end)
            
            -- Create option buttons
            local function createOptions(filterText)
                optionsScroll:ClearAllChildren()
                
                local optionsLayout = Instance.new("UIListLayout", optionsScroll)
                optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
                optionsLayout.Padding = UDim.new(0, 2)
                
                local optionsPadding = Instance.new("UIPadding", optionsScroll)
                optionsPadding.PaddingTop = UDim.new(0, 4)
                optionsPadding.PaddingLeft = UDim.new(0, 8)
                optionsPadding.PaddingRight = UDim.new(0, 8)
                
                local filteredValues = filterText and FilterSearch(values, filterText) or values
                
                if #filteredValues == 0 then
                    local emptyLabel = Instance.new("TextLabel", optionsScroll)
                    emptyLabel.BackgroundTransparency = 1
                    emptyLabel.Size = UDim2.new(1, 0, 0, 30)
                    emptyLabel.Font = Enum.Font.Gotham
                    emptyLabel.Text = "No results found"
                    emptyLabel.TextColor3 = Window.Theme.TextDim
                    emptyLabel.TextSize = FONT_GENERAL
                end
                
                for _, value in ipairs(filteredValues) do
                    local optionBtn = Instance.new("TextButton", optionsScroll)
                    optionBtn.Name = value
                    optionBtn.Size = UDim2.new(1, 0, 0, 32)
                    optionBtn.BackgroundColor3 = Window.Theme.Interactive
                    optionBtn.BackgroundTransparency = 0.5
                    optionBtn.Font = Enum.Font.Gotham
                    optionBtn.Text = "  " .. value
                    optionBtn.TextColor3 = Window.Theme.Text
                    optionBtn.TextSize = FONT_GENERAL
                    optionBtn.TextXAlignment = Enum.TextXAlignment.Left
                    optionBtn.AutoButtonColor = false
                    
                    local optBtnCorner = Instance.new("UICorner", optionBtn)
                    optBtnCorner.CornerRadius = UDim.new(0, 4)
                    
                    -- Highlight if selected
                    if multi then
                        for _, sel in ipairs(selected) do
                            if sel == value then
                                optionBtn.BackgroundColor3 = Window.Theme.Accent
                                optionBtn.BackgroundTransparency = 0.3
                                break
                            end
                        end
                    elseif value == selected then
                        optionBtn.BackgroundColor3 = Window.Theme.Accent
                        optionBtn.BackgroundTransparency = 0.3
                    end
                    
                    optionBtn.MouseButton1Click:Connect(function()
                        if multi then
                            local found = false
                            for i, sel in ipairs(selected) do
                                if sel == value then
                                    table.remove(selected, i)
                                    found = true
                                    break
                                end
                            end
                            if not found then
                                table.insert(selected, value)
                            end
                            dropButton.Text = #selected > 0 and table.concat(selected, ", ") or "None"
                            callback(selected)
                            createOptions(searchBox.Text)
                        else
                            selected = value
                            dropButton.Text = value
                            callback(value)
                            dropList:Destroy()
                            listOpen = false
                        end
                    end)
                end
                
                optionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    optionsScroll.CanvasSize = UDim2.new(0, 0, 0, optionsLayout.AbsoluteContentSize.Y + 8)
                end)
            end
            
            createOptions()
            
            -- Search functionality
            searchBox:GetPropertyChangedSignal("Text"):Connect(function()
                createOptions(searchBox.Text)
            end)
            
            -- Close on outside click
            local closeConnection
            closeConnection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local mousePos = UserInputService:GetMouseLocation()
                    local listPos = dropList.AbsolutePosition
                    local listSize = dropList.AbsoluteSize
                    
                    if mousePos.X < listPos.X or mousePos.X > listPos.X + listSize.X or
                       mousePos.Y < listPos.Y or mousePos.Y > listPos.Y + listSize.Y then
                        dropList:Destroy()
                        listOpen = false
                        closeConnection:Disconnect()
                    end
                end
            end)
        end
        
        dropButton.MouseButton1Click:Connect(function()
            if not listOpen then
                createDropList()
                listOpen = true
            else
                if dropList then dropList:Destroy() end
                listOpen = false
            end
        end)
        
        if elementId then
            Window.Elements[elementId] = {
                Type = "Dropdown",
                GetValue = function() return selected end,
                SetValue = function(value) selected = value dropButton.Text = value end
            }
        end
    end
    
    -- ==========================================
    -- ADD KEYBIND
    -- ==========================================
    function Window:AddKeybind(tab, config)
        config = config or {}
        local title = config.Title or "Keybind"
        local default = config.Default or Enum.KeyCode.E
        local callback = config.Callback or function() end
        local elementId = config.ElementId
        
        local parent = tab.Content
        if config.Parent then parent = config.Parent end
        
        local currentKey = default
        local listening = false
        
        local keybindFrame = Instance.new("Frame", parent)
        keybindFrame.Name = title
        keybindFrame.BackgroundColor3 = Window.Theme.Interactive
        keybindFrame.Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT)
        keybindFrame.BorderSizePixel = 0
        
        local keybindCorner = Instance.new("UICorner", keybindFrame)
        keybindCorner.CornerRadius = UDim.new(0, 6)
        
        local keybindLabel = Instance.new("TextLabel", keybindFrame)
        keybindLabel.BackgroundTransparency = 1
        keybindLabel.Position = UDim2.new(0, 12, 0, 0)
        keybindLabel.Size = UDim2.new(0.4, 0, 1, 0)
        keybindLabel.Font = Enum.Font.GothamBold
        keybindLabel.Text = title
        keybindLabel.TextColor3 = Window.Theme.Text
        keybindLabel.TextSize = FONT_GENERAL
        keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local keybindButton = Instance.new("TextButton", keybindFrame)
        keybindButton.BackgroundColor3 = Window.Theme.Secondary
        keybindButton.Position = UDim2.new(0.45, 0, 0.5, -14)
        keybindButton.Size = UDim2.new(0.5, -12, 0, 28)
        keybindButton.Font = Enum.Font.Gotham
        keybindButton.Text = currentKey.Name
        keybindButton.TextColor3 = Window.Theme.Text
        keybindButton.TextSize = FONT_GENERAL
        keybindButton.AutoButtonColor = false
        
        local keybindCorner2 = Instance.new("UICorner", keybindButton)
        keybindCorner2.CornerRadius = UDim.new(0, 4)
        
        keybindButton.MouseButton1Click:Connect(function()
            listening = true
            keybindButton.Text = "..."
        end)
        
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                currentKey = input.KeyCode
                keybindButton.Text = currentKey.Name
                listening = false
            elseif not gameProcessed and input.KeyCode == currentKey then
                callback(currentKey)
            end
        end)
        
        if elementId then
            Window.Elements[elementId] = {
                Type = "Keybind",
                GetValue = function() return currentKey end,
                SetValue = function(key) currentKey = key keybindButton.Text = key.Name end
            }
        end
    end
    
    
    -- ==========================================
    -- ADD SLIDER
    -- ==========================================
    function Window:AddSlider(tab, config)
        config = config or {}
        local title = config.Title or "Slider"
        local min = config.Min or 0
        local max = config.Max or 100
        local default = config.Default or min
        local callback = config.Callback or function() end
        local elementId = config.ElementId
        
        local parent = tab.Content
        if config.Parent then parent = config.Parent end
        
        local currentValue = default
        
        local sliderFrame = Instance.new("Frame", parent)
        sliderFrame.Name = title
        sliderFrame.BackgroundColor3 = Window.Theme.Interactive
        sliderFrame.Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT + 10)
        sliderFrame.BorderSizePixel = 0
        
        local sliderCorner = Instance.new("UICorner", sliderFrame)
        sliderCorner.CornerRadius = UDim.new(0, 6)
        
        local sliderLabel = Instance.new("TextLabel", sliderFrame)
        sliderLabel.BackgroundTransparency = 1
        sliderLabel.Position = UDim2.new(0, 12, 0, 5)
        sliderLabel.Size = UDim2.new(0.5, 0, 0, 20)
        sliderLabel.Font = Enum.Font.GothamBold
        sliderLabel.Text = title
        sliderLabel.TextColor3 = Window.Theme.Text
        sliderLabel.TextSize = FONT_GENERAL
        sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local valueLabel = Instance.new("TextLabel", sliderFrame)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Position = UDim2.new(0.5, 0, 0, 5)
        valueLabel.Size = UDim2.new(0.5, -12, 0, 20)
        valueLabel.Font = Enum.Font.Gotham
        valueLabel.Text = tostring(currentValue)
        valueLabel.TextColor3 = Window.Theme.Accent
        valueLabel.TextSize = FONT_GENERAL
        valueLabel.TextXAlignment = Enum.TextXAlignment.Right
        
        local sliderBar = Instance.new("Frame", sliderFrame)
        sliderBar.BackgroundColor3 = Window.Theme.Secondary
        sliderBar.Position = UDim2.new(0, 12, 0, 32)
        sliderBar.Size = UDim2.new(1, -24, 0, 6)
        sliderBar.BorderSizePixel = 0
        
        local sliderBarCorner = Instance.new("UICorner", sliderBar)
        sliderBarCorner.CornerRadius = UDim.new(1, 0)
        
        local sliderFill = Instance.new("Frame", sliderBar)
        sliderFill.BackgroundColor3 = Window.Theme.Accent
        sliderFill.Size = UDim2.new((currentValue - min) / (max - min), 0, 1, 0)
        sliderFill.BorderSizePixel = 0
        
        local sliderFillCorner = Instance.new("UICorner", sliderFill)
        sliderFillCorner.CornerRadius = UDim.new(1, 0)
        
        local sliderKnob = Instance.new("Frame", sliderBar)
        sliderKnob.BackgroundColor3 = Window.Theme.Text
        sliderKnob.Size = UDim2.new(0, 14, 0, 14)
        sliderKnob.Position = UDim2.new((currentValue - min) / (max - min), -7, 0.5, -7)
        sliderKnob.BorderSizePixel = 0
        
        local sliderKnobCorner = Instance.new("UICorner", sliderKnob)
        sliderKnobCorner.CornerRadius = UDim.new(1, 0)
        
        local dragging = false
        
        local function updateSlider(input)
            local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
            currentValue = math.floor(min + (max - min) * relativeX)
            
            valueLabel.Text = tostring(currentValue)
            sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
            sliderKnob.Position = UDim2.new(relativeX, -7, 0.5, -7)
            
            callback(currentValue)
        end
        
        sliderBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input)
            end
        end)
        
        sliderBar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        
        if elementId then
            Window.Elements[elementId] = {
                Type = "Slider",
                GetValue = function() return currentValue end,
                SetValue = function(value) 
                    currentValue = math.clamp(value, min, max)
                    local relativeX = (currentValue - min) / (max - min)
                    valueLabel.Text = tostring(currentValue)
                    sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
                    sliderKnob.Position = UDim2.new(relativeX, -7, 0.5, -7)
                end
            }
        end
    end
    
    -- ==========================================
    -- ADD COLOR PICKER
    -- ==========================================
    function Window:AddColorPicker(tab, config)
        config = config or {}
        local title = config.Title or "Color Picker"
        local default = config.Default or Color3.fromRGB(255, 255, 255)
        local callback = config.Callback or function() end
        local elementId = config.ElementId
        
        local parent = tab.Content
        if config.Parent then parent = config.Parent end
        
        local currentColor = default
        
        local colorFrame = Instance.new("Frame", parent)
        colorFrame.Name = title
        colorFrame.BackgroundColor3 = Window.Theme.Interactive
        colorFrame.Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT)
        colorFrame.BorderSizePixel = 0
        
        local colorCorner = Instance.new("UICorner", colorFrame)
        colorCorner.CornerRadius = UDim.new(0, 6)
        
        local colorLabel = Instance.new("TextLabel", colorFrame)
        colorLabel.BackgroundTransparency = 1
        colorLabel.Position = UDim2.new(0, 12, 0, 0)
        colorLabel.Size = UDim2.new(0.6, 0, 1, 0)
        colorLabel.Font = Enum.Font.GothamBold
        colorLabel.Text = title
        colorLabel.TextColor3 = Window.Theme.Text
        colorLabel.TextSize = FONT_GENERAL
        colorLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local colorDisplay = Instance.new("TextButton", colorFrame)
        colorDisplay.BackgroundColor3 = currentColor
        colorDisplay.Position = UDim2.new(1, -60, 0.5, -14)
        colorDisplay.Size = UDim2.new(0, 48, 0, 28)
        colorDisplay.Text = ""
        colorDisplay.AutoButtonColor = false
        
        local colorDisplayCorner = Instance.new("UICorner", colorDisplay)
        colorDisplayCorner.CornerRadius = UDim.new(0, 4)
        
        local colorDisplayStroke = Instance.new("UIStroke", colorDisplay)
        colorDisplayStroke.Color = Window.Theme.Outline
        colorDisplayStroke.Thickness = 1
        
        -- Simple color picker (RGB sliders in popup)
        local pickerOpen = false
        
        colorDisplay.MouseButton1Click:Connect(function()
            if pickerOpen then return end
            pickerOpen = true
            
            -- Create color picker popup
            local pickerFrame = Instance.new("Frame", screenGui)
            pickerFrame.Name = "ColorPicker"
            pickerFrame.BackgroundColor3 = Window.Theme.Secondary
            pickerFrame.Size = UDim2.new(0, 200, 0, 150)
            pickerFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
            pickerFrame.BorderSizePixel = 0
            pickerFrame.ZIndex = 200
            
            local pickerCorner = Instance.new("UICorner", pickerFrame)
            pickerCorner.CornerRadius = UDim.new(0, 8)
            
            local pickerStroke = Instance.new("UIStroke", pickerFrame)
            pickerStroke.Color = Window.Theme.Outline
            pickerStroke.Thickness = 1.5
            
            local r, g, b = math.floor(currentColor.R * 255), math.floor(currentColor.G * 255), math.floor(currentColor.B * 255)
            
            -- RGB value labels
            local rgbLabel = Instance.new("TextLabel", pickerFrame)
            rgbLabel.BackgroundTransparency = 1
            rgbLabel.Position = UDim2.new(0, 10, 0, 10)
            rgbLabel.Size = UDim2.new(1, -20, 0, 25)
            rgbLabel.Font = Enum.Font.GothamBold
            rgbLabel.Text = string.format("RGB: %d, %d, %d", r, g, b)
            rgbLabel.TextColor3 = Window.Theme.Text
            rgbLabel.TextSize = FONT_GENERAL
            
            -- Color preview
            local colorPreview = Instance.new("Frame", pickerFrame)
            colorPreview.BackgroundColor3 = currentColor
            colorPreview.Position = UDim2.new(0, 10, 0, 40)
            colorPreview.Size = UDim2.new(1, -20, 0, 40)
            
            local previewCorner = Instance.new("UICorner", colorPreview)
            previewCorner.CornerRadius = UDim.new(0, 6)
            
            -- Close button
            local closeBtn = Instance.new("TextButton", pickerFrame)
            closeBtn.BackgroundColor3 = Window.Theme.Accent
            closeBtn.Position = UDim2.new(0, 10, 1, -35)
            closeBtn.Size = UDim2.new(1, -20, 0, 28)
            closeBtn.Font = Enum.Font.GothamBold
            closeBtn.Text = "Done"
            closeBtn.TextColor3 = Window.Theme.Text
            closeBtn.TextSize = FONT_GENERAL
            closeBtn.AutoButtonColor = false
            
            local closeBtnCorner = Instance.new("UICorner", closeBtn)
            closeBtnCorner.CornerRadius = UDim.new(0, 6)
            
            closeBtn.MouseButton1Click:Connect(function()
                currentColor = colorPreview.BackgroundColor3
                colorDisplay.BackgroundColor3 = currentColor
                callback(currentColor)
                pickerFrame:Destroy()
                pickerOpen = false
            end)
            
            -- Simple RGB input boxes would go here
            -- For brevity, using basic color preview + done button
        end)
        
        if elementId then
            Window.Elements[elementId] = {
                Type = "ColorPicker",
                GetValue = function() return currentColor end,
                SetValue = function(color) currentColor = color colorDisplay.BackgroundColor3 = color end
            }
        end
    end
    
    -- ==========================================
    -- ADD PARAGRAPH (Info Text)
    -- ==========================================
    function Window:AddParagraph(tab, config)
        config = config or {}
        local title = config.Title or "Information"
        local content = config.Content or ""
        
        local parent = tab.Content
        if config.Parent then parent = config.Parent end
        
        local paragraphFrame = Instance.new("Frame", parent)
        paragraphFrame.Name = title
        paragraphFrame.BackgroundColor3 = Window.Theme.Interactive
        paragraphFrame.Size = UDim2.new(1, 0, 0, 70)
        paragraphFrame.AutomaticSize = Enum.AutomaticSize.Y
        paragraphFrame.BorderSizePixel = 0
        
        local paragraphCorner = Instance.new("UICorner", paragraphFrame)
        paragraphCorner.CornerRadius = UDim.new(0, 6)
        
        local titleLabel = Instance.new("TextLabel", paragraphFrame)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Position = UDim2.new(0, 12, 0, 8)
        titleLabel.Size = UDim2.new(1, -24, 0, 18)
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.Text = title
        titleLabel.TextColor3 = Window.Theme.Text
        titleLabel.TextSize = FONT_SECTION
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        
        local contentLabel = Instance.new("TextLabel", paragraphFrame)
        contentLabel.BackgroundTransparency = 1
        contentLabel.Position = UDim2.new(0, 12, 0, 30)
        contentLabel.Size = UDim2.new(1, -24, 1, -38)
        contentLabel.Font = Enum.Font.Gotham
        contentLabel.Text = content
        contentLabel.TextColor3 = Window.Theme.TextDim
        contentLabel.TextSize = FONT_GENERAL
        contentLabel.TextXAlignment = Enum.TextXAlignment.Left
        contentLabel.TextYAlignment = Enum.TextYAlignment.Top
        contentLabel.TextWrapped = true
        contentLabel.AutomaticSize = Enum.AutomaticSize.Y
    end
    
    -- ==========================================
    -- ADD BUTTON
    -- ==========================================
    function Window:AddButton(tab, config)
        config = config or {}
        local title = config.Title or "Button"
        local callback = config.Callback or function() end
        
        local parent = tab.Content
        if config.Parent then parent = config.Parent end
        
        local buttonFrame = Instance.new("TextButton", parent)
        buttonFrame.Name = title
        buttonFrame.BackgroundColor3 = Window.Theme.Accent
        buttonFrame.Size = UDim2.new(1, 0, 0, ELEMENT_HEIGHT)
        buttonFrame.BorderSizePixel = 0
        buttonFrame.Font = Enum.Font.GothamBold
        buttonFrame.Text = title
        buttonFrame.TextColor3 = Window.Theme.Text
        buttonFrame.TextSize = FONT_GENERAL
        buttonFrame.AutoButtonColor = false
        
        local buttonCorner = Instance.new("UICorner", buttonFrame)
        buttonCorner.CornerRadius = UDim.new(0, 6)
        
        buttonFrame.MouseButton1Click:Connect(function()
            CircleClick(buttonFrame, buttonFrame.AbsolutePosition.X + buttonFrame.AbsoluteSize.X/2,
                       buttonFrame.AbsolutePosition.Y + buttonFrame.AbsoluteSize.Y/2)
            callback()
        end)
    end
    
    
    -- ==========================================
    -- SET THEME (Live Theme Switching)
    -- ==========================================
    function Window:SetTheme(themeName)
        local newTheme = Themes[themeName]
        if not newTheme then
            Orvion:Notify({
                Title = "Error",
                Content = "Theme not found: " .. themeName,
                Duration = 2
            })
            return
        end
        
        Window.Theme = newTheme
        
        -- Update main frame colors
        mainFrame.BackgroundColor3 = newTheme.Primary
        mainStroke.Color = newTheme.Outline
        header.BackgroundColor3 = newTheme.Primary
        titleLabel.TextColor3 = newTheme.Text
        minimizeBtn.ImageColor3 = newTheme.Text
        closeBtn.ImageColor3 = newTheme.Text
        
        -- Update sidebar
        sidebar.BackgroundColor3 = newTheme.Sidebar
        searchContainer.BackgroundColor3 = newTheme.Interactive
        searchStroke.Color = newTheme.Outline
        searchIcon.ImageColor3 = newTheme.TextDim
        searchInput.TextColor3 = newTheme.Text
        searchInput.PlaceholderColor3 = newTheme.TextDim
        
        -- Update tabs
        for _, tab in pairs(Window.Tabs) do
            tab.Button.BackgroundColor3 = newTheme.Interactive
            tab.Button.TextColor3 = newTheme.TextDim
            if Window.CurrentTab == tab then
                tab.Button.TextColor3 = newTheme.Text
            end
        end
        
        -- Update footer
        footer.BackgroundColor3 = newTheme.Primary
        footer.TextColor3 = newTheme.TextDim
        
        Orvion:Notify({
            Title = "Theme Changed",
            Content = "Theme set to: " .. themeName,
            Duration = 2
        })
    end
    
    -- ==========================================
    -- SAVE CONFIGURATION
    -- ==========================================
    function Window:SaveConfig(configName)
        if not configName or configName == "" then
            Orvion:Notify({
                Title = "Error",
                Content = "Config name cannot be empty",
                Duration = 2
            })
            return false
        end
        
        local elementStates = {}
        
        for id, element in pairs(Window.Elements) do
            elementStates[id] = {
                Type = element.Type,
                Value = element.GetValue()
            }
        end
        
        local success, message = ConfigSystem:Save(configName, elementStates)
        
        if success then
            Orvion:Notify({
                Title = "Config Saved",
                Content = message,
                Duration = 2
            })
        else
            Orvion:Notify({
                Title = "Save Failed",
                Content = message,
                Duration = 3
            })
        end
        
        return success
    end
    
    -- ==========================================
    -- LOAD CONFIGURATION
    -- ==========================================
    function Window:LoadConfig(configName)
        if not configName or configName == "" then
            Orvion:Notify({
                Title = "Error",
                Content = "Config name cannot be empty",
                Duration = 2
            })
            return false
        end
        
        local configData, errorMsg = ConfigSystem:Load(configName)
        
        if not configData then
            Orvion:Notify({
                Title = "Load Failed",
                Content = errorMsg or "Failed to load config",
                Duration = 3
            })
            return false
        end
        
        -- Restore element states
        for id, state in pairs(configData.Elements or {}) do
            local element = Window.Elements[id]
            if element and element.SetValue then
                element.SetValue(state.Value)
            end
        end
        
        Orvion:Notify({
            Title = "Config Loaded",
            Content = "Loaded: " .. configName,
            Duration = 2
        })
        
        return true
    end
    
    -- ==========================================
    -- AUTO-LOAD CONFIGURATION
    -- ==========================================
    if config.Config and config.Config.Enabled and config.Config.AutoLoad then
        task.delay(0.5, function()
            local configData = ConfigSystem:AutoLoad()
            if configData then
                Window:LoadConfig(configData.Name)
            end
        end)
    end
    
    return Window
end

-- ==========================================
-- RETURN ORVION LIBRARY
-- ==========================================
return Orvion

-- ==========================================
-- ORVION UI LIBRARY - EXAMPLE USAGE
-- Complete demonstration of all features
-- ==========================================

local Orvion = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_REPO/orvion_source.luau"))()

-- ==========================================
-- CREATE WINDOW
-- ==========================================
local Window = Orvion:CreateWindow({
    Title = "Orvion UI v2.0",
    Theme = "Dark",
    Size = UDim2.fromOffset(470, 600),
    Config = {
        Enabled = true,
        AutoLoad = true
    }
})

-- ==========================================
-- CREATE TABS
-- ==========================================
local MainTab = Window:AddTab("Main")
local SettingsTab = Window:AddTab("Settings")
local ConfigTab = Window:AddTab("Configuration")

-- ==========================================
-- MAIN TAB - ALL ELEMENTS
-- ==========================================

-- Collapsible Section
Window:AddSection(MainTab, "Player Settings")

-- Toggle
Window:AddToggle(MainTab, {
    Title = "Auto Farm",
    Default = false,
    Callback = function(state)
        print("Auto Farm:", state)
    end,
    ElementId = "AutoFarm"
})

-- Input with validation
Window:AddInput(MainTab, {
    Title = "Walk Speed",
    Default = "16",
    Validation = "number",
    Min = 16,
    Max = 100,
    Callback = function(value)
        print("Walk Speed:", value)
    end,
    ElementId = "WalkSpeed"
})

-- Keybind
Window:AddKeybind(MainTab, {
    Title = "Toggle UI",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key)
        print("Keybind pressed:", key.Name)
    end,
    ElementId = "ToggleKey"
})

-- Dropdown with search
Window:AddDropdown(MainTab, {
    Title = "Select Weapon",
    Values = {"Sword", "Bow", "Staff", "Dagger", "Axe"},
    Default = "Sword",
    Callback = function(selected)
        print("Weapon selected:", selected)
    end,
    ElementId = "WeaponSelect"
})

-- Multi-select dropdown
Window:AddDropdown(MainTab, {
    Title = "Auto Collect Items",
    Values = {"Coins", "Gems", "Keys", "Potions"},
    Multi = true,
    Callback = function(selected)
        print("Selected items:", table.concat(selected, ", "))
    end,
    ElementId = "AutoCollect"
})

-- Slider
Window:AddSlider(MainTab, {
    Title = "Volume",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value)
        print("Volume:", value)
    end,
    ElementId = "Volume"
})

-- Color Picker
Window:AddColorPicker(MainTab, {
    Title = "Accent Color",
    Default = Color3.fromRGB(100, 100, 255),
    Callback = function(color)
        print("Color selected:", color)
    end,
    ElementId = "AccentColor"
})

-- Paragraph (info text)
Window:AddParagraph(MainTab, {
    Title = "Information",
    Content = "This is a demonstration of all Orvion UI features. Use the sidebar search to quickly find tabs."
})

-- Button
Window:AddButton(MainTab, {
    Title = "Test Notification",
    Callback = function()
        Orvion:Notify({
            Title = "Success",
            Content = "Notification system working!",
            Duration = 3
        })
    end
})

-- ==========================================
-- SETTINGS TAB
-- ==========================================

Window:AddSection(SettingsTab, "UI Settings")

Window:AddToggle(SettingsTab, {
    Title = "Show Real Ping",
    Default = false,
    Callback = function(state)
        print("Show Real Ping:", state)
    end,
    ElementId = "ShowPing"
})

Window:AddToggle(SettingsTab, {
    Title = "Potato Mode",
    Default = false,
    Callback = function(state)
        print("Potato Mode:", state)
    end,
    ElementId = "PotatoMode"
})

-- Theme switching
Window:AddDropdown(SettingsTab, {
    Title = "Theme",
    Values = {"Dark", "Crimson", "Ocean", "Forest", "Purple"},
    Default = "Dark",
    Callback = function(theme)
        Window:SetTheme(theme)
    end,
    ElementId = "Theme"
})

-- ==========================================
-- CONFIGURATION TAB
-- ==========================================

-- Config UI uses Orvion's 2-button grid style (built-in)
-- No manual setup needed - handled by library

print("Orvion UI Example loaded successfully!")

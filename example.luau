local OrvionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/KnullXDgt/Orvion-UI-Library/refs/heads/main/source.luau"))()

local Window = OrvionLib:CreateWindow({
    Title = "Orvion UI",
    Theme = "Crimson",
    Size = UDim2.fromOffset(470, 270),
    Center = true,
    Draggable = true,
    Resize = true,
    Badges = {"BETA", "v2.0"},
    MinimizeKey = Enum.KeyCode.RightShift,
    MinimizeButton = true,
    MinimizeButton_Image = "rbxassetid://116850882259653"
})

local MainTab = Window:CreateTab("Main")
local SettingsTab = Window:CreateTab("Settings")

Window:AddParagraph(MainTab, {
    Title = "Welcome",
    Content = "Orvion UI v2.0 - Kairo + Orvion hybrid."
})

Window:AddToggle(MainTab, {
    Title = "Enable Feature",
    Default = false,
    Callback = function(state)
        print("Toggle:", state)
    end
})

Window:AddButton(MainTab, {
    Title = "Show Notification",
    Callback = function()
        OrvionLib:Notify("Orvion UI", "Hello from Orvion v2.0!", 3)
    end
})

Window:AddInput(MainTab, {
    Title = "Username",
    Default = "Player",
    Placeholder = "Enter username...",
    Callback = function(value)
        print("Input:", value)
    end
})

Window:AddDropdown(MainTab, {
    Title = "Weapon",
    Values = {"Sword", "Axe", "Bow", "Staff"},
    DefaultValue = "Sword",
    Callback = function(value)
        print("Dropdown:", value)
    end
})

local Collapsible = Window:AddCollapsibleSection(MainTab, "Advanced", true)
Collapsible:AddToggle({
    Title = "Advanced Feature",
    Default = false,
    Callback = function(state) end
})

Window:AddParagraph(SettingsTab, {
    Title = "Configuration",
    Content = "Manage your settings here."
})

Window:AddButtonGrid(SettingsTab,
    {Title = "Save", Callback = function() OrvionLib:Notify("Config", "Saved!", 2) end},
    {Title = "Load", Callback = function() OrvionLib:Notify("Config", "Loaded!", 2) end}
)

OrvionLib:Notify("Orvion UI", "Library loaded successfully!", 5)

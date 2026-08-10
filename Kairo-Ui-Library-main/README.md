# Kairo UI Library
# Supports PC and Mobile!

Loadstring
```lua
local Kairo = loadstring(game:HttpGet("https://raw.githubusercontent.com/Itzzavi335/Kairo-Ui-Library/refs/heads/main/source.luau"))
```

CreateWindow:
```lua
local Window = Kairo:CreateWindow({
    Title = "KairoUI",
    Theme = "Crimson",
    Size = UDim2.fromOffset(580, 520),
    Center = true,
    Draggable = true,
    Resize = true,
    Badges = {"BETA", "v2.0"},
    MinimizeKey = Enum.KeyCode.RightShift,
    MinimizeButton = true, -- For Mobile
    MinimizeButton_Image = "rbxassetid://116850882259653",
    Config = {
        Enabled = true,
        Folder = "Kairo_Config",
        AutoLoad = true
    }
})
```
AddParagraph:
```lua
Window:AddParagraph(MainTab, "Welcome", "This is the Kairo UI Library with all features!")
```

AddTab:
```lua
local MainTab = Window:CreateTab("Main", "rbxassetid://16932740082")
```
AddDivider:
```lua
Window:AddDivider(MainTab, "Settings Section")
```
AddButton:
```lua
Window:AddButton(MainTab, "Click Me", "This button shows a notification", "rbxassetid://16932740082", function()
    -- Code here
end)
```
AddToggle:
```lua
local MyToggle = Window:AddToggle(MainTab, "Enable Feature", "Toggle this feature on or off", false, function(state)
    -- Code here
end, "FeatureToggle")
```

Toggle Methods: ( not needed )
```lua
MyToggle:Set(true) -- Set toggle state true / false
print(MyToggle.Value) -- Get current state
```
AddInput:
```lua
local MyInput = Window:AddInput(MainTab, "Username", "Enter your username", "Player123", function(value)
    -- Code here
end, "UsernameInput")
```
Input Methods: ( not needed )
```lua
MyInput:Set("NewUsername") -- Set input text
print(MyInput.Value) -- Get current value
```
AddSlider:
```lua
local MySlider = Window:AddLineSlider(MainTab, "Line Speed", "Clean line slider without knob", 0, 100, 50, function(value)
    -- Code here
    print("Line slider value:", value)
end, "LineSpeedSlider")
```
Slider Methods: ( not needed )
```lua
MySlider:Set(75) -- Set slider value
print(MySlider.Value) -- Get current value
```
AddDropdown:
```lua
local MyDropdown = Window:AddDropdown(MainTab, "Weapon", "Select your weapon", 
    {"Sword", "Axe", "Bow", "Staff"}, false, "Sword", function(value)
    -- Code here
end, "WeaponDropdown")
```
AddMultiDropdown:
```lua
local MyMultiDropdown = Window:AddMultiDropdown(MainTab, "Perks", "Select multiple perks",
    {"Speed Boost", "Double Jump", "Invisibility", "Shield", "Regeneration"},
    {"Speed Boost", "Shield"}, -- Default selected values (table)
    function(selectedValues)
        -- Code here
        print("Selected perks:", table.concat(selectedValues, ", "))
    end,
    "PerksDropdown"
)
```
Dropdown Methods: ( not needed )
```lua
MyDropdown:Set("Axe") -- Set selected option
MyDropdown:Refresh({"Gun", "Rifle", "Shotgun"}, "Gun") -- Refresh options
print(MyDropdown.Value) -- Get current value
```
AddKeybind:
```lua
local Keybind = Window:AddKeybind(CombatTab, "Aimbot Key", "Key to activate aimbot", 
    Enum.KeyCode.E,  -- Default key
    function(key)
        print("Key pressed:", key.Name)
    end,
    "AimbotKeybind"
)
```
AddColorPicker:
```lua
local ColorPicker = Window:AddColorPicker(MainTab, "ESP Color", "Choose ESP color", 
    Color3.fromRGB(255, 0, 0),  -- Default color
    function(color)
        print("Color changed:", color.R, color.G, color.B)
    end,
    "ESPColorPicker"
)
```
AddImageBox:
```lua
local ImageBox = Window:AddImageBox(MainTab, "Logo", "Kairo UI Logo", 
    "rbxassetid://16932740082",  -- Image ID
    UDim2.new(0, 150, 0, 150),  -- Size
    function(imageId)
        print("Image clicked:", imageId)
    end,
    "LogoImage"
)
```
AddNotification:
```lua
Window:Notify({
    Title = "Kairo UI Loaded",
    Description = "Welcome",
    Content = "Press RightShift to toggle the UI",
    Color = Color3.fromRGB(200, 0, 50),
    Delay = 5
})
```

SetTheme: ( not needed )
```lua
Window:SetTheme("Forest") -- Changes theme to Forest
```

Configs Management: ( not needed )
```lua
-- Save current settings
Window:SaveConfig("MySettings")

-- Load settings
Window:LoadConfig("MySettings")

-- Delete config
Window:DeleteConfig("OldConfig")

-- Get all config names
local configs = Window:GetConfigs()
for _, name in ipairs(configs) do
    print("Config:", name)
end
```

Credit to Itzzavi

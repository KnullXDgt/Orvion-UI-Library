# Orvion UI Library

A clean, lightweight Roblox UI library built for executor scripts. Dark themed, mobile-friendly, and easy to drop into any script.

---

## Loading

```lua
local Orvion = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/KnullXDgt/Orvion-UI-Library/main/source.luau"
))()
```

---

## Creating a Window

```lua
local Window = Orvion:CreateWindow({
    Title          = "My Script",
    Center         = true,
    Draggable      = true,
    Resizable      = true,
    ToggleButton   = true,          -- floating button to open/close UI
    ConfigFolder   = "MyFolder",    -- folder name in executor workspace
    -- BackgroundImage = "rbxassetid://...",  -- optional bg image (Default theme only)
})
```

---

## Tabs

```lua
local Tab = Window:CreateTab("Features")
```

---

## Collapsible Section

```lua
local Section = Window:AddCollapsible(Tab, "Section Name", true)  -- true = open by default
```

All elements below can be added to a tab directly or inside a collapsible section.

---

## Elements

### Toggle

```lua
Window:AddToggle(Tab, "Enable Something", "Description text", false, function(state)
    print(state)
end)
```

### Button

```lua
Window:AddButton(Tab, "Do Action", "Description", "rbxassetid://16932740082", function()
    print("clicked")
end)
```

### Button Grid (2 side by side)

```lua
Window:AddButtonGrid(Tab,
    { Title = "Start", Callback = function() end },
    { Title = "Stop",  Callback = function() end }
)
```

### Input

```lua
Window:AddInput(Tab, "Player Name", "Optional description", "placeholder", function(value)
    print(value)
end)
```

### Slider

```lua
Window:AddSlider(Tab, "Speed", "Description", 0, 100, 16, function(value)
    print(value)
end)
```

### Dropdown (single)

```lua
Window:AddDropdown(Tab, "Mode", "Description",
    {"Option A", "Option B", "Option C"},
    false, "Option A",
    function(value) print(value) end
)
```

### Dropdown (multi select)

```lua
Window:AddMultiDropdown(Tab, "Perks", "Description",
    {"Speed", "Jump", "Shield"},
    {},
    function(values) print(values) end
)
```

### Paragraph

```lua
Window:AddParagraph(Tab, "Title", "Body text here.")
```

### Color Picker

```lua
Window:AddColorPicker(Tab, "Color", "Pick a color", Color3.fromRGB(255,0,0), function(color)
    print(color)
end)
```

### Keybind

```lua
Window:AddKeybind(Tab, "Hotkey", "Press to activate", Enum.KeyCode.E, function(key)
    print(key.Name)
end)
```

---

## Notification

```lua
Orvion:Notify({
    Title       = "Title",
    Description = "Subtitle",
    Content     = "Message body.",
    Color       = Color3.fromRGB(150, 150, 170),
    Delay       = 3
})
```

---

## Config System

A **Configs** tab is automatically added to every window. It handles:

- **Config Name** — type a name for your config
- **Select Config** — pick an existing saved config
- **Save Config / Load Config** — save or restore all element states to a JSON file
- **Delete Config / Set Autoload** — delete a config or mark it to auto-load on next run
- **Refresh List / Clear Autoload** — refresh the dropdown or clear the autoload marker
- **Reset All Elements** — reset all toggles/sliders/dropdowns/inputs to default

Config files are saved to: `ConfigFolder/Configs/name.json`
Autoload marker: `ConfigFolder/Autoload.txt`

To use a custom folder name:

```lua
local Window = Orvion:CreateWindow({
    Title        = "My Script",
    ConfigFolder = "MyScriptName",
})
```

---

## Search Bar

Type in the search bar (sidebar) to find any element across all tabs and sections. Click a result to jump directly to it with a highlight effect.

---

## Toggle Button (floating)

A draggable button on the left side of the screen to open/close the UI. Enable it with:

```lua
ToggleButton = true,
-- ToggleButton_Image = "rbxassetid://...",  -- optional custom icon
```

---

## Background Image

Shows a background image inside the main content area. Visible only on the Darker theme by default.

```lua
BackgroundImage       = "rbxassetid://123981509631924",
BackgroundImage_Theme = "Darker",  -- which theme shows it
```

---

## Setting Values Programmatically

Every element returns an object you can call `:Set()` on:

```lua
local MyToggle = Window:AddToggle(Tab, "Auto Fish", "", false, function(state) end)
MyToggle:Set(true)

local MySlider = Window:AddSlider(Tab, "Delay", "", 0, 10, 2, function(v) end)
MySlider:Set(5)

local MyDropdown = Window:AddDropdown(Tab, "Mode", "", {"A","B"}, false, "A", function(v) end)
MyDropdown:Set("B")
```

---

## Notes

- Executor: tested on Delta (Android)
- UI is mobile-first — works on both mobile and PC
- All element IDs are auto-generated from their title (spaces and special chars stripped)
- No emoji in script code — Delta will silently fail to parse them

---

*Credits to Kairo UI and Itzzavi*

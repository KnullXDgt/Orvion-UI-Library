# Orvion UI Library v2.0

A modern Roblox UI library that actually looks good. Built from scratch with performance and aesthetics in mind.

## Why Orvion?

Because most Roblox UI libraries are either ugly, slow, or missing features you actually need. Orvion gives you:

- Clean, modern design that works on both PC and mobile
- Smooth animations that don't tank your FPS
- Collapsible sections so your UI isn't a giant wall of toggles
- Search bars where they matter (sidebar + dropdowns)
- Config saving that actually works
- Multiple themes without reloading

## Getting Started

Load it like any other script:

```lua
local Orvion = loadstring(game:HttpGet("https://raw.githubusercontent.com/KnullXDgt/Orvion-UI-Library/main/orvion_source.luau"))()
```

Create a window:

```lua
local Window = Orvion:CreateWindow({
    Title = "My Script",
    Theme = "Dark",
    Config = { Enabled = true, AutoLoad = true }
})
```

Add a tab:

```lua
local MainTab = Window:AddTab("Main")
```

## The Cool Part: Collapsible Sections

Instead of dumping everything into one tab, organize it:

```lua
local section = Window:AddSection(MainTab, "Player Settings")

Window:AddToggle(MainTab, {
    Title = "Speed Hack",
    Default = false,
    Parent = section,  -- Goes inside the collapsible section
    Callback = function(state)
        print("Speed:", state)
    end
})
```

Click the section header to expand/collapse. Way cleaner than scrolling through 50 toggles.

## What's Included

### Basic Stuff
- Toggles (smooth animations, not janky)
- Inputs (with validation so users can't break stuff)
- Dropdowns (full-height with search - no more tiny 5-option lists)
- Sliders (actually responsive, not laggy)
- Buttons (with ripple effects because we're fancy)
- Color pickers (for theme nerds)
- Keybinds (so people can bind your script to whatever key they want)

### Actually Useful Features
- **Sidebar search** - Find tabs instantly instead of scrolling
- **Dropdown search** - Type to filter long dropdown lists
- **Multi-select dropdowns** - Select multiple options at once
- **Config system** - Save/load settings with one function call
- **Theme switching** - 5 built-in themes, switch live without reload
- **Notifications** - Queue system so they don't spam over each other
- **DPI scaling** - Text looks good on 720p mobile and 4K monitors

## Themes

```lua
Window:SetTheme("Ocean")  -- Blue accent
Window:SetTheme("Crimson")  -- Red accent
Window:SetTheme("Forest")  -- Green accent
Window:SetTheme("Purple")  -- Purple accent
Window:SetTheme("Dark")  -- Grayscale (default)
```

## Config Saving

```lua
-- User hits "Save Config" with name "MySetup"
Window:SaveConfig("MySetup")

-- Next session, load it back
Window:LoadConfig("MySetup")
```

If you enable AutoLoad in CreateWindow, it loads the last config automatically.

## Notifications

```lua
Orvion:Notify({
    Title = "Success",
    Content = "Your thing worked",
    Duration = 3
})
```

They stack in the bottom-right and auto-dismiss. No more spam.

## Real Example

Check `orvion_example.luau` for a complete working script. It shows every element and feature.

## File Structure

```
orvion_source.luau   - Main library (~1600 lines)
orvion_config.luau   - Save/load system
orvion_themes.luau   - Color definitions
orvion_example.luau  - Working example
```

You only need to load `orvion_source.luau`. It handles the rest.

## API Quick Reference

### Window
```lua
Orvion:CreateWindow(config) -- Returns Window object
```

### Tabs
```lua
Window:AddTab(name) -- Returns tab object
```

### Sections (Collapsible!)
```lua
Window:AddSection(tab, name) -- Returns section container
```

### Elements
```lua
Window:AddToggle(tab, config)
Window:AddInput(tab, config)
Window:AddDropdown(tab, config)
Window:AddSlider(tab, config)
Window:AddKeybind(tab, config)
Window:AddColorPicker(tab, config)
Window:AddButton(tab, config)
Window:AddParagraph(tab, config)
```

Every element takes a config table. Most important keys:
- `Title` - Label text
- `Default` - Starting value
- `Parent` - Put it inside a section (optional)
- `Callback` - Function that runs on change
- `ElementId` - Unique ID for save/load

Multi-select dropdown? Add `Multi = true` to the config.

Input validation? Add `Validation = "number"`, `Min = 0`, `Max = 100`.

## Notes

- Config saves to executor's file system (writefile/readfile)
- Themes are just color palettes - easy to add your own in `orvion_themes.luau`
- Dropdown search works client-side, no remote calls
- Collapsible sections save vertical space - use them

## Known Issues

None yet. If you find bugs, open an issue.

## Credits

Made by KnullXDgt. Inspired by Kairo UI but rebuilt from scratch.

MIT License - do whatever you want with it.

---

**Repo:** [github.com/KnullXDgt/Orvion-UI-Library](https://github.com/KnullXDgt/Orvion-UI-Library)

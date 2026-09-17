# Fawn Modern — Complete Documentation

This document matches the optimized `Fawn Modern.Lua` build generated with the complete demo. It documents the public API, common options, flags/config behavior, three-dot accessories, images, settings, ESP editing, overlays, schema/dynamic APIs, and the performance system.

> Internal methods whose names begin with `_` are renderer internals and are intentionally not part of the supported public API.

## 1. GitHub loader

The canonical raw library URL is:

`https://raw.githubusercontent.com/Aoruen/Fawn-UI-LIB-Never-Lose/refs/heads/main/Fawn%20Modern.Lua`

A robust asynchronous loader:

```lua
local URL="https://raw.githubusercontent.com/Aoruen/Fawn-UI-LIB-Never-Lose/refs/heads/main/Fawn%20Modern.Lua"
local bust=tostring((utility.GetTickCount and utility.GetTickCount())or 0)
http.Get(URL.."?v="..bust,{["Accept"]="text/plain,*/*",["Cache-Control"]="no-cache"},function(body)
    local chunk,err=loadstring(body)
    assert(chunk,err)
    local Fawn=chunk()
    assert(Fawn and Fawn.IsFawnLibrary,"Fawn failed to initialize")
    Fawn:SetPerformanceMode("Peak")
    -- create UI here
end)
```

The full demo included with this package already uses the GitHub loader and cache-busting URL.

## 2. Performance profiles

`Peak` is the default optimized profile. The performance pass keeps the UI feature set intact while reducing work in the hot render/input paths: cached `Color3` objects, integer-font text measurement caching, cached text fitting, smart hotkey polling until key capture is active, frame time/screen-value reuse, slower failed-image retries, a smaller default snow budget, and direct validated draw dispatch instead of a protected call for every primitive.

```lua
Fawn:SetPerformanceMode("Peak")      -- default / highest runtime throughput
Fawn:SetPerformanceMode("Balanced")  -- slightly larger snow budget
Fawn:SetPerformanceMode("Safe")      -- protected draw calls + full key polling

Fawn:SetFastDraw(true)
Fawn:SetSnowParticleCount(48)

local stats=Fawn:GetPerformanceStats()
print(stats.mode,stats.measureCache,stats.fitCache,stats.rgbCache)
```

Use `Safe` only when debugging a runtime-specific native drawing problem. `Peak` is intended for normal use.

## 3. Create a window

```lua
local W=Fawn.Window({
    title="FAWN",
    subtitle="SEROTONIN",
    logo="F",
    x=45,y=38,
    width=1300,height=985,
    minWidth=900,minHeight=620,
    maxWidth=1900,maxHeight=1300,
    scale=1,
    columns=2,
    theme="Modern Blue",
    toggleKey="Insert",
    toggleLabel="INSERT",
    user="Lua Dekker",
    userSub="Developer",
    group="Global",
    groups={"Global","Rifles","Snipers"},
    smoothScroll=true,
    scrollSpeed=12,
    liquidGlass=false,
    glassOpacity=.72,
    animations=true,
    animationSpeed=10,
    backgroundBlur=false,
    backgroundSnow=false,
    draggable=true,
    resizable=true,
    mainScrollEnabled=true
})
```

Important constructor rules: `scale` is clamped to `0.55–1.65`; `columns` supports `1–4`; resize and UI scale are separate; Windows default to a 900×620 minimum while Panels default smaller. Secondary/narrow windows automatically reflow authored columns rather than letting controls spill outside the frame.

Aliases: `Fawn.Window`, `Fawn.NewWindow`, and `Fawn.new` create a Window. `Fawn.Panel` / `Fawn.NewPanel` create a tabless Panel.

## 4. Tabs and sections

```lua
local Main=W:AddTab("Main",{group="COMBAT",icon="crosshair",selected=true})
local Left=Main:AddSection("AIM",{column=1,row=1,sizeMode="auto"})
local Right=Main:AddSection("MISC",{column=2,row=1,sizeMode="fixed",height=360})
local Grid=Main:AddSection("GRID",{column=1,row=2,span=2,columns=3,controlGap=12})
```

Section size modes: `auto` grows to content, `fixed` owns internal overflow/scrolling, and `fill` stretches to the available row height. `span` controls how many window columns a Section occupies. `columns` inside a Section controls its control grid.

## 5. Controls

Every control can be created as `Section:AddX(...)` or the shorter `Section:X(...)`. Windows also expose `Window:AddX(...)` helpers that create/use an implicit section.

### Toggle
```lua
local Enabled=Left:AddToggle("Enabled",true,{flag="enabled"})
Enabled:OnChanged(function(v) print("enabled",v) end)
```

Toggle with embedded keybind + color picker:
```lua
local Aim=Left:AddToggle("Aim",true,{
    flag="aim",
    keybind={key="Q",label="Q",mode="Toggle",keybindList=true},
    colorPicker={value={125,85,255,255},flag="aimColor"}
})
local key=Aim:GetKeybind()
local color=Aim:GetColorPicker()
```

### Slider
```lua
local Speed=Left:AddSlider("Speed",0,100,50,{
    flag="speed",step=1,
    format=function(v)return math.floor(v).."%"end
})
```

The slider min/max are the **visual track range by default**. Typed/scripted values may exceed it without changing the track size:
```lua
Speed:SetClamp(false)
Speed:Set(250)       -- value is 250; knob stays at the end of the 0–100 track
Speed:SetClamp(true) -- future values are clamped to the visual range
```

Click the slider value box to type a custom number. This also works inside the three-dot accessory popup.

### Dropdown
```lua
local Mode=Left:AddDropdown("Mode",{"Legit","Rage","Hybrid"},1,{flag="mode"})
print(Mode:Get())      -- selected text/value
print(Mode:GetIndex()) -- selected index
```

**Fawn Modern dropdown indices are 1-based.** Clicking an already-open dropdown field closes it. The same toggle-to-close behavior applies to dropdowns inside three-dot accessories.

### Multi-select
```lua
local Hitboxes=Left:AddMultiSelect("Hitboxes",{"Head","Chest","Arms"},{"Head","Chest"},{
    flag="hitboxes",summaryMode="items",summaryItems=2,noneText="None"
})
Hitboxes:SetSelected("Arms",true)
print(Hitboxes:GetSummary())
```

### Text input
```lua
local Name=Left:AddInput("Name","Fawn",{flag="name",placeholder="Type here",maxLength=64})
local Number=Left:AddInput("Number","42.5",{numeric=true,allowFloat=true,allowNegative=true})
local Password=Left:AddInput("Password","secret",{password=true})
Name:OnSubmit(function(v) print("submitted",v) end)
```

The caret uses the exact rendered font geometry, supports left/right/home/end, backspace/delete, and clicking the text places the caret at the nearest character. Password mode only masks rendering; the stored value remains the actual string.

### Color picker
```lua
local C=Left:AddColorPicker("Color",{120,90,255,220},{flag="color"})
C:OnChanged(function(rgba) print(rgba[1],rgba[2],rgba[3],rgba[4]) end)
```

Colors are `{R,G,B,A}` arrays using `0–255`. Three-dot accessory color pickers are fully interactive and modal; they no longer click through to controls behind the popup. Clicking the same chip again closes its picker.

### Keybind
```lua
local K=Left:AddKeybind("Key","V",{mode="Hold",keybindList=true})
K:SetMode("Toggle")
K:SetKey("F6","F6")
print(K:IsActive())
```

Modes include `Hold`, `Toggle`, and `Always` / `Always On` behavior supported by the runtime. Left-click arms capture; Backspace clears; the mode context is available from the keybind UI.

### Buttons, labels, separators, values
```lua
Left:AddButton("Run",function() print("clicked") end)
Left:AddButtonPair("Save",saveFn,"Load",loadFn)
Left:AddLabel("Wrapped help text",{wrap=true,maxLines=3})
Left:AddSeparator("ADVANCED")
Left:AddSpacer(10)
Left:AddValue("FPS",function()return math.floor(1/math.max(utility.GetDeltaTime(),.0001))end,{accent=true})
```

## 6. Flags: what they actually do

Flags are **not decorative**. A flag is the stable ID that lets your feature code and config system find a control.

```lua
local T=Left:AddToggle("Enabled",false,{flag="featureEnabled"})

if W:GetValue("featureEnabled") then
    -- run your actual feature
end

W:SetValue("featureEnabled",true)
local control=W:GetControl("featureEnabled")
```

Flagged controls are included in `W:GetConfig()` unless `noConfig=true`. A flag does not create feature behavior by itself; your script either reads the flag or attaches an `OnChanged` callback.

## 7. Three-dot accessory menus

Any compatible parent control can host a compact child Section:

```lua
local Owner=Left:AddToggle("Targeting",true,{
    keybind={key="G",label="G",mode="Toggle"},
    colorPicker={value={100,150,255,255}}
})

Owner:Extra(function(e)
    e:AddToggle("Prediction",true,{flag="prediction"})
    e:AddSlider("Amount",0,100,35,{flag="predictionAmount"})
    e:AddDropdown("Mode",{"A","B","C"},1,{flag="predictionMode"})
    e:AddInput("Label","hello")
    e:AddColorPicker("Color",{120,90,255,255})
    e:AddKeybind("Key","H",{mode="Hold"})
    e:AddButton("Action",function() print("clicked") end)
end)
```

Direct helpers also exist: `AddAccessoryToggle`, `AddAccessorySlider`, `AddAccessoryDropdown`, `AddAccessoryMultiSelect`, `AddAccessoryInput`, `AddAccessoryColorPicker`, `AddAccessoryKeybind`, `AddAccessoryButton`, and `AddAccessoryLabel`.

Accessory child dropdowns/color pickers are modal: child popups consume their own clicks, do not activate rows behind them, and clicking the same trigger again closes the popup.

## 8. Visibility rules

```lua
local Master=Left:AddToggle("Advanced",false)
local Child=Left:AddSlider("Advanced Value",0,100,50)
Child:ShowWhen(Master,true)

local Note=Left:AddLabel("Only visible while Advanced is off")
Note:HideWhen(Master,true)
```

`ShowWhen`, `HideWhen`, `VisibleWhen`, `ClearVisibilityRule`, and `RefreshVisibility` are available on Controls, Sections, and Tabs.

## 9. Dropdown option mutation and live sources

```lua
Mode:AddOption("New")
Mode:SetOption(1,"Renamed")
Mode:RemoveOption("Hybrid")
Mode:MoveOption(3,1)
Mode:SetOptions({"One","Two","Three"},{preserve="text"})

Mode:SetOptionsSource(function()
    return {"Live A","Live B","Live C"}
end,{interval=500,preserve="index"})

Mode:RefreshOptionsSource(true)
```

## 10. Themes and polish

Built-in theme names are exposed through `Fawn.ThemeNames`.

```lua
W:SetTheme("Midnight")
W:SetThemeColor("accent",{160,90,255,255},true)
W:SetLiquidGlass(true)
W:SetGlassOpacity(.76)
W:SetSurfaceStyle("Frosted")
W:SetMotionStyle("Smooth")
W:SetCornerPreset("Round")
W:SetBackgroundBlur(true)
W:SetBackgroundSnow(true)
```

Runtime theme registration:
```lua
Fawn:AddPreset("My Theme",{
    accent={170,105,255,255},
    activeItem={40,30,55,255},
    outline={75,60,95,255}
})
W:SetTheme("My Theme")
```

## 11. Images and managed storage

Managed folders are created below `C:/Serotonin/files/Fawn Modern/`:

- `Fawn Modern/configs`
- `Fawn Modern/Profile Pictures`
- `Fawn Modern/logo pictures`

```lua
Fawn:EnsureStorage()
local paths=Fawn:GetStoragePaths()
local profiles=Fawn:ListStorage("ProfilePictures")
local logos=Fawn:ListStorage("LogoPictures")

W:ApplyProfileImage("avatar.png")
W:ApplyLogoImage("logo.png")
W:ClearProfileImage()
W:ClearLogoImage()
```

Custom PNG/JPG images are always drawn with explicit white modulation and full alpha, so theme colors and UI tinting do not darken or recolor the source image. Texture loading is cached; the library does not decode images every frame.

## 12. Built-in premade Settings page

```lua
local Settings=Fawn:CreateSettingsPage(W,{
    title="Settings",
    group="MISCELLANEOUS",
    configPath="my_config.lua",
    showInSidebar=false,
    profileOnly=true
})

W:AttachSettingsToProfile({only=true,title="PROFILE",width=261})
```

The premade page includes live Style & Material, Window & Effects, Motion & Input, Profile & Brand, Theme Colors, Configuration, Diagnostics, and Performance sections. The performance section controls Peak/Balanced/Safe mode, Fast Draw, snow particle budget, cache counters, and runtime error counters.

Settings file helpers:
```lua
Settings:SetConfigPath("my_config.lua")
Settings:CaptureDefaults()
Settings:SaveConfig()
Settings:LoadConfig()
Settings:ResetConfig()
Settings:RefreshBrowsers()
```

## 13. Configs and state

In-memory config:
```lua
local cfg=W:GetConfig()
W:LoadConfig(cfg)
W:SaveNamedConfig("Legit")
W:LoadNamedConfig("Legit")
local names=W:GetNamedConfigs()
W:DuplicateNamedConfig()
W:DeleteNamedConfig("Legit")
```

Object state/schema helpers:
```lua
local snap=W:SnapshotState()
W:RestoreState(snap)
local schema=W:ExportSchema()
local clone=W:CloneSchema()
W:ApplySchema(schema)
```

## 14. Panels and secondary windows

```lua
local P=Fawn.Panel({
    title="TOOLS",subtitle="SECONDARY",
    x=1400,y=80,width=560,height=500,
    columns=1,theme="Midnight",
    draggable=true,resizable=true
})
local S=P:AddSection("PANEL",{column=1,row=1})
S:AddToggle("Enabled",true)
```

Secondary windows use responsive topbar/header geometry and automatic narrow-column reflow. The same padding contract is used while resizing.

## 15. Overlays

### Watermark / status bar
```lua
local Mark=W:Watermark({x=25,y=25,autoSize=true,segments={{brand=true},{text="Fawn"}}})
Mark:AddSegment({text=function()return W:GetThemeName()end})
```

### Keybind list
```lua
local Keys=W:KeybindList({title="KEYBINDS",x=25,y=125,auto=true,onlyActive=true})
Keys:Track(K,"Demo Key")
```

### Info panel
```lua
local Info=W:InfoPanel({title="INFO",x=25,y=300,autoSize=true})
Info:AddRow("Theme",function()return W:GetThemeName()end,{accent=true})
Info:AddRow("Scale",function()return math.floor(W:GetScale()*100).."%"end)
```

Every overlay supports visibility, position, dragging, layer, theme binding, padding, auto-size, min/max width, and destruction through the base `Overlay` API.

## 16. ESP Preview

```lua
local ESP=W:ESPPreview({
    tab=Main,
    docked=true,
    editable=true,
    boxes=true,name=true,healthbar=true,
    healthtext=true,distance=true,
    health=78,
    dockWidthRatio=.36
})

ESP:SetElementPosition("name","top")
ESP:SetElementPosition("healthbar","left")
ESP:SetElementPosition("healthtext","right")
ESP:SetElementPosition("distance","bottom")
ESP:SetElementDragPadding(8)
```

Editable ESP widgets follow the cursor while held and commit to the nearest slot only on release. Docked ESP drag ownership stays with the parent Window, preventing the old one-frame flicker/snap-back behavior.

Feature/color binding:
```lua
ESP:BindFeature("boxes",Enabled)
ESP:BindColor("box",C)
ESP:SetFeature("distance",true)
ESP:SetColor("distance",{180,180,190,255})
ESP:SetText("name","Player")
ESP:ResetLayout()
```

## 17. Notifications

```lua
local N=W:Notify("Saved configuration",{
    title="CONFIG",duration=3,
    position="Bottom Right",width=330,maxLines=5,wrap=true
})
N:SetText("Updated")
N:SetDuration(5)
N:Dismiss()
```

## 18. Profile popup and groups

```lua
W:SetProfileName("Lua Dekker")
W:SetProfileSubtitle("Developer")
W:SetBranding({title="FAWN",subtitle="SEROTONIN",logo="F"})

W:SetProfileMenu({
    {label="Settings",callback=function()W:OpenPresetSettings()end,icon="settings"},
    {separator=true,label="TOOLS"},
    {label="Center Window",callback=function()W:Center()end}
},{title="PROFILE",width=261})

W:SetGroups({"Global","Rifles","Snipers"},"Global")
W:SetGroupClick(function() print(W:GetGroup()) end)
```

## 19. Dynamic tabs / sections / controls

```lua
local T=W:CreateTab({name="Runtime",group="DYNAMIC",icon="misc"})
local S=T:CreateSection({name="Runtime Section",column=1,row=1})
local C=S:CreateControl({type="toggle",label="Runtime Toggle",value=true,flag="runtimeToggle"})

S:MoveControl(C,1)
T:MoveSection(S,1)
W:MoveTab(T,1)
```

Use `Destroy()` for permanent removal and `SetVisible(false)` for temporary hiding.

## 20. Declarative schemas

```lua
local SW=Fawn:CreateFromSchema({
    title="SCHEMA WINDOW",
    width=650,height=440,columns=1,
    tabs={{
        name="Main",group="SCHEMA",
        sections={{
            name="SETTINGS",
            controls={{type="toggle",label="Enabled",value=true,flag="enabled"},
                      {type="slider",label="Amount",min=0,max=100,value=50}}
        }}
    }}
})
```

`CreatePanelFromSchema`, `Window:ExportSchema`, `Tab:ExportSchema`, `Section:ExportSchema`, `Window:ApplySchema`, and `Window:CloneSchema` support schema-driven UI construction and rebuilding.

## 21. Events

Windows, Tabs, Sections, Controls, Overlays, and Notifications have the generic event API:

```lua
W:On("custom",function(self,value) print(value) end)
W:Emit("custom",123)
W:Off("custom")
W:ClearEvents()
```

There are also purpose-built callbacks such as `Control:OnChanged`, `Control:OnSubmit`, `Control:OnKeyChanged`, and `Window:OnTabChanged`.

## 22. Diagnostics and validation

```lua
local ok,missing=Fawn:Validate()
local metricsOK,metricMissing=Fawn:ValidateReferenceMetrics()
local treeOK,treeErrors=W:ValidateTree()

local stats=Fawn:GetStats()
local perf=Fawn:GetPerformanceStats()
print(Fawn:GetPaintCount(),Fawn:GetPaintErrors(),Fawn:GetDrawErrors())
```

## 23. Performance guidelines

For the highest FPS: keep `Peak` mode enabled; load images once and reuse them; do not call `ApplyLogoImage`/`ApplyProfileImage` every frame; prefer function-backed `Value` rows only for data you actually need to display live; keep Background Snow at the default 48 or lower if the UI is open during GPU-heavy scenes; hide/destroy overlays you do not use; use `SetVisible(false)` for temporary UI hiding; and avoid rebuilding tabs/options every frame. The library already culls off-screen section controls and only runs full keyboard scanning while a keybind is being captured.

## 24. Complete public API reference

The signatures below are extracted from the final library source. Aliases are noted after the tables.

### Fawn

| Method | Purpose |
|---|---|
| `Fawn:AddPreset(name,t)` | Adds preset. |
| `Fawn:AssertCompatible()` | Assert compatible. |
| `Fawn:ClearImageCache(path)` | Clears image cache. |
| `Fawn:CreateESPPreview(opt)` | Creates esppreview. |
| `Fawn:CreateFromSchema(schema)` | Creates a Window from declarative schema data. |
| `Fawn:CreateInfoPanel(opt)` | Creates info panel. |
| `Fawn:CreateKeybindList(opt)` | Creates keybind list. |
| `Fawn:CreatePanel(opt)` | Creates panel. |
| `Fawn:CreatePanelFromSchema(schema)` | Creates a Panel from declarative schema data. |
| `Fawn:CreatePresetSettingsMenu(window,opt)` | Creates preset settings menu. |
| `Fawn:CreateSettingsPage(window,opt)` | Creates the polished built-in settings page. |
| `Fawn:CreateStatusBar(opt)` | Creates status bar. |
| `Fawn:CreateWatermark(opt)` | Creates watermark. |
| `Fawn:CreateWindow(opt)` | Creates window. |
| `Fawn:DestroyAll()` | Destroy all. |
| `Fawn:EnsureStorage()` | Creates/ensures the managed Fawn storage folders. |
| `Fawn:GetColorClipboard()` | Returns color clipboard. |
| `Fawn:GetDrawErrors()` | Returns draw errors. |
| `Fawn:GetDynamicCapabilities()` | Returns dynamic capabilities. |
| `Fawn:GetFastDraw()` | Returns fast draw. |
| `Fawn:GetImageError(path)` | Returns image error. |
| `Fawn:GetInputState()` | Returns input state. |
| `Fawn:GetKind(object)` | Returns kind. |
| `Fawn:GetNotificationPosition()` | Returns notification position. |
| `Fawn:GetOverlays()` | Returns overlays. |
| `Fawn:GetPadding()` | Returns padding. |
| `Fawn:GetPaintCount()` | Returns paint count. |
| `Fawn:GetPaintErrors()` | Returns paint errors. |
| `Fawn:GetPerformanceMode()` | Returns performance mode. |
| `Fawn:GetPerformanceStats()` | Returns renderer/cache/runtime performance counters. |
| `Fawn:GetPreset(name)` | Returns preset. |
| `Fawn:GetReferenceMetrics()` | Returns reference metrics. |
| `Fawn:GetRules()` | Returns rules. |
| `Fawn:GetSnowParticleCount()` | Returns snow particle count. |
| `Fawn:GetStats()` | Returns stats. |
| `Fawn:GetStorageDisplayPaths()` | Returns storage display paths. |
| `Fawn:GetStoragePaths()` | Returns storage paths. |
| `Fawn:GetTheme()` | Returns theme. |
| `Fawn:GetWindows()` | Returns windows. |
| `Fawn:Is(object,k)` | Is. |
| `Fawn:ListStorage(kind)` | Lists managed config/profile/logo files. |
| `Fawn:MeasureText(value,font,size)` | Measure text. |
| `Fawn:Notify(textValue,opt)` | Creates a notification. |
| `Fawn:PreloadStorageImages(force)` | Preload storage images. |
| `Fawn:ResolveStoragePath(kind,name)` | Resolves a managed storage item to its sandbox path. |
| `Fawn:Section(a,b,c,d)` | Section. |
| `Fawn:SetColorClipboard(v)` | Sets color clipboard. |
| `Fawn:SetFastDraw(v)` | Turns direct native draw dispatch on/off. |
| `Fawn:SetNotificationPosition(v)` | Sets notification position. |
| `Fawn:SetPerformanceMode(mode)` | Switches between Peak, Balanced, and Safe performance profiles. |
| `Fawn:SetSnowParticleCount(v)` | Changes the background-snow particle budget. |
| `Fawn:SetTheme(name)` | Applies a theme preset. |
| `Fawn:SettingsPage(a,b,c)` | Sets ings page. |
| `Fawn:Tab(a,b,c)` | Tab. |
| `Fawn:Validate()` | Validates . |
| `Fawn:ValidateObjectTree(window)` | Validates object tree. |
| `Fawn:ValidateReferenceMetrics()` | Validates reference metrics. |
| `Fawn:WrapText(value,maxWidth,font,maxLines,size)` | Wrap text. |

### Window

| Method | Purpose |
|---|---|
| `Window:AddGroup(value, index)` | Adds group. |
| `Window:AddPresetSettingsMenu(opt)` | Adds preset settings menu. |
| `Window:AddProfileMenuBuiltin(id,opt)` | Adds profile menu builtin. |
| `Window:AddProfileMenuItem(label,callback,options)` | Adds profile menu item. |
| `Window:AddProfileMenuSeparator(label,opt)` | Adds profile menu separator. |
| `Window:AddSection(name,opt)` | Adds section. |
| `Window:AddSettingsPage(opt)` | Adds settings page. |
| `Window:ApplyLogoImage(v)` | Force-loads and applies a managed logo image. |
| `Window:ApplyProfileImage(v)` | Force-loads and applies a managed profile image. |
| `Window:ApplySchema(schema, options)` | Applies schema data to a window. |
| `Window:AttachSettingsToProfile(opt)` | Adds/attaches the built-in Settings page to the profile popup. |
| `Window:BindToggleKey(control)` | Bind toggle key. |
| `Window:Center()` | Center. |
| `Window:ClearGlassTint()` | Clears glass tint. |
| `Window:ClearGroups()` | Clears groups. |
| `Window:ClearLogoImage()` | Clears logo image. |
| `Window:ClearProfileImage()` | Clears profile image. |
| `Window:ClearProfileMenuItems()` | Clears profile menu items. |
| `Window:ClearSurfaceOpacity(role)` | Clears surface opacity. |
| `Window:ClearSurfaceTint(role)` | Clears surface tint. |
| `Window:ClearTabs()` | Clears tabs. |
| `Window:CloneSchema()` | Clone schema. |
| `Window:CreateTab(definition, options)` | Creates tab. |
| `Window:CreateTabs(definitions)` | Creates tabs. |
| `Window:DeleteNamedConfig(name)` | Delete named config. |
| `Window:Destroy()` | Permanently destroys the object. |
| `Window:DuplicateNamedConfig()` | Duplicate named config. |
| `Window:ESPPreview(opt)` | Esppreview. |
| `Window:ExportSchema()` | Exports the object or subtree as schema data. |
| `Window:FindControl(predicate)` | Finds control. |
| `Window:FindSection(predicate)` | Finds section. |
| `Window:FindTab(predicate)` | Finds tab. |
| `Window:ForEachControl(fn)` | For each control. |
| `Window:ForEachSection(callback)` | For each section. |
| `Window:ForEachTab(callback)` | For each tab. |
| `Window:GetBodyBounds()` | Returns body bounds. |
| `Window:GetColumns()` | Returns columns. |
| `Window:GetConfig()` | Builds an in-memory config table from flagged controls. |
| `Window:GetControl(flag)` | Returns control. |
| `Window:GetDraggable()` | Returns draggable. |
| `Window:GetGlassOpacity()` | Returns glass opacity. |
| `Window:GetGlassTint()` | Returns glass tint. |
| `Window:GetGlassTintStrength()` | Returns glass tint strength. |
| `Window:GetGroup()` | Returns group. |
| `Window:GetGroups()` | Returns groups. |
| `Window:GetIndependentTheme()` | Returns independent theme. |
| `Window:GetKeybindPickerWidth(control,maxW)` | Returns keybind picker width. |
| `Window:GetLayoutSnapshot()` | Returns layout snapshot. |
| `Window:GetLiquidGlass()` | Returns liquid glass. |
| `Window:GetLogoText()` | Returns logo text. |
| `Window:GetMainScrollEnabled()` | Returns main scroll enabled. |
| `Window:GetMaximumSize()` | Returns maximum size. |
| `Window:GetMetrics()` | Returns metrics. |
| `Window:GetMinimumSize()` | Returns minimum size. |
| `Window:GetMotionStyle()` | Returns motion style. |
| `Window:GetNamedConfigs()` | Returns named configs. |
| `Window:GetNotificationPosition()` | Returns notification position. |
| `Window:GetOutlineColor()` | Returns outline color. |
| `Window:GetOutlineStrength()` | Returns outline strength. |
| `Window:GetPixelMetrics()` | Returns pixel metrics. |
| `Window:GetPosition()` | Returns position. |
| `Window:GetPresetSettingsMenu()` | Returns preset settings menu. |
| `Window:GetProfile()` | Returns profile. |
| `Window:GetProfileMenuItems()` | Returns profile menu items. |
| `Window:GetResizable()` | Returns resizable. |
| `Window:GetResolvedProfileMenu()` | Returns resolved profile menu. |
| `Window:GetScale()` | Returns scale. |
| `Window:GetScrollSpeed()` | Returns scroll speed. |
| `Window:GetSize()` | Returns size. |
| `Window:GetStyle()` | Returns style. |
| `Window:GetSubtitle()` | Returns subtitle. |
| `Window:GetSurfaceStyle()` | Returns surface style. |
| `Window:GetTab(which)` | Returns tab. |
| `Window:GetTabCount()` | Returns tab count. |
| `Window:GetTabGroups()` | Returns tab groups. |
| `Window:GetTabs()` | Returns tabs. |
| `Window:GetTabsInGroup(groupName)` | Returns tabs in group. |
| `Window:GetTheme()` | Returns theme. |
| `Window:GetThemeName()` | Returns theme name. |
| `Window:GetTitle()` | Returns title. |
| `Window:GetValue(flag)` | Reads a flagged control by flag. |
| `Window:InfoPanel(opt)` | Info panel. |
| `Window:InsertTab(index,name,opt)` | Insert tab. |
| `Window:IsTabBarVisible()` | Is tab bar visible. |
| `Window:KeybindList(opt)` | Keybind list. |
| `Window:LoadConfig(cfg,silent)` | Loads an in-memory config table. |
| `Window:LoadNamedConfig(name,silent)` | Loads a named in-memory config. |
| `Window:MoveGroup(value, index)` | Moves group. |
| `Window:MoveTab(which,index)` | Moves tab. |
| `Window:Notify(textValue,opt)` | Creates a notification. |
| `Window:OnTabChanged(fn)` | On tab changed. |
| `Window:OpenPresetSettings()` | Open preset settings. |
| `Window:RebuildTabs(definitions, selected)` | Rebuild tabs. |
| `Window:RemoveGroup(value)` | Removes group. |
| `Window:RemoveProfileMenuItem(which)` | Removes profile menu item. |
| `Window:RemoveTab(which)` | Removes tab. |
| `Window:ResetPolish()` | Reset polish. |
| `Window:ResetReferenceMetrics()` | Reset reference metrics. |
| `Window:RestoreState(snapshot, silent)` | Restore state. |
| `Window:SaveNamedConfig(name)` | Stores a named in-memory config. |
| `Window:SelectTab(which)` | Select tab. |
| `Window:SetAccentGlow(v)` | Sets accent glow. |
| `Window:SetAnimationSpeed(v)` | Sets animation speed. |
| `Window:SetAnimations(v)` | Sets animations. |
| `Window:SetBackgroundBlur(v)` | Enables/disables the full-screen dim/frost backdrop. |
| `Window:SetBackgroundSnow(v)` | Enables/disables animated background snow. |
| `Window:SetBorderThickness(v)` | Sets border thickness. |
| `Window:SetBranding(opt)` | Sets branding. |
| `Window:SetColumns(n)` | Sets columns. |
| `Window:SetCompact(v)` | Sets compact. |
| `Window:SetCornerPreset(name)` | Sets corner preset. |
| `Window:SetCornerRadius(v)` | Sets corner radius. |
| `Window:SetDraggable(value)` | Sets draggable. |
| `Window:SetFont(_)` | Sets font. |
| `Window:SetGlassOpacity(v)` | Sets glass opacity. |
| `Window:SetGlassTint(color,strength)` | Sets glass tint. |
| `Window:SetGlassTintStrength(v)` | Sets glass tint strength. |
| `Window:SetGroup(v)` | Sets group. |
| `Window:SetGroupClick(fn)` | Sets group click. |
| `Window:SetGroups(list,current)` | Sets groups. |
| `Window:SetHoverAnimations(v)` | Sets hover animations. |
| `Window:SetIndependentTheme(v)` | Sets independent theme. |
| `Window:SetLayoutMode(v)` | Sets layout mode. |
| `Window:SetLiquidGlass(v)` | Enables/disables liquid-glass rendering. |
| `Window:SetLogoImage(v,force)` | Sets logo image. |
| `Window:SetLogoText(value)` | Sets logo text. |
| `Window:SetMainScrollEnabled(v)` | Sets main scroll enabled. |
| `Window:SetMaximumSize(width, height)` | Sets maximum size. |
| `Window:SetMinimumSize(width, height)` | Sets minimum size. |
| `Window:SetMotionStyle(name)` | Applies an animation/motion preset. |
| `Window:SetNotificationPosition(v)` | Sets notification position. |
| `Window:SetOutlineColor(v)` | Sets outline color. |
| `Window:SetOutlineOpacity(v)` | Sets outline opacity. |
| `Window:SetOutlineStrength(v)` | Sets outline strength. |
| `Window:SetPosition(x,y)` | Sets position. |
| `Window:SetProfile(profile)` | Sets profile. |
| `Window:SetProfileClick(fn)` | Sets profile click. |
| `Window:SetProfileDivider(v)` | Sets profile divider. |
| `Window:SetProfileImage(v,force)` | Sets profile image. |
| `Window:SetProfileMenu(items,opt)` | Replaces the profile popup menu definition. |
| `Window:SetProfileMenuTitle(v)` | Sets profile menu title. |
| `Window:SetProfileMenuWidth(v)` | Sets profile menu width. |
| `Window:SetProfileName(v)` | Sets profile name. |
| `Window:SetProfileSubtitle(v)` | Sets profile subtitle. |
| `Window:SetRadiusScale(v)` | Sets radius scale. |
| `Window:SetResizable(value)` | Sets resizable. |
| `Window:SetScale(v)` | Sets scale. |
| `Window:SetScrollSpeed(v)` | Sets scroll speed. |
| `Window:SetSidebarStitch(v)` | Sets sidebar stitch. |
| `Window:SetSize(w,h)` | Sets size. |
| `Window:SetSmoothScroll(v)` | Sets smooth scroll. |
| `Window:SetStyle(t)` | Sets style. |
| `Window:SetSubtitle(value)` | Sets subtitle. |
| `Window:SetSurfaceHighlights(v)` | Sets surface highlights. |
| `Window:SetSurfaceOpacity(role,value)` | Sets surface opacity. |
| `Window:SetSurfaceStyle(name,preserveOpacity)` | Applies a surface material preset. |
| `Window:SetSurfaceTint(role,color,strength)` | Sets surface tint. |
| `Window:SetSwitchAnimations(v)` | Sets switch animations. |
| `Window:SetTabBarVisible(v)` | Sets tab bar visible. |
| `Window:SetTheme(name,localOnly)` | Applies a theme preset. |
| `Window:SetThemeColor(key,v,localOnly)` | Overrides one theme color. |
| `Window:SetTitle(value)` | Sets title. |
| `Window:SetToggleKey(key,label)` | Sets toggle key. |
| `Window:SetValue(flag,v,silent)` | Sets a flagged control by flag. |
| `Window:SetVisible(v)` | Shows/hides the object without destroying it. |
| `Window:SnapshotState()` | Snapshot state. |
| `Window:StatusBar(opt)` | Status bar. |
| `Window:Tab(name,opt)` | Tab. |
| `Window:Toggle()` | Toggles visibility. |
| `Window:UseDefaultProfileMenu(v)` | Use default profile menu. |
| `Window:ValidateTree()` | Validates the current object tree. |
| `Window:Watermark(opt)` | Watermark. |

Also supports `:On(eventName, callback)`, `:Off(eventName, callback)`, `:Emit(eventName, ...)`, and `:ClearEvents(eventName?)`.

### Tab

| Method | Purpose |
|---|---|
| `Tab:ClearSections()` | Clears sections. |
| `Tab:CreateSection(definition)` | Creates section. |
| `Tab:CreateSections(definitions)` | Creates sections. |
| `Tab:Destroy()` | Permanently destroys the object. |
| `Tab:ExportSchema()` | Exports the object or subtree as schema data. |
| `Tab:GetGroup()` | Returns group. |
| `Tab:GetIcon()` | Returns icon. |
| `Tab:GetIndex()` | Returns index. |
| `Tab:GetMainScrollEnabled()` | Returns main scroll enabled. |
| `Tab:GetMaxScroll()` | Returns max scroll. |
| `Tab:GetName()` | Returns name. |
| `Tab:GetScroll()` | Returns scroll. |
| `Tab:GetScrollStep()` | Returns scroll step. |
| `Tab:GetSection(which)` | Returns section. |
| `Tab:GetSectionCount()` | Returns section count. |
| `Tab:GetSections()` | Returns sections. |
| `Tab:GetSidebarHidden()` | Returns sidebar hidden. |
| `Tab:GetWindow()` | Returns window. |
| `Tab:InsertSection(index,name,opt)` | Insert section. |
| `Tab:MoveAfter(other)` | Moves after. |
| `Tab:MoveBefore(other)` | Moves before. |
| `Tab:MoveSection(which,index)` | Moves section. |
| `Tab:OnSelected(fn)` | On selected. |
| `Tab:RebuildSections(definitions)` | Rebuild sections. |
| `Tab:RemoveSection(which)` | Removes section. |
| `Tab:ScrollBottom()` | Scrolls bottom. |
| `Tab:ScrollBy(n)` | Scrolls by. |
| `Tab:ScrollTo(n)` | Scrolls to. |
| `Tab:ScrollTop()` | Scrolls top. |
| `Tab:Section(name,opt)` | Section. |
| `Tab:Select()` | Select. |
| `Tab:SetGroup(value)` | Sets group. |
| `Tab:SetIcon(value)` | Sets icon. |
| `Tab:SetMainScrollEnabled(v)` | Sets main scroll enabled. |
| `Tab:SetName(value)` | Sets name. |
| `Tab:SetOrder(index)` | Sets order. |
| `Tab:SetScrollStep(n)` | Sets scroll step. |
| `Tab:SetSidebarHidden(v)` | Sets sidebar hidden. |
| `Tab:SetVisible(v)` | Shows/hides the object without destroying it. |

Also supports `:On(eventName, callback)`, `:Off(eventName, callback)`, `:Emit(eventName, ...)`, and `:ClearEvents(eventName?)`.

### Section

| Method | Purpose |
|---|---|
| `Section:Button(label,fn,opt)` | Button. |
| `Section:ButtonPair(leftText,leftFn,rightText,rightFn,opt)` | Button pair. |
| `Section:ClearControls()` | Clears controls. |
| `Section:ColorPicker(label,default,opt)` | Color picker. |
| `Section:CreateControl(definition)` | Creates control. |
| `Section:CreateControls(definitions)` | Creates controls. |
| `Section:Destroy()` | Permanently destroys the object. |
| `Section:Dropdown(label,options,default,opt)` | Dropdown. |
| `Section:ExportSchema()` | Exports the object or subtree as schema data. |
| `Section:FindControl(predicate)` | Finds control. |
| `Section:ForEachControl(callback)` | For each control. |
| `Section:GetColumnDividers()` | Returns column dividers. |
| `Section:GetColumns()` | Returns columns. |
| `Section:GetControl(which)` | Returns control. |
| `Section:GetControlCount()` | Returns control count. |
| `Section:GetControls()` | Returns controls. |
| `Section:GetHeight()` | Returns height. |
| `Section:GetIndex()` | Returns index. |
| `Section:GetMaxHeight()` | Returns max height. |
| `Section:GetMinHeight()` | Returns min height. |
| `Section:GetName()` | Returns name. |
| `Section:GetResolvedHeight()` | Returns resolved height. |
| `Section:GetScrollStep()` | Returns scroll step. |
| `Section:GetSizeMode()` | Returns size mode. |
| `Section:GetTab()` | Returns tab. |
| `Section:GetWindow()` | Returns window. |
| `Section:Input(label,default,opt)` | Input. |
| `Section:InsertControl(index, control)` | Insert control. |
| `Section:Keybind(label,key,opt)` | Keybind. |
| `Section:Label(textValue,opt)` | Label. |
| `Section:MoveControl(which,newIndex)` | Moves control. |
| `Section:MoveControlAfter(which,target)` | Moves control after. |
| `Section:MoveControlBefore(which,target)` | Moves control before. |
| `Section:MultiSelect(label,options,default,opt)` | Multi select. |
| `Section:RebuildControls(definitions)` | Rebuild controls. |
| `Section:RemoveControl(which)` | Removes control. |
| `Section:ScrollBottom()` | Scrolls bottom. |
| `Section:ScrollBy(n)` | Scrolls by. |
| `Section:ScrollTo(n)` | Scrolls to. |
| `Section:ScrollTop()` | Scrolls top. |
| `Section:Separator(textValue,opt)` | Separator. |
| `Section:SetAutoSize(v)` | Sets auto size. |
| `Section:SetColumn(n)` | Sets column. |
| `Section:SetColumnDividers(v)` | Sets column dividers. |
| `Section:SetColumns(n)` | Sets columns. |
| `Section:SetControlGap(n)` | Sets control gap. |
| `Section:SetFillHeight(v)` | Sets fill height. |
| `Section:SetFullWidth(v)` | Sets full width. |
| `Section:SetHeight(h)` | Sets height. |
| `Section:SetMaxHeight(v)` | Sets max height. |
| `Section:SetMinHeight(v)` | Sets min height. |
| `Section:SetName(value)` | Sets name. |
| `Section:SetOrder(index)` | Sets order. |
| `Section:SetRow(n)` | Sets row. |
| `Section:SetScrollStep(n)` | Sets scroll step. |
| `Section:SetSizeMode(mode,height)` | Sets size mode. |
| `Section:SetSpan(n)` | Sets span. |
| `Section:SetVisible(v)` | Shows/hides the object without destroying it. |
| `Section:Slider(label,lo,hi,default,opt)` | Slider. |
| `Section:Spacer(height,opt)` | Spacer. |
| `Section:Toggle(label,default,opt)` | Toggles visibility. |
| `Section:ToggleKeybind(label,default,key,opt)` | Toggle keybind. |
| `Section:Value(label,value,opt)` | Value. |

Also supports `:On(eventName, callback)`, `:Off(eventName, callback)`, `:Emit(eventName, ...)`, and `:ClearEvents(eventName?)`.

### Control

| Method | Purpose |
|---|---|
| `Control:AddAccessoryButton(...)` | Adds accessory button. |
| `Control:AddAccessoryColorPicker(...)` | Adds accessory color picker. |
| `Control:AddAccessoryDropdown(...)` | Adds accessory dropdown. |
| `Control:AddAccessoryInput(...)` | Adds accessory input. |
| `Control:AddAccessoryKeybind(...)` | Adds accessory keybind. |
| `Control:AddAccessoryLabel(...)` | Adds accessory label. |
| `Control:AddAccessoryMultiSelect(...)` | Adds accessory multi select. |
| `Control:AddAccessorySlider(...)` | Adds accessory slider. |
| `Control:AddAccessoryToggle(...)` | Adds accessory toggle. |
| `Control:AddOption(v,index)` | Adds option. |
| `Control:Append(v,silent)` | Append. |
| `Control:Blur()` | Blur. |
| `Control:Clear(silent)` | Clears . |
| `Control:ClearExtra()` | Clears extra. |
| `Control:ClearKey()` | Clears key. |
| `Control:ClearOptions(opt)` | Clears options. |
| `Control:ClearOptionsSource()` | Clears options source. |
| `Control:ClearSelection(silent)` | Clears selection. |
| `Control:Destroy()` | Permanently destroys the object. |
| `Control:Extra(fn)` | Builds the three-dot accessory section for a control. |
| `Control:FindOption(v)` | Finds option. |
| `Control:Focus()` | Focus. |
| `Control:Get()` | Returns the control value in its user-facing form. |
| `Control:GetClamp()` | Returns whether slider clamping is enabled. |
| `Control:GetColorPicker()` | Returns color picker. |
| `Control:GetControlIndex()` | Returns control index. |
| `Control:GetCursor()` | Returns cursor. |
| `Control:GetDescription()` | Returns description. |
| `Control:GetDropdownScroll()` | Returns dropdown scroll. |
| `Control:GetDropdownScrollStep()` | Returns dropdown scroll step. |
| `Control:GetExtraSection()` | Returns a control’s three-dot accessory section. |
| `Control:GetFlag()` | Returns flag. |
| `Control:GetFormat()` | Returns format. |
| `Control:GetIndex()` | Returns index. |
| `Control:GetKey()` | Returns key. |
| `Control:GetKeybind()` | Returns keybind. |
| `Control:GetMaxLength()` | Returns max length. |
| `Control:GetMaxVisibleOptions()` | Returns max visible options. |
| `Control:GetMode()` | Returns mode. |
| `Control:GetNoConfig()` | Returns no config. |
| `Control:GetNoneText()` | Returns none text. |
| `Control:GetNumber(default)` | Returns number. |
| `Control:GetOptionCount()` | Returns option count. |
| `Control:GetOptions()` | Returns options. |
| `Control:GetPickerWidth(maxW)` | Returns picker width. |
| `Control:GetPlaceholder()` | Returns placeholder. |
| `Control:GetRange()` | Returns range. |
| `Control:GetRaw()` | Returns the underlying stored value. |
| `Control:GetRowHover()` | Returns row hover. |
| `Control:GetSection()` | Returns section. |
| `Control:GetSelected()` | Returns selected. |
| `Control:GetSelectedCount()` | Returns selected count. |
| `Control:GetSelectedIndices()` | Returns selected indices. |
| `Control:GetStep()` | Returns step. |
| `Control:GetSummary()` | Returns summary. |
| `Control:GetSummaryMode()` | Returns summary mode. |
| `Control:GetTooltip()` | Returns tooltip. |
| `Control:GetWindow()` | Returns window. |
| `Control:GetWrap()` | Returns wrap. |
| `Control:HasOption(v)` | Has option. |
| `Control:IsActive()` | Is active. |
| `Control:IsFocused()` | Is focused. |
| `Control:IsKeyCleared()` | Is key cleared. |
| `Control:IsPassword()` | Is password. |
| `Control:IsSelected(which)` | Is selected. |
| `Control:MoveAfter(c)` | Moves after. |
| `Control:MoveBefore(c)` | Moves before. |
| `Control:MoveOption(from,to)` | Moves option. |
| `Control:OnChanged(fn)` | Registers the control change callback. |
| `Control:OnKeyChanged(fn)` | On key changed. |
| `Control:OnSubmit(fn)` | On submit. |
| `Control:RefreshOptions(list,preserve,opt)` | Refreshes options. |
| `Control:RefreshOptionsSource(force)` | Forces a dynamic option-source refresh. |
| `Control:RemoveOption(which,opt)` | Removes option. |
| `Control:ScrollOptionsTo(which)` | Scrolls options to. |
| `Control:SelectAll(silent)` | Select all. |
| `Control:Set(v,silent)` | Sets the control value; pass silent=true to suppress the callback. |
| `Control:SetClamp(v)` | Enables/disables slider value clamping to the visual min/max. |
| `Control:SetColor(v)` | Sets color. |
| `Control:SetColumn(v)` | Sets column. |
| `Control:SetCursor(v)` | Sets cursor. |
| `Control:SetDescription(value)` | Sets description. |
| `Control:SetDisabled(v)` | Sets disabled. |
| `Control:SetDropdownScroll(n)` | Sets dropdown scroll. |
| `Control:SetDropdownScrollStep(n)` | Sets dropdown scroll step. |
| `Control:SetFlag(v)` | Sets flag. |
| `Control:SetFormat(callback)` | Sets format. |
| `Control:SetKey(key,label)` | Sets key. |
| `Control:SetKeybind(key,opt)` | Sets keybind. |
| `Control:SetLineHeight(v)` | Sets line height. |
| `Control:SetListVisible(v)` | Sets list visible. |
| `Control:SetMaxLength(v)` | Sets max length. |
| `Control:SetMaxLines(v)` | Sets max lines. |
| `Control:SetMaxVisibleOptions(n)` | Sets max visible options. |
| `Control:SetMode(mode)` | Sets mode. |
| `Control:SetNoConfig(value)` | Sets no config. |
| `Control:SetNoneText(value)` | Sets none text. |
| `Control:SetNumeric(v,allowFloat,allowNegative)` | Sets numeric. |
| `Control:SetOption(i,v,opt)` | Sets option. |
| `Control:SetOptions(list,opt)` | Replaces a dropdown/multiselect option list. |
| `Control:SetOptionsSource(fn,opt)` | Attaches a dynamic dropdown option source. |
| `Control:SetOrder(i)` | Sets order. |
| `Control:SetPassword(v)` | Sets password. |
| `Control:SetPlaceholder(v)` | Sets placeholder. |
| `Control:SetRange(lo,hi)` | Sets range. |
| `Control:SetRow(v)` | Sets row. |
| `Control:SetRowHover(v)` | Sets row hover. |
| `Control:SetSelected(which,on,silent)` | Sets selected. |
| `Control:SetSpan(v)` | Sets span. |
| `Control:SetStep(value)` | Sets step. |
| `Control:SetSummaryMode(mode, maxItems)` | Sets summary mode. |
| `Control:SetText(v)` | Sets text. |
| `Control:SetTooltip(value)` | Sets tooltip. |
| `Control:SetVisible(v)` | Shows/hides the object without destroying it. |
| `Control:SetWrap(v)` | Sets wrap. |
| `Control:Submit()` | Submit. |
| `Control:ToggleOption(which,silent)` | Toggle option. |

Also supports `:On(eventName, callback)`, `:Off(eventName, callback)`, `:Emit(eventName, ...)`, and `:ClearEvents(eventName?)`.

### Overlay

| Method | Purpose |
|---|---|
| `Overlay:BindWindow(w)` | Bind window. |
| `Overlay:Destroy()` | Permanently destroys the object. |
| `Overlay:GetAutoSize()` | Returns auto size. |
| `Overlay:GetPadding()` | Returns padding. |
| `Overlay:GetPosition()` | Returns position. |
| `Overlay:GetSize()` | Returns size. |
| `Overlay:SetAutoSize(v)` | Sets auto size. |
| `Overlay:SetDraggable(v)` | Sets draggable. |
| `Overlay:SetIndependentTheme(v)` | Sets independent theme. |
| `Overlay:SetLayer(v)` | Sets layer. |
| `Overlay:SetMaxWidth(v)` | Sets max width. |
| `Overlay:SetMinWidth(v)` | Sets min width. |
| `Overlay:SetPadding(v)` | Sets padding. |
| `Overlay:SetPosition(x,y)` | Sets position. |
| `Overlay:SetTheme(name)` | Applies a theme preset. |
| `Overlay:SetVisible(v)` | Shows/hides the object without destroying it. |
| `Overlay:Toggle()` | Toggles visibility. |

Also supports `:On(eventName, callback)`, `:Off(eventName, callback)`, `:Emit(eventName, ...)`, and `:ClearEvents(eventName?)`.

### Watermark

| Method | Purpose |
|---|---|
| `Watermark:AddSegment(value,opt)` | Adds segment. |
| `Watermark:Clear()` | Clears . |
| `Watermark:ClearSegments()` | Clears segments. |
| `Watermark:ClearSegmentsSource()` | Clears segments source. |
| `Watermark:GetSegment(i)` | Returns segment. |
| `Watermark:GetSegmentCount()` | Returns segment count. |
| `Watermark:GetSegments()` | Returns segments. |
| `Watermark:InsertSegment(index,value,opt)` | Insert segment. |
| `Watermark:MoveSegment(from,to)` | Moves segment. |
| `Watermark:RefreshSegmentsSource(force)` | Refreshes segments source. |
| `Watermark:RemoveSegment(i)` | Removes segment. |
| `Watermark:SetAutoWidth(v)` | Sets auto width. |
| `Watermark:SetSegment(i,value,opt)` | Sets segment. |
| `Watermark:SetSegmentPadding(v)` | Sets segment padding. |
| `Watermark:SetSegments(list)` | Sets segments. |
| `Watermark:SetSegmentsSource(fn,opt)` | Sets segments source. |
| `Watermark:SetText(i,v)` | Sets text. |

### KeybindList

| Method | Purpose |
|---|---|
| `KeybindList:Clear()` | Clears . |
| `KeybindList:SetOnlyActive(v)` | Sets only active. |
| `KeybindList:Track(control,name)` | Track. |
| `KeybindList:Untrack(control)` | Untrack. |

### InfoPanel

| Method | Purpose |
|---|---|
| `InfoPanel:AddRow(label,value,opt)` | Adds row. |
| `InfoPanel:Clear()` | Clears . |
| `InfoPanel:ClearRowsSource()` | Clears rows source. |
| `InfoPanel:FindRow(label)` | Finds row. |
| `InfoPanel:GetRow(i)` | Returns row. |
| `InfoPanel:GetRowCount()` | Returns row count. |
| `InfoPanel:GetRows()` | Returns rows. |
| `InfoPanel:InsertRow(index,label,value,opt)` | Insert row. |
| `InfoPanel:MoveRow(from,to)` | Moves row. |
| `InfoPanel:RefreshRowsSource(force)` | Refreshes rows source. |
| `InfoPanel:RemoveRow(which)` | Removes row. |
| `InfoPanel:SetRow(i,label,value)` | Sets row. |
| `InfoPanel:SetRows(rows)` | Sets rows. |
| `InfoPanel:SetRowsSource(fn,opt)` | Sets rows source. |

### ESPPreview

| Method | Purpose |
|---|---|
| `ESPPreview:BindColor(name,control)` | Bind color. |
| `ESPPreview:BindFeature(name,control)` | Bind feature. |
| `ESPPreview:GetAnimateHealth()` | Returns animate health. |
| `ESPPreview:GetColor(name)` | Returns color. |
| `ESPPreview:GetDockedSize()` | Returns docked size. |
| `ESPPreview:GetElementPosition(name)` | Returns element position. |
| `ESPPreview:GetFeature(name)` | Returns feature. |
| `ESPPreview:GetSeamless()` | Returns seamless. |
| `ESPPreview:GetWidgetOrder()` | Returns widget order. |
| `ESPPreview:GetWidgetTools()` | Returns widget tools. |
| `ESPPreview:ResetLayout()` | Restores the default ESP widget layout. |
| `ESPPreview:SetAnimateHealth(v)` | Sets animate health. |
| `ESPPreview:SetBoxThickness(v)` | Sets box thickness. |
| `ESPPreview:SetColor(name,v)` | Sets color. |
| `ESPPreview:SetDockGap(v)` | Sets dock gap. |
| `ESPPreview:SetDockMode(v)` | Sets dock mode. |
| `ESPPreview:SetDockWidthRatio(v)` | Sets dock width ratio. |
| `ESPPreview:SetDocked(v)` | Docks or undocks the ESP preview. |
| `ESPPreview:SetEditable(v)` | Enables/disables ESP widget editing. |
| `ESPPreview:SetElementDragPadding(v)` | Sets element drag padding. |
| `ESPPreview:SetElementPosition(name,slot)` | Sets an ESP widget to one of the supported slots. |
| `ESPPreview:SetFeature(name,v)` | Sets feature. |
| `ESPPreview:SetHealth(v)` | Sets health. |
| `ESPPreview:SetHealthStyle(v)` | Sets health style. |
| `ESPPreview:SetSeamless(v)` | Sets seamless. |
| `ESPPreview:SetText(name,value)` | Sets text. |
| `ESPPreview:SetWidgetOrder(t)` | Sets widget order. |
| `ESPPreview:SetWidgetTools(v)` | Sets widget tools. |
| `ESPPreview:ShuffleWidgets()` | Randomizes ESP widget positions. |
| `ESPPreview:UnbindColor(name)` | Unbind color. |
| `ESPPreview:UnbindFeature(name)` | Unbind feature. |

### Notification

| Method | Purpose |
|---|---|
| `Notification:Dismiss()` | Dismiss. |
| `Notification:SetDuration(v)` | Sets duration. |
| `Notification:SetMaxLines(v)` | Sets max lines. |
| `Notification:SetPosition(v)` | Sets position. |
| `Notification:SetText(v)` | Sets text. |
| `Notification:SetTitle(v)` | Sets title. |
| `Notification:SetWidth(v)` | Sets width. |
| `Notification:SetWrap(v)` | Sets wrap. |

Also supports `:On(eventName, callback)`, `:Off(eventName, callback)`, `:Emit(eventName, ...)`, and `:ClearEvents(eventName?)`.

### SettingsPage

| Method | Purpose |
|---|---|
| `SettingsPage:CaptureDefaults()` | Capture defaults. |
| `SettingsPage:GetConfigPath()` | Returns config path. |
| `SettingsPage:ListConfigs()` | List configs. |
| `SettingsPage:ListLogoPictures()` | List logo pictures. |
| `SettingsPage:ListProfilePictures()` | List profile pictures. |
| `SettingsPage:LoadConfig()` | Loads an in-memory config table. |
| `SettingsPage:RefreshBrowsers()` | Refreshes browsers. |
| `SettingsPage:ResetConfig()` | Reset config. |
| `SettingsPage:SaveConfig()` | Save config. |
| `SettingsPage:SetConfigPath(p)` | Sets config path. |
| `SettingsPage:ShowConfigPath()` | Show config path. |

### Important aliases

- `Fawn.Window`, `Fawn.NewWindow`, `Fawn.new` → Window constructor
- `Fawn.Panel`, `Fawn.NewPanel` → Panel constructor
- `Section:AddToggle` / `Checkbox` → `Section:Toggle`
- `Section:AddDropdown` / `Combo` → `Section:Dropdown`
- `Section:AddMultiSelect` / `MultiDropdown` → `Section:MultiSelect`
- `Section:AddInput` / `Textbox` / `TextInput` → `Section:Input`
- `Section:AddColorPicker` / `Color` → `Section:ColorPicker`
- `Section:AddKeybind` / `Hotkey` → `Section:Keybind`
- `Window:AddToggle`, `AddSlider`, `AddDropdown`, `AddMultiSelect`, `AddInput`, `AddColorPicker`, `AddKeybind`, `AddButton`, `AddButtonPair`, `AddLabel`, `AddSeparator`, `AddSpacer`, `AddValue` use the active tab’s implicit section.
- `Fawn.Watermark`, `Fawn.KeybindList`, `Fawn.InfoPanel`, `Fawn.ESPPreview`, `Fawn.StatusBar` map to the corresponding factory methods.

## 25. Included files

- `Fawn Modern.Lua` — fully updated optimized library.
- `Fawn Modern - FULL DEMO.lua` — complete GitHub-loading showcase of the library.
- `Fawn Modern - FULL DOCUMENTATION.md` — this documentation.

The demo is the best live reference for exact control composition, dynamic mutation, overlay setup, schema factories, ESP widget editing, settings integration, and the performance controls working together.
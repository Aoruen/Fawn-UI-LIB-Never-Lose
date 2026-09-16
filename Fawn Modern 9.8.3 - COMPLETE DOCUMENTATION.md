# Fawn Modern 9.8.3 — Complete Documentation

**Runtime:** Serotonin Lua  
**Version:** `9.8.3-serotonin`  
**API revision:** `39`  
**Build:** `fawnui-serotonin-9.8.3-preset-settings-managed-storage-20260916`

## 9.8.3 finishing guarantees

Fawn automatically creates the managed storage tree on load:

```text
Fawn Modern/
├─ configs/
├─ Profile Pictures/
└─ logo pictures/
```

These paths are intentionally relative to Serotonin's sandboxed `files` root. Use `Fawn:GetStoragePaths()`, `Fawn:GetStorageDisplayPaths()`, `Fawn:ListStorage(kind)`, and `Fawn:ResolveStoragePath(kind,name)` instead of hard-coding absolute paths. The built-in Settings page exposes dropdown browsers for configs, profile pictures, and logo pictures.

The preset Settings system can be mounted into any Window/Panel creation. It is hidden from the sidebar by default and can exist only in the profile popup:

```lua
local W=Fawn.Window({
    title="Example",
    presetSettings={
        profileMenuOnly=true,
        configPath="example.lua"
    }
})
```

Equivalent explicit form:

```lua
local Settings=W:AddPresetSettingsMenu({
    showInSidebar=false,
    profileMenuOnly=true,
    configPath="example.lua"
})
```

You can later open or retrieve it with `W:OpenPresetSettings()` and `W:GetPresetSettingsMenu()`. `W:AttachSettingsToProfile({only=true})` makes Settings the only profile-popup row.

Profile popup contents are fully authored with `SetProfileMenu`, `AddProfileMenuBuiltin`, `AddProfileMenuItem`, `AddProfileMenuSeparator`, `RemoveProfileMenuItem`, and `ClearProfileMenuItems`. Built-ins include `settings`, `profile`, `build`, `center`, `reset`, `resetstyle`, `close`, and `destroy`.

Appearance Settings keep surface/material controls inside the APPEARANCE section and expose color pickers for accent, main background, cards, controls, hover, active item, text, muted text, navigation text, popups, avatar, danger, success, warning, outline, and glass tint.

Renderer cleanup in this build keeps clipped/scrolled Section slices rounded, prevents translucent scrollbar gutter overdraw, gives ESP elements pointer ownership while dragging, uses an inset notification accent, and applies shared secondary-frame padding/radius rules to popups and overlays.

---


**Canonical GitHub file:** `Fawn Modern.Lua`  
**Version in this package:** `9.8.1-serotonin`  
**API revision:** `37`  
**Build:** `fawnui-serotonin-9.8.1-pixel-polish-glass-wrap-20260916`  
**Font:** Verdana  
**Target runtime:** Serotonin Lua  
**SHA-256 of included `Fawn Modern.lua`:** `1bdfc77ba07c5d48da4c2b684d28f09042b51364b5b5821d4779fb7b4e7bf44a`

This document describes the standalone Fawn 9.8 library included with this package. `Fawn Modern` is the visual nickname; the product/API remains Fawn Neverlose UI.

## 1. GitHub loading

The full demo in this package loads the library from:

```text
https://raw.githubusercontent.com/Aoruen/Fawn-UI-LIB-Never-Lose/refs/heads/main/Fawn%20Modern.Lua
```

A compact asynchronous Serotonin loader is:

```lua
local URL="https://raw.githubusercontent.com/Aoruen/Fawn-UI-LIB-Never-Lose/refs/heads/main/Fawn%20Modern.Lua"
http.Get(URL,{["Accept"]="text/plain,*/*"},function(source)
    local chunk,err=loadstring(source)
    assert(chunk,err)
    local Fawn=chunk()
    Fawn:AssertCompatible(37)
    -- build UI here
end)
```

The included full demo uses a dispatcher-safe version: the HTTP callback only compiles the library and queues UI creation for `onUpdate`.

## 2. Important rules

- Fawn dropdowns are **one-based**. In `{"A","B","C"}`, index `1` is `A`.
- Colors are RGBA arrays such as `{63,126,247,255}`.
- Input control values are strings. Use `GetNumber()` for numeric conversion.
- Use colon syntax: `Window:AddTab(...)`, `Section:AddToggle(...)`, `Control:Set(...)`.
- Destroyed objects are terminal; create a new object instead of reviving a destroyed one.
- UI scale is independent from physical window resize.
- AUTO Sections grow to content; FIXED/FILL Sections can own internal scrolling.
- Dropdown, accessory, color, config, group, account and search popups own pointer input while open.
- Only load one Fawn build in one Serotonin session because the library registers input/render callbacks.

## 3. 9.8 pixel-polish renderer

The 9.8.1 finishing pass keeps the UI as one outer shell instead of stacking another rounded sidebar surface over the root. This matters most with Liquid Glass: the profile/footer no longer paints an opaque cleanup rectangle, so the bottom-left area uses the same glass layer as the rest of the shell.

The sidebar separator and profile divider are single-pass lines with consistent outline blending. The connected profile divider visually meets the sidebar separator without drawing two different-opacity lines on top of one another. Card/popup glass highlights are inset from the border so they do not contaminate the actual outline.

The brand subtitle in the upper-left header now uses measured two-line wrapping inside the sidebar width instead of drawing an unbounded single line. Long titles still use measured fitting.

### 9.8 surface controls

```lua
Window:SetLiquidGlass(true)
Window:SetGlassOpacity(.72)
Window:SetSurfaceStyle("Frosted") -- Solid, Frosted, Acrylic, Smoke, Clear
Window:SetGlassTint({90,120,255,255},.05)
Window:SetGlassTintStrength(.05)
Window:SetSurfaceHighlights(true)
Window:SetSurfaceOpacity("card",220)
Window:ClearSurfaceOpacity("card")
Window:SetSurfaceTint("popup",{145,95,255,255},.12)
Window:ClearSurfaceTint("popup")
```

Surface roles are `main`, `sidebar`, `card`, `control`, `popup`, and `overlay`. The default sidebar is intentionally not repainted over the root glass; an explicit sidebar opacity override adds a subtle sidebar wash.

### Corners and outlines

```lua
Window:SetCornerPreset("Round") -- Square, Tight, Soft, Round
Window:SetRadiusScale(1.0)
Window:SetOutlineColor({55,58,68,255})
Window:SetOutlineStrength(1.0)
Window:SetOutlineOpacity(1.0)
Window:SetProfileDivider("Connected") -- Connected / Inset
```

### Motion

```lua
Window:SetAnimations(true)
Window:SetMotionStyle("Smooth") -- Off, Minimal, Smooth, Snappy, Fluid
Window:SetAnimationSpeed(10)
Window:SetHoverAnimations(true)
Window:SetSwitchAnimations(true)
```

## 4. Creating a Window

```lua
local W=Fawn.Window({
    title="FAWN",
    subtitle="SEROTONIN · COMPLETE LIBRARY DEMO · GITHUB BUILD",
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
    user="User",
    userSub="Fawn Modern",
    groups={"Global","Pistols","Rifles","Snipers"},
    group="Global",
    smoothScroll=true,
    scrollSpeed=12,
    liquidGlass=true,
    glassOpacity=.72,
    surfaceStyle="Frosted",
    animations=true,
    animationSpeed=10,
    draggable=true,
    resizable=true
})
```

`Fawn.Panel(options)` creates a tabless Window surface. `Fawn.NewWindow`, `Fawn.NewPanel`, and `Fawn.new` are compatibility constructors.

## 5. Tabs and Sections

```lua
local T=W:AddTab("Combat",{group="MAIN",icon="crosshair",selected=true})
local S=T:AddSection("AIMBOT",{column=1,row=1,span=1,sizeMode="auto"})
```

Section layout options include `column`, `row`, `span`, `columns`, `controlGap`, `sizeMode`, `height`, `minHeight`, `maxHeight`, `scrollStep`, and `columnDividers`.

Size modes:
- `auto`: height follows visible content.
- `fixed`: fixed height with internal overflow/scrolling.
- `fill`: expands to the row height and owns internal overflow.

## 6. Controls

### Toggle

```lua
local C=S:AddToggle("Enabled",true,{
    flag="enabled",
    keybind={key="Q",label="Q",mode="Toggle",keybindList=true},
    colorPicker={value={63,126,247,255},flag="accent"}
})
```

### Slider

```lua
local C=S:AddSlider("Speed",0,100,50,{step=1,clamp=true,format=function(v)return math.floor(v).."%"end})
```

`float=true` allows floating values. Slider min/max are the visual drag range unless clamp is enabled.

### Dropdown

```lua
local C=S:AddDropdown("Mode",{"A","B","C"},1)
```

Dropdown values are one-based.

### MultiSelect

```lua
local C=S:AddMultiSelect("Hitboxes",{"Head","Chest","Arms"},{"Head","Chest"},{summaryMode="auto",summaryItems=2,noneText="None"})
```

### Input

```lua
local C=S:AddInput("Name","Fawn",{placeholder="Type...",maxLength=64})
local N=S:AddInput("Number","42.5",{numeric=true,allowFloat=true,allowNegative=true})
local P=S:AddInput("Password","secret",{password=true})
```

### Other controls

```lua
S:AddColorPicker("Color",{255,120,180,255})
S:AddKeybind("Bind","V",{mode="Hold",keybindList=true})
S:AddButton("Run",function() end)
S:AddButtonPair("Left",function() end,"Right",function() end)
S:AddLabel("Text",{wrap=true,maxLines=4,lineHeight=18})
S:AddSeparator("GROUP")
S:AddSpacer(10)
S:AddValue("FPS",function()return 144 end,{accent=true})
```

## 7. Accessories / three-dot popup

Any Control can own a compact accessory Section:

```lua
local C=S:AddToggle("Advanced",true)
C:Extra(function(E)
    E:AddToggle("Child Toggle",true)
    E:AddSlider("Child Slider",0,100,50)
    E:AddDropdown("Child Dropdown",{"A","B"},1)
    E:AddInput("Child Input","text")
    E:AddColorPicker("Child Color",{255,255,255,255})
    E:AddKeybind("Child Bind","H")
    E:AddButton("Child Button",function() end)
    E:AddLabel("Child Label")
end)
```

Direct helpers also exist: `AddAccessoryToggle`, `AddAccessorySlider`, `AddAccessoryDropdown`, `AddAccessoryMultiSelect`, `AddAccessoryInput`, `AddAccessoryColorPicker`, `AddAccessoryKeybind`, `AddAccessoryButton`, and `AddAccessoryLabel`.

## 8. Dynamic option APIs

Dropdowns and MultiSelects can be changed at runtime. Important methods include `SetOptions`, `AddOption`, `SetOption`, `RemoveOption`, `MoveOption`, `ClearOptions`, `SetOptionsSource`, `RefreshOptionsSource`, `SetMaxVisibleOptions`, `SetDropdownScroll`, and `ScrollOptionsTo`.

MultiSelect adds `GetSelected`, `GetSelectedIndices`, `GetSelectedCount`, `IsSelected`, `SetSelected`, `ToggleOption`, `SelectAll`, `ClearSelection`, and summary controls.

## 9. Visibility and control metadata

```lua
Child:ShowWhen(Master,true)
Child:HideWhen(Master,true)
Child:SetTooltip("Tooltip metadata")
Child:SetDescription("Longer description")
Child:SetNoConfig(true)
```

Controls can be moved/reordered and mutated after creation. Runtime APIs are demonstrated in the included full demo.

## 10. Themes

Built-in themes:

`Modern Blue`, `Midnight`, `Graphite`, `Amethyst`, `Rose`, `Sakura`, `Emerald`, `Teal`, `Amber`, `Crimson`, `Arctic`, `Monochrome`, `Fawn Gold`.

```lua
W:SetTheme("Amethyst")
W:SetThemeColor("accent",{165,100,255,255},true)
Fawn:AddPreset("Custom",{accent={120,90,255,255},outline={70,55,90,255}})
W:SetTheme("Custom")
```

## 11. Overlays

### Watermark / StatusBar

```lua
local Mark=W:Watermark({
    x=25,y=25,autoSize=true,draggable=true,
    segments={{brand=true},{text="RAGE"},{text=function()return "144 FPS"end,reserve="9999 FPS"}}
})
```

Watermark segments can be inserted, removed, moved, replaced, and sourced dynamically.

### KeybindList

```lua
local Keys=W:KeybindList({title="KEYBINDS",x=25,y=115,onlyActive=false})
Keys:Track(SomeKeybind,"Aim Assist")
```

### InfoPanel

```lua
local Info=W:InfoPanel({title="INFO",x=25,y=300})
Info:AddRow("Build",function()return Fawn.BuildId end)
```

All overlays inherit base Overlay APIs for visibility, position, dragging, theme, layer, padding, sizing, and Window binding.

## 12. ESP Preview / Editor

```lua
local ESP=W:ESPPreview({
    tab=T,docked=true,editable=true,seamless=true,
    widgetTools=true,dockMode="auto",dockWidthRatio=.36,dockGap=18
})
ESP:SetFeature("boxes",true)
ESP:SetColor("box",{235,235,238,255})
ESP:SetHealthStyle("both")
ESP:SetBoxThickness(2)
ESP:SetAnimateHealth(true)
ESP:SetWidgetTools(true)
ESP:ShuffleWidgets()
```

Feature and color bindings can point directly at Fawn Controls with `BindFeature` and `BindColor`.

## 13. Notifications

```lua
local N=W:Notify("Saved",{title="CONFIG",duration=4,width=340,maxLines=4,wrap=true})
N:SetText("Updated")
N:SetPosition("Bottom Right")
```

Global notifications are also available with `Fawn:Notify(...)`.

## 14. Profile, brand, groups, and account menu

```lua
W:SetBranding({title="FAWN",subtitle="SEROTONIN",logo="F",user="User",userSub="Fawn Modern"})
W:SetProfileName("User")
W:SetProfileSubtitle("Fawn Modern")
W:SetProfileImage("avatar.png")
W:SetLogoImage("logo.png")
W:AddProfileMenuItem("Open Settings",function() end,{icon="settings"})
W:SetGroups({"Global","Pistols","Rifles"})
W:SetGroup("Global")
```

Long header subtitles are automatically wrapped to two measured lines in 9.8.1.

## 15. Config, named profiles, snapshots

```lua
local cfg=W:GetConfig()
W:LoadConfig(cfg)
W:SaveNamedConfig("Default")
W:LoadNamedConfig("Default")
W:DuplicateNamedConfig("Default")
W:DeleteNamedConfig("Default")
local state=W:SnapshotState()
W:RestoreState(state)
```

9.8 material/motion settings are stored in the `polish` config block.

## 16. Schema and dynamic object creation

```lua
local W2=Fawn:CreateFromSchema({
    title="SCHEMA",
    tabs={{name="Main",sections={{name="GENERAL",controls={{type="toggle",label="Enabled",value=true}}}}}}
})
```

The hierarchy supports runtime create/remove/move/rebuild operations for Tabs, Sections, Controls, and dropdown options. Use `ExportSchema`, `ApplySchema`, `CloneSchema`, and `ValidateTree` for schema workflows.

## 17. Built-in Settings page

```lua
local Settings=Fawn:CreateSettingsPage(W,{
    title="Settings",
    group="MISCELLANEOUS",
    configPath="FawnNeverlose/config.lua"
})
```

The Settings page covers Appearance, Behavior, profile/branding, config management, diagnostics, 9.8 surface materials, glass tint, corner presets, outline opacity, profile-divider style, and motion settings.

## 18. Public API index

### Fawn (44 public methods)

- `CreateWindow`
- `CreatePanel`
- `Window`
- `Panel`
- `Notify`
- `SetNotificationPosition`
- `GetNotificationPosition`
- `CreateWatermark`
- `CreateKeybindList`
- `CreateInfoPanel`
- `CreateESPPreview`
- `CreateStatusBar`
- `CreateSettingsPage`
- `SettingsPage`
- `AddPreset`
- `GetPreset`
- `SetTheme`
- `GetTheme`
- `GetWindows`
- `GetOverlays`
- `DestroyAll`
- `GetInputState`
- `GetColorClipboard`
- `SetColorClipboard`
- `GetPaintCount`
- `GetPaintErrors`
- `GetDrawErrors`
- `MeasureText`
- `WrapText`
- `GetKind`
- `Is`
- `GetDynamicCapabilities`
- `AssertCompatible`
- `GetRules`
- `GetPadding`
- `GetReferenceMetrics`
- `ValidateReferenceMetrics`
- `CreateFromSchema`
- `CreatePanelFromSchema`
- `ValidateObjectTree`
- `GetStats`
- `Validate`
- `Tab`
- `Section`

### Window (158 public methods)

- `SetVisible`
- `Toggle`
- `SetToggleKey`
- `BindToggleKey`
- `SetPosition`
- `GetPosition`
- `SetSize`
- `GetSize`
- `SetScale`
- `GetScale`
- `Center`
- `SetColumns`
- `GetColumns`
- `SetTabBarVisible`
- `IsTabBarVisible`
- `SetMainScrollEnabled`
- `GetMainScrollEnabled`
- `SetScrollSpeed`
- `GetScrollSpeed`
- `SetSmoothScroll`
- `SetAnimations`
- `SetAnimationSpeed`
- `SetAccentGlow`
- `SetCompact`
- `SetLayoutMode`
- `SetBackgroundBlur`
- `SetBackgroundSnow`
- `SetFont`
- `SetCornerRadius`
- `SetBorderThickness`
- `SetLiquidGlass`
- `GetLiquidGlass`
- `SetGlassOpacity`
- `GetGlassOpacity`
- `SetOutlineColor`
- `GetOutlineColor`
- `SetOutlineStrength`
- `GetOutlineStrength`
- `GetStyle`
- `SetStyle`
- `SetTheme`
- `SetThemeColor`
- `GetTheme`
- `SetIndependentTheme`
- `GetIndependentTheme`
- `GetThemeName`
- `GetPixelMetrics`
- `GetBodyBounds`
- `GetLayoutSnapshot`
- `GetKeybindPickerWidth`
- `SetProfileName`
- `SetProfileSubtitle`
- `SetProfileImage`
- `ClearProfileImage`
- `SetProfileClick`
- `SetLogoImage`
- `ClearLogoImage`
- `SetBranding`
- `SetGroups`
- `SetGroup`
- `GetGroup`
- `SetGroupClick`
- `Tab`
- `SelectTab`
- `OnTabChanged`
- `GetTabs`
- `GetTab`
- `GetTabCount`
- `RemoveTab`
- `ClearTabs`
- `MoveTab`
- `InsertTab`
- `AddSection`
- `GetControl`
- `GetValue`
- `SetValue`
- `ForEachControl`
- `GetConfig`
- `LoadConfig`
- `SaveNamedConfig`
- `LoadNamedConfig`
- `GetNamedConfigs`
- `DuplicateNamedConfig`
- `DeleteNamedConfig`
- `Destroy`
- `Notify`
- `SetNotificationPosition`
- `GetNotificationPosition`
- `Watermark`
- `KeybindList`
- `InfoPanel`
- `ESPPreview`
- `StatusBar`
- `AddSettingsPage`
- `GetMetrics`
- `ResetReferenceMetrics`
- `SetMinimumSize`
- `GetMinimumSize`
- `SetMaximumSize`
- `GetMaximumSize`
- `SetResizable`
- `GetResizable`
- `SetDraggable`
- `GetDraggable`
- `SetTitle`
- `GetTitle`
- `SetSubtitle`
- `GetSubtitle`
- `SetLogoText`
- `GetLogoText`
- `GetProfile`
- `SetProfile`
- `AddProfileMenuItem`
- `RemoveProfileMenuItem`
- `ClearProfileMenuItems`
- `GetProfileMenuItems`
- `AddGroup`
- `RemoveGroup`
- `MoveGroup`
- `GetGroups`
- `ClearGroups`
- `GetTabsInGroup`
- `GetTabGroups`
- `FindTab`
- `ForEachTab`
- `ForEachSection`
- `FindSection`
- `FindControl`
- `CreateTab`
- `CreateTabs`
- `RebuildTabs`
- `ExportSchema`
- `ApplySchema`
- `SnapshotState`
- `RestoreState`
- `CloneSchema`
- `ValidateTree`
- `SetSurfaceStyle`
- `GetSurfaceStyle`
- `SetSurfaceOpacity`
- `ClearSurfaceOpacity`
- `SetSurfaceTint`
- `ClearSurfaceTint`
- `SetGlassTint`
- `GetGlassTint`
- `SetGlassTintStrength`
- `ClearGlassTint`
- `SetSurfaceHighlights`
- `SetSidebarStitch`
- `SetProfileDivider`
- `SetRadiusScale`
- `SetCornerPreset`
- `SetOutlineOpacity`
- `SetMotionStyle`
- `GetMotionStyle`
- `SetHoverAnimations`
- `SetSwitchAnimations`
- `ResetPolish`

### Tab (37 public methods)

- `Section`
- `SetVisible`
- `Select`
- `OnSelected`
- `SetScrollStep`
- `GetScrollStep`
- `ScrollTo`
- `ScrollBy`
- `ScrollTop`
- `ScrollBottom`
- `GetScroll`
- `GetMaxScroll`
- `SetMainScrollEnabled`
- `GetMainScrollEnabled`
- `GetSections`
- `GetSection`
- `GetSectionCount`
- `RemoveSection`
- `ClearSections`
- `MoveSection`
- `InsertSection`
- `SetOrder`
- `Destroy`
- `SetName`
- `GetName`
- `SetIcon`
- `GetIcon`
- `SetGroup`
- `GetGroup`
- `MoveBefore`
- `MoveAfter`
- `GetWindow`
- `GetIndex`
- `CreateSection`
- `CreateSections`
- `RebuildSections`
- `ExportSchema`

### Section (63 public methods)

- `Toggle`
- `ToggleKeybind`
- `Slider`
- `Dropdown`
- `MultiSelect`
- `Input`
- `ColorPicker`
- `Keybind`
- `Button`
- `ButtonPair`
- `Label`
- `Separator`
- `Spacer`
- `Value`
- `SetColumn`
- `SetRow`
- `SetSpan`
- `SetFullWidth`
- `SetHeight`
- `GetHeight`
- `SetSizeMode`
- `GetSizeMode`
- `SetAutoSize`
- `SetFillHeight`
- `SetMinHeight`
- `GetMinHeight`
- `SetMaxHeight`
- `GetMaxHeight`
- `GetResolvedHeight`
- `SetColumns`
- `GetColumns`
- `SetControlGap`
- `SetVisible`
- `SetScrollStep`
- `GetScrollStep`
- `ScrollTo`
- `ScrollBy`
- `ScrollTop`
- `ScrollBottom`
- `GetControls`
- `GetControl`
- `GetControlCount`
- `RemoveControl`
- `ClearControls`
- `MoveControl`
- `MoveControlBefore`
- `MoveControlAfter`
- `SetOrder`
- `Destroy`
- `SetName`
- `GetName`
- `GetTab`
- `GetWindow`
- `GetIndex`
- `InsertControl`
- `FindControl`
- `ForEachControl`
- `CreateControl`
- `CreateControls`
- `RebuildControls`
- `ExportSchema`
- `SetColumnDividers`
- `GetColumnDividers`

### Control (117 public methods)

- `Get`
- `GetRaw`
- `GetIndex`
- `GetKey`
- `GetMode`
- `IsActive`
- `OnChanged`
- `SetVisible`
- `SetDisabled`
- `SetText`
- `SetFlag`
- `GetFlag`
- `SetClamp`
- `GetClamp`
- `SetRange`
- `GetRange`
- `Set`
- `SetMode`
- `SetKey`
- `ClearKey`
- `IsKeyCleared`
- `OnKeyChanged`
- `SetListVisible`
- `GetKeybind`
- `SetKeybind`
- `GetColorPicker`
- `SetColor`
- `SetWrap`
- `GetWrap`
- `SetMaxLines`
- `SetLineHeight`
- `GetPickerWidth`
- `SetColumn`
- `SetRow`
- `SetSpan`
- `SetOrder`
- `MoveBefore`
- `MoveAfter`
- `Destroy`
- `SetOptions`
- `GetOptions`
- `GetOptionCount`
- `FindOption`
- `HasOption`
- `AddOption`
- `SetOption`
- `RemoveOption`
- `ClearOptions`
- `MoveOption`
- `RefreshOptions`
- `SetOptionsSource`
- `ClearOptionsSource`
- `RefreshOptionsSource`
- `GetSelected`
- `GetSelectedIndices`
- `GetSelectedCount`
- `IsSelected`
- `SetSelected`
- `ToggleOption`
- `SelectAll`
- `ClearSelection`
- `GetSummary`
- `SetPlaceholder`
- `GetPlaceholder`
- `SetMaxLength`
- `GetMaxLength`
- `SetNumeric`
- `SetPassword`
- `IsPassword`
- `OnSubmit`
- `Submit`
- `Clear`
- `Append`
- `GetNumber`
- `IsFocused`
- `Focus`
- `Blur`
- `GetCursor`
- `SetCursor`
- `SetMaxVisibleOptions`
- `GetMaxVisibleOptions`
- `SetDropdownScrollStep`
- `GetDropdownScrollStep`
- `SetDropdownScroll`
- `GetDropdownScroll`
- `ScrollOptionsTo`
- `GetSection`
- `GetWindow`
- `GetControlIndex`
- `SetTooltip`
- `GetTooltip`
- `SetDescription`
- `GetDescription`
- `SetNoConfig`
- `GetNoConfig`
- `SetSummaryMode`
- `GetSummaryMode`
- `SetNoneText`
- `GetNoneText`
- `SetFormat`
- `GetFormat`
- `SetStep`
- `GetStep`
- `Extra`
- `GetExtraSection`
- `ClearExtra`
- `AddAccessoryToggle`
- `AddAccessorySlider`
- `AddAccessoryDropdown`
- `AddAccessoryMultiSelect`
- `AddAccessoryInput`
- `AddAccessoryColorPicker`
- `AddAccessoryKeybind`
- `AddAccessoryButton`
- `AddAccessoryLabel`
- `SetRowHover`
- `GetRowHover`

### Overlay (17 public methods)

- `SetVisible`
- `Toggle`
- `SetPosition`
- `GetPosition`
- `SetDraggable`
- `SetTheme`
- `BindWindow`
- `Destroy`
- `SetLayer`
- `SetIndependentTheme`
- `SetPadding`
- `GetPadding`
- `SetAutoSize`
- `GetAutoSize`
- `SetMinWidth`
- `SetMaxWidth`
- `GetSize`

### Watermark (17 public methods)

- `SetSegments`
- `AddSegment`
- `Clear`
- `SetText`
- `SetSegmentPadding`
- `SetAutoWidth`
- `InsertSegment`
- `GetSegment`
- `GetSegments`
- `GetSegmentCount`
- `SetSegment`
- `RemoveSegment`
- `MoveSegment`
- `ClearSegments`
- `SetSegmentsSource`
- `ClearSegmentsSource`
- `RefreshSegmentsSource`

### KeybindList (4 public methods)

- `Track`
- `Untrack`
- `Clear`
- `SetOnlyActive`

### InfoPanel (14 public methods)

- `AddRow`
- `SetRow`
- `Clear`
- `InsertRow`
- `GetRow`
- `GetRows`
- `GetRowCount`
- `FindRow`
- `RemoveRow`
- `MoveRow`
- `SetRows`
- `SetRowsSource`
- `ClearRowsSource`
- `RefreshRowsSource`

### ESPPreview (30 public methods)

- `SetFeature`
- `GetFeature`
- `SetColor`
- `GetColor`
- `SetElementPosition`
- `GetElementPosition`
- `SetEditable`
- `SetHealth`
- `SetAnimateHealth`
- `GetAnimateHealth`
- `SetText`
- `BindFeature`
- `BindColor`
- `UnbindFeature`
- `UnbindColor`
- `SetHealthStyle`
- `SetBoxThickness`
- `SetDocked`
- `ResetLayout`
- `SetDockWidthRatio`
- `SetDockGap`
- `GetDockedSize`
- `SetSeamless`
- `GetSeamless`
- `SetDockMode`
- `SetWidgetTools`
- `GetWidgetTools`
- `GetWidgetOrder`
- `SetWidgetOrder`
- `ShuffleWidgets`

### Notification (8 public methods)

- `Dismiss`
- `SetText`
- `SetTitle`
- `SetDuration`
- `SetPosition`
- `SetWidth`
- `SetMaxLines`
- `SetWrap`

### SettingsPage (7 public methods)

- `SetConfigPath`
- `GetConfigPath`
- `CaptureDefaults`
- `SaveConfig`
- `LoadConfig`
- `ResetConfig`
- `ShowConfigPath`

## 19. Compatibility aliases

Common aliases include:

- `Section:AddToggle` / `Section:Toggle` / `Section:Checkbox`
- `Section:AddDropdown` / `Section:Dropdown` / `Section:Combo`
- `Section:AddMultiSelect` / `Section:MultiSelect` / `Section:MultiDropdown`
- `Section:AddInput` / `Section:Input` / `Section:Textbox` / `Section:TextInput`
- `Window:AddTab` / `Window:Tab`
- `Window:AddSection` / `Window:Section`
- `Fawn.Window` / `Fawn.NewWindow` / `Fawn.new`
- `Fawn.Panel` / `Fawn.NewPanel`

Prefer the `Add...` names in application scripts because they are explicit and easy to read.

## 20. Validation / diagnostics

```lua
local ok,missing=Fawn:Validate()
local metricsOk,metricMissing=Fawn:ValidateReferenceMetrics()
local treeOk,treeErrors=W:ValidateTree()
local stats=Fawn:GetStats()
local caps=Fawn:GetDynamicCapabilities()
```

`Fawn:GetPaintErrors()` and `Fawn:GetDrawErrors()` expose renderer error counters. The full demo includes live diagnostics for these values.

## 21. Files in this package

- `Fawn Modern.lua` — canonical full 9.8.1 library to upload to the GitHub path used by the demo.
- `Fawn Modern 9.8 - FULL DEMO.lua` — complete GitHub-loading showcase.
- `Fawn Modern 9.8 - COMPLETE DOCUMENTATION.md` — this document.

After replacing the repository's `Fawn Modern.Lua` with the included library, the demo will load the updated pixel-polish build directly from GitHub.

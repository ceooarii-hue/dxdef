local REMOTE_BASE = "https://raw.githubusercontent.com/ceooarii-hue/dxdef/main/"

local function normalize_remote_path(path)
    return path
        :gsub(" ", "%%20")
        :gsub("%(", "%%28")
        :gsub("%)", "%%29")
end

local function run_module(paths)
    for _, path in ipairs(paths) do
        local ok, result = pcall(function()
            return game:HttpGet(REMOTE_BASE .. normalize_remote_path(path))
        end)

        if ok and result and result ~= "404: Not Found" then
            local chunk, err = loadstring(result)
            if not chunk then
                error("failed to compile remote script: " .. path .. " | " .. tostring(err))
            end
            return chunk()
        end
    end

    for _, path in ipairs(paths) do
        local ok, result = pcall(readfile, path)
        if ok and result then
            local chunk, err = loadstring(result)
            if not chunk then
                error("failed to compile local script: " .. path .. " | " .. tostring(err))
            end
            return chunk()
        end
    end

    error("failed to load script: " .. table.concat(paths, ", "))
end

local function load_windui()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end

local function notify(WindUI, content)
    WindUI:Notify({
        Title = "REMAP-H",
        Content = content,
        Duration = 4,
    })
end

local Players = cloneref(game:GetService("Players"))
local lp = Players.LocalPlayer

if getgenv().RemapHWindow and getgenv().RemapHWindow.Destroy then
    pcall(function()
        getgenv().RemapHWindow:Destroy()
    end)
end

run_module({
    "tps/modules/Bypass.lua",
    "modules/Bypass.lua",
})

local Chams, ReachFTI, ReachMethod2, ReachHRP, Reacts, GKReact
local BallSize, BallSkin, AirHelper, InfDribbleHelper, AvatarStolen

local function ensure_chams()
    Chams = Chams or run_module({ "tps/modules/Chams.lua", "modules/Chams.lua" })
    return Chams
end

local function ensure_reach_fti()
    ReachFTI = ReachFTI or run_module({ "tps/modules/Reach(FTI).lua", "modules/Reach(FTI).lua" })
    return ReachFTI
end

local function ensure_reach_method2()
    ReachMethod2 = ReachMethod2 or run_module({ "tps/modules/Reach Method 2.lua", "modules/Reach Method 2.lua" })
    return ReachMethod2
end

local function ensure_reach_method3()
    ReachHRP = ReachHRP or run_module({ "tps/modules/Reach Method 3.lua", "modules/Reach Method 3.lua" })
    return ReachHRP
end

local function ensure_reacts()
    Reacts = Reacts or run_module({ "tps/modules/Reacts.lua", "modules/Reacts.lua" })
    return Reacts
end

local function ensure_gk_react()
    GKReact = GKReact or run_module({ "tps/modules/GK React.lua", "modules/GK React.lua" })
    return GKReact
end

local function ensure_ball_size()
    BallSize = BallSize or run_module({ "tps/modules/Ball size.lua", "modules/Ball size.lua" })
    return BallSize
end

local function ensure_ball_skin()
    BallSkin = BallSkin or run_module({ "tps/modules/Ball skin changer.lua", "modules/Ball skin changer.lua" })
    return BallSkin
end

local function ensure_air_helper()
    AirHelper = AirHelper or run_module({ "tps/modules/AirHelper.lua", "modules/AirHelper.lua" })
    return AirHelper
end

local function ensure_inf_dribble_helper()
    InfDribbleHelper = InfDribbleHelper or run_module({ "tps/modules/Inf Dribble Helper.lua", "modules/Inf Dribble Helper.lua" })
    return InfDribbleHelper
end

local function ensure_avatar_stolen()
    AvatarStolen = AvatarStolen or run_module({ "tps/modules/Avatarstolen.lua", "modules/Avatarstolen.lua" })
    return AvatarStolen
end

local ok, result = pcall(function()
local WindUI = load_windui()
local uiState = getgenv().RemapHUIState or {
    activeTheme = "REMAP Night",
    customTheme = {
        accent = Color3.fromRGB(95, 135, 255),
        background = Color3.fromRGB(11, 14, 24),
        surface = Color3.fromRGB(21, 27, 44),
        text = Color3.fromRGB(240, 244, 255),
    },
}

getgenv().RemapHUIState = uiState

local function mix(a, b, alpha)
    return a:Lerp(b, alpha)
end

local function make_theme(name, palette)
    local accent = palette.accent
    local background = palette.background
    local surface = palette.surface
    local text = palette.text
    local icon = mix(text, accent, 0.3)
    local hover = mix(surface, text, 0.08)

    return {
        Name = name,
        Accent = accent,
        Background = background,
        WindowBackground = background,
        PanelBackground = surface,
        Hover = hover,
        Text = text,
        Icon = icon,
        Button = accent,
        Checkbox = accent,
        Slider = accent,
        Notification = surface,
        White = Color3.new(1, 1, 1),
        Black = Color3.new(0, 0, 0),
    }
end

local presetThemes = {
    ["REMAP Night"] = {
        accent = Color3.fromRGB(95, 135, 255),
        background = Color3.fromRGB(11, 14, 24),
        surface = Color3.fromRGB(21, 27, 44),
        text = Color3.fromRGB(240, 244, 255),
    },
    ["REMAP Ocean"] = {
        accent = Color3.fromRGB(30, 184, 255),
        background = Color3.fromRGB(7, 23, 31),
        surface = Color3.fromRGB(13, 42, 56),
        text = Color3.fromRGB(232, 249, 255),
    },
    ["REMAP Rose"] = {
        accent = Color3.fromRGB(255, 98, 146),
        background = Color3.fromRGB(28, 12, 20),
        surface = Color3.fromRGB(45, 20, 33),
        text = Color3.fromRGB(255, 239, 245),
    },
    ["REMAP Lime"] = {
        accent = Color3.fromRGB(153, 255, 102),
        background = Color3.fromRGB(14, 20, 11),
        surface = Color3.fromRGB(24, 33, 20),
        text = Color3.fromRGB(244, 255, 235),
    },
}

local function register_theme(name, palette)
    local themes = WindUI.GetThemes and WindUI:GetThemes() or WindUI.Themes
    if themes and themes[name] then
        for key, value in pairs(make_theme(name, palette)) do
            themes[name][key] = value
        end
    else
        WindUI:AddTheme(make_theme(name, palette))
    end
end

for name, palette in pairs(presetThemes) do
    register_theme(name, palette)
end

local function apply_custom_theme(setActive)
    register_theme("Custom", uiState.customTheme)
    if setActive then
        uiState.activeTheme = "Custom"
        WindUI:SetTheme("Custom")
    elseif uiState.activeTheme == "Custom" then
        WindUI:SetTheme("Custom")
    end
end

apply_custom_theme(false)

local window = WindUI:CreateWindow({
    Title = "REMAP-H | TPS",
    Folder = "REMAPH_TPS",
    Icon = "sparkles",
    HideSearchBar = true,
    OpenButton = {
        Title = "REMAP-H",
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
    },
})

window:SetToggleKey(Enum.KeyCode.K)

if not presetThemes[uiState.activeTheme] and uiState.activeTheme ~= "Custom" then
    uiState.activeTheme = "REMAP Night"
end

WindUI:SetTheme(uiState.activeTheme)

getgenv().RemapHWindow = window

notify(WindUI, "bypass active")
notify(WindUI, "Welcome back, " .. lp.Name .. "!")

local uiTab = window:Tab({
    Title = "UI",
    Icon = "palette",
})

uiTab:Section({
    Title = "Themes",
})

uiTab:Dropdown({
    Title = "Theme preset",
    Values = { "REMAP Night", "REMAP Ocean", "REMAP Rose", "REMAP Lime", "Custom" },
    Value = uiState.activeTheme,
    Callback = function(value)
        uiState.activeTheme = value
        if value == "Custom" then
            apply_custom_theme(true)
        else
            WindUI:SetTheme(value)
        end
    end,
})

uiTab:Space()

uiTab:Colorpicker({
    Title = "Custom accent",
    Default = uiState.customTheme.accent,
    Callback = function(color)
        uiState.customTheme.accent = color
        apply_custom_theme(uiState.activeTheme == "Custom")
    end,
})

uiTab:Colorpicker({
    Title = "Custom background",
    Default = uiState.customTheme.background,
    Callback = function(color)
        uiState.customTheme.background = color
        apply_custom_theme(uiState.activeTheme == "Custom")
    end,
})

uiTab:Colorpicker({
    Title = "Custom surface",
    Default = uiState.customTheme.surface,
    Callback = function(color)
        uiState.customTheme.surface = color
        apply_custom_theme(uiState.activeTheme == "Custom")
    end,
})

uiTab:Colorpicker({
    Title = "Custom text",
    Default = uiState.customTheme.text,
    Callback = function(color)
        uiState.customTheme.text = color
        apply_custom_theme(uiState.activeTheme == "Custom")
    end,
})

uiTab:Section({
    Title = "Usa un preset o cambia colores y luego elige Custom para aplicar tu theme.",
})

Chams = ensure_chams()

local chamsTab = window:Tab({
    Title = "Chams",
    Icon = "scan-eye",
})

chamsTab:Toggle({
    Title = "Player chams",
    Desc = "Resalta a los otros jugadores.",
    Value = Chams.enabled,
    Callback = function(state)
        Chams.setEnabled(state)
    end,
})

chamsTab:Space()

chamsTab:Dropdown({
    Title = "Style",
    Values = { "Highlight", "Outline", "Box", "Hybrid" },
    Value = Chams.style,
    Callback = function(value)
        Chams.setStyle(value)
    end,
})

chamsTab:Toggle({
    Title = "Through walls",
    Value = Chams.throughWalls,
    Callback = function(state)
        Chams.setThroughWalls(state)
    end,
})

chamsTab:Toggle({
    Title = "Include self",
    Value = Chams.includeSelf,
    Callback = function(state)
        Chams.setIncludeSelf(state)
    end,
})

chamsTab:Space()

chamsTab:Colorpicker({
    Title = "Fill color",
    Default = Chams.fillColor,
    Callback = function(color)
        Chams.fillColor = color
        Chams.refresh()
    end,
})

chamsTab:Colorpicker({
    Title = "Outline color",
    Default = Chams.outlineColor,
    Callback = function(color)
        Chams.outlineColor = color
        Chams.refresh()
    end,
})

chamsTab:Space()

chamsTab:Slider({
    Title = "Fill transparency",
    Step = 0.05,
    Value = {
        Min = 0,
        Max = 1,
        Default = Chams.fillTransparency,
    },
    Callback = function(value)
        Chams.fillTransparency = value
        Chams.refresh()
    end,
})

chamsTab:Slider({
    Title = "Outline transparency",
    Step = 0.05,
    Value = {
        Min = 0,
        Max = 1,
        Default = Chams.outlineTransparency,
    },
    Callback = function(value)
        Chams.outlineTransparency = value
        Chams.refresh()
    end,
})

local reachEnabled = false
local reachMethod2Enabled = false
local reachMethod3Enabled = false
ReachFTI = ensure_reach_fti()
ReachMethod2 = ensure_reach_method2()
ReachHRP = ensure_reach_method3()
local reachTab = window:Tab({
    Title = "Reach",
    Icon = "crosshair",
})

local reachMethod2X = ReachMethod2.size.X
local reachMethod2Z = ReachMethod2.size.Z
local reachMethod3X = ReachHRP.size.X
local reachMethod3Z = ReachHRP.size.Z
local reachVisualizer1 = ReachFTI.visualizerEnabled
local reachVisualizer2 = ReachMethod2.visualizerEnabled
local reachVisualizer3 = ReachHRP.visualizerEnabled

local function reload_reach_fti()
    ReachFTI.destroy()
    ReachFTI = run_module({
        "tps/modules/Reach(FTI).lua",
        "modules/Reach(FTI).lua",
    })
    ReachFTI.setVisualizerEnabled(reachVisualizer1)
end

local function reload_reach_method2()
    ReachMethod2.destroy()
    ReachMethod2 = run_module({
        "tps/modules/Reach Method 2.lua",
        "modules/Reach Method 2.lua",
    })
    reachMethod2X = ReachMethod2.size.X
    reachMethod2Z = ReachMethod2.size.Z
    ReachMethod2.setVisualizerEnabled(reachVisualizer2)
end

local function reload_reach_method3()
    ReachHRP.destroy()
    ReachHRP = run_module({
        "tps/modules/Reach Method 3.lua",
        "modules/Reach Method 3.lua",
    })
    reachMethod3X = ReachHRP.size.X
    reachMethod3Z = ReachHRP.size.Z
    ReachHRP.setVisualizerEnabled(reachVisualizer3)
end

local reachToggle
local reachMethod2Toggle
local reachMethod3Toggle

local function disable_other_reach(active)
    if active ~= 1 and reachEnabled then
        reachEnabled = false
        reload_reach_fti()
        if reachToggle and reachToggle.Set then pcall(function() reachToggle:Set(false) end) end
    end

    if active ~= 2 and reachMethod2Enabled then
        reachMethod2Enabled = false
        reload_reach_method2()
        if reachMethod2Toggle and reachMethod2Toggle.Set then pcall(function() reachMethod2Toggle:Set(false) end) end
    end

    if active ~= 3 and reachMethod3Enabled then
        reachMethod3Enabled = false
        reload_reach_method3()
        if reachMethod3Toggle and reachMethod3Toggle.Set then pcall(function() reachMethod3Toggle:Set(false) end) end
    end
end

reachToggle = reachTab:Toggle({
    Title = "Enable reach",
    Value = false,
    Callback = function(state)
        reachEnabled = state
        if state then
            disable_other_reach(1)
            ReachFTI.enable()
        else
            reload_reach_fti()
        end
    end,
})

reachTab:Space()

reachTab:Section({
    Title = "Only one reach method can be active at a time.",
})

reachTab:Space()

reachTab:Slider({
    Title = "Reach studs",
    Step = 1,
    Value = {
        Min = 1,
        Max = 10,
        Default = ReachFTI.studs or 10,
    },
    Callback = function(value)
        ReachFTI.setStuds(value)
        if reachEnabled then
            ReachFTI.enable()
        end
    end,
})

reachTab:Space()

reachTab:Toggle({
    Title = "Method 1 visualizer",
    Value = reachVisualizer1,
    Callback = function(state)
        reachVisualizer1 = state
        ReachFTI.setVisualizerEnabled(state)
    end,
})

reachTab:Space()

reachTab:Section({
    Title = "Reach Method 2",
})

reachMethod2Toggle = reachTab:Toggle({
    Title = "Enable reach method 2",
    Value = false,
    Callback = function(state)
        reachMethod2Enabled = state
        if state then
            disable_other_reach(2)
            ReachMethod2.enable()
            ReachMethod2.setSize(reachMethod2X, reachMethod2Z)
        else
            reload_reach_method2()
        end
    end,
})

reachTab:Slider({
    Title = "Method 2 Size X",
    Step = 1,
    Value = {
        Min = 2,
        Max = 10,
        Default = reachMethod2X,
    },
    Callback = function(value)
        reachMethod2X = value
        ReachMethod2.setSize(reachMethod2X, reachMethod2Z)
    end,
})

reachTab:Slider({
    Title = "Method 2 Size Z",
    Step = 1,
    Value = {
        Min = 2,
        Max = 10,
        Default = reachMethod2Z,
    },
    Callback = function(value)
        reachMethod2Z = value
        ReachMethod2.setSize(reachMethod2X, reachMethod2Z)
    end,
})

reachTab:Toggle({
    Title = "Method 2 visualizer",
    Value = reachVisualizer2,
    Callback = function(state)
        reachVisualizer2 = state
        ReachMethod2.setVisualizerEnabled(state)
    end,
})

reachTab:Space()

reachTab:Section({
    Title = "Method 2 usa el mismo estilo visual, pero aplicado a todo el cuerpo.",
})

reachTab:Space()

reachTab:Section({
    Title = "Reach Method 3",
})

reachMethod3Toggle = reachTab:Toggle({
    Title = "Enable reach method 3",
    Value = false,
    Callback = function(state)
        reachMethod3Enabled = state
        if state then
            disable_other_reach(3)
            ReachHRP.enable()
            ReachHRP.setSize(reachMethod3X, reachMethod3Z)
        else
            reload_reach_method3()
        end
    end,
})

reachTab:Slider({
    Title = "Method 3 Size X",
    Step = 1,
    Value = {
        Min = 2,
        Max = 10,
        Default = reachMethod3X,
    },
    Callback = function(value)
        reachMethod3X = value
        ReachHRP.setSize(reachMethod3X, reachMethod3Z)
    end,
})

reachTab:Slider({
    Title = "Method 3 Size Z",
    Step = 1,
    Value = {
        Min = 2,
        Max = 10,
        Default = reachMethod3Z,
    },
    Callback = function(value)
        reachMethod3Z = value
        ReachHRP.setSize(reachMethod3X, reachMethod3Z)
    end,
})

reachTab:Toggle({
    Title = "Method 3 visualizer",
    Value = reachVisualizer3,
    Callback = function(state)
        reachVisualizer3 = state
        ReachHRP.setVisualizerEnabled(state)
    end,
})

reachTab:Space()

reachTab:Section({
    Title = "Los tres methods ahora comparten el mismo look con distinto color por modo.",
})

local reactsEnabled = false
Reacts = ensure_reacts()
GKReact = ensure_gk_react()
local reactsTab = window:Tab({
    Title = "Reacts",
    Icon = "zap",
})

reactsTab:Section({
    Title = "Ball Reactions",
})

reactsTab:Button({
    Title = "Better React",
    Callback = function()
        local ok, message = Reacts.betterReact()
        notify(WindUI, message)
    end,
})

reactsTab:Space()

reactsTab:Section({
    Title = "GK React",
})

reactsTab:Toggle({
    Title = "Enable GK React",
    Value = GKReact.enabled,
    Callback = function(state)
        if state then
            GKReact.enable()
            notify(WindUI, "GK React enabled")
        else
            GKReact.disable()
            notify(WindUI, "GK React disabled")
        end
    end,
})

reactsTab:Dropdown({
    Title = "GK Part",
    Values = { "LLCL", "RLCL", "HumanoidRootPart" },
    Value = GKReact.preferredPart,
    Callback = function(value)
        GKReact.setPart(value)
    end,
})

reactsTab:Space()

reactsTab:Section({
    Title = "Cada react aplica velocidad durante varios frames para que pegue mejor.",
})

local ballTab = window:Tab({
    Title = "Ball",
    Icon = "circle-dot",
})

local ballSizeEnabled = false
BallSize = ensure_ball_size()
BallSkin = ensure_ball_skin()
local ballSizeX = 3
local ballSizeY = 3
local ballSizeZ = 3

local function apply_ball_size()
    BallSize.set(ballSizeX, ballSizeY, ballSizeZ)
end

ballTab:Toggle({
    Title = "Custom ball size",
    Value = false,
    Callback = function(state)
        ballSizeEnabled = state
        if state then
            apply_ball_size()
        else
            BallSize.reset()
        end
    end,
})

ballTab:Space()

ballTab:Slider({
    Title = "Size X",
    Step = 1,
    Value = {
        Min = 1,
        Max = 20,
        Default = ballSizeX,
    },
    Callback = function(value)
        ballSizeX = value
        if ballSizeEnabled then apply_ball_size() end
    end,
})

ballTab:Slider({
    Title = "Size Y",
    Step = 1,
    Value = {
        Min = 1,
        Max = 20,
        Default = ballSizeY,
    },
    Callback = function(value)
        ballSizeY = value
        if ballSizeEnabled then apply_ball_size() end
    end,
})

ballTab:Slider({
    Title = "Size Z",
    Step = 1,
    Value = {
        Min = 1,
        Max = 20,
        Default = ballSizeZ,
    },
    Callback = function(value)
        ballSizeZ = value
        if ballSizeEnabled then apply_ball_size() end
    end,
})

ballTab:Space()

ballTab:Dropdown({
    Title = "Ball skin",
    Values = { "none", "maxwell", "foxy", "reimu" },
    Value = "none",
    Callback = function(value)
        if value == "none" then
            BallSkin.reset()
        else
            BallSkin.set(value)
        end
    end,
})

local airSize = 20
AirHelper = ensure_air_helper()

local helpersTab = window:Tab({
    Title = "Helpers",
    Icon = "wand-sparkles",
})

InfDribbleHelper = ensure_inf_dribble_helper()

helpersTab:Section({
    Title = "Air Helper",
})

helpersTab:Toggle({
    Title = "Air helper",
    Value = false,
    Callback = function(state)
        if state then
            AirHelper.enable()
            AirHelper.setSize(airSize)
        else
            AirHelper = run_module({
                "tps/modules/AirHelper.lua",
                "modules/AirHelper.lua",
            })
        end
    end,
})

helpersTab:Space()

helpersTab:Slider({
    Title = "Air helper size",
    Step = 1,
    Value = {
        Min = 5,
        Max = 50,
        Default = airSize,
    },
    Callback = function(value)
        airSize = value
        AirHelper.setSize(value)
    end,
})

helpersTab:Space()

helpersTab:Section({
    Title = "Inf Dribble Helper",
})

helpersTab:Toggle({
    Title = "Enable Inf Dribble Helper [PC]",
    Desc = "Toggle follow with B.",
    Value = false,
    Callback = function(state)
        if state then
            InfDribbleHelper.enable()
            notify(WindUI, "Inf Dribble Helper enabled")
        else
            InfDribbleHelper.disable()
            notify(WindUI, "Inf Dribble Helper disabled")
        end
    end,
})

helpersTab:Slider({
    Title = "Stop Distance",
    Step = 0.25,
    Value = {
        Min = 1,
        Max = 6,
        Default = InfDribbleHelper.stopDistance,
    },
    Callback = function(value)
        InfDribbleHelper.setStopDistance(value)
    end,
})

helpersTab:Section({
    Title = "Press B to start or stop following the ball with smoother tracking.",
})

local avatarTab = window:Tab({
    Title = "Avatar",
    Icon = "contact-round",
})

AvatarStolen = ensure_avatar_stolen()

local avatarName = ""

avatarTab:Input({
    Title = "Username",
    Placeholder = "Player name",
    Callback = function(value)
        avatarName = value
    end,
})

avatarTab:Space()

avatarTab:Button({
    Title = "Steal avatar",
    Callback = function()
        if avatarName ~= "" then
            AvatarStolen.steal(avatarName)
            notify(WindUI, "avatar applied: " .. avatarName)
        end
    end,
})

avatarTab:Button({
    Title = "Stop avatar steal",
    Callback = function()
        AvatarStolen.destroy()
        AvatarStolen = run_module({
            "tps/modules/Avatarstolen.lua",
            "modules/Avatarstolen.lua",
        })
    end,
})
end)

if not ok then
    warn("REMAP-H UI failed:", result)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "REMAP-H",
            Text = tostring(result),
            Duration = 8,
        })
    end)
end

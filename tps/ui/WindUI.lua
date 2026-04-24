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
local window = WindUI:CreateWindow({
    Title = "REMAP-H | TPS",
    Folder = "REMAPH_TPS",
    Icon = "eye",
    HideSearchBar = true,
    OpenButton = {
        Title = "REMAP-H",
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
    },
})

window:SetToggleKey(Enum.KeyCode.K)

getgenv().RemapHWindow = window

notify(WindUI, "bypass active")
notify(WindUI, "Welcome back, " .. lp.Name .. "!")

Chams = ensure_chams()

local chamsTab = window:Tab({
    Title = "Chams",
    Icon = "eye",
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
    Icon = "accessibility",
})

local reachMethod2X = ReachMethod2.size.X
local reachMethod2Z = ReachMethod2.size.Z
local reachMethod3X = ReachHRP.size.X
local reachMethod3Z = ReachHRP.size.Z

local function reload_reach_fti()
    ReachFTI.destroy()
    ReachFTI = run_module({
        "tps/modules/Reach(FTI).lua",
        "modules/Reach(FTI).lua",
    })
end

local function reload_reach_method2()
    ReachMethod2.destroy()
    ReachMethod2 = run_module({
        "tps/modules/Reach Method 2.lua",
        "modules/Reach Method 2.lua",
    })
    reachMethod2X = ReachMethod2.size.X
    reachMethod2Z = ReachMethod2.size.Z
end

local function reload_reach_method3()
    ReachHRP.destroy()
    ReachHRP = run_module({
        "tps/modules/Reach Method 3.lua",
        "modules/Reach Method 3.lua",
    })
    reachMethod3X = ReachHRP.size.X
    reachMethod3Z = ReachHRP.size.Z
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
        Max = 30,
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
        Max = 40,
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
        Max = 40,
        Default = reachMethod2Z,
    },
    Callback = function(value)
        reachMethod2Z = value
        ReachMethod2.setSize(reachMethod2X, reachMethod2Z)
    end,
})

reachTab:Space()

reachTab:Section({
    Title = "Method 2 is full body reach with blue visualizers.",
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
        Max = 40,
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
        Max = 40,
        Default = reachMethod3Z,
    },
    Callback = function(value)
        reachMethod3Z = value
        ReachHRP.setSize(reachMethod3X, reachMethod3Z)
    end,
})

reachTab:Space()

reachTab:Section({
    Title = "Method 1 visualizer is red. Method 3 visualizer is green.",
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

reactsTab:Button({
    Title = "Alz React",
    Callback = function()
        local ok, message = Reacts.alzReact()
        notify(WindUI, message)
    end,
})

reactsTab:Button({
    Title = "Foxtede React",
    Callback = function()
        local ok, message = Reacts.foxtedeReact()
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
    Icon = "circle",
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
local miscTab = window:Tab({
    Title = "Misc",
    Icon = "layers-2",
})

local helpersTab = window:Tab({
    Title = "Helpers",
    Icon = "wrench",
})

InfDribbleHelper = ensure_inf_dribble_helper()

miscTab:Toggle({
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

miscTab:Space()

miscTab:Slider({
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
    Title = "Press B to start or stop following the ball while enabled.",
})

local avatarTab = window:Tab({
    Title = "Avatar",
    Icon = "user-round",
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

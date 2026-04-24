local REMOTE_BASE = "https://raw.githubusercontent.com/ceooarii-hue/dxdef/main/"

local function run_local(paths)
    for _, path in ipairs(paths) do
        local ok, result = pcall(readfile, path)
        if ok and result then
            return loadstring(result)()
        end
    end

    for _, path in ipairs(paths) do
        local ok, result = pcall(function()
            return game:HttpGet(REMOTE_BASE .. path)
        end)

        if ok and result and result ~= "404: Not Found" then
            return loadstring(result)()
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

run_local({
    "tps/modules/Bypass.lua",
    "modules/Bypass.lua",
})

local Chams = run_local({
    "tps/modules/Chams.lua",
    "modules/Chams.lua",
})

local ReachFTI = run_local({
    "tps/modules/Reach(FTI).lua",
    "modules/Reach(FTI).lua",
})

local Reacts = run_local({
    "tps/modules/Reacts.lua",
    "modules/Reacts.lua",
})

local LookDistance = run_local({
    "tps/modules/Look distance.lua",
    "modules/Look distance.lua",
})

local FirstClick = run_local({
    "tps/modules/First click.lua",
    "modules/First click.lua",
})

local SecondClick = run_local({
    "tps/modules/Second click.lua",
    "modules/Second click.lua",
})

local MacroReact = run_local({
    "tps/modules/Macro react.lua",
    "modules/Macro react.lua",
})

local BallSize = run_local({
    "tps/modules/Ball size.lua",
    "modules/Ball size.lua",
})

local BallSkin = run_local({
    "tps/modules/Ball skin changer.lua",
    "modules/Ball skin changer.lua",
})

local AirHelper = run_local({
    "tps/modules/AirHelper.lua",
    "modules/AirHelper.lua",
})

local AvatarStolen = run_local({
    "tps/modules/Avatarstolen.lua",
    "modules/Avatarstolen.lua",
})

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
local reachTab = window:Tab({
    Title = "Reach",
    Icon = "accessibility",
})

reachTab:Toggle({
    Title = "Enable reach",
    Value = false,
    Callback = function(state)
        reachEnabled = state
        if state then
            ReachFTI.enable()
        else
            ReachFTI.destroy()
            ReachFTI = run_local({
                "tps/modules/Reach(FTI).lua",
                "modules/Reach(FTI).lua",
            })
        end
    end,
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

local reactsEnabled = false
local reactsTab = window:Tab({
    Title = "Reacts",
    Icon = "zap",
})

reactsTab:Toggle({
    Title = "Enable reacts",
    Desc = "Touch mas rapido, 0 delay.",
    Value = false,
    Callback = function(state)
        reactsEnabled = state
        if state then
            Reacts.enable()
        else
            Reacts.destroy()
            Reacts = run_local({
                "tps/modules/Reacts.lua",
                "modules/Reacts.lua",
            })
        end
    end,
})

reactsTab:Space()

reactsTab:Slider({
    Title = "React Distance",
    Step = 1,
    Value = {
        Min = 1,
        Max = 30,
        Default = Reacts.reactDistance or 10,
    },
    Callback = function(value)
        Reacts.setReactDistance(value)
    end,
})

reactsTab:Slider({
    Title = "Look Distance",
    Step = 1,
    Value = {
        Min = 1,
        Max = 15,
        Default = LookDistance.value,
    },
    Callback = function(value)
        LookDistance.set(value)
    end,
})

reactsTab:Slider({
    Title = "ZZ Helps",
    Step = 1,
    Value = {
        Min = 0,
        Max = 10,
        Default = Reacts.zzHelps or 1,
    },
    Callback = function(value)
        Reacts.setZZHelps(value)
    end,
})

reactsTab:Slider({
    Title = "React Speed",
    Step = 0.01,
    Value = {
        Min = 0,
        Max = 1,
        Default = Reacts.reactSpeed or 0.25,
    },
    Callback = function(value)
        Reacts.setReactSpeed(value)
    end,
})

reactsTab:Slider({
    Title = "First Click",
    Step = 0.01,
    Value = {
        Min = 0,
        Max = 1,
        Default = FirstClick.value,
    },
    Callback = function(value)
        FirstClick.set(value)
    end,
})

reactsTab:Slider({
    Title = "Second Click",
    Step = 0.01,
    Value = {
        Min = 0,
        Max = 1,
        Default = SecondClick.value,
    },
    Callback = function(value)
        SecondClick.set(value)
    end,
})

reactsTab:Slider({
    Title = "Break React Speed",
    Step = 0.01,
    Value = {
        Min = 0,
        Max = 1,
        Default = Reacts.breakReactSpeed or 0.25,
    },
    Callback = function(value)
        Reacts.setBreakReactSpeed(value)
    end,
})

reactsTab:Toggle({
    Title = "Macro React",
    Value = MacroReact.enabled,
    Callback = function(state)
        MacroReact.set(state)
    end,
})

local ballTab = window:Tab({
    Title = "Ball",
    Icon = "circle",
})

local ballSizeEnabled = false
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
local miscTab = window:Tab({
    Title = "Misc",
    Icon = "layers-2",
})

miscTab:Toggle({
    Title = "Air helper",
    Value = false,
    Callback = function(state)
        if state then
            AirHelper.enable()
            AirHelper.setSize(airSize)
        else
            AirHelper = run_local({
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

local avatarTab = window:Tab({
    Title = "Avatar",
    Icon = "user-round",
})

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
        AvatarStolen = run_local({
            "tps/modules/Avatarstolen.lua",
            "modules/Avatarstolen.lua",
        })
    end,
})

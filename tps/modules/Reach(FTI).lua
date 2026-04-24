local env      = getgenv()
local plrs     = cloneref(game:GetService("Players"))
local rs       = cloneref(game:GetService("RunService"))
local lighting = cloneref(game:GetService("Lighting"))
local CoreGui  = cloneref(game:GetService("CoreGui"))
local lp       = plrs.LocalPlayer
local sys      = workspace:WaitForChild("TPSSystem")

if env.ReachFTI and type(env.ReachFTI.destroy) == "function" then
    pcall(env.ReachFTI.destroy)
end

local _conn = nil
local _visual = nil

local function get_leg(char)
    if not char then return nil end

    local foot   = lighting[lp.Name].PreferredFoot
    local is_r15 = char:FindFirstChild("RightLowerLeg") ~= nil
    local name

    if is_r15 then
        name = foot == 2 and "LeftLowerLeg" or "RightLowerLeg"
    else
        name = foot == 2 and "Left Leg" or "Right Leg"
    end

    return char:FindFirstChild(name)
end

env.ReachFTI = {}
env.ReachFTI.studs = 10

local function update_visual(leg)
    if not _visual then
        _visual = Instance.new("BoxHandleAdornment")
        _visual.Name = "ReachFTIVisualizer"
        _visual.Parent = CoreGui
        _visual.Color3 = Color3.fromRGB(255, 80, 80)
        _visual.Transparency = 0.68
        _visual.AlwaysOnTop = true
        _visual.ZIndex = 5
    end

    if not leg then
        _visual.Visible = false
        return
    end

    local studs = env.ReachFTI and env.ReachFTI.studs or 10
    _visual.Adornee = leg
    _visual.Size = Vector3.new(studs * 2, 2, studs * 2)
    _visual.Visible = true
end

env.ReachFTI.enable = function()
    if _conn then return end

    _conn = rs.Heartbeat:Connect(function()
        local char = lp.Character
        local leg  = get_leg(char)
        local tps  = sys:FindFirstChild("TPS")
        update_visual(leg)
        if not leg or not tps then return end

        local dist = (leg.Position - tps.Position).Magnitude
        if dist > (env.ReachFTI and env.ReachFTI.studs or 10) then return end

        firetouchinterest(leg, tps, 0)
        firetouchinterest(leg, tps, 1)
    end)
end

env.ReachFTI.setStuds = function(n)
    if not env.ReachFTI then return end
    env.ReachFTI.studs = n
end

env.ReachFTI.destroy = function()
    if _conn then _conn:Disconnect(); _conn = nil end
    if _visual then _visual:Destroy(); _visual = nil end
    env.ReachFTI = nil
end

return env.ReachFTI

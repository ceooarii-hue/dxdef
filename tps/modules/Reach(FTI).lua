local env = getgenv()
local plrs = cloneref(game:GetService("Players"))
local rs = cloneref(game:GetService("RunService"))
local lighting = cloneref(game:GetService("Lighting"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local lp = plrs.LocalPlayer
local sys = workspace:WaitForChild("TPSSystem")

if env.ReachFTI and type(env.ReachFTI.destroy) == "function" then
    pcall(env.ReachFTI.destroy)
end

local conn = nil
local visual = nil

local function get_leg(char)
    if not char then return nil end

    local foot = lighting[lp.Name].PreferredFoot
    local is_r15 = char:FindFirstChild("RightLowerLeg") ~= nil
    local name

    if is_r15 then
        name = foot == 2 and "LeftLowerLeg" or "RightLowerLeg"
    else
        name = foot == 2 and "Left Leg" or "Right Leg"
    end

    return char:FindFirstChild(name)
end

env.ReachFTI = {
    studs = 10,
    visualizerEnabled = true,
}

local function update_visual(leg)
    if not env.ReachFTI.visualizerEnabled then
        if visual then visual.Visible = false end
        return
    end

    if not visual then
        visual = Instance.new("SelectionBox")
        visual.Name = "ReachFTIVisualizer"
        visual.Parent = CoreGui
        visual.Color3 = Color3.fromRGB(255, 95, 95)
        visual.LineThickness = 0.03
        visual.SurfaceTransparency = 1
    end

    if not leg then
        visual.Visible = false
        return
    end

    visual.Adornee = leg
    visual.Visible = true
end

env.ReachFTI.enable = function()
    if conn then return end

    conn = rs.Heartbeat:Connect(function()
        local char = lp.Character
        local leg = get_leg(char)
        local tps = sys:FindFirstChild("TPS")

        update_visual(leg)
        if not leg or not tps then return end

        local dist = (leg.Position - tps.Position).Magnitude
        if dist > (env.ReachFTI.studs or 10) then return end

        firetouchinterest(leg, tps, 0)
        firetouchinterest(leg, tps, 1)
    end)
end

env.ReachFTI.setStuds = function(n)
    if env.ReachFTI then
        env.ReachFTI.studs = n
    end
end

env.ReachFTI.setVisualizerEnabled = function(state)
    if env.ReachFTI then
        env.ReachFTI.visualizerEnabled = state
    end

    if visual then
        visual.Visible = state and visual.Adornee ~= nil
    end
end

env.ReachFTI.destroy = function()
    if conn then conn:Disconnect(); conn = nil end
    if visual then visual:Destroy(); visual = nil end
    env.ReachFTI = nil
end

return env.ReachFTI

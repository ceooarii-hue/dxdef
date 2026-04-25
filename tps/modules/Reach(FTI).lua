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

local function create_visualizer(name, color)
    local box = Instance.new("BoxHandleAdornment")
    box.Name = name .. "Fill"
    box.Parent = CoreGui
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Transparency = 0.72
    box.Color3 = color

    local outline = Instance.new("SelectionBox")
    outline.Name = name .. "Outline"
    outline.Parent = CoreGui
    outline.Color3 = color:Lerp(Color3.new(1, 1, 1), 0.25)
    outline.LineThickness = 0.045
    outline.SurfaceTransparency = 1

    return {
        box = box,
        outline = outline,
    }
end

local function update_visualizer(adornee, enabled)
    if not visual then return end

    local visible = enabled and adornee ~= nil
    visual.box.Adornee = adornee
    visual.outline.Adornee = adornee
    visual.box.Size = adornee and (adornee.Size + Vector3.new(0.08, 0.08, 0.08)) or Vector3.zero
    visual.box.Visible = visible
    visual.outline.Visible = visible
end

local function destroy_visualizer()
    if not visual then return end
    visual.box:Destroy()
    visual.outline:Destroy()
    visual = nil
end

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
        if visual then
            update_visualizer(visual.box.Adornee, false)
        end
        return
    end

    if not visual then
        visual = create_visualizer("ReachFTIVisualizer", Color3.fromRGB(255, 108, 108))
    end

    if not leg then
        update_visualizer(nil, false)
        return
    end

    update_visualizer(leg, true)
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
        update_visualizer(visual.box.Adornee, state)
    end
end

env.ReachFTI.destroy = function()
    if conn then conn:Disconnect(); conn = nil end
    destroy_visualizer()
    env.ReachFTI = nil
end

return env.ReachFTI

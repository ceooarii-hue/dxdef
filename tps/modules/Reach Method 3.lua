local env = getgenv()
local plrs = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local lp = plrs.LocalPlayer

if env.ReachHRP and type(env.ReachHRP.destroy) == "function" then
    pcall(env.ReachHRP.destroy)
end

local origSize = nil
local origCollide = nil
local charConn = nil
local propConn = nil
local visualizer = nil

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
    outline.Color3 = color:Lerp(Color3.new(1, 1, 1), 0.2)
    outline.LineThickness = 0.045
    outline.SurfaceTransparency = 1

    return {
        box = box,
        outline = outline,
    }
end

local function update_visualizer(adornee, enabled)
    if not visualizer then return end

    local visible = enabled and adornee ~= nil
    visualizer.box.Adornee = adornee
    visualizer.outline.Adornee = adornee
    visualizer.box.Size = adornee and (adornee.Size + Vector3.new(0.08, 0.08, 0.08)) or Vector3.zero
    visualizer.box.Visible = visible
    visualizer.outline.Visible = visible
end

local function destroy_visualizer()
    if not visualizer then return end
    visualizer.box:Destroy()
    visualizer.outline:Destroy()
    visualizer = nil
end

local function apply(char)
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end

    task.wait(0.1)
    if not hrp.Parent then return end

    if not origSize then origSize = hrp.Size end
    if origCollide == nil then origCollide = hrp.CanCollide end

    local function set_hrp()
        local s = env.ReachHRP and env.ReachHRP.size or Vector3.new(10, 2, 10)
        hrp.Size = Vector3.new(s.X, 2, s.Z)
        hrp.CanCollide = false

        if not visualizer then
            visualizer = create_visualizer("ReachHRPVisualizer", Color3.fromRGB(100, 255, 170))
        end

        update_visualizer(hrp, env.ReachHRP.visualizerEnabled)
    end

    set_hrp()

    if propConn then propConn:Disconnect() end
    propConn = hrp:GetPropertyChangedSignal("Size"):Connect(function()
        local s = env.ReachHRP and env.ReachHRP.size or Vector3.new(10, 2, 10)
        local want = Vector3.new(s.X, 2, s.Z)
        if hrp.Size ~= want then
            hrp.Size = want
        end
        update_visualizer(hrp, env.ReachHRP.visualizerEnabled)
    end)
end

env.ReachHRP = {
    size = Vector3.new(10, 2, 10),
    visualizerEnabled = true,
}

env.ReachHRP.enable = function()
    local char = lp.Character
    if char then apply(char) end

    if charConn then charConn:Disconnect() end
    charConn = lp.CharacterAdded:Connect(apply)
end

env.ReachHRP.setSize = function(x, z)
    env.ReachHRP.size = Vector3.new(x, 2, z)

    local char = lp.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Size = Vector3.new(x, 2, z)
            hrp.CanCollide = false
            update_visualizer(hrp, env.ReachHRP.visualizerEnabled)
        end
    end
end

env.ReachHRP.setVisualizerEnabled = function(state)
    env.ReachHRP.visualizerEnabled = state
    if visualizer then
        update_visualizer(visualizer.box.Adornee, state)
    end
end

env.ReachHRP.destroy = function()
    if charConn then charConn:Disconnect(); charConn = nil end
    if propConn then propConn:Disconnect(); propConn = nil end
    destroy_visualizer()

    local char = lp.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if origSize then hrp.Size = origSize end
            if origCollide ~= nil then hrp.CanCollide = origCollide end
        end
    end

    origSize = nil
    origCollide = nil
    env.ReachHRP = nil
end

return env.ReachHRP

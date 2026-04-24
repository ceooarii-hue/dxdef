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
            visualizer = Instance.new("SelectionBox")
            visualizer.Name = "ReachHRPVisualizer"
            visualizer.Parent = CoreGui
            visualizer.Color3 = Color3.fromRGB(90, 255, 140)
            visualizer.LineThickness = 0.03
            visualizer.SurfaceTransparency = 1
        end

        visualizer.Adornee = hrp
        visualizer.Visible = env.ReachHRP.visualizerEnabled
    end

    set_hrp()

    if propConn then propConn:Disconnect() end
    propConn = hrp:GetPropertyChangedSignal("Size"):Connect(function()
        local s = env.ReachHRP and env.ReachHRP.size or Vector3.new(10, 2, 10)
        local want = Vector3.new(s.X, 2, s.Z)
        if hrp.Size ~= want then
            hrp.Size = want
        end
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
        end
    end
end

env.ReachHRP.setVisualizerEnabled = function(state)
    env.ReachHRP.visualizerEnabled = state
    if visualizer then
        visualizer.Visible = state
    end
end

env.ReachHRP.destroy = function()
    if charConn then charConn:Disconnect(); charConn = nil end
    if propConn then propConn:Disconnect(); propConn = nil end
    if visualizer then visualizer:Destroy(); visualizer = nil end

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

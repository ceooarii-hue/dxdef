local env = getgenv()
local plrs = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local lp = plrs.LocalPlayer

if env.ReachMethod2 and type(env.ReachMethod2.destroy) == "function" then
    pcall(env.ReachMethod2.destroy)
end

local charConn = nil
local sizeToken = 0
local parts = {}

local function is_body_part(part)
    if not part or not part:IsA("BasePart") then return false end
    local name = part.Name
    return name == "Head"
        or name == "Torso"
        or name == "UpperTorso"
        or name == "LowerTorso"
        or name:find("Arm") ~= nil
        or name:find("Hand") ~= nil
        or name:find("Leg") ~= nil
        or name:find("Foot") ~= nil
end

local function cleanup_parts()
    sizeToken = sizeToken + 1

    for _, entry in ipairs(parts) do
        if entry.visualizer and entry.visualizer.Parent then
            entry.visualizer:Destroy()
        end
        if entry.clone and entry.clone.Parent then
            entry.clone:Destroy()
        end
        if entry.original and entry.original.Parent then
            if entry.origSize then entry.original.Size = entry.origSize end
            if entry.origTransparency ~= nil then entry.original.Transparency = entry.origTransparency end
            if entry.origMassless ~= nil then entry.original.Massless = entry.origMassless end
        end
    end

    parts = {}
end

local function apply(char)
    cleanup_parts()

    task.wait(0.1)
    if not char or not char.Parent then return end

    for _, original in ipairs(char:GetChildren()) do
        if is_body_part(original) then
            local origSize = original.Size
            local origTransparency = original.Transparency
            local origMassless = original.Massless

            local clone = original:Clone()
            clone.Name = original.Name .. "_Visual"
            clone.Size = origSize
            clone.Transparency = origTransparency
            clone.Massless = true
            clone.CanCollide = false
            clone.Anchored = false

            local weld = Instance.new("WeldConstraint")
            weld.Part0 = original
            weld.Part1 = clone
            weld.Parent = clone

            clone.Parent = char
            clone.CFrame = original.CFrame

            local visualizer = Instance.new("SelectionBox")
            visualizer.Name = original.Name .. "_ReachM2"
            visualizer.Parent = CoreGui
            visualizer.Adornee = original
            visualizer.Color3 = Color3.fromRGB(95, 170, 255)
            visualizer.LineThickness = 0.03
            visualizer.SurfaceTransparency = 1
            visualizer.Visible = env.ReachMethod2.visualizerEnabled

            parts[#parts + 1] = {
                original = original,
                clone = clone,
                visualizer = visualizer,
                origSize = origSize,
                origTransparency = origTransparency,
                origMassless = origMassless,
            }

            original.Transparency = 1
            original.Size = env.ReachMethod2.size
            original.Massless = true
        end
    end

    local last = env.ReachMethod2.size
    local token = sizeToken + 1
    sizeToken = token

    task.spawn(function()
        while sizeToken == token and env.ReachMethod2 do
            local cur = env.ReachMethod2.size
            if cur ~= last then
                for _, entry in ipairs(parts) do
                    if entry.original and entry.original.Parent then
                        entry.original.Size = cur
                    end
                end
                last = cur
            end

            for _, entry in ipairs(parts) do
                if entry.visualizer and entry.visualizer.Parent then
                    entry.visualizer.Visible = env.ReachMethod2.visualizerEnabled
                end
            end

            task.wait(0.1)
        end
    end)
end

env.ReachMethod2 = {
    size = Vector3.new(10, 2, 10),
    visualizerEnabled = true,
}

env.ReachMethod2.enable = function()
    local char = lp.Character
    if char then
        task.spawn(apply, char)
    end

    if charConn then charConn:Disconnect() end
    charConn = lp.CharacterAdded:Connect(apply)
end

env.ReachMethod2.setSize = function(x, z)
    env.ReachMethod2.size = Vector3.new(x, 2, z)
    for _, entry in ipairs(parts) do
        if entry.original and entry.original.Parent then
            entry.original.Size = env.ReachMethod2.size
        end
    end
end

env.ReachMethod2.setVisualizerEnabled = function(state)
    env.ReachMethod2.visualizerEnabled = state
    for _, entry in ipairs(parts) do
        if entry.visualizer and entry.visualizer.Parent then
            entry.visualizer.Visible = state
        end
    end
end

env.ReachMethod2.destroy = function()
    if charConn then charConn:Disconnect(); charConn = nil end
    cleanup_parts()
    env.ReachMethod2 = nil
end

return env.ReachMethod2

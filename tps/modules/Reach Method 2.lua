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

local function create_visualizer(name, color)
    local box = Instance.new("BoxHandleAdornment")
    box.Name = name .. "Fill"
    box.Parent = CoreGui
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Transparency = 0.74
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

local function update_visualizer(visualizer, adornee, enabled)
    local visible = enabled and adornee ~= nil and adornee.Parent ~= nil
    visualizer.box.Adornee = adornee
    visualizer.outline.Adornee = adornee
    visualizer.box.Size = adornee and (adornee.Size + Vector3.new(0.08, 0.08, 0.08)) or Vector3.zero
    visualizer.box.Visible = visible
    visualizer.outline.Visible = visible
end

local function destroy_visualizer(visualizer)
    if visualizer.box.Parent then
        visualizer.box:Destroy()
    end
    if visualizer.outline.Parent then
        visualizer.outline:Destroy()
    end
end

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
        if entry.visualizer then
            destroy_visualizer(entry.visualizer)
        end
        if entry.hitbox and entry.hitbox.Parent then
            entry.hitbox:Destroy()
        end
    end

    parts = {}
end

local function create_hitbox(original, char)
    local hitbox = Instance.new("Part")
    hitbox.Name = original.Name .. "_ReachM2Hitbox"
    hitbox.Transparency = 1
    hitbox.CanCollide = false
    hitbox.CanQuery = false
    hitbox.CanTouch = true
    hitbox.CastShadow = false
    hitbox.Massless = true
    hitbox.Anchored = false
    hitbox.Locked = true
    hitbox.Size = env.ReachMethod2.size
    hitbox.CFrame = original.CFrame
    hitbox.Parent = char

    local weld = Instance.new("WeldConstraint")
    weld.Part0 = original
    weld.Part1 = hitbox
    weld.Parent = hitbox

    return hitbox
end

local function apply(char)
    cleanup_parts()

    task.wait(0.1)
    if not char or not char.Parent then return end

    for _, original in ipairs(char:GetChildren()) do
        if is_body_part(original) then
            local hitbox = create_hitbox(original, char)
            local visualizer = create_visualizer(original.Name .. "_ReachM2", Color3.fromRGB(98, 182, 255))
            update_visualizer(visualizer, hitbox, env.ReachMethod2.visualizerEnabled)

            parts[#parts + 1] = {
                original = original,
                hitbox = hitbox,
                visualizer = visualizer,
            }
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
                    if entry.hitbox and entry.hitbox.Parent then
                        entry.hitbox.Size = cur
                    end
                end
                last = cur
            end

            for _, entry in ipairs(parts) do
                if entry.visualizer then
                    local adornee = nil
                    if entry.hitbox and entry.hitbox.Parent then
                        adornee = entry.hitbox
                    end
                    update_visualizer(entry.visualizer, adornee, env.ReachMethod2.visualizerEnabled)
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
        if entry.hitbox and entry.hitbox.Parent then
            entry.hitbox.Size = env.ReachMethod2.size
        end
    end
end

env.ReachMethod2.setVisualizerEnabled = function(state)
    env.ReachMethod2.visualizerEnabled = state
    for _, entry in ipairs(parts) do
        if entry.visualizer then
            local adornee = nil
            if entry.hitbox and entry.hitbox.Parent then
                adornee = entry.hitbox
            end
            update_visualizer(entry.visualizer, adornee, state)
        end
    end
end

env.ReachMethod2.destroy = function()
    if charConn then charConn:Disconnect(); charConn = nil end
    cleanup_parts()
    env.ReachMethod2 = nil
end

return env.ReachMethod2

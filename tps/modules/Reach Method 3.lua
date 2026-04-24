local env = getgenv()
local plrs = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local lp = plrs.LocalPlayer

if env.ReachHRP and type(env.ReachHRP.destroy) == "function" then
    pcall(env.ReachHRP.destroy)
end

local _orig_size = nil
local _orig_collide = nil
local _char_conn = nil
local _prop_conn = nil
local _visualizer = nil

local function apply(char)
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end

    task.wait(0.1)
    if not hrp.Parent then return end

    if not _orig_size then _orig_size = hrp.Size end
    if _orig_collide == nil then _orig_collide = hrp.CanCollide end

    local function set_hrp()
        local s = env.ReachHRP and env.ReachHRP.size or Vector3.new(15, 2, 15)
        hrp.Size = Vector3.new(s.X, 2, s.Z)
        hrp.CanCollide = false

        if not _visualizer then
            _visualizer = Instance.new("BoxHandleAdornment")
            _visualizer.Name = "ReachHRPVisualizer"
            _visualizer.Parent = CoreGui
            _visualizer.Color3 = Color3.fromRGB(90, 255, 140)
            _visualizer.Transparency = 0.72
            _visualizer.AlwaysOnTop = true
            _visualizer.ZIndex = 5
        end

        _visualizer.Adornee = hrp
        _visualizer.Size = Vector3.new(s.X, 2, s.Z)
    end

    set_hrp()

    if _prop_conn then _prop_conn:Disconnect() end
    _prop_conn = hrp:GetPropertyChangedSignal("Size"):Connect(function()
        local s = env.ReachHRP and env.ReachHRP.size or Vector3.new(15, 2, 15)
        local want = Vector3.new(s.X, 2, s.Z)
        if hrp.Size ~= want then
            hrp.Size = want
        end
    end)
end

env.ReachHRP = {
    size = Vector3.new(15, 2, 15),
}

env.ReachHRP.enable = function()
    local char = lp.Character
    if char then apply(char) end

    if _char_conn then _char_conn:Disconnect() end
    _char_conn = lp.CharacterAdded:Connect(apply)
end

env.ReachHRP.setSize = function(x, z)
    env.ReachHRP.size = Vector3.new(x, 2, z)

    local char = lp.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Size = Vector3.new(x, 2, z)
            hrp.CanCollide = false
            if _visualizer then
                _visualizer.Adornee = hrp
                _visualizer.Size = Vector3.new(x, 2, z)
            end
        end
    end
end

env.ReachHRP.destroy = function()
    if _char_conn then _char_conn:Disconnect(); _char_conn = nil end
    if _prop_conn then _prop_conn:Disconnect(); _prop_conn = nil end
    if _visualizer then _visualizer:Destroy(); _visualizer = nil end

    local char = lp.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            if _orig_size then hrp.Size = _orig_size end
            if _orig_collide ~= nil then hrp.CanCollide = _orig_collide end
        end
    end

    _orig_size = nil
    _orig_collide = nil
    env.ReachHRP = nil
end

return env.ReachHRP

local rs   = cloneref(game:GetService("RunService"))
local sys  = workspace:WaitForChild("TPSSystem")
local cfg  = { size = 20 }

if getgenv().AirHelper and type(getgenv().AirHelper.destroy) == "function" then
    pcall(getgenv().AirHelper.destroy)
end

local platform = nil
local conn = nil

local function get_tps()
    return sys:FindFirstChild("TPS")
end

local function update_platform()
    local tps = get_tps()
    if not tps or not platform then return end
    platform.CFrame = CFrame.new(tps.Position.X, tps.Position.Y - 1.5, tps.Position.Z)
end

local function ensure_platform()
    if platform and platform.Parent then return end

    platform = Instance.new("Part")
    platform.Name = ""
    platform.Anchored = true
    platform.CanCollide = true
    platform.Transparency = 1
    platform.CastShadow = false
    platform.Size = Vector3.new(cfg.size, 0.1, cfg.size)
    platform.Material = Enum.Material.SmoothPlastic
    platform.Parent = sys
    update_platform()
end

getgenv().AirHelper = {
    enable = function()
        ensure_platform()
        if conn then return end

        conn = rs.Heartbeat:Connect(function()
            update_platform()
        end)
    end,
    destroy = function()
        if conn then conn:Disconnect(); conn = nil end
        if platform and platform.Parent then platform:Destroy() end
        platform = nil
        getgenv().AirHelper = nil
    end,
    setSize = function(s)
        cfg.size      = s
        if platform then
            platform.Size = Vector3.new(s, 0.1, s)
        end
    end,
}

return getgenv().AirHelper

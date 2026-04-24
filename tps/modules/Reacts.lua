local RunService = cloneref(game:GetService("RunService"))
local sys = workspace:WaitForChild("TPSSystem")

if getgenv().Reacts and type(getgenv().Reacts.destroy) == "function" then
    pcall(getgenv().Reacts.destroy)
end

local Reacts = {}
local activeConn = nil

local function get_ball()
    return sys:FindFirstChild("TPS")
end

local function stop_active()
    if activeConn then
        activeConn:Disconnect()
        activeConn = nil
    end
end

local function apply_react(linearVelocity, angularVelocity, frames)
    local ball = get_ball()
    if not ball then
        return false, "TPS not found"
    end

    stop_active()

    local remaining = frames or 6
    activeConn = RunService.Heartbeat:Connect(function()
        if not ball.Parent then
            stop_active()
            return
        end

        ball.Velocity = linearVelocity
        ball.RotVelocity = angularVelocity

        remaining = remaining - 1
        if remaining <= 0 then
            stop_active()
        end
    end)

    return true, "React applied"
end

Reacts.betterReact = function()
    return apply_react(Vector3.new(110, 110, 110), Vector3.new(32, 32, 32), 10)
end

Reacts.destroy = function()
    stop_active()
    getgenv().Reacts = nil
end

getgenv().Reacts = Reacts

return Reacts

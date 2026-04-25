local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UserInputService = cloneref(game:GetService("UserInputService"))

local lp = Players.LocalPlayer
local sys = workspace:WaitForChild("TPSSystem")

if getgenv().InfDribbleHelper and type(getgenv().InfDribbleHelper.destroy) == "function" then
    pcall(getgenv().InfDribbleHelper.destroy)
end

local Helper = {
    enabled = false,
    following = false,
    toggleKey = Enum.KeyCode.B,
    stopDistance = 2.25,
    predictionTime = 0.12,
    orbitPadding = 1.15,
}

local inputConn = nil
local stepConn = nil

local function get_ball()
    return sys:FindFirstChild("TPS")
end

local function get_humanoid()
    local char = lp.Character
    if not char then return nil, nil end
    return char:FindFirstChildOfClass("Humanoid"), char:FindFirstChild("HumanoidRootPart")
end

local function stop_motion()
    local humanoid = get_humanoid()
    if humanoid then
        humanoid:Move(Vector3.zero, false)
    end
end

local function stop_following()
    Helper.following = false
    stop_motion()
end

local function flatten(v)
    return Vector3.new(v.X, 0, v.Z)
end

local function get_target_position(ball, root)
    local predictedBall = ball.Position + flatten(ball.AssemblyLinearVelocity) * Helper.predictionTime
    local fromBallToPlayer = flatten(root.Position - predictedBall)

    if fromBallToPlayer.Magnitude < 0.05 then
        fromBallToPlayer = flatten(-root.CFrame.LookVector)
    end

    local stopOffset = math.min(Helper.stopDistance * 0.6, Helper.orbitPadding)
    return predictedBall + fromBallToPlayer.Unit * stopOffset
end

local function ensure_connections()
    if not inputConn then
        inputConn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp or not Helper.enabled then return end
            if input.KeyCode == Helper.toggleKey then
                Helper.following = not Helper.following
            end
        end)
    end

    if not stepConn then
        stepConn = RunService.RenderStepped:Connect(function()
            if not Helper.enabled or not Helper.following then return end

            local ball = get_ball()
            local humanoid, root = get_humanoid()
            if not ball or not humanoid or not root or humanoid.Health <= 0 then
                stop_motion()
                return
            end

            local distance = (root.Position - ball.Position).Magnitude
            if distance <= Helper.stopDistance then
                humanoid:Move(Vector3.zero, false)
                return
            end

            local target = get_target_position(ball, root)
            local moveDirection = flatten(target - root.Position)

            if moveDirection.Magnitude < 0.05 then
                humanoid:Move(Vector3.zero, false)
                return
            end

            humanoid:Move(moveDirection.Unit, false)
        end)
    end
end

Helper.enable = function()
    Helper.enabled = true
    ensure_connections()
end

Helper.disable = function()
    Helper.enabled = false
    stop_following()
end

Helper.setToggleKey = function(keyCode)
    Helper.toggleKey = keyCode
end

Helper.setStopDistance = function(distance)
    Helper.stopDistance = distance
end

Helper.destroy = function()
    if inputConn then inputConn:Disconnect(); inputConn = nil end
    if stepConn then stepConn:Disconnect(); stepConn = nil end
    Helper.disable()
    getgenv().InfDribbleHelper = nil
end

getgenv().InfDribbleHelper = Helper

return Helper

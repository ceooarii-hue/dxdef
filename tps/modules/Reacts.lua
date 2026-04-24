local plrs = cloneref(game:GetService("Players"))
local rs = cloneref(game:GetService("RunService"))
local lighting = cloneref(game:GetService("Lighting"))
local camera = workspace.CurrentCamera
local lp = plrs.LocalPlayer
local sys = workspace:WaitForChild("TPSSystem")

if getgenv().Reacts and type(getgenv().Reacts.destroy) == "function" then
    pcall(getgenv().Reacts.destroy)
end

local conn = nil
local busy = false
local insideWindow = false
local lastReactAt = 0
local lastBreakAt = 0

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

local function point_to_ray_distance(origin, direction, point)
    local unit = direction.Unit
    local projected = math.max((point - origin):Dot(unit), 0)
    local closest = origin + unit * projected
    return (point - closest).Magnitude
end

local function touch_ball(leg, tps)
    firetouchinterest(leg, tps, 0)
    firetouchinterest(leg, tps, 1)
end

getgenv().Reacts = {
    reactDistance = 10,
    zzHelps = 1,
    reactSpeed = 0.25,
    breakReactSpeed = 0.25,
}

local function can_look_at_ball(tps)
    local currentCamera = workspace.CurrentCamera or camera
    if not currentCamera then return true end
    local lookDistance = getgenv().LookDistance and getgenv().LookDistance.value or 6
    return point_to_ray_distance(currentCamera.CFrame.Position, currentCamera.CFrame.LookVector, tps.Position)
        <= lookDistance
end

local function is_valid_target()
    local char = lp.Character
    local leg = get_leg(char)
    local tps = sys:FindFirstChild("TPS")
    if not leg or not tps then return nil end

    if (leg.Position - tps.Position).Magnitude > (getgenv().Reacts.reactDistance or 10) then
        return nil
    end

    if not can_look_at_ball(tps) then
        return nil
    end

    return leg, tps
end

local function run_react_sequence(leg, tps)
    if busy then return end
    busy = true

    task.spawn(function()
        local cfg = getgenv().Reacts
        local firstClick = getgenv().FirstClick and getgenv().FirstClick.value or 0
        local secondClick = getgenv().SecondClick and getgenv().SecondClick.value or 0.25
        if not cfg then
            busy = false
            return
        end

        if firstClick > 0 then
            task.wait(firstClick)
        end
        if not leg.Parent or not tps.Parent then
            busy = false
            return
        end

        touch_ball(leg, tps)

        if secondClick > 0 then
            task.wait(secondClick)
        end
        if not leg.Parent or not tps.Parent then
            busy = false
            return
        end

        touch_ball(leg, tps)

        for _ = 1, math.max(math.floor(cfg.zzHelps or 0), 0) do
            task.wait()
            if not leg.Parent or not tps.Parent then break end
            touch_ball(leg, tps)
        end

        lastReactAt = tick()
        busy = false
    end)
end

getgenv().Reacts.enable = function()
    if conn then return end

    conn = rs.RenderStepped:Connect(function()
        local leg, tps = is_valid_target()
        local now = tick()

        if not leg or not tps then
            if insideWindow then
                insideWindow = false
                lastBreakAt = now
            end
            return
        end

        if now - lastBreakAt < (getgenv().Reacts.breakReactSpeed or 0.25) then
            insideWindow = true
            return
        end

        if busy or (now - lastReactAt) < (getgenv().Reacts.reactSpeed or 0.25) then
            insideWindow = true
            return
        end

        if getgenv().MacroReact and not getgenv().MacroReact.enabled and insideWindow then
            return
        end

        insideWindow = true
        run_react_sequence(leg, tps)
    end)
end

getgenv().Reacts.setReactDistance = function(n)
    if getgenv().Reacts then getgenv().Reacts.reactDistance = n end
end

getgenv().Reacts.setZZHelps = function(n)
    if getgenv().Reacts then getgenv().Reacts.zzHelps = n end
end

getgenv().Reacts.setReactSpeed = function(n)
    if getgenv().Reacts then getgenv().Reacts.reactSpeed = n end
end

getgenv().Reacts.setBreakReactSpeed = function(n)
    if getgenv().Reacts then getgenv().Reacts.breakReactSpeed = n end
end

getgenv().Reacts.destroy = function()
    if conn then conn:Disconnect(); conn = nil end
    busy = false
    insideWindow = false
    lastReactAt = 0
    lastBreakAt = 0
    getgenv().Reacts = nil
end

return getgenv().Reacts

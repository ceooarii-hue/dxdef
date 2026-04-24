local plrs = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local lp = plrs.LocalPlayer

if getgenv().ReachMethod2 and type(getgenv().ReachMethod2.destroy) == "function" then
    pcall(getgenv().ReachMethod2.destroy)
end

local _char_conn = nil
local _size_token = 0
local _parts = {}

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
    _size_token = _size_token + 1

    for _, entry in ipairs(_parts) do
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

    _parts = {}
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

            local visualizer = Instance.new("BoxHandleAdornment")
            visualizer.Name = original.Name .. "_ReachM2"
            visualizer.Parent = CoreGui
            visualizer.Adornee = original
            visualizer.Color3 = Color3.fromRGB(90, 170, 255)
            visualizer.Transparency = 0.72
            visualizer.AlwaysOnTop = true
            visualizer.ZIndex = 5
            visualizer.Size = getgenv().ReachMethod2.size

            _parts[#_parts + 1] = {
                original = original,
                clone = clone,
                visualizer = visualizer,
                origSize = origSize,
                origTransparency = origTransparency,
                origMassless = origMassless,
            }

            original.Transparency = 1
            original.Size = getgenv().ReachMethod2.size
            original.Massless = true
        end
    end

    local last = getgenv().ReachMethod2.size
    local token = _size_token + 1
    _size_token = token
    task.spawn(function()
        while _size_token == token and getgenv().ReachMethod2 do
            local cur = getgenv().ReachMethod2.size
            if cur ~= last then
                for _, entry in ipairs(_parts) do
                    if entry.original and entry.original.Parent then
                        entry.original.Size = cur
                    end
                    if entry.visualizer and entry.visualizer.Parent then
                        entry.visualizer.Size = cur
                    end
                end
                last = cur
            end
            task.wait(0.1)
        end
    end)
end

getgenv().ReachMethod2 = {
    size = Vector3.new(25, 2, 25),
}

function getgenv().ReachMethod2.enable()
    local char = lp.Character
    if char then
        task.spawn(apply, char)
    end

    if _char_conn then _char_conn:Disconnect() end
    _char_conn = lp.CharacterAdded:Connect(apply)
end

function getgenv().ReachMethod2.setSize(x, z)
    getgenv().ReachMethod2.size = Vector3.new(x, 2, z)
    for _, entry in ipairs(_parts) do
        if entry.original and entry.original.Parent then
            entry.original.Size = getgenv().ReachMethod2.size
        end
        if entry.visualizer and entry.visualizer.Parent then
            entry.visualizer.Size = getgenv().ReachMethod2.size
        end
    end
end

function getgenv().ReachMethod2.destroy()
    if _char_conn then _char_conn:Disconnect(); _char_conn = nil end
    cleanup_parts()
    getgenv().ReachMethod2 = nil
end

return getgenv().ReachMethod2

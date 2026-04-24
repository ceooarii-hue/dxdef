local Players = cloneref(game:GetService("Players"))
local lp = Players.LocalPlayer

getgenv().RemapHGKReactState = getgenv().RemapHGKReactState or {}
local shared = getgenv().RemapHGKReactState

if getgenv().GKReact and type(getgenv().GKReact.disable) == "function" then
    pcall(getgenv().GKReact.disable)
end

local GKReact = {
    enabled = false,
    actions = {
        SaveRA = true,
        SaveLA = true,
        SaveRL = true,
        SaveLL = true,
        SaveT = true,
        Tackle = true,
        Header = true,
    },
    preferredPart = "LLCL",
}

local meta = getrawmetatable(game)
shared.oldNamecall = shared.oldNamecall or meta.__namecall

local function get_react_part()
    local char = lp.Character
    if not char then return nil end

    return char:FindFirstChild(GKReact.preferredPart)
        or char:FindFirstChild("RLCL")
        or char:FindFirstChild("LLCL")
        or char:FindFirstChild("HumanoidRootPart")
end

if not shared.hooked then
    setreadonly(meta, false)
    meta.__namecall = newcclosure(function(self, ...)
        local current = getgenv().GKReact
        local method = getnamecallmethod()
        if current and current.enabled and method == "FireServer" and current.actions[tostring(self)] then
            local args = { ... }
            local reactPart = get_react_part()
            if reactPart then
                args[2] = reactPart
                return shared.oldNamecall(self, unpack(args))
            end
        end

        return shared.oldNamecall(self, ...)
    end)
    setreadonly(meta, true)
    shared.hooked = true
end

GKReact.enable = function()
    GKReact.enabled = true
end

GKReact.disable = function()
    GKReact.enabled = false
end

GKReact.setPart = function(partName)
    GKReact.preferredPart = partName
end

GKReact.destroy = function()
    GKReact.disable()
    getgenv().GKReact = nil
end

getgenv().GKReact = GKReact

return GKReact

local Players = cloneref(game:GetService("Players"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local RunService = cloneref(game:GetService("RunService"))
local lp = Players.LocalPlayer

if getgenv().Chams and type(getgenv().Chams.destroy) == "function" then
    pcall(getgenv().Chams.destroy)
end

local Chams = {
    enabled = false,
    includeSelf = true,
    fillColor = Color3.fromRGB(255, 85, 85),
    outlineColor = Color3.fromRGB(255, 255, 255),
    fillTransparency = 0.5,
    outlineTransparency = 0,
    style = "Highlight",
    throughWalls = true,
    highlights = {},
    selectionBoxes = {},
    boxAdornments = {},
    charConns = {},
    playerConns = {},
    hbConn = nil,
}

local function get_root(char)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

local function clear_visuals(player)
    local highlight = Chams.highlights[player]
    if highlight then
        highlight:Destroy()
        Chams.highlights[player] = nil
    end

    local selection = Chams.selectionBoxes[player]
    if selection then
        selection:Destroy()
        Chams.selectionBoxes[player] = nil
    end

    local box = Chams.boxAdornments[player]
    if box then
        box:Destroy()
        Chams.boxAdornments[player] = nil
    end
end

local function ensure_highlight(player, char)
    local highlight = Chams.highlights[player]
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "REMAPH_ChamsHighlight"
        highlight.Parent = CoreGui
        Chams.highlights[player] = highlight
    end

    highlight.Adornee = char
    highlight.FillColor = Chams.fillColor
    highlight.OutlineColor = Chams.outlineColor
    highlight.DepthMode = Chams.throughWalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
    return highlight
end

local function ensure_selection(player, char)
    local selection = Chams.selectionBoxes[player]
    if not selection then
        selection = Instance.new("SelectionBox")
        selection.Name = "REMAPH_ChamsSelection"
        selection.Parent = CoreGui
        selection.LineThickness = 0.05
        Chams.selectionBoxes[player] = selection
    end

    selection.Adornee = char
    selection.Color3 = Chams.outlineColor
    selection.SurfaceTransparency = 1
    return selection
end

local function ensure_box(player, char)
    local root = get_root(char)
    if not root then return nil end

    local box = Chams.boxAdornments[player]
    if not box then
        box = Instance.new("BoxHandleAdornment")
        box.Name = "REMAPH_ChamsBox"
        box.Parent = CoreGui
        box.ZIndex = 10
        box.AlwaysOnTop = Chams.throughWalls
        Chams.boxAdornments[player] = box
    end

    box.Adornee = root
    box.Color3 = Chams.fillColor
    box.Transparency = math.clamp(Chams.fillTransparency, 0, 1)
    box.AlwaysOnTop = Chams.throughWalls
    box.Size = char:GetExtentsSize() + Vector3.new(0.15, 0.15, 0.15)
    return box
end

local function apply_visuals(player)
    if not Chams.enabled then return end
    if player == lp and not Chams.includeSelf then return end

    local char = player.Character
    if not char or not char.Parent then
        clear_visuals(player)
        return
    end

    clear_visuals(player)

    if Chams.style == "Highlight" then
        local highlight = ensure_highlight(player, char)
        highlight.FillTransparency = Chams.fillTransparency
        highlight.OutlineTransparency = Chams.outlineTransparency
    elseif Chams.style == "Outline" then
        local highlight = ensure_highlight(player, char)
        highlight.FillTransparency = 1
        highlight.OutlineTransparency = Chams.outlineTransparency
        ensure_selection(player, char)
    elseif Chams.style == "Box" then
        ensure_box(player, char)
    elseif Chams.style == "Hybrid" then
        local highlight = ensure_highlight(player, char)
        highlight.FillTransparency = Chams.fillTransparency
        highlight.OutlineTransparency = Chams.outlineTransparency
        ensure_box(player, char)
        ensure_selection(player, char)
    end
end

local function watch_player(player)
    if Chams.playerConns[player] then return end

    Chams.playerConns[player] = player.CharacterAdded:Connect(function(char)
        if Chams.charConns[player] then
            Chams.charConns[player]:Disconnect()
        end

        Chams.charConns[player] = char.AncestryChanged:Connect(function(_, parent)
            if not parent then
                clear_visuals(player)
            end
        end)

        task.defer(function()
            apply_visuals(player)
        end)
    end)

    if player.Character then
        apply_visuals(player)
    end
end

local function unwatch_player(player)
    clear_visuals(player)

    if Chams.charConns[player] then
        Chams.charConns[player]:Disconnect()
        Chams.charConns[player] = nil
    end

    if Chams.playerConns[player] then
        Chams.playerConns[player]:Disconnect()
        Chams.playerConns[player] = nil
    end
end

function Chams.setEnabled(state)
    Chams.enabled = state

    if state then
        for _, player in ipairs(Players:GetPlayers()) do
            watch_player(player)
            apply_visuals(player)
        end

        if not Chams.hbConn then
            Chams.hbConn = RunService.Heartbeat:Connect(function()
                if not Chams.enabled then return end
                for _, player in ipairs(Players:GetPlayers()) do
                    if (player ~= lp or Chams.includeSelf) and player.Character and (Chams.style == "Box" or Chams.style == "Hybrid") then
                        local box = Chams.boxAdornments[player]
                        if box then
                            box.Size = player.Character:GetExtentsSize() + Vector3.new(0.15, 0.15, 0.15)
                        end
                    end
                end
            end)
        end
    else
        for player in pairs(Chams.highlights) do
            clear_visuals(player)
        end
        for player in pairs(Chams.selectionBoxes) do
            clear_visuals(player)
        end
        for player in pairs(Chams.boxAdornments) do
            clear_visuals(player)
        end
        if Chams.hbConn then
            Chams.hbConn:Disconnect()
            Chams.hbConn = nil
        end
    end
end

function Chams.setStyle(style)
    Chams.style = style
    Chams.refresh()
end

function Chams.setThroughWalls(state)
    Chams.throughWalls = state
    Chams.refresh()
end

function Chams.setIncludeSelf(state)
    Chams.includeSelf = state
    if not state then
        clear_visuals(lp)
    end
    Chams.refresh()
end

function Chams.refresh()
    if not Chams.enabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        apply_visuals(player)
    end
end

function Chams.destroy()
    Chams.setEnabled(false)

    for player in pairs(Chams.charConns) do
        unwatch_player(player)
    end

    if Chams.addedConn then
        Chams.addedConn:Disconnect()
        Chams.addedConn = nil
    end

    if Chams.removingConn then
        Chams.removingConn:Disconnect()
        Chams.removingConn = nil
    end
end

Chams.addedConn = Players.PlayerAdded:Connect(function(player)
    watch_player(player)
    apply_visuals(player)
end)

Chams.removingConn = Players.PlayerRemoving:Connect(function(player)
    unwatch_player(player)
end)

getgenv().Chams = Chams

return Chams

local Players = cloneref(game:GetService("Players"))
local lp = Players.LocalPlayer

if getgenv().Chams and type(getgenv().Chams.destroy) == "function" then
    pcall(getgenv().Chams.destroy)
end

local Chams = {
    enabled = false,
    fillColor = Color3.fromRGB(255, 85, 85),
    outlineColor = Color3.fromRGB(255, 255, 255),
    fillTransparency = 0.5,
    outlineTransparency = 0,
    highlights = {},
    charConns = {},
    playerConns = {},
}

local function clear_highlight(player)
    local highlight = Chams.highlights[player]
    if highlight then
        highlight:Destroy()
        Chams.highlights[player] = nil
    end
end

local function apply_highlight(player)
    if not Chams.enabled or player == lp then return end

    local char = player.Character
    if not char or not char.Parent then
        clear_highlight(player)
        return
    end

    local highlight = Chams.highlights[player]
    if not highlight or not highlight.Parent then
        clear_highlight(player)
        highlight = Instance.new("Highlight")
        highlight.Name = "REMAPH_Chams"
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = char
        Chams.highlights[player] = highlight
    elseif highlight.Parent ~= char then
        highlight.Parent = char
    end

    highlight.Adornee = char
    highlight.FillColor = Chams.fillColor
    highlight.OutlineColor = Chams.outlineColor
    highlight.FillTransparency = Chams.fillTransparency
    highlight.OutlineTransparency = Chams.outlineTransparency
end

local function watch_player(player)
    if player == lp or Chams.playerConns[player] then return end

    Chams.playerConns[player] = player.CharacterAdded:Connect(function(char)
        task.wait(0.1)

        if Chams.charConns[player] then
            Chams.charConns[player]:Disconnect()
        end

        Chams.charConns[player] = char.AncestryChanged:Connect(function(_, parent)
            if not parent then
                clear_highlight(player)
            end
        end)

        apply_highlight(player)
    end)

    if player.Character then
        apply_highlight(player)
    end
end

local function unwatch_player(player)
    clear_highlight(player)

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
            apply_highlight(player)
        end
    else
        for player in pairs(Chams.highlights) do
            clear_highlight(player)
        end
    end
end

function Chams.refresh()
    if not Chams.enabled then return end

    for _, player in ipairs(Players:GetPlayers()) do
        apply_highlight(player)
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
    apply_highlight(player)
end)

Chams.removingConn = Players.PlayerRemoving:Connect(function(player)
    unwatch_player(player)
end)

getgenv().Chams = Chams

return Chams

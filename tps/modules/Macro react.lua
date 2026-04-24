if getgenv().MacroReact and type(getgenv().MacroReact.destroy) == "function" then
    pcall(getgenv().MacroReact.destroy)
end

getgenv().MacroReact = {
    enabled = true,
    set = function(state)
        getgenv().MacroReact.enabled = state
    end,
    destroy = function()
        getgenv().MacroReact = nil
    end,
}

return getgenv().MacroReact

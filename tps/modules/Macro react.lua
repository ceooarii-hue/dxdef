local env = getgenv()

if env.MacroReact and type(env.MacroReact.destroy) == "function" then
    pcall(env.MacroReact.destroy)
end

env.MacroReact = {
    enabled = true,
    set = function(state)
        env.MacroReact.enabled = state
    end,
    destroy = function()
        env.MacroReact = nil
    end,
}

return env.MacroReact

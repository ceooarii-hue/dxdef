local env = getgenv()

if env.LookDistance and type(env.LookDistance.destroy) == "function" then
    pcall(env.LookDistance.destroy)
end

env.LookDistance = {
    value = 6,
    set = function(n)
        env.LookDistance.value = n
    end,
    destroy = function()
        env.LookDistance = nil
    end,
}

return env.LookDistance

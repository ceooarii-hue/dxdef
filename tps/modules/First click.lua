local env = getgenv()

if env.FirstClick and type(env.FirstClick.destroy) == "function" then
    pcall(env.FirstClick.destroy)
end

env.FirstClick = {
    value = 2.4,
    set = function(n)
        env.FirstClick.value = n
    end,
    destroy = function()
        env.FirstClick = nil
    end,
}

return env.FirstClick

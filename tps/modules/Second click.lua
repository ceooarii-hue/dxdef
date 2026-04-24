local env = getgenv()

if env.SecondClick and type(env.SecondClick.destroy) == "function" then
    pcall(env.SecondClick.destroy)
end

env.SecondClick = {
    value = 1.2,
    set = function(n)
        env.SecondClick.value = n
    end,
    destroy = function()
        env.SecondClick = nil
    end,
}

return env.SecondClick

if getgenv().SecondClick and type(getgenv().SecondClick.destroy) == "function" then
    pcall(getgenv().SecondClick.destroy)
end

getgenv().SecondClick = {
    value = 0.25,
    set = function(n)
        getgenv().SecondClick.value = n
    end,
    destroy = function()
        getgenv().SecondClick = nil
    end,
}

return getgenv().SecondClick

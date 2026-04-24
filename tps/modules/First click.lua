if getgenv().FirstClick and type(getgenv().FirstClick.destroy) == "function" then
    pcall(getgenv().FirstClick.destroy)
end

getgenv().FirstClick = {
    value = 2.4,
    set = function(n)
        getgenv().FirstClick.value = n
    end,
    destroy = function()
        getgenv().FirstClick = nil
    end,
}

return getgenv().FirstClick

if getgenv().LookDistance and type(getgenv().LookDistance.destroy) == "function" then
    pcall(getgenv().LookDistance.destroy)
end

getgenv().LookDistance = {
    value = 6,
    set = function(n)
        getgenv().LookDistance.value = n
    end,
    destroy = function()
        getgenv().LookDistance = nil
    end,
}

return getgenv().LookDistance

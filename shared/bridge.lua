Bridge = {}
Bridge.Framework = nil
Bridge.FrameworkObject = nil
local resourceName = GetCurrentResourceName()
local frameworks = {
    ["es_extended"] = "esx",
    ["qb-core"] = "qbcore",
    ["qbx_core"] = "qbox"
}

CreateThread(function()
   Bridge.Framework = Config.Framework
    if not Bridge.Framework then
        if Config.Debug then
            print("^1ERROR: No framework set. Please set Config.Framework manually.^0")
        end
        return
    end
    if resourceName ~= "anox-blackmarket" then
        if Config.Debug then
            print("^1ERROR: Resource must be named 'anox-blackmarket'^0")
        end
        return
    end

    if Config.Debug then
        print("^2INFO: Using " .. Bridge.Framework .. " framework.^0")
    end

    TriggerEvent(resourceName..':CheckFramework')
end)

function Bridge.GetMoneyType()
    if Config.UseDirtyMoney then
        if Bridge.Framework == "esx" or Bridge.Framework == "qbox" then
            return "black_money"
        elseif Bridge.Framework == "qbcore" then
            return "markedbills"
        end
    else
        if Bridge.Framework == "esx" then
            return "money"
        elseif Bridge.Framework == "qbcore" or Bridge.Framework == "qbox" then
            return "cash"
        end
    end
    return "money"
end
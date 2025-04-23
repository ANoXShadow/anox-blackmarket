local currentLocation = 0
local resourceName = GetCurrentResourceName()
local isUsingNativeWeapons = true

RegisterNetEvent(resourceName..':CheckFramework')
AddEventHandler(resourceName..':CheckFramework', function()
    if Bridge.Framework == "esx" then
        ESX = exports["es_extended"]:getSharedObject()
        Bridge.FrameworkObject = ESX
        isUsingNativeWeapons = CheckNativeWeaponHandling()
        if Config.Debug then
        print("^2INFO: ESX detected. Using " .. (isUsingNativeWeapons and "native" or "inventory") .. " weapon handling^0")
        end
    elseif Bridge.Framework == "qbcore" then
        QBCore = exports['qb-core']:GetCoreObject()
        Bridge.FrameworkObject = QBCore
    elseif Bridge.Framework == "qbox" then
        QBCore = exports['qb-core']:GetCoreObject()
        Bridge.FrameworkObject = QBCore
    end
    lib.locale(Config.Locale)
    InitializeBlackMarket()
    RegisterCallbacks()
end)

function _L(key, ...)
    return locale(key, ...)
end

function InitializeBlackMarket()
    MySQL.query('SELECT * FROM anox_blackmarket_locations WHERE id = 1', {}, function(result)
        if result and result[1] then
            local storedLocation = result[1].current_location
            local lastChange = result[1].last_change
            local currentTime = os.time()
            local lastChangeTime
            if type(lastChange) == "string" then
                local year, month, day, hour, min, sec = string.match(lastChange, "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
                if year and month and day and hour and min and sec then
                    lastChangeTime = os.time({
                        year = tonumber(year),
                        month = tonumber(month),
                        day = tonumber(day),
                        hour = tonumber(hour),
                        min = tonumber(min),
                        sec = tonumber(sec)
                    })
                else
                    lastChangeTime = currentTime - (Config.LocationChangeTime * 60 + 1)
                    if Config.Debug then
                        print("^1WARNING: Failed to parse timestamp, forcing location change^0")
                    end
                end
            elseif type(lastChange) == "number" then
                lastChangeTime = lastChange
            else
                lastChangeTime = currentTime - (Config.LocationChangeTime * 60 + 1)
                if Config.Debug then
                    print("^1WARNING: Invalid timestamp format, forcing location change^0")
                end
            end
            local minutesPassed = (currentTime - lastChangeTime) / 60
            if minutesPassed >= Config.LocationChangeTime or storedLocation == 0 then
                ChangeBlackMarketLocation()
            else
                currentLocation = storedLocation
                if Config.Debug then
                    print("^2INFO: Current black market location loaded: " .. currentLocation .. "^0")
                end
            end
        else
            MySQL.insert('INSERT INTO anox_blackmarket_locations (id, last_change, current_location) VALUES (?, CURRENT_TIMESTAMP, ?)', {
                1, 1
            }, function()
                currentLocation = 1
                if Config.Debug then
                    print("^2INFO: Initial black market location set to: 1^0")
                end
            end)
        end
    end)
    SetTimeout(Config.LocationChangeTime * 60 * 1000, ChangeBlackMarketLocationTimer)
end


function RegisterCallbacks()
    if Bridge.Framework == "esx" then
        ESX.RegisterServerCallback(resourceName..':buyItem', function(source, cb, itemName, price, metadata)
            BuyItem(source, cb, itemName, price, metadata)
        end)
    elseif Bridge.Framework == "qbcore" or Bridge.Framework == "qbox" then
        Bridge.FrameworkObject.Functions.CreateCallback(resourceName..':buyItem', function(source, cb, itemName, price, metadata)
            BuyItem(source, cb, itemName, price, metadata)
        end)
    end
end

function ChangeBlackMarketLocationTimer()
    ChangeBlackMarketLocation()
    SetTimeout(Config.LocationChangeTime * 60 * 1000, ChangeBlackMarketLocationTimer)
end

function ChangeBlackMarketLocation()
    local oldLocation = currentLocation
    repeat
        currentLocation = math.random(1, #Config.Locations)
    until currentLocation ~= oldLocation or #Config.Locations == 1
    MySQL.update('UPDATE anox_blackmarket_locations SET last_change = CURRENT_TIMESTAMP, current_location = ? WHERE id = 1', {
        currentLocation
    })
    if Config.Debug then
        print("^3INFO: Black market location changed to: " .. currentLocation .. "^0")
    end
    TriggerClientEvent(resourceName..':UpdateLocations', -1, currentLocation)
end

RegisterNetEvent(resourceName..':requestLocation')
AddEventHandler(resourceName..':requestLocation', function()
    local src = source
    TriggerClientEvent(resourceName..':UpdateLocations', src, currentLocation)
end)

local function GetPlayer(source)
    if Bridge.Framework == "esx" then
        return ESX.GetPlayerFromId(source)
    elseif Bridge.Framework == "qbcore" or Bridge.Framework == "qbox" then
        return Bridge.FrameworkObject.Functions.GetPlayer(source)
    end
    return nil
end

function CheckNativeWeaponHandling()
    if Bridge.Framework ~= "esx" then 
        return false
    end
    local hasGetWeapon = pcall(function()
        return ESX.GetWeapon ~= nil
    end)
    local inventoryResources = {
        "ox_inventory",
    }
    for _, resource in ipairs(inventoryResources) do
        if GetResourceState(resource) == "started" then
            if Config.Debug then
                print("^3INFO: Detected inventory system: " .. resource .. ", disabling native weapon handling^0")
            end
            return false
        end
    end
    local dummyCheck = true
    local testPlayer = ESX.GetPlayerFromId(1)
    if testPlayer then
        dummyCheck = pcall(function()
            if testPlayer.addInventoryItem and type(testPlayer.addInventoryItem) == "function" then
                return true
            else
                return false
            end
        end)
    end
    if not hasGetWeapon and dummyCheck then
        if Config.Debug then
            print("^3INFO: ESX inventory system detected, disabling native weapon handling^0")
        end
        return false
    end
    if Config.Debug then
        print("^3INFO: Using native ESX weapon handling^0")
    end
    return true
end


function BuyItem(source, cb, itemName, price, metadata)
    local src = source
    local Player = GetPlayer(src)
    if not Player then
        cb(false, _L('player_not_found'))
        return
    end
    local moneyType = Bridge.GetMoneyType()
    local hasMoney = false
    local debugPrefix = "^3[DEBUG]^0 "
    if Config.Debug then
        print(debugPrefix.."Starting purchase for "..src.." - Item: "..itemName.." | Price: "..price.." | MoneyType: "..moneyType)
    end
    if Bridge.Framework == "esx" then
        hasMoney = Player.getAccount(moneyType).money >= price
    elseif Bridge.Framework == "qbcore" then
        if moneyType == "markedbills" then
            local totalWorth = 0
            local markedBills = Player.Functions.GetItemsByName("markedbills") or {}
            for _, item in pairs(markedBills) do
                if item.info and item.info.worth then
                    totalWorth = totalWorth + item.info.worth
                end
            end
            hasMoney = totalWorth >= price
        else
            local moneyAmount = Player.Functions.GetMoney(moneyType) or 0
            hasMoney = moneyAmount >= price
        end
    elseif Bridge.Framework == "qbox" then
        if moneyType == "black_money" then
            local blackMoneyItems = Player.Functions.GetItemsByName("black_money") or {}
            local totalAmount = 0
            if Config.Debug then
                print(debugPrefix.."Black Money Items Structure:")
                for i, item in pairs(blackMoneyItems) do
                    print(debugPrefix.."Item "..i..":")
                    for k, v in pairs(item) do
                        print(debugPrefix.."  "..k.." = "..tostring(v))
                    end
                end
            end
            for _, item in pairs(blackMoneyItems) do
                local itemAmount = 0
                if item.count then
                    itemAmount = tonumber(item.count) or 0
                elseif item.quantity then
                    itemAmount = tonumber(item.quantity) or 0
                elseif item.amount then
                    itemAmount = tonumber(item.amount) or 0
                end
                totalAmount = totalAmount + itemAmount
            end
            hasMoney = totalAmount >= price
            if Config.Debug then
                print(debugPrefix.."Black Money Check - Total: "..totalAmount.." | Needed: "..price.." | Has Enough: "..tostring(hasMoney))
            end
        else
            local moneyAmount = Player.Functions.GetMoney(moneyType) or 0
            hasMoney = moneyAmount >= price
        end
    end
    if not hasMoney then
        if Config.Debug then
            print(debugPrefix.."Player "..src.." doesn't have enough money")
        end
        cb(false, _L('not_enough_money'))
        return
    end
    local isWeapon = string.match(itemName, "WEAPON_")
    local shouldUseNativeWeapon = isWeapon and isUsingNativeWeapons
    local canCarry = false
    local alreadyAdded = false
    if Bridge.Framework == "esx" then
        if shouldUseNativeWeapon then
            canCarry = true
        else
            canCarry = Player.canCarryItem(itemName, 1)
        end
    elseif Bridge.Framework == "qbcore" then
        if Player.Functions.CanCarryItem then
            canCarry = Player.Functions.CanCarryItem(itemName, 1)
        else
            canCarry = Player.Functions.AddItem(itemName, 1, nil, metadata)
            if not canCarry then
                Player.Functions.RemoveItem(itemName, 1)
            else
                alreadyAdded = true
            end
        end
    elseif Bridge.Framework == "qbox" then
        if Player.Functions.CanCarryItem then
            canCarry = Player.Functions.CanCarryItem(itemName, 1)
        else
            canCarry = true
        end
    end
    if not canCarry then
        if Config.Debug then
            print(debugPrefix.."Player "..src.." can't carry item "..itemName)
        end
        cb(false, _L('cannot_carry'))
        return
    end
    if Bridge.Framework == "esx" then
        Player.removeAccountMoney(moneyType, price)
    elseif Bridge.Framework == "qbcore" then
        if moneyType == "markedbills" then
            local remaining = price
            local markedBills = Player.Functions.GetItemsByName("markedbills") or {}
            table.sort(markedBills, function(a, b)
                return (a.info and a.info.worth or 0) > (b.info and b.info.worth or 0)
            end)
            for _, item in pairs(markedBills) do
                if remaining <= 0 then break end
                if item.info and item.info.worth and item.info.worth > 0 then
                    local deductAmount = math.min(remaining, item.info.worth)
                    local newWorth = item.info.worth - deductAmount
                    Player.Functions.RemoveItem("markedbills", 1, item.slot)
                    if newWorth > 0 then
                        local newInfo = {worth = newWorth}
                        for k, v in pairs(item.info) do
                            if k ~= 'worth' then newInfo[k] = v end
                        end
                        Player.Functions.AddItem("markedbills", 1, item.slot, newInfo)
                    end
                    remaining = remaining - deductAmount
                end
            end
            if remaining > 0 then
                cb(false, _L('not_enough_money'))
                return
            end
        else
            Player.Functions.RemoveMoney(moneyType, price)
        end
    elseif Bridge.Framework == "qbox" then
        if moneyType == "black_money" then
            local removed = 0
            local blackMoneyItems = Player.Functions.GetItemsByName("black_money") or {}
            for _, item in pairs(blackMoneyItems) do
                if removed >= price then break end
                local itemAmount = 0
                local slotInfo = item.slot
                if item.count then
                    itemAmount = tonumber(item.count) or 0
                elseif item.quantity then
                    itemAmount = tonumber(item.quantity) or 0
                elseif item.amount then
                    itemAmount = tonumber(item.amount) or 0
                end
                local toRemove = math.min(price - removed, itemAmount)
                if Config.Debug then
                    print(debugPrefix.."Removing black money - Slot: "..tostring(slotInfo).." | Amount: "..toRemove)
                end
                if Player.Functions.RemoveItem("black_money", toRemove, slotInfo) then
                    removed = removed + toRemove
                end
            end
            if removed < price then
                if Config.Debug then
                    print(debugPrefix.."Failed to remove enough black money. Needed: "..price.." | Removed: "..removed)
                end
                cb(false, _L('transaction_failed'))
                return
            end
        else
            Player.Functions.RemoveMoney(moneyType, price)
        end
    end
    if Bridge.Framework == "esx" then
        if shouldUseNativeWeapon then
            Player.addWeapon(itemName, 100)
            if Config.Debug then
            print("^3PURCHASE: Player "..src.." bought weapon "..itemName.." for $"..price.." (native weapon)^0")
            end
        else
            Player.addInventoryItem(itemName, 1, metadata)
            print("^3PURCHASE: Player "..src.." bought "..itemName.." for $"..price.."^0")
        end
    elseif Bridge.Framework == "qbcore" then
        if not alreadyAdded then
            if not Player.Functions.AddItem(itemName, 1, nil, metadata) then
                if Config.Debug then
                    print(debugPrefix.."Failed to add item "..itemName.." to player "..src)
                end
                Player.Functions.AddMoney(moneyType, price)
                cb(false, _L('transaction_failed'))
                return
            end
        end
        print("^3PURCHASE: Player "..src.." bought "..itemName.." for $"..price.."^0")
    elseif Bridge.Framework == "qbox" then
        if not Player.Functions.AddItem(itemName, 1, nil, metadata) then
            if Config.Debug then
                print(debugPrefix.."Failed to add item "..itemName.." to player "..src)
            end
            if moneyType == "black_money" then
                Player.Functions.AddItem("black_money", price)
            else
                Player.Functions.AddMoney(moneyType, price)
            end
            cb(false, _L('transaction_failed'))
            return
        end
        print("^3PURCHASE: Player "..src.." bought "..itemName.." for $"..price.."^0")
    end
    cb(true)
end

RegisterCommand('changebmspot', function(source, args, rawCommand)
    local src = source
    local player = GetPlayer(src)
    local isAdmin = false
    if Bridge.Framework == "esx" then
        if player.getGroup() == 'admin' or player.getGroup() == 'superadmin' then
            isAdmin = true
        end
    elseif Bridge.Framework == "qbcore" or Bridge.Framework == "qbox" then
        if QBCore.Functions.HasPermission(src, 'admin') then
            isAdmin = true
        end
    end
    if isAdmin then
        ChangeBlackMarketLocation()
        if Config.Notify == "ox" then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Admin Action',
                description = _L('admin_changed_location'),
                type = 'success'
            })
        elseif Config.Notify == "qb" then
            TriggerClientEvent('QBCore:Notify', src, _L('admin_changed_location'), "success")
        elseif Config.Notify == "esx" then
            TriggerClientEvent('esx:showNotification', src, _L('admin_changed_location'))
        end
    else
        if Config.Notify == "ox" then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Error',
                description = _L('no_permission'),
                type = 'error'
            })
        elseif Config.Notify == "qb" then
            TriggerClientEvent('QBCore:Notify', src, _L('no_permission'), "error")
        elseif Config.Notify == "esx" then
            TriggerClientEvent('esx:showNotification', src, _L('no_permission'))
        end
    end
end, false)
local currentPed = nil
local currentBlip = nil
local currentLocation = nil
local isSpawned = false
local resourceName = GetCurrentResourceName()

RegisterNetEvent(resourceName..':CheckFramework')
AddEventHandler(resourceName..':CheckFramework', function()
    if Bridge.Framework == "esx" then
        ESX = exports["es_extended"]:getSharedObject()
        Bridge.FrameworkObject = ESX
    elseif Bridge.Framework == "qbcore" then
        QBCore = exports['qb-core']:GetCoreObject()
        Bridge.FrameworkObject = QBCore
    elseif Bridge.Framework == "qbox" then
        QBCore = exports['qb-core']:GetCoreObject()
        Bridge.FrameworkObject = QBCore
    end
    InitializeBlackMarket()
end)

function InitializeBlackMarket()
    lib.locale(Config.Locale)
    Wait(1000)
    TriggerServerEvent(resourceName..':requestLocation')
end

function _L(key, ...)
    return locale(key, ...)
end

function CleanupPedAndBlip()
    if DoesEntityExist(currentPed) then
        DeleteEntity(currentPed)
        currentPed = nil
    end
    if currentBlip then
        RemoveBlip(currentBlip)
        currentBlip = nil
    end    
    isSpawned = false
end

function SpawnDealer(locationIndex)
    if isSpawned then
        CleanupPedAndBlip()
    end
    if not locationIndex or not Config.Locations[locationIndex] then
        if Config.Debug then
            print("Invalid location index:", locationIndex)
        end
        locationIndex = 1
    end
    currentLocation = Config.Locations[locationIndex]
    local coords = currentLocation.coords
    
    lib.requestModel(Config.PedModel)
    currentPed = CreatePed(4, GetHashKey(Config.PedModel), coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
    SetEntityHeading(currentPed, coords.w)
    FreezeEntityPosition(currentPed, true)
    SetEntityInvincible(currentPed, true)
    SetBlockingOfNonTemporaryEvents(currentPed, true)
    TaskStartScenarioInPlace(currentPed, Config.PedScenario, 0, true)
    
    if Config.EnableBlip then
        local blipConfig = currentLocation.blip
        currentBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(currentBlip, blipConfig.sprite)
        SetBlipColour(currentBlip, blipConfig.color)
        SetBlipScale(currentBlip, blipConfig.scale)
        SetBlipAsShortRange(currentBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blipConfig.label)
        EndTextCommandSetBlipName(currentBlip)
    end
    
    AddPedInteraction(currentPed)

    if Config.Debug then
        print("Black market dealer spawned at location: " .. locationIndex)
    end
    isSpawned = true
end

function AddPedInteraction(ped)
    if Config.Target == "ox" then
        exports.ox_target:addLocalEntity(ped, {
            {
                icon = Config.TargetOptions.icon,
                label = _L('talk_to_dealer'),
                distance = Config.TargetOptions.distance,
                onSelect = function()
                    OpenBlackMarketMenu()
                end
            }
        })
    elseif Config.Target == "qb" then
        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                {
                    icon = Config.TargetOptions.icon,
                    label = _L('talk_to_dealer'),
                    action = function()
                        OpenBlackMarketMenu()
                    end
                },
            },
            distance = Config.TargetOptions.distance
        })
    end
end

function OpenBlackMarketMenu()
    if Config.Menu == "ox" then
        OpenOxLibMenu()
    elseif Config.Menu == "qb" then
        OpenQBMenu()
    elseif Config.Menu == "esx" then
        OpenESXMenu()
    end
end

function OpenOxLibMenu()
    local options = {}
    for _, item in ipairs(Config.Items) do
        table.insert(options, {
            title = item.label,
            description = item.description .. "\nPrice: $" .. item.price,
            icon = 'bag-shopping',
            onSelect = function()
                AttemptPurchase(item)
            end,
            metadata = {
                {label = 'Price', value = '$' .. item.price},
            }
        })
    end
    lib.registerContext({
        id = 'blackmarket_menu',
        title = _L('dealer_name'),
        options = options
    })
    lib.showContext('blackmarket_menu')
end

function OpenQBMenu()
    local options = {}
    for _, item in ipairs(Config.Items) do
        table.insert(options, {
            header = item.label,
            txt = item.description .. " - $" .. item.price,
            icon = 'fas fa-shopping-bag',
            params = {
                event = resourceName..':PurchaseItem',
                args = {
                    item = item
                }
            }
        })
    end
    exports['qb-menu']:openMenu(options)
end

function OpenESXMenu()
    local elements = {}
    for _, item in ipairs(Config.Items) do
        table.insert(elements, {
            label = item.label .. ' - $' .. item.price,
            desc = item.description,
            value = item.item,
            price = item.price,
            metadata = item.metadata or {}
        })
    end
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'black_market', {
        title = _L('dealer_name'),
        align = 'center',
        elements = elements
    }, function(data, menu)
        local item = nil
        for _, i in ipairs(Config.Items) do
            if i.item == data.current.value then
                item = i
                break
            end
        end
        if item then
            AttemptPurchase(item)
        end
    end, function(data, menu)
        menu.close()
    end)
end

RegisterNetEvent(resourceName..':PurchaseItem')
AddEventHandler(resourceName..':PurchaseItem', function(data)
    if data and data.item then
        AttemptPurchase(data.item)
    end
end)

function AttemptPurchase(item)
    if Config.ProgressBar == "ox" then
        lib.progressBar({
            duration = 2000,
            label = _L('checking_merchandise'),
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
            },
            anim = {
                dict = 'mp_common',
                clip = 'givetake1_a'
            },
        })
    elseif Config.ProgressBar == "qb" then
        QBCore.Functions.Progressbar("checking_merchandise", _L('checking_merchandise'), 2000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = "mp_common",
            anim = "givetake1_a",
            flags = 50,
        }, {}, {}, function()
        end)
    elseif Config.ProgressBar == "esx" then
        exports['esx_progressbar']:Progressbar(_L('checking_merchandise'), 2000, {
            FreezePlayer = true,
            animation = {
                type = "anim",
                dict = "mp_common",
                lib = "givetake1_a",
                flags = 50,
            },
            onFinish = function()
            end,
            onCancel = function()
                return
            end
        })
    end
    Wait(2100)

    if Bridge.Framework == "esx" then
        ESX.TriggerServerCallback(resourceName..':buyItem', function(success, reason)
            HandlePurchaseResult(success, reason, item)
        end, item.item, item.price, item.metadata or {})
    elseif Bridge.Framework == "qbcore" or Bridge.Framework == "qbox" then
        Bridge.FrameworkObject.Functions.TriggerCallback(resourceName..':buyItem', function(success, reason)
            HandlePurchaseResult(success, reason, item)
        end, item.item, item.price, item.metadata or {})
    end
end

function HandlePurchaseResult(success, reason, item)
    if Config.Notify == "ox" then
        if success then
            lib.notify({
                title = 'Purchase Successful',
                description = _L('purchase_success', item.label),
                type = 'success'
            })
        else
            lib.notify({
                title = 'Purchase Failed',
                description = _L('purchase_failed', reason),
                type = 'error'
            })
        end
    elseif Config.Notify == "qb" then
        if success then
            QBCore.Functions.Notify(_L('purchase_success', item.label), "success")
        else
            QBCore.Functions.Notify(_L('purchase_failed', reason), "error")
        end
    elseif Config.Notify == "esx" then
        if success then
            ESX.ShowNotification(_L('purchase_success', item.label))
        else
            ESX.ShowNotification(_L('purchase_failed', reason))
        end
    end
end

RegisterNetEvent(resourceName..':UpdateLocations')
AddEventHandler(resourceName..':UpdateLocations', function(locationIndex)
    if Config.Debug then
        print("Received new black market location: " .. locationIndex)
    end
    
    SpawnDealer(locationIndex)
    
    if Config.Notify == "ox" then
        lib.notify({
            title = _L('dealer_name'),
            description = _L('market_moved'),
            type = 'inform'
        })
    elseif Config.Notify == "qb" then
        QBCore.Functions.Notify(_L('market_moved'), "primary")
    elseif Config.Notify == "esx" then
        ESX.ShowNotification(_L('market_moved'))
    end
end)

-- RegisterCommand('refreshblackmarket', function()
--     TriggerServerEvent(resourceName..':requestLocation')
-- end, false)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    CleanupPedAndBlip()
end)
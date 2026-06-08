local QBCore = exports['qb-core']:GetCoreObject()
local robbing = false

CreateThread(function()
    exports['qb-target']:AddTargetModel(Config.MeterModels, {
        options = {
            {
                type = "client",
                event = "ssrp-meter:client:attemptRobbery",
                icon = "fas fa-microchip",
                label = "Hack Meter",
                canInteract = function()
                    local pData = QBCore.Functions.GetPlayerData()
                    if not pData or not pData.items then return false end
                    for _, i in pairs(pData.items) do
                        if i.name == 'lockpick' then return true end
                        if Config.EnableToolset and i.name == 'toolset' then return true end
                    end
                    return false
                end
            },
        },
        distance = 1.5
    })
end)

local currentItemUsed = nil
RegisterNetEvent('ssrp-meter:client:attemptRobbery', function(data)
    if robbing then return end
    local entity = data.entity
    local coords = GetEntityCoords(entity)

    QBCore.Functions.TriggerCallback('ssrp-meter:server:checkItem', function(hasItem, itemName)
        if not hasItem then 
            QBCore.Functions.Notify("You need the proper tools", "error")
            return 
        end
        currentItemUsed = itemName

        QBCore.Functions.TriggerCallback('ssrp-meter:server:checkCooldown', function(canRob)
            if not canRob then
                QBCore.Functions.Notify("System Rebooting...", "error")
                return
            end
            StartRobbery(coords, itemName)
        end, coords)
    end)
end)

function StartRobbery(coords, itemName)
    robbing = true

    if math.random(1, 100) <= Config.PoliceCallChance then
        local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        local street = GetStreetNameFromHashKey(streetHash)
        
        local dispatchData = {
            title = "Meter Robbery",
            code = "10-90",
            location = street,
            description = "Someone tampering with a parking meter",
            type = "Alert",
            x = coords.x,
            y = coords.y,
            z = coords.z,
            sound = "dispatch",
            jobs = { 
                police = true
            },
            blip = {
                radius = 0,
                sprite = 58,
                color = 1,
                scale = 1.0,
                length = 2,
            }
        }
        TriggerServerEvent('kartik-mdt:server:sendDispatchNotification', dispatchData)
    end
    
    RequestAnimDict("anim@heists@ornate_bank@hack")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@hack") do Wait(10) end
    TaskPlayAnim(PlayerPedId(), "anim@heists@ornate_bank@hack", "hack_loop", 3.0, 3.0, -1, 1, 0, 0, 0, 0)

    SetNuiFocus(true, true)
    
    SendNUIMessage({
        action = "startMemoryGame",
        config = Config.HackSettings[itemName]
    })
end

RegisterNUICallback('fail', function()
    SetNuiFocus(false, false)
    ClearPedTasks(PlayerPedId())
    robbing = false
    
    local dispatchData = {
        message = "Parking Meter Tampering",
        code = "10-90",
        description = "Suspect failed to bypass parking meter security.",
        radius = 0,
        sprite = 58, 
        color = 1, 
        scale = 1.0,
        length = 3,
    }
    exports['ps-dispatch']:CustomAlert(dispatchData)

    QBCore.Functions.Notify("Connection Failed!", "error")
    TriggerServerEvent('ssrp-meter:server:removeItem', currentItemUsed)
end)

RegisterNUICallback('win', function()
    SetNuiFocus(false, false)
    ClearPedTasks(PlayerPedId())
    robbing = false
    
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local meter = 0
    for _, model in pairs(Config.MeterModels) do
        meter = GetClosestObjectOfType(coords.x, coords.y, coords.z, 2.0, model, false, false, false)
        if meter ~= 0 then break end
    end
    
    if meter ~= 0 then
        local meterLoc = GetEntityCoords(meter)
        TriggerServerEvent('ssrp-meter:server:reward', meterLoc)
    else
        TriggerServerEvent('ssrp-meter:server:reward', coords)
    end
end)
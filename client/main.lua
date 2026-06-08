local QBCore = exports['qb-core']:GetCoreObject()
local robbing = false

CreateThread(function()
    exports['qb-target']:AddTargetModel(Config.MeterModels, {
        options = {
            {
                type = "client",
                event = "ppr-meter:client:attemptRobbery",
                icon = "fas fa-microchip",
                label = "Hack Meter",
                item = Config.RequiredItem
            },
        },
        distance = 1.5
    })
end)

RegisterNetEvent('ppr-meter:client:attemptRobbery', function(data)
    if robbing then return end
    local entity = data.entity
    local coords = GetEntityCoords(entity)

    QBCore.Functions.TriggerCallback('ppr-meter:server:checkItem', function(hasItem)
        if not hasItem then 
            QBCore.Functions.Notify("You need a "..Config.RequiredItem, "error")
            return 
        end

        QBCore.Functions.TriggerCallback('ppr-meter:server:checkCooldown', function(canRob)
            if not canRob then
                QBCore.Functions.Notify("System Rebooting...", "error")
                return
            end
            StartRobbery(coords)
        end, coords)
    end)
end)

function StartRobbery(coords)
    robbing = true
    
    RequestAnimDict("anim@heists@ornate_bank@hack")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@hack") do Wait(10) end
    TaskPlayAnim(PlayerPedId(), "anim@heists@ornate_bank@hack", "hack_loop", 3.0, 3.0, -1, 1, 0, 0, 0, 0)

    SetNuiFocus(true, true)
    
    SendNUIMessage({
        action = "startMemoryGame",
        config = Config.MemoryGame
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
    TriggerServerEvent('ppr-meter:server:removeItem')
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
        TriggerServerEvent('ppr-meter:server:reward', meterLoc)
    else
        TriggerServerEvent('ppr-meter:server:reward', coords)
    end
end)
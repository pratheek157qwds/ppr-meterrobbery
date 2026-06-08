local QBCore = exports['qb-core']:GetCoreObject()
local MeterCooldowns = {}

QBCore.Functions.CreateCallback('ppr-meter:server:checkItem', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(false) end
    local hasItem = Player.Functions.GetItemByName(Config.RequiredItem)
    if hasItem then cb(true) else cb(false) end
end)

QBCore.Functions.CreateCallback('ppr-meter:server:checkCooldown', function(source, cb, meterLoc)
    local locString = string.format("%.2f,%.2f", meterLoc.x, meterLoc.y)
    if MeterCooldowns[locString] and (os.time() - MeterCooldowns[locString]) < Config.MeterCooldown then
        cb(false)
    else
        cb(true)
    end
end)

RegisterNetEvent('ppr-meter:server:reward', function(meterLoc)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local locString = string.format("%.2f,%.2f", meterLoc.x, meterLoc.y)
    if MeterCooldowns[locString] and (os.time() - MeterCooldowns[locString]) < Config.MeterCooldown then return end

    MeterCooldowns[locString] = os.time()

    if Config.RewardType == 'money' then
        local amount = math.random(Config.MoneyReward.min, Config.MoneyReward.max)
        Player.Functions.AddMoney('cash', amount, "meter-hack")
        TriggerClientEvent('QBCore:Notify', src, 'System Bypassed: +$'..amount, 'success')
    elseif Config.RewardType == 'item' then
        local count = math.random(Config.ItemReward.min, Config.ItemReward.max)
        if Player.Functions.AddItem(Config.ItemReward.item, count) then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.ItemReward.item], "add")
        end
    end
end)

RegisterNetEvent('ppr-meter:server:removeItem', function()
    if Config.RemoveItemOnFail then
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            Player.Functions.RemoveItem(Config.RequiredItem, 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.RequiredItem], "remove")
        end
    end
end)
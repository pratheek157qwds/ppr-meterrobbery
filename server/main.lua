local QBCore = exports['qb-core']:GetCoreObject()
local MeterCooldowns = {}

QBCore.Functions.CreateCallback('ssrp-meter:server:checkItem', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(false) end
    
    local itemsToCheck = {'lockpick'}
    if Config.EnableToolset then
        table.insert(itemsToCheck, 'toolset')
    end

    local usedItem = nil
    for _, item in ipairs(itemsToCheck) do
        if Player.Functions.GetItemByName(item) then
            usedItem = item
            break
        end
    end

    if usedItem then 
        cb(true, usedItem) 
    else 
        cb(false) 
    end
end)

QBCore.Functions.CreateCallback('ssrp-meter:server:checkCooldown', function(source, cb, meterLoc)
    local locString = string.format("%.2f,%.2f", meterLoc.x, meterLoc.y)
    if MeterCooldowns[locString] and (os.time() - MeterCooldowns[locString]) < Config.MeterCooldown then
        cb(false)
    else
        cb(true)
    end
end)

RegisterNetEvent('ssrp-meter:server:reward', function(meterLoc)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local locString = string.format("%.2f,%.2f", meterLoc.x, meterLoc.y)
    if MeterCooldowns[locString] and (os.time() - MeterCooldowns[locString]) < Config.MeterCooldown then return end

    MeterCooldowns[locString] = os.time()

    if Config.RewardType == 'money' or Config.RewardType == 'both' then
        local amount = math.random(Config.MoneyReward.min, Config.MoneyReward.max)
        Player.Functions.AddMoney('cash', amount, "meter-hack")
        TriggerClientEvent('QBCore:Notify', src, 'System Bypassed: +$'..amount, 'success')
    end

    if Config.RewardType == 'item' or Config.RewardType == 'both' then
        for _, reward in ipairs(Config.ItemRewards) do
            local chance = math.random(1, 100)
            if chance <= reward.chance then
                local count = math.random(reward.min, reward.max)
                if Player.Functions.AddItem(reward.item, count) then
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[reward.item], "add")
                end
            end
        end
    end
end)

RegisterNetEvent('ssrp-meter:server:removeItem', function(itemName)
    if not itemName then return end
    if math.random(1, 100) <= Config.ToolBreakChance then
        local src = source
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            Player.Functions.RemoveItem(itemName, 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], "remove")
        end
    end
end)
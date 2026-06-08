Config = {}

Config.RequiredItem = 'lockpick' 
Config.RemoveItemOnFail = true 

Config.RewardType = 'money' 
Config.MoneyReward = {min = 300, max = 600} 
Config.ItemReward = {item = 'plastic', min = 5, max = 15}

Config.MeterCooldown = 300 

Config.MemoryGame = {
    GridSize = {rows = 4, cols = 5}, -- 20 Cards = 10 Pairs
    TimeLimit = 60, 
    Icons = {
        "fa-car", "fa-motorcycle", "fa-truck", "fa-taxi", "fa-bus", 
        "fa-ambulance", "fa-fire-extinguisher", "fa-bicycle", "fa-plane", "fa-helicopter",
        "fa-ship", "fa-anchor", "fa-rocket", "fa-shuttle-van", "fa-subway"
    }
}

Config.MeterModels = {
    `prop_parknmeter_01`,
    `prop_parknmeter_02`
}
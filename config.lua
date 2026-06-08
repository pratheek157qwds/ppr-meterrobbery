Config = {}

Config.EnableToolset = true -- disablethis if you want it to work only with lockpick
Config.ToolBreakChance = 10 -- 10% chance to break toolkit/lockpick/toolset on failure

Config.RewardType = 'both' -- 'money', 'item', or 'both'
Config.MoneyReward = {min = 300, max = 600} 
Config.ItemRewards = {
    {item = 'steel', min = 3, max = 6, chance = 100},
    {item = 'plastic', min = 3, max = 6, chance = 100}
}

Config.MeterCooldown = 300
Config.PoliceCallChance = 60 -- 60% chance to call police change to your need

Config.HackSettings = {
    ['lockpick'] = {
        GridSize = {rows = 4, cols = 5},
        TimeLimit = 60,
        Icons = {
            "fa-car", "fa-motorcycle", "fa-truck", "fa-taxi", "fa-bus",
            "fa-ambulance", "fa-fire-extinguisher", "fa-bicycle", "fa-plane", "fa-helicopter",
            "fa-ship", "fa-anchor", "fa-rocket", "fa-shuttle-van", "fa-subway"
        }
    },
    ['toolset'] = {
        GridSize = {rows = 5, cols = 6},
        TimeLimit = 60,
        Icons = {
            "fa-car", "fa-motorcycle", "fa-truck", "fa-taxi", "fa-bus", 
            "fa-ambulance", "fa-fire-extinguisher", "fa-bicycle", "fa-plane", "fa-helicopter",
            "fa-ship", "fa-anchor", "fa-rocket", "fa-shuttle-van", "fa-subway",
            "fa-train", "fa-tractor", "fa-fighter-jet"
        }
    }
}


Config.MeterModels = {
    `prop_parknmeter_01`,
    `prop_parknmeter_02`
}
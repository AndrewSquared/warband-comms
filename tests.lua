WarbandComms.TestQueue = {}
WarbandComms.testing = false

local testStep = 0
local TEST_RUNTIME_SECONDS = 45

local TEST_WARBAND = {
    [1] = {
        players = {
            {name = "Knight", careerLine = GameData.CareerLine.KNIGHT},
            {name = "Swordmaster", careerLine = GameData.CareerLine.SWORDMASTER},
            {name = "Ironbreaker", careerLine = GameData.CareerLine.IRON_BREAKER},
            {name = "Blackguard", careerLine = GameData.CareerLine.BLACKGUARD},
            {name = "Black Orc", careerLine = GameData.CareerLine.BLACK_ORC},
            {name = "Chosen", careerLine = GameData.CareerLine.CHOSEN},
        },
    },
    [2] = {
        players = {
            {name = "White Lion", careerLine = GameData.CareerLine.WHITE_LION},
            {name = "Slayer", careerLine = GameData.CareerLine.SLAYER},
            {name = "Witch Hunter", careerLine = GameData.CareerLine.WITCH_HUNTER},
            {name = "Marauder", careerLine = GameData.CareerLine.MARAUDER},
            {name = "Choppa", careerLine = GameData.CareerLine.CHOPPA},
            {name = "Witch Elf", careerLine = GameData.CareerLine.WITCH_ELF},

        },
    },
    [3] = {
        players = {
            {name = "Bright Wizard", careerLine = GameData.CareerLine.BRIGHT_WIZARD},
            {name = "Shadow Warrior", careerLine = GameData.CareerLine.SHADOW_WARRIOR},
            {name = "Engineer", careerLine = GameData.CareerLine.ENGINEER},
            {name = "Sorcerer", careerLine = GameData.CareerLine.SORCERER},
            {name = "Squig Herder", careerLine = GameData.CareerLine.SQUIG_HERDER},
            {name = "Magus", careerLine = GameData.CareerLine.MAGUS},
        },
    },
    [4] = {
        players = {
            {name = "Warrior Priest", careerLine = GameData.CareerLine.WARRIOR_PRIEST},
            {name = "Rune Priest", careerLine = GameData.CareerLine.RUNE_PRIEST},
            {name = "Archmage", careerLine = GameData.CareerLine.ARCHMAGE},
            {name = "Shaman", careerLine = GameData.CareerLine.SHAMAN},
            {name = "Disciple", careerLine = GameData.CareerLine.DISCIPLE},
            {name = "Zealot", careerLine = GameData.CareerLine.ZEALOT},
        },
    },
}

local FULL_TRACKER_TEST_DATA = {
    challenge = {
        {name = "Knight", timer = 30, cooldown = 30, duration = 7, careerLine = GameData.CareerLine.KNIGHT},
        {name = "Swordmaster", timer = 22, cooldown = 30, duration = 7, careerLine = GameData.CareerLine.SWORDMASTER},
        {name = "Ironbreaker", timer = 11, cooldown = 30, duration = 7, careerLine = GameData.CareerLine.IRON_BREAKER},
        {name = "Blackguard", timer = 0, cooldown = 30, duration = 7, careerLine = GameData.CareerLine.BLACKGUARD},
    },
    channels = {
        {name = "Bright Wizard", timer = 8, cooldown = 8, duration = 3, careerLine = GameData.CareerLine.BRIGHT_WIZARD},
        {name = "White Lion", timer = 13, cooldown = 13, duration = 3, careerLine = GameData.CareerLine.WHITE_LION},
        {name = "Marauder", timer = 5, cooldown = 13, duration = 3, careerLine = GameData.CareerLine.MARAUDER},
        {name = "Slayer", timer = 0, cooldown = 25, duration = 5, careerLine = GameData.CareerLine.SLAYER},
    },
    interrupt = {
        {name = "Marauder", timer = 15, cooldown = 15, duration = 2, careerLine = GameData.CareerLine.MARAUDER},
        {name = "White Lion", timer = 12, cooldown = 15, duration = 2, careerLine = GameData.CareerLine.WHITE_LION},
        {name = "Swordmaster", timer = 7, cooldown = 15, duration = 2, careerLine = GameData.CareerLine.SWORDMASTER},
        {name = "Blackguard", timer = 0, cooldown = 15, duration = 2, careerLine = GameData.CareerLine.BLACKGUARD},
    },
    LTC = {
        {name = "Knight", timer = 120, cooldown = 120, duration = 10, careerLine = GameData.CareerLine.KNIGHT},
        {name = "Chosen", timer = 95, cooldown = 120, duration = 10, careerLine = GameData.CareerLine.CHOSEN},
        {name = "Black Orc", timer = 0, cooldown = 120, duration = 10, careerLine = GameData.CareerLine.BLACK_ORC},
        {name = "Blackguard", timer = 180, cooldown = 180, duration = 10, careerLine = GameData.CareerLine.BLACKGUARD},
    },
}

local CENTER_NOTIFICATION_TEST_DATA = {
    "Knight LTC",
    "Chosen LTC",
    "Blackguard Immaculate Defense",
    "Black Orc Immaculate Defense",
}

local function ResetAllTrackerData()
    for _, tracker in pairs(WarbandComms.Trackers) do
        for name, _ in pairs(tracker) do
            tracker[name] = nil
        end
    end
end

local function GetCareerIcon(careerLine)
    local careerData = WarbandComms.CAREERS[careerLine]
    if careerData then
        return careerData.icon or ""
    end

    return ""
end

function WarbandComms.RunTestQueue()
    testStep = testStep + 1

    if testStep >= TEST_RUNTIME_SECONDS then
        testStep = 0
        WarbandComms.testing = false
        WarbandComms.ClearUI()
        ResetAllTrackerData()
        WarbandComms.WarbandMap = {}
        EA_ChatWindow.Print(towstring("[WarbandComms] Test harness complete."))
    end
end


function WarbandComms.StartTest()
    WarbandComms.testing = true
    testStep = 0

    WarbandComms.ClearUI()
    ResetAllTrackerData()
    WarbandComms.MapWarbandMembers(TEST_WARBAND)

    for trackerName, trackerEntries in pairs(FULL_TRACKER_TEST_DATA) do
        for _, entry in ipairs(trackerEntries) do
            WarbandComms.AddTestAbility(
                entry.name,
                trackerName,
                entry.timer,
                entry.duration,
                GetCareerIcon(entry.careerLine),
                entry.cooldown
            )
        end
    end

    EA_ChatWindow.Print(towstring("[WarbandComms] Test harness started. All tracker boxes populated."))
end

function WarbandComms.StartCenterNotificationTest()
    for _, textLine in ipairs(CENTER_NOTIFICATION_TEST_DATA) do
        AlertTextWindow.AddLine(SystemData.AlertText.Types.RVR, towstring(textLine))
    end

    EA_ChatWindow.Print(towstring("[WarbandComms] Center-screen notification test fired (LTC + ID)."))
end

function WarbandComms.AddTestAbility(name, ability, timer, duration, careerIcon, cooldown)
    local trackerName = WarbandComms.ResolveTrackerName(ability)
    if not trackerName or not WarbandComms.Trackers[trackerName] then return end

    local testData = {
        ability = trackerName,
        name = name,
        timer = timer,
        cooldown = cooldown or timer,
        duration = duration,
        careerIcon = careerIcon,
    }

    WarbandComms.Trackers[trackerName][name] = testData

end


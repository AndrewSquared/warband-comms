WarbandComms.TestQueue = {}
WarbandComms.testing = false

local testStep = 0
local TEST_RUNTIME_SECONDS = 45
local testNameRun = 0

local TEST_WARBAND_TEMPLATE = {
    [1] = {
        players = {
            {careerLine = GameData.CareerLine.KNIGHT},
            {careerLine = GameData.CareerLine.SWORDMASTER},
            {careerLine = GameData.CareerLine.IRON_BREAKER},
            {careerLine = GameData.CareerLine.BLACKGUARD},
            {careerLine = GameData.CareerLine.BLACK_ORC},
            {careerLine = GameData.CareerLine.CHOSEN},
        },
    },
    [2] = {
        players = {
            {careerLine = GameData.CareerLine.WHITE_LION},
            {careerLine = GameData.CareerLine.SLAYER},
            {careerLine = GameData.CareerLine.WITCH_HUNTER},
            {careerLine = GameData.CareerLine.MARAUDER},
            {careerLine = GameData.CareerLine.CHOPPA},
            {careerLine = GameData.CareerLine.WITCH_ELF},

        },
    },
    [3] = {
        players = {
            {careerLine = GameData.CareerLine.BRIGHT_WIZARD},
            {careerLine = GameData.CareerLine.SHADOW_WARRIOR},
            {careerLine = GameData.CareerLine.ENGINEER},
            {careerLine = GameData.CareerLine.SORCERER},
            {careerLine = GameData.CareerLine.SQUIG_HERDER},
            {careerLine = GameData.CareerLine.MAGUS},
        },
    },
    [4] = {
        players = {
            {careerLine = GameData.CareerLine.WARRIOR_PRIEST},
            {careerLine = GameData.CareerLine.RUNE_PRIEST},
            {careerLine = GameData.CareerLine.ARCHMAGE},
            {careerLine = GameData.CareerLine.SHAMAN},
            {careerLine = GameData.CareerLine.DISCIPLE},
            {careerLine = GameData.CareerLine.ZEALOT},
        },
    },
}

local FULL_TRACKER_TEST_TEMPLATE = {
    challenge = {
        {careerLine = GameData.CareerLine.KNIGHT, timer = 30, cooldown = 30, duration = 7},
        {careerLine = GameData.CareerLine.SWORDMASTER, timer = 22, cooldown = 30, duration = 7},
        {careerLine = GameData.CareerLine.IRON_BREAKER, timer = 11, cooldown = 30, duration = 7},
        {careerLine = GameData.CareerLine.BLACKGUARD, timer = 0, cooldown = 30, duration = 7},
    },
    channels = {
        {careerLine = GameData.CareerLine.BRIGHT_WIZARD, timer = 8, cooldown = 8, duration = 3},
        {careerLine = GameData.CareerLine.WHITE_LION, timer = 13, cooldown = 13, duration = 3},
        {careerLine = GameData.CareerLine.MARAUDER, timer = 5, cooldown = 13, duration = 3},
        {careerLine = GameData.CareerLine.SLAYER, timer = 0, cooldown = 25, duration = 5},
    },
    interrupt = {
        {careerLine = GameData.CareerLine.MARAUDER, timer = 15, cooldown = 15, duration = 2},
        {careerLine = GameData.CareerLine.WHITE_LION, timer = 12, cooldown = 15, duration = 2},
        {careerLine = GameData.CareerLine.SWORDMASTER, timer = 7, cooldown = 15, duration = 2},
        {careerLine = GameData.CareerLine.BLACKGUARD, timer = 0, cooldown = 15, duration = 2},
    },
    LTC = {
        {careerLine = GameData.CareerLine.KNIGHT, timer = 120, cooldown = 120, duration = 10},
        {careerLine = GameData.CareerLine.CHOSEN, timer = 95, cooldown = 120, duration = 10},
		{careerLine = GameData.CareerLine.SWORDMASTER, timer = 40, cooldown = 120, duration = 4},
        {careerLine = GameData.CareerLine.BLACK_ORC, timer = 0, cooldown = 120, duration = 10},
        },
	ID = {
		{careerLine = GameData.CareerLine.BLACKGUARD, timer = 180, cooldown = 180, duration = 10},
		{careerLine = GameData.CareerLine.KNIGHT, timer = 140, cooldown = 180, duration = 10},
		{careerLine = GameData.CareerLine.CHOSEN, timer = 70, cooldown = 180, duration = 10},
		{careerLine = GameData.CareerLine.IRON_BREAKER, timer = 0, cooldown = 180, duration = 10},
    },
}

local CENTER_NOTIFICATION_TEST_TEMPLATE = {
    {careerLine = GameData.CareerLine.KNIGHT, label = "LTC"},
    {careerLine = GameData.CareerLine.CHOSEN, label = "LTC"},
    {careerLine = GameData.CareerLine.BLACKGUARD, label = "Immaculate Defense"},
    {careerLine = GameData.CareerLine.BLACK_ORC, label = "Immaculate Defense"},
}

local NAME_PREFIXES = {
    "Al", "Bar", "Cor", "Da", "El", "Fen", "Gar", "Hal", "Is", "Jar",
    "Kel", "Lor", "Mor", "Nor", "Or", "Prae", "Qua", "Ryn", "Sar", "Tor",
    "Ul", "Var", "Wyn", "Xan", "Yor", "Zel",
}

local NAME_MIDDLES = {
    "a", "e", "i", "o", "u", "ae", "ia", "or", "ar", "en", "un", "yr",
}

local NAME_SUFFIXES = {
    "dor", "grim", "ion", "or", "ar", "eth", "ric", "mir", "drin", "vex",
    "thas", "mund", "rak", "len", "wyn", "dred", "gorn", "ros", "dain", "vek",
}

local function HashString(value)
    local hash = 0
    for index = 1, string.len(value) do
        hash = (hash * 33 + string.byte(value, index)) % 2147483647
    end
    return hash
end

local function PickNamePart(parts, seed, salt)
    local index = ((seed + salt) % #parts) + 1
    return parts[index]
end

local function BuildGeneratedName(careerLine, ordinal)
    local playerName = tostring(WarbandComms.FixString(GameData.Player.name) or "Player")
    local seed = HashString(playerName) + (careerLine or 0) * 17 + testNameRun * 101 + (ordinal or 0) * 53

    local prefix = PickNamePart(NAME_PREFIXES, seed, 3)
    local middle = PickNamePart(NAME_MIDDLES, seed, 11)
    local suffix = PickNamePart(NAME_SUFFIXES, seed, 23)

    return prefix .. middle .. suffix
end

local function BuildGeneratedTestData()
    local generatedWarband = {}
    local generatedNamesByCareer = {}
    local usedNames = {}
    local ordinal = 0

    for partyIndex, party in ipairs(TEST_WARBAND_TEMPLATE) do
        generatedWarband[partyIndex] = { players = {} }
        for playerIndex, player in ipairs(party.players) do
            ordinal = ordinal + 1
            local generatedName = BuildGeneratedName(player.careerLine, ordinal)
            local duplicateIndex = 1

            while usedNames[generatedName] do
                duplicateIndex = duplicateIndex + 1
                generatedName = BuildGeneratedName(player.careerLine, ordinal + (duplicateIndex * 29))
            end

            usedNames[generatedName] = true
            generatedNamesByCareer[player.careerLine] = generatedName
            generatedWarband[partyIndex].players[playerIndex] = {
                name = generatedName,
                careerLine = player.careerLine,
            }
        end
    end

    return generatedWarband, generatedNamesByCareer
end

local function BuildTrackerTestData(generatedNamesByCareer)
    local trackerData = {}

    for trackerName, trackerEntries in pairs(FULL_TRACKER_TEST_TEMPLATE) do
        trackerData[trackerName] = {}
        for _, entry in ipairs(trackerEntries) do
            trackerData[trackerName][#trackerData[trackerName] + 1] = {
                name = generatedNamesByCareer[entry.careerLine],
                timer = entry.timer,
                cooldown = entry.cooldown,
                duration = entry.duration,
                careerLine = entry.careerLine,
            }
        end
    end

    return trackerData
end

local function BuildCenterNotificationTestData(generatedNamesByCareer)
    local notifications = {}

    for _, entry in ipairs(CENTER_NOTIFICATION_TEST_TEMPLATE) do
        notifications[#notifications + 1] = generatedNamesByCareer[entry.careerLine] .. " " .. entry.label
    end

    return notifications
end

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
    testNameRun = testNameRun + 1

    WarbandComms.ClearUI()
    ResetAllTrackerData()
    local generatedWarband, generatedNamesByCareer = BuildGeneratedTestData()
    local trackerTestData = BuildTrackerTestData(generatedNamesByCareer)

    WarbandComms.MapWarbandMembers(generatedWarband)

    for trackerName, trackerEntries in pairs(trackerTestData) do
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
    testNameRun = testNameRun + 1
    local _, generatedNamesByCareer = BuildGeneratedTestData()
    local centerNotificationTestData = BuildCenterNotificationTestData(generatedNamesByCareer)

    for _, textLine in ipairs(centerNotificationTestData) do
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


WarbandComms.TestQueue = {}
WarbandComms.testing = false

local testStep = 0

function WarbandComms.RunTestQueue()
    if testStep == 1 then
        local message = "/say " .. WarbandComms.commsKey .. ":challenge:7:30" --deliberate no career icon, backwards compatibility test
		SendChatText (towstring(message), L"")
        testStep = testStep + 1
    elseif testStep == 3 then
        WarbandComms.AddTestAbility("Mainline", "challenge", 30, 7, WarbandComms.CAREERS[GameData.CareerLine.KNIGHT].icon)
        testStep = testStep + 1
    elseif testStep == 6 then
        WarbandComms.AddTestAbility("Nevermind", "challenge", 30, 7, WarbandComms.CAREERS[GameData.CareerLine.SWORDMASTER].icon)
        WarbandComms.AddTestAbility("Wizard", "channels", 8, 3, WarbandComms.CAREERS[GameData.CareerLine.BRIGHT_WIZARD].icon)
        testStep = testStep + 1
    elseif testStep == 8 then
        WarbandComms.AddTestAbility("Enlil", "challenge", 30, 7, WarbandComms.CAREERS[GameData.CareerLine.SWORDMASTER].icon)
        testStep = testStep + 1
    elseif testStep == 10 then
        -- remove Nevermind from WarbandMap
        for i, member in pairs(WarbandComms.WarbandMap) do
            if member.name == "Nevermind" then
                table.remove(WarbandComms.WarbandMap, i)
                break
            end
        end
        testStep = testStep + 1
    elseif testStep == 13 then
        WarbandComms.AddTestAbility("Mainline", "LTC", 120, 10, WarbandComms.CAREERS[GameData.CareerLine.KNIGHT].icon)
        testStep = testStep + 1
    elseif testStep == 15 then
        WarbandComms.AddTestAbility("Wizard", "channels", 8, 3, WarbandComms.CAREERS[GameData.CareerLine.BRIGHT_WIZARD].icon)
        WarbandComms.AddTestAbility("Del", "channels", 13, 3, WarbandComms.CAREERS[GameData.CareerLine.WHITE_LION].icon)
        WarbandComms.AddTestAbility("Gaijin", "channels", 13, 3, WarbandComms.CAREERS[GameData.CareerLine.WHITE_LION].icon)
        WarbandComms.AddTestAbility("Knut", "channels", 25, 5, WarbandComms.CAREERS[GameData.CareerLine.SLAYER].icon)
        WarbandComms.AddTestAbility("Insia", "channels", 8, 3,    WarbandComms.CAREERS[GameData.CareerLine.BRIGHT_WIZARD].icon)
        WarbandComms.AddTestAbility("Xue", "channels", 30, 5,   WarbandComms.CAREERS[GameData.CareerLine.SLAYER].icon)
        WarbandComms.AddTestAbility("Garenn", "channels", 13, 3, WarbandComms.CAREERS[GameData.CareerLine.WHITE_LION].icon)
        WarbandComms.AddTestAbility("Kong", "channels", 13, 3, WarbandComms.CAREERS[GameData.CareerLine.BRIGHT_WIZARD].icon)
        testStep = testStep + 1
    elseif testStep > 30 then
        testStep = 0
        WarbandComms.testing = false
        WarbandComms.ClearUI()
        WarbandComms.WarbandMap = {}
    else
        testStep = testStep + 1
    end
end


function WarbandComms.StartTest()
    WarbandComms.testing = true
    testStep = 1

    local playerName = tostring(WarbandComms.FixString(GameData.Player.name))

--    WarbandComms.WarbandMap = {}

    local testband = {
        [1] = {
            players={
                --{name = playerName, careerLine = GameData.Player.careerLine},
                {name = "Mainline", careerLine = GameData.CareerLine.KNIGHT},
                {name = "Nevermind", careerLine = GameData.CareerLine.SWORDMASTER },
                {name = "Enlil", careerLine = GameData.CareerLine.SWORDMASTER },
            },
        },
        [2] = {
            players={
                {name = "Wizard", careerLine = GameData.CareerLine.BRIGHT_WIZARD },
                {name = "Del", careerLine = GameData.CareerLine.WHITE_LION },
                {name = "Gaijin", careerLine = GameData.CareerLine.WHITE_LION },
                {name = "Knut", careerLine = GameData.CareerLine.SLAYER },
            },
        },
        [3] = {
            players={
                {name = "Insia", careerLine = GameData.CareerLine.BRIGHT_WIZARD },
                {name = "Xue", careerLine = GameData.CareerLine.SLAYER },
                {name = "Garenn", careerLine = GameData.CareerLine.WHITE_LION },
                {name = "LavaLeet", careerLine = GameData.CareerLine.BRIGHT_WIZARD },
            },

        }
    }

    WarbandComms.MapWarbandMembers(testband)
end

function WarbandComms.AddTestAbility(name, ability, timer, duration, careerIcon)
    local testData = {
        ability = ability,
        name = name,
        timer = timer,
        cooldown = timer,
        duration = duration,
        careerIcon = careerIcon
    }

    WarbandComms.Trackers[ability][name] = testData

end


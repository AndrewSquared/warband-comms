local version = "4.0.0"

if not WarbandComms then WarbandComms = {} end

WarbandComms.AddonName = "WarbandComms"
local LTC_UI = WarbandComms.AddonName .. "LTC"
local CHALLENGE_UI = WarbandComms.AddonName .. "CHALLENGE"
local CHANNELING_UI = WarbandComms.AddonName .. "CHANNELS"
WarbandComms.configWindow = WarbandComms.AddonName .. "Config"
WarbandComms.InWarband = false
WarbandComms.selfTest = false

WarbandComms.EnqueueBattleGroupUpdate = false

WarbandComms.elapsed = 0
WarbandComms.friendlyTarget = nil
local throttle1 = 1.0;
local throttle2 = 0.25;
local lastUpdate = 0;

-- LUA locals for performance
local tostring = tostring
local towstring = towstring
local tonumber = tonumber

local tinsert = table.insert
local tremove = table.remove
local tsort = table.sort
local SendChatText = SendChatText
local max = math.max
local floor = math.floor
local next = next

local WarbandCommsWindow = "WarbandCommsWindow"

WarbandComms.Trackers = {}
WarbandComms.Notifications = {}
WarbandComms.Cooldowns = {}
WarbandComms.SendChatQueue = {}
WarbandComms.SendChatQueuedByAction = {}
WarbandComms.TrackerKeyByLower = {}
WarbandComms.suppressTrackerWindowSync = false

WarbandComms.ChatChannels = {
	[SystemData.ChatLogFilters.BATTLEGROUP] = true,
	[SystemData.ChatLogFilters.SAY] = false,
}

local MAX_CDR = 5 -- max cooldown reduction in seconds
local MIN_CD = 2.5 -- above GCD

WarbandComms.trackedAbilities = {
	[28301] = {name = "LTC", cooldown = 120, duration = 10, tracker= "LTC", nofify=true},
	[27044] = {name = "Into The Fray", cooldown = 120, duration = 4, tracker= "LTC", notify=true},
	-- Challenges for tanks
	[8021] = {name = "Challenge", cooldown = 30, duration=7, tracker= "challenge"}, --KOTBS
	[9013] = {name = "Challenge", cooldown = 30, duration=7, tracker= "challenge"}, --SM
	[1368] = {name = "Challenge", cooldown = 30, duration=7, tracker= "challenge"}, --IB
	[8333] = {name = "Challenge", cooldown = 30, duration=7, tracker= "challenge"}, --Chosen
	[1679] = {name = "Challenge", cooldown = 30, duration=7, tracker= "challenge"}, --BORC
	[9332] = {name = "Challenge", cooldown = 30, duration=7, tracker= "challenge"}, --BG
	-- DPS Channels
	[8187] = {name = "Annihilate", cooldown = 8, duration = 3, tracker= "channels"},
	[9188] = {name = "WhirlingAxe", cooldown = 13, duration = 3, tracker= "channels"},
	[1450] = {name = "Retribution", cooldown = 30, duration = 5, tracker= "channels"},
	[8425] = {name = "WreckingBall", cooldown = 13, duration = 3, tracker= "channels"},
	[1762] = {name = "BringItOn", cooldown = 30, duration = 5, tracker= "channels"},
	[9503] = {name = "DisastrousCascade", cooldown = 8, duration = 3, tracker= "channels"},
	-- Interrupts
	[9187] = {name = "EchoingRoar", cooldown = 15, duration = 2, tracker= "interrupt"}, -- WL
	[9032] = {name = "RedirectedForce", cooldown = 15, duration = 2, tracker= "interrupt"}, -- WL
	[8397] = {name = "MouthofTzeentch", cooldown = 15, duration = 2, tracker= "interrupt"}, -- Mara
	--
	--[610] = {name = "Bellow", cooldown = 60, duration = 10, tracker= "bellow", notify=true, fixedCooldown=true}, --
}

function WarbandComms.RefreshTrackerKeyIndex()
	local map = {}
	for trackerName, _ in pairs(WarbandComms.Trackers) do
		map[string.lower(trackerName)] = trackerName
	end
	WarbandComms.TrackerKeyByLower = map
end

function WarbandComms.ResolveTrackerName(trackerName)
	if not trackerName then return nil end
	if WarbandComms.Trackers[trackerName] ~= nil then
		return trackerName
	end

	return WarbandComms.TrackerKeyByLower[string.lower(trackerName)] or trackerName
end

function WarbandComms.IsTrackerVisible(trackerName)
	trackerName = WarbandComms.ResolveTrackerName(trackerName)
	return trackerName ~= nil
		and WarbandComms.Settings.enabled
		and WarbandComms.Settings[trackerName] == true
end

function WarbandComms.NormalizeTrackerSettingsKeys()
	for lowerName, trackerName in pairs(WarbandComms.TrackerKeyByLower) do
		if lowerName ~= trackerName and WarbandComms.Settings[lowerName] ~= nil then
			WarbandComms.Settings[trackerName] = WarbandComms.Settings[lowerName] == true
			WarbandComms.Settings[lowerName] = nil
		end

		if WarbandComms.Settings.notifications
			and lowerName ~= trackerName
			and WarbandComms.Settings.notifications[lowerName] ~= nil then
			WarbandComms.Settings.notifications[trackerName] = WarbandComms.Settings.notifications[lowerName] == true
			WarbandComms.Settings.notifications[lowerName] = nil
		end
	end
end

function WarbandComms.SetTrackerWindowVisibility(trackerName)
	trackerName = WarbandComms.ResolveTrackerName(trackerName)
	if not trackerName then return end

	local uiName = WarbandComms.AddonName .. trackerName:upper()
	WarbandComms.suppressTrackerWindowSync = true
	WindowSetShowing(uiName, WarbandComms.IsTrackerVisible(trackerName))
	WarbandComms.suppressTrackerWindowSync = false
end

function WarbandComms.OnInitialize()
	RegisterEventHandler(SystemData.Events.CHAT_TEXT_ARRIVED, "WarbandComms.TextArrived");
	RegisterEventHandler(SystemData.Events.PLAYER_BEGIN_CAST, "WarbandComms.OnCast")
	RegisterEventHandler(SystemData.Events.BATTLEGROUP_UPDATED, "WarbandComms.OnBattleGroupUpdated")
	RegisterEventHandler( SystemData.Events.GROUP_LEAVE, "WarbandComms.OnBattleGroupUpdated")

	if GameData.Player.realm == GameData.Realm.ORDER then
		WarbandComms.commsKey = "[RET]"
	elseif GameData.Player.realm == GameData.Realm.DESTRUCTION then
		WarbandComms.commsKey = "[DEVA]"
	end

	local defaultSettings = {
		enabled = true,
		LTC = true,
		challenge = true,
		channels = true,
		interrupt = true,
		bellow = true,
		version = version,
		showOnStartup = true,
		notifications = {
			LTC = true,
			bellow = true,
		}
	}

	if not WarbandComms.Settings or WarbandComms.Settings.version ~= version then
		WarbandComms.Settings = defaultSettings
	end

	for _, v in pairs(WarbandComms.trackedAbilities) do
		WarbandComms.Trackers[v.tracker] = {}
		if v.notify then
			WarbandComms.Notifications[v.tracker] = {}
		end
	end
	WarbandComms.RefreshTrackerKeyIndex()
	WarbandComms.NormalizeTrackerSettingsKeys()

	WarbandComms.InitConfig(version)
	WarbandComms.InitSlash()
	WarbandComms.InitAbilityCooldownHook()

	for trackerName, data in pairs(WarbandComms.Trackers) do
		WarbandComms.CreateUI(trackerName)
	end

	local careerId = GameData.Player.career.id
    local PlayerCareerLine = WarbandComms.CareerIdToLine[careerId]
    WarbandComms.PlayerCareer = WarbandComms.CAREERS[PlayerCareerLine]

	WarbandComms.MapWarbandMembers({})

	EA_ChatWindow.Print(towstring("<LINK data=\"0\" text=\"[".. WarbandComms.AddonName .. "]\" color=\"50,255,10\"> Loaded OK. Type /wbc for options."))
end

function WarbandComms.OnBattleGroupUpdated()
	WarbandComms.EnqueueBattleGroupUpdate = true

end

function WarbandComms.MapWarbandMembers(warband)
	if not warband then warband = PartyUtils.GetWarbandData() end
	local activeWB = IsWarBandActive()

	local warbandMap = {}
	local sortAdder = {
		[GameData.CareerLine.SLAYER] = 1000,
		[GameData.CareerLine.CHOPPA] = 1000,
		[GameData.CareerLine.WHITE_LION] = 100,
		[GameData.CareerLine.MARAUDER] = 100,
	}

	local index = 1

	for i, party in pairs(warband) do
		for j, member in pairs(party.players) do
			local name = tostring(WarbandComms.FixString(member.name))
			local careerLine = member.careerLine
			local sortAdd = sortAdder[careerLine] or 0
			local sortOrder = (25 - index) + sortAdd

			if name then
				tinsert(
					warbandMap,
					{
						name = name,
						index = index,
						careerLine = careerLine,
						sortOrder = sortOrder
					})
			end
			index = index + 1
		end
	end

	if index == 1 then
		-- for tesing, put yourself in the warband map
		warbandMap = {}
		local playerName = tostring(WarbandComms.FixString(GameData.Player.name))
		tinsert(warbandMap, {
			name = playerName,
			index = 1,
			careerLine = 1,
			sortOrder = 0,
		})
	end

	tsort(warbandMap, function(a, b)
		return a.sortOrder > b.sortOrder
	end)

	WarbandComms.WarbandMap = warbandMap

	if not WarbandComms.InWarband and activeWB then
		WarbandComms.ClearUI()
		WindowSetShowing(WarbandComms.configWindow, true)
		WarbandComms.InWarband = true
	end

	if not activeWB then
		WarbandComms.InWarband = false
	end
end

function WarbandComms.OnUpdate(elapsed)
    WarbandComms.elapsed = WarbandComms.elapsed + elapsed

	if not WarbandComms.Settings.enabled then return end

    -- Check and update chat messages every throttle2 (0.1s)
    if WarbandComms.elapsed - (WarbandComms.lastChatUpdate or 0) >= throttle2 then
        WarbandComms.lastChatUpdate = WarbandComms.elapsed

        if #WarbandComms.SendChatQueue > 0 then
            local chatData = WarbandComms.SendChatQueue[1]
            local cooldownData = WarbandComms.Cooldowns[chatData.actionId]

			-- HACK FOR MORALE ABILITIES THAT ARE NOT ON ACTION BAR
			if not cooldownData and chatData.fixed_cooldown then
				cooldownData = {
					maxCooldown = chatData.fixed_cooldown,
					mininimum_allowed_cooldown = chatData.fixed_cooldown,
				}
			end

			if cooldownData and cooldownData.maxCooldown then
				local ui_cooldown = cooldownData.maxCooldown
				local min_allowed_cooldown = chatData.mininimum_allowed_cooldown or 2.5
				local cooldown = max(ui_cooldown, min_allowed_cooldown)

				if cooldown > 2.5 then
					cooldown = floor(cooldown + 0.5)
					local careerIcon = WarbandComms.PlayerCareer.icon or ""
            		local message = chatData.message .. ":" .. tostring(cooldown or 0) .. ":" .. careerIcon
            		SendChatText(towstring(message), L"")
	            	tremove(WarbandComms.SendChatQueue, 1)
					WarbandComms.SendChatQueuedByAction[chatData.actionId] = nil
				end
			end
        end
    end

    -- Check and update UI/timers every throttle1 (1.0s)
    if WarbandComms.elapsed - (WarbandComms.lastUIUpdate or 0) >= throttle1 then
        WarbandComms.lastUIUpdate = WarbandComms.elapsed

		if WarbandComms.EnqueueBattleGroupUpdate then
			WarbandComms.MapWarbandMembers()
			WarbandComms.EnqueueBattleGroupUpdate = false
		end

        for trackerName, tracker in pairs(WarbandComms.Trackers) do
            for _, v in pairs(tracker) do
                if v.timer > 0 then
                    v.timer = v.timer - throttle1
                end
            end
            WarbandComms.UpdateUI(trackerName, tracker, 5)
        end

        if WarbandComms.testing then
            WarbandComms.RunTestQueue()
        end
    end
end


function WarbandComms.OnCast(actionId, isChannel, desiredCastTime, averageLatency)
	if averageLatency then return end -- stops double messages
	if not WarbandComms.Settings.enabled then return end

	local ability = WarbandComms.trackedAbilities[actionId]
	if not ability then return end

	local chatChannel
	if IsWarBandActive() then
		chatChannel = "/wb "
	elseif WarbandComms.selfTest then
		chatChannel = "/say "
	else
		return
	end

	local tracker = ability.tracker
	local enabled = WarbandComms.Settings[tracker]

	if enabled then
		local default_cooldown = ability.cooldown
		local fixed_cooldown = nil
		if ability.fixedCooldown then
			fixed_cooldown = default_cooldown
		end

		local duration = ability.duration
		local message = chatChannel .. WarbandComms.commsKey .. ":" .. tracker .. ":" .. duration

		local mininimum_allowed_cooldown = max(MIN_CD, default_cooldown - MAX_CDR)

		local chatData = {
			message = message,
			actionId = actionId,
			mininimum_allowed_cooldown = mininimum_allowed_cooldown,
			fixed_cooldown = fixed_cooldown,
		}
		if not WarbandComms.SendChatQueuedByAction[actionId] then
			WarbandComms.SendChatQueuedByAction[actionId] = true
			tinsert(WarbandComms.SendChatQueue, chatData)
		end
	end
end

function WarbandComms.TextArrived()
	if not WarbandComms.Settings.enabled then return end

	local chatData = GameData.ChatData
	local chatType = chatData.type
    if WarbandComms.ChatChannels[chatType] then
		local text = tostring(chatData.text)
		-- Expected: [key]:tracker:duration:cooldown[:careerIcon]
		local key, tracker, duration, cooldown, careerIcon = text:match("^(%b[]):([^:]+):(%d+):(%d+):?(.*)$")

		if key ~= WarbandComms.commsKey then return end
		careerIcon = careerIcon or ""

		local sender = tostring(chatData.name)

		if WarbandComms.Settings.notifications[tracker] then
  			AlertTextWindow.AddLine(SystemData.AlertText.Types.RVR, towstring(sender .. " " .. tracker))
		end

		local enabled = WarbandComms.Settings[tracker]
		if not enabled then return end

		local abilityData = {
			name = sender,
			timer = tonumber(cooldown),
			cooldown = tonumber(cooldown),
			duration = tonumber(duration),
			careerIcon = careerIcon
		}
		WarbandComms.Trackers[tracker][sender] = abilityData
    end
end
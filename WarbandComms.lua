local version = "3.6.0"

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
local min = math.min
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
WarbandComms.startupTrackerSelfHealPasses = 0
WarbandComms.DefaultTrackerWidth = 125
WarbandComms.DefaultTrackerHeight = 113

WarbandComms.ChatChannels = {
	[SystemData.ChatLogFilters.BATTLEGROUP] = true,
	[SystemData.ChatLogFilters.SAY] = false,
}

local MAX_CDR = 5 -- max cooldown reduction in seconds
local MIN_CD = 2.5 -- above GCD
local DEFAULT_COMMS_KEY = "[WBC]"
local LEGACY_ORDER_COMMS_KEY = "[RET]"
local LEGACY_DESTRO_COMMS_KEY = "[DEVA]"

WarbandComms.trackedAbilities = {
	[28301] = {name = "Leading the Charge", cooldown = 120, duration = 10, tracker= "LTC", notify=true},
	[27044] = {name = "Leading the Charge", cooldown = 120, duration = 4, tracker= "LTC", notify=true},
	[613] = {name = "Immaculate Defense", cooldown = 180, duration = 10, tracker= "ID", notify=true, fixedCooldown=true},
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

function WarbandComms.IsAcceptedCommsKey(key)
	if key == DEFAULT_COMMS_KEY then
		return true, false
	end

	if key == LEGACY_ORDER_COMMS_KEY or key == LEGACY_DESTRO_COMMS_KEY then
		return true, true
	end

	return false, false
end

function WarbandComms.GetLegacyRealmCommsKey()
	if GameData and GameData.Player and GameData.Player.realm == GameData.Realm.ORDER then
		return LEGACY_ORDER_COMMS_KEY
	end

	if GameData and GameData.Player and GameData.Player.realm == GameData.Realm.DESTRUCTION then
		return LEGACY_DESTRO_COMMS_KEY
	end

	return nil
end

function WarbandComms.GetOutboundCommsKey()
	local legacyRealmKey = WarbandComms.GetLegacyRealmCommsKey()
	if legacyRealmKey then
		return legacyRealmKey
	end

	return DEFAULT_COMMS_KEY
end

function WarbandComms.GetAcceptedCommsKeys()
	return {
		DEFAULT_COMMS_KEY,
		LEGACY_ORDER_COMMS_KEY,
		LEGACY_DESTRO_COMMS_KEY,
	}
end

function WarbandComms.GetAbilityNameFromTrackerPayload(tracker, duration, cooldown)
	local resolvedTracker = WarbandComms.ResolveTrackerName(tracker)
	local numericDuration = tonumber(duration)
	local numericCooldown = tonumber(cooldown)
	if not resolvedTracker or not numericDuration or not numericCooldown then
		return resolvedTracker or tracker
	end

	for _, ability in pairs(WarbandComms.trackedAbilities) do
		if ability.tracker == resolvedTracker
			and ability.duration == numericDuration
			and ability.cooldown == numericCooldown then
			return ability.name
		end
	end

	return resolvedTracker
end

function WarbandComms.PrintSelfCheck()
	local realmName = "Unknown"
	if GameData and GameData.Player and GameData.Player.realm == GameData.Realm.ORDER then
		realmName = "Order"
	elseif GameData and GameData.Player and GameData.Player.realm == GameData.Realm.DESTRUCTION then
		realmName = "Destruction"
	end

	local outbound = WarbandComms.commsKey or WarbandComms.GetOutboundCommsKey()
	local accepted = table.concat(WarbandComms.GetAcceptedCommsKeys(), ", ")
	local activeTrackers = 0
	local totalTrackers = 0
	for trackerName, _ in pairs(WarbandComms.Trackers) do
		totalTrackers = totalTrackers + 1
		if WarbandComms.Settings and WarbandComms.Settings[trackerName] == true then
			activeTrackers = activeTrackers + 1
		end
	end

	EA_ChatWindow.Print(towstring("[WarbandComms] Self-check"))
	EA_ChatWindow.Print(towstring("[WarbandComms] Realm: " .. realmName))
	EA_ChatWindow.Print(towstring("[WarbandComms] Outbound key: " .. tostring(outbound)))
	EA_ChatWindow.Print(towstring("[WarbandComms] Accepted inbound keys: " .. accepted))
	EA_ChatWindow.Print(towstring("[WarbandComms] Trackers enabled: " .. tostring(activeTrackers) .. "/" .. tostring(totalTrackers)))
	EA_ChatWindow.Print(towstring("[WarbandComms] selfTest: " .. tostring(WarbandComms.selfTest)))
end

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
		and WarbandComms.Settings[trackerName] == true
end

function WarbandComms.GetTrackerWindowName(trackerName)
	trackerName = WarbandComms.ResolveTrackerName(trackerName)
	if not trackerName then return nil end

	-- Use a dedicated prefix so stale per-window client settings from older
	-- versions cannot keep forcing trackers into broken phantom states.
	return WarbandComms.AddonName .. "Tracker" .. trackerName:upper()
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

	local uiName = WarbandComms.GetTrackerWindowName(trackerName)
	local isVisible = WarbandComms.IsTrackerVisible(trackerName)
	WarbandComms.suppressTrackerWindowSync = true
	WindowSetShowing(uiName, isVisible)
	if LayoutEditor and LayoutEditor.RegisterWindow then
		if LayoutEditor.UnregisterWindow then
			LayoutEditor.UnregisterWindow(uiName)
		end
		LayoutEditor.RegisterWindow(
			uiName,
			towstring(WarbandComms.AddonName .. trackerName),
			towstring(WarbandComms.AddonName),
			not isVisible,
			false,
			true,
			nil
		)
	end
	WarbandComms.suppressTrackerWindowSync = false
end

function WarbandComms.CleanupLegacyLayoutWindows()
	if not LayoutEditor or not LayoutEditor.UnregisterWindow then return end

	for trackerName, _ in pairs(WarbandComms.Trackers) do
		LayoutEditor.UnregisterWindow(WarbandComms.AddonName .. trackerName:upper())
	end

	-- Remove legacy typo registrations that can show as phantom white boxes.
	LayoutEditor.UnregisterWindow(WarbandComms.AddonName .. "INTERUPT")
	LayoutEditor.UnregisterWindow(WarbandComms.AddonName .. "interupt")
end

function WarbandComms.ClampTextScale(value)
	local numeric = tonumber(value) or 1.0
	return min(1.5, max(0.7, numeric))
end

function WarbandComms.GetHeaderTextScale()
	return WarbandComms.ClampTextScale(WarbandComms.Settings.headerTextScale)
end

function WarbandComms.GetRowTextScale()
	return WarbandComms.ClampTextScale(WarbandComms.Settings.rowTextScale)
end

function WarbandComms.ClampTrackerWidth(value)
	local numeric = tonumber(value) or WarbandComms.DefaultTrackerWidth
	return min(360, max(100, math.floor(numeric + 0.5)))
end

function WarbandComms.ClampTrackerHeight(value)
	local numeric = tonumber(value) or WarbandComms.DefaultTrackerHeight
	return min(320, max(80, math.floor(numeric + 0.5)))
end

function WarbandComms.GetTrackerWidth()
	return WarbandComms.ClampTrackerWidth(WarbandComms.Settings.trackerWidth)
end

function WarbandComms.GetTrackerHeight()
	return WarbandComms.ClampTrackerHeight(WarbandComms.Settings.trackerHeight)
end

function WarbandComms.GetSizeApplyMode()
	local mode = WarbandComms.Settings.sizeApplyMode
	if mode ~= "uniform" and mode ~= "relative" then
		mode = "relative"
	end
	return mode
end

function WarbandComms.ClampBackgroundAlpha(value)
	local numeric = tonumber(value) or 0.60
	return min(1.0, max(0.0, numeric))
end

function WarbandComms.GetBackgroundAlpha()
	return WarbandComms.ClampBackgroundAlpha(WarbandComms.Settings.backgroundAlpha)
end

function WarbandComms.GetHeaderTone()
	local tone = WarbandComms.Settings.headerTone
	if tone ~= "bright" and tone ~= "gold" and tone ~= "red" and tone ~= "green" and tone ~= "blue" then
		tone = "bright"
	end
	return tone
end

function WarbandComms.GetHeaderStyle()
	local style = WarbandComms.Settings.headerStyle
	if style == "strong" then
		style = "caps"
	elseif style ~= "clean" and style ~= "caps" then
		style = "clean"
	end
	return style
end

function WarbandComms.OnInitialize()
	RegisterEventHandler(SystemData.Events.CHAT_TEXT_ARRIVED, "WarbandComms.TextArrived");
	RegisterEventHandler(SystemData.Events.PLAYER_BEGIN_CAST, "WarbandComms.OnCast")
	RegisterEventHandler(SystemData.Events.BATTLEGROUP_UPDATED, "WarbandComms.OnBattleGroupUpdated")
	RegisterEventHandler( SystemData.Events.GROUP_LEAVE, "WarbandComms.OnBattleGroupUpdated")

	WarbandComms.commsKey = WarbandComms.GetOutboundCommsKey()

	local defaultSettings = {
		enabled = true,
		LTC = true,
		ID = true,
		challenge = true,
		channels = true,
		interrupt = true,
		bellow = true,
		headerTextScale = 1.0,
		rowTextScale = 1.0,
		trackerWidth = WarbandComms.DefaultTrackerWidth,
		trackerHeight = WarbandComms.DefaultTrackerHeight,
		sizeApplyMode = "relative",
		backgroundAlpha = 0.60,
		headerTone = "bright",
		headerStyle = "clean",
		version = version,
		showOnStartup = true,
		notifications = {
			LTC = true,
			ID = true,
			bellow = true,
		}
	}

	if not WarbandComms.Settings or WarbandComms.Settings.version ~= version then
		WarbandComms.Settings = defaultSettings
	end

	if WarbandComms.Settings.headerTextScale == nil then
		WarbandComms.Settings.headerTextScale = defaultSettings.headerTextScale
	end
	if WarbandComms.Settings.rowTextScale == nil then
		WarbandComms.Settings.rowTextScale = defaultSettings.rowTextScale
	end
	if WarbandComms.Settings.trackerWidth == nil then
		WarbandComms.Settings.trackerWidth = defaultSettings.trackerWidth
	end
	if WarbandComms.Settings.trackerHeight == nil then
		WarbandComms.Settings.trackerHeight = defaultSettings.trackerHeight
	end
	if WarbandComms.Settings.sizeApplyMode == nil then
		WarbandComms.Settings.sizeApplyMode = defaultSettings.sizeApplyMode
	end
	if WarbandComms.Settings.backgroundAlpha == nil then
		WarbandComms.Settings.backgroundAlpha = defaultSettings.backgroundAlpha
	end
	if WarbandComms.Settings.headerTone == nil then
		WarbandComms.Settings.headerTone = defaultSettings.headerTone
	end
	if WarbandComms.Settings.headerStyle == nil then
		WarbandComms.Settings.headerStyle = defaultSettings.headerStyle
	end
	WarbandComms.Settings.headerTextScale = WarbandComms.GetHeaderTextScale()
	WarbandComms.Settings.rowTextScale = WarbandComms.GetRowTextScale()
	WarbandComms.Settings.trackerWidth = WarbandComms.GetTrackerWidth()
	WarbandComms.Settings.trackerHeight = WarbandComms.GetTrackerHeight()
	WarbandComms.Settings.sizeApplyMode = WarbandComms.GetSizeApplyMode()
	WarbandComms.Settings.backgroundAlpha = WarbandComms.GetBackgroundAlpha()
	WarbandComms.Settings.headerTone = WarbandComms.GetHeaderTone()
	WarbandComms.Settings.headerStyle = WarbandComms.GetHeaderStyle()

	for _, v in pairs(WarbandComms.trackedAbilities) do
		WarbandComms.Trackers[v.tracker] = {}
		if v.notify then
			WarbandComms.Notifications[v.tracker] = {}
		end
	end
	if not WarbandComms.Settings.notifications then
		WarbandComms.Settings.notifications = defaultSettings.notifications
	end
	for trackerName, _ in pairs(WarbandComms.Trackers) do
		if WarbandComms.Settings[trackerName] == nil then
			WarbandComms.Settings[trackerName] = defaultSettings[trackerName] ~= false
		end
	end
	for trackerName, _ in pairs(WarbandComms.Notifications) do
		if WarbandComms.Settings.notifications[trackerName] == nil then
			WarbandComms.Settings.notifications[trackerName] = defaultSettings.notifications[trackerName] == true
		end
	end
	WarbandComms.RefreshTrackerKeyIndex()
	WarbandComms.NormalizeTrackerSettingsKeys()
	WarbandComms.CleanupLegacyLayoutWindows()

	WarbandComms.InitConfig(version)
	WarbandComms.InitSlash()
	WarbandComms.InitAbilityCooldownHook()

	for trackerName, data in pairs(WarbandComms.Trackers) do
		WarbandComms.CreateUI(trackerName)
	end
	WarbandComms.startupTrackerSelfHealPasses = 4

	local careerId = GameData.Player.career.id
    local PlayerCareerLine = WarbandComms.CareerIdToLine[careerId]
    WarbandComms.PlayerCareer = WarbandComms.CAREERS[PlayerCareerLine]

	WarbandComms.MapWarbandMembers({})

	EA_ChatWindow.Print(towstring("<LINK data=\"0\" text=\"[".. WarbandComms.AddonName .. "]\" color=\"50,255,10\"> Loaded OK. Type /wbc for options."))
	if WarbandComms.StartTest then
		EA_ChatWindow.Print(towstring("[WarbandComms] TEST BUILD ACTIVE: /wbc testboxes, /wbc testcenter, /wbc selftest"))
	end
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

					-- Some clients/channels do not echo our own outbound message back through CHAT_TEXT_ARRIVED.
					-- Mirror local cast state so self-casts are always visible in tracker rows.
					if chatData.tracker and WarbandComms.Trackers[chatData.tracker] then
						local localName = tostring(WarbandComms.FixString(GameData.Player.name))
						WarbandComms.Trackers[chatData.tracker][localName] = {
							name = localName,
							timer = cooldown,
							cooldown = cooldown,
							duration = chatData.duration,
							careerIcon = careerIcon,
						}
					end
	            	tremove(WarbandComms.SendChatQueue, 1)
					WarbandComms.SendChatQueuedByAction[chatData.actionId] = nil
				end
			end
        end
    end

    -- Check and update UI/timers every throttle1 (1.0s)
    if WarbandComms.elapsed - (WarbandComms.lastUIUpdate or 0) >= throttle1 then
        WarbandComms.lastUIUpdate = WarbandComms.elapsed

		if WarbandComms.startupTrackerSelfHealPasses and WarbandComms.startupTrackerSelfHealPasses > 0 then
			for trackerName, _ in pairs(WarbandComms.Trackers) do
				WarbandComms.NormalizeTrackerToLiveDimensions(trackerName)
				WarbandComms.ApplyTextScale(trackerName)
				WarbandComms.ApplyTrackerBackgroundAlpha(trackerName)
				WarbandComms.SetTrackerWindowVisibility(trackerName)
			end
			WarbandComms.startupTrackerSelfHealPasses = WarbandComms.startupTrackerSelfHealPasses - 1
		end

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
		local message = chatChannel .. WarbandComms.commsKey .. ":" .. tracker .. ":" .. tostring(duration)

		local mininimum_allowed_cooldown = max(MIN_CD, default_cooldown - MAX_CDR)

		local chatData = {
			message = message,
			actionId = actionId,
			tracker = tracker,
			duration = duration,
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
	local chatData = GameData.ChatData
	local chatType = chatData.type
    if WarbandComms.ChatChannels[chatType] then
		local text = tostring(chatData.text)
		-- Expected: [key]:tracker:duration:cooldown[:careerIcon]
		local key, tracker, duration, cooldown, careerIcon = text:match("^(%b[]):([^:]+):(%d+):(%d+):?(.*)$")
		local accepted = WarbandComms.IsAcceptedCommsKey(key)
		if not accepted then return end
		careerIcon = careerIcon or ""
		local resolvedTracker = WarbandComms.ResolveTrackerName(tracker)
		if not resolvedTracker then return end
		duration = tonumber(duration)
		cooldown = tonumber(cooldown)
		if not duration or not cooldown then return end
		local abilityName = WarbandComms.GetAbilityNameFromTrackerPayload(resolvedTracker, duration, cooldown)
		if not resolvedTracker or not duration or not cooldown then return end

		local sender = tostring(chatData.name)

		if WarbandComms.Settings.notifications[resolvedTracker] then
	 		AlertTextWindow.AddLine(SystemData.AlertText.Types.RVR, towstring(sender .. " " .. abilityName))
		end

		local enabled = WarbandComms.Settings[resolvedTracker]
		if not enabled then return end

		local abilityData = {
			name = sender,
			timer = cooldown,
			cooldown = cooldown,
			duration = duration,
			careerIcon = careerIcon
		}
		WarbandComms.Trackers[resolvedTracker][sender] = abilityData
    end
end
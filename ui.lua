
local function GetTrackerNameFromWindow(windowName)
	if not windowName then return nil end
	local trackerToken = string.match(windowName, "^" .. WarbandComms.AddonName .. "(.*)$")
	if not trackerToken then return nil end

	local trackerName = WarbandComms.ResolveTrackerName(trackerToken)
	if WarbandComms.Trackers[trackerName] == nil then
		return nil
	end

	return trackerName
end

local function SyncConfigButtonForTracker(trackerName, isEnabled)
	local buttonName = WarbandComms.AddonName .. "Config" .. trackerName:upper() .. "Button"
	ButtonSetPressedFlag(buttonName, isEnabled)
end

function WarbandComms.ApplyTextScale(tracker)
	local window = WarbandComms.AddonName .. tracker:upper()
	local headerScale = WarbandComms.GetHeaderTextScale()
	local rowScale = WarbandComms.GetRowTextScale()
	local windowTitle = window .. "Title"
	WindowSetScale(windowTitle, headerScale)

	local listWindow = window .. "ListRow"
	for i = 1, 12 do
		WindowSetScale(listWindow .. i .. "Name", rowScale)
		WindowSetScale(listWindow .. i .. "Timer", rowScale)
	end
end

function WarbandComms.OnTrackerWindowShown()
	if WarbandComms.suppressTrackerWindowSync then return end

	local trackerName = GetTrackerNameFromWindow(SystemData.ActiveWindow.name)
	if not trackerName then return end

	WarbandComms.Settings[trackerName] = true
	SyncConfigButtonForTracker(trackerName, true)
end

function WarbandComms.OnTrackerWindowHidden()
	if WarbandComms.suppressTrackerWindowSync then return end

	local trackerName = GetTrackerNameFromWindow(SystemData.ActiveWindow.name)
	if not trackerName then return end

	WarbandComms.Settings[trackerName] = false
	SyncConfigButtonForTracker(trackerName, false)
end

function WarbandComms.CreateUI(tracker)
	local window = WarbandComms.AddonName .. tracker:upper()

	CreateWindowFromTemplate (window, "WarbandCommsUITemplate", "Root")
	WarbandComms.SetTrackerWindowVisibility(tracker)
	WindowSetTintColor (window.."Background", 0, 0, 0)
	WindowSetAlpha (window.."Background", 0.60)
	WindowSetScale(window, 1.0)
	WindowSetDimensions(window, 125, 113) -- width, height


	local windowTitle = window .. "Title"
	local titleText = "-- " .. string.upper(tracker) .. " --"
	LabelSetText(windowTitle, towstring(titleText))
	LabelSetTextColor(windowTitle, 165, 165, 165)
	WarbandComms.ApplyTextScale(tracker)
end

function WarbandComms.UpdateUI(tracker, abilityList, nearlyReadyTime)
	local window = WarbandComms.AddonName .. tracker:upper()
    if not WindowGetShowing(window) then return end
	WarbandComms.ApplyTextScale(tracker)

	local listWindow = window .. "ListRow"
	local listIndex = 1
	for i, member in pairs(WarbandComms.WarbandMap) do
		local trackedMember = abilityList[member.name]
		if trackedMember then
			local listName = listWindow .. listIndex .. "Name"
			local listTimer = listWindow .. listIndex .. "Timer"
			local name = trackedMember.name
			local timer = trackedMember.timer
			local duration = trackedMember.duration
			local cooldown = trackedMember.cooldown
			local careerIcon = trackedMember.careerIcon or ""

			LabelSetText(listName, towstring(name))
			LabelSetText(listTimer, towstring(timer))
			LabelSetText(listWindow .. listIndex .. "Icon", towstring(careerIcon))

			if timer <= 0 then
				LabelSetText(listTimer, towstring(""))
				LabelSetTextColor(listName, 255, 255, 255)
			else
				if timer >= (cooldown - duration) then -- active
					LabelSetTextColor(listName, 92, 195, 0)
					LabelSetTextColor(listTimer, 92, 195, 0)
				elseif timer > nearlyReadyTime then -- on cooldown
					LabelSetTextColor(listTimer, 182, 135, 0)
					LabelSetTextColor(listName, 182, 135, 0)
				elseif timer >= 1 then -- nearly ready
					LabelSetTextColor(listTimer, 222, 222, 0)
					LabelSetTextColor(listName, 222, 222, 0)
				elseif timer < 1 then
					LabelSetTextColor(listTimer, 255, 255, 255)
					LabelSetTextColor(listName, 255, 255, 255)
				end
			end
			listIndex = listIndex + 1
		end
	end

	local maxListRows = 12
	for i = listIndex, maxListRows do
		local listName = listWindow .. i .. "Name"
		local listTimer = listWindow .. i .. "Timer"
		LabelSetText(listName, towstring(""))
		LabelSetText(listTimer, towstring(""))
		LabelSetText(listWindow .. i .. "Icon", towstring(""))
	end
end

function WarbandComms.ClearUI()
	WarbandComms.LTCList = {}
	WarbandComms.ChallengeList = {}
	WarbandComms.WhirlingAxeList = {}
	--WarbandComms.RetributionList = {}
	WarbandComms.ChannelList = {}
end

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

local TRACKER_TITLES = {
	LTC = "Leading the Charge",
	challenge = "Challenge",
	channels = "Channels",
	interrupt = "Interrupt",
}

local TRACKER_SHORT_TITLES = {
	LTC = { "LTC" },
	challenge = { "CHAL" },
	channels = { "CHNL" },
	interrupt = { "INT" },
}

local HEADER_TONES = {
	bright = { 225, 225, 225 },
	gold = { 244, 214, 96 },
	red = { 230, 90, 90 },
	green = { 92, 195, 0 },
	blue = { 90, 160, 235 },
}

local HEADER_STYLE_SCALE = {
	clean = 1.00,
	caps = 1.00,
}

local HEADER_TEXT_PAD = "  "

local function GetTrackerWindowWidth(window)
	local width = WarbandComms.GetTrackerWidth()
	if WindowGetDimensions then
		local currentWidth = WindowGetDimensions(window)
		if currentWidth and currentWidth > 0 then
			width = currentWidth
		end
	end
	return width
end

local function FitHeaderTextToTracker(tracker, title, requestedScale)
	local window = WarbandComms.AddonName .. tracker:upper()
	local width = GetTrackerWindowWidth(window)
	local clampedScale = math.max(0.7, math.min(1.8, requestedScale or 1.0))
	local usablePixels = math.max(24, width - 12)
	local avgCharPixels = math.max(1, 6 * clampedScale)
	local maxChars = math.max(4, math.floor(usablePixels / avgCharPixels))
	local paddedTitle = HEADER_TEXT_PAD .. title .. HEADER_TEXT_PAD
	if string.len(paddedTitle) <= maxChars then
		return title, clampedScale
	end

	local shortTitles = TRACKER_SHORT_TITLES[tracker] or {}
	for _, shortTitle in ipairs(shortTitles) do
		local paddedShortTitle = HEADER_TEXT_PAD .. shortTitle .. HEADER_TEXT_PAD
		if string.len(paddedShortTitle) <= maxChars then
			return shortTitle, clampedScale
		end
	end

	return shortTitles[#shortTitles] or title, clampedScale
end

local function FormatTrackerTitle(tracker)
	if TRACKER_TITLES[tracker] then
		return TRACKER_TITLES[tracker]
	end

	local title = tracker or ""
	title = string.gsub(title, "(%l)(%u)", "%1 %2")
	return string.gsub(title, "^%l", string.upper)
end

local function GetStyledTrackerTitle(tracker)
	local title = FormatTrackerTitle(tracker)
	local style = WarbandComms.GetHeaderStyle()
	if style == "caps" then
		return string.upper(title)
	end
	return title
end

function WarbandComms.ApplyTrackerHeaderAppearance(tracker)
	local window = WarbandComms.AddonName .. tracker:upper()
	local windowTitle = window .. "Title"
	local tone = HEADER_TONES[WarbandComms.GetHeaderTone()] or HEADER_TONES.bright
	local style = WarbandComms.GetHeaderStyle()
	local headerScale = WarbandComms.GetHeaderTextScale() * (HEADER_STYLE_SCALE[style] or 1.0)
	local fittedTitle, fittedScale = FitHeaderTextToTracker(tracker, GetStyledTrackerTitle(tracker), headerScale)
	local paddedTitle = HEADER_TEXT_PAD .. fittedTitle .. HEADER_TEXT_PAD

	LabelSetText(windowTitle, towstring(paddedTitle))
	LabelSetTextColor(windowTitle, tone[1], tone[2], tone[3])
	WindowSetScale(windowTitle, fittedScale)
end

local function GetTrackerRowMetrics(rowScale)
	local iconWidth = math.max(15, math.floor((15 * rowScale) + 0.5))
	local timerWidth = 28
	local nameOffset = iconWidth + 2

	return iconWidth, timerWidth, nameOffset
end

local function GetTrackerRowHeight(rowScale, iconWidth)
	local textHeight = math.floor((12 * rowScale) + 0.5)
	return math.max(12, iconWidth, textHeight)
end

local function FitNameToTrackerRow(tracker, name)
	local width = WarbandComms.GetTrackerWidth()
	local scale = WarbandComms.GetRowTextScale()
	local windowScale = 1.0

	local window = WarbandComms.AddonName .. tracker:upper()
	if WindowGetDimensions then
		local currentWidth = WindowGetDimensions(window)
		if currentWidth and currentWidth > 0 then
			width = currentWidth
		end
	end
	if WindowGetScale then
		local currentScale = WindowGetScale(window)
		if currentScale and currentScale > 0 then
			windowScale = currentScale
		end
	end

	if not name or name == "" then return "" end

	-- Match row layout math so text fitting stays consistent with live anchors/sizes.
	local _, timerWidth, nameOffset = GetTrackerRowMetrics(scale)
	local usablePixels = math.max(12, width - (nameOffset + timerWidth + 8))
	local avgCharPixels = math.max(1, 6 * scale * windowScale)
	local maxChars = math.max(4, math.floor(usablePixels / avgCharPixels))

	if string.len(name) <= maxChars then
		return name
	end

	if maxChars <= 3 then
		return string.sub(name, 1, maxChars)
	end

	return string.sub(name, 1, maxChars - 3) .. "..."
end

function WarbandComms.ApplyTextScale(tracker)
	local window = WarbandComms.AddonName .. tracker:upper()
	local rowScale = WarbandComms.GetRowTextScale()
	WarbandComms.ApplyTrackerHeaderAppearance(tracker)

	local listWindow = window .. "ListRow"
	for i = 1, 12 do
		WindowSetScale(listWindow .. i .. "Icon", rowScale)
		WindowSetScale(listWindow .. i .. "Name", rowScale)
		WindowSetScale(listWindow .. i .. "Timer", rowScale)
	end
end

function WarbandComms.ApplyTrackerInternalLayout(tracker)
	local window = WarbandComms.AddonName .. tracker:upper()
	local width = GetTrackerWindowWidth(window)

	local titleName = window .. "Title"
	WindowSetDimensions(titleName, math.max(40, width - 12), 20)

	local listName = window .. "List"
	local _, windowHeight = WindowGetDimensions(window)
	if windowHeight and windowHeight > 20 then
		WindowSetDimensions(listName, width, windowHeight - 15)
	end

	local rowBase = window .. "ListRow"
	local rowScale = WarbandComms.GetRowTextScale()
	local iconWidth, timerWidth, nameOffset = GetTrackerRowMetrics(rowScale)
	local rowHeight = GetTrackerRowHeight(rowScale, iconWidth)
	local iconYOffset = math.max(0, math.floor((rowHeight - iconWidth) / 2))
	local nameWidth = math.max(12, width - (nameOffset + timerWidth + 8))
	for i = 1, 12 do
		local rowName = rowBase .. i
		WindowSetDimensions(rowName, width, rowHeight)
		WindowSetDimensions(rowName .. "Icon", iconWidth, iconWidth)
		WindowClearAnchors(rowName .. "Icon")
		WindowAddAnchor(rowName .. "Icon", "topleft", rowName, "topleft", 1, iconYOffset)
		WindowSetDimensions(rowName .. "Name", nameWidth, rowHeight)
		WindowClearAnchors(rowName .. "Name")
		WindowAddAnchor(rowName .. "Name", "topleft", rowName, "topleft", nameOffset, 0)
		WindowSetDimensions(rowName .. "Timer", timerWidth, rowHeight)
		WindowClearAnchors(rowName .. "Timer")
		WindowAddAnchor(rowName .. "Timer", "topright", rowName, "topright", -2, 0)
	end
end

function WarbandComms.ApplyTrackerDimensions(tracker)
	local window = WarbandComms.AddonName .. tracker:upper()
	WindowSetDimensions(window, WarbandComms.GetTrackerWidth(), WarbandComms.GetTrackerHeight())
	WarbandComms.ApplyTrackerInternalLayout(tracker)
end

function WarbandComms.ApplyTrackerDimensionsUniform(tracker)
	local window = WarbandComms.AddonName .. tracker:upper()
	WindowSetScale(window, 1.0)
	WarbandComms.ApplyTrackerDimensions(tracker)
end

function WarbandComms.AdjustTrackerDimensionsRelative(tracker, deltaWidth, deltaHeight)
	local window = WarbandComms.AddonName .. tracker:upper()
	local currentWidth, currentHeight = WindowGetDimensions(window)
	if not currentWidth or currentWidth <= 0 then
		currentWidth = WarbandComms.GetTrackerWidth()
	end
	if not currentHeight or currentHeight <= 0 then
		currentHeight = WarbandComms.GetTrackerHeight()
	end

	local nextWidth = WarbandComms.ClampTrackerWidth(currentWidth + (deltaWidth or 0))
	local nextHeight = WarbandComms.ClampTrackerHeight(currentHeight + (deltaHeight or 0))
	WindowSetDimensions(window, nextWidth, nextHeight)
	WarbandComms.ApplyTrackerInternalLayout(tracker)
end

function WarbandComms.ApplyTrackerBackgroundAlpha(tracker)
	local window = WarbandComms.AddonName .. tracker:upper()
	WindowSetAlpha(window .. "Background", WarbandComms.GetBackgroundAlpha())
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
	WarbandComms.ApplyTrackerBackgroundAlpha(tracker)
	WindowSetScale(window, 1.0)
	WarbandComms.ApplyTrackerDimensions(tracker)
	WarbandComms.ApplyTextScale(tracker)
end

function WarbandComms.UpdateUI(tracker, abilityList, nearlyReadyTime)
	local window = WarbandComms.AddonName .. tracker:upper()
    if not WindowGetShowing(window) then return end
	WarbandComms.ApplyTrackerInternalLayout(tracker)
	WarbandComms.ApplyTextScale(tracker)

	local listWindow = window .. "ListRow"
	local listIndex = 1
	for i, member in pairs(WarbandComms.WarbandMap) do
		local trackedMember = abilityList[member.name]
		if trackedMember then
			local listName = listWindow .. listIndex .. "Name"
			local listTimer = listWindow .. listIndex .. "Timer"
			local name = trackedMember.name
			local displayName = FitNameToTrackerRow(tracker, name)
			local timer = trackedMember.timer
			local duration = trackedMember.duration
			local cooldown = trackedMember.cooldown
			local careerIcon = trackedMember.careerIcon or ""

			LabelSetText(listName, towstring(displayName))
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
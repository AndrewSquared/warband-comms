
local function GetTrackerNameFromWindow(windowName)
	if not windowName then return nil end
	local trackerToken = string.match(windowName, "^" .. WarbandComms.AddonName .. "Tracker(.*)$")
	if not trackerToken then
		trackerToken = string.match(windowName, "^" .. WarbandComms.AddonName .. "(.*)$")
	end
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
	ID = "Immaculate Defense",
	challenge = "Challenge",
	channels = "Channels",
	interrupt = "Interrupt",
}

local TRACKER_SHORT_TITLES = {
	LTC = { "LTC" },
	ID = { "ID" },
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
local READY_COLOR = { 92, 195, 0 }
local ACTIVE_COLOR = { 255, 255, 255 }
local COOLDOWN_COLOR = { 230, 90, 90 }
local HEADER_SEPARATOR_COLOR = { 175, 175, 175 }
local HEADER_SUMMARY_COUNT_WIDTH = 18
local HEADER_SUMMARY_SEPARATOR_WIDTH = 2
local HEADER_SUMMARY_RIGHT_PAD = 4
local HEADER_COMPACT_SHORT_TITLE_PIXELS = 88
-- Keep short titles visible across the clamped small-width range so headers
-- do not disappear prematurely during downward resize transitions.
local HEADER_COMPACT_HIDE_TITLE_PIXELS = 24
local ROW_ICON_TIMER_ONLY_WIDTH = 140
local ROW_ICON_LEFT_PAD = 4
local TRACKER_DIMENSION_CACHE = {}

local function GetTrackerCacheKey(tracker)
	return WarbandComms.ResolveTrackerName(tracker) or tracker
end

local function UpdateTrackerDimensionCache(tracker, width, height)
	TRACKER_DIMENSION_CACHE[GetTrackerCacheKey(tracker)] = {
		width = width,
		height = height,
	}
end

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
	local resolvedTracker = WarbandComms.ResolveTrackerName(tracker) or tracker
	local window = WarbandComms.GetTrackerWindowName(resolvedTracker)
	local width = GetTrackerWindowWidth(window)
	local clampedScale = math.max(0.7, math.min(1.8, requestedScale or 1.0))
	-- Always derive usable pixels from box width and summary block math.
	-- WindowGetDimensions on a label returns content/text width, not the
	-- constrained window width, so it cannot be trusted for space estimation.
	local summaryScale = math.min(clampedScale, 1.0)
	local summaryCountWidth = math.max(1, math.floor((HEADER_SUMMARY_COUNT_WIDTH * summaryScale) + 0.5))
	local summarySepWidth = math.max(1, math.floor((HEADER_SUMMARY_SEPARATOR_WIDTH * summaryScale) + 0.5))
	local summaryTotalWidth = (summaryCountWidth * 3) + (summarySepWidth * 2) + HEADER_SUMMARY_RIGHT_PAD + 4
	local usablePixels = math.max(24, width - 12 - summaryTotalWidth)
	local shortTitles = TRACKER_SHORT_TITLES[resolvedTracker] or TRACKER_SHORT_TITLES[string.lower(tostring(resolvedTracker))] or {}

	if usablePixels <= HEADER_COMPACT_HIDE_TITLE_PIXELS then
		return "", clampedScale
	end

	if usablePixels <= HEADER_COMPACT_SHORT_TITLE_PIXELS and #shortTitles > 0 then
		return shortTitles[1], clampedScale
	end

	local avgCharPixels = math.max(1, 6 * clampedScale)
	local maxChars = math.max(4, math.floor(usablePixels / avgCharPixels))
	local paddedTitle = HEADER_TEXT_PAD .. title .. HEADER_TEXT_PAD
	if string.len(paddedTitle) <= maxChars then
		return title, clampedScale
	end

	for _, shortTitle in ipairs(shortTitles) do
		local paddedShortTitle = HEADER_TEXT_PAD .. shortTitle .. HEADER_TEXT_PAD
		if string.len(paddedShortTitle) <= maxChars then
			return shortTitle, clampedScale
		end
	end

	return shortTitles[#shortTitles] or title, clampedScale
end

local function FormatTrackerTitle(tracker)
	local resolvedTracker = WarbandComms.ResolveTrackerName(tracker) or tracker
	if TRACKER_TITLES[resolvedTracker] then
		return TRACKER_TITLES[resolvedTracker]
	end

	local title = resolvedTracker or ""
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
	local window = WarbandComms.GetTrackerWindowName(tracker)
	local windowTitle = window .. "Title"
	local summaryReady = window .. "SummaryReady"
	local summaryActive = window .. "SummaryActive"
	local summaryCooldown = window .. "SummaryCooldown"
	local summarySep1 = window .. "SummarySep1"
	local summarySep2 = window .. "SummarySep2"
	local tone = HEADER_TONES[WarbandComms.GetHeaderTone()] or HEADER_TONES.bright
	local style = WarbandComms.GetHeaderStyle()
	local headerScale = WarbandComms.GetHeaderTextScale() * (HEADER_STYLE_SCALE[style] or 1.0)
	local fittedTitle, fittedScale = FitHeaderTextToTracker(tracker, GetStyledTrackerTitle(tracker), headerScale)
	local paddedTitle = HEADER_TEXT_PAD .. fittedTitle .. HEADER_TEXT_PAD

	LabelSetText(windowTitle, towstring(paddedTitle))
	LabelSetTextColor(windowTitle, tone[1], tone[2], tone[3])
	LabelSetTextColor(summaryReady, READY_COLOR[1], READY_COLOR[2], READY_COLOR[3])
	LabelSetTextColor(summaryActive, ACTIVE_COLOR[1], ACTIVE_COLOR[2], ACTIVE_COLOR[3])
	LabelSetTextColor(summaryCooldown, COOLDOWN_COLOR[1], COOLDOWN_COLOR[2], COOLDOWN_COLOR[3])
	LabelSetTextColor(summarySep1, HEADER_SEPARATOR_COLOR[1], HEADER_SEPARATOR_COLOR[2], HEADER_SEPARATOR_COLOR[3])
	LabelSetTextColor(summarySep2, HEADER_SEPARATOR_COLOR[1], HEADER_SEPARATOR_COLOR[2], HEADER_SEPARATOR_COLOR[3])
	WindowSetScale(windowTitle, fittedScale)
end

local function GetTrackerStateCounts(abilityList)
	local ready = 0
	local active = 0
	local cooldown = 0

	for _, member in pairs(WarbandComms.WarbandMap) do
		local trackedMember = abilityList[member.name]
		if trackedMember then
			if trackedMember.timer <= 0 then
				ready = ready + 1
			elseif trackedMember.timer >= (trackedMember.cooldown - trackedMember.duration) then
				active = active + 1
			else
				cooldown = cooldown + 1
			end
		end
	end

	return ready, active, cooldown
end

local function UpdateTrackerHeaderSummary(tracker, ready, active, cooldown)
	local window = WarbandComms.GetTrackerWindowName(tracker)
	LabelSetText(window .. "SummaryReady", towstring(tostring(ready or 0)))
	LabelSetText(window .. "SummaryActive", towstring(tostring(active or 0)))
	LabelSetText(window .. "SummaryCooldown", towstring(tostring(cooldown or 0)))
	LabelSetText(window .. "SummarySep1", L"")
	LabelSetText(window .. "SummarySep2", L"")
end

local function GetTrackerRowMetrics(rowScale)
	local iconWidth = math.max(15, math.floor((15 * rowScale) + 0.5))
	local timerWidth = 28
	local nameOffset = ROW_ICON_LEFT_PAD + iconWidth + 2

	return iconWidth, timerWidth, nameOffset
end

local function GetTrackerRowDisplayMode(windowWidth)
	if (windowWidth or 0) <= ROW_ICON_TIMER_ONLY_WIDTH then
		return "icon_timer_only"
	end

	return "normal"
end

local function GetTrackerRowHeight(rowScale, iconWidth)
	local textHeight = math.floor((12 * rowScale) + 0.5)
	return math.max(12, iconWidth, textHeight)
end

local function GetVisibleTrackerRowCount(tracker)
	local window = WarbandComms.GetTrackerWindowName(tracker)
	local _, windowHeight = WindowGetDimensions(window)
	local rowScale = WarbandComms.GetRowTextScale()
	local iconWidth = select(1, GetTrackerRowMetrics(rowScale))
	local rowHeight = math.max(1, GetTrackerRowHeight(rowScale, iconWidth))
	local usableListHeight = rowHeight

	if windowHeight and windowHeight > 15 then
		usableListHeight = math.max(rowHeight, windowHeight - 15)
	end

	local visibleRows = math.floor(usableListHeight / rowHeight)
	return math.max(1, math.min(12, visibleRows))
end

local function SyncTrackerDimensionsAndLayout(tracker, requestedWidth, requestedHeight)
	local window = WarbandComms.GetTrackerWindowName(tracker)
	local currentWidth, currentHeight = WindowGetDimensions(window)

	if not currentWidth or currentWidth <= 0 then
		currentWidth = WarbandComms.GetTrackerWidth()
	end
	if not currentHeight or currentHeight <= 0 then
		currentHeight = WarbandComms.GetTrackerHeight()
	end

	local targetWidth = WarbandComms.ClampTrackerWidth(requestedWidth or currentWidth)
	local targetHeight = WarbandComms.ClampTrackerHeight(requestedHeight or currentHeight)

	if currentWidth ~= targetWidth or currentHeight ~= targetHeight then
		WindowSetDimensions(window, targetWidth, targetHeight)
	end

	WarbandComms.ApplyTrackerInternalLayout(tracker)
	WarbandComms.ApplyTrackerHeaderAppearance(tracker)
	UpdateTrackerDimensionCache(tracker, targetWidth, targetHeight)

	return targetWidth, targetHeight
end

local function SyncTrackerLayoutIfDimensionsChangedExternally(tracker)
	local window = WarbandComms.GetTrackerWindowName(tracker)
	local currentWidth, currentHeight = WindowGetDimensions(window)
	if not currentWidth or currentWidth <= 0 or not currentHeight or currentHeight <= 0 then
		-- Some fresh characters can start with zero-sized saved windows until a
		-- manual resize occurs; force a sane first-pass size so trackers are usable.
		SyncTrackerDimensionsAndLayout(tracker, WarbandComms.GetTrackerWidth(), WarbandComms.GetTrackerHeight())
		return true
	end

	local cached = TRACKER_DIMENSION_CACHE[GetTrackerCacheKey(tracker)]
	if not cached then
		UpdateTrackerDimensionCache(tracker, currentWidth, currentHeight)
		return false
	end

	if cached.width == currentWidth and cached.height == currentHeight then
		return false
	end

	SyncTrackerDimensionsAndLayout(tracker, currentWidth, currentHeight)
	return true
end

local function FitNameToTrackerRow(tracker, name)
	local window = WarbandComms.GetTrackerWindowName(tracker)
	local width = GetTrackerWindowWidth(window)
	local scale = WarbandComms.GetRowTextScale()

	if not name or name == "" then return "" end

	if GetTrackerRowDisplayMode(width) == "icon_timer_only" then
		return ""
	end

	local _, timerWidth, nameOffset = GetTrackerRowMetrics(scale)
	local usablePixels = math.max(12, width - (nameOffset + timerWidth + 8))

	local avgCharPixels = math.max(1, 6 * scale)
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
	local window = WarbandComms.GetTrackerWindowName(tracker)
	local rowScale = WarbandComms.GetRowTextScale()
	-- Tracker sizing is controlled via explicit width/height settings; keep
	-- parent window scale normalized so stale saved scale values cannot shrink
	-- individual tracker windows into non-interactive phantom boxes.
	WindowSetScale(window, 1.0)
	WarbandComms.ApplyTrackerHeaderAppearance(tracker)
	WarbandComms.ApplyTrackerInternalLayout(tracker)

	local listWindow = window .. "ListRow"
	for i = 1, 12 do
		WindowSetScale(listWindow .. i .. "Icon", rowScale)
		WindowSetScale(listWindow .. i .. "Name", rowScale)
		WindowSetScale(listWindow .. i .. "Timer", rowScale)
	end
end

function WarbandComms.ApplyTrackerInternalLayout(tracker)
	local window = WarbandComms.GetTrackerWindowName(tracker)
	local width = GetTrackerWindowWidth(window)
	local rowScale = WarbandComms.GetRowTextScale()
	local rowMode = GetTrackerRowDisplayMode(width)
	-- Summary counters are tied to header scale, capped at 1.0 so they never
	-- grow beyond their base size regardless of header text scale setting.
	local headerScale = WarbandComms.GetHeaderTextScale()
	local summaryScale = math.min(headerScale, 1.0)
	local summaryCountWidth = math.max(1, math.floor((HEADER_SUMMARY_COUNT_WIDTH * summaryScale) + 0.5))
	local summarySepWidth = math.max(1, math.floor((HEADER_SUMMARY_SEPARATOR_WIDTH * summaryScale) + 0.5))
	local summaryTotalWidth = (summaryCountWidth * 3) + (summarySepWidth * 2) + HEADER_SUMMARY_RIGHT_PAD + 4

	WindowSetScale(window .. "SummaryReady", 1.0)
	WindowSetScale(window .. "SummaryActive", 1.0)
	WindowSetScale(window .. "SummaryCooldown", 1.0)
	WindowSetScale(window .. "SummarySep1", 1.0)
	WindowSetScale(window .. "SummarySep2", 1.0)

	local titleName = window .. "Title"
	WindowSetDimensions(titleName, math.max(40, width - 12 - summaryTotalWidth), 20)

	local summaryReady = window .. "SummaryReady"
	local summaryActive = window .. "SummaryActive"
	local summaryCooldown = window .. "SummaryCooldown"
	local summarySep1 = window .. "SummarySep1"
	local summarySep2 = window .. "SummarySep2"
	local headerY = 3
	-- Offsets from window topright, computed left-to-right from the right edge.
	-- Layout (right to left): [pad][cooldown][sep2][active][sep1][ready]
	local cdRight   = -HEADER_SUMMARY_RIGHT_PAD
	local sep2Right = cdRight   - summaryCountWidth
	local actRight  = sep2Right - summarySepWidth
	local sep1Right = actRight  - summaryCountWidth
	local rdyRight  = sep1Right - summarySepWidth
	WindowSetDimensions(summaryCooldown, summaryCountWidth, 20)
	WindowClearAnchors(summaryCooldown)
	WindowAddAnchor(summaryCooldown, "topright", window, "topright", cdRight, headerY)
	WindowSetDimensions(summarySep2, summarySepWidth, 20)
	WindowClearAnchors(summarySep2)
	WindowAddAnchor(summarySep2, "topright", window, "topright", sep2Right, headerY)
	WindowSetDimensions(summaryActive, summaryCountWidth, 20)
	WindowClearAnchors(summaryActive)
	WindowAddAnchor(summaryActive, "topright", window, "topright", actRight, headerY)
	WindowSetDimensions(summarySep1, summarySepWidth, 20)
	WindowClearAnchors(summarySep1)
	WindowAddAnchor(summarySep1, "topright", window, "topright", sep1Right, headerY)
	WindowSetDimensions(summaryReady, summaryCountWidth, 20)
	WindowClearAnchors(summaryReady)
	WindowAddAnchor(summaryReady, "topright", window, "topright", rdyRight, headerY)

	local listName = window .. "List"
	local _, windowHeight = WindowGetDimensions(window)
	if windowHeight and windowHeight > 20 then
		WindowSetDimensions(listName, width, windowHeight - 15)
	end

	local rowBase = window .. "ListRow"
	local iconWidth, timerWidth, nameOffset = GetTrackerRowMetrics(rowScale)
	local rowHeight = GetTrackerRowHeight(rowScale, iconWidth)
	local iconYOffset = math.max(0, math.floor((rowHeight - iconWidth) / 2))
	local nameWidth = math.max(12, width - (nameOffset + timerWidth + 8))
	if rowMode == "icon_timer_only" then
		nameWidth = 1
	end
	for i = 1, 12 do
		local rowName = rowBase .. i
		WindowSetDimensions(rowName, width, rowHeight)
		WindowSetDimensions(rowName .. "Icon", iconWidth, iconWidth)
		WindowClearAnchors(rowName .. "Icon")
		WindowAddAnchor(rowName .. "Icon", "topleft", rowName, "topleft", ROW_ICON_LEFT_PAD, iconYOffset)
		WindowSetDimensions(rowName .. "Name", nameWidth, rowHeight)
		WindowClearAnchors(rowName .. "Name")
		WindowAddAnchor(rowName .. "Name", "topleft", rowName, "topleft", nameOffset, 0)
		WindowSetDimensions(rowName .. "Timer", timerWidth, rowHeight)
		WindowClearAnchors(rowName .. "Timer")
		if rowMode == "icon_timer_only" then
			WindowAddAnchor(rowName .. "Timer", "topleft", rowName, "topleft", nameOffset + 1, 0)
		else
			WindowAddAnchor(rowName .. "Timer", "topright", rowName, "topright", -2, 0)
		end
	end
end

function WarbandComms.ApplyTrackerDimensions(tracker)
	SyncTrackerDimensionsAndLayout(tracker, WarbandComms.GetTrackerWidth(), WarbandComms.GetTrackerHeight())
end

function WarbandComms.ApplyTrackerDimensionsUniform(tracker)
	local window = WarbandComms.GetTrackerWindowName(tracker)
	WindowSetScale(window, 1.0)
	WarbandComms.ApplyTrackerDimensions(tracker)
end

-- Reads the tracker's live window dimensions and normalises them through
-- the clamp + layout pipeline, then updates the dimension cache.
-- Call this when an external source (e.g. LayoutEditor) may have changed
-- a window's size and the internal state needs to be brought in sync before
-- any subsequent relative adjustments are made.
function WarbandComms.NormalizeTrackerToLiveDimensions(tracker)
	local window = WarbandComms.GetTrackerWindowName(tracker)
	local liveWidth, liveHeight = WindowGetDimensions(window)
	if not liveWidth or liveWidth <= 0 then
		liveWidth = WarbandComms.GetTrackerWidth()
	end
	if not liveHeight or liveHeight <= 0 then
		liveHeight = WarbandComms.GetTrackerHeight()
	end
	SyncTrackerDimensionsAndLayout(tracker, liveWidth, liveHeight)
end

function WarbandComms.AdjustTrackerDimensionsRelative(tracker, deltaWidth, deltaHeight)
	local window = WarbandComms.GetTrackerWindowName(tracker)
	local currentWidth, currentHeight = WindowGetDimensions(window)
	if not currentWidth or currentWidth <= 0 then
		currentWidth = WarbandComms.GetTrackerWidth()
	end
	if not currentHeight or currentHeight <= 0 then
		currentHeight = WarbandComms.GetTrackerHeight()
	end

	local nextWidth = WarbandComms.ClampTrackerWidth(currentWidth + (deltaWidth or 0))
	local nextHeight = WarbandComms.ClampTrackerHeight(currentHeight + (deltaHeight or 0))
	SyncTrackerDimensionsAndLayout(tracker, nextWidth, nextHeight)
end

function WarbandComms.ApplyTrackerBackgroundAlpha(tracker)
	local window = WarbandComms.GetTrackerWindowName(tracker)
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
	local window = WarbandComms.GetTrackerWindowName(tracker)

	CreateWindowFromTemplate (window, "WarbandCommsUITemplate", "Root")
	WindowSetTintColor (window.."Background", 0, 0, 0)
	WarbandComms.ApplyTrackerBackgroundAlpha(tracker)
	WindowSetScale(window, 1.0)
	WarbandComms.ApplyTrackerDimensions(tracker)
	WarbandComms.ApplyTextScale(tracker)
	UpdateTrackerHeaderSummary(tracker, 0, 0, 0)
	WarbandComms.SetTrackerWindowVisibility(tracker)
end

function WarbandComms.UpdateUI(tracker, abilityList, nearlyReadyTime)
	local window = WarbandComms.GetTrackerWindowName(tracker)
    if not WindowGetShowing(window) then return end
	SyncTrackerLayoutIfDimensionsChangedExternally(tracker)
	WarbandComms.ApplyTextScale(tracker)
	local readyCount, activeCount, cooldownCount = GetTrackerStateCounts(abilityList)
	UpdateTrackerHeaderSummary(tracker, readyCount, activeCount, cooldownCount)

	local listWindow = window .. "ListRow"
	local listIndex = 1
	local maxVisibleRows = GetVisibleTrackerRowCount(tracker)
	for i, member in pairs(WarbandComms.WarbandMap) do
		local trackedMember = abilityList[member.name]
		if trackedMember then
			if listIndex > maxVisibleRows then
				break
			end

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
				LabelSetText(listTimer, towstring("0"))
				LabelSetTextColor(listName, 92, 195, 0)
				LabelSetTextColor(listTimer, 92, 195, 0)
			else
				if timer >= (cooldown - duration) then -- active
					LabelSetTextColor(listTimer, 255, 255, 255)
					LabelSetTextColor(listName, 255, 255, 255)
				else -- on cooldown
					LabelSetTextColor(listTimer, 230, 90, 90)
					LabelSetTextColor(listName, 230, 90, 90)
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
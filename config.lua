local configWindow = WarbandComms.AddonName .. "Config"

local HEADER_TONE_ORDER = { "bright", "gold", "red", "green", "blue" }
local HEADER_TONE_LABELS = {
	bright = L"Bright",
	gold = L"Gold",
	red = L"Red",
	green = L"Green",
	blue = L"Blue",
}

local HEADER_STYLE_ORDER = { "clean", "caps" }
local HEADER_STYLE_LABELS = {
	clean = L"Clean",
	caps = L"Caps",
}

local function IsTrackerVisible(trackerName)
	return WarbandComms.IsTrackerVisible(trackerName)
end

local function ApplyTrackerVisibility(trackerName)
	WarbandComms.SetTrackerWindowVisibility(trackerName)
end

local function FormatPercentLabel(scale)
	return towstring(tostring(math.floor((scale * 100) + 0.5)) .. "%")
end

local function RefreshTextScaleLabels()
	LabelSetText(configWindow .. "HeaderTextSizeValue", FormatPercentLabel(WarbandComms.GetHeaderTextScale()))
	LabelSetText(configWindow .. "RowTextSizeValue", FormatPercentLabel(WarbandComms.GetRowTextScale()))
end

local function RefreshSizeLabels()
	local width = WarbandComms.GetTrackerWidth()
	local height = WarbandComms.GetTrackerHeight()
	if WarbandComms.GetSizeApplyMode() == "relative" then
		local widthDelta = width - WarbandComms.DefaultTrackerWidth
		local heightDelta = height - WarbandComms.DefaultTrackerHeight
		LabelSetText(configWindow .. "TrackerWidthValue", towstring(string.format("%+d", widthDelta)))
		LabelSetText(configWindow .. "TrackerHeightValue", towstring(string.format("%+d", heightDelta)))
	else
		LabelSetText(configWindow .. "TrackerWidthValue", towstring(tostring(width)))
		LabelSetText(configWindow .. "TrackerHeightValue", towstring(tostring(height)))
	end
end

local function RefreshSizeModeLabel()
	local mode = WarbandComms.GetSizeApplyMode()
	if mode == "uniform" then
		LabelSetText(configWindow .. "SizeApplyModeButtonValue", L"Uniform")
	else
		LabelSetText(configWindow .. "SizeApplyModeButtonValue", L"Relative")
	end
	RefreshSizeLabels()
end

local function RefreshBackgroundAlphaLabel()
	local percent = math.floor((WarbandComms.GetBackgroundAlpha() * 100) + 0.5)
	LabelSetText(configWindow .. "BackgroundOpacityValue", towstring(tostring(percent) .. "%"))
end

local function RefreshHeaderEmphasisLabels()
	LabelSetText(configWindow .. "HeaderToneButtonValue", HEADER_TONE_LABELS[WarbandComms.GetHeaderTone()] or L"Bright")
	LabelSetText(configWindow .. "HeaderStyleButtonValue", HEADER_STYLE_LABELS[WarbandComms.GetHeaderStyle()] or L"Clean")
end

local function GetNextPresetValue(order, currentValue)
	for index, value in ipairs(order) do
		if value == currentValue then
			return order[(index % #order) + 1]
		end
	end
	return order[1]
end

local function ApplyTextScaleToAllTrackers()
	for trackerName, _ in pairs(WarbandComms.Trackers) do
		WarbandComms.ApplyTextScale(trackerName)
	end
end

local function ApplyTrackerSizeToAllTrackers()
	for trackerName, _ in pairs(WarbandComms.Trackers) do
		if WarbandComms.GetSizeApplyMode() == "uniform" then
			WarbandComms.ApplyTrackerDimensionsUniform(trackerName)
		else
			WarbandComms.ApplyTrackerDimensions(trackerName)
		end
	end
end

local function ApplyTrackerSizeDeltaToAllTrackers(deltaWidth, deltaHeight)
	for trackerName, _ in pairs(WarbandComms.Trackers) do
		WarbandComms.AdjustTrackerDimensionsRelative(trackerName, deltaWidth, deltaHeight)
	end
end

local function ApplyBackgroundAlphaToAllTrackers()
	for trackerName, _ in pairs(WarbandComms.Trackers) do
		WarbandComms.ApplyTrackerBackgroundAlpha(trackerName)
	end
end

function WarbandComms.InitConfig(version)
    local configWindow = WarbandComms.AddonName .. "Config"
    WarbandComms.configWindow = configWindow -- so OnClose has the exact name

    -- Config Window
	CreateWindow(configWindow, true)
	WindowSetShowing(configWindow, WarbandComms.Settings.showOnStartup)

	LabelSetText(configWindow .. "TitleBarText", towstring(WarbandComms.AddonName .. " v" .. version))
	LabelSetText(configWindow .. "InfoLabel", L"Type /wbc to see this again.")

	LabelSetText(configWindow .. "TrackerTitle", L"Cooldown Trackers")
	local enabled = WarbandComms.Settings.enabled
	ButtonSetPressedFlag("WarbandCommsConfigEnableTrackersButton", enabled)

	LabelSetText(configWindow .. "NotificationsTitle", L"Center Screen Notifications")
	LabelSetText(configWindow .. "HeaderTextSizeLabel", L"Header Text")
	LabelSetText(configWindow .. "RowTextSizeLabel", L"Row Text")
	LabelSetText(configWindow .. "HeaderTextSizeDecreaseButtonLabel", L"-")
	LabelSetText(configWindow .. "HeaderTextSizeIncreaseButtonLabel", L"+")
	LabelSetText(configWindow .. "RowTextSizeDecreaseButtonLabel", L"-")
	LabelSetText(configWindow .. "RowTextSizeIncreaseButtonLabel", L"+")
	LabelSetText(configWindow .. "TrackerWidthLabel", L"Box Width")
	LabelSetText(configWindow .. "TrackerHeightLabel", L"Box Height")
	LabelSetText(configWindow .. "TrackerWidthDecreaseButtonLabel", L"-")
	LabelSetText(configWindow .. "TrackerWidthIncreaseButtonLabel", L"+")
	LabelSetText(configWindow .. "TrackerHeightDecreaseButtonLabel", L"-")
	LabelSetText(configWindow .. "TrackerHeightIncreaseButtonLabel", L"+")
	LabelSetText(configWindow .. "SizeApplyModeLabel", L"Resize Mode")
	LabelSetText(configWindow .. "BackgroundOpacityLabel", L"Background")
	LabelSetText(configWindow .. "HeaderToneLabel", L"Header Tone")
	LabelSetText(configWindow .. "HeaderStyleLabel", L"Header Style")
	LabelSetText(configWindow .. "BackgroundOpacityDecreaseButtonLabel", L"-")
	LabelSetText(configWindow .. "BackgroundOpacityIncreaseButtonLabel", L"+")
	RefreshTextScaleLabels()
	RefreshSizeLabels()
	RefreshSizeModeLabel()
	RefreshBackgroundAlphaLabel()
	RefreshHeaderEmphasisLabels()

	-- Dynamically add trackers
	local tracker_index = 0
	for trackerName, _ in pairs(WarbandComms.Trackers) do
		local window = configWindow .. trackerName:upper()

		CreateWindowFromTemplate(window, "WarbandCommsConfigTemplate", configWindow)
		WindowSetShowing(window, true)
		WindowSetDimensions(window, 300, 24) -- a tidy row height

		WindowClearAnchors(window)
        -- place rows under the header controls
		WindowAddAnchor(window, "topleft", configWindow, "topleft", 20, 250 + (tracker_index * 40))
		tracker_index = tracker_index + 1

		local buttonName = window .. "Button"
		local labelName  = window .. "Label"

		LabelSetText(labelName, towstring(trackerName:sub(1,1):upper() .. trackerName:sub(2)))
		ButtonSetPressedFlag(buttonName, WarbandComms.Settings[trackerName] == true)

		local enabled = WarbandComms.Settings.enabled
		if enabled then
			LabelSetTextColor(labelName, 255, 255, 255)
		else
			LabelSetTextColor(labelName, 108, 108, 108)
		end
	end

	-- dynamically add notifications
	local notification_index = 0
	for trackerName, _ in pairs(WarbandComms.Notifications) do
		local window = configWindow .. trackerName:upper() .. "NOTIFY"

		CreateWindowFromTemplate(window, "WarbandCommsConfigTemplate", configWindow)
		WindowSetShowing(window, true)
		WindowSetDimensions(window, 300, 24) -- a tidy row height

		WindowClearAnchors(window)
		-- place rows under the header controls
		WindowAddAnchor(window, "topleft", configWindow, "topleft", 350, 250 + (notification_index * 40))
		notification_index = notification_index + 1

		local buttonName = window .. "Button"
		local labelName  = window .. "Label"

		LabelSetText(labelName, towstring(trackerName:sub(1,1):upper() .. trackerName:sub(2)))
		ButtonSetPressedFlag(buttonName, WarbandComms.Settings.notifications[trackerName] == true)

		local enabled = WarbandComms.Settings.notifications[trackerName] == true
		if enabled then
			LabelSetTextColor(labelName, 255, 255, 255)
		else
			LabelSetTextColor(labelName, 108, 108, 108)
		end
	end
	-- Resize config window to fit all trackers
	WindowSetDimensions(configWindow, 700, 300 + (tracker_index * 50))
end

function WarbandComms.ChangeHeaderTextSize(delta)
	WarbandComms.Settings.headerTextScale = WarbandComms.ClampTextScale(WarbandComms.GetHeaderTextScale() + delta)
	RefreshTextScaleLabels()
	ApplyTextScaleToAllTrackers()
end

function WarbandComms.ChangeRowTextSize(delta)
	WarbandComms.Settings.rowTextScale = WarbandComms.ClampTextScale(WarbandComms.GetRowTextScale() + delta)
	RefreshTextScaleLabels()
	ApplyTextScaleToAllTrackers()
end

function WarbandComms.DecreaseHeaderTextSize()
	WarbandComms.ChangeHeaderTextSize(-0.1)
end

function WarbandComms.IncreaseHeaderTextSize()
	WarbandComms.ChangeHeaderTextSize(0.1)
end

function WarbandComms.DecreaseRowTextSize()
	WarbandComms.ChangeRowTextSize(-0.1)
end

function WarbandComms.IncreaseRowTextSize()
	WarbandComms.ChangeRowTextSize(0.1)
end

function WarbandComms.ToggleHeaderTone()
	WarbandComms.Settings.headerTone = GetNextPresetValue(HEADER_TONE_ORDER, WarbandComms.GetHeaderTone())
	RefreshHeaderEmphasisLabels()
	ApplyTextScaleToAllTrackers()
end

function WarbandComms.ToggleHeaderStyle()
	WarbandComms.Settings.headerStyle = GetNextPresetValue(HEADER_STYLE_ORDER, WarbandComms.GetHeaderStyle())
	RefreshHeaderEmphasisLabels()
	ApplyTextScaleToAllTrackers()
end

function WarbandComms.ChangeTrackerWidth(delta)
	WarbandComms.Settings.trackerWidth = WarbandComms.ClampTrackerWidth(WarbandComms.GetTrackerWidth() + delta)
	RefreshSizeLabels()
	if WarbandComms.GetSizeApplyMode() == "uniform" then
		ApplyTrackerSizeToAllTrackers()
	else
		ApplyTrackerSizeDeltaToAllTrackers(delta, 0)
	end
end

function WarbandComms.ChangeTrackerHeight(delta)
	WarbandComms.Settings.trackerHeight = WarbandComms.ClampTrackerHeight(WarbandComms.GetTrackerHeight() + delta)
	RefreshSizeLabels()
	if WarbandComms.GetSizeApplyMode() == "uniform" then
		ApplyTrackerSizeToAllTrackers()
	else
		ApplyTrackerSizeDeltaToAllTrackers(0, delta)
	end
end

function WarbandComms.DecreaseTrackerWidth()
	WarbandComms.ChangeTrackerWidth(-10)
end

function WarbandComms.IncreaseTrackerWidth()
	WarbandComms.ChangeTrackerWidth(10)
end

function WarbandComms.DecreaseTrackerHeight()
	WarbandComms.ChangeTrackerHeight(-10)
end

function WarbandComms.IncreaseTrackerHeight()
	WarbandComms.ChangeTrackerHeight(10)
end

function WarbandComms.ToggleSizeApplyMode()
	if WarbandComms.GetSizeApplyMode() == "uniform" then
		WarbandComms.Settings.sizeApplyMode = "relative"
		EA_ChatWindow.Print(L"[WarbandComms] Resize Mode: Relative (preserve per-tracker size differences)")
	else
		WarbandComms.Settings.sizeApplyMode = "uniform"
		ApplyTrackerSizeToAllTrackers()
		EA_ChatWindow.Print(L"[WarbandComms] Resize Mode: Uniform (normalize all tracker sizes)")
	end
	RefreshSizeModeLabel()
end

function WarbandComms.ChangeBackgroundOpacity(delta)
	WarbandComms.Settings.backgroundAlpha = WarbandComms.ClampBackgroundAlpha(WarbandComms.GetBackgroundAlpha() + delta)
	RefreshBackgroundAlphaLabel()
	ApplyBackgroundAlphaToAllTrackers()
end

function WarbandComms.DecreaseBackgroundOpacity()
	WarbandComms.ChangeBackgroundOpacity(-0.05)
end

function WarbandComms.IncreaseBackgroundOpacity()
	WarbandComms.ChangeBackgroundOpacity(0.05)
end

function WarbandComms.ToggleAllTrackers()
	local enabled = WarbandComms.Settings.enabled
	enabled = not enabled

	WarbandComms.Settings.enabled = enabled
	ButtonSetPressedFlag("WarbandCommsConfigEnableTrackersButton", enabled)

	for trackerName, _ in pairs(WarbandComms.Trackers) do
		local labelName = WarbandComms.AddonName .. "Config" .. trackerName:upper() .. "Label"
		-- set white or dark grey if enabled/disabled
		if enabled then
			LabelSetTextColor(labelName, 255, 255, 255)
		else
			LabelSetTextColor(labelName, 108, 108, 108)
		end
		ApplyTrackerVisibility(trackerName)
	end
end

function WarbandComms.OnClose()
	WindowSetShowing(WarbandComms.configWindow, false)
	WarbandComms.Settings.showOnStartup = false
end

function WarbandComms.ToggleLTCNotifications()
	WarbandComms.Settings.ltcNotifications = not WarbandComms.Settings.ltcNotifications
	ButtonSetPressedFlag("WarbandCommsConfigLTCNotificationsButton", WarbandComms.Settings.ltcNotifications)
end

function WarbandComms.ToggleTracker()
	local activeWindowName = SystemData.ActiveWindow.name
	local trackerName = string.match(activeWindowName, WarbandComms.AddonName .. "Config(.*)Button")
	if not trackerName then return end

	local notify_button = string.match(activeWindowName, WarbandComms.AddonName .. "Config(.*)NOTIFYButton")
	if notify_button then
		trackerName = WarbandComms.ResolveTrackerName(string.gsub(trackerName, "NOTIFY", ""))
		if not trackerName then return end
		WarbandComms.Settings.notifications[trackerName] = not WarbandComms.Settings.notifications[trackerName]
		ButtonSetPressedFlag(activeWindowName, WarbandComms.Settings.notifications[trackerName])
		return
	end

	trackerName = WarbandComms.ResolveTrackerName(trackerName)
	if not trackerName then return end

	WarbandComms.Settings[trackerName] = not WarbandComms.Settings[trackerName]
	ButtonSetPressedFlag(activeWindowName, WarbandComms.Settings[trackerName])

	ApplyTrackerVisibility(trackerName)
end
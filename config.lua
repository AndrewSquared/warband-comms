local configWindow = WarbandComms.AddonName .. "Config"

local LAYOUT = {
	leftColumnX = 20,
	rightColumnX = 350,
	trackerRowsStartY = 252,
	notificationRowsStartY = 224,
	dynamicRowSpacingY = 34,
	baseWindowHeight = 300,
	windowWidth = 700,
}

local COLORS = {
	enabledText = { 255, 255, 255 },
	disabledText = { 108, 108, 108 },
	softSetting = { 198, 198, 198 },
	valueGold = { 244, 214, 96 },
}

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

local TRACKER_ROW_ORDER = { "LTC", "ID", "challenge", "channels", "interrupt" }
local TRACKER_LABELS = {
	LTC = L"Leading the Charge",
	ID = L"Immaculate Defense",
	challenge = L"Challenge",
	channels = L"Channels",
	interrupt = L"Interrupt",
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

local function GetTrackerLabel(trackerName)
	return TRACKER_LABELS[trackerName] or towstring(trackerName:sub(1,1):upper() .. trackerName:sub(2))
end

local function GetOrderedTrackerNames(sourceTable)
	local names = {}
	local seen = {}

	for _, trackerName in ipairs(TRACKER_ROW_ORDER) do
		if sourceTable[trackerName] ~= nil then
			names[#names + 1] = trackerName
			seen[trackerName] = true
		end
	end

	for trackerName, _ in pairs(sourceTable) do
		if not seen[trackerName] then
			names[#names + 1] = trackerName
		end
	end

	table.sort(names, function(left, right)
		local leftKnown = TRACKER_LABELS[left] ~= nil
		local rightKnown = TRACKER_LABELS[right] ~= nil
		if leftKnown ~= rightKnown then
			return leftKnown
		end
		return string.lower(left) < string.lower(right)
	end)

	for index = #TRACKER_ROW_ORDER, 1, -1 do
		local trackerName = TRACKER_ROW_ORDER[index]
		if sourceTable[trackerName] ~= nil then
			for nameIndex = #names, 1, -1 do
				if names[nameIndex] == trackerName then
					table.remove(names, nameIndex)
					break
				end
			end
			table.insert(names, index, trackerName)
		end
	end

	return names
end

local function RefreshTextScaleLabels()
	LabelSetText(configWindow .. "HeaderTextSizeValueText", FormatPercentLabel(WarbandComms.GetHeaderTextScale()))
	LabelSetText(configWindow .. "RowTextSizeValueText", FormatPercentLabel(WarbandComms.GetRowTextScale()))
end

local function RefreshSizeLabels()
	local width = WarbandComms.GetTrackerWidth()
	local height = WarbandComms.GetTrackerHeight()
	if WarbandComms.GetSizeApplyMode() == "relative" then
		local widthDelta = width - WarbandComms.DefaultTrackerWidth
		local heightDelta = height - WarbandComms.DefaultTrackerHeight
		LabelSetText(configWindow .. "TrackerWidthValueText", towstring(string.format("%+d", widthDelta)))
		LabelSetText(configWindow .. "TrackerHeightValueText", towstring(string.format("%+d", heightDelta)))
	else
		LabelSetText(configWindow .. "TrackerWidthValueText", towstring(tostring(width)))
		LabelSetText(configWindow .. "TrackerHeightValueText", towstring(tostring(height)))
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
	LabelSetText(configWindow .. "BackgroundOpacityValueText", towstring(tostring(percent) .. "%"))
end

local function SetEnabledLabelColor(labelName, isEnabled)
	if isEnabled then
		LabelSetTextColor(labelName, COLORS.enabledText[1], COLORS.enabledText[2], COLORS.enabledText[3])
	else
		LabelSetTextColor(labelName, COLORS.disabledText[1], COLORS.disabledText[2], COLORS.disabledText[3])
	end
end

local function AreAllTrackersEnabled()
	for trackerName, _ in pairs(WarbandComms.Trackers) do
		if WarbandComms.Settings[trackerName] ~= true then
			return false
		end
	end
	return true
end

-- Shared UI primitives for future controls (checkboxes, dropdowns, inputs).
function WarbandComms.UIEnsureCheckboxState(buttonName, settingState)
	if not buttonName or not DoesWindowExist(buttonName) then return end
	ButtonSetStayDownFlag(buttonName, true)
	ButtonSetPressedFlag(buttonName, settingState == true)
end

function WarbandComms.UIResolveCheckboxToggle(buttonName, settingState)
	if not buttonName or not DoesWindowExist(buttonName) then
		return not (settingState == true)
	end

	ButtonSetStayDownFlag(buttonName, true)
	local uiPressed = ButtonGetPressedFlag(buttonName)
	local uiPressedBool = (uiPressed == true) or (uiPressed == 1)
	local current = (settingState == true)

	if uiPressedBool == current then
		return not current
	end

	return uiPressedBool
end

function WarbandComms.UISetEditBoxTextIfExists(editBoxName, textValue)
	if not editBoxName or not DoesWindowExist(editBoxName) then return end
	TextEditBoxSetText(editBoxName, towstring(textValue or ""))
end

function WarbandComms.UIPopulateComboBox(comboName, items, selectedIndex)
	if not comboName or not DoesWindowExist(comboName) then return end
	ComboBoxClearMenuItems(comboName)

	for _, item in ipairs(items or {}) do
		ComboBoxAddMenuItem(comboName, towstring(item))
	end

	if selectedIndex and selectedIndex > 0 then
		ComboBoxSetSelectedMenuItem(comboName, selectedIndex)
	end
end

local function GetReferenceState()
	WarbandComms.ReferenceControlState = WarbandComms.ReferenceControlState or {
		toggle = false,
		numeric = nil,
		comboIndex = 0,
		items = {},
	}
	return WarbandComms.ReferenceControlState
end

local function GetActiveWindowNameSafe()
	return SystemData.ActiveWindow and SystemData.ActiveWindow.name or nil
end

function WarbandComms.OnReferenceToggle()
	local state = GetReferenceState()
	local buttonName = GetActiveWindowNameSafe()
	state.toggle = WarbandComms.UIResolveCheckboxToggle(buttonName, state.toggle)
	WarbandComms.UIEnsureCheckboxState(buttonName, state.toggle)
end

function WarbandComms.OnReferenceNumericChanged()
	local state = GetReferenceState()
	local editBoxName = GetActiveWindowNameSafe()
	if not editBoxName or not DoesWindowExist(editBoxName) then return end

	local rawText = TextEditBoxGetText(editBoxName)
	local text = tostring(rawText or "")
	if WStringToString and type(rawText) == "wstring" then
		text = WStringToString(rawText)
	end

	local numeric = tonumber(text)
	if numeric then
		state.numeric = numeric
	end
end

function WarbandComms.OnReferenceComboChanged()
	local state = GetReferenceState()
	local comboName = GetActiveWindowNameSafe()
	if not comboName or not DoesWindowExist(comboName) then return end

	state.comboIndex = ComboBoxGetSelectedMenuItem(comboName) or 0
end

function WarbandComms.OnReferenceAdd()
	local state = GetReferenceState()
	local nextId = #state.items + 1
	state.items[nextId] = {
		id = nextId,
		toggle = state.toggle,
		numeric = state.numeric,
		comboIndex = state.comboIndex,
	}
end

function WarbandComms.OnReferenceDelete()
	local state = GetReferenceState()
	if #state.items > 0 then
		table.remove(state.items)
	end
end

local function ApplyControlLabelStyling()
	local softLabels = {
		"HeaderTextSizeLabel",
		"RowTextSizeLabel",
		"TrackerWidthLabel",
		"TrackerHeightLabel",
		"SizeApplyModeLabel",
		"BackgroundOpacityLabel",
		"HeaderToneLabel",
		"HeaderStyleLabel",
	}
	for _, suffix in ipairs(softLabels) do
		LabelSetTextColor(configWindow .. suffix, COLORS.softSetting[1], COLORS.softSetting[2], COLORS.softSetting[3])
	end

	local valueLabels = {
		"HeaderTextSizeValueText",
		"RowTextSizeValueText",
		"TrackerWidthValueText",
		"TrackerHeightValueText",
		"BackgroundOpacityValueText",
		"SizeApplyModeButtonValue",
		"HeaderToneButtonValue",
		"HeaderStyleButtonValue",
	}
	for _, suffix in ipairs(valueLabels) do
		LabelSetTextColor(configWindow .. suffix, COLORS.valueGold[1], COLORS.valueGold[2], COLORS.valueGold[3])
	end

	local plusMinusLabels = {
		"HeaderTextSizeDecreaseButtonLabel",
		"HeaderTextSizeIncreaseButtonLabel",
		"RowTextSizeDecreaseButtonLabel",
		"RowTextSizeIncreaseButtonLabel",
		"TrackerWidthDecreaseButtonLabel",
		"TrackerWidthIncreaseButtonLabel",
		"TrackerHeightDecreaseButtonLabel",
		"TrackerHeightIncreaseButtonLabel",
		"SizeApplyModeDecreaseButtonLabel",
		"SizeApplyModeIncreaseButtonLabel",
		"BackgroundOpacityDecreaseButtonLabel",
		"BackgroundOpacityIncreaseButtonLabel",
		"HeaderToneDecreaseButtonLabel",
		"HeaderToneIncreaseButtonLabel",
		"HeaderStyleDecreaseButtonLabel",
		"HeaderStyleIncreaseButtonLabel",
	}
	for _, suffix in ipairs(plusMinusLabels) do
		LabelSetTextColor(configWindow .. suffix, COLORS.valueGold[1], COLORS.valueGold[2], COLORS.valueGold[3])
	end
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

local function GetPreviousPresetValue(order, currentValue)
	for index, value in ipairs(order) do
		if value == currentValue then
			return order[((index - 2 + #order) % #order) + 1]
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

	LabelSetText(configWindow .. "TrackerTitle", L"Toggle All")
	LabelSetText(configWindow .. "TrackerGroupTitle", L"Trackers")
	local allEnabled = AreAllTrackersEnabled()
	WarbandComms.Settings.enabled = allEnabled
	ButtonSetPressedFlag("WarbandCommsConfigEnableTrackersButton", allEnabled)

	LabelSetText(configWindow .. "NotificationsTitle", L"Tracker Appearance")
	LabelSetText(configWindow .. "NotificationGroupTitle", L"Center Screen Notifications")
	LabelSetText(configWindow .. "HeaderTextSizeLabel", L"Header Text")
	LabelSetText(configWindow .. "RowTextSizeLabel", L"Row Text")
	LabelSetText(configWindow .. "HeaderTextSizeDecreaseButtonLabel", L"[-]")
	LabelSetText(configWindow .. "HeaderTextSizeIncreaseButtonLabel", L"[+]")
	LabelSetText(configWindow .. "RowTextSizeDecreaseButtonLabel", L"[-]")
	LabelSetText(configWindow .. "RowTextSizeIncreaseButtonLabel", L"[+]")
	LabelSetText(configWindow .. "TrackerWidthLabel", L"Box Width")
	LabelSetText(configWindow .. "TrackerHeightLabel", L"Box Height")
	LabelSetText(configWindow .. "TrackerWidthDecreaseButtonLabel", L"[-]")
	LabelSetText(configWindow .. "TrackerWidthIncreaseButtonLabel", L"[+]")
	LabelSetText(configWindow .. "TrackerHeightDecreaseButtonLabel", L"[-]")
	LabelSetText(configWindow .. "TrackerHeightIncreaseButtonLabel", L"[+]")
	LabelSetText(configWindow .. "SizeApplyModeLabel", L"Resize Mode")
	LabelSetText(configWindow .. "BackgroundOpacityLabel", L"Background")
	LabelSetText(configWindow .. "HeaderToneLabel", L"Header Tone")
	LabelSetText(configWindow .. "HeaderStyleLabel", L"Header Style")
	LabelSetText(configWindow .. "SizeApplyModeDecreaseButtonLabel", L"[-]")
	LabelSetText(configWindow .. "SizeApplyModeIncreaseButtonLabel", L"[+]")
	LabelSetText(configWindow .. "BackgroundOpacityDecreaseButtonLabel", L"[-]")
	LabelSetText(configWindow .. "BackgroundOpacityIncreaseButtonLabel", L"[+]")
	LabelSetText(configWindow .. "HeaderToneDecreaseButtonLabel", L"[-]")
	LabelSetText(configWindow .. "HeaderToneIncreaseButtonLabel", L"[+]")
	LabelSetText(configWindow .. "HeaderStyleDecreaseButtonLabel", L"[-]")
	LabelSetText(configWindow .. "HeaderStyleIncreaseButtonLabel", L"[+]")
	RefreshTextScaleLabels()
	RefreshSizeLabels()
	RefreshSizeModeLabel()
	RefreshBackgroundAlphaLabel()
	RefreshHeaderEmphasisLabels()
	ApplyControlLabelStyling()

	-- Dynamically add trackers
	local tracker_index = 0
	for _, trackerName in ipairs(GetOrderedTrackerNames(WarbandComms.Trackers)) do
		local window = configWindow .. trackerName:upper()

		CreateWindowFromTemplate(window, "WarbandCommsConfigTemplate", configWindow)
		WindowSetShowing(window, true)
		WindowSetDimensions(window, 300, 24) -- a tidy row height

		WindowClearAnchors(window)
        -- place rows under the header controls
		WindowAddAnchor(window, "topleft", configWindow, "topleft", LAYOUT.leftColumnX, LAYOUT.trackerRowsStartY + (tracker_index * LAYOUT.dynamicRowSpacingY))
		tracker_index = tracker_index + 1

		local buttonName = window .. "Button"
		local labelName  = window .. "Label"

		LabelSetText(labelName, GetTrackerLabel(trackerName))
		ButtonSetPressedFlag(buttonName, WarbandComms.Settings[trackerName] == true)

		SetEnabledLabelColor(labelName, WarbandComms.Settings[trackerName] == true)
	end

	-- dynamically add notifications
	local notification_index = 0
	for _, trackerName in ipairs(GetOrderedTrackerNames(WarbandComms.Notifications)) do
		local window = configWindow .. trackerName:upper() .. "NOTIFY"

		CreateWindowFromTemplate(window, "WarbandCommsConfigTemplate", configWindow)
		WindowSetShowing(window, true)
		WindowSetDimensions(window, 300, 24) -- a tidy row height

		WindowClearAnchors(window)
		-- place rows under the header controls
		WindowAddAnchor(window, "topleft", configWindow, "topleft", LAYOUT.rightColumnX, LAYOUT.notificationRowsStartY + (notification_index * LAYOUT.dynamicRowSpacingY))
		notification_index = notification_index + 1

		local buttonName = window .. "Button"
		local labelName  = window .. "Label"

		LabelSetText(labelName, GetTrackerLabel(trackerName))
		ButtonSetPressedFlag(buttonName, WarbandComms.Settings.notifications[trackerName] == true)

		local enabled = WarbandComms.Settings.notifications[trackerName] == true
		SetEnabledLabelColor(labelName, enabled)
	end
	-- Resize config window to fit all trackers
	local maxRows = math.max(tracker_index, notification_index)
	WindowSetDimensions(configWindow, LAYOUT.windowWidth, LAYOUT.baseWindowHeight + (maxRows * LAYOUT.dynamicRowSpacingY))
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

function WarbandComms.ResetHeaderTextSize()
	WarbandComms.Settings.headerTextScale = 1.0
	RefreshTextScaleLabels()
	ApplyTextScaleToAllTrackers()
end

function WarbandComms.ResetRowTextSize()
	WarbandComms.Settings.rowTextScale = 1.0
	RefreshTextScaleLabels()
	ApplyTextScaleToAllTrackers()
end

function WarbandComms.ToggleHeaderTone()
	WarbandComms.IncreaseHeaderTone()
end

function WarbandComms.DecreaseHeaderTone()
	WarbandComms.Settings.headerTone = GetPreviousPresetValue(HEADER_TONE_ORDER, WarbandComms.GetHeaderTone())
	RefreshHeaderEmphasisLabels()
	ApplyTextScaleToAllTrackers()
end

function WarbandComms.IncreaseHeaderTone()
	WarbandComms.Settings.headerTone = GetNextPresetValue(HEADER_TONE_ORDER, WarbandComms.GetHeaderTone())
	RefreshHeaderEmphasisLabels()
	ApplyTextScaleToAllTrackers()
end

function WarbandComms.ToggleHeaderStyle()
	WarbandComms.IncreaseHeaderStyle()
end

function WarbandComms.DecreaseHeaderStyle()
	WarbandComms.Settings.headerStyle = GetPreviousPresetValue(HEADER_STYLE_ORDER, WarbandComms.GetHeaderStyle())
	RefreshHeaderEmphasisLabels()
	ApplyTextScaleToAllTrackers()
end

function WarbandComms.IncreaseHeaderStyle()
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

function WarbandComms.ResetTrackerWidth()
	if WarbandComms.GetSizeApplyMode() == "uniform" then
		WarbandComms.Settings.trackerWidth = WarbandComms.DefaultTrackerWidth
		RefreshSizeLabels()
		ApplyTrackerSizeToAllTrackers()
	else
		local delta = WarbandComms.DefaultTrackerWidth - WarbandComms.GetTrackerWidth()
		WarbandComms.ChangeTrackerWidth(delta)
	end
end

function WarbandComms.DecreaseTrackerHeight()
	WarbandComms.ChangeTrackerHeight(-10)
end

function WarbandComms.IncreaseTrackerHeight()
	WarbandComms.ChangeTrackerHeight(10)
end

function WarbandComms.ResetTrackerHeight()
	if WarbandComms.GetSizeApplyMode() == "uniform" then
		WarbandComms.Settings.trackerHeight = WarbandComms.DefaultTrackerHeight
		RefreshSizeLabels()
		ApplyTrackerSizeToAllTrackers()
	else
		local delta = WarbandComms.DefaultTrackerHeight - WarbandComms.GetTrackerHeight()
		WarbandComms.ChangeTrackerHeight(delta)
	end
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

function WarbandComms.DecreaseSizeApplyMode()
	WarbandComms.ToggleSizeApplyMode()
end

function WarbandComms.IncreaseSizeApplyMode()
	WarbandComms.ToggleSizeApplyMode()
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

function WarbandComms.ResetBackgroundOpacity()
	WarbandComms.Settings.backgroundAlpha = 0.60
	RefreshBackgroundAlphaLabel()
	ApplyBackgroundAlphaToAllTrackers()
end

function WarbandComms.ToggleAllTrackers()
	local enabled = not AreAllTrackersEnabled()

	WarbandComms.Settings.enabled = enabled
	ButtonSetPressedFlag("WarbandCommsConfigEnableTrackersButton", enabled)

	for trackerName, _ in pairs(WarbandComms.Trackers) do
		WarbandComms.Settings[trackerName] = enabled
		local buttonName = WarbandComms.AddonName .. "Config" .. trackerName:upper() .. "Button"
		local labelName = WarbandComms.AddonName .. "Config" .. trackerName:upper() .. "Label"
		ButtonSetPressedFlag(buttonName, enabled)
		SetEnabledLabelColor(labelName, enabled)
		ApplyTrackerVisibility(trackerName)
	end
end

local function SyncMasterToggleFromTrackerStates()
	local allEnabled = AreAllTrackersEnabled()
	WarbandComms.Settings.enabled = allEnabled
	ButtonSetPressedFlag("WarbandCommsConfigEnableTrackersButton", allEnabled)
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
	SetEnabledLabelColor(WarbandComms.AddonName .. "Config" .. trackerName:upper() .. "Label", WarbandComms.Settings[trackerName] == true)
	SyncMasterToggleFromTrackerStates()

	ApplyTrackerVisibility(trackerName)
end
local configWindow = WarbandComms.AddonName .. "Config"

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

local function ApplyTextScaleToAllTrackers()
	for trackerName, _ in pairs(WarbandComms.Trackers) do
		WarbandComms.ApplyTextScale(trackerName)
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
	RefreshTextScaleLabels()

	-- Dynamically add trackers
	local tracker_index = 0
	for trackerName, _ in pairs(WarbandComms.Trackers) do
		local window = configWindow .. trackerName:upper()

		CreateWindowFromTemplate(window, "WarbandCommsConfigTemplate", configWindow)
		WindowSetShowing(window, true)
		WindowSetDimensions(window, 300, 24) -- a tidy row height

		WindowClearAnchors(window)
        -- place rows under the header controls
		WindowAddAnchor(window, "topleft", configWindow, "topleft", 20, 140 + (tracker_index * 40))
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
		WindowAddAnchor(window, "topleft", configWindow, "topleft", 350, 140 + (notification_index * 40))
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
	WindowSetDimensions(configWindow, 700, 190 + (tracker_index * 50))
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
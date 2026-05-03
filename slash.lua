

function WarbandComms.InitSlash()
    if LibSlash ~= nil then
		LibSlash.RegisterSlashCmd("warbandcomms", function (msg) WarbandComms.Slash(msg) end)
		LibSlash.RegisterSlashCmd("wb-comms", function (msg) WarbandComms.Slash(msg) end)
		LibSlash.RegisterSlashCmd("wbc", function (msg) WarbandComms.Slash(msg) end)
	end
end

function WarbandComms.PrintSlashHelp()
	local lines = {
		"[WarbandComms] Commands:",
		"/wbc - toggle config window",
		"/wbc clear - clear tracker UI data",
		"/wbc selfcheck - print protocol and runtime diagnostics",
		"/wbc help - show this help",
		"/wbc testboxes - run tracker-box test harness (test builds)",
		"/wbc testcenter - show LTC/ID center-screen notification samples (test builds)",
		"/wbc selftest - toggle /say self-test mode (test builds)",
	}

	for _, line in ipairs(lines) do
		EA_ChatWindow.Print(towstring(line))
	end
end

function WarbandComms.Slash(msg)
	local command = ""
	if msg then
		command = tostring(msg)
		command = string.match(command, "^%s*(.-)%s*$") or ""
		command = string.lower(command)
	end

	if command == "" then
		WindowSetShowing(WarbandComms.configWindow, not WindowGetShowing(WarbandComms.configWindow))
	else
		if command == "clear" then
			WarbandComms.ClearUI()
		elseif command == "testboxes" or command == "test" then
			if WarbandComms.StartTest then
				WarbandComms.StartTest()
			else
				EA_ChatWindow.Print(towstring("[WarbandComms] Test harness is only available in test builds."))
			end
		elseif command == "testcenter" or command == "test-center" or command == "test center" then
			if WarbandComms.StartCenterNotificationTest then
				WarbandComms.StartCenterNotificationTest()
			else
				EA_ChatWindow.Print(towstring("[WarbandComms] Center test is only available in test builds."))
			end
        elseif command == "selftest" then
            WarbandComms.selfTest = not WarbandComms.selfTest
			EA_ChatWindow.Print(towstring("[WarbandComms] selfTest is now " .. tostring(WarbandComms.selfTest)))
            WarbandComms.ChatChannels[SystemData.ChatLogFilters.SAY] = WarbandComms.selfTest
        elseif command == "selfcheck" then
			WarbandComms.PrintSelfCheck()
        elseif command == "help" then
			WarbandComms.PrintSlashHelp()
        end
	end
end
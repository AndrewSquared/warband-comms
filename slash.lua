

function WarbandComms.InitSlash()
    if LibSlash ~= nil then
		LibSlash.RegisterSlashCmd("warbandcomms", function (msg) WarbandComms.Slash(msg) end)
		LibSlash.RegisterSlashCmd("wb-comms", function (msg) WarbandComms.Slash(msg) end)
		LibSlash.RegisterSlashCmd("wbc", function (msg) WarbandComms.Slash(msg) end)
	end
end

function WarbandComms.Slash(msg)
	if not msg or msg == "" then
		WindowSetShowing(WarbandComms.configWindow, not WindowGetShowing(WarbandComms.configWindow))
	else
		if msg == "clear" then
			WarbandComms.ClearUI()
        elseif msg == "test" then
            WarbandComms.StartTest()
        elseif msg == "selftest" then
            WarbandComms.selfTest = not WarbandComms.selfTest
			EA_ChatWindow.Print(towstring("[WarbandComms] selfTest is now " .. tostring(WarbandComms.selfTest)))
            WarbandComms.ChatChannels[SystemData.ChatLogFilters.SAY] = WarbandComms.selfTest
        end
	end
end
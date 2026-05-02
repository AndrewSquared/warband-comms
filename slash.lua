

function WarbandComms.InitSlash()
    if LibSlash ~= nil then
		LibSlash.RegisterSlashCmd("warbandcomms", function (msg) WarbandComms.Slash(msg) end)
		LibSlash.RegisterSlashCmd("wb-comms", function (msg) WarbandComms.Slash(msg) end)
		LibSlash.RegisterSlashCmd("wbc", function (msg) WarbandComms.Slash(msg) end)
		LibSlash.RegisterSlashCmd("retwbcomms", function (msg) WarbandComms.DeprecatedRetwbcommsSlash(msg) end)
		LibSlash.RegisterSlashCmd("rwc", function (msg) WarbandComms.DeprecatedRwcSlash(msg) end)
		LibSlash.RegisterSlashCmd("wbcomms", function (msg) WarbandComms.Slash(msg) end)
		LibSlash.RegisterSlashCmd("ret", function (msg) WarbandComms.DeprecatedRetSlash(msg) end)
	end
end

function WarbandComms.DeprecatedRetwbcommsSlash(msg)
	EA_ChatWindow.Print(towstring("[WarbandComms] '/retwbcomms' is deprecated. Use /wbc (or /wb-comms)."))
	WarbandComms.Slash(msg)
end

function WarbandComms.DeprecatedRwcSlash(msg)
	EA_ChatWindow.Print(towstring("[WarbandComms] '/rwc' is deprecated. Use /wbc (or /wb-comms)."))
	WarbandComms.Slash(msg)
end

function WarbandComms.DeprecatedRetSlash(msg)
	EA_ChatWindow.Print(towstring("[WarbandComms] '/ret' is deprecated. Use /wbc (or /wb-comms)."))
	WarbandComms.Slash(msg)
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
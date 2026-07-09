--Returns a corrected formated player name
function WarbandComms.FixString (str)
	if (str == nil) then return nil end
	local str = towstring(str)
	local pos = str:find (L"^", 1, true)
	if (pos) then str = str:sub (1, pos - 1) end
	return str
end

function WarbandComms.isItemInArray(item, array)
	for i, v in pairs(array) do
			if v == item then
				return true
			end
    end
	return false
end


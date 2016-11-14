local K, C, L = select(2, ...):unpack()

local tostring = tostring
local CreateFrame = CreateFrame
local inBattlefield = inBattlefield
local GetCurrentMapAreaID = GetCurrentMapAreaID
local GetBattlefieldStatus = GetBattlefieldStatus
local GetMaxBattlefieldID = GetMaxBattlefieldID
local CanUseSoulstone = CanUseSoulstone
local HasSoulstone = HasSoulstone

-- AUTO RESURRECTION IN PVP
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_DEAD")
frame:SetScript("OnEvent", function(self, event)
	local inBattlefield = false
	for i = 1, GetMaxBattlefieldID() do
		local status = GetBattlefieldStatus(i)
		if status == "active" then inBattlefield = true end
	end

	if not (HasSoulstone() and CanUseSoulstone()) then
		SetMapToCurrentZone()
		local areaID = GetCurrentMapAreaID() or 0
		if areaID == 501 or areaID == 708 or areaID == 978 or areaID == 1009 or areaID == 1011 or inBattlefield == true then
			RepopMe()
		end
	end
end)
